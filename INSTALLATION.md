# Полная установка Ambient Life v2 (NWN2)

Документ для «чистой» установки с нуля: что импортировать, куда назначать скрипты, какие locals выставлять и как проверить, что система действительно запустилась.

> Важно: инструкция описывает только то, что есть в текущем проекте (Stages A–I.1), без дополнительных допущений.

## 0) Что это ставит

Ambient Life v2 — событийная симуляция NPC без heartbeat/polling на каждом NPC. Центральный цикл работает через area tick, а NPC получают сигналы через `OnUserDefined`.

## 1) Подготовка перед установкой

1. Откройте модуль NWN2 в Toolset.
2. Проверьте, что у вас есть доступ к:
   - событиям **Module**, **Area**, **NPC**;
   - locals у NPC/waypoint/area.
3. Определите, какие области и какие NPC должны работать через Ambient Life v2.

## 2) Импорт скриптов проекта

1. Импортируйте в модуль **все** `.nss` файлы из папки:
   - `scripts/ambient_life/`
2. Скомпилируйте импортированные скрипты.
3. Убедитесь, что после компиляции нет ошибок по include-файлам (`al_*_inc`).

## 3) Назначение entry scripts (обязательно)

Назначьте скрипты в событиях объектов **точно** как ниже.

### 3.1 Module
- `OnClientLeave` → `al_mod_onleave`

### 3.2 Area
- `OnEnter` → `al_area_onenter`
- `OnExit` → `al_area_onexit`
- `OnHeartbeat` (или отдельный area tick hook в вашем шаблоне) → `al_area_tick`

### 3.3 NPC
- `OnSpawn` → `al_npc_onspawn`
- `OnDeath` → `al_npc_ondeath`
- `OnUserDefined` → `al_npc_onud`
- `OnBlocked` → `al_npc_onblocked`
- `OnDisturbed` → `al_npc_ondisturbed`

## 4) Настройка locals на контенте

Ниже — полный список locals, которые используются системой.

## 4.1 NPC locals

### Обязательные
- `alwp0..alwp5` (string) — route tag для 6 слотов суток.
- `al_default_activity` (int) — дефолтная активность NPC.

### Опциональные (legacy)
- `AL_WP_S0..AL_WP_S5` (string) — старые алиасы route tags.

### Runtime-owned (НЕ редактировать вручную)
Система сама пишет/читает:
- `al_last_area`, `al_last_slot`
- `al_route_cache_*`, `al_route_rt_*`
- `al_trans_rt_*`
- `al_sleep_rt_*`
- `al_blocked_rt_active`, `al_blocked_rt_retry`
- `al_react_active`, `al_react_type`, `al_react_resume_flag`, `al_react_last_source`, `al_react_last_item`
- `al_mode`, `al_activity_current`

## 4.2 Waypoint locals

### Обычный шаг маршрута
- `al_step` (int, >=0)
- `al_activity` (int, optional)
- `al_dur_sec` (int, optional)

### Transition-step
- `al_trans_type`:
  - `1` — area helper
  - `2` — intra teleport
- `al_trans_src_wp` (string)
- `al_trans_dst_wp` (string)

### Sleep-step
- `al_bed_id` (string)
- ожидаемые waypoint-теги:
  - `{al_bed_id}_approach`
  - `{al_bed_id}_pose`

## 4.3 Area locals

### Опциональные контентные
- `al_link_count` (int)
- `al_link_0..N` (string)

### Runtime-owned (НЕ редактировать вручную)
- `al_player_count`, `al_sim_tier`, `al_slot`
- `al_tick_token`, `al_sync_tick`, `al_warm_until_sync`
- `al_npc_count`, `al_npc_<idx>`

## 5) Важные лимиты и параметры runtime

- `AL_AREA_TICK_SEC = 30.0`
- `AL_MAX_NPCS = 100` на одну area
- `AL_ROUTE_MAX_STEPS = 16`
- события event bus:
  - `AL_EVENT_SLOT_0..5 = 3100..3105`
  - `AL_EVENT_RESYNC = 3106`
  - `AL_EVENT_ROUTE_REPEAT = 3107`
  - `AL_EVENT_BLOCKED_RESUME = 3108`

## 6) Проверка после установки (smoke-check)

1. Зайдите игроком в область, где настроены NPC.
2. Проверьте, что у NPC стартует `RESYNC` и routine.
3. Переключите игровое время на следующий 4-часовой слот — маршрут должен смениться.
4. Проверьте `OnBlocked` (перекрытый проход/дверь) — ожидается bounded recovery и возврат.
5. Проверьте `OnDisturbed` (inventory/theft) — ожидается bounded override и возврат к routine.

## 7) Частые ошибки и как исправлять

- Не назначен `OnUserDefined` у NPC → core orchestration не работает.
- У waypoint нет `al_step` → шаг не попадёт в route cache.
- Route tag указывает на waypoint другой area → шаги будут отфильтрованы, возможен fallback.
- В area больше `AL_MAX_NPCS` (`100`) → часть NPC не зарегистрируется в runtime.
- В sleep-разметке нет `{bed}_approach` или `{bed}_pose` → будет fallback-поведение.

## 8) Очистка/обновление старых настроек (рекомендуется)

Чтобы не оставлять «мусор» после перехода на текущий контракт:

1. Оставьте только актуальные entry scripts из раздела 3.
2. Удалите/отключите старые обработчики, которые дублируют те же события и конфликтуют с Ambient Life.
3. Не пишите вручную значения в runtime-owned locals (раздел 4) — при необходимости очистите их и дайте системе заполнить заново.
4. Legacy-поля `AL_WP_S0..AL_WP_S5` держите только если они реально нужны старому контенту; для нового контента используйте `alwp0..alwp5`.

## 9) Минимальный чек-лист «с нуля до рабочего состояния»

- [ ] Импортированы и скомпилированы все `scripts/ambient_life/*.nss`
- [ ] Назначены entry scripts на Module/Area/NPC
- [ ] На NPC заполнены `alwp0..alwp5` и `al_default_activity`
- [ ] На waypoint проставлены `al_step` (+ опциональные `al_activity`, `al_dur_sec`)
- [ ] Для transition/sleep шагов заполнены спец locals и теги
- [ ] Не превышен лимит `100` NPC на area
- [ ] Пройден smoke-check из раздела 6
