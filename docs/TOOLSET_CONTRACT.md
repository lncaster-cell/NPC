# Ambient Life — Toolset Contract (Stage A + C + D/E + F transitions + G sleep + H activity semantics + Stage I.0/I.1 reactions split)

Stage A зафиксировал базовый контракт locals.
Stage C добавил cheap area-linkage и simulation tier policy.
Stage D/E добавили area-scoped route cache и bounded routine.
Stage F добавляет отдельный transition subsystem (без смешивания с обычными route steps).
Stage G добавляет отдельный sleep runtime subsystem поверх Stage E/F.
Stage H добавляет отдельный canonical activity subsystem для ordinary шагов (int-code mapping).
Stage I.0 добавляет отдельный локальный `OnBlocked` runtime helper.
Stage I.1 добавляет отдельный bounded `OnDisturbed` inventory/theft foundation.

## 1) NPC locals (canonical)

### 1.1 Toolset-configured

| Local | Type | Назначение |
|---|---|---|
| `alwp0` | string | Базовый route tag для слота 0. |
| `alwp1` | string | Базовый route tag для слота 1. |
| `alwp2` | string | Базовый route tag для слота 2. |
| `alwp3` | string | Базовый route tag для слота 3. |
| `alwp4` | string | Базовый route tag для слота 4. |
| `alwp5` | string | Базовый route tag для слота 5. |
| `al_slot_offset_min` | int | Персональный временной offset NPC в минутах. |
| `al_sleep_profile` | string | Идентификатор sleep-профиля NPC (следующая стадия). |
| `al_default_activity` | int | Activity ID (code) по умолчанию при отсутствии валидного шага. |

### 1.2 Runtime-owned (не редактируются вручную)

| Local | Type | Назначение |
|---|---|---|
| `al_last_slot` | int | Последний обработанный слот NPC. |
| `al_last_area` | object/string | Последняя area, в которой NPC обработан системой. |
| `al_mode` | string | Текущий режим NPC (canonical activity name / `idle`). |
| `al_activity_current` | int | Stage H текущий ordinary activity code (для диагностики runtime). |
| `al_route_rt_active` | int (0/1) | Stage E marker активного bounded routine цикла. |
| `al_route_rt_idx` | int | Stage E текущий индекс шага в route cache. |
| `al_route_rt_left` | int | Stage E сколько шагов осталось в текущем bounded cycle. |
| `al_route_rt_cycle` | int | Stage E служебный счётчик запусков cycle. |
| `al_trans_rt_active` | int (0/1) | Stage F marker активного transition step. |
| `al_trans_rt_type` | int | Stage F тип перехода (`1=area helper`, `2=intra teleport`). |
| `al_trans_rt_dst` | object/string | Stage F destination helper waypoint текущего transition шага. |
| `al_sleep_rt_active` | int (0/1) | Stage G marker активного sleep шага. |
| `al_sleep_rt_bed_id` | string | Stage G текущий `bed_id` для сна (очищается на fallback sleep on place). |
| `al_sleep_rt_phase` | int | Stage G фаза (`0=none`, `1=place`, `2=approach`, `3=pose`). |
| `al_react_active` | int (0/1) | Stage I.1 marker активной bounded `OnDisturbed` реакции. |
| `al_react_type` | int | Stage I.1 тип disturbance (`1=added`, `2=removed`, `3=stolen`, `4=unknown`). |
| `al_react_resume_flag` | int (0/1) | Stage I.1 флаг необходимости resume ordinary route после локальной реакции. |
| `al_react_last_source` | object/string | Stage I.1 последний disturbance source (если валиден). |
| `al_react_last_item` | object/string | Stage I.1 последний disturbance item (если валиден). |
| `al_exit_counted` | int (0/1) | Runtime-флаг PC guard для дедупликации area exit/module leave декремента `al_player_count` (сбрасывается на входе в area). |

---

### 1.3 Canonical activity IDs (Stage H)

Source of truth: `lncaster-cell/PycukSystems` canonical activity list (`al_acts_inc.nss` + activity table).

Stage H реализует ordinary Ambient Life subset:
- `1 ActOne`
- `3 Dinner`
- `7 Agree`
- `8 Angry`
- `20 Read`
- `21 Sit`
- `23 StandChat`
- `28 Cheer`
- `39 KneelTalk`
- `43 Guard`

Sleep-коды (`4`, `5`, `31`, `32`) зарезервированы как Stage G special-case и не исполняются ordinary activity path.

## 2) Waypoint locals (canonical)

### 2.1 Обычный route step

| Local | Type | Назначение |
|---|---|---|
| `al_step` | int | Порядковый номер шага в маршруте/рутине. |
| `al_activity` | int | Activity ID (code) для шага. |
| `al_dur_sec` | int | Желаемая длительность шага (секунды). |

