#!/usr/bin/env python3
"""Offline route markup preflight validator for Ambient Life routes.

Input JSON can be either:
1) {"waypoints": [ ... ]}
2) [ ... ]

Each waypoint entry should contain:
- area_tag (str)
- route_tag (str)
- waypoint_tag (str, required)
- al_step (int)

Expected fields contract:
- Missing or invalid `waypoint_tag` is a validation error (`missing_waypoint_tag` / `invalid_waypoint_tag_type`).
"""

from __future__ import annotations

import argparse
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from scripts.ambient_life.preflight_common import is_strict_int, read_json_list_input, read_tag, tag_error_code

AL_ROUTE_MAX_STEPS = 16

_SEVERITY_RANK = {"ERROR": 0, "WARN": 1, "INFO": 2}


@dataclass
class Waypoint:
    area_tag: str
    route_tag: str
    waypoint_tag: str
    al_step: int
    al_bed_id: str


@dataclass
class ValidationIssue:
    level: str
    area_tag: str
    route_tag: str
    code: str
    details: str


def _read_input(path: Path) -> list[dict[str, Any]]:
    return read_json_list_input(path, key="waypoints")


def _as_waypoint(raw: dict[str, Any], index: int) -> tuple[Waypoint | None, ValidationIssue | None]:
    area_tag_raw = raw.get("area_tag")
    area_tag = read_tag(area_tag_raw)
    route_tag_raw = raw.get("route_tag")
    route_tag = read_tag(route_tag_raw)
    waypoint_tag_raw = raw.get("waypoint_tag")
    waypoint_tag = read_tag(waypoint_tag_raw) or f"<idx:{index}>"
    step_raw = raw.get("al_step")

    al_bed_id_raw = raw.get("al_bed_id")
    if al_bed_id_raw is None:
        al_bed_id = ""
    elif not isinstance(al_bed_id_raw, str):
        return None, ValidationIssue(
            level="ERROR",
            area_tag=area_tag or "<unknown-area>",
            route_tag=route_tag or "<unknown-route>",
            code="invalid_bed_id_type",
            details=f"waypoint={waypoint_tag} al_bed_id={al_bed_id_raw!r}",
        )
    else:
        al_bed_id = al_bed_id_raw.strip()

    if area_tag is None:
        code = tag_error_code(area_tag_raw, missing_code="missing_area_tag", invalid_type_code="invalid_area_tag_type")
        return None, ValidationIssue(
            level="ERROR",
            area_tag="<unknown-area>",
            route_tag=route_tag or "<unknown-route>",
            code=code,
            details=f"waypoint={waypoint_tag}",
        )

    if route_tag is None:
        code = tag_error_code(route_tag_raw, missing_code="missing_route_tag", invalid_type_code="invalid_route_tag_type")
        return None, ValidationIssue(
            level="ERROR",
            area_tag=area_tag,
            route_tag="<unknown-route>",
            code=code,
            details=f"waypoint={waypoint_tag}",
        )

    if waypoint_tag.startswith(f"<idx:{index}>") and read_tag(waypoint_tag_raw) is None:
        code = tag_error_code(
            waypoint_tag_raw,
            missing_code="missing_waypoint_tag",
            invalid_type_code="invalid_waypoint_tag_type",
        )
        return None, ValidationIssue(
            level="ERROR",
            area_tag=area_tag,
            route_tag=route_tag,
            code=code,
            details=f"waypoint=<idx:{index}>",
        )

    if not is_strict_int(step_raw):
        return None, ValidationIssue(
            level="ERROR",
            area_tag=area_tag,
            route_tag=route_tag,
            code="invalid_step_type",
            details=f"waypoint={waypoint_tag} al_step={step_raw!r}",
        )

    return Waypoint(area_tag, route_tag, waypoint_tag, step_raw, al_bed_id), None


def _sleep_suffix(waypoint_tag: str) -> tuple[str, str] | None:
    for suffix in ("_approach", "_pose"):
        if waypoint_tag.endswith(suffix):
            return waypoint_tag[: -len(suffix)], suffix
    return None


