import tempfile
import unittest
from pathlib import Path

from scripts.ambient_life.validate_perf_gate import ValidationError, load_baseline, load_report


class LoadBaselineCsvValidationTests(unittest.TestCase):
    def _write_temp(self, content: str, suffix: str = ".csv") -> Path:
        tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="", suffix=suffix, delete=False)
        self.addCleanup(lambda: Path(tmp.name).unlink(missing_ok=True))
        with tmp:
            tmp.write(content)
        return Path(tmp.name)

    def test_missing_required_header_raises_validation_error(self):
        path = self._write_temp("scenario,metric\nS80,al_dispatch_q_overflow\n")

        with self.assertRaisesRegex(ValidationError, r"missing required columns: baseline_value"):
            load_baseline(path)

    def test_empty_baseline_value_cell_raises_validation_error(self):
        csv_content = """scenario,metric,baseline_value
S80,al_dispatch_q_overflow,
S80,al_dispatch_ticks_to_drain,3
S100,al_dispatch_q_overflow,0
S100,al_dispatch_ticks_to_drain,4
S120,al_dispatch_q_overflow,1
S120,al_dispatch_ticks_to_drain,5
"""
        path = self._write_temp(csv_content)

        with self.assertRaisesRegex(ValidationError, r"row 2: missing value for 'baseline_value'"):
            load_baseline(path)


class LoadReportCsvValidationTests(unittest.TestCase):
    def _write_temp(self, content: str, suffix: str = ".csv") -> Path:
        tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="", suffix=suffix, delete=False)
        self.addCleanup(lambda: Path(tmp.name).unlink(missing_ok=True))
        with tmp:
            tmp.write(content)
        return Path(tmp.name)

    def test_missing_required_header_raises_validation_error(self):
        path = self._write_temp("scenario,metric\nS80,al_dispatch_q_overflow\n")

        with self.assertRaisesRegex(ValidationError, r"missing required columns: after_value"):
            load_report(path)

    def test_empty_required_cell_raises_validation_error(self):
        csv_content = """scenario,metric,after_value
,al_dispatch_q_overflow,0
S80,al_dispatch_ticks_to_drain,3
S100,al_dispatch_q_overflow,0
S100,al_dispatch_ticks_to_drain,4
S120,al_dispatch_q_overflow,1
S120,al_dispatch_ticks_to_drain,5
"""
        path = self._write_temp(csv_content)

        with self.assertRaisesRegex(ValidationError, r"row 2: missing value for 'scenario'"):
            load_report(path)


class LoadReportJsonValidationTests(unittest.TestCase):
    def _write_temp(self, content: str, suffix: str = ".json") -> Path:
        tmp = tempfile.NamedTemporaryFile("w", encoding="utf-8", newline="", suffix=suffix, delete=False)
        self.addCleanup(lambda: Path(tmp.name).unlink(missing_ok=True))
        with tmp:
            tmp.write(content)
        return Path(tmp.name)

    def test_non_object_row_raises_validation_error(self):
        json_content = """{
  "rows": [
    {"scenario": "S80", "metric": "al_dispatch_q_overflow", "after_value": 0},
    1,
    {"scenario": "S80", "metric": "al_dispatch_ticks_to_drain", "after_value": 3},
    {"scenario": "S100", "metric": "al_dispatch_q_overflow", "after_value": 0},
    {"scenario": "S100", "metric": "al_dispatch_ticks_to_drain", "after_value": 4},
    {"scenario": "S120", "metric": "al_dispatch_q_overflow", "after_value": 1},
    {"scenario": "S120", "metric": "al_dispatch_ticks_to_drain", "after_value": 5}
  ]
}
"""
        path = self._write_temp(json_content)

        with self.assertRaisesRegex(ValidationError, r"Report JSON row 3 must be object, got int"):
            load_report(path)


if __name__ == "__main__":
    unittest.main()
