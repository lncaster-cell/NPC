#!/usr/bin/env python3
"""Offline locals preflight validator for Ambient Life content objects.

Expected JSON input shape:
{
  "npcs": [
    {"npc_tag": "npc_a", "locals": {"alwp0": "market_route", "al_default_activity": 1}}
  ],
  "waypoints": [
    {
      "area_tag": "area_market",
      "route_tag": "market_route",
      "waypoint_tag": "market_0",
      "locals": {"al_step": 0}
    }
  ],
  "areas": [
    {"area_tag": "area_market", "locals": {"al_link_count": 1, "al_link_0": "area_gate"}}
  ]
}

For compatibility, object locals may be provided directly on the object
without nested "locals".
"""

from __future__ import annotations

import argparse
import json
import sys
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Any

AL_ROUTE_MAX_STEPS = 16
NPC_ROUTE_SLOTS = tuple(range(6))
NPC_ROLE_MIN = 0
NPC_ROLE_MAX = 2


@dataclass
class ValidationIssue:
    level: str
    scope: str
    object_id: str
    code: str
    reason: str


def _read_input(path: Path) -> dict[str, Any]:
    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise ValueError("JSON root must be an object")

    return {
        "npcs": payload.get("npcs", []),
        "waypoints": payload.get("waypoints", []),
        "areas": payload.get("areas", []),
    }


def _extract_locals(raw: dict[str, Any], reserved_fields: set[str]) -> tuple[dict[str, Any], bool]:
    if "locals" in raw:
        locals_payload = raw.get("locals")
        if isinstance(locals_payload, dict):
            return locals_payload, False
        return {}, True

    return {k: v for k, v in raw.items() if k not in reserved_fields}, False


def _append_issue(issues: list[ValidationIssue], level: str, scope: str, object_id: str, code: str, reason: str) -> None:
    issues.append(ValidationIssue(level=level, scope=scope, object_id=object_id, code=code, reason=reason))


def is_strict_int(value: Any) -> bool:
    # Exclude bool explicitly: JSON boolean is not a valid integer value for route/locals config fields.
    return isinstance(value, int) and not isinstance(value, bool)

def _is_non_empty_string(value: Any) -> bool:
    return isinstance(value, str) and value.strip() != ""


def _validate_npcs(rows: list[Any], issues: list[ValidationIssue]) -> None:
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            _append_issue(issues, "ERROR", "npc", f"<idx:{index}>", "invalid_row_type", f"expected object, got {type(row).__name__}")
            continue

        npc_tag = str(row.get("npc_tag", row.get("tag", f"<idx:{index}>"))).strip() or f"<idx:{index}>"
        locals_map, has_invalid_locals_type = _extract_locals(row, {"npc_tag", "tag", "name", "locals"})
        if has_invalid_locals_type:
            _append_issue(
                issues,
                "ERROR",
                "npc",
                npc_tag,
                "invalid_locals_type",
                "[CI_FILTER:INVALID_LOCALS_TYPE] locals key exists but is not an object",
            )

        if not is_strict_int(locals_map.get("al_default_activity")):
            _append_issue(issues, "ERROR", "npc", npc_tag, "invalid_default_activity", "al_default_activity must be int")

        has_primary_route = False
        has_legacy_route = False
        for slot in NPC_ROUTE_SLOTS:
            primary_key = f"alwp{slot}"
            legacy_key = f"AL_WP_S{slot}"
            primary_val = locals_map.get(primary_key)
            legacy_val = locals_map.get(legacy_key)

            if primary_val is not None and not isinstance(primary_val, str):
                _append_issue(issues, "ERROR", "npc", npc_tag, "invalid_route_local_type", f"{primary_key} must be string")
            if legacy_val is not None and not isinstance(legacy_val, str):
                _append_issue(issues, "ERROR", "npc", npc_tag, "invalid_route_local_type", f"{legacy_key} must be string")

            if _is_non_empty_string(primary_val):
                has_primary_route = True
            if _is_non_empty_string(legacy_val):
                has_legacy_route = True
                _append_issue(issues, "WARN", "npc", npc_tag, "legacy_route_alias_in_use", f"{legacy_key} is used")

            if _is_non_empty_string(primary_val) and _is_non_empty_string(legacy_val) and primary_val != legacy_val:
                _append_issue(
                    issues,
                    "WARN",
                    "npc",
                    npc_tag,
                    "conflicting_route_slot_values",
                    f"slot={slot} has different values in {primary_key} and {legacy_key}",
                )

        if not has_primary_route and not has_legacy_route:
            _append_issue(issues, "WARN", "npc", npc_tag, "missing_route_slots", "no route tags in alwp0..alwp5 or AL_WP_S0..AL_WP_S5")

        role_val = locals_map.get("al_npc_role")
        if role_val is not None:
            if not is_strict_int(role_val) or role_val < NPC_ROLE_MIN or role_val > NPC_ROLE_MAX:
                _append_issue(issues, "ERROR", "npc", npc_tag, "invalid_npc_role", "al_npc_role must be int in range 0..2")

        safe_wp_val = locals_map.get("al_safe_wp")
        if safe_wp_val is not None and not _is_non_empty_string(safe_wp_val):
            _append_issue(issues, "ERROR", "npc", npc_tag, "invalid_safe_wp", "al_safe_wp must be non-empty string waypoint tag")

        for flag_name in ("al_allow_all", "al_force_witness"):
            flag_val = locals_map.get(flag_name)
            if flag_val is None:
                continue
            if not is_strict_int(flag_val) or flag_val not in (0, 1):
                _append_issue(issues, "WARN", "npc", npc_tag, "invalid_disturbed_flag", f"{flag_name} should be 0 or 1")

        for tag_name in ("al_owner_tag", "al_allowed_tag"):
            tag_val = locals_map.get(tag_name)
            if tag_val is None:
                continue
            if not _is_non_empty_string(tag_val):
                _append_issue(issues, "WARN", "npc", npc_tag, "invalid_disturbed_tag", f"{tag_name} should be non-empty string")


