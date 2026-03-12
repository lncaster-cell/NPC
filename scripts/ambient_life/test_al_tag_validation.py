import unittest

from scripts.ambient_life.al_locals_preflight import validate_locals
from scripts.ambient_life.al_route_preflight import _as_waypoint


class RouteTagValidationTests(unittest.TestCase):
    def _issue_code(self, payload):
        _, issue = _as_waypoint(payload, 0)
        self.assertIsNotNone(issue)
        return issue.code

    def test_area_tag_invalid_inputs(self):
        cases = [
            (None, "missing_area_tag"),
            (123, "invalid_area_tag_type"),
            (True, "invalid_area_tag_type"),
            ("", "missing_area_tag"),
            ("   ", "missing_area_tag"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                code = self._issue_code({"area_tag": value, "route_tag": "route", "waypoint_tag": "wp", "al_step": 0})
                self.assertEqual(code, expected)

    def test_route_tag_invalid_inputs(self):
        cases = [
            (None, "missing_route_tag"),
            (123, "invalid_route_tag_type"),
            (True, "invalid_route_tag_type"),
            ("", "missing_route_tag"),
            ("   ", "missing_route_tag"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                code = self._issue_code({"area_tag": "area", "route_tag": value, "waypoint_tag": "wp", "al_step": 0})
                self.assertEqual(code, expected)

    def test_waypoint_tag_invalid_inputs(self):
        cases = [
            (None, "missing_waypoint_tag"),
            (123, "invalid_waypoint_tag_type"),
            (True, "invalid_waypoint_tag_type"),
            ("", "missing_waypoint_tag"),
            ("   ", "missing_waypoint_tag"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                code = self._issue_code({"area_tag": "area", "route_tag": "route", "waypoint_tag": value, "al_step": 0})
                self.assertEqual(code, expected)


class LocalsTagValidationTests(unittest.TestCase):
    def test_npc_tag_invalid_inputs(self):
        cases = [
            (None, "missing_npc_tag"),
            (123, "invalid_npc_tag_type"),
            (True, "invalid_npc_tag_type"),
            ("", "missing_npc_tag"),
            ("   ", "missing_npc_tag"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                report = validate_locals(
                    {
                        "npcs": [{"npc_tag": value, "locals": {"al_default_activity": 1, "alwp0": "route"}}],
                        "waypoints": [{"waypoint_tag": "wp", "locals": {"al_step": 0}}],
                        "areas": [{"area_tag": "area", "locals": {"al_link_count": 0}}],
                    }
                )
                self.assertIn(expected, [issue.code for issue in report])

    def test_waypoint_tag_invalid_inputs(self):
        cases = [
            (None, "missing_waypoint_tag"),
            (123, "invalid_waypoint_tag_type"),
            (True, "invalid_waypoint_tag_type"),
            ("", "missing_waypoint_tag"),
            ("   ", "missing_waypoint_tag"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                report = validate_locals(
                    {
                        "npcs": [{"npc_tag": "npc", "locals": {"al_default_activity": 1, "alwp0": "route"}}],
                        "waypoints": [{"waypoint_tag": value, "locals": {"al_step": 0}}],
                        "areas": [{"area_tag": "area", "locals": {"al_link_count": 0}}],
                    }
                )
                self.assertIn(expected, [issue.code for issue in report])

    def test_area_tag_invalid_inputs(self):
        cases = [
            (None, "missing_area_tag"),
            (123, "invalid_area_tag_type"),
            (True, "invalid_area_tag_type"),
            ("", "missing_area_tag"),
            ("   ", "missing_area_tag"),
        ]
        for value, expected in cases:
            with self.subTest(value=value):
                report = validate_locals(
                    {
                        "npcs": [{"npc_tag": "npc", "locals": {"al_default_activity": 1, "alwp0": "route"}}],
                        "waypoints": [{"waypoint_tag": "wp", "locals": {"al_step": 0}}],
                        "areas": [{"area_tag": value, "locals": {"al_link_count": 0}}],
                    }
                )
                self.assertIn(expected, [issue.code for issue in report])


if __name__ == "__main__":
    unittest.main()
