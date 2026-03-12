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

`OnHeartbeat` **не используется как штатный периодический тик Ambient Life**.

Периодический runtime-цикл идёт только через внутренний scheduler (`AL_ScheduleAreaTick`) и запускается из lifecycle
(`OnEnter`/`OnExit` через `AL_AreaActivate`).

`al_area_tick` можно оставлять только как legacy safety hook (bootstrap), если в вашем шаблоне уже есть такое подключение:
он выполняет только активацию lifecycle и **не** должен быть единственным/основным источником периодического тика.

#### 2.2.1 Единый контракт подключения `al_area_tick` (entrypoint)

Ниже фиксируется единый контракт для типовых шаблонов модулей.

| Шаблон модуля | Что назначать в Toolset | Правило контракта |
|---|---|---|
| **A. Чистый lifecycle (рекомендуется)** | `OnEnter=al_area_onenter`, `OnExit=al_area_onexit`, `OnHeartbeat` пусто | Периодический тик идёт только через runtime scheduler (`AL_ScheduleAreaTick`). `al_area_tick` не подключается. |
| **B. Общий heartbeat-dispatcher (legacy shared chain)** | Оставить текущий heartbeat-скрипт шаблона, но внутри цепочки вызывать `al_area_tick` ровно один раз | `al_area_tick` используется только как bootstrap (`AL_AreaActivate`), без собственного цикла и без дублирования scheduler-тика. |
| **C. Прямой legacy heartbeat-hook** | `OnHeartbeat=al_area_tick` (только если шаблон уже исторически так устроен) | Допускается как safety bootstrap. Основной периодический цикл всё равно только через `AL_ScheduleAreaTick`. |

Запрещённый вариант для всех шаблонов: любой heartbeat-скрипт, который вручную эмулирует/дублирует периодический area-loop Ambient Life.

### 2.3 Таблица контракта hooks: `hook point → required script → expected locals/events`

| Hook point | Required script | Expected locals/events (после инициализации) |
|---|---|---|
| Module `OnClientLeave` | `al_mod_onleave` | Корректная деактивация/cleanup player-context для area lifecycle; без ручных правок runtime locals. |
| Area `OnEnter` | `al_area_onenter` | `AL_AreaActivate` запускает area lifecycle; появляются/обновляются area runtime locals (`al_tick_token`, `al_player_count`, `al_sim_tier`, `al_slot`). |
| Area `OnExit` | `al_area_onexit` | Пересчёт активности area и корректное продолжение/останов lifecycle по population policy. |
| Area `OnHeartbeat` (опционально, только legacy bootstrap) | `al_area_tick` или вызов `al_area_tick` из общего dispatcher | Допускается только bootstrap-entrypoint; не должен создавать второй периодический loop. |
| NPC `OnSpawn` | `al_npc_onspawn` | NPC регистрируется в area (`AL_RegisterNPC`), начинает runtime routine/resync workflow. |
| NPC `OnDeath` | `al_npc_ondeath` | NPC снимается с активного runtime-учёта area. |
| NPC `OnUserDefined` | `al_npc_onud` | Обрабатываются события шины `AL_EVENT_SLOT_0..5`, `AL_EVENT_RESYNC`, `AL_EVENT_ROUTE_REPEAT`, `AL_EVENT_BLOCKED_RESUME`. |
| NPC `OnBlocked` | `al_npc_onblocked` | bounded blocked-recovery без разрыва основного route-loop. |
| NPC `OnDisturbed` | `al_npc_ondisturbed` | bounded disturbed-reaction c возвратом в routine. |

### 2.4 NPC (Свойства NPC → Scripts)

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

### Что именно писать в `alwp0..alwp5` (конкретно)

В `alwpX` вписывается **Tag маршрута** — это **общий Tag группы waypoint**, которые образуют один маршрут.

**Коротко:**
- `alwp0 = <Tag маршрута>`
- `alwp1 = <Tag маршрута>`
- ...
- `alwp5 = <Tag маршрута>`

**Важно:** сюда вписывается **не имя отдельного шага**, а **общий Tag маршрута**.

Как система понимает маршрут:
1. Берёт значение `alwpX` у NPC.
2. Находит в этой же area **все waypoint с таким Tag**.
3. Сортирует их по `al_step` (`0,1,2,...`) и получает последовательность шагов маршрута.

То есть «маршрут» = несколько waypoint с одинаковым `Tag` + с разными `al_step` без пропусков.

Привязка `X` к времени суток (слоты по 4 часа):

| Local | Слот | Часы |
|---|---:|---|
| `alwp0` | 0 | 00:00–03:59 |
| `alwp1` | 1 | 04:00–07:59 |
| `alwp2` | 2 | 08:00–11:59 |
| `alwp3` | 3 | 12:00–15:59 |
| `alwp4` | 4 | 16:00–19:59 |
| `alwp5` | 5 | 20:00–23:59 |

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
- все waypoint одного маршрута должны иметь **одинаковый Tag** (ровно тот, что вы вписали в `alwpX` у NPC);
- `al_step` должен идти без дыр (например `0,1,2,3`);
- waypoint с другим Tag в этот маршрут не попадут.

Формула заполнения без двусмысленности:
- `alwp0 = <Tag маршрута из waypoint>`
- `alwp1 = <Tag маршрута из waypoint>`
- `alwp2 = <Tag маршрута из waypoint>`
- `alwp3 = <Tag маршрута из waypoint>`
- `alwp4 = <Tag маршрута из waypoint>`
- `alwp5 = <Tag маршрута из waypoint>`

Где брать `<Tag маршрута из waypoint>`:
1. Вы выбираете название маршрута (например `rt_market_day`).
2. Ставите этот же `Tag` у всех waypoint этого маршрута.
3. Выставляете им `al_step` как `0,1,2,...`.
4. Это же название (`rt_market_day`) вписываете в нужный `alwpX` у NPC.

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

### 6.1 Smoke-процедура: сигнатура корректной инициализации area

1. В Toolset/рантайме включите debug area: local `al_debug=1` (опционально, только для диагностики).
2. Зайдите игроком в target area и дождитесь **2–3 тиков** `AL_AreaTick`.
3. Зафиксируйте отличительный признак корректной инициализации:
   - в area locals присутствуют и обновляются `al_h_npc_count`, `al_h_tier`, `al_h_slot`;
   - `al_h_reg_overflow_count=0` и `al_h_route_overflow_count=0` для штатного контента;
   - в module log появляются записи `[AL][AreaHealthDelta]` (минимум одна запись при изменении метрик).
4. Если после 2–3 тиков health-метрики не появились/не меняются, считать подключение hooks некорректным и перепроверить раздел 2.

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
