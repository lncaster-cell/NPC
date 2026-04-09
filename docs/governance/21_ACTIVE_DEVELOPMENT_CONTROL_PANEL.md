# Ambient Life v2 — Active Development Control Panel

Дата: 2026-04-09  
Статус: active execution control panel (rewrite track)

---

## 0) Текущий статус

- Статус выполнения: **ACTIVE (owner decision applied)**.
- Решение владельца от **2026-04-09**: legacy-reference не восстанавливаем, разработка v2 идёт clean-room с нуля.
- Восстановлен активный runtime-каталог `scripts/daily_life/` для нового baseline v2.
- Текущий микро-шаг: event-ingress ядро (`OnSpawn`/`OnDeath` -> `SignalEvent(EventUserDefined)` -> `OnUserDefined`).
- Нумерация clean-room шагов перезапущена с **Step 01** после удаления прежнего кода.
- Работа идёт в режиме: `один микро-шаг -> одна проверка -> документирование факта`.

Ключевые документы для текущей фазы:
1. `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`

---

## 0.1) Owner resolution (applied)

- Тип решения: глобальный architectural direction от владельца.
- Решение: разработка Daily Life v2 продолжается с нуля без восстановления legacy reference.
- Ограничение: pipeline остаётся event-driven + area-centric, без helper-first runtime в обход событийного контура.

## 1) Зафиксированное

### 1.1 Этап 0 — Alignment (завершён)
- Границы Daily Life зафиксированы.
- Event-driven + area-centric модель подтверждена.
- Per-NPC heartbeat-first ядро запрещено.

### 1.2 Шаг 1 baseline-runtime (завершён)
- Базовый include `dl_v2_core_inc.nss` содержит module contract (`DL2_IsRuntimeEnabled`, `DL2_InitModuleContract`).
- Добавлен smoke `dl2_smoke_step_01_event_pipeline.nss` для проверки init-contract.

---

## 2) Текущая активная фаза

### Фаза A — Design Baseline (в работе)

DoD фазы:
- [ ] Утверждён минимальный data-contract v2.
- [ ] Утверждён event-pipeline hooks set (module/area/npc).
- [ ] Утверждён performance budget + degradation policy.
- [x] Реализован init-contract + event-ingress hooks + smoke.

---

## 3) Правила исполнения

1. Один PR = один микро-шаг.
2. На каждый шаг обязательно:
   - контракт,
   - минимальная реализация,
   - проверка,
   - синхронизация docs.
3. Нельзя смешивать resolver/materialization/worker в одном шаге без явного отдельного approval.

---

## 4) Ближайший backlog

1. Step 02: area-tier bootstrap (`HOT/WARM/FROZEN`) без полного worker-loop.
2. Step 03: минимальный dispatcher/resync hook для controlled событий.
3. Step 04: registry + bounded worker skeleton.

---

## 5) Формат отчёта владельцу

- Что изменено (1–3 пункта).
- Чем проверено (точные команды).
- Что подтверждено фактом.
- Следующий микро-шаг.
