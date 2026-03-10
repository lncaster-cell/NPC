# Ambient Life — Toolset Contract (Stage A)

Документ фиксирует locals-контракт, который настраивается в toolset для Area/NPC/Waypoint.
На этом этапе задаются только имена и семантика, без runtime-реализации.

## 1) Area Locals

| Local | Type | Назначение |
|---|---|---|
| `AL_AREA_ENABLED` | int (0/1) | Глобальный флаг включения Ambient Life для зоны. |
| `AL_AREA_PROFILE` | string | Идентификатор профиля зоны (правила рутины/плотности). |
| `AL_AREA_ROUTE_SET` | string | Набор маршрутов, используемый route layer. |
| `AL_AREA_SLEEP_SET` | string | Набор sleep waypoints для зоны. |
| `AL_AREA_DEBUG` | int (0/1) | Локальный оверрайд debug-режима. |
| `AL_AREA_CACHE_VER` | int | Версия area cache (служебное поле ядра). |
| `AL_AREA_PLAYERS` | int | Текущее число игроков в зоне (служебное поле ядра). |
| `AL_AREA_NPC_COUNT` | int | Размер dense registry (служебное поле ядра). |

## 2) NPC Locals

| Local | Type | Назначение |
|---|---|---|
| `AL_NPC_ENABLED` | int (0/1) | Участвует ли NPC в Ambient Life. |
| `AL_NPC_SCHEDULE` | string | Идентификатор slot profile для NPC. |
| `AL_NPC_TIME_OFFSET` | int | Персональный временной offset NPC. |
| `AL_NPC_HOME_AREA` | string | Идентификатор домашней area/группы. |
| `AL_NPC_ROLE` | string | Роль NPC (merchant/guard/civilian/etc) для маршрутизации политик. |
| `AL_NPC_ACTIVITY_SET` | string | Набор activity routines. |
| `AL_NPC_SLEEP_SET` | string | Набор sleep routines (approach/pose chains). |
| `AL_NPC_SLOT_ACTIVE` | int | Текущий активный слот (служебно). |
| `AL_NPC_ROUTINE_STATE` | string | Текущая стадия routine (служебно). |
| `AL_NPC_CACHE_VER` | int | Версия npc cache (служебно). |
| `AL_NPC_REG_INDEX` | int | Индекс в dense area registry (служебно). |

## 3) Waypoint Locals

### 3.1 Общие

| Local | Type | Назначение |
|---|---|---|
| `AL_WP_KIND` | string | Тип waypoint: `activity`, `sleep_approach`, `sleep_pose`, `route_anchor`, `react`. |
| `AL_WP_SET` | string | Идентификатор набора (route/activity/sleep set). |
| `AL_WP_GROUP` | string | Подгруппа внутри набора. |
| `AL_WP_ORDER` | int | Порядок узла в цепочке/маршруте. |
| `AL_WP_AREA_PROFILE` | string | Ограничение по профилю зоны (опционально). |

### 3.2 Sleep-specific

| Local | Type | Назначение |
|---|---|---|
| `AL_SLEEP_NODE_TYPE` | string | `approach` или `pose`. |
| `AL_SLEEP_POSE` | string | Идентификатор позы/анимации сна. |
| `AL_SLEEP_NEXT` | string | Явный следующий node tag (опционально). |

## 4) Toolset Setup Rules

1. Для зоны достаточно `AL_AREA_ENABLED=1` + базовый profile/set.
2. NPC должен иметь минимум:
   - `AL_NPC_ENABLED=1`
   - `AL_NPC_SCHEDULE`
   - `AL_NPC_TIME_OFFSET` (может быть 0)
3. Сон настраивается только через waypoint chains `sleep_approach -> sleep_pose`.
4. Нельзя использовать `rest`/`OnRested` как часть Ambient Life contract.
5. Runtime locals (`*_CACHE_VER`, `*_REG_INDEX`, `*_SLOT_ACTIVE`) не редактируются вручную в toolset после запуска.

## 5) Backward/Forward Compatibility

- Новые locals добавляются только с префиксом `AL_`.
- Удаление/переименование существующих locals требует миграционного шага в roadmap.
- Неизвестные `AL_*` locals должны игнорироваться, если модуль их не поддерживает.
