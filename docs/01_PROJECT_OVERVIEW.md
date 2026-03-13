# Ambient Life v2 — Project Overview

## 1. Назначение
Ambient Life v2 симулирует «живую» жизнь NPC в NWN2 через area-centric runtime и event-driven orchestration без per-NPC heartbeat-циклов.

## 2. Архитектурные принципы
- **Area-centric execution**: обработка координируется area tick scheduler.
- **Event-driven orchestration**: NPC получают сигналы через `OnUserDefined` и профильные event hooks.
- **Bounded processing**: маршруты, реакции и dispatch выполняются в ограниченных бюджетах.
- **Content-configured behavior**: поведение задаётся локалами на NPC/waypoint/area.

## 3. Ключевые подсистемы
- Lifecycle tiers (`FREEZE/WARM/HOT`).
- Area/NPC registry + bounded dispatch queue.
- Route + transition subsystem для linked areas.
- Sleep/activity/react pipelines.
- City crime/alarm слой с конечными состояниями и ограниченной эскалацией.

## 4. Карта runtime-файлов
Основная реализация находится в `scripts/ambient_life/al_*` и разделена на:
- ядро и диспетчеризацию (`al_core_inc`, `al_dispatch_inc`, `al_events_inc`),
- реестры и кэши (`al_registry_inc`, `al_lookup_cache_inc`, `al_route_cache_inc`),
- механики (`al_route_inc`, `al_transition_inc`, `al_sleep_inc`, `al_activity_inc`, `al_react_inc`),
- city layer (`al_city_registry_inc`, `al_city_alarm_inc`, `al_city_crime_inc`).

## 5. Дорожная карта
### Завершено
- Stages A–H (архитектура, registry, lifecycle, route/transition, sleep/activity).
- Stage I.0–I.2 (blocked/disturbed и локальный crime/alarm слой).

### Следующий этап
**Stage I.3 — Reinforcement/Legal extensions**:
1. Ограниченные policy для reinforcement/guard spawn.
2. Surrender/arrest/trial pipeline поверх legal hooks.
3. Расширение последствий crime incidents без world-wide scan.
4. Smoke/QA сценарии для legal/reinforcement цепочки.

## 6. Что редактирует контент vs runtime
- Контент задаёт route-теги, activity hints, city/area linkage, sleep markup.
- Runtime локалы (очереди, курсоры, счётчики, state-machine flags) вручную не редактируются.
