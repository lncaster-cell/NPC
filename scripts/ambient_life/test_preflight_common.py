import json
import tempfile
import unittest
from pathlib import Path

from scripts.ambient_life.preflight_common import (
    is_strict_int,
    read_json_list_input,
    read_json_object_input,
    read_tag,
    tag_error_code,
)


class PreflightCommonTests(unittest.TestCase):
    def _tmp_json(self, payload):
        tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".json", delete=False)
        with tmp:
            json.dump(payload, tmp)
        return Path(tmp.name)

    def test_read_json_list_input_supports_object_and_list_root(self):
        object_path = self._tmp_json({"waypoints": [{"k": "v"}]})
        list_path = self._tmp_json([{"k": "v"}])

        self.assertEqual(read_json_list_input(object_path, key="waypoints"), [{"k": "v"}])
        self.assertEqual(read_json_list_input(list_path, key="waypoints"), [{"k": "v"}])

    def test_read_json_list_input_errors_match_existing_contract(self):
        missing_key_path = self._tmp_json({"other": []})
        with self.assertRaises(ValueError) as missing_key_ctx:
            read_json_list_input(missing_key_path, key="areas")
        self.assertEqual(str(missing_key_ctx.exception), "missing required key 'areas'")

        invalid_list_path = self._tmp_json({"areas": {"bad": "type"}})
        with self.assertRaises(ValueError) as invalid_list_ctx:
            read_json_list_input(invalid_list_path, key="areas")
        self.assertEqual(str(invalid_list_ctx.exception), "'areas' must be an array")

    def test_read_json_object_input_requires_object_root(self):
        object_path = self._tmp_json({"npcs": []})
        list_path = self._tmp_json([])

        self.assertEqual(read_json_object_input(object_path), {"npcs": []})
        with self.assertRaises(ValueError) as ctx:
            read_json_object_input(list_path)
        self.assertEqual(str(ctx.exception), "JSON root must be an object")

    def test_tag_helpers(self):
        self.assertTrue(is_strict_int(0))
        self.assertFalse(is_strict_int(True))
        self.assertEqual(read_tag("  market  "), "market")
        self.assertIsNone(read_tag("   "))
        self.assertIsNone(read_tag(123))

        self.assertEqual(
            tag_error_code(None, missing_code="missing_area_tag", invalid_type_code="invalid_area_tag_type"),
            "missing_area_tag",
        )
        self.assertEqual(
            tag_error_code("   ", missing_code="missing_area_tag", invalid_type_code="invalid_area_tag_type"),
            "missing_area_tag",
        )
        self.assertEqual(
            tag_error_code(1, missing_code="missing_area_tag", invalid_type_code="invalid_area_tag_type"),
            "invalid_area_tag_type",
        )


if __name__ == "__main__":
    unittest.main()
