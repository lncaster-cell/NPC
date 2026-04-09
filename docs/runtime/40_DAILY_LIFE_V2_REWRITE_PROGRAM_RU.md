# 40 — Daily Life Rewrite Program (RU)

> Статус: **ACTIVE**  
> Дата запуска: **2026-04-08**  
> Последняя актуализация: **2026-04-09**

## 1. Цель

Переписать Daily Life-контур с нуля, сохранив канонические принципы и убрав технический шум:
- contract-first,
- предсказуемый runtime,
- bounded performance,
- поэтапная проверка фактом.

Нумерация шагов в clean-room ветке перезапущена с `Step 01`.

## 2. Обязательные источники перед каждым шагом
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `README.md` (фактическое состояние репозитория и active workspace)

## 3. Протокол «одна функция за шаг»

Каждый шаг включает:
1. Контракт функции.
2. Минимальную реализацию.
3. Локальную проверку (smoke/diagnostic).
4. Синхронное обновление документации.

Запрещено:
- внедрять несколько подсистем в одном шаге,
- менять runtime без doc-sync,
- делать «массовый рефактор» без этапной верификации.

## 4. Фазы переписи

### Фаза A — Design Baseline (active)
- [x] Создан baseline-документ (`41_*`).
- [x] Реализован module contract (`DL_IsRuntimeEnabled`, `DL_InitModuleContract`).
- [ ] Утвердить минимальный data-contract.
- [ ] Утвердить event-pipeline hooks.
- [ ] Утвердить budget/degradation policy.

### Фаза B — Runtime Skeleton
- [x] `OnModuleLoad` init contract.
- [x] Area-tier bootstrap (Step 02).
- [x] Минимальный dispatcher/resync hook (через `OnUserDefined`, Step 03).
- [x] Registry + bounded area worker skeleton (Step 04).

### Фаза C — Controlled Growth
- [ ] Resolver.
- [ ] Materialization.
- [ ] Worker/fairness loop + profiling.

### Фаза D — Acceptance
- [ ] Runbook.
- [ ] Owner-run по сценариям.
- [ ] Финальный PASS-протокол.

## 5. Актуальный репозиторный факт (2026-04-09)

- Владелец подтвердил clean-room путь: legacy reference не восстанавливается.
- Активный runtime workspace: `scripts/daily_life/`.
- В рамках текущего шага добавлены файлы:
  - `scripts/daily_life/dl_core_inc.nss`
  - `scripts/daily_life/dl_load.nss`
  - `scripts/daily_life/dl_spawn.nss`
  - `scripts/daily_life/dl_death.nss`
  - `scripts/daily_life/dl_userdef.nss`
  - `scripts/daily_life/dl_smoke_ev.nss`
  - `scripts/daily_life/dl_a_enter.nss`
  - `scripts/daily_life/dl_a_exit.nss`
  - `scripts/daily_life/dl_smk_tier.nss`
  - `scripts/daily_life/dl_smk_sync.nss`
  - `scripts/daily_life/dl_a_hb.nss`
  - `scripts/daily_life/dl_smk_work.nss`

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
5. Step 05 — resolver/materialization skeleton.

## 6. Формат отчётности

На каждый шаг:
- Что изменено.
- Чем проверено.
- Фактический результат.
- Следующий шаг.