def _validate_waypoints(rows: list[Any], issues: list[ValidationIssue]) -> None:
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            _append_issue(issues, "ERROR", "waypoint", f"<idx:{index}>", "invalid_row_type", f"expected object, got {type(row).__name__}")
            continue

        wp_tag = str(row.get("waypoint_tag", row.get("tag", f"<idx:{index}>"))).strip() or f"<idx:{index}>"
        locals_map, has_invalid_locals_type = _extract_locals(row, {"waypoint_tag", "tag", "name", "area_tag", "route_tag", "locals"})
        if has_invalid_locals_type:
            _append_issue(
                issues,
                "ERROR",
                "waypoint",
                wp_tag,
                "invalid_locals_type",
                "[CI_FILTER:INVALID_LOCALS_TYPE] locals key exists but is not an object",
            )

        step_val = locals_map.get("al_step")
        if not is_strict_int(step_val):
            _append_issue(issues, "ERROR", "waypoint", wp_tag, "invalid_step_type", "al_step must be int")
        elif step_val < 0 or step_val >= AL_ROUTE_MAX_STEPS:
            _append_issue(issues, "ERROR", "waypoint", wp_tag, "invalid_step_range", f"al_step must be in range 0..{AL_ROUTE_MAX_STEPS - 1}")

        trans_type = locals_map.get("al_trans_type")
        has_any_trans_key = any(key in locals_map for key in ("al_trans_type", "al_trans_src_wp", "al_trans_dst_wp"))
        if has_any_trans_key:
            if not is_strict_int(trans_type) or trans_type not in (1, 2):
                _append_issue(issues, "ERROR", "waypoint", wp_tag, "invalid_transition_type", "al_trans_type must be 1 or 2")

            for key in ("al_trans_src_wp", "al_trans_dst_wp"):
                if not _is_non_empty_string(locals_map.get(key)):
                    _append_issue(issues, "ERROR", "waypoint", wp_tag, "invalid_transition_endpoint", f"{key} must be non-empty string")

        bed_id = locals_map.get("al_bed_id")
        has_bed = bed_id is not None
        if has_bed and not _is_non_empty_string(bed_id):
            _append_issue(issues, "ERROR", "waypoint", wp_tag, "invalid_bed_id", "al_bed_id must be non-empty string")

        if has_bed and _is_non_empty_string(bed_id):
            expected_approach = f"{bed_id}_approach"
            expected_pose = f"{bed_id}_pose"
            if wp_tag not in (expected_approach, expected_pose):
                _append_issue(
                    issues,
                    "WARN",
                    "waypoint",
                    wp_tag,
                    "unexpected_bed_waypoint_tag",
                    f"for al_bed_id={bed_id!r} expected tag {expected_approach!r} or {expected_pose!r}",
                )

        if has_any_trans_key and has_bed:
            _append_issue(issues, "ERROR", "waypoint", wp_tag, "mixed_transition_and_sleep_step", "waypoint cannot be both transition and sleep step")


