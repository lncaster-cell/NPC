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


_SEVERITY_RANK = {"error": 0, "warn": 1, "info": 2}


def _order_issues(issues: list[dict[str, Any]], sort_mode: str) -> list[dict[str, Any]]:
    if sort_mode == "strict":
        return sorted(
            issues,
            key=lambda item: (
                _SEVERITY_RANK.get(item["severity"], 99),
                item["check"],
                item["path"],
                item["code"],
                item["message"],
            ),
        )
    if sort_mode == "grouped":
        return sorted(
            issues,
            key=lambda item: (
                item["check"],
                _SEVERITY_RANK.get(item["severity"], 99),
            ),
        )
    return issues


def _run_route_check(route_input: Path) -> list[al_route_preflight.ValidationIssue]:
    route_rows = al_route_preflight._read_input(route_input)
    return al_route_preflight.validate_route_markup(route_rows)


def _run_link_check(link_input: Path) -> list[al_link_preflight.ValidationIssue]:
    link_rows = al_link_preflight._read_input(link_input)
    return al_link_preflight.validate_links(link_rows)


def _run_locals_check(locals_input: Path) -> list[al_locals_preflight.ValidationIssue]:
    locals_payload = al_locals_preflight._read_input(locals_input)
    return al_locals_preflight.validate_locals(locals_payload)


def _build_report(
    route_input: Path,
    link_input: Path,
    locals_input: Path,
    *,
    parallel: bool = False,
    sort_mode: str = "none",
) -> dict[str, Any]:
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
    summary = {"error": 0, "warn": 0, "info": 0, "total": 0}

    def bump_summary(severity: str) -> None:
        normalized = _normalize_severity(severity)
        summary[normalized] += 1
        summary["total"] += 1

    def add_issue(payload: dict[str, Any]) -> None:
        issues.append(payload)
        bump_summary(payload["severity"])

    for issue in route_issues:
        add_issue(
            {
                "check": "route",
                "severity": _normalize_severity(issue.level),
                "code": issue.code,
                "path": _route_path(issue),
                "message": issue.details,
            }
        )

    for issue in link_issues:
        add_issue(
            {
                "check": "link",
                "severity": _normalize_severity(issue.level),
                "code": issue.code,
                "path": _link_path(issue),
                "message": issue.reason,
            }
        )

    for issue in locals_issues:
        add_issue(
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
            add_issue(
                {
                    "check": check_name,
                    "severity": "info",
                    "code": "ok",
                    "path": check_name,
                    "message": "preflight passed without issues",
                }
            )

    issues = sorted(
        issues,
        key=lambda item: (
            _SEVERITY_RANK.get(item["severity"], 99),
            item["check"],
            item["path"],
            item["code"],
            item["message"],
        ),
    )

    code_counts = Counter(issue["code"] for issue in issues)
    check_counts = Counter(issue["check"] for issue in issues)
    severity_counts = Counter(issue["severity"] for issue in issues)

    return {
        "status": "ERROR" if summary["error"] else "OK",
        "inputs": {
            "route": str(route_input),
            "link": str(link_input),
            "locals": str(locals_input),
        },
        "summary": summary,
        "aggregates": {
            "code": dict(code_counts),
            "check": dict(check_counts),
            "severity": dict(severity_counts),
        },
        "issues": _order_issues(issues, sort_mode),
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
    code_aggregates = report.get("aggregates", {}).get("code", {})
    if not code_aggregates:
        code_aggregates = Counter(issue["code"] for issue in report["issues"])

    top_codes = sorted(
        ((code, count) for code, count in code_aggregates.items() if code != "ok"),
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
    parser.add_argument("--parallel", action="store_true", help="Run route/link/locals checks in parallel")
    parser.add_argument("--format", choices=("json", "text"), default="json", help="Output format")
    parser.add_argument(
        "--detail-limit",
        type=int,
        default=50,
        help="Maximum number of issues printed in text format",
    )
    sort_group = parser.add_mutually_exclusive_group()
    sort_group.add_argument(
        "--deterministic-sort",
        action="store_true",
        help="Enable grouped deterministic ordering (check, severity) while preserving issue arrival order inside groups",
    )
    sort_group.add_argument(
        "--strict-deterministic-sort",
        action="store_true",
        help="Enable strict deterministic ordering with full issue sort (heavier than grouped ordering)",
    )
    args = parser.parse_args()

    sort_mode = "none"
    if args.strict_deterministic_sort:
        sort_mode = "strict"
    elif args.deterministic_sort:
        sort_mode = "grouped"

    report = _build_report(
        Path(args.route_input),
        Path(args.link_input),
        Path(args.locals_input),
        parallel=args.parallel,
        sort_mode=sort_mode,
    )

    if args.format == "json":
        print(json.dumps(report, ensure_ascii=False, indent=2))
    else:
        _print_text_summary(report, args.detail_limit)

    return 1 if report["summary"]["error"] else 0


if __name__ == "__main__":
    raise SystemExit(main())
