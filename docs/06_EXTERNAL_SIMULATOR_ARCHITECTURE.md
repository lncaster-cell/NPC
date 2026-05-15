# 06_EXTERNAL_SIMULATOR_ARCHITECTURE

## Цель

Внешний world simulator должен быть отдельным инструментом управления миром, а не заменой runtime-логики NWN2.

Он хранит и пересчитывает:

- города;
- ресурсы;
- население;
- роли;
- кланы;
- торговлю;
- преступления;
- репутацию;
- ownership;
- события.

NWN2 получает только готовое coarse state и пишет важные события.

## Главный принцип

```text
Игра не симулирует весь мир.
Игра читает подготовленное состояние и пишет coarse-grained события.
Симулятор периодически пересчитывает мир вне hot path.
```

## Рекомендуемый v1

Для одного разработчика:

```text
NWN2 server
+ NWNX4 if available
+ xp_sqlite
+ one local SQLite DB
+ external simulator as CLI/desktop process
+ DB Browser for SQLite or Datasette dashboard
```

Если NWNX недоступен, можно начать с Campaign DB / file export / manual sync, но архитектурно держать модель state + event_log.

## Почему SQLite v1

Плюсы:

- один файл;
- нет отдельного сервера;
- простые бэкапы;
- простая отладка;
- можно открыть через GUI;
- достаточно для одного разработчика/одного сервера.

Ограничения:

- частые параллельные записи;
- live remote dashboard;
- несколько редакторов одновременно;
- высокая write concurrency.

Когда SQLite станет тесен — следующий шаг MySQL/MariaDB, не сразу микросервисы.

## Что слишком сложно для v1

- полноценный REST/RPC bridge;
- постоянно живущий control-plane daemon;
- gRPC/Protocol Buffers;
- кастомная web-панель с нуля;
- чистый event sourcing без state tables;
- distributed services;
- “панель как у хостинга”.

## Data model v1

Минимальные таблицы:

```text
city
city_resource
city_daily_snapshot
clan
clan_relation
role
role_assignment
npc_logical
property
crime_event
reputation
world_event
outbox_to_game
inbox_from_game
migration_version
```

## State + event log

Использовать гибрид:

```text
current state tables
+ event_log
+ outbox/inbox
```

Не строить весь мир только через replay events.

## Sync direction

### Game -> Simulator

Игра пишет:

- преступление совершено;
- NPC умер;
- игрок продал большую партию еды;
- роль освободилась;
- город захвачен;
- игрок купил property;
- merchant stock changed;
- quest/world event happened.

### Simulator -> Game

Симулятор пишет:

- city resource levels;
- price tiers;
- active shortages;
- guard/security level;
- role assignments;
- merchant availability;
- clan relations;
- bounty/crime status;
- spawn pressure;
- world news/rumors.

## Частота синхронизации

Не каждый шаг NPC.

Подходящие интервалы:

- час мира;
- день мира;
- safe-point;
- server start;
- server shutdown;
- admin sync;
- player login/logout;
- area activation для relevant summary.

## NWN2 runtime boundary

NWN2 runtime не должен ждать внешний симулятор в hot path.

Правило:

```text
If simulator unavailable:
  use last known projection
  mark sync stale
  continue gameplay
```

## MVP external simulator

v1 может быть очень простым:

```text
python simulate_world.py --db world.db --advance-hours 1
```

Dashboard v1:

```text
DB Browser for SQLite
```

Позже:

```text
Datasette read-only web dashboard
```

Ещё позже:

```text
custom editor for cities/clans/roles
```

## Anti-patterns

- NWN2 вызывает внешний API на каждый route step;
- внешний сервис решает каждую idle-анимацию NPC;
- игра блокируется, если dashboard не запущен;
- JSON-файлы используются как главная БД без транзакций;
- world sim требует постоянного онлайн-сервиса;
- слишком ранняя web-админка.
