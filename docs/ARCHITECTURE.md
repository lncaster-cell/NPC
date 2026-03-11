# Ambient Life — Architecture (актуально на Stage I.1)

## 1. Принцип

Система построена как **area-driven event runtime**:
- область управляет жизненным циклом симуляции;
- NPC реагируют на user-defined события;
- длительная логика выполняется bounded action-очередями, а не heartbeat-петлями.

## 2. Слои

### 2.1 Entry layer

Тонкие скрипты-обработчики событий:
- area: `al_area_onenter`, `al_area_onexit`, `al_area_tick`;
- module: `al_mod_onleave`;
- npc: `al_npc_onspawn`, `al_npc_ondeath`, `al_npc_onud`, `al_npc_onblocked`, `al_npc_ondisturbed`.

### 2.2 Core runtime

`al_core_inc` координирует:
- spawn/death register lifecycle;
- обработку шины событий `OnUserDefined`;
- запуск/перезапуск routine.

### 2.3 Area lifecycle + LOD

`al_area_inc`:
- tiers: `FREEZE(0)`, `WARM(1)`, `HOT(2)`;
- тик по токену (`al_tick_token`) с периодом 30 сек;
- slot computation (`hour/4`);
- dispatch в area registry;
- linked areas warm-retention через `al_link_*`.

### 2.4 Registry

`al_registry_inc`:
- плотный массив `al_npc_0..` + `al_npc_count`;
- swap-remove при удалении и compaction;
- runtime cap: `AL_MAX_NPCS = 100`.

### 2.5 Route engine (D/E)

`al_route_inc`:
- route cache per NPC/slot/tag;
- до 16 шагов (`AL_ROUTE_MAX_STEPS`);
- routine state: индекс шага, циклы, active-flag;
- fallback в idle activity при провале загрузки маршрута.

### 2.6 Transition subsystem (F)

`al_transition_inc`:
- `AL_TRANSITION_AREA_HELPER`;
- `AL_TRANSITION_INTRA_TELEPORT`;
- отдельный runtime-state, очищаемый при reset routine.

### 2.7 Sleep subsystem (G)

`al_sleep_inc`:
- sleep step определяется по `al_bed_id`;
- поддержка `approach/pose` waypoint связки;
- fallback sleep-on-place при неполном конфиге.

### 2.8 Activity subsystem (H)

`al_activity_inc`:
- канонические activity IDs;
- mapping activity -> behavior;
- единый apply-path для шага routine.

### 2.9 Reactions (I.0 / I.1)

- I.0 `al_blocked_inc`: door-first unblock + bounded resume/resync.
- I.1 `al_react_inc`: inventory/theft disturbance capture, bounded override, resume routine.

## 3. Event bus

Канонические события:
- `3100..3105` — slot events;
- `3106` — RESYNC;
- `3107` — ROUTE_REPEAT;
- `3108` — BLOCKED_RESUME.

NPC слушают события только через `OnUserDefined`.

## 4. Runtime-инварианты

- Нет heartbeat на NPC;
- no per-NPC polling loops;
- тик централизован в области;
- dispatch идёт только по текущему плотному реестру области.

## 5. Границы Stage I.1

В I.1 **нет** crime/alarm/world-escalation. Реализован только foundation для disturbed inventory/theft с безопасным возвратом в обычный маршрут.
