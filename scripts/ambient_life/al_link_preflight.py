#!/usr/bin/env python3
"""Offline linked-graph preflight validator for Ambient Life area links.

Input JSON modes:
1) {"areas": [ ... ]}
2) [ ... ]

Area entry supports either nested locals object:
  {"area_tag": "market", "locals": {"al_link_count": 2, "al_link_0": "gate", "al_link_1": "tavern"}}
or flat fields on the area object.

Each area must have a unique `area_tag` in the input payload.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

TARGET_DEGREE_MIN = 2
TARGET_DEGREE_MAX = 4
HUB_DEGREE_MAX = 6
LINK_KEY_RE = re.compile(r"^al_link_(\d+)$")


@dataclass
class ValidationIssue:
    level: str
    area_tag: str
    code: str
    reason: str


def is_strict_int(value: Any) -> bool:
    return isinstance(value, int) and not isinstance(value, bool)


def _read_tag(value: Any) -> str | None:
    if not isinstance(value, str):
        return None
    tag = value.strip()
    return tag or None


def _read_input(path: Path) -> list[dict[str, Any]]:
    payload = json.loads(path.read_text(encoding="utf-8"))

    if isinstance(payload, dict):
        if "areas" not in payload:
            raise ValueError("missing required key 'areas'")
        areas = payload["areas"]
    elif isinstance(payload, list):
        areas = payload
    else:
        raise ValueError("JSON root must be an object with key 'areas' or an array")

    if not isinstance(areas, list):
        raise ValueError("'areas' must be an array")

    return areas


def _extract_locals(raw: dict[str, Any]) -> tuple[dict[str, Any], bool]:
    if "locals" in raw:
        locals_payload = raw.get("locals")
        if isinstance(locals_payload, dict):
            return locals_payload, False
        return {}, True

    return {k: v for k, v in raw.items() if k not in {"area_tag", "tag", "name", "locals"}}, False


def _append_issue(issues: list[ValidationIssue], level: str, area_tag: str, code: str, reason: str) -> None:
    issues.append(ValidationIssue(level=level, area_tag=area_tag, code=code, reason=reason))


def validate_links(rows: list[dict[str, Any]], fail_fast: bool = False, max_errors: int | None = None) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []
    adjacency: dict[str, set[str]] = {}
    error_limit = max_errors if fail_fast and max_errors is not None else (1 if fail_fast else None)
    error_count = 0

    def add_issue(level: str, area_tag: str, code: str, reason: str) -> bool:
        nonlocal error_count
        _append_issue(issues, level, area_tag, code, reason)
        if level == "ERROR":
            error_count += 1
        return error_limit is not None and error_count >= error_limit

    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            if add_issue("ERROR", f"<idx:{index}>", "invalid_row_type", f"expected object, got {type(row).__name__}"):
                return issues
            continue

        area_tag_raw = row.get("area_tag")
        area_tag = _read_tag(area_tag_raw)
        object_id = f"<idx:{index}>"
        issue_area_tag = area_tag or object_id
        if area_tag is None:
            code = (
                "missing_area_tag"
                if area_tag_raw is None or (isinstance(area_tag_raw, str) and area_tag_raw.strip() == "")
                else "invalid_area_tag_type"
            )
            if add_issue("ERROR", object_id, code, "area_tag must be non-empty string"):
                return issues

        locals_map, invalid_locals = _extract_locals(row)
        if invalid_locals:
            if add_issue("ERROR", issue_area_tag, "invalid_locals_type", "locals key exists but is not an object"):
                return issues

        link_count = locals_map.get("al_link_count", 0)
        if not is_strict_int(link_count) or link_count < 0:
            if add_issue("ERROR", issue_area_tag, "invalid_link_count", "al_link_count must be int >= 0"):
                return issues
            link_count = 0

        indexed_links: dict[int, str] = {}
        for key, value in locals_map.items():
            if key == "al_link_count":
                continue

            match = LINK_KEY_RE.match(key)
            if not match:
                if key.startswith("al_link_"):
                    if add_issue("ERROR", issue_area_tag, "invalid_link_slot_key", f"{key} must use numeric suffix"):
                        return issues
                continue

            slot = int(match.group(1))
            if slot >= link_count:
                if add_issue("ERROR", issue_area_tag, "link_slot_out_of_range", f"{key} is set but al_link_count={link_count}"):
                    return issues
                continue

            if not isinstance(value, str) or not value.strip():
                if add_issue("ERROR", issue_area_tag, "invalid_link_slot_value", f"{key} must be non-empty string"):
                    return issues
                continue

            indexed_links[slot] = value.strip()

        for slot in range(link_count):
            if slot not in indexed_links:
                if add_issue("ERROR", issue_area_tag, "missing_link_slot", f"al_link_{slot} must be set for al_link_count={link_count}"):
                    return issues

        values = list(indexed_links.values())
        if len(values) != len(set(values)):
            if add_issue("ERROR", issue_area_tag, "duplicate_links", "duplicate area tags in al_link_* are not allowed"):
                return issues

        for target_tag in values:
            if area_tag is None:
                continue
            if target_tag == area_tag:
                if add_issue("ERROR", area_tag, "self_link", f"self-link detected: {area_tag} -> {target_tag}"):
                    return issues

        degree = len(set(values))
        if degree > HUB_DEGREE_MAX:
            if add_issue(
                "ERROR",
                issue_area_tag,
                "degree_exceeds_hub_max",
                f"degree={degree} exceeds max allowed {HUB_DEGREE_MAX}",
            ):
                return issues
        elif degree > TARGET_DEGREE_MAX:
            _append_issue(
                issues,
                "WARN",
                issue_area_tag,
                "degree_above_target",
                f"degree={degree} above target {TARGET_DEGREE_MIN}..{TARGET_DEGREE_MAX}",
            )
        elif degree < TARGET_DEGREE_MIN:
            _append_issue(
                issues,
                "WARN",
                issue_area_tag,
                "degree_below_target",
                f"degree={degree} below target {TARGET_DEGREE_MIN}..{TARGET_DEGREE_MAX}",
            )

        if area_tag is None:
            continue

        if area_tag in adjacency:
            if add_issue("ERROR", area_tag, "duplicate_area_tag", f"area_tag {area_tag!r} appears more than once in payload"):
                return issues
            continue

        adjacency[area_tag] = set(values)

    for src, targets in adjacency.items():
        for dst in sorted(targets):
            if dst not in adjacency:
                if add_issue("ERROR", src, "unknown_link_target", f"link target area {dst!r} not present in payload"):
                    return issues
                continue

            if src not in adjacency[dst]:
                if add_issue("ERROR", src, "symmetry_mismatch", f"{src} -> {dst} exists but reverse edge is missing"):
                    return issues

    return issues


def build_report(issues: list[ValidationIssue]) -> dict[str, Any]:
    errors = sum(1 for issue in issues if issue.level == "ERROR")
    warns = sum(1 for issue in issues if issue.level == "WARN")
    return {
        "status": "ERROR" if errors else "OK",
        "summary": {"errors": errors, "warnings": warns, "total": len(issues)},
        "issues": [asdict(issue) for issue in sorted(issues, key=lambda i: (i.level, i.area_tag, i.code, i.reason))],
    }


def print_text_report(report: dict[str, Any]) -> None:
    if not report["issues"]:
        print("[OK] link preflight passed: no issues found")
        return

    for issue in report["issues"]:
        print(f"[{issue['level']}] area={issue['area_tag']} code={issue['code']} reason={issue['reason']}")

    summary = report["summary"]
    print(f"\nSummary: errors={summary['errors']} warnings={summary['warnings']} total={summary['total']}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambient Life linked-area graph offline")
    parser.add_argument("--input", required=True, help="Path to JSON with area link locals")
    parser.add_argument("--format", choices=("json", "text"), default="json", help="Output format")
    parser.add_argument("--fail-fast", action="store_true", help="Stop validation after first error (or after --max-errors)")
    parser.add_argument("--max-errors", type=int, default=None, help="Error limit used with --fail-fast")
    args = parser.parse_args()
    if args.max_errors is not None and args.max_errors < 1:
        parser.error("--max-errors must be >= 1")

    try:
        rows = _read_input(Path(args.input))
    except Exception as exc:
        print(json.dumps({"status": "FATAL", "reason": str(exc)}), file=sys.stderr)
        return 2

    report = build_report(validate_links(rows, fail_fast=args.fail_fast, max_errors=args.max_errors))

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_text_report(report)

    return 1 if report["summary"]["errors"] > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
