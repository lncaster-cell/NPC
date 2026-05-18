# 02_PERFORMANCE_AND_CACHING_RULES

## Главный закон производительности

```text
Дёшево читать уже найденный объект.
Дорого искать его снова.
```

Runtime-логика должна работать через local variables и cached object refs.  
Tag lookup, area scan и DB I/O — cold-path/maintenance-path операции.

## Hot path

Hot path — код, который может выполняться часто:

- heartbeat;
- perception;
- route step;
- animation step;
- transition handling;
- OnUsed / OnDamaged / OnDisturbed при массовом использовании;
- любой цикл по NPC.

## В hot path разрешено

- `GetLocalInt`;
- `GetLocalString`;
- `GetLocalObject`;
- умеренный `SetLocal*`;
- чтение area/controller dense registry;
- проверка `dirty`, `gen`, `active`, `resyncing`;
- `AssignCommand`;
- короткие action queue.

## В hot path запрещено

- `GetObjectByTag`;
- `GetWaypointByTag`;
- `GetNearestObjectByTag` как замена registry;
- `GetFirstObjectInArea` / `GetNextObjectInArea`;
- полные area scans;
- Campaign DB read/write;
- рекурсивный `DelayCommand`;
- cleanup/resync на transient NPC.

## Canonical dense registry

Канонический паттерн проекта:

```c
// area/controller locals
al_init
al_gen
al_dirty
al_active
al_resyncing

al_npc_count
al_npc_0001
al_npc_0002
...

al_route_count
al_route_0001
al_route_0002
...

al_wp_count
al_wp_0001
al_wp_0002
...
```

Тег — это bootstrap/resync key.  
Object ref — это runtime address.

## Где допустим tag lookup

Допустимо:

- cold init;
- area activation;
- dirty resync;
- admin command;
- audit;
- fallback после stale cache;
- migration/rebuild.

Недопустимо:

- каждый шаг маршрута;
- каждый heartbeat;
- каждый NPC в цикле;
- регулярная проверка “где мой waypoint”.

## Area scans

Полный обход area допустим только:

- при cold init;
- при rebuild registry;
- при редком audit;
- при maintenance;
- при admin resync.

Если нужен локальный поиск, предпочтительно:

- shape/radius query;
- type-filter;
- заранее известный controller;
- заранее известный anchor;
- area registry.

## Dirty/resync protocol

Любая частичная мутация registry должна выставлять dirty flag.

```text
spawn/death/transition/admin edit
  -> al_dirty = TRUE
  -> scheduler/rebuild at safe point
  -> al_gen++
  -> al_dirty = FALSE
```

Нельзя неделями держать tombstone-slots без compaction.

## DB rule

DB — durable storage, не runtime-cache.

DB подходит для:

- городских ресурсов;
- кланов;
- долговременной репутации;
- ownership;
- преступлений;
- role assignment;
- coarse NPC state;
- event log;
- save/load.

DB не подходит для:

- каждого route step;
- каждого animation tick;
- каждого perception;
- каждого heartbeat;
- current object refs;
- transient action state.

## Safe points для batch flush

- player logout;
- module scheduler tick;
- day/hour transition;
- admin save;
- controlled shutdown;
- area deactivation;
- завершение крупной операции, но не каждый её шаг.

## Минимальный audit checklist

Проверять в коде:

```text
1. GetObjectByTag в runtime?
2. GetWaypointByTag в route step?
3. GetFirstObjectInArea в heartbeat?
4. GetNearestObject в массовом цикле?
5. DB read/write внутри движения NPC?
6. DelayCommand-loop на NPC?
7. cleanup назначен на transient object?
8. есть ли dirty/gen/resyncing?
9. есть ли rebuild/compact registry?
10. есть ли early exit в scheduler?
```
