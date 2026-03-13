# Ambient Life v2 — Operations & Validation

## 1. Perf-регламент
Для PR с изменениями в `scripts/ambient_life/al_*` обязательны прогоны:
- **S80**
- **S100**
- **S120**

Рекомендованное окно:
- warm-up: 2 area-tick,
- измерение: 20 tick,
- одинаковые условия для baseline/after.

Baseline и шаблоны отчётов:
- `docs/perf/baselines/s80_s100_s120_baseline.csv`
- `docs/perf/baselines/s80_s100_s120_baseline.md`
- `docs/perf/baselines/perf_gate_report_template.csv`
- `docs/perf/baselines/README.md`

## 2. Обязательные метрики
Минимально фиксируются:
- `al_dispatch_q_len`, `al_dispatch_q_overflow`
- `al_reg_overflow_count`, `al_route_overflow_count`
- `route_cache_hits`, `route_cache_rebuilds`, `route_cache_invalidations`
- `al_h_recent_resync`
- `al_h_reg_index_miss_delta`, `al_h_reg_index_miss_window_delta`
- `al_reg_lookup_window_total`, `al_reg_lookup_window_miss`
- `al_reg_reverse_hit`
- `al_dispatch_ticks_to_drain`, `al_dispatch_budget_current`
- `al_dispatch_processed_tick`, `al_dispatch_backlog_before`, `al_dispatch_backlog_after`

## 3. Operator checklist (перед PR)
- Есть baseline-vs-after сравнение для обязательных метрик.
- Приложены operator-readable таблицы + machine-readable отчёт.
- Для core-файлов (`al_area_inc`, `al_registry_inc`, `al_route_inc`) perf-часть не пропущена.
- Если baseline обновлён — есть обоснование и ссылка на PR/commit.
- Preflight summary внешнего инструмента приложен (json/text).

## 4. Linked graph preflight
Используйте preflight-проверки для:
- валидации `al_link_*` связности,
- проверки route/locals,
- выявления WARN/ERROR до релиза.

Примеры формата:

## 5. Sleep markup — контентный минимум
Для sleep-step задавайте:
- `al_step`
- `al_bed_id`
- опционально `al_dur_sec`

Для каждого `al_bed_id` в area должны существовать обязательные waypoint-теги sleep-пары.
