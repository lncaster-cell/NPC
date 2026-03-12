# S80/S100/S120 baseline (operator view)

Источник истины для автоматизации: `docs/perf/baselines/s80_s100_s120_baseline.csv`.

## S80

| Metric | Baseline | Unit | Trend (direction ± tol) | Порог (warn/critical) | Статус |
| --- | ---: | --- | --- | --- | --- |
| al_dispatch_q_len | 6 | count | n/a | 8..12 / >=13 | OK |
| al_dispatch_q_overflow | 0 | count | stable ±1 | 1..2 / >=3 | OK |
| al_reg_overflow_count | 0 | count | n/a | 1 / >=2 | OK |
| al_route_overflow_count | 0 | count | n/a | 1 / >=2 | OK |
| route_cache_hits | 140 | count | up ±2 | n/a | n/a |
| route_cache_rebuilds | 6 | count | down ±1 | n/a | n/a |
| route_cache_invalidations | 3 | count | down ±1 | n/a | n/a |
| al_h_recent_resync | 2 | count | n/a | 3..5 / >=6 | OK |
| al_h_reg_index_miss_delta | 0 | count | n/a | 1 / >=2 | OK |
| al_reg_compact_calls | 6 | count | n/a | n/a | n/a |
| al_reg_compact_calls_window | 2 | count | n/a | n/a | n/a |
| al_dispatch_ticks_to_drain | 3 | ticks | stable ±1 | n/a | n/a |

## S100

| Metric | Baseline | Unit | Trend (direction ± tol) | Порог (warn/critical) | Статус |
| --- | ---: | --- | --- | --- | --- |
| al_dispatch_q_len | 9 | count | n/a | 10..14 / >=15 | OK |
| al_dispatch_q_overflow | 0 | count | stable ±1 | 1..3 / >=4 | OK |
| al_reg_overflow_count | 0 | count | n/a | 1..2 / >=3 | OK |
| al_route_overflow_count | 0 | count | n/a | 1..2 / >=3 | OK |
| route_cache_hits | 175 | count | up ±2 | n/a | n/a |
| route_cache_rebuilds | 8 | count | down ±1 | n/a | n/a |
| route_cache_invalidations | 4 | count | down ±1 | n/a | n/a |
| al_h_recent_resync | 3 | count | n/a | 4..7 / >=8 | OK |
| al_h_reg_index_miss_delta | 0 | count | n/a | 1..2 / >=3 | OK |
| al_reg_compact_calls | 8 | count | n/a | n/a | n/a |
| al_reg_compact_calls_window | 3 | count | n/a | n/a | n/a |
| al_dispatch_ticks_to_drain | 4 | ticks | stable ±1 | n/a | n/a |

## S120

| Metric | Baseline | Unit | Trend (direction ± tol) | Порог (warn/critical) | Статус |
| --- | ---: | --- | --- | --- | --- |
| al_dispatch_q_len | 11 | count | n/a | 12..17 / >=18 | OK |
| al_dispatch_q_overflow | 1 | count | stable ±1 | 2..4 / >=5 | OK |
| al_reg_overflow_count | 1 | count | n/a | 2..4 / >=5 | OK |
| al_route_overflow_count | 1 | count | n/a | 2..4 / >=5 | OK |
| route_cache_hits | 205 | count | up ±2 | n/a | n/a |
| route_cache_rebuilds | 10 | count | down ±1 | n/a | n/a |
| route_cache_invalidations | 5 | count | down ±1 | n/a | n/a |
| al_h_recent_resync | 5 | count | n/a | 6..10 / >=11 | OK |
| al_h_reg_index_miss_delta | 1 | count | n/a | 2..3 / >=4 | OK |
| al_reg_compact_calls | 11 | count | n/a | n/a | n/a |
| al_reg_compact_calls_window | 4 | count | n/a | n/a | n/a |
| al_dispatch_ticks_to_drain | 5 | ticks | stable ±1 | n/a | n/a |

## Унифицированный формат «до/после»

Используйте одинаковую структуру как в Markdown, так и в CSV.

### Markdown-шаблон

| Scenario | Metric | Baseline | Direction | TrendTolerance | After | Delta | Unit | Warn | Critical | Status | Notes |
| --- | --- | ---: | --- | ---: | ---: | ---: | --- | --- | --- | --- | --- |
| S80 | al_dispatch_q_len | 6 |  |  |  |  | count | 8..12 | >=13 |  |  |

### CSV-шаблон

```csv
scenario,metric,baseline_value,expected_direction,trend_tolerance,after_value,delta,unit,warn_threshold,critical_threshold,status,notes
S80,al_dispatch_q_len,6,,,,,count,8..12,>=13,,
```
