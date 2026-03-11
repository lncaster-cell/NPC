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

## Stage G — Sleep Runtime (implemented)
- Реализован отдельный Stage G sleep runtime subsystem поверх Stage E/F foundation.
- Поддержан канонический pipeline `<bed_id>_approach -> <bed_id>_pose`.
- Реализован fallback sleep on place при missing/invalid `al_bed_id` или неполной pair-конфигурации.
- Sleep runtime остаётся HOT-only, без heartbeat/polling/per-NPC timer архитектур.
- `ActionInteractObject` и `rest`/`OnRested`/`AnimActionRest` сознательно не используются.

## Stage H — Activity Subsystem / Canonical Activity Semantics (implemented)
- Выделена отдельная activity subsystem в `al_activity_inc.nss` (без ad-hoc логики в route/transition).
- Сохранён int-based контракт `al_activity`/`al_default_activity`.
- Canonical activity ID set синхронизирован с таблицей PycukSystems (см. ARCHITECTURE/TOOLSET_CONTRACT).
- Stage D/E/F/G интегрированы через общий execution layer `AL_ActivityApplyStep`.
- Sleep и transition сохранены как отдельные special-case подсистемы.

## Stage I.0 — OnBlocked Local Unblock / Door Handling (implemented)
- Добавлен отдельный узкий `OnBlocked` path как local navigation/runtime helper.
- Реализована door-first политика: `GetBlockingDoor()` + штатное `ActionOpenDoor(...)` + bounded resume текущего route шага.
- Если local-unblock не сработал: bounded fallback (single retry) и safe resync через `AL_EVENT_RESYNC`.
- Добавлен минимальный runtime state: `al_blocked_rt_active`, `al_blocked_rt_retry`.
- Границы: без giant reaction layer, без heartbeat/polling/per-NPC timers.

## Stage I.1 — OnDisturbed Reaction Layer (next)
- Отдельный слой реакции на disturbed events (вне `OnBlocked`).
- Дебаунс/кулдауны для шумных сигналов.

## Stage I.2 — Crime/Alarm Reactions (later)
- Отдельная интеграция crime/alarm без смешивания с локальным unblock path.
