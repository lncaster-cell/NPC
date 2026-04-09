# 40 — Daily Life v2 Rewrite Program (RU)

> Статус: **ACTIVE**  
> Дата запуска: **2026-04-08**  
> Последняя актуализация: **2026-04-09**

## 1. Цель

Переписать Daily Life-контур с нуля, сохранив канонические принципы и убрав технический шум:
- contract-first,
- предсказуемый runtime,
- bounded performance,
- поэтапная проверка фактом.

## 2. Обязательные источники перед каждым шагом
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `archive/daily_life_v1_legacy/scripts/daily_life/` (только reference)

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
- [x] Реализован и проверен helper `DL2_IsRuntimeEnabled()`.
- [ ] Утвердить минимальный data-contract v2.
- [ ] Утвердить event-pipeline hooks.
- [ ] Утвердить budget/degradation policy.

### Фаза B — Runtime Skeleton
- [ ] `OnModuleLoad` init contract.
- [ ] Area-tier bootstrap.
- [ ] Минимальный dispatcher/resync hook.

### Фаза C — Controlled Growth
- [ ] Resolver.
- [ ] Materialization.
- [ ] Worker/fairness loop + profiling.

### Фаза D — Acceptance
- [ ] Runbook v2.
- [ ] Owner-run по сценариям.
- [ ] Финальный PASS-протокол.

## 5. Актуальный репозиторный факт (2026-04-09)

- v1 runtime архивирован: `archive/daily_life_v1_legacy/scripts/daily_life/`
- активный runtime workspace: `scripts/daily_life/`
- текущие файлы v2:
  - `scripts/daily_life/dl_v2_runtime_inc.nss`
  - `scripts/daily_life/dl2_smoke_step_01.nss`
- reset-лог: `docs/runtime/42_DAILY_LIFE_V2_REPOSITORY_RESET_LOG_RU.md`

## 6. Формат отчётности

На каждый шаг:
- Что изменено.
- Чем проверено.
- Фактический результат.
- Следующий шаг.
