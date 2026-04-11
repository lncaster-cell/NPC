# Ambient Life — Active Development Control Panel

Дата: 2026-04-11
Статус: execution control panel

## 0) Режим работы

- Формат: **code-first**.
- Документация ограничена active doc set (5 файлов).
- Канонический runtime workspace path: `daily_life/`.
- Любые ссылки на `scripts/daily_life/` считаются legacy.

## 1) Текущий фактический статус

- Owner-run текущего clean-room lifecycle/registry slice уже выполнен (см. acceptance journal).
- Подтверждены `AREA_ENTER`, `HB`, death lifecycle и cleanup регистрации в isolated area (`reg: 1 -> 0`).
- Это **не равно** полному закрытию Milestone A.
- Незакрытые обязательные acceptance-шаги: **Scenario F** и **Scenario G**.
- До фиксации verdict по F/G переход к Step 07+ не считается подтверждённым.

## 2) Active doc set (обязательный)

1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
5. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

## 3) Операционные reference-документы текущего acceptance-этапа

- `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
- `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`
- `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`

Используются для уточнения acceptance-статуса и фактической текущей точки без расширения active doc set.

## 4) Правила PR

1. Каждый PR должен содержать полезный кодовый сдвиг в `daily_life/`, кроме специально выделенных cleanup PR.
2. Док-изменения допускаются только в active doc set и только как синхронизация факта.
3. Новые digest/индексные meta-файлы не добавляются.
