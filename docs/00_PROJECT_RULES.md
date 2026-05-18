# 00_PROJECT_RULES

## Назначение

Этот документ фиксирует базовые правила проекта NWN2 / Ambient Live / Daily Life.  
Он должен читаться перед любыми изменениями runtime-логики, Daily Life, NPC-маршрутов, law-system, симулятора города, persistence и CI.

## Главный принцип

Проект не должен пытаться симулировать весь мир постоянно внутри NWN2.

Правильная модель:

```text
игрок видит область -> движок показывает короткую правдоподобную жизнь NPC
игрок не видит область -> состояние живёт как coarse data, а не как активный pathfinding AI
```

Цель — не абсолютная симуляция, а дешёвая, стабильная и управляемая иллюзия живого мира.

## Архитектурная формула

```text
Runtime NWN2:
  locals
  local object refs
  area/controller cache
  scripted/action queue
  event-driven callbacks
  thin scheduler

Durable world state:
  Campaign DB / SQLite / external DB
  city resources
  clans
  roles
  crimes
  ownership
  coarse snapshots
  event log

External simulator:
  periodic recalculation
  dashboard/table UI
  offline or safe-point sync
```

## Запрещённые направления без отдельного решения

Нельзя без явного архитектурного решения:

- вводить постоянный per-NPC heartbeat как основу поведения;
- делать глобальные area scans в runtime;
- искать NPC, waypoint, route, door, controller по тегам в hot path;
- писать или читать DB на каждом шаге маршрута;
- строить псевдо-heartbeat через рекурсивный `DelayCommand`;
- хранить object refs или raw campaign location как долговременную истину;
- ломать существующие маршруты, сон, переходы между area или registry ради локального фикса;
- добавлять новую подсистему, если можно расширить существующий механизм.

## Приоритеты проекта

1. Производительность.
2. Стабильность.
3. Ремонтопригодность.
4. Простота диагностики.
5. Иллюзия живого мира.
6. Глубина симуляции — только если она не ломает первые пять пунктов.

## Рабочий процесс

Любая крупная задача должна проходить так:

```text
1. Проверить актуальное состояние repo/branch/PR.
2. Прочитать docs.
3. Сформулировать маленькую задачу.
4. Запретить unrelated refactor.
5. Сделать минимальный diff.
6. Запустить compile/CI.
7. Отчитаться: файлы, причина, результат компиляции.
```

## Маленькие PR

Один PR должен делать одну вещь:

- один баг;
- один аудит;
- один документ;
- один performance fix;
- один новый слой архитектуры.

Не смешивать:

- bugfix + refactor;
- law system + Daily Life;
- compiler fixes + gameplay behavior;
- DB architecture + animation behavior.

## Состояние сна NPC

На момент фиксации этих правил сон в текущей версии считается отрегулированным и приемлемо работающим.  
Не считать sleep/pathfinding главным текущим блокером, если новое тестирование не покажет обратное.
