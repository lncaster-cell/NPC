# 41 — Daily Life Design Baseline (RU)

> Дата: 2026-04-12  
> Статус: baseline reference synced to current repository state

## 1) Цель baseline

Согласовать минимальную архитектуру foundation-слоя до расширения runtime-логики и держать единое понимание того, с какого минимального контура вырос текущий clean-room runtime.

## 2) Входные источники

- Канон: `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- Инварианты: `docs/runtime/06_SYSTEM_INVARIANTS.md`
- Rewrite program: `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
- Owner directive (2026-04-09): clean-room implementation without legacy reference restoration
- Frozen digest `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md` может использоваться только как historical reference, но не как активный источник новых требований

## 3) Минимальный Data Contract (baseline layer)

### 3.1 Module locals (зафиксировано в коде foundation/runtime layer)
- `dl_enabled`
- `dl_contract_version`
- `dl_chat_log`
- `dl_module_event_seq`
- `dl_module_last_event_kind`
- `dl_module_last_event_actor`
- `dl_module_spawn_count`
- `dl_module_death_count`
- `dl_module_resync_req`
- `dl_module_cleanup_cnt`
- `dl_module_worker_seq`
- `dl_module_worker_ticks`

### 3.2 Area locals (baseline + acceptance hardening)
- `dl_area_tier` (`HOT/WARM/FROZEN`)
- `dl_worker_cursor`
- `dl_worker_budget`
- `dl_reg_count`
- `dl_reg_seq`
- `dl_area_enter_resync_pending`
- `dl_area_enter_resync_cursor`
- `dl_area_enter_resync_touched`
- `dl_area_enter_resync_done`

### 3.3 NPC locals (foundation/runtime minimum)
- `dl_npc_event_kind`
- `dl_npc_event_seq`
- `dl_npc_resync_pending`
- `dl_npc_resync_reason`
- `dl_reg_on`
- `dl_npc_worker_seq`
- `dl_npc_directive`
- `dl_npc_mat_req`
- `dl_npc_mat_tag`
- `dl_profile_id`
- `dl_state`

Примечание:
- вертикальный slice-слой (`BLACKSMITH A/B`, presentation/activity locals, sleep execution locals и др.) уже существует в текущем коде, но не переопределяет этот baseline-документ;
- текущая операционная точка после baseline отражается в `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`.

## 4) Event Pipeline (baseline contract)

Принятые уточнения:
- UserDefined event range для Daily Life: `3000+` (текущий ID: `3001`).
- Зарезервированные движком/BioWare значения (`1000..1011`, `1510`, `1511`) не используем для внутренних событий Daily Life.
- Критерий pipeline NPC на foundation-слое: `OBJECT_TYPE_CREATURE`, исключая DM; расширение фильтра (summon/companion/service actors) — отдельным шагом.
- `OnDeath` на baseline-слое ограничен lifecycle ingress + cleanup/runtime counters; более широкий death policy — отдельный уровень поведения.

Контур foundation-layer:
1. `OnModuleLoad` — инициализация module contract.
2. `OnNPCSpawn` и `OnNPCDeath` — ingress lifecycle-сигналов.
3. `OnNPCUserDefined` — единый dispatcher lifecycle-сигналов (`SignalEvent(EventUserDefined)`).
4. `OnAreaEnter/OnAreaExit` — управление tier-активацией.
5. `OnAreaHeartbeat` — bounded worker tick и area-enter resync processing.

## 5) Performance baseline

- На один heartbeat обрабатывается не более `budget` NPC.
- В `FROZEN` tier нет фоновой симуляции.
- Tier/runtime path остаётся event-driven + area-centric.
- Нельзя возвращаться к per-NPC heartbeat-first ядру.

## 6) Foundation-слой, фактически реализованный в репозитории

### Step 01 — IMPLEMENTED
`DL_InitModuleContract()` + lifecycle event ingress (`OnSpawn`/`OnDeath`/`OnUserDefined`).

Контракт:
- `OnModuleLoad` фиксирует contract version и runtime-enabled gate.
- `OnSpawn`/`OnDeath` не выполняют heavy-логику: только отправляют `SignalEvent(EventUserDefined)`.
- `OnUserDefined` обрабатывает только DL-сигналы и записывает module-level counters.

