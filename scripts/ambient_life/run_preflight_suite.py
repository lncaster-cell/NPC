#!/usr/bin/env python3
"""Run Ambient Life preflight suite and emit a unified report.

Preferred launch mode (from repository root):
    python3 -m scripts.ambient_life.run_preflight_suite ...

Direct standalone execution is also supported:
    python3 scripts/ambient_life/run_preflight_suite.py ...
"""

from __future__ import annotations

import argparse
import json
from collections import Counter
from pathlib import Path
from typing import Any

try:
    from scripts.ambient_life import al_link_preflight, al_locals_preflight, al_route_preflight
except ImportError:
    import al_link_preflight
    import al_locals_preflight
    import al_route_preflight


def _route_path(issue: al_route_preflight.ValidationIssue) -> str:
    return f"area:{issue.area_tag}/route:{issue.route_tag}"


def _link_path(issue: al_link_preflight.ValidationIssue) -> str:
    return f"area:{issue.area_tag}"


def _locals_path(issue: al_locals_preflight.ValidationIssue) -> str:
    return f"{issue.scope}:{issue.object_id}"


def _normalize_severity(level: str) -> str:
    lowered = level.strip().lower()
    if lowered in {"error", "warn", "info"}:
        return lowered
    return "info"


def _severity_order(severity: str) -> int:
    order = {"error": 0, "warn": 1, "info": 2}
    return order.get(severity, 3)


def _build_aggregates(issues: list[dict[str, Any]]) -> dict[str, dict[str, int]]:
    return {
        "check": dict(sorted(Counter(issue["check"] for issue in issues).items())),
        "code": dict(sorted(Counter(issue["code"] for issue in issues).items())),
        "severity": dict(sorted(Counter(issue["severity"] for issue in issues).items())),
    }


def _build_report(route_input: Path, link_input: Path, locals_input: Path) -> dict[str, Any]:
    route_rows = al_route_preflight._read_input(route_input)
    link_rows = al_link_preflight._read_input(link_input)
    locals_payload = al_locals_preflight._read_input(locals_input)

    route_issues = al_route_preflight.validate_route_markup(route_rows)
    link_issues = al_link_preflight.validate_links(link_rows)
    locals_issues = al_locals_preflight.validate_locals(locals_payload)

    issues: list[dict[str, Any]] = []

    for issue in route_issues:
        issues.append(
            {
                "check": "route",
                "severity": _normalize_severity(issue.level),
                "code": issue.code,
                "path": _route_path(issue),
                "message": issue.details,
            }
        )

    for issue in link_issues:
        issues.append(
            {
                "check": "link",
                "severity": _normalize_severity(issue.level),
                "code": issue.code,
                "path": _link_path(issue),
                "message": issue.reason,
            }
        )

    for issue in locals_issues:
        issues.append(
            {
                "check": "locals",
                "severity": _normalize_severity(issue.level),
                "code": issue.code,
                "path": _locals_path(issue),
                "message": issue.reason,
            }
        )

    for check_name, check_issues in (
        ("route", route_issues),
        ("link", link_issues),
        ("locals", locals_issues),
    ):
        if not check_issues:
            issues.append(
                {
                    "check": check_name,
                    "severity": "info",
                    "code": "ok",
                    "path": check_name,
                    "message": "preflight passed without issues",
                }
            )

    summary = {
        "error": sum(1 for issue in issues if issue["severity"] == "error"),
        "warn": sum(1 for issue in issues if issue["severity"] == "warn"),
        "info": sum(1 for issue in issues if issue["severity"] == "info"),
        "total": len(issues),
    }

    issues = sorted(
        issues,
        key=lambda item: (
            _severity_order(item["severity"]),
            item["check"],
            item["path"],
            item["code"],
            item["message"],
        ),
    )

    return {
        "status": "ERROR" if summary["error"] else "OK",
        "inputs": {
            "route": str(route_input),
            "link": str(link_input),
            "locals": str(locals_input),
        },
        "summary": summary,
        "aggregates": _build_aggregates(issues),
        "issues": issues,
    }


def _print_text_summary(report: dict[str, Any], detail_limit: int) -> None:
    print(f"[suite:{report['status']}] Ambient Life preflight suite")
    print(
        "Summary: "
        f"error={report['summary']['error']} "
        f"warn={report['summary']['warn']} "
        f"info={report['summary']['info']} "
        f"total={report['summary']['total']}"
    )

    if not report["issues"]:
        return

    error_issues = [issue for issue in report["issues"] if issue["severity"] == "error"]
    print("\nCritical errors:")
    if error_issues:
        for issue in error_issues:
            print(
                f"- code={issue['code']} check={issue['check']} "
                f"path={issue['path']} message={issue['message']}"
            )
    else:
        print("- none")

    print("\nTop issue codes:")
    top_codes = sorted(
        (
            (code, count)
            for code, count in report["aggregates"]["code"].items()
            if code != "ok"
        ),
        key=lambda item: (-item[1], item[0]),
    )
    if top_codes:
        for code, count in top_codes[:5]:
            print(f"- code={code} count={count}")
    else:
        print("- none")

    print("\nIssues:")
    displayed = report["issues"][: max(detail_limit, 0)]
    for issue in displayed:
        print(
            f"- [{issue['severity']}] check={issue['check']} code={issue['code']} "
            f"path={issue['path']} message={issue['message']}"
        )

    omitted = len(report["issues"]) - len(displayed)
    if omitted > 0:
        print(f"... and {omitted} more issues (use --format json for full report)")


def main() -> int:
    parser = argparse.ArgumentParser(description="Run Ambient Life preflight suite")
    parser.add_argument("--route-input", required=True, help="Path to route preflight JSON input")
    parser.add_argument("--link-input", required=True, help="Path to link preflight JSON input")
    parser.add_argument("--locals-input", required=True, help="Path to locals preflight JSON input")
    parser.add_argument("--format", choices=("json", "text"), default="json", help="Output format")
    parser.add_argument(
        "--detail-limit",
        type=int,
        default=20,
        help="Max number of detailed issue lines in text mode",
    )
    args = parser.parse_args()

    report = _build_report(Path(args.route_input), Path(args.link_input), Path(args.locals_input))

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        _print_text_summary(report, args.detail_limit)

    return 1 if report["summary"]["error"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
