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


class ValidateLinksAreaTagValidationTests(unittest.TestCase):
    def test_area_tag_integer_reports_invalid_type(self):
        rows = [{"area_tag": 123, "locals": {"al_link_count": 0}}]

        issues = validate_links(rows)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.area_tag == "<idx:0>"
                and issue.code == "invalid_area_tag_type"
                for issue in issues
            )
        )

    def test_area_tag_boolean_reports_invalid_type(self):
        rows = [{"area_tag": True, "locals": {"al_link_count": 0}}]

        issues = validate_links(rows)

        self.assertTrue(
            any(
                issue.level == "ERROR"
                and issue.area_tag == "<idx:0>"
                and issue.code == "invalid_area_tag_type"
                for issue in issues
            )
        )

    def test_area_tag_empty_or_whitespace_reports_missing(self):
        rows = [
            {"area_tag": "", "locals": {"al_link_count": 0}},
            {"area_tag": "   ", "locals": {"al_link_count": 0}},
        ]

        issues = validate_links(rows)

        missing_codes = {
            issue.area_tag: issue.code
            for issue in issues
            if issue.level == "ERROR" and issue.code in {"missing_area_tag", "invalid_area_tag_type"}
        }

        self.assertEqual(missing_codes.get("<idx:0>"), "missing_area_tag")
        self.assertEqual(missing_codes.get("<idx:1>"), "missing_area_tag")


if __name__ == "__main__":
    unittest.main()