Реализация:
- `daily_life/dl_core_inc.nss`
- `daily_life/dl_load.nss`
- `daily_life/dl_spawn.nss`
- `daily_life/dl_death.nss`
- `daily_life/dl_userdef.nss`

Проверка:
- `daily_life/dl_smoke_ev.nss` (module contract init gate).

### Step 02 — IMPLEMENTED
`DL_BootstrapAreaTier()` + area lifecycle hooks (`OnAreaEnter`/`OnAreaExit`).

Контракт:
- Tier хранится в `dl_area_tier` как `FROZEN/WARM/HOT`.
- Если в area есть игрок, tier поднимается до `HOT`.
- Если игроки покинули area, tier опускается до `WARM`.

Реализация:
- `daily_life/dl_core_inc.nss`
- `daily_life/dl_a_enter.nss`
- `daily_life/dl_a_exit.nss`

Проверка:
- `daily_life/dl_smk_tier.nss`.

### Step 03 — IMPLEMENTED
`DL_RequestResync()` + `DL_ProcessResync()` + death-cleanup path.

Контракт:
- Resync-request хранится в NPC locals (`dl_npc_resync_pending`, `dl_npc_resync_reason`).
- On spawn: ставится resync-request и выполняется минимальный `DL_ProcessResync`.
- On death: выполняется `DL_CleanupNpcRuntimeState`.

Реализация:
- `daily_life/dl_core_inc.nss`

Проверка:
- `daily_life/dl_smk_sync.nss`.

### Step 04 — IMPLEMENTED
`DL_RegisterNpc()` + `DL_UnregisterNpc()` + `DL_RunAreaWorkerTick()`.

Контракт:
- Runtime-candidate NPC регистрируется в registry layer (`dl_reg_on`, area counters).
- Worker выполняется на `OnAreaHeartbeat`, использует `dl_worker_budget` и `dl_worker_cursor`.
- Worker остаётся bounded: scan-cap и ограничение budget, без возврата к full background simulation.

Реализация:
- `daily_life/dl_core_inc.nss`
- `daily_life/dl_a_hb.nss`

Проверка:
- `daily_life/dl_smk_work.nss`.

### Step 05 — IMPLEMENTED
`DL_ResolveNpcDirective*()` + `DL_ApplyDirectiveSkeleton()` + `DL_ApplyMaterializationSkeleton()`.

Контракт:
- Первый resolver-срез был ограничен foundation-профилем `early_worker`.
- Базовая owner-рамка сна: `22:00..06:00`.
- Materialization на baseline-слое стартовал как skeleton-сигнал (`dl_npc_mat_req`, `dl_npc_mat_tag`) без broad activity/anchor runtime.

Реализация:
- `daily_life/dl_res_inc.nss`
- `daily_life/dl_core_inc.nss` (вызов resolver/materialization path из worker touch)

Проверка:
- `daily_life/dl_smk_res.nss`.

### Step 06 — IMPLEMENTED (baseline runbook + owner-run)
Baseline runbook и owner-run foundation-slice выполнены.

Контракт:
- Runbook зафиксировал последовательность проверок Steps 01–05 без расширения runtime.
- Owner-run baseline использовался отдельно по зафиксированному шаблону отчёта.

Реализация:
- `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
- фактические owner-run результаты хранятся в `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`

### Post-baseline acceptance state
После foundation-runbook:
- acceptance gate `Scenario F` и `Scenario G` закрыт;
- текущая операционная точка смещена в первый vertical slice `BLACKSMITH A/B`;
- эта стадия отслеживается не в baseline-документе, а в `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`.

## 7) Ограничения baseline-документа

- Этот документ не должен превращаться в полный журнал всех последующих runtime-расширений.
- Здесь фиксируется foundation-слой и минимальная архитектурная опора.
- Текущая живая рабочая точка после baseline должна отслеживаться через `40_*`, `21_*`, `53_*` и acceptance journal.

## 8) Этапы baseline-выполнения

1. **Step 01 (done):** module init contract + lifecycle ingress (`OnSpawn/OnDeath/OnUserDefined`).
2. **Step 02 (done):** area-tier bootstrap (`HOT/WARM/FROZEN`).
3. **Step 03 (done):** dispatcher/resync contract (включая death-cleanup).
4. **Step 04 (done):** registry + bounded worker skeleton.
5. **Step 05 (done):** resolver/materialization baseline.
6. **Step 06 (done):** baseline runbook used; owner-run foundation-slice completed.
