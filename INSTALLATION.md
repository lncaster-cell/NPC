# Полная установка Ambient Life v2 (NWN2)

Инструкция для установки «с нуля» без погружения в код.

## 1) Что импортировать

1. В NWN2 Toolset откройте ваш модуль.
2. Импортируйте **все** `.nss` из `scripts/ambient_life/`.
3. Скомпилируйте все импортированные скрипты.

---

## 2) Точное назначение скриптов (что куда ставить)

Назначения делаются в свойствах соответствующего объекта в Toolset, вкладка **Scripts**.

### 2.1 Module (Свойства модуля → Scripts)

| Событие | Скрипт |
|---|---|
| `OnClientLeave` | `al_mod_onleave` |

### 2.2 Area (Свойства area → Scripts)

| Событие | Скрипт |
|---|---|
| `OnEnter` | `al_area_onenter` |
| `OnExit` | `al_area_onexit` |
| `OnHeartbeat` | `al_area_tick` |

> Если в вашем шаблоне area tick подключается отдельным hook-механизмом, `al_area_tick` должен быть вызван этим механизмом.

### 2.3 NPC (Свойства NPC → Scripts)

| Событие | Скрипт |
|---|---|
| `OnSpawn` | `al_npc_onspawn` |
| `OnDeath` | `al_npc_ondeath` |
| `OnUserDefined` | `al_npc_onud` |
| `OnBlocked` | `al_npc_onblocked` |
| `OnDisturbed` | `al_npc_ondisturbed` |

---

## 3) Какие переменные прописываются вручную и где

Ниже только ручные (контентные) переменные. Всё, что не перечислено как ручное, руками не трогать.

## 3.1 NPC (вручную)

Где задавать: **Свойства NPC → Variables/Locals**.

### Обязательные
- `alwp0` (string)
- `alwp1` (string)
- `alwp2` (string)
- `alwp3` (string)
- `alwp4` (string)
- `alwp5` (string)
- `al_default_activity` (int)

### Что именно писать в `alwp0..alwp5`

`alwpX` — это **тег маршрута** (route tag). Система ищет в текущей area все waypoint с этим тегом, сортирует их по `al_step` и строит маршрут.

Привязка `X` к времени суток (слоты по 4 часа):

| Local | Слот | Часы |
|---|---:|---|
| `alwp0` | 0 | 00:00–03:59 |
| `alwp1` | 1 | 04:00–07:59 |
| `alwp2` | 2 | 08:00–11:59 |
| `alwp3` | 3 | 12:00–15:59 |
| `alwp4` | 4 | 16:00–19:59 |
| `alwp5` | 5 | 20:00–23:59 |

Пример заполнения для одного NPC:
- `alwp0 = rt_inn_sleep`
- `alwp1 = rt_inn_morning`
- `alwp2 = rt_market_day`
- `alwp3 = rt_market_day`
- `alwp4 = rt_tavern_evening`
- `alwp5 = rt_inn_sleep`

Это значит:
- ночью NPC ходит по маршруту с тегом `rt_inn_sleep`,
- утром — по `rt_inn_morning`,
- днём — по `rt_market_day`,
- вечером — по `rt_tavern_evening`.

### Что писать в `al_default_activity`

Это числовой ID активности на случай fallback/дефолтного поведения.

Часто используемые значения:
- `0` — `AL_ACT_NPC_HIDDEN`
- `20` — `AL_ACT_NPC_READ`
- `21` — `AL_ACT_NPC_SIT`
- `23` — `AL_ACT_NPC_STAND_CHAT`
- `43` — `AL_ACT_NPC_GUARD`

Если не знаете, что выбрать, ставьте безопасный базовый вариант:
- `al_default_activity = 23` (stand/chat).

> Полный список ID находится в `scripts/ambient_life/al_acts_inc.nss`.

### Опционально (только для legacy-контента)
- `AL_WP_S0..AL_WP_S5` (string)

## 3.2 Waypoint (вручную)

Где задавать: **Свойства Waypoint → Variables/Locals**.

