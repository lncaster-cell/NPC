#!/usr/bin/env python3
"""Validate Ambient Life perf report against locked baseline thresholds.

Supports CSV/JSON report formats and enforces perf gate conditions documented in
`docs/PERF_PROFILE.md` and `docs/PERF_RUNBOOK.md`.
"""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
import sys
from pathlib import Path
from typing import Dict, Iterable, List, Tuple

REQUIRED_SCENARIOS = ("S80", "S100", "S120")
REQUIRED_METRICS = (
    "al_dispatch_q_overflow",
    "al_dispatch_ticks_to_drain",
    "route_cache_hits",
    "route_cache_rebuilds",
    "route_cache_invalidations",
)
CACHE_TREND_METRICS = (
    "route_cache_hits",
    "route_cache_rebuilds",
    "route_cache_invalidations",
)
TREND_DIRECTIONS = ("up", "down", "stable")

# PERF_PROFILE.md section "Дополнительно для изменений dispatch-degradation".
OVERFLOW_TARGETS = {"S80": 0.0, "S100": 0.0, "S120": 1.0}
DRAIN_ABSOLUTE_TARGETS = {"S80": 3.0, "S100": 4.0, "S120": 5.0}
MAX_DRAIN_DELTA = 1.0
CACHE_VERSION = 1
CACHE_DIRNAME = ".cache/perf_gate"


class ValidationError(Exception):
    pass


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Validate Ambient Life perf gate report")
    parser.add_argument("--baseline", required=True, help="Path to baseline CSV")
    parser.add_argument("--report", required=True, help="Path to perf report CSV/JSON")
    parser.add_argument(
        "--no-cache",
        action="store_true",
        help="Disable local parse cache (useful for deterministic CI runs)",
    )
    return parser.parse_args()


def _cache_path(baseline_path: Path, report_path: Path) -> Path:
    digest = hashlib.sha256()
    digest.update(baseline_path.read_bytes())
    digest.update(b"\0")
    digest.update(report_path.read_bytes())
    return Path(CACHE_DIRNAME) / f"{digest.hexdigest()}.json"


def _encode_cache(
    baseline: Dict[Tuple[str, str], float], report: Dict[Tuple[str, str], dict]
) -> dict:
    return {
        "cache_version": CACHE_VERSION,
        "baseline": [
            {"scenario": scenario, "metric": metric, "value": value}
            for (scenario, metric), value in sorted(baseline.items())
        ],
        "report": [
            {
                "scenario": scenario,
                "metric": metric,
                "after_value": entry["after_value"],
                "baseline_value": entry["baseline_value"],
                "delta": entry["delta"],
            }
            for (scenario, metric), entry in sorted(report.items())
        ],
    }


def _decode_cache(payload: dict) -> Tuple[Dict[Tuple[str, str], float], Dict[Tuple[str, str], dict]]:
    if payload.get("cache_version") != CACHE_VERSION:
        raise ValidationError("cache version mismatch")

    baseline_rows = payload.get("baseline")
    report_rows = payload.get("report")
    if not isinstance(baseline_rows, list) or not isinstance(report_rows, list):
        raise ValidationError("cache payload is malformed")

    baseline: Dict[Tuple[str, str], float] = {}
    for row in baseline_rows:
        scenario = str(row.get("scenario", "")).strip()
        metric = str(row.get("metric", "")).strip()
        value = row.get("value")
        if not scenario or not metric:
            raise ValidationError("cache payload baseline entry is malformed")
        baseline[(scenario, metric)] = _to_float(value, "value", scenario, metric)

    report: Dict[Tuple[str, str], dict] = {}
    for row in report_rows:
        scenario = str(row.get("scenario", "")).strip()
        metric = str(row.get("metric", "")).strip()
        if not scenario or not metric:
            raise ValidationError("cache payload report entry is malformed")

        baseline_value = row.get("baseline_value")
        if baseline_value is not None:
            baseline_value = _to_float(baseline_value, "baseline_value", scenario, metric)

        report[(scenario, metric)] = {
            "after_value": _to_float(row.get("after_value"), "after_value", scenario, metric),
            "baseline_value": baseline_value,
            "delta": row.get("delta"),
        }

    return baseline, report


