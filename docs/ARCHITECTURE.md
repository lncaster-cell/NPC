# Ambient Life — Architecture Canon (Stage A/B/C + Stage D/E + Stage F transitions + Stage G sleep + Stage H activity semantics)

## 1) Scope

- Stage A: базовые contracts.
- Stage B: core lifecycle + event bus.
- Stage C: area graph linkage + `FREEZE/WARM/HOT` LOD.
- Stage D: area-scoped route cache foundation.
- Stage E: bounded multi-step routines в `HOT`.
- Stage F: отдельная transition subsystem поверх Stage E (без смешивания с route cache).
- Stage G: отдельная sleep subsystem поверх Stage E/F (special routine case).
- Stage H: отдельная canonical activity subsystem для ordinary non-sleep/non-transition шагов.
- Stage I.0: локальный `OnBlocked` unblock layer (door-first + bounded fallback/resync).

Обязательные принципы:
- Event-driven оркестрация через `OnUserDefined`.
- Один area-level tick loop, без NPC heartbeat.
- Никаких per-NPC periodic timers.
- Никакого polling arrival tracking.
- Hot path cache-first, без repeated full-area scans.
- Route/routine/transition runtime исполняется только в `HOT`.

---

## 2) Layers

### 2.1 Entry scripts
Внешние входы:
- `al_area_onenter`
- `al_area_onexit`
- `al_area_tick`
- `al_mod_onleave`
- `al_npc_onspawn`
- `al_npc_ondeath`
- `al_npc_onud`
- `al_npc_onblocked`

### 2.2 Core layer
Управляет area/npc lifecycle и dispatch:
- slot events / resync;
- запуском Stage D/E route progression;
- bounded step-advance hook;
- runtime-owned locals (`al_last_slot`, `al_last_area`, `al_mode`).

### 2.3 Area Graph + LOD layer (Stage C)
- area linkage через `al_link_count` + `al_link_<idx>`;
- hysteresis policy;
- route/transition runtime разрешён только в `HOT`.

### 2.4 Registry + cache layer
- dense area registry (`al_npc_count`, `al_npc_<idx>`);
- controlled cache build/rebuild;
- без repeated scans в hot path.

### 2.5 Route cache + bounded routines (Stage D/E)
- slot -> route tag (`alwp0..alwp5`);
- ordered chain только по `al_step`;
- bounded multi-step queue execution;
- fallback-first safety.

### 2.6 Transition subsystem (Stage F, separate)
Два канонических механизма:
1. **Area-to-area helper transition** — переход между area через заранее поставленную пару helper waypoint.
2. **Intra-area teleport transition** — teleport внутри одной area через отдельную пару waypoint.

Ключевая граница:
- Transition step задаётся в route chain, но исполняется отдельным runtime path.
- Stage D route cache не преобразуется в transition graph.
- Helper transitions не становятся "обычным move step".

### 2.7 Future layers
- Stage I.0 local runtime unblock (`OnBlocked`: door-first + bounded fallback/resync).
- Stage I.x reactions (disturbed/crime/alarm), deferred.

---

## 3) Event model

Internal namespace `3100..3108`:
- `3100..3105` — `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`.
- `3106` — `AL_EVENT_RESYNC`.
- `3107` — `AL_EVENT_ROUTE_REPEAT` (bounded step-advance hook для Stage E/F/G).
- `3108` — `AL_EVENT_BLOCKED_RESUME` (Stage I.0 local OnBlocked resume hook после door-first попытки).

Требования:
1. Внутренние сигналы только event-driven.
2. Entry scripts не содержат feature runtime.
3. `WARM/FREEZE` не исполняют route/transition progression.

---

## 4) LOD semantics

1. `FREEZE`
   - area спит;
   - нет route/transition progression.
2. `WARM`
   - поддержание readiness/caches;
   - без route/transition execution.
3. `HOT`
   - активный runtime Stage D/E/F/G/H/I.0.

---

## 5) Stage D/E/F/G execution contracts

