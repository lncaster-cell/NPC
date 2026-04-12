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

### Фаза D — Acceptance
- [x] Runbook (`52_*`).
- [x] Owner-run текущего clean-room lifecycle/registry slice.
- [x] Scenario F (full bounded resync/materialization on area enter).
- [x] Scenario G (`HOT/WARM/FROZEN` acceptance subset for active tier-cycle).
- [ ] Финальный PASS-протокол Milestone A (`A–G = PASS` в одном owner-run или эквивалентном итоговом acceptance verdict).

## 5. Актуальный репозиторный факт (2026-04-12)

- Владелец подтвердил clean-room путь: legacy reference не восстанавливается.
- Active runtime workspace: `daily_life/`.
- Временное debug/logging остаётся в игровом чате через централизованный helper `DL_LogRuntime`; текущая debug-ориентированная инициализация управляется модульным флагом `dl_chat_log`.
- Owner-run текущего clean-room lifecycle/registry slice уже выполнен и зафиксирован в acceptance journal.
- Acceptance gate по `Scenario F` и `Scenario G` закрыт.
- Текущая рабочая точка: первый vertical slice `BLACKSMITH A/B` (`WORK/SLEEP`) без перехода к broad `Step 07+`.

## 5.1 Принцип интеграции NWN2 (текущий фокус)

- Не обходить `OnSpawn`/`OnDeath`/`OnUserDefined`.
- `OnSpawn`/`OnDeath` работают как ingress-точки и отправляют событие через `SignalEvent(EventUserDefined)`.
- `OnUserDefined` — единая шина обработки lifecycle-сигналов Daily Life.
- UserDefined диапазон проекта: `3000+` (текущий ID `3001`).

Справка по UserDefined диапазонам:
- не использовать engine/BioWare события `1000..1011`, `1510`, `1511`;
- для внутренних событий Daily Life использовать отдельный project-диапазон.

## 5.2 Этапы (рабочая декомпозиция)

1. Step 01 — done: init + lifecycle ingress.
2. Step 02 — area-tier bootstrap (done).
3. Step 03 — dispatcher/resync contract (+ death cleanup policy) (done).
4. Step 04 — registry + worker skeleton (done).
5. Step 05 — resolver/materialization skeleton (done).
6. Step 06A — owner-run текущего clean-room lifecycle/registry slice (done).
7. Step 06B — acceptance gate `Scenario F + Scenario G` (done).
8. Текущая рабочая точка — первый vertical slice `BLACKSMITH A/B` (`WORK/SLEEP`) в `daily_life/`.
9. Step 07+ broad expansion — not started / not confirmed.

## 6. Формат отчётности

На каждый шаг:
- Что изменено.
- Чем проверено.
- Фактический результат.
- Следующий шаг.

## 7. Текущий операционный статус

- Baseline runbook подготовлен и уже использован для owner-run текущего clean-room lifecycle/registry slice.
- Это не эквивалентно полному owner-run Milestone A.
- Acceptance gate по `Scenario F/G` уже закрыт и зафиксирован в `53_*` и acceptance journal.
- Следующий рабочий шаг: продолжать первый vertical slice `BLACKSMITH A/B` (`WORK/SLEEP`) и не расширяться шире согласованного scope.
- До итогового закрытия `A–G` broad переход к `Step 07+` не считается подтверждённым.

## 8. Что не делать сейчас

- Не расползаться шире текущего `BLACKSMITH A/B`, пока не зафиксирован результат первого vertical slice.
- Не делать массовый foundation-refactor ради красоты.
- Не переносить logging из чата в другой канал в этой итерации.
- Не возвращать legacy reference path.

## 9. Backlog candidates (вынесено из бывшего roadmap-слоя `54_*`)

Эти пункты **не являются активным execution-планом текущей итерации**.  
Они сохранены как кандидаты на следующую декомпозицию **после** закрытия текущего фокуса (`BLACKSMITH A/B`, затем `C/D/E`, затем итоговый Milestone A verdict).

- Anchor policy maturity:
  - `directive -> anchor_group`;
  - fallback на альтернативный anchor в группе.
- Activity layer maturity:
  - формальный переход `directive + anchor context -> activity`;
  - отдельная эволюция activity-слоя без смешения с resolver.
- Materialization maturity:
  - разделение instant/local-walk/soft-hide path;
  - controlled visual activation по tier (`WARM` prep, `HOT` full local runtime, `FROZEN` без фоновой жизни).
- Dialogue/Service refresh:
  - стабильный `directive -> dialogue mode`;
  - `directive -> service_available` для service NPC.
- Base/Fallback/Absence hardening:
  - обработка `BASE_INVALID/BASE_LOST`;
  - fallback chain до `IDLE_BASE/RETURN_BASE` и дальше до `UNASSIGNED/ABSENT`.
- External override / resync / handoff:
  - read-only override input shell;
  - time/context/tier resync path;
  - vacancy/role handoff shell (вне core resolver).
- Worker/fairness/profiling:
  - full fairness loop;
  - минимальные profiling/observability counters (`trace`, degradation counters, binding integrity checks).
- Acceptance expansion (post-current scope):
  - owner-facing runbook расширенного покрытия;
  - owner-run сценарии beyond текущего vertical slice (`sleep/work/tier/resync` в расширенном составе);
  - единый PASS/FAIL протокол на расширенный scope.