def _load_inputs_with_cache(
    baseline_path: Path, report_path: Path, use_cache: bool
) -> Tuple[Dict[Tuple[str, str], float], Dict[Tuple[str, str], dict]]:
    if not use_cache:
        return load_baseline(baseline_path), load_report(report_path)

    cache_path: Path | None = None
    try:
        cache_path = _cache_path(baseline_path, report_path)
        if cache_path.exists():
            payload = json.loads(cache_path.read_text(encoding="utf-8"))
            return _decode_cache(payload)
    except (OSError, json.JSONDecodeError, ValidationError):
        # Best-effort cache: any read/decode issue falls back to direct parsing.
        pass

    baseline = load_baseline(baseline_path)
    report = load_report(report_path)

    if cache_path is not None:
        try:
            cache_path.parent.mkdir(parents=True, exist_ok=True)
            cache_path.write_text(json.dumps(_encode_cache(baseline, report)), encoding="utf-8")
        except OSError:
            # Best-effort cache: write issues must not break validation.
            pass

    return baseline, report


def _to_float(raw: str, field: str, scenario: str, metric: str) -> float:
    try:
        return float(raw)
    except (TypeError, ValueError) as exc:
        raise ValidationError(
            f"Invalid numeric value for '{field}' in {scenario}/{metric}: {raw!r}"
        ) from exc


def load_baseline(path: Path) -> Dict[Tuple[str, str], dict]:
    values: Dict[Tuple[str, str], dict] = {}
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.DictReader(f)
        required_fields = (
            "scenario",
            "metric",
            "baseline_value",
            "expected_direction",
            "trend_tolerance",
        )
        missing_fields = [field for field in required_fields if field not in (reader.fieldnames or [])]
        if missing_fields:
            raise ValidationError(
                "Baseline CSV is missing required columns: " + ", ".join(missing_fields)
            )

        for idx, row in enumerate(reader, start=2):
            scenario_raw = row.get("scenario")
            metric_raw = row.get("metric")
            baseline_raw = row.get("baseline_value")

            scenario = str(scenario_raw).strip() if scenario_raw is not None else ""
            metric = str(metric_raw).strip() if metric_raw is not None else ""
            if not scenario:
                raise ValidationError(f"Baseline CSV row {idx}: missing value for 'scenario'")
            if not metric:
                raise ValidationError(f"Baseline CSV row {idx}: missing value for 'metric'")

            key = (scenario, metric)
            if key[1] not in REQUIRED_METRICS:
                continue

            if baseline_raw in (None, ""):
                raise ValidationError(
                    f"Baseline CSV row {idx}: missing value for 'baseline_value' in {scenario}/{metric}"
                )

            if key in values:
                raise ValidationError(f"duplicate entry for {scenario}/{metric} (row {idx})")

            values[key] = _to_float(str(baseline_raw), "baseline_value", *key)

    missing = [f"{s}/{m}" for s in REQUIRED_SCENARIOS for m in REQUIRED_METRICS if (s, m) not in values]
    if missing:
        raise ValidationError("Baseline CSV misses required entries: " + ", ".join(missing))
    return values


def _normalize_rows_json(raw: object) -> List[dict]:
    if isinstance(raw, dict):
        if "rows" in raw and isinstance(raw["rows"], list):
            return raw["rows"]
        raise ValidationError("JSON report must be a list or an object with key 'rows'")
    if isinstance(raw, list):
        return raw
    raise ValidationError("JSON report must be a list or an object with key 'rows'")


