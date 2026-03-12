#!/usr/bin/env python3
"""Run Ambient Life preflight suite and emit a unified report.

Preferred launch mode (from repository root):
    python3 -m scripts.ambient_life.run_preflight_suite ...

Direct standalone execution is also supported:
    python3 scripts/ambient_life/run_preflight_suite.py ...
"""

from __future__ import annotations

import argparse
import concurrent.futures
import json
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


def _run_route_check(route_input: Path) -> list[al_route_preflight.ValidationIssue]:
    route_rows = al_route_preflight._read_input(route_input)
    return al_route_preflight.validate_route_markup(route_rows)


def _run_link_check(link_input: Path) -> list[al_link_preflight.ValidationIssue]:
    link_rows = al_link_preflight._read_input(link_input)
    return al_link_preflight.validate_links(link_rows)


def _run_locals_check(locals_input: Path) -> list[al_locals_preflight.ValidationIssue]:
    locals_payload = al_locals_preflight._read_input(locals_input)
    return al_locals_preflight.validate_locals(locals_payload)


def _build_report(route_input: Path, link_input: Path, locals_input: Path, *, parallel: bool = False) -> dict[str, Any]:
    if parallel:
        with concurrent.futures.ThreadPoolExecutor(max_workers=3) as executor:
            route_future = executor.submit(_run_route_check, route_input)
            link_future = executor.submit(_run_link_check, link_input)
            locals_future = executor.submit(_run_locals_check, locals_input)
            route_issues = route_future.result()
            link_issues = link_future.result()
            locals_issues = locals_future.result()
    else:
        route_issues = _run_route_check(route_input)
        link_issues = _run_link_check(link_input)
        locals_issues = _run_locals_check(locals_input)

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

    return {
        "status": "ERROR" if summary["error"] else "OK",
        "inputs": {
            "route": str(route_input),
            "link": str(link_input),
            "locals": str(locals_input),
        },
        "summary": summary,
        "issues": sorted(issues, key=lambda item: (item["severity"], item["check"], item["path"], item["code"], item["message"])),
    }


def _print_text_summary(report: dict[str, Any]) -> None:
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

    print("\nIssues:")
    for issue in report["issues"]:
        print(
            f"- [{issue['severity']}] check={issue['check']} code={issue['code']} "
            f"path={issue['path']} message={issue['message']}"
        )


def main() -> int:
    parser = argparse.ArgumentParser(description="Run Ambient Life preflight suite")
    parser.add_argument("--route-input", required=True, help="Path to route preflight JSON input")
    parser.add_argument("--link-input", required=True, help="Path to link preflight JSON input")
    parser.add_argument("--locals-input", required=True, help="Path to locals preflight JSON input")
    parser.add_argument("--parallel", action="store_true", help="Run route/link/locals checks in parallel")
    parser.add_argument("--format", choices=("json", "text"), default="json", help="Output format")
    args = parser.parse_args()

    report = _build_report(Path(args.route_input), Path(args.link_input), Path(args.locals_input), parallel=args.parallel)

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        _print_text_summary(report)

    return 1 if report["summary"]["error"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
