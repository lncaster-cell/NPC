import json
import subprocess
import tempfile
import unittest
from pathlib import Path


class PreflightSuiteCliFormatsTests(unittest.TestCase):
    def _write_inputs(self, temp_path: Path) -> tuple[Path, Path, Path]:
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

        route_input = temp_path / "route.json"
        link_input = temp_path / "link.json"
        locals_input = temp_path / "locals.json"
        route_input.write_text(json.dumps(route_payload), encoding="utf-8")
        link_input.write_text(json.dumps(link_payload), encoding="utf-8")
        locals_input.write_text(json.dumps(locals_payload), encoding="utf-8")
        return route_input, link_input, locals_input

    def _run_suite(self, route_input: Path, link_input: Path, locals_input: Path, output_format: str, *extra: str) -> subprocess.CompletedProcess[str]:
        cmd = [
            "python3",
            "-m",
            "scripts.ambient_life.run_preflight_suite",
            "--route-input",
            str(route_input),
            "--link-input",
            str(link_input),
            "--locals-input",
            str(locals_input),
            "--format",
            output_format,
            *extra,
        ]
        return subprocess.run(cmd, cwd="/workspace/NPC", capture_output=True, text=True, check=False)

    def test_text_and_json_have_matching_status_and_summary(self):
        with tempfile.TemporaryDirectory() as temp_dir:
            route_input, link_input, locals_input = self._write_inputs(Path(temp_dir))

            json_result = self._run_suite(route_input, link_input, locals_input, "json")
            text_result = self._run_suite(route_input, link_input, locals_input, "text", "--detail-limit", "3")

        self.assertEqual(json_result.returncode, text_result.returncode)

        json_report = json.loads(json_result.stdout)
        self.assertEqual(json_report["status"], "ERROR")
        self.assertIn(f"[suite:{json_report['status']}]", text_result.stdout)

        expected_summary = (
            "Summary: "
            f"error={json_report['summary']['error']} "
            f"warn={json_report['summary']['warn']} "
            f"info={json_report['summary']['info']} "
            f"total={json_report['summary']['total']}"
        )
        self.assertIn(expected_summary, text_result.stdout)

        self.assertIn("Top issue codes:", text_result.stdout)
        self.assertIn("- code=degree_below_target count=2", text_result.stdout)

        detail_lines = [line for line in text_result.stdout.splitlines() if line.startswith("- [")]
        self.assertEqual(len(detail_lines), 3)
        self.assertIn("... and 3 more issues", text_result.stdout)


if __name__ == "__main__":
    unittest.main()
