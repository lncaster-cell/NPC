# NPC Ambient Life v2 (NWN2)

Система событийной симуляции NPC без heartbeat/polling на каждом NPC.

## Текущий статус

Репозиторий содержит рабочую реализацию **Stages A–I.1**:
- A: базовая архитектура и контракты;
- B: event bus + плотный area-регистр;
- C: lifecycle области и LOD-tier модель FREEZE/WARM/HOT;
- D/E: route cache и bounded routine progression;
- F: transition steps;
- G: sleep steps;
- H: activity semantics;
- I.0: локальная реакция на OnBlocked;
- I.1: foundation для OnDisturbed (inventory/theft).

## Быстрый старт

1. Импортировать все скрипты из `scripts/ambient_life/` в модуль.
2. Привязать entry scripts (см. `INSTALLATION.md`).
3. Настроить locals у NPC/waypoints/areas (см. `docs/TOOLSET_CONTRACT.md`).
4. Пройти smoke-check из `TASKS.md`.

## Ключевые runtime-константы

- `AL_AREA_TICK_SEC = 30.0`
- `AL_MAX_NPCS = 100`
- `AL_ROUTE_MAX_STEPS = 16`
- события шины: `AL_EVENT_SLOT_0..5 = 3100..3105`, `AL_EVENT_RESYNC = 3106`, `AL_EVENT_ROUTE_REPEAT = 3107`, `AL_EVENT_BLOCKED_RESUME = 3108`

## Структура репозитория

- `scripts/ambient_life/` — NWScript runtime.
- `docs/ARCHITECTURE.md` — архитектурная модель и инварианты.
- `docs/TOOLSET_CONTRACT.md` — контракт locals для toolset.
- `docs/IMPLEMENTATION_ROADMAP.md` — дорожная карта.
- `INSTALLATION.md` — установка и подключение в модуле.
- `AUDIT.md` — текущие риски и контрольные меры.
- `TASKS.md` — активный backlog.

## Что важно помнить

- Централизованный area tick — единственный runtime loop.
- Обработка событий идёт через `OnUserDefined` NPC.
- Переполнение area-реестра (`>100`) приводит к отказу регистрации дополнительных NPC.
