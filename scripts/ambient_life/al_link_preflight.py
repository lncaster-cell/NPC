#!/usr/bin/env python3
"""Offline linked-area graph preflight validator for Ambient Life.

Input JSON can be either:
1) {"areas": [ ... ]}
2) [ ... ]

Each area entry should contain:
- area_tag (str) or tag (str)
- locals map or flat locals with:
  - al_link_count (int >= 0)
  - al_link_0..al_link_{count-1} (str area tags)
"""

from __future__ import annotations

import argparse
import json
import sys
from collections import defaultdict, deque
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

AL_LINK_TARGET_DEGREE_MIN = 2
AL_LINK_TARGET_DEGREE_MAX = 4
AL_LINK_HUB_DEGREE_MAX = 6
AL_LINK_CLUSTER_WARN_MAX = 8
AL_LINK_CLUSTER_CRITICAL_MAX = 12


@dataclass
class ValidationIssue:
    level: str
    area_tag: str
    code: str
    details: str


def is_strict_int(value: Any) -> bool:
    # Exclude bool explicitly: JSON booleans are not valid integer locals.
    return isinstance(value, int) and not isinstance(value, bool)


def _read_input(path: Path) -> list[Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if isinstance(payload, dict):
        areas = payload.get("areas", [])
    elif isinstance(payload, list):
        areas = payload
    else:
        raise ValueError("JSON root must be an object with key 'areas' or an array")

    if not isinstance(areas, list):
        raise ValueError("'areas' must be an array")
    return areas


def _extract_locals(area_row: dict[str, Any]) -> dict[str, Any]:
    nested = area_row.get("locals")
    if isinstance(nested, dict):
        return nested

    skip_keys = {"area_tag", "tag", "name", "locals"}
    return {key: value for key, value in area_row.items() if key not in skip_keys}


def _append_issue(issues: list[ValidationIssue], level: str, area_tag: str, code: str, details: str) -> None:
    issues.append(ValidationIssue(level=level, area_tag=area_tag, code=code, details=details))


def _parse_areas(rows: list[Any], issues: list[ValidationIssue]) -> tuple[dict[str, set[str]], dict[str, int]]:
    graph: dict[str, set[str]] = defaultdict(set)
    declared_counts: dict[str, int] = {}

    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            _append_issue(issues, "ERROR", f"<idx:{index}>", "invalid_row_type", f"expected object, got {type(row).__name__}")
            continue

        area_tag = str(row.get("area_tag", row.get("tag", f"<idx:{index}>"))).strip()
        if not area_tag:
            area_tag = f"<idx:{index}>"
            _append_issue(issues, "ERROR", area_tag, "missing_area_tag", "area_tag/tag must be non-empty string")

        if area_tag in graph:
            _append_issue(issues, "ERROR", area_tag, "duplicate_area_tag", "area appears multiple times in input")

        locals_map = _extract_locals(row)

        link_count = locals_map.get("al_link_count", 0)
        if not is_strict_int(link_count) or link_count < 0:
            _append_issue(issues, "ERROR", area_tag, "invalid_link_count", "al_link_count must be int >= 0")
            link_count = 0

        declared_counts[area_tag] = link_count

        seen_targets: set[str] = set()
        for i in range(link_count):
            key = f"al_link_{i}"
            raw_target = locals_map.get(key)
            target = str(raw_target).strip() if raw_target is not None else ""

            if not target:
                _append_issue(issues, "ERROR", area_tag, "missing_link_slot", f"{key} must be non-empty string")
                continue

            if target == area_tag:
                _append_issue(issues, "ERROR", area_tag, "self_link", f"{key} points to itself ({target})")

            if target in seen_targets:
                _append_issue(issues, "ERROR", area_tag, "duplicate_link_target", f"duplicate link target={target}")
            else:
                seen_targets.add(target)
                graph[area_tag].add(target)

        for key in sorted(k for k in locals_map if k.startswith("al_link_")):
            if key == "al_link_count":
                continue
            suffix = key.removeprefix("al_link_")
            if not suffix.isdigit():
                _append_issue(issues, "WARN", area_tag, "non_numeric_link_slot", f"unexpected link key {key}")
                continue
            if int(suffix) >= link_count:
                _append_issue(issues, "WARN", area_tag, "link_slot_outside_count", f"{key} is set but al_link_count={link_count}")

        # Degree policy checks follow operator guide thresholds.
        degree = len(graph.get(area_tag, set()))
        if degree > AL_LINK_HUB_DEGREE_MAX:
            _append_issue(
                issues,
                "ERROR",
                area_tag,
                "degree_above_hub_max",
                f"degree={degree} exceeds hub max={AL_LINK_HUB_DEGREE_MAX}",
            )
        elif degree > AL_LINK_TARGET_DEGREE_MAX:
            _append_issue(
                issues,
                "WARN",
                area_tag,
                "degree_above_target",
                f"degree={degree} above target range {AL_LINK_TARGET_DEGREE_MIN}..{AL_LINK_TARGET_DEGREE_MAX}",
            )

    return graph, declared_counts


def _validate_graph_semantics(graph: dict[str, set[str]], declared_counts: dict[str, int], issues: list[ValidationIssue]) -> None:
    all_areas = set(declared_counts.keys())

    for area_tag, targets in graph.items():
        for target in targets:
            if target not in all_areas:
                _append_issue(issues, "ERROR", area_tag, "unknown_link_target", f"target area {target!r} not found in payload")
                continue
            if area_tag not in graph.get(target, set()):
                _append_issue(issues, "WARN", area_tag, "asymmetric_link", f"{area_tag} -> {target} exists but reverse edge is missing")

    # Component-size analysis via weakly connected components.
    undirected: dict[str, set[str]] = {area: set() for area in all_areas}
    for src, targets in graph.items():
        for dst in targets:
            if dst in all_areas:
                undirected[src].add(dst)
                undirected[dst].add(src)

    visited: set[str] = set()
    for start in sorted(all_areas):
        if start in visited:
            continue

        queue: deque[str] = deque([start])
        component: list[str] = []
        visited.add(start)

        while queue:
            node = queue.popleft()
            component.append(node)
            for neighbor in undirected.get(node, set()):
                if neighbor not in visited:
                    visited.add(neighbor)
                    queue.append(neighbor)

        component_size = len(component)
        details = f"size={component_size} members={','.join(sorted(component))}"
        anchor = sorted(component)[0]

        if component_size > AL_LINK_CLUSTER_CRITICAL_MAX:
            _append_issue(issues, "ERROR", anchor, "cluster_size_critical", details)
        elif component_size > AL_LINK_CLUSTER_WARN_MAX:
            _append_issue(issues, "WARN", anchor, "cluster_size_warn", details)


def validate_links(rows: list[Any]) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    graph, declared_counts = _parse_areas(rows, issues)
    _validate_graph_semantics(graph, declared_counts, issues)
    return issues


def build_report(issues: list[ValidationIssue]) -> dict[str, Any]:
    errors = sum(1 for issue in issues if issue.level == "ERROR")
    warns = sum(1 for issue in issues if issue.level == "WARN")
    return {
        "status": "ERROR" if errors > 0 else "OK",
        "summary": {
            "errors": errors,
            "warnings": warns,
            "total": len(issues),
        },
        "issues": [
            asdict(issue)
            for issue in sorted(issues, key=lambda i: (i.level, i.area_tag, i.code, i.details))
        ],
    }


def print_text_report(report: dict[str, Any]) -> None:
    if not report["issues"]:
        print("[OK] linked-area preflight passed: no issues found")
        return

    for issue in report["issues"]:
        print(
            f"[{issue['level']}] area={issue['area_tag']} code={issue['code']} details={issue['details']}"
        )

    summary = report["summary"]
    print(f"\nSummary: errors={summary['errors']} warnings={summary['warnings']} total={summary['total']}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambient Life linked-area graph offline")
    parser.add_argument("--input", required=True, help="Path to JSON with area locals")
    parser.add_argument("--format", choices=("json", "text"), default="json", help="Output format")
    args = parser.parse_args()

    try:
        rows = _read_input(Path(args.input))
    except Exception as exc:
        print(json.dumps({"status": "FATAL", "reason": str(exc)}), file=sys.stderr)
        return 2

    report = build_report(validate_links(rows))

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_text_report(report)

    return 1 if report["summary"]["errors"] > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
