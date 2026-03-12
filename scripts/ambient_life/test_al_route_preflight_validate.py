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


if __name__ == "__main__":
    unittest.main()