### Для обычных шагов маршрута
- `al_step` (int, `>= 0`) — обязателен для шага маршрута.
- `al_activity` (int) — опционально.
- `al_dur_sec` (int) — опционально.

Важно для маршрута:
- все waypoint одного маршрута должны иметь **одинаковый Tag** (тот, что вы указали в `alwpX` у NPC);
- `al_step` должен идти без дыр (например `0,1,2,3`).

Пример для `alwp2 = rt_market_day`:
- Waypoint A: `Tag=rt_market_day`, `al_step=0`
- Waypoint B: `Tag=rt_market_day`, `al_step=1`
- Waypoint C: `Tag=rt_market_day`, `al_step=2`

### Для transition-step
- `al_trans_type` (int):
  - `1` — area helper
  - `2` — intra teleport
- `al_trans_src_wp` (string)
- `al_trans_dst_wp` (string)

### Для sleep-step
- `al_bed_id` (string)
- Также должны существовать waypoint-теги:
  - `{al_bed_id}_approach`
  - `{al_bed_id}_pose`

## 3.3 Area (вручную, опционально)

Где задавать: **Свойства Area → Variables/Locals**.

- `al_link_count` (int)
- `al_link_0..N` (string)

---

## 4) Что НЕ прописывается вручную

Эти locals принадлежат runtime и заполняются системой автоматически.

### NPC runtime locals (не трогать)
- `al_last_area`, `al_last_slot`
- `al_route_cache_*`, `al_route_rt_*`
- `al_trans_rt_*`
- `al_sleep_rt_*`
- `al_blocked_rt_active`, `al_blocked_rt_retry`
- `al_react_active`, `al_react_type`, `al_react_resume_flag`, `al_react_last_source`, `al_react_last_item`
- `al_mode`, `al_activity_current`

### Area runtime locals (не трогать)
- `al_player_count`, `al_sim_tier`, `al_slot`
- `al_tick_token`, `al_sync_tick`, `al_warm_until_sync`
- `al_npc_count`, `al_npc_<idx>`

---

## 5) Лимиты системы

- `AL_AREA_TICK_SEC = 30.0`
- `AL_MAX_NPCS = 100` на одну area
- `AL_ROUTE_MAX_STEPS = 16`

События шины:
- `AL_EVENT_SLOT_0..5 = 3100..3105`
- `AL_EVENT_RESYNC = 3106`
- `AL_EVENT_ROUTE_REPEAT = 3107`
- `AL_EVENT_BLOCKED_RESUME = 3108`

---

## 6) Проверка после установки

1. Зайдите игроком в area с настроенными NPC.
2. Убедитесь, что у NPC запускается `RESYNC` и routine.
3. Переключите игровое время на следующий 4-часовой слот — должен смениться маршрут.
4. Проверьте `OnBlocked` (закрытый проход/дверь) — должен отработать bounded recovery.
5. Проверьте `OnDisturbed` (inventory/theft) — должен сработать bounded override с возвратом к routine.

---

## 7) Что убрать как устаревшее/лишнее

1. Удалите или отключите старые обработчики событий, если они дублируют те же события Module/Area/NPC.
2. Не оставляйте ручную запись в runtime locals (раздел 4).
3. Для нового контента используйте `alwp0..alwp5`; legacy `AL_WP_S0..AL_WP_S5` держите только если без них нельзя.

---

## 8) Короткий чек-лист

- [ ] Импортированы и скомпилированы все `scripts/ambient_life/*.nss`
- [ ] Скрипты назначены в Module/Area/NPC **точно по таблицам из раздела 2**
- [ ] У каждого NPC заполнены `alwp0..alwp5` и `al_default_activity`
- [ ] Для каждого route tag созданы waypoint с одинаковым Tag и `al_step` без дыр
- [ ] Ручные locals заполнены в нужных объектах (NPC/Waypoint/Area) по разделу 3
- [ ] Runtime locals вручную не заполняются
- [ ] Пройдена проверка из раздела 6
