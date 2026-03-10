# Ambient Life — Toolset Contract (Stage A + Stage C)

Stage A зафиксировал базовый контракт locals.
Stage C расширяет его cheap area-linkage и simulation tier policy (без route/runtime DSL).

## 1) NPC locals (canonical)

### 1.1 Toolset-configured

| Local | Type | Назначение |
|---|---|---|
| `alwp0` | string | Базовый waypoint/tag для слота 0. |
| `alwp1` | string | Базовый waypoint/tag для слота 1. |
| `alwp2` | string | Базовый waypoint/tag для слота 2. |
| `alwp3` | string | Базовый waypoint/tag для слота 3. |
| `alwp4` | string | Базовый waypoint/tag для слота 4. |
| `alwp5` | string | Базовый waypoint/tag для слота 5. |
| `al_slot_offset_min` | int | Персональный временной offset NPC в минутах. |
| `al_sleep_profile` | string | Идентификатор sleep-профиля NPC (для выбора bed/поведения сна). |
| `al_default_activity` | int | Activity ID (code) по умолчанию при отсутствии валидного route шага. |

### 1.2 Runtime-owned (не редактируются вручную)

| Local | Type | Назначение |
|---|---|---|
| `al_last_slot` | int | Последний обработанный слот NPC. |
| `al_last_area` | object/string | Последняя area, в которой NPC обработан системой. |
| `al_mode` | string | Текущий режим NPC (служебное состояние core/runtime). Stage B baseline: `"idle"` на spawn. |

---

## 2) Waypoint locals (canonical)

| Local | Type | Назначение |
|---|---|---|
| `al_step` | int | Порядковый номер шага в маршруте/рутине. |
| `al_activity` | int | Activity ID (code) для данного шага. |
| `al_dur_sec` | int | Желаемая длительность шага (секунды). |
| `al_bed_id` | string | Идентификатор кровати/точки сна для sleep pipeline. |

---

## 3) Sleep contract (canonical)

Sleep работает через waypoint-пару по `al_bed_id`:
- `<bed_id>_approach`
- `<bed_id>_pose`

Правила:
1. Базовый путь сна: `approach -> pose`.
2. Если валидная пара не найдена — fallback: sleep on place.
3. `ActionInteractObject` не используется как основа sleep runtime.

---

## 4) Area locals (canonical)

### 4.1 Toolset-configured

| Local | Type | Назначение |
|---|---|---|
| `al_link_count` | int | Количество прямых linked areas (depth 1 interest). |
| `al_link_<idx>` | string | Tag связанной area по индексу `0..al_link_count-1` (улица/интерьер/соседний район). |
| `al_area_kind` | string | Опциональная семантика area (`street`, `interior`, `district`, ...); используется для authoring/документации, не для сложной graph-логики. |
| `al_debug` | int (0/1) | Флаг диагностического режима для зоны. |

Stage C canonical linkage assumption: linked area резолвится runtime-слоем по area tag через object lookup (`GetObjectByTag`) с проверкой, что результат — объект area.
Если в конкретной сборке движка этот lookup окажется недостаточно надёжным для area object, механизм резолва может быть скорректирован на следующем техническом шаге **без изменения 3-tier LOD модели** и без изменения semantics `FREEZE/WARM/HOT`.

### 4.2 Runtime-owned

| Local | Type | Назначение |
|---|---|---|
| `al_player_count` | int | Количество игроков в зоне. |
| `al_tick_token` | int/string | Токен/маркер текущего tick-цикла area. |
| `al_slot` | int | Текущий глобальный slot зоны (обновляется только в `HOT`). |
| `al_sync_tick` | int | Служебный sync-счётчик area runtime. |
| `al_npc_count` | int | Размер dense registry для area. |
| `al_npc_<idx>` | object/string | Плотный индексный список NPC в area registry. |
| `al_sim_tier` | int | Текущий simulation tier area (`0=FREEZE`, `1=WARM`, `2=HOT`). |
| `al_warm_until_sync` | int | Hysteresis marker: до какого `al_sync_tick` area удерживается в `WARM` после потери игрока/соседнего interest. |

---

## 5) Stage C LOD policy contract

Используется только 3 tiers:
- `FREEZE`: area спит, runtime progression не идёт.
- `WARM`: area прогрета/быстро достижима, только лёгкая runtime maintenance без rich route execution.
- `HOT`: area с игроком, полный доступный runtime текущей стадии.

Depth model на Stage C:
1. Current player area => `HOT`.
2. Directly linked areas => `WARM`.
3. Всё остальное => `FREEZE`.

Ограничения Stage C:
- Нет deep BFS/path prediction.
- Нет recursive graph warming.
- Нет отдельной graph DSL.
- Нет route/sleep/reaction runtime в рамках LOD этапа.

---

## 6) Contract boundaries

- Контракт остаётся простым и дешёвым для контент-автора.
- Runtime-owned locals обновляются только runtime-слоем.
- Ввод linked areas делается через простые indexed locals, без сложных конфигурационных моделей.
