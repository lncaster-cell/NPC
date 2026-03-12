import json
import tempfile
import unittest
from pathlib import Path

from scripts.ambient_life.al_route_preflight import _read_input


class ReadInputTests(unittest.TestCase):
    def _tmp_json(self, payload):
        tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", suffix=".json", delete=False)
        with tmp:
            json.dump(payload, tmp)
        return Path(tmp.name)

    def test_dict_requires_waypoints_key(self):
        path = self._tmp_json({"not_waypoints": []})
        with self.assertRaises(ValueError) as ctx:
            _read_input(path)
        self.assertEqual(str(ctx.exception), "missing required key 'waypoints'")

    def test_dict_waypoints_must_be_array(self):
        path = self._tmp_json({"waypoints": {"bad": "type"}})
        with self.assertRaises(ValueError) as ctx:
            _read_input(path)
        self.assertEqual(str(ctx.exception), "'waypoints' must be an array")

    def test_root_array_mode_remains_supported(self):
        expected = [{"area_tag": "A", "route_tag": "R", "al_step": 0}]
        path = self._tmp_json(expected)
        self.assertEqual(_read_input(path), expected)


if __name__ == "__main__":
    unittest.main()
