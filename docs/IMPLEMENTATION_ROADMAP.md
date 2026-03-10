# Ambient Life — Implementation Roadmap

## Stage A — Contracts + Skeleton (текущий)
- Зафиксировать канонические locals contracts (Area/NPC/Waypoint).
- Зафиксировать архитектурные принципы (event-driven, dense registry, slot model, caching policy).
- Подготовить skeleton include/entry scripts без runtime logic.

## Stage B — Core Lifecycle (implemented)
- Подключены entry scripts к core dispatcher.
- Реализованы area/npc lifecycle обработчики (spawn/death/enter/exit/leave).
- Реализованы single area-level tick loop, dense registry и internal OnUserDefined bus.
- Slot dispatch работает как area-global orchestration backbone (per-NPC offset-aware dispatch отложен на следующие стадии).

## Stage C — Route Cache + Route Execution
- Реализовать агрессивный route cache без full-scan в hot path.
- Реализовать route lookup по slot anchors (`alwp0..alwp5`).
- Реализовать базовое route execution с invalidation/rebuild политикой.

## Stage D — Multi-step Routines
- Реализовать multi-step routines внутри активного slot.
- Поддержать шаги по waypoint locals: `al_step`, `al_activity`, `al_dur_sec`.
- Добавить переходы между шагами и fallback на `al_default_activity`.

## Stage E — Sleep Runtime
- Реализовать sleep pipeline по канону `<bed_id>_approach -> <bed_id>_pose`.
- Поддержать `al_bed_id` и валидацию sleep цепочки.
- Реализовать fallback sleep on place при неполной конфигурации.

## Stage F — Blocked / Disturbed Reactions
- Реализовать реактивный слой для blocked/disturbed ситуаций.
- Добавить приоритеты реакций поверх текущего mode.
- Добавить debounce/cooldown для шумных событий.

## Stage G+ — Crime / Alarm / Extensions
- Интегрировать crime/alarm реакции.
- Добавить расширения для контекстных систем мира.
- Сохранить совместимость с каноническим contract.
