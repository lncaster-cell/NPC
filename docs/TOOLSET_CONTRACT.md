# Ambient Life — Toolset Contract (Stage A)

Stage A фиксирует **только контракт данных и именование locals**, без runtime-логики.
Ниже приведён канонический минимум, согласованный для toolset/runtime.

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
| `al_mode` | string/int | Текущий режим NPC (служебное состояние core/runtime). |

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

| Local | Type | Назначение |
|---|---|---|
| `al_player_count` | int | Количество игроков в зоне. |
| `al_tick_token` | int/string | Токен/маркер текущего tick-цикла area. |
| `al_slot` | int | Текущий глобальный slot зоны. |
| `al_sync_tick` | int | Служебный sync-счётчик тика. |
| `al_npc_count` | int | Размер dense registry для area. |
| `al_npc_<idx>` | object/string | Плотный индексный список NPC в area registry. |
| `al_debug` | int (0/1) | Флаг диагностического режима для зоны. |

---

## 5) Stage A boundaries

- Контракт фиксируется как есть, без введения новых naming systems.
- Любые runtime-owned locals обновляются только runtime-слоем.
- Новые поля/переименования не вводятся на этапе A.
