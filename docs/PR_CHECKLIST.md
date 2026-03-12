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

## Linked graph changes

- [ ] Для изменений linked-area данных/скриптов (`al_link_*`, `scripts/ambient_life/al_link_preflight.py`) запущен `python3 scripts/ambient_life/al_link_preflight.py --input <linked_areas.json>`; при `ERROR` merge блокируется.
