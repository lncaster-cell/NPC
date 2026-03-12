import unittest

from scripts.ambient_life.al_locals_preflight import validate_locals


class ValidateLocalsRouteRefsTests(unittest.TestCase):
    def test_npc_route_tag_typo_reports_unknown_route_error(self):
        payload = {
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

        issues = validate_locals(payload)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.code == "unknown_route_tag_ref"
                and issue.object_id == "merchant_01"
                and "slot=alwp0" in issue.reason
                and "market_rute" in issue.reason
                for issue in issues
            )
        )

    def test_npc_route_tag_with_whitespace_does_not_report_unknown_route_error(self):
        payload = {
            "npcs": [
                {
                    "npc_tag": "merchant_01",
                    "locals": {
                        "al_default_activity": 1,
                        "alwp0": "  market_route  ",
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

        issues = validate_locals(payload)

        self.assertFalse(
            any(
                issue.level == "ERROR"
                and issue.code == "unknown_route_tag_ref"
                and issue.object_id == "merchant_01"
                and "slot=alwp0" in issue.reason
                for issue in issues
            )
        )


class ValidateLocalsAreaTagValidationTests(unittest.TestCase):
    def test_area_tag_with_non_string_type_reports_invalid_type(self):
        payload = {
            "npcs": [],
            "waypoints": [],
            "areas": [
                {
                    "area_tag": 123,
                    "locals": {"al_link_count": 0},
                }
            ],
        }

        issues = validate_locals(payload)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.code == "invalid_area_tag_type"
                and issue.object_id == "<idx:0>"
                for issue in issues
            )
        )


class ValidateLocalsWaypointTagValidationTests(unittest.TestCase):
    def test_waypoint_missing_area_tag_reports_error_with_waypoint_object_id(self):
        payload = {
            "npcs": [],
            "waypoints": [
                {
                    "route_tag": "market_route",
                    "waypoint_tag": "market_0",
                    "locals": {"al_step": 0},
                }
            ],
            "areas": [],
        }

        issues = validate_locals(payload)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.code == "missing_area_tag"
                and issue.object_id == "market_0"
                for issue in issues
            )
        )

    def test_waypoint_route_tag_with_non_string_type_reports_invalid_type(self):
        payload = {
            "npcs": [],
            "waypoints": [
                {
                    "area_tag": "area_market",
                    "route_tag": 42,
                    "waypoint_tag": "market_0",
                    "locals": {"al_step": 0},
                }
            ],
            "areas": [],
        }

        issues = validate_locals(payload)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.code == "invalid_route_tag_type"
                and issue.object_id == "market_0"
                for issue in issues
            )
        )

    def test_waypoint_with_blank_area_and_route_tags_reports_missing_errors(self):
        payload = {
            "npcs": [],
            "waypoints": [
                {
                    "area_tag": "   ",
                    "route_tag": "\t",
                    "waypoint_tag": "market_0",
                    "locals": {"al_step": 0},
                }
            ],
            "areas": [],
        }

        issues = validate_locals(payload)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.code == "missing_area_tag"
                and issue.object_id == "market_0"
                for issue in issues
            )
        )
        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.code == "missing_route_tag"
                and issue.object_id == "market_0"
                for issue in issues
            )
        )


if __name__ == "__main__":
    unittest.main()