def load_report(path: Path) -> Dict[Tuple[str, str], dict]:
    ext = path.suffix.lower()
    rows: Iterable[dict]
    strict_csv = False

    if ext == ".csv":
        with path.open(newline="", encoding="utf-8") as f:
            reader = csv.DictReader(f)
            required_fields = ("scenario", "metric", "after_value")
            missing_fields = [field for field in required_fields if field not in (reader.fieldnames or [])]
            if missing_fields:
                raise ValidationError(
                    "Report CSV is missing required columns: " + ", ".join(missing_fields)
                )
            rows = list(reader)
            strict_csv = True
    elif ext == ".json":
        with path.open(encoding="utf-8") as f:
            rows = _normalize_rows_json(json.load(f))
    else:
        raise ValidationError("Unsupported report format. Use .csv or .json")

    parsed: Dict[Tuple[str, str], dict] = {}
    for idx, row in enumerate(rows, start=2):
        if not isinstance(row, dict):
            raise ValidationError(
                f"Report JSON row {idx} must be object, got {type(row).__name__}"
            )

        scenario_raw = row.get("scenario")
        metric_raw = row.get("metric")

        scenario = str(scenario_raw).strip() if scenario_raw is not None else ""
        metric = str(metric_raw).strip() if metric_raw is not None else ""

        if strict_csv and not scenario:
            raise ValidationError(f"Report CSV row {idx}: missing value for 'scenario'")
        if strict_csv and not metric:
            raise ValidationError(f"Report CSV row {idx}: missing value for 'metric'")

        after_raw = row.get("after_value")
        if strict_csv and after_raw in (None, ""):
            raise ValidationError(f"Report CSV row {idx}: missing value for 'after_value'")

        if scenario not in REQUIRED_SCENARIOS or metric not in REQUIRED_METRICS:
            continue

        if after_raw in (None, ""):
            raise ValidationError(f"Missing after_value for {scenario}/{metric}")
        after_value = _to_float(str(after_raw), "after_value", scenario, metric)

        baseline_raw = row.get("baseline_value")
        baseline_value = None
        if baseline_raw not in (None, ""):
            baseline_value = _to_float(str(baseline_raw), "baseline_value", scenario, metric)

        if (scenario, metric) in parsed:
            raise ValidationError(f"duplicate entry for {scenario}/{metric} (row {idx})")

        parsed[(scenario, metric)] = {
            "after_value": after_value,
            "baseline_value": baseline_value,
            "delta": row.get("delta"),
        }

    missing = [f"{s}/{m}" for s in REQUIRED_SCENARIOS for m in REQUIRED_METRICS if (s, m) not in parsed]
    if missing:
        raise ValidationError("Report misses required entries: " + ", ".join(missing))
    return parsed


def _format_delta(delta: float) -> str:
    return f"{delta:+.1f}"


def _validate_cache_trend(
    scenario: str,
    metric: str,
    baseline_entry: dict,
    after_value: float,
) -> str | None:
    baseline_value = baseline_entry["baseline_value"]
    expected_direction = baseline_entry["expected_direction"]
    tolerance = baseline_entry["trend_tolerance"]
    delta = after_value - baseline_value

    if expected_direction == "up" and delta < -tolerance:
        return (
            f"{scenario}/{metric} trend violation: expected up within tolerance {tolerance}, "
            f"got {baseline_value} -> {after_value} (delta {_format_delta(delta)})"
        )
    if expected_direction == "down" and delta > tolerance:
        return (
            f"{scenario}/{metric} trend violation: expected down within tolerance {tolerance}, "
            f"got {baseline_value} -> {after_value} (delta {_format_delta(delta)})"
        )
    if expected_direction == "stable" and abs(delta) > tolerance:
        return (
            f"{scenario}/{metric} trend violation: expected stable within tolerance ±{tolerance}, "
            f"got {baseline_value} -> {after_value} (delta {_format_delta(delta)})"
        )
    return None


