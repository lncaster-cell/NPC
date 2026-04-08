# 40 — Daily Life v2 Rewrite Program (RU)

> Статус: **ACTIVE / STARTED**  
> Дата запуска: **2026-04-08**

## 1. Цель

Переписать Daily Life-контур с нуля, сохранив канонические принципы, но убрав накопленный технический шум:
- чистые контракты;
- предсказуемое поведение;
- контроль производительности;
- пошаговая проверка без «больших слепых поставок».

## 2. Источники проектирования (обязательно)

Перед каждой новой функцией сверяемся минимум с:
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
4. `archive/daily_life_v1_legacy/scripts/daily_life/` (как тех. референс, не как копипаст).

## 3. Протокол «одна функция за шаг»

Каждый шаг обязан содержать:
1. **Контракт функции** (что принимает, что возвращает, какие гарантии).
2. **Минимальную реализацию** (без побочной «магии»).
3. **Локальную проверку** (smoke/diagnostic script под конкретную функцию).
4. **Запись результата** (что работает, что не работает, что дальше).

Запрещено:
- добавлять несколько новых подсистем в одном PR;
- менять архитектуру и runtime-код без синхронизации документации;
- «лечить всё сразу» без изолированного шага.

## 4. Фазы переписи

### Фаза A — Design Baseline
- [x] Черновик baseline-документа создан (`41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`).
- [ ] Утвердить минимальный v2 data-contract с владельцем.
- [ ] Утвердить v2 event-pipeline (module/area/npc hooks).
- [ ] Зафиксировать performance budget и degradation-policy.

### Фаза B — Runtime Skeleton
- [ ] Ввести пустой bootstrap и диагностический лог.
- [ ] Ввести первый валидированный helper.
- [ ] Подключить smoke-проверку helper-функции.

### Фаза C — Controlled Growth
- [ ] Resolver (в изолированных функциях).
- [ ] Materialization (отдельно от resolver).
- [ ] Worker/fairness loop с профилированием.

### Фаза D — Acceptance
- [ ] Обновлённый runbook для v2.
- [ ] Поэтапный owner-run.
- [ ] Финальный PASS-протокол.

## 5. Репозиторный статус на старте

- v1 runtime архивирован: `archive/daily_life_v1_legacy/scripts/daily_life/`
- v2 runtime workspace открыт: `scripts/daily_life/`
- стартовый stub: `scripts/daily_life/dl_v2_bootstrap.nss`
- reset-лог: `docs/runtime/42_DAILY_LIFE_V2_REPOSITORY_RESET_LOG_RU.md`

## 6. Формат отчётности (жёсткий)

На каждый шаг:
- Что изменено (1–3 пункта).
- Чем проверено (конкретные команды/скрипты).
- Что подтверждено фактом.
- Какой следующий микро-шаг.
