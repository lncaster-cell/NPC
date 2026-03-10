# Ambient Life — Implementation Roadmap

## Stage A — Architecture & Contracts (текущий)
- Зафиксировать архитектурный канон и event namespace.
- Зафиксировать locals contract для Area/NPC/Waypoint.
- Подготовить модульный каркас include/entry scripts без runtime логики.

## Stage B — Core Lifecycle Skeleton
- Подключить entry scripts к core dispatcher.
- Реализовать базовую обработку lifecycle событий area/npc/mod.
- Ввести безопасные noop/fallback переходы.

## Stage C — Registry + Route/Cache Foundation
- Реализовать dense area registry.
- Реализовать area/npc cache версии и invalidation протокол.
- Реализовать route descriptor cache и lookup без full-scan в hot path.

## Stage D — Multi-step Activity Routines
- Добавить activity routines как многошаговые state machines.
- Синхронизировать routines со slot transitions и route descriptors.
- Добавить базовую телеметрию routine-step.

## Stage E — Sleep Pipeline
- Реализовать sleep через `approach -> pose` waypoint chains.
- Добавить валидацию sleep chains и fallback при неполной конфигурации.
- Исключить `ActionInteractObject`/rest-подходы из ядра.

## Stage F — Reactive Layer
- Реализовать события реакций (`AL_EVT_REACT_*`) и приоритеты.
- Интегрировать реакции с текущей routine state без heartbeat-модели.
- Добавить cooldown/debounce политику для шумных событий.

## Stage G+ — Crime / Alarm / Extensions
- Реализовать crime/alarm вертикаль как расширение реактивного слоя.
- Добавить контекст area-security roles, escalation policy.
- Подготовить extension points для фракций, погоды, праздников и пр.
