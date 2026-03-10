# Ambient Life — Architecture Canon (Stage A)

## 1) Цель этапа
На этапе A фиксируется **архитектурный канон и контракт**, без реализации runtime-поведения.

Ограничения ядра:
- Event-driven orchestration.
- Area-level tick выполняется только если в зоне есть игроки.
- Никаких NPC heartbeat.
- Dense registry на уровне area.
- `OnUserDefined` используется как внутренняя шина событий.
- Временная модель — слотная, слоты назначаются на NPC.
- Поддерживается персональный временной offset для каждого NPC.
- Агрессивное кэширование, без повторных сканирований area в hot path.
- Сон строится через `approach/pose` waypoints.
- `rest` / `OnRested` не входит в core.

---

## 2) Слои системы

### 2.1 Entry Layer
Скрипты входа, привязанные к движковым событиям:
- `al_area_onenter`
- `al_area_onexit`
- `al_area_tick`
- `al_mod_onleave`
- `al_npc_onspawn`
- `al_npc_ondeath`
- `al_npc_onud`

Задача entry-слоя: минимальная маршрутизация в core/event APIs без бизнес-логики.

### 2.2 Event Layer
`al_events_inc` определяет namespace внутренних сообщений и упаковку payload для `OnUserDefined`.

Задача слоя:
- нормализовать событие (источник, тип, контекст);
- гарантировать единый формат transport-а для core/feature модулей.

### 2.3 Core Orchestrator Layer
`al_core_inc` — центральная координация жизненного цикла area/NPC, но без hardcoded feature runtime на этапе A.

Задача слоя:
- принимать entry-события;
- перенаправлять в registry/schedule/route/activity/reaction модули по контракту;
- удерживать единые точки синхронизации.

### 2.4 Data/Registry Layer
`al_area_inc` + `al_registry_inc`.

Задача слоя:
- хранить dense-реестр активных NPC на area;
- вести runtime-счётчики area (players, active_npc_count, cache_version);
- обеспечивать O(1)/амортизированный доступ к активным сущностям без повторного полного обхода объектов.

### 2.5 Feature Layers
- `al_schedule_inc` — слотное время и переходы между slot state.
- `al_route_inc` — кэш путей/маршрутов и lookup маршрутов.
- `al_activity_inc` — activity intents/routines.
- `al_sleep_inc` — sleep intents через approach/pose waypoints.
- `al_react_inc` — реактивные ответы на события мира.
- `al_debug_inc` — диагностика/трассировка.

---

## 3) Event Namespace (internal bus)

Транспорт: `OnUserDefined`.

Рекомендуемый namespace:
- `AL_EVT_AREA_*` — area lifecycle (`ENTER`, `EXIT`, `TICK`).
- `AL_EVT_NPC_*` — npc lifecycle (`SPAWN`, `DEATH`, `DESPAWN`).
- `AL_EVT_SCHED_*` — события планировщика (`SLOT_DUE`, `SLOT_CHANGED`).
- `AL_EVT_ROUTE_*` — route/cache (`INVALIDATE`, `READY`, `FAILED`).
- `AL_EVT_ACTIVITY_*` — start/advance/complete routine.
- `AL_EVT_SLEEP_*` — sleep pipeline (`APPROACH`, `POSE`, `WAKE`).
- `AL_EVT_REACT_*` — реакции (`NOISE`, `CRIME`, `ALARM`, etc.).
- `AL_EVT_DEBUG_*` — отладочные события.

Правила:
1. Все внутренние сигналы Ambient Life должны идти через этот namespace.
2. Публичные точки входа конвертируются в AL-события как можно раньше (entry layer).
3. Из feature-модулей не допускается прямой вызов entry-скриптов.

---

## 4) Tick Model и Time Slots

1. Есть ровно один area tick loop на зону.
2. Tick активен только когда `area_player_count > 0`.
3. NPC не имеют heartbeat-логики.
4. Каждый NPC имеет:
   - profile слотов времени (`slot_0..slot_n`);
   - персональный `time_offset` (минуты/доли слота по контракту);
   - состояние текущего активного слота.
5. Вычисление due slot делается по `world_time + npc_offset`.

---

## 5) Caching Policy (каноничная)

### 5.1 Общие правила
- Hot path не делает повторных full-scan области.
- Любой lookup сперва использует кэш/реестр, затем fallback.
- Каждый кэш имеет версию (`cache_version`) и причину invalidation.

### 5.2 Area Cache
Содержит:
- dense список активных NPC id/tag/object refs;
- число игроков в area;
- route-cache index для area.

Обновляется только событиями:
- NPC spawn/death/leave;
- player enter/exit;
- явная invalidation команда.

### 5.3 NPC Cache
Содержит:
- slot profile id;
- personal time offset;
- текущая стадия routine;
- ссылки на назначенные waypoint chains (activity/sleep).

Обновляется только при:
- смене слота;
- смене routine/activity;
- reset/respawn NPC;
- внешней forced invalidation.

### 5.4 Route Cache
Содержит:
- предразрешённые route descriptors (не pathfinding runtime на этапе A);
- fallback target list по типу активности;
- timestamp/version.

### 5.5 Invalidation-first fallback
Если кэш устарел/битый:
1. Отметить invalid.
2. Попробовать rebuild через registry/toolset metadata.
3. Если rebuild невозможен — graceful degrade (noop/idle marker), без аварийного сканирования на каждом тике.

---

## 6) Fallback Policy

При отсутствии данных/waypoint/слота:
1. Никаких hard fail/crash.
2. NPC переводится в безопасное idle-состояние и помечается debug-флагом.
3. Система ставит событие диагностики (`AL_EVT_DEBUG_*`) для последующего анализа.
4. Повторные попытки ограничиваются cooldown/следующим slot boundary, чтобы не создать hot loop.

---

## 7) Non-goals этапа A
- Нет исполнения реальных рутин.
- Нет runtime pathfinding orchestration.
- Нет имплементации crime/alarm (только архитектурный резерв в namespace/roadmap).
