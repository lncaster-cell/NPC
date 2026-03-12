import json
import tempfile
import unittest
from pathlib import Path

from scripts.ambient_life.run_preflight_suite import _build_report


class PreflightSuiteParallelModeTests(unittest.TestCase):
    def test_parallel_and_sequential_modes_match_summary_and_issue_codes(self):
        route_payload = {
            "waypoints": [
                {
                    "area_tag": "inn_01",
                    "route_tag": "route_a",
                    "waypoint_tag": "bed_1_approach",
                    "al_step": 0,
                    "al_bed_id": "bed_1",
                }
            ]
        }
        link_payload = [
            {
                "area_tag": "market",
                "locals": {
                    "al_link_count": 1,
                    "al_link_0": "gate",
                },
            },
            {
                "area_tag": "market",
                "locals": {
                    "al_link_count": 1,
                    "al_link_0": "dock",
                },
            },
        ]
        locals_payload = {
            "npcs": [
                {
                    "npc_tag": "merchant_01",
                    "locals": {
                        "al_default_activity": 1,
                        "alwp0": "market_rute",
                    },
                }
            ],
            "waypoints": [
                {
                    "area_tag": "area_market",
                    "route_tag": "market_route",
                    "waypoint_tag": "market_0",
                    "locals": {"al_step": 0},
                }
            ],
            "areas": [],
        }

        with tempfile.TemporaryDirectory() as temp_dir:
            temp_path = Path(temp_dir)
            route_input = temp_path / "route.json"
            link_input = temp_path / "link.json"
            locals_input = temp_path / "locals.json"

            route_input.write_text(json.dumps(route_payload), encoding="utf-8")
            link_input.write_text(json.dumps(link_payload), encoding="utf-8")
            locals_input.write_text(json.dumps(locals_payload), encoding="utf-8")

            sequential_report = _build_report(route_input, link_input, locals_input, parallel=False)
            parallel_report = _build_report(route_input, link_input, locals_input, parallel=True)

        self.assertEqual(sequential_report["summary"], parallel_report["summary"])
        self.assertEqual(
            sorted(issue["code"] for issue in sequential_report["issues"]),
            sorted(issue["code"] for issue in parallel_report["issues"]),
        )


if __name__ == "__main__":
    unittest.main()