## 5.1 Route cache (Stage D)
- cache area-scoped;
- сборка по route tag текущего slot;
- ordering строго по `al_step`;
- invalidation/rebuild только контролируемо.

## 5.2 Routine progression (Stage E)
- bounded multi-step внутри slot;
- queue-based semantics (`move -> activity -> repeat event`);
- без polling.

## 5.3 Transition progression (Stage F)
Transition step определяется waypoint-полями `al_trans_type`, `al_trans_src_wp`, `al_trans_dst_wp`.

Если step transition:
- runtime идёт в отдельный transition executor;
- выполняется `move-to-source -> jump-to-destination -> optional dwell -> repeat event`;
- ставится минимальный transition runtime marker на NPC.

Если step не transition:
- проверяется Stage G sleep special-case;
- если это не sleep step, остаётся обычный Stage E path.

## 5.4 Sleep progression (Stage G)
Sleep step определяется наличием `al_bed_id` на route waypoint.

Если step sleep:
- runtime резолвит canonical pair `<bed_id>_approach` и `<bed_id>_pose` в текущей area;
- выполняется `move-to-approach -> dock-to-pose -> sleep dwell -> repeat event`;
- ставится минимальный sleep runtime marker на NPC.

Fallback policy:
- missing/invalid `al_bed_id`;
- missing/invalid `<bed_id>_approach`;
- missing/invalid `<bed_id>_pose`.

Во всех случаях выше используется clean fallback `sleep on place`.

---

## 6) Caching / hot-path policy

- Нет repeated full-area scans в hot path.
- Нет repeated nearest/tag search как baseline route/transition/sleep strategy.
- Transition pair резолвится по явно заданным helper tag (authoring contract), а не через nearest fallback.
- Sleep pair резолвится по canonical tags `<bed_id>_approach` и `<bed_id>_pose`.
- Failure любого шага ведёт к clean fallback на `al_default_activity`.

---

## 7) Stage G boundary (explicit)

Stage G добавляет отдельную sleep subsystem:
- sleep pair `<bed_id>_approach -> <bed_id>_pose`;
- fallback sleep on place при невалидной конфигурации.

При этом Stage F transition subsystem сохраняется отдельно:
- area-to-area helper transition;
- intra-area teleport transition.

Stage G не включает:
- reactions/crime/alarm;
- linked-area traversal graph;
- `ActionInteractObject`-based sleep;
- `rest`/`OnRested`/`AnimActionRest`;
- heartbeat/timer-per-NPC/polling architectures.

Следующий этап: Stage I reactions (crime/alarm/disturb override).


## 8) Stage H activity boundary (explicit)

Stage H вводит отдельный activity execution layer:
- вход: `al_activity` на step + fallback через `al_default_activity`;
- исполнение: централизованный int-code -> behavior mapping;
- clean fallback: safe idle при отсутствии валидного ordinary activity code.

Source of truth для activity IDs/имен:
- canonical activity table из `lncaster-cell/PycukSystems` (`al_acts_inc.nss` / activity table).
- На Stage H используется только Ambient Life subset ordinary IDs; sleep-коды остаются Stage G special-case.

Границы:
- Ordinary activity: non-transition + non-sleep steps.
- Transition special-case: Stage F subsystem.
- Sleep special-case: Stage G subsystem.
- Reaction override: не здесь, переносится в Stage I.


## 8) Stage I.0 boundary (implemented, narrow)

- `OnBlocked` трактуется как локальный runtime helper, а не как общий reaction framework.
- First-line policy: попытка door/open через `GetBlockingDoor()` и `ActionOpenDoor(...)`, затем resume текущего route-step.
- Если local-unblock не удался: bounded fallback (одна локальная попытка resume), затем safe resync через `AL_EVENT_RESYNC`.
- Без heartbeat, без per-NPC periodic timers, без polling/retry-loop machine.
- `OnDisturbed` и crime/alarm сознательно отложены на следующие sub-stages.
