import unittest

from scripts.ambient_life.al_link_preflight import validate_links


class ValidateLinksDuplicateAreaTagTests(unittest.TestCase):
    def test_duplicate_area_tag_reports_error(self):
        rows = [
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
            {
                "area_tag": "gate",
                "locals": {
                    "al_link_count": 1,
                    "al_link_0": "market",
                },
            },
        ]

        issues = validate_links(rows)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.area_tag == "market"
                and issue.code == "duplicate_area_tag"
                for issue in issues
            )
        )


if __name__ == "__main__":
    unittest.main()
