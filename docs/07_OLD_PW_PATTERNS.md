# 07_OLD_PW_PATTERNS

## Цель

Зафиксировать старые проверенные паттерны NWN/NWN2 persistent worlds и living world modules, которые применимы к проекту.

## Главный вывод

Старые работающие системы почти никогда не строили полную симуляцию города.  
Они создавали дешёвые наблюдаемые следы жизни:

- расписания;
- scripted waypoints;
- off-screen teleport;
- локальные переменные;
- area activation;
- простая persistent DB;
- reputation counters;
- store capital;
- spawn memory;
- DM/admin tools.

## Scripted waypoints

NWN2 даёт штатный паттерн:

```text
WP_<creature_tag>_##
wp_<creature_tag>
GetCurrentWaypoint()
SetNextWaypoint()
controller/local refs
```

Использовать для:

- локальных патрулей;
- work/eat/sleep маршрутов;
- controlled waypoint logic;
- динамического выбора следующей точки.

Не использовать как единственную основу сложной FSM без project-level state.

## Ultima-style schedules

Полезный паттерн:

```text
3-hour slots
local vars on NPC
Tag_Time waypoints
on-screen walking
off-screen teleport
reduced AI for off-area NPC
```

Применение:

- city NPC routine;
- visible daily life;
- low-cost time buckets.

## NPC Activities / Puttering

Полезно как идея:

- дешёвое локальное idle-поведение;
- waypoint commands;
- один script pattern на много NPC.

Осторожно:

- большие data-driven системы могут стать слишком трудными для сопровождения.

## PRR-like reputation/law

Применимые идеи:

- NPC reactions;
- ownership/theft;
- security/crime;
- pickpocket;
- dynamic rumors;
- persistence;
- faction reaction.

Для нашего проекта лучше делать PRR-lite, не переносить огромный фреймворк целиком.

## Dynamic Merchant

Полезная модель экономики:

```text
store capital
2DA item lists
local vars
stock changes
merchant spends gold to restock
random off-screen sales
player trade affects capital
```

Это лучше для v1, чем полная item-level macroeconomy.

## SoZ trade pattern

Применимый принцип:

```text
limited resource set
trade nodes
price differences
bulk goods
routes
```

Использовать для городских ресурсов:

- food;
- consumer goods;
- raw resources;
- security;
- mood/prosperity.

## RCSS-style spawn

Полезный паттерн:

```text
spawn on player entering area
remember selected spawn composition until reset
despawn when area empty
remember killed/despawned count
restore plausible state next activation
```

Это прямо подходит для area-level LOD.

## ALFA/ACR lessons

Полезные уроки:

- жёсткие conventions;
- event handlers;
- local variables as builder data layer;
- coarse polling;
- cleanup inactive instanced areas;
- признавать дорогие системы и снижать frequency.

## PC Deputy pattern

Для law enforcement:

- не всё автоматизировать;
- логировать действия;
- дать DM/trusted PC инструменты;
- использовать non-lethal enforcement;
- автоматическая law-система + ручная власть лучше, чем “идеальный AI-суд”.

## Что можно брать прямо

- scripted waypoint/controller pattern;
- coarse daily time slots;
- off-screen teleport;
- area activation/deactivation;
- store capital;
- PRR-lite репутацию;
- crime log;
- simple faction counters;
- spawn memory;
- dynamic rumors через event log;
- DM/admin tools.

## Что не брать в v1

- полную микроэкономику каждого предмета;
- полноценный world AI orchestra;
- монолитные системы на сотни скриптов;
- дорогие background daemons;
- сложную distributed DB;
- постоянный simulation heartbeat.
