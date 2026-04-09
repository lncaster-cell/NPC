# 41 — Daily Life Design Baseline (RU)

> Дата: 2026-04-09  
> Статус: draft for owner approval (updated to real repository state)

## 1) Цель baseline

Согласовать минимальную архитектуру до расширения runtime-логики.

## 2) Входные источники

- Канон: `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- Инварианты: `docs/runtime/06_SYSTEM_INVARIANTS.md`
- Digest: `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
- Owner directive (2026-04-09): clean-room implementation without legacy reference restoration

## 3) Минимальный Data Contract (предлагаемый)

### 3.1 Module locals (зафиксировано в коде)
- `dl_enabled`
- `dl_contract_version`
- `dl_module_event_seq`
- `dl_module_last_event_kind`
- `dl_module_last_event_actor`
- `dl_module_spawn_count`
- `dl_module_death_count`

### 3.2 Area locals (кандидаты на Step 02/03)
- `dl_area_tier` (`HOT/WARM/FROZEN`)
- `dl_worker_cursor`
- `dl_worker_budget`

### 3.3 NPC locals (минимум event-ingress)
- `dl_npc_event_kind`
- `dl_npc_event_seq`
- (`dl_profile_id`, `dl_state`, `dl_anchor_id`, `dl_last_tick`, `dl_debug_trace`) остаются на следующих шагах

## 4) Event Pipeline (MVP proposal)

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
`DL_InitModuleContract()` + lifecycle event ingress (`OnSpawn`/`OnDeath`/`OnUserDefined`).

Контракт:
- `OnModuleLoad` фиксирует contract version и runtime-enabled gate.
- `OnSpawn`/`OnDeath` не выполняют heavy-логику: только отправляют `SignalEvent(EventUserDefined)`.
- `OnUserDefined` обрабатывает только DL-сигналы и записывает module-level counters.

Реализация:
- `scripts/daily_life/dl_core_inc.nss`
- `scripts/daily_life/dl_load.nss`
- `scripts/daily_life/dl_spawn.nss`
- `scripts/daily_life/dl_death.nss`
- `scripts/daily_life/dl_userdef.nss`

Проверка:
- `scripts/daily_life/dl_smoke_ev.nss` (module contract init gate).

## 7) Ограничения до Step 02+

- Не добавлять resolver/materialization/slot-handoff до фиксации init-contract.
- Не мигрировать legacy API массово.
- Не расширять runtime за границы согласованного baseline.
