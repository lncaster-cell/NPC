# 10_MASTER_SUMMARY

## Короткий итог исследований

Загруженные исследования сходятся в одном выводе:

```text
Не строить полный living world внутри NWN2.
Строить управляемую иллюзию жизни через events, locals, area cache, authored anchors,
coarse schedules и внешний durable state.
```

## Архитектура проекта

```text
NWN2 runtime:
  area/controller local state
  dense registries
  action queue
  event callbacks
  short visible behaviors
  thin scheduler

Durable state:
  DB / SQLite / Campaign DB
  city resources
  clans
  roles
  crimes
  ownership
  reputation
  snapshots

External simulator:
  periodic recalculation
  dashboard/table management
  event log
  projections for game
```

## Самые важные правила

1. Runtime uses locals/cache.
2. Tags are bootstrap keys.
3. DB is durable state.
4. Heartbeat is scheduler.
5. DelayCommand is not pseudo-heartbeat.
6. Daily Life is visible illusion, not full simulation.
7. Law system is event-driven.
8. Compiler compatibility must stay stock-NWN2-safe.
9. Codex tasks must be small.
10. Every architectural decision goes into `09_DECISIONS.md`.

## Следующие практические задачи

### Task 1 — add docs only

```text
Add the docs package to the repository.
Do not edit scripts.
Do not change CI.
Do not refactor code.
```

### Task 2 — audit hot-path violations

```text
Audit Daily Life scripts for hot-path lookup/scan/DB/DelayCommand violations.
Do not edit code.
Return table: file/function/operation/path type/risk/recommendation.
```

### Task 3 — audit compiler risk

```text
Audit include graph, prototypes, const declarations, shadowing, duplicate include basenames.
Do not edit code.
Return minimal compatibility risk list.
```

### Task 4 — audit law-system readiness

```text
Map current module events/triggers/creature events to future law-system hooks.
Do not implement law system yet.
Return design gaps only.
```

### Task 5 — project index

```text
Create docs/PROJECT_INDEX.md listing core systems, scripts, includes and event entry points.
Do not edit scripts.
```

## Practical status

The current architecture direction is approved:

```text
area-level cache
roles over identities
event-driven law
external coarse simulator
minimal runtime overhead
```

The next work should be audit and documentation, not broad refactor.
