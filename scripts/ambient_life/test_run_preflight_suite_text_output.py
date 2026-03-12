import io
import unittest
from unittest import mock

from scripts.ambient_life import run_preflight_suite
from scripts.ambient_life.preflight_issue_utils import make_issue_context


class PreflightSuiteTextOutputTests(unittest.TestCase):
    def test_build_report_exposes_code_aggregates(self):
        route_issue = run_preflight_suite.al_route_preflight.ValidationIssue(
            "ERROR",
            "area_a",
            "route_a",
            "route.missing_step",
            make_issue_context("missing step"),
        )
        link_issue = run_preflight_suite.al_link_preflight.ValidationIssue(
            "WARN", "area_a", "link.duplicate", make_issue_context("duplicate link")
        )
        locals_issue = run_preflight_suite.al_locals_preflight.ValidationIssue(
            "WARN", "npc", "npc_01", "link.duplicate", make_issue_context("duplicate local")
        )

        with (
            mock.patch.object(run_preflight_suite, "_run_route_check", return_value=[route_issue]),
            mock.patch.object(run_preflight_suite, "_run_link_check", return_value=[link_issue]),
            mock.patch.object(run_preflight_suite, "_run_locals_check", return_value=[locals_issue]),
        ):
            report = run_preflight_suite._build_report(
                route_input=run_preflight_suite.Path("route.json"),
                link_input=run_preflight_suite.Path("link.json"),
                locals_input=run_preflight_suite.Path("locals.json"),
            )

        self.assertEqual(report["aggregates"]["code"]["route.missing_step"], 1)
        self.assertEqual(report["aggregates"]["code"]["link.duplicate"], 2)

    def test_main_text_output_prints_top_issue_codes_without_key_error(self):
        report = {
            "status": "ERROR",
            "summary": {"error": 1, "warn": 2, "info": 0, "total": 3},
            "issues": [
                {
                    "check": "route",
                    "severity": "error",
                    "code": "route.missing_step",
                    "path": "area:a/route:r",
                    "message": "missing step 0",
                },
                {
                    "check": "link",
                    "severity": "warn",
                    "code": "link.duplicate",
                    "path": "area:a",
                    "message": "duplicate",
                },
                {
                    "check": "locals",
                    "severity": "warn",
                    "code": "link.duplicate",
                    "path": "npc:npc_01",
                    "message": "duplicate",
                },
            ],
            "aggregates": {
                "severity": {"error": 1, "warn": 2, "info": 0},
                "check": {"route": 1, "link": 1, "locals": 1},
                "code": {"route.missing_step": 1, "link.duplicate": 2},
            },
        }

        stdout = io.StringIO()
        with (
            mock.patch.object(run_preflight_suite, "_build_report", return_value=report),
            mock.patch(
                "sys.argv",
                [
                    "run_preflight_suite.py",
                    "--route-input",
                    "route.json",
                    "--link-input",
                    "link.json",
                    "--locals-input",
                    "locals.json",
                    "--format",
                    "text",
                ],
            ),
            mock.patch("sys.stdout", stdout),
        ):
            exit_code = run_preflight_suite.main()

        output = stdout.getvalue()
        self.assertEqual(exit_code, 1)
        self.assertIn("Top issue codes:", output)
        self.assertIn("- code=link.duplicate count=2", output)
        self.assertIn("- code=route.missing_step count=1", output)


if __name__ == "__main__":
    unittest.main()
