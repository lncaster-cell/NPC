import unittest

from scripts.ambient_life import al_link_preflight, al_locals_preflight, al_route_preflight, run_preflight_suite


class SuiteSortModeTests(unittest.TestCase):
    def test_suite_none_keeps_arrival_order(self):
        issues = [
            {"check": "route", "severity": "warn", "code": "b", "path": "p2", "message": "m2"},
            {"check": "link", "severity": "error", "code": "a", "path": "p1", "message": "m1"},
        ]

        ordered = run_preflight_suite._order_issues(issues, sort_mode="none")

        self.assertEqual(ordered, issues)

    def test_suite_grouped_sorts_check_and_severity_but_keeps_inner_order(self):
        issues = [
            {"check": "route", "severity": "warn", "code": "r1", "path": "p", "message": "m"},
            {"check": "route", "severity": "warn", "code": "r2", "path": "p", "message": "m"},
            {"check": "link", "severity": "error", "code": "l1", "path": "p", "message": "m"},
        ]

        ordered = run_preflight_suite._order_issues(issues, sort_mode="grouped")

        self.assertEqual([item["code"] for item in ordered], ["l1", "r1", "r2"])


class ValidatorSortModeTests(unittest.TestCase):
    def test_link_report_none_keeps_arrival_order(self):
        issues = [
            al_link_preflight.ValidationIssue("WARN", "b", "z", "r2"),
            al_link_preflight.ValidationIssue("ERROR", "a", "a", "r1"),
        ]

        report = al_link_preflight.build_report(issues, sort_mode="none")

        self.assertEqual([item["code"] for item in report["issues"]], ["z", "a"])

    def test_locals_report_strict_sorts_all_fields(self):
        issues = [
            al_locals_preflight.ValidationIssue("WARN", "waypoint", "z", "z", "z"),
            al_locals_preflight.ValidationIssue("ERROR", "area", "a", "a", "a"),
        ]

        report = al_locals_preflight.build_report(issues, sort_mode="strict")

        self.assertEqual([item["level"] for item in report["issues"]], ["ERROR", "WARN"])

    def test_route_grouped_sort_preserves_order_inside_group(self):
        issues = [
            al_route_preflight.ValidationIssue("WARN", "a", "r", "c1", "d1"),
            al_route_preflight.ValidationIssue("WARN", "b", "r", "c2", "d2"),
            al_route_preflight.ValidationIssue("ERROR", "c", "r", "c3", "d3"),
        ]

        ordered = al_route_preflight._order_issues(issues, sort_mode="grouped")

        self.assertEqual([issue.code for issue in ordered], ["c3", "c1", "c2"])


if __name__ == "__main__":
    unittest.main()
