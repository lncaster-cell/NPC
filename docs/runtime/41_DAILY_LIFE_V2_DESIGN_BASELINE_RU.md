# 41 — Daily Life v2 Design Baseline (RU)

> Дата: 2026-04-09  
> Статус: draft for owner approval (updated to real repository state)

## 1) Цель baseline

Согласовать минимальную архитектуру v2 до расширения runtime-логики.

## 2) Входные источники

- Канон: `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- Инварианты: `docs/runtime/06_SYSTEM_INVARIANTS.md`
- Digest: `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
- Legacy reference code: `archive/daily_life_v1_legacy/scripts/daily_life/`

## 3) Минимальный v2 Data Contract (предлагаемый)

### 3.1 Module locals (уже частично в коде)
- `dl2_enabled`
- `dl2_contract_version`

### 3.2 Area locals (кандидаты на Step 02/03)
- `dl2_area_tier` (`HOT/WARM/FROZEN`)
- `dl2_worker_cursor`
- `dl2_worker_budget`

### 3.3 NPC locals (кандидаты на Step 03+)
- `dl2_profile_id`
- `dl2_state`
- `dl2_anchor_id`
- `dl2_last_tick`
- `dl2_debug_trace`

## 4) Event Pipeline v2 (MVP proposal)

1. `OnModuleLoad` — инициализация module contract.
2. `OnAreaEnter/OnAreaExit` — управление tier активацией.
3. `OnAreaHeartbeat` — bounded worker tick.
4. `OnNPCSpawn` — регистрация NPC в pipeline.
5. `OnNPCUserDefined` — targeted resync/diagnostic.

## 5) Performance baseline

- На тик обрабатывается не более `budget` NPC.
- В `FROZEN` tier нет фоновой симуляции.
- Функции должны быть идемпотентными в пределах одного тика.

## 6) Фактически реализовано на сегодня

### Step 01 — IMPLEMENTED
`DL2_IsRuntimeEnabled()`

Контракт:
- Вход: нет.
- Выход: `TRUE/FALSE`.
- Логика: `dl2_enabled == TRUE` и `dl2_contract_version == v2.a0`.

Реализация:
- `scripts/daily_life/dl_v2_runtime_inc.nss`

Проверка:
- `scripts/daily_life/dl2_smoke_step_01.nss` (3 кейса: disabled / invalid version / valid version).

## 7) Ограничения до Step 02+

- Не добавлять resolver/materialization/slot-handoff до фиксации init-contract.
- Не мигрировать legacy API массово.
- Не расширять runtime за границы согласованного baseline.