def _validate_areas(rows: list[Any], issues: list[ValidationIssue]) -> None:
    for index, row in enumerate(rows):
        if not isinstance(row, dict):
            _append_issue(issues, "ERROR", "area", f"<idx:{index}>", "invalid_row_type", f"expected object, got {type(row).__name__}")
            continue

        area_tag = str(row.get("area_tag", row.get("tag", f"<idx:{index}>"))).strip() or f"<idx:{index}>"
        locals_map, has_invalid_locals_type = _extract_locals(row, {"area_tag", "tag", "name", "locals"})
        if has_invalid_locals_type:
            _append_issue(
                issues,
                "ERROR",
                "area",
                area_tag,
                "invalid_locals_type",
                "[CI_FILTER:INVALID_LOCALS_TYPE] locals key exists but is not an object",
            )

        link_count = locals_map.get("al_link_count")
        if link_count is None:
            link_count = 0
        if not is_strict_int(link_count) or link_count < 0:
            _append_issue(issues, "ERROR", "area", area_tag, "invalid_link_count", "al_link_count must be int >= 0")
            link_count = 0

        for i in range(link_count):
            key = f"al_link_{i}"
            if not _is_non_empty_string(locals_map.get(key)):
                _append_issue(issues, "ERROR", "area", area_tag, "missing_link_slot", f"{key} must be non-empty string")

        for key in sorted(k for k in locals_map if k.startswith("al_link_")):
            if key == "al_link_count":
                continue
            suffix = key.removeprefix("al_link_")
            if not suffix.isdigit():
                _append_issue(issues, "WARN", "area", area_tag, "non_numeric_link_slot", f"unexpected link key {key}")
                continue
            if int(suffix) >= link_count:
                _append_issue(issues, "WARN", "area", area_tag, "link_slot_outside_count", f"{key} is set but al_link_count={link_count}")

        for flag_name in ("al_debug", "al_perf"):
            if flag_name not in locals_map:
                continue
            flag_val = locals_map.get(flag_name)
            if not is_strict_int(flag_val) or flag_val < 0:
                _append_issue(issues, "WARN", "area", area_tag, "invalid_debug_perf_flag", f"{flag_name} should be int >= 0")


def validate_locals(payload: dict[str, Any]) -> list[ValidationIssue]:
    issues: list[ValidationIssue] = []

    npcs = payload.get("npcs", [])
    waypoints = payload.get("waypoints", [])
    areas = payload.get("areas", [])

    if not isinstance(npcs, list):
        _append_issue(issues, "ERROR", "payload", "npcs", "invalid_collection_type", "npcs must be array")
        npcs = []
    if not isinstance(waypoints, list):
        _append_issue(issues, "ERROR", "payload", "waypoints", "invalid_collection_type", "waypoints must be array")
        waypoints = []
    if not isinstance(areas, list):
        _append_issue(issues, "ERROR", "payload", "areas", "invalid_collection_type", "areas must be array")
        areas = []

    _validate_npcs(npcs, issues)
    _validate_waypoints(waypoints, issues)
    _validate_areas(areas, issues)

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
        "issues": [asdict(issue) for issue in sorted(issues, key=lambda i: (i.level, i.scope, i.object_id, i.code, i.reason))],
    }


def print_text_report(report: dict[str, Any]) -> None:
    if not report["issues"]:
        print("[OK] locals preflight passed: no issues found")
        return

    for issue in report["issues"]:
        print(
            f"[{issue['level']}] scope={issue['scope']} object={issue['object_id']} "
            f"code={issue['code']} reason={issue['reason']}"
        )

    summary = report["summary"]
    print(f"\nSummary: errors={summary['errors']} warnings={summary['warnings']} total={summary['total']}")


def main() -> int:
    parser = argparse.ArgumentParser(description="Validate Ambient Life locals offline")
    parser.add_argument("--input", required=True, help="Path to JSON with NPC/waypoint/area locals")
    parser.add_argument("--format", choices=("json", "text"), default="json", help="Output format")
    args = parser.parse_args()

    try:
        payload = _read_input(Path(args.input))
    except Exception as exc:
        print(json.dumps({"status": "FATAL", "reason": str(exc)}), file=sys.stderr)
        return 2

    report = build_report(validate_locals(payload))

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        print_text_report(report)

    return 1 if report["summary"]["errors"] > 0 else 0


if __name__ == "__main__":
    raise SystemExit(main())
