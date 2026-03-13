# PR Checklist
<!-- DOCSYNC:2026-03-13 -->
> Documentation sync: 2026-03-13. This file was reviewed and aligned with the current repository structure.


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
  - [ ] заполнен machine-readable отчёт (`docs/perf/baselines/perf_gate_report.csv` или `.json`), который принят CI job.
- [ ] **Preflight gate passed (external-only):**
  - [ ] к PR приложен preflight summary (route/link/locals) из внешнего tooling (JSON или text);
  - [ ] CI job `Ambient Life Integrity` зелёный.
- [ ] Для preflight-режимов явно указан контекст запуска во внешнем tooling:
  - [ ] **CI mode**: fail-fast/early-fail конфигурация.
  - [ ] **Operator mode**: полный список issue для triage.

## Scope note for audits/inspections

- [ ] При аудитах/инспекциях не анализировались и не модифицировались `third party/` и вложенный компилятор.
