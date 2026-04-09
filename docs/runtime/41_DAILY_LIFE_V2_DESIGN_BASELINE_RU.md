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

### 3.2 Area locals (зафиксировано после Step 02)
- `dl_area_tier` (`HOT/WARM/FROZEN`)
- `dl_worker_cursor`
- `dl_worker_budget`
- `dl_reg_count`
- `dl_reg_seq`

### 3.3 NPC locals (минимум event-ingress)
- `dl_npc_event_kind`
- `dl_npc_event_seq`
- `dl_reg_on`
- `dl_npc_worker_seq`
- `dl_npc_directive`
- `dl_npc_mat_req`
- `dl_npc_mat_tag`
- (`dl_profile_id`, `dl_state`, `dl_anchor_id`, `dl_last_tick`, `dl_debug_trace`) остаются на следующих шагах

## 4) Event Pipeline (MVP proposal)

Принятые уточнения:
- UserDefined event range для Daily Life: `3000+` (текущий ID: `3001`).
- Зарезервированные движком/BioWare значения (`1000..1011`, `1510`, `1511`) не используем для внутренних событий Daily Life.
- Критерий pipeline NPC на текущем шаге: только `OBJECT_TYPE_CREATURE`, исключая DM; расширение фильтра (summon/companion/service actors) — отдельным шагом.
- Обработка `OnDeath` на текущем шаге ограничена event ingress + counters; cleanup/respawn policy будет формализована в следующем этапе lifecycle/resync.


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

### Step 02 — IMPLEMENTED
`DL_BootstrapAreaTier()` + area lifecycle hooks (`OnAreaEnter`/`OnAreaExit`).

Контракт:
- Tier хранится в `dl_area_tier` как `FROZEN/WARM/HOT`.
- Если в area есть игрок, tier поднимается до `HOT`.
- Если игроки покинули area, tier опускается до `WARM`.

Реализация:
- `scripts/daily_life/dl_core_inc.nss`
- `scripts/daily_life/dl_a_enter.nss`
- `scripts/daily_life/dl_a_exit.nss`

Проверка:
- `scripts/daily_life/dl_smk_tier.nss`.

### Step 03 — IMPLEMENTED
`DL_RequestResync()` + `DL_ProcessResync()` + death-cleanup path.

Контракт:
- Resync-request хранится в NPC locals (`dl_npc_resync_pending`, `dl_npc_resync_reason`).
- On spawn: ставится resync-request и выполняется минимальный `DL_ProcessResync`.
- On death: ставится resync-request и выполняется `DL_CleanupNpcRuntimeState`.

Реализация:
- `scripts/daily_life/dl_core_inc.nss`

Проверка:
- `scripts/daily_life/dl_smk_sync.nss`.

## 7) Ограничения до Step 06+

- Не добавлять resolver/materialization/slot-handoff до фиксации init-contract.
- Не мигрировать legacy API массово.
- Не расширять runtime за границы согласованного baseline.

### Step 04 — IMPLEMENTED
`DL_RegisterNpc()` + `DL_UnregisterNpc()` + `DL_RunAreaWorkerTick()`.

Контракт:
- Runtime-candidate NPC регистрируется в registry layer (`dl_reg_on`, area counters).
- Worker выполняется на `OnAreaHeartbeat`, использует `dl_worker_budget` и `dl_worker_cursor`.
- Worker остаётся bounded: scan-cap и ограничение budget, без resolver/materialization логики.

Реализация:
- `scripts/daily_life/dl_core_inc.nss`
- `scripts/daily_life/dl_a_hb.nss`

Проверка:
- `scripts/daily_life/dl_smk_work.nss`.

### Step 05 — IMPLEMENTED
`DL_ResolveNpcDirective*()` + `DL_ApplyDirectiveSkeleton()` + `DL_ApplyMaterializationSkeleton()`.

Контракт:
- Первый resolver-срез ограничен только профилем `early_worker`.
- Единственная директива шага: `SLEEP`.
- Окно сна фиксировано owner-решением: `22:00..06:00`.
- Materialization на этом шаге только skeleton-сигнал (`dl_npc_mat_req`, `dl_npc_mat_tag`) без activity/anchor-исполнения.

Реализация:
- `scripts/daily_life/dl_res_inc.nss`
- `scripts/daily_life/dl_core_inc.nss` (вызов resolver/materialization skeleton из worker touch).

Проверка:
- `scripts/daily_life/dl_smk_res.nss`.


## 8) Этапы выполнения (самостоятельно декомпозированные)

1. **Step 01 (done):** module init contract + lifecycle ingress (`OnSpawn/OnDeath/OnUserDefined`).
2. **Step 02 (done):** area-tier bootstrap (`HOT/WARM/FROZEN`) без worker-loop.
3. **Step 03 (done):** dispatcher/resync contract (включая death-cleanup правила).
4. **Step 04 (done):** registry + bounded worker skeleton.
5. **Step 05 (done):** resolver/materialization skeleton.
6. **Step 06+:** acceptance по rewrite program.