### 2.2 Transition step descriptor (Stage F)

Transition step остаётся waypoint в route chain, но обрабатывается отдельной transition-подсистемой.

| Local | Type | Назначение |
|---|---|---|
| `al_step` | int | Индекс шага в обычной route chain (как и для normal step). |
| `al_trans_type` | int | Тип перехода: `1` = area-to-area helper, `2` = intra-area teleport. |
| `al_trans_src_wp` | string | Tag source helper waypoint перехода. |
| `al_trans_dst_wp` | string | Tag destination helper waypoint перехода. |
| `al_activity` | int | Activity после завершения transition (optional; fallback на `al_default_activity`). |
| `al_dur_sec` | int | Dwell после transition (optional; bounded fallback применяется runtime). |

Граница контракта:
- Если у шага нет валидного `al_trans_type`, это обычный route step Stage D/E.
- Если `al_trans_type` валиден, это transition step и он исполняется только через Stage F subsystem.
- Transition step **не** разворачивается в обычный route execution path.

### 2.3 Sleep step descriptor (Stage G)

Sleep step остаётся waypoint в route chain и исполняется отдельной sleep-подсистемой.

| Local | Type | Назначение |
|---|---|---|
| `al_step` | int | Индекс шага в обычной route chain (как и для других step). |
| `al_bed_id` | string | Идентификатор кровати; runtime резолвит `<bed_id>_approach` и `<bed_id>_pose`. |
| `al_dur_sec` | int | Время sleep dwell (optional; bounded fallback применяется runtime). |

Граница контракта:
- Если у шага задан `al_bed_id`, он исполняется через Stage G sleep subsystem.
- При невалидном/missing `al_bed_id` или missing pair waypoint применяется fallback sleep on place.
- Sleep step не использует `ActionInteractObject` и `rest`/`OnRested`/`AnimActionRest`.

### 2.4 Helper waypoint authoring

Для обоих механизмов автор задаёт ровно пару helper waypoint в toolset и указывает их теги в `al_trans_src_wp`/`al_trans_dst_wp` на transition step.

- Area-to-area helper transition: source и destination обязаны быть в разных area.
- Intra-area teleport transition: source и destination обязаны быть в одной area.

Пара helper waypoint может переиспользоваться многими NPC и многими route step, если теги совпадают.

---

## 3) Area locals (canonical)

### 3.1 Toolset-configured

| Local | Type | Назначение |
|---|---|---|
| `al_link_count` | int | Количество прямых linked areas (depth 1 interest). |
| `al_link_<idx>` | string | Tag связанной area по индексу `0..al_link_count-1`. |
| `al_area_kind` | string | Опциональная семантика area (`street`, `interior`, `district`, ...). |
| `al_debug` | int (0/1) | Флаг диагностического режима для зоны. |

### 3.2 Runtime-owned

| Local | Type | Назначение |
|---|---|---|
| `al_player_count` | int | Количество игроков в зоне. |
| `al_tick_token` | int/string | Токен/маркер текущего tick-цикла area. |
| `al_slot` | int | Текущий глобальный slot зоны (обновляется только в `HOT`). |
| `al_sync_tick` | int | Служебный sync-счётчик area runtime. |
| `al_npc_count` | int | Размер dense registry для area. |
| `al_npc_<idx>` | object/string | Плотный индексный список NPC в area registry. |
| `al_sim_tier` | int | Текущий simulation tier area (`0=FREEZE`, `1=WARM`, `2=HOT`). |
| `al_warm_until_sync` | int | Hysteresis marker для удержания `WARM`. |

---

## 4) LOD policy boundary

Используются только 3 tiers:
- `FREEZE`: area спит, runtime progression не идёт.
- `WARM`: area прогрета/быстро достижима, только лёгкая maintenance без route execution.
- `HOT`: area с игроком, Stage D/E/F runtime.

Ограничения:
- Нет NPC heartbeat.
- Нет per-NPC periodic timers.
- Нет polling arrival tracking.
- Нет baseline repeated nearest/tag search.
- Для sleep pair резолвятся строго canonical waypoint tags `<bed_id>_approach` и `<bed_id>_pose` (без nearest fallback loops).

---

## 5) Boundaries и deferred scope

- Stage F добавляет только transition subsystem (area helper + intra teleport).
- Stage D/E area-scoped route cache остаётся отдельным foundation слоем.
- Stage I.0 `OnBlocked` и Stage I.1 `OnDisturbed` остаются раздельными подсистемами.
- Stage I.1 покрывает только inventory/theft disturbance foundation (added/removed/stolen).
- `GetInventoryDisturbItem()`/disturb context могут быть неполными в creature theft edge-cases; runtime обязан использовать bounded fallback.
- Crime/alarm не входят в текущий этап и переносятся в следующий PR/Stage I.2.
