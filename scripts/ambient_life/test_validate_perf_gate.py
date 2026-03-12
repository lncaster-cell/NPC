import tempfile
import unittest
from pathlib import Path

from scripts.ambient_life.validate_perf_gate import ValidationError, load_baseline, load_report, validate


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
        csv_content = """scenario,metric,baseline_value,expected_direction,trend_tolerance
S80,al_dispatch_q_overflow,,stable,1
S80,al_dispatch_ticks_to_drain,3,stable,1
S80,route_cache_hits,140,up,2
S80,route_cache_rebuilds,6,down,1
S80,route_cache_invalidations,3,down,1
S100,al_dispatch_q_overflow,0,stable,1
S100,al_dispatch_ticks_to_drain,4,stable,1
S100,route_cache_hits,175,up,2
S100,route_cache_rebuilds,8,down,1
S100,route_cache_invalidations,4,down,1
S120,al_dispatch_q_overflow,1,stable,1
S120,al_dispatch_ticks_to_drain,5,stable,1
S120,route_cache_hits,205,up,2
S120,route_cache_rebuilds,10,down,1
S120,route_cache_invalidations,5,down,1
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
S80,route_cache_hits,140
S80,route_cache_rebuilds,6
S80,route_cache_invalidations,3
S100,al_dispatch_q_overflow,0
S100,al_dispatch_ticks_to_drain,4
S100,route_cache_hits,175
S100,route_cache_rebuilds,8
S100,route_cache_invalidations,4
S120,al_dispatch_q_overflow,1
S120,al_dispatch_ticks_to_drain,5
S120,route_cache_hits,205
S120,route_cache_rebuilds,10
S120,route_cache_invalidations,5
"""
        path = self._write_temp(csv_content)

        with self.assertRaisesRegex(ValidationError, r"row 2: missing value for 'scenario'"):
            load_report(path)


class ValidateCacheTrendTests(unittest.TestCase):
    def test_route_cache_hits_regression_fails_perf_gate(self):
        baseline = {
            ("S80", "al_dispatch_q_overflow"): {"baseline_value": 0, "expected_direction": "stable", "trend_tolerance": 1},
            ("S80", "al_dispatch_ticks_to_drain"): {"baseline_value": 3, "expected_direction": "stable", "trend_tolerance": 1},
            ("S80", "route_cache_hits"): {"baseline_value": 140, "expected_direction": "up", "trend_tolerance": 2},
            ("S80", "route_cache_rebuilds"): {"baseline_value": 6, "expected_direction": "down", "trend_tolerance": 1},
            ("S80", "route_cache_invalidations"): {"baseline_value": 3, "expected_direction": "down", "trend_tolerance": 1},
            ("S100", "al_dispatch_q_overflow"): {"baseline_value": 0, "expected_direction": "stable", "trend_tolerance": 1},
            ("S100", "al_dispatch_ticks_to_drain"): {"baseline_value": 4, "expected_direction": "stable", "trend_tolerance": 1},
            ("S100", "route_cache_hits"): {"baseline_value": 175, "expected_direction": "up", "trend_tolerance": 2},
            ("S100", "route_cache_rebuilds"): {"baseline_value": 8, "expected_direction": "down", "trend_tolerance": 1},
            ("S100", "route_cache_invalidations"): {"baseline_value": 4, "expected_direction": "down", "trend_tolerance": 1},
            ("S120", "al_dispatch_q_overflow"): {"baseline_value": 1, "expected_direction": "stable", "trend_tolerance": 1},
            ("S120", "al_dispatch_ticks_to_drain"): {"baseline_value": 5, "expected_direction": "stable", "trend_tolerance": 1},
            ("S120", "route_cache_hits"): {"baseline_value": 205, "expected_direction": "up", "trend_tolerance": 2},
            ("S120", "route_cache_rebuilds"): {"baseline_value": 10, "expected_direction": "down", "trend_tolerance": 1},
            ("S120", "route_cache_invalidations"): {"baseline_value": 5, "expected_direction": "down", "trend_tolerance": 1},
        }
        report = {
            key: {"after_value": value["baseline_value"], "baseline_value": None, "delta": None}
            for key, value in baseline.items()
        }
        report[("S100", "route_cache_hits")]["after_value"] = 170

        failures = validate(baseline, report)

        self.assertTrue(any("S100/route_cache_hits trend violation" in failure for failure in failures))


if __name__ == "__main__":
    unittest.main()
