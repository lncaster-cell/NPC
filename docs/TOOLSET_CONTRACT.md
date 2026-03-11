# Ambient Life — Toolset Contract (Stage A + C + D/E + F transitions)

Stage A зафиксировал базовый контракт locals.
Stage C добавил cheap area-linkage и simulation tier policy.
Stage D/E добавили area-scoped route cache и bounded routine.
Stage F добавляет отдельный transition subsystem (без смешивания с обычными route steps).

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
| `al_mode` | string | Текущий режим NPC (Stage B baseline: `"idle"`). |
| `al_route_rt_active` | int (0/1) | Stage E marker активного bounded routine цикла. |
| `al_route_rt_idx` | int | Stage E текущий индекс шага в route cache. |
| `al_route_rt_left` | int | Stage E сколько шагов осталось в текущем bounded cycle. |
| `al_route_rt_cycle` | int | Stage E служебный счётчик запусков cycle. |
| `al_trans_rt_active` | int (0/1) | Stage F marker активного transition step. |
| `al_trans_rt_type` | int | Stage F тип перехода (`1=area helper`, `2=intra teleport`). |
| `al_trans_rt_dst` | object/string | Stage F destination helper waypoint текущего transition шага. |

---

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

### 2.3 Helper waypoint authoring

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

---

## 5) Boundaries и deferred scope

- Stage F добавляет только transition subsystem (area helper + intra teleport).
- Stage D/E area-scoped route cache остаётся отдельным foundation слоем.
- Sleep runtime (`al_bed_id`) и reactions/crime/alarm не входят в текущий этап.
