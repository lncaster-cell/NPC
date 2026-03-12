#!/usr/bin/env python3
"""Offline route markup preflight validator for Ambient Life routes.

Input JSON can be either:
1) {"waypoints": [ ... ]}
2) [ ... ]

Each waypoint entry should contain:
- area_tag (str)
- route_tag (str)
- waypoint_tag (str, optional but recommended)
- al_step (int)
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path
from typing import Any

AL_ROUTE_MAX_STEPS = 16


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
    payload = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(payload, dict):
        if "waypoints" not in payload:
            raise ValueError("missing required key 'waypoints'")
        waypoints = payload["waypoints"]
    elif isinstance(payload, list):
        waypoints = payload
    else:
        raise ValueError("JSON root must be an object with key 'waypoints' or an array")

    if not isinstance(waypoints, list):
        raise ValueError("'waypoints' must be an array")
    return waypoints


def is_strict_int(value: Any) -> bool:
    # Exclude bool explicitly: JSON boolean is not a valid integer value for route/locals config fields.
    return isinstance(value, int) and not isinstance(value, bool)


def _as_waypoint(raw: dict[str, Any], index: int) -> tuple[Waypoint | None, ValidationIssue | None]:
    area_tag = str(raw.get("area_tag", "")).strip()
    route_tag = str(raw.get("route_tag", "")).strip()
    waypoint_tag = str(raw.get("waypoint_tag", f"<idx:{index}>"))
    step_raw = raw.get("al_step")
    al_bed_id = str(raw.get("al_bed_id", "")).strip()

    if not area_tag or not route_tag:
        return None, ValidationIssue(
            level="WARN",
            area_tag=area_tag or "<unknown-area>",
            route_tag=route_tag or "<unknown-route>",
            code="missing_route_or_area_tag",
            details=f"waypoint={waypoint_tag}",
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


def print_report(issues: list[ValidationIssue]) -> None:
    if not issues:
        print("[OK] route preflight passed: no issues found")
        return

    for issue in sorted(issues, key=lambda x: (x.level, x.area_tag, x.route_tag, x.code, x.details)):
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
    args = parser.parse_args()

    try:
        rows = _read_input(Path(args.input))
    except Exception as exc:
        print(f"[FATAL] failed to read input: {exc}", file=sys.stderr)
        return 2

    issues = validate_route_markup(rows)
    print_report(issues)

    return 1 if any(i.level == "ERROR" for i in issues) else 0


if __name__ == "__main__":
    raise SystemExit(main())
