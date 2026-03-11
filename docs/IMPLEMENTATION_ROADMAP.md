# Ambient Life — Implementation Roadmap

## Stage A — Contracts and Architecture Canon (implemented)
- Зафиксированы архитектурные контракты и базовая модель runtime.

## Stage B — Core Runtime Backbone (implemented)
- Реализованы area/npc lifecycle обработчики (spawn/death/enter/exit/leave).
- Реализованы single area-level tick loop, dense registry и internal OnUserDefined bus.
- Slot dispatch работает как area-global orchestration backbone.

## Stage C — Area Graph + Simulation LOD Policy (implemented)
- Введён area linkage contract (`al_link_count` + `al_link_<idx>`).
- Введена 3-tier модель симуляции area: `FREEZE`, `WARM`, `HOT`.
- Реализована depth 0 / depth 1 interest policy с hysteresis.

## Stage D — Route Cache + Route Execution Baseline (implemented)
- Реализован area-scoped route cache.
- Route tag берётся из slot anchors (`alwp0..alwp5`).
- Waypoint ordering детерминирован через `al_step`.
- Runtime исполняется только в `HOT`.

## Stage E — Bounded Multi-step Routines (implemented)
- Реализованы bounded multi-step routines поверх Stage D cache foundation.
- Поддержан step-advance через `AL_EVENT_ROUTE_REPEAT`.
- Runtime остаётся HOT-only и без polling.

## Stage F — Transition Subsystem (implemented)
- Добавлена отдельная transition subsystem поверх Stage E, не смешанная с Stage D cache.
- Поддержаны два канонических механизма:
  - area-to-area helper transition (pair waypoint);
  - intra-area teleport transition (pair waypoint).
- Transition step интегрирован как special action в bounded routine progression.
- Добавлен минимальный transition runtime state (`al_trans_rt_active`, `al_trans_rt_type`, `al_trans_rt_dst`).

## Stage G — Sleep Runtime (next)
- Реализовать sleep pipeline `<bed_id>_approach -> <bed_id>_pose`.
- Поддержать fallback sleep on place при неполной конфигурации.

## Stage H — Blocked/Disturbed + Crime/Alarm Reactions (next)
- Реализовать реактивный слой и приоритеты реакций.
- Добавить debounce/cooldown для шумных событий.
