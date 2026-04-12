# 40 — Daily Life Rewrite Program (RU)

> Статус документа: **PROGRAM (non-live)**  
> Дата запуска программы: **2026-04-08**  
> Последняя редакция: **2026-04-12**

> Этот документ не является live-журналом статуса.

## 1. Цель

Переписать Daily Life-контур в clean-room режиме с сохранением канонических принципов:
- contract-first,
- предсказуемый runtime,
- bounded performance,
- поэтапная верификация фактом.

Нумерация clean-room шагов ведётся от `Step 01`.

## 2. Фазы и этапы программы

### Фаза A — Design Baseline
- Step 01: module init/lifecycle ingress.
- Утверждение минимального data-contract.
- Утверждение event-pipeline hooks.
- Утверждение budget/degradation policy.

### Фаза B — Runtime Skeleton
- Step 02: area-tier bootstrap.
- Step 03: dispatcher/resync contract (+ death cleanup policy).
- Step 04: registry + bounded area worker skeleton.

### Фаза C — Controlled Growth
- Step 05: resolver/materialization skeleton.
- Step 06A: owner-run clean-room lifecycle/registry slice.
- Step 06B: acceptance gate (`Scenario F + Scenario G`).
- Первый vertical slice: `BLACKSMITH A/B` (`WORK/SLEEP`).
- Подготовка к `Step 07+` broad expansion только после подтверждённых gate-условий.

### Фаза D — Acceptance
- Финальный PASS-протокол Milestone A (`A–G = PASS`) в едином owner-run или эквивалентном итоговом acceptance verdict.

## 3. Процессные правила выполнения шагов

Каждый шаг обязан включать:
1. Явный контракт изменения.
2. Минимальную реализацию без нецелевого расширения scope.
3. Локальную проверку (smoke/diagnostic/owner-run по необходимости).
4. Синхронный doc-sync по затронутым runtime/governance документам.

Запрещено:
- объединять несколько крупных подсистем в одном шаге;
- менять runtime без документированного sync;
- делать массовый рефактор до прохождения этапной верификации;
- стартовать broad expansion (`Step 07+`) до формально подтверждённых acceptance-gate условий.

## 4. Обязательные источники (active set)

1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`
5. `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`

Runtime/live-статус: `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`.

## 5. Current execution status

`Current execution status -> docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`