def validate_route_markup(rows: list[dict[str, Any]]) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    grouped: dict[tuple[str, str], list[Waypoint]] = defaultdict(list)
    route_to_areas: dict[str, set[str]] = defaultdict(set)
    area_waypoint_tags: dict[str, set[str]] = defaultdict(set)
    route_waypoint_tags: dict[tuple[str, str], set[str]] = defaultdict(set)
    waypoint_tag_to_areas: dict[str, set[str]] = defaultdict(set)
    bed_id_to_areas: dict[str, set[str]] = defaultdict(set)
    sleep_steps: list[Waypoint] = []

    for index, raw in enumerate(rows):
        if not isinstance(raw, dict):
            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag="<unknown-area>",
                    route_tag="<unknown-route>",
                    code="invalid_row_type",
                    details=f"index={index} type={type(raw).__name__}",
                )
            )
            continue

        waypoint, parse_issue = _as_waypoint(raw, index)
        if parse_issue:
            issues.append(parse_issue)
        if not waypoint:
            continue

        grouped[(waypoint.area_tag, waypoint.route_tag)].append(waypoint)
        route_to_areas[waypoint.route_tag].add(waypoint.area_tag)
        area_waypoint_tags[waypoint.area_tag].add(waypoint.waypoint_tag)
        route_waypoint_tags[(waypoint.area_tag, waypoint.route_tag)].add(waypoint.waypoint_tag)
        waypoint_tag_to_areas[waypoint.waypoint_tag].add(waypoint.area_tag)

        if waypoint.al_bed_id:
            sleep_steps.append(waypoint)
            bed_id_to_areas[waypoint.al_bed_id].add(waypoint.area_tag)

        sleep_meta = _sleep_suffix(waypoint.waypoint_tag)
        if sleep_meta and waypoint.al_bed_id and waypoint.al_bed_id != sleep_meta[0]:
            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag=waypoint.area_tag,
                    route_tag=waypoint.route_tag,
                    code="sleep_bed_id_tag_mismatch",
                    details=(
                        f"waypoint={waypoint.waypoint_tag} al_bed_id={waypoint.al_bed_id} "
                        f"expected={sleep_meta[0]}"
                    ),
                )
            )

    for (area_tag, route_tag), waypoints in grouped.items():
        step_to_waypoint: dict[int, str] = {}
        valid_steps: set[int] = set()

        for wp in waypoints:
            if wp.al_step < 0 or wp.al_step >= AL_ROUTE_MAX_STEPS:
                issues.append(
                    ValidationIssue(
                        level="ERROR",
                        area_tag=area_tag,
                        route_tag=route_tag,
                        code="invalid_step_range",
                        details=f"waypoint={wp.waypoint_tag} al_step={wp.al_step} expected=0..{AL_ROUTE_MAX_STEPS - 1}",
                    )
                )
                continue

            if wp.al_step in step_to_waypoint:
                issues.append(
                    ValidationIssue(
                        level="ERROR",
                        area_tag=area_tag,
                        route_tag=route_tag,
                        code="duplicate_step",
                        details=(
                            f"step={wp.al_step} waypoint={wp.waypoint_tag} "
                            f"already_used_by={step_to_waypoint[wp.al_step]}"
                        ),
                    )
                )
                continue

            step_to_waypoint[wp.al_step] = wp.waypoint_tag
            valid_steps.add(wp.al_step)

        if not valid_steps:
            continue

        if 0 not in valid_steps:
            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag=area_tag,
                    route_tag=route_tag,
                    code="missing_step_0",
                    details="route has no valid al_step=0",
                )
            )
            continue

        for expected in range(0, len(valid_steps)):
            if expected not in valid_steps:
                issues.append(
                    ValidationIssue(
                        level="ERROR",
                        area_tag=area_tag,
                        route_tag=route_tag,
                        code="non_contiguous_steps",
                        details=f"missing_step={expected} present_steps={sorted(valid_steps)}",
                    )
                )
                break

    for route_tag, area_tags in route_to_areas.items():
        if len(area_tags) <= 1:
            continue

        ordered = ",".join(sorted(area_tags))
        for area_tag in sorted(area_tags):
            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag=area_tag,
                    route_tag=route_tag,
                    code="area_inconsistency",
                    details=f"route_tag appears in multiple areas: {ordered}",
                )
            )

    for sleep_step in sleep_steps:
        expected_tags = (
            f"{sleep_step.al_bed_id}_approach",
            f"{sleep_step.al_bed_id}_pose",
        )
        for expected_tag in expected_tags:
            if expected_tag in route_waypoint_tags[(sleep_step.area_tag, sleep_step.route_tag)]:
                continue

            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag=sleep_step.area_tag,
                    route_tag=sleep_step.route_tag,
                    code="sleep_pair_point_missing",
                    details=(
                        f"waypoint={sleep_step.waypoint_tag} al_bed_id={sleep_step.al_bed_id} "
                        f"missing={expected_tag}"
                    ),
                )
            )

    for bed_id, area_tags in bed_id_to_areas.items():
        if len(area_tags) <= 1:
            continue

        ordered = ",".join(sorted(area_tags))
        for area_tag in sorted(area_tags):
            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag=area_tag,
                    route_tag="<sleep>",
                    code="sleep_bed_area_inconsistency",
                    details=f"al_bed_id={bed_id} used across multiple areas: {ordered}",
                )
            )

    for waypoint_tag, area_tags in waypoint_tag_to_areas.items():
        sleep_meta = _sleep_suffix(waypoint_tag)
        if not sleep_meta or len(area_tags) <= 1:
            continue

        ordered = ",".join(sorted(area_tags))
        for area_tag in sorted(area_tags):
            issues.append(
                ValidationIssue(
                    level="ERROR",
                    area_tag=area_tag,
                    route_tag="<sleep>",
                    code="sleep_waypoint_area_inconsistency",
                    details=f"waypoint={waypoint_tag} appears in multiple areas: {ordered}",
                )
            )

    return issues


