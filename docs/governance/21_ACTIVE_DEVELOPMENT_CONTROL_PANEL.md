# Ambient Life v2 — Active Development Control Panel

Дата: 2026-04-09  
Статус: active execution control panel (rewrite track)

---

## 0) Текущий статус

- Legacy-контур `Daily Life v1` хранится в `archive/daily_life_v1_legacy/scripts/daily_life/`.
- Активный каталог `scripts/daily_life/` сейчас содержит два рабочих артефакта:
  - `dl_v2_runtime_inc.nss`
  - `dl2_smoke_step_01.nss`
- Работа идёт в режиме: `один микро-шаг -> одна проверка -> документирование факта`.

Ключевые документы для текущей фазы:
1. `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`

---

## 1) Зафиксированное

### 1.1 Этап 0 — Alignment (завершён)
- Границы Daily Life зафиксированы.
- Event-driven + area-centric модель подтверждена.
- Per-NPC heartbeat-first ядро запрещено.

### 1.2 Шаг 1 baseline-runtime (завершён)
- Реализована функция `DL2_IsRuntimeEnabled()`.
- Есть smoke `dl2_smoke_step_01.nss` (3 кейса PASS/FAIL).

---

## 2) Текущая активная фаза

### Фаза A — Design Baseline (в работе)

DoD фазы:
- [ ] Утверждён минимальный data-contract v2.
- [ ] Утверждён event-pipeline hooks set (module/area/npc).
- [ ] Утверждён performance budget + degradation policy.
- [x] Реализован и проверен первый helper + smoke.

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

1. Step 02: `OnModuleLoad` init contract (включая version stamp).
2. Step 03: area-tier bootstrap (`HOT/WARM/FROZEN`) без полного worker-loop.
3. Step 04: минимальный dispatcher hook для controlled resync event.

---

## 5) Формат отчёта владельцу

- Что изменено (1–3 пункта).
- Чем проверено (точные команды).
- Что подтверждено фактом.
- Следующий микро-шаг.
