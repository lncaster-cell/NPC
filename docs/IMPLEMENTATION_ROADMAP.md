# Ambient Life — Implementation Roadmap

## Stage A — Contracts + Skeleton (implemented)
- Зафиксировать канонические locals contracts (Area/NPC/Waypoint).
- Зафиксировать архитектурные принципы (event-driven, dense registry, slot model, caching policy).
- Подготовить skeleton include/entry scripts без runtime logic.

## Stage B — Core Lifecycle (implemented)
- Подключены entry scripts к core dispatcher.
- Реализованы area/npc lifecycle обработчики (spawn/death/enter/exit/leave).
- Реализованы single area-level tick loop, dense registry и internal OnUserDefined bus.
- Slot dispatch работает как area-global orchestration backbone (per-NPC offset-aware dispatch отложен на следующие стадии).

## Stage C — Area Graph + Simulation LOD Policy (implemented)
- Введён area linkage contract (`al_link_count`, `al_link_<idx>`) для прямых связей street/interior/adjacent.
- Введена 3-tier модель симуляции area: `FREEZE`, `WARM`, `HOT`.
- Реализована depth 0 / depth 1 interest policy:
  - current player area => `HOT`;
  - directly linked areas => `WARM`;
  - остальные => `FREEZE`.
- Добавлен minimal grace/hysteresis (`al_warm_until_sync`), чтобы area не дёргалась на мгновенных переходах через двери/границы.
- Stage B tick backbone расширен так, чтобы полноценно тиковал только `HOT`, а `WARM` оставался лёгким runtime-maintenance tier без route execution.

## Stage D — Route Cache + Route Execution Baseline (implemented)
- Реализован route cache в `al_route_inc.nss` с controlled rebuild/invalidation.
- Route tag берётся из slot anchors (`alwp0..alwp5`) для текущего slot.
- Waypoint ordering детерминирован через `al_step`; nearest-based construction не используется.
- Route runtime запускается только в `HOT` area (на `RESYNC`/slot events).
- Baseline execution использует action queue и минимальные activity semantics (`al_activity` + fallback `al_default_activity`).
- `WARM` и `FREEZE` не исполняют normal route runtime.

## Stage E — Multi-step Routines (implemented)
- Реализованы bounded multi-step routines внутри активного slot поверх Stage D cache foundation.
- Поддержан step-advance через `AL_EVENT_ROUTE_REPEAT` как controlled hook (не heartbeat) и без polling.
- Runtime остаётся строго HOT-only и area-scoped, без межзоновых переходов.
- `al_dur_sec` применяется как dwell-фаза каждого шага через action queue.

## Stage F — Sleep Runtime (next)
- Реализовать sleep pipeline по канону `<bed_id>_approach -> <bed_id>_pose`.
- Поддержать `al_bed_id` и валидацию sleep цепочки.
- Реализовать fallback sleep on place при неполной конфигурации.

## Stage G — Blocked / Disturbed Reactions
- Реализовать реактивный слой для blocked/disturbed ситуаций.
- Добавить приоритеты реакций поверх текущего mode.
- Добавить debounce/cooldown для шумных событий.

## Stage H+ — Crime / Alarm / Extensions
- Интегрировать crime/alarm реакции.
- Добавить расширения для контекстных систем мира.
- Сохранить совместимость с каноническим contract.
