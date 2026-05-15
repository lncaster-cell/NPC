# 03_DAILY_LIFE_ARCHITECTURE

## Цель Daily Life

Daily Life должен создавать наблюдаемую иллюзию жизни NPC:

- NPC спит;
- ест;
- работает;
- перемещается между area;
- может быть off-screen;
- ведёт себя правдоподобно рядом с игроком.

Daily Life не должен симулировать весь мир постоянно.

## Базовая модель

```text
Role / Schedule / Route / Anchor / State
```

Не “личность каждого NPC прежде всего”, а:

```text
домовладение -> роль/должность -> NPC-носитель роли
```

NPC может умереть/смениться. Роль и место в городе остаются.

## Area-level LOD

### Area inactive

Если игрок не видит area:

- NPC может существовать только как logical state;
- не нужен pathfinding;
- не нужны анимации;
- не нужен heartbeat;
- можно хранить coarse state: где должен быть, какой слот дня, активен ли.

### Area active

Если игрок входит:

- area controller lazy-init cache;
- поднимает нужных NPC;
- расставляет по anchor;
- запускает короткую action queue;
- синхронизирует видимое состояние.

## Time buckets

Для v1 лучше грубые временные слоты:

```text
sleep
morning/eat
work
evening/eat/social
night
```

Или старый проверенный стиль:

```text
3-hour slots
```

Не нужно ежеминутное планирование каждого NPC, если этого не видит игрок.

## Routes

Маршрут должен быть route/anchor driven.

Предпочтительно:

```text
RouteID
  segment 1: current area anchor -> door/transition
  segment 2: receiving area entry anchor -> destination anchor
  segment 3: local behavior anchor
```

Не делать:

```text
каждый раз GetWaypointByTag("wp_" + route + "_" + step)
```

Делать:

```text
cold init:
  route tag -> object refs -> area/controller cache

runtime:
  route index -> cached object ref
```

## Movement

Предпочтительно:

- двигаться к object anchor;
- дробить дальние переходы на сегменты;
- переходы между area обрабатывать явно;
- off-screen travel симулировать телепортом/состоянием;
- не заставлять NPC физически идти через весь мир, если игрок этого не видит.

## Sleep

Сон считается рабочей подсистемой текущей версии.  
Не трогать без отдельной причины.

Общее правило остаётся:

```text
sleep approach anchor -> sleep point -> wake/exit anchor -> valid area path
```

## Animation

Анимации должны быть bounded.

Нельзя:

- спамить animation call;
- вызывать `PlayAnimation` вместо queued `ActionPlayAnimation`, если нужна очередь;
- запускать несколько одинаковых idle-анимаций подряд без cooldown/state guard.

Нужно:

- cooldown;
- current animation state;
- bounded random;
- one-shot per activity window;
- clear separation between activity state and cosmetic emote.

## Interrupt/resume

Runtime-state Daily Life должен использоваться для:

- orchestration;
- resync;
- interrupt/resume;
- dirty/fallback;
- recovery.

Runtime-state не должен заменять встроенную action queue движка.

## Minimal state machine

```text
DL_STATE_OFFSCREEN
DL_STATE_IDLE
DL_STATE_MOVING_TO_ACTIVITY
DL_STATE_ACTIVITY_RUNNING
DL_STATE_TRANSITIONING_AREA
DL_STATE_INTERRUPTED
DL_STATE_RECOVERING
```

## Recovery

Если cache stale или anchor invalid:

```text
mark area dirty
stop local action if necessary
resync via scheduler/controller
fallback to safe anchor only if needed
```

Не делать бесконечный retry-loop на NPC.

## Readiness checklist

Daily Life считается архитектурно здоровым, если:

- hot path не ищет объекты по тегам;
- NPC list кэширован на area/controller;
- route anchors кэшированы;
- off-screen area не гоняет AI;
- DB не дёргается на каждый step;
- heartbeat не является мозгом NPC;
- action queue используется штатно;
- есть bounded recovery;
- есть diagnostics/debug flags.
