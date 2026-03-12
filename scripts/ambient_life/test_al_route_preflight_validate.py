import unittest

from scripts.ambient_life.al_route_preflight import validate_route_markup


class ValidateRouteMarkupSleepPairTests(unittest.TestCase):
    def test_sleep_pair_point_missing_checked_per_route(self):
        rows = [
            {
                "area_tag": "inn_01",
                "route_tag": "route_a",
                "waypoint_tag": "bed_1_approach",
                "al_step": 0,
                "al_bed_id": "bed_1",
            },
            {
                "area_tag": "inn_01",
                "route_tag": "route_b",
                "waypoint_tag": "bed_1_pose",
                "al_step": 0,
                "al_bed_id": "bed_1",
            },
        ]

        issues = validate_route_markup(rows)
        missing_pair_issues = [
            issue
            for issue in issues
            if issue.code == "sleep_pair_point_missing"
        ]

        self.assertEqual(len(missing_pair_issues), 2)
        self.assertCountEqual(
            [(issue.area_tag, issue.route_tag) for issue in missing_pair_issues],
            [("inn_01", "route_a"), ("inn_01", "route_b")],
        )

        self.assertTrue(any("missing=bed_1_pose" in issue.details for issue in missing_pair_issues))
        self.assertTrue(any("missing=bed_1_approach" in issue.details for issue in missing_pair_issues))


class ValidateRouteMarkupWaypointTagContractTests(unittest.TestCase):
    def test_missing_waypoint_tag_reports_error(self):
        rows = [
            {
                "area_tag": "inn_01",
                "route_tag": "route_a",
                "al_step": 0,
            },
        ]

        issues = validate_route_markup(rows)

        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "missing_waypoint_tag")
        self.assertIn("waypoint=<idx:0>", issues[0].details)


class ValidateRouteMarkupBedIdTypeTests(unittest.TestCase):
    def test_al_bed_id_numeric_reports_invalid_type(self):
        rows = [
            {
                "area_tag": "inn_01",
                "route_tag": "route_a",
                "waypoint_tag": "bed_1_approach",
                "al_step": 0,
                "al_bed_id": 123,
            },
        ]

        issues = validate_route_markup(rows)

        invalid_type_issues = [issue for issue in issues if issue.code == "invalid_bed_id_type"]
        self.assertEqual(len(invalid_type_issues), 1)
        self.assertIn("al_bed_id=123", invalid_type_issues[0].details)


class ValidateRouteMarkupFailFastTests(unittest.TestCase):
    def test_fail_fast_stops_after_first_error(self):
        rows = [
            {"area_tag": "a", "route_tag": "r", "waypoint_tag": "wp0", "al_step": -1},
            {"area_tag": "a", "route_tag": "r", "waypoint_tag": "wp1", "al_step": 99},
        ]

        issues = validate_route_markup(rows, fail_fast=True)

        self.assertEqual(len(issues), 1)
        self.assertEqual(issues[0].code, "invalid_step_range")


if __name__ == "__main__":
    unittest.main()