def render_cache_efficiency(
    baseline: Dict[Tuple[str, str], dict], report: Dict[Tuple[str, str], dict]
) -> List[str]:
    lines = ["[PERF-GATE] cache efficiency"]
    for scenario in REQUIRED_SCENARIOS:
        for metric in CACHE_TREND_METRICS:
            key = (scenario, metric)
            baseline_entry = baseline[key]
            baseline_value = baseline_entry["baseline_value"]
            after_value = report[key]["after_value"]
            delta = after_value - baseline_value
            direction = baseline_entry["expected_direction"]
            tolerance = baseline_entry["trend_tolerance"]
            trend_failure = _validate_cache_trend(scenario, metric, baseline_entry, after_value)
            status = "FAIL" if trend_failure else "OK"
            lines.append(
                f" - {scenario}/{metric}: {baseline_value} -> {after_value} (delta {_format_delta(delta)}), "
                f"expected {direction} (tol {tolerance}) [{status}]"
            )
    return lines


def validate(baseline: Dict[Tuple[str, str], dict], report: Dict[Tuple[str, str], dict]) -> List[str]:
    failures: List[str] = []

    for scenario in REQUIRED_SCENARIOS:
        # 1) Overflow growth relative to baseline is forbidden.
        overflow_key = (scenario, "al_dispatch_q_overflow")
        overflow_after = report[overflow_key]["after_value"]
        overflow_baseline = report[overflow_key]["baseline_value"]
        if overflow_baseline is None:
            overflow_baseline = baseline[overflow_key]["baseline_value"]

        if overflow_after > overflow_baseline:
            failures.append(
                f"{scenario}/al_dispatch_q_overflow grew vs baseline: {overflow_baseline} -> {overflow_after}"
            )

        target_overflow = OVERFLOW_TARGETS[scenario]
        if overflow_after > target_overflow:
            failures.append(
                f"{scenario}/al_dispatch_q_overflow exceeds target {target_overflow}: {overflow_after}"
            )

        # 2) Drain delta above +1 tick is forbidden, and absolute caps must hold.
        drain_key = (scenario, "al_dispatch_ticks_to_drain")
        drain_after = report[drain_key]["after_value"]
        drain_baseline = report[drain_key]["baseline_value"]
        if drain_baseline is None:
            drain_baseline = baseline[drain_key]["baseline_value"]

        drain_delta = drain_after - drain_baseline
        if drain_delta > MAX_DRAIN_DELTA:
            failures.append(
                f"{scenario}/al_dispatch_ticks_to_drain delta too high: {drain_baseline} -> {drain_after} (delta {drain_delta:+.1f})"
            )

        absolute_target = DRAIN_ABSOLUTE_TARGETS[scenario]
        if drain_after > absolute_target:
            failures.append(
                f"{scenario}/al_dispatch_ticks_to_drain exceeds target {absolute_target}: {drain_after}"
            )

        for metric in CACHE_TREND_METRICS:
            key = (scenario, metric)
            trend_failure = _validate_cache_trend(
                scenario,
                metric,
                baseline[key],
                report[key]["after_value"],
            )
            if trend_failure:
                failures.append(trend_failure)

    return failures


def main() -> int:
    args = parse_args()
    try:
        baseline = Path(args.baseline)
        report = Path(args.report)
        baseline_values, report_values = _load_inputs_with_cache(
            baseline, report, use_cache=not args.no_cache
        )
        failures = validate(baseline_values, report_values)
    except ValidationError as exc:
        print(f"[PERF-GATE][ERROR] {exc}")
        return 1

    for line in cache_efficiency_lines:
        print(line)

    if failures:
        print("[PERF-GATE][FAIL] Perf gate did not pass:")
        for failure in failures:
            print(f" - {failure}")
        return 1

    print("[PERF-GATE][PASS] Perf gate checks passed for S80/S100/S120")
    return 0


if __name__ == "__main__":
    sys.exit(main())