def _order_issues(issues: list[ValidationIssue], sort_mode: str) -> list[ValidationIssue]:
    if sort_mode == "strict":
        return sorted(issues, key=lambda x: (x.level, x.area_tag, x.route_tag, x.code, x.details))
    if sort_mode == "grouped":
        return sorted(issues, key=lambda x: (_SEVERITY_RANK.get(x.level, 99), x.code))
    return issues


def print_report(issues: list[ValidationIssue], sort_mode: str = "none") -> None:
    if not issues:
        print("[OK] route preflight passed: no issues found")
        return

    for issue in _order_issues(issues, sort_mode):
        print(
            f"[{issue.level}] area={issue.area_tag} route={issue.route_tag} "
            f"code={issue.code} {issue.details}"
        )

    error_count = sum(1 for i in issues if i.level == "ERROR")
    warn_count = sum(1 for i in issues if i.level == "WARN")
    print(f"\nSummary: errors={error_count} warnings={warn_count} total={len(issues)}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambient Life route markup offline")
    parser.add_argument("--input", required=True, help="Path to JSON with waypoint route markup")
    sort_group = parser.add_mutually_exclusive_group()
    sort_group.add_argument(
        "--deterministic-sort",
        action="store_true",
        help="Enable grouped deterministic ordering (severity/code) while preserving issue arrival order inside groups",
    )
    sort_group.add_argument(
        "--strict-deterministic-sort",
        action="store_true",
        help="Enable strict deterministic ordering with full issue sort",
    )
    args = parser.parse_args()

    try:
        rows = _read_input(Path(args.input))
    except Exception as exc:
        print(f"[FATAL] failed to read input: {exc}", file=sys.stderr)
        return 2

    issues = validate_route_markup(rows)

    sort_mode = "none"
    if args.strict_deterministic_sort:
        sort_mode = "strict"
    elif args.deterministic_sort:
        sort_mode = "grouped"

    print_report(issues, sort_mode=sort_mode)

    return 1 if any(i.level == "ERROR" for i in issues) else 0


if __name__ == "__main__":
    raise SystemExit(main())
