# PR Checklist

## Core Ambient Life changes (`scripts/ambient_life/al_*`)

Отметьте пункты перед отправкой PR:

- [ ] Приложен perf-отчёт для S80/S100/S120 по `docs/PERF_PROFILE.md`.
- [ ] Для всех обязательных метрик есть baseline-vs-after сравнение.
- [ ] Добавлены оба формата сравнения:
  - [ ] Markdown-таблицы (operator-readable)
  - [ ] CSV (machine-readable, единый формат)
- [ ] Для core-изменений (`al_area_inc.nss`, `al_registry_inc.nss`, `al_route_inc.nss`) подтверждено, что без baseline-vs-after PR считается неполным.
- [ ] Если baseline обновлён, соблюдено правило из `docs/perf/baselines/README.md` (подтверждённое улучшение или обоснованное изменение поведения + ссылка на PR/commit).
- [ ] **Perf gate passed** для PR с изменениями в `scripts/ambient_life/al_*`:
  - [ ] CI job `Ambient Life Perf Gate` зелёный;
  - [ ] заполнен machine-readable отчёт (`docs/perf/baselines/perf_gate_report.csv` или `.json`) и валидирован скриптом `scripts/ambient_life/validate_perf_gate.py`.
- [ ] К PR приложен preflight summary из `scripts/ambient_life/run_preflight_suite.py` (JSON или text), подтверждающий актуальное состояние route/link/locals.
- [ ] Для preflight-артефактов выбран и зафиксирован режим сортировки issue:
  - [ ] default (без сортировки) для performance/диагностики,
  - [ ] `--deterministic-sort` для стабильной группировки без полной сортировки,
  - [ ] `--strict-deterministic-sort` **только** если CI действительно требует полностью детерминированный порядок.
