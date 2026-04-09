# 41 — Daily Life v2 Design Baseline (RU)

> Дата: 2026-04-09  
> Статус: draft for owner approval (updated to real repository state)

## 1) Цель baseline

Согласовать минимальную архитектуру v2 до расширения runtime-логики.

## 2) Входные источники

- Канон: `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- Инварианты: `docs/runtime/06_SYSTEM_INVARIANTS.md`
- Digest: `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
- Owner directive (2026-04-09): clean-room implementation without legacy reference restoration

## 3) Минимальный v2 Data Contract (предлагаемый)

### 3.1 Module locals (зафиксировано в коде)
- `dl2_enabled`
- `dl2_contract_version`
- `dl2_module_event_seq`
- `dl2_module_last_event_kind`
- `dl2_module_last_event_actor`
- `dl2_module_spawn_count`
- `dl2_module_death_count`

### 3.2 Area locals (кандидаты на Step 02/03)
- `dl2_area_tier` (`HOT/WARM/FROZEN`)
- `dl2_worker_cursor`
- `dl2_worker_budget`

### 3.3 NPC locals (минимум event-ingress)
- `dl2_npc_event_kind`
- `dl2_npc_event_seq`
- (`dl2_profile_id`, `dl2_state`, `dl2_anchor_id`, `dl2_last_tick`, `dl2_debug_trace`) остаются на следующих шагах

## 4) Event Pipeline v2 (MVP proposal)

1. `OnModuleLoad` — инициализация module contract.
2. `OnNPCSpawn` и `OnNPCDeath` — ingress lifecycle-сигналов.
3. `OnNPCUserDefined` — единый dispatcher lifecycle-сигналов (`SignalEvent(EventUserDefined)`).
4. `OnAreaEnter/OnAreaExit` — управление tier активацией (следующий шаг).
5. `OnAreaHeartbeat` — bounded worker tick (после registry/bootstrap).

## 5) Performance baseline

- На тик обрабатывается не более `budget` NPC.
- В `FROZEN` tier нет фоновой симуляции.
- Функции должны быть идемпотентными в пределах одного тика.

## 6) Фактически реализовано на сегодня

### Step 01 — IMPLEMENTED (clean-room reset index)
`DL2_InitModuleContract()` + lifecycle event ingress (`OnSpawn`/`OnDeath`/`OnUserDefined`).

Контракт:
- `OnModuleLoad` фиксирует contract version и runtime-enabled gate.
- `OnSpawn`/`OnDeath` не выполняют heavy-логику: только отправляют `SignalEvent(EventUserDefined)`.
- `OnUserDefined` обрабатывает только DL2-сигналы и записывает module-level counters.

Реализация:
- `scripts/daily_life/dl_v2_core_inc.nss`
- `scripts/daily_life/dl_on_load.nss`
- `scripts/daily_life/dl_npc_onspawn.nss`
- `scripts/daily_life/dl_npc_ondeath.nss`
- `scripts/daily_life/dl_npc_onud.nss`

Проверка:
- `scripts/daily_life/dl2_smoke_step_01_event_pipeline.nss` (module contract init gate).

## 7) Ограничения до Step 02+

- Не добавлять resolver/materialization/slot-handoff до фиксации init-contract.
- Не мигрировать legacy API массово.
- Не расширять runtime за границы согласованного baseline.
