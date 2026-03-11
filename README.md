# Ambient Life v2 (NWN2)

Актуальный статус репозитория: **Stages A–I.1 реализованы в коде**.

Этот README — короткая «точка входа» для разработчика и билдера модуля. Подробные контракты вынесены в `docs/`.

## Что это

Ambient Life v2 — событийная система поведения NPC для NWN2 без heartbeat/polling.

Ключевые свойства текущей реализации:
- плотный area-регистр NPC (`al_npc_0..N`) с лимитом `AL_MAX_NPCS = 100`;
- area-driven runtime с LOD-режимами `FREEZE/WARM/HOT`;
- тик области только по токену и только через единый loop (`DelayCommand`);
- смена поведения через user-defined события;
- маршруты по слотам времени (0..5), bounded routine execution;
- поддержка transition-step, sleep-step, OnBlocked, OnDisturbed (I.1 foundation).

## Реализованные стадии

- **A**: архитектурные контракты;
- **B**: event-bus + плотный реестр;
- **C**: area lifecycle, tier policy, linked areas warm retention;
- **D/E**: route cache и bounded routine progression;
- **F**: transition subsystem (area helper / intra teleport);
- **G**: sleep runtime;
- **H**: canonical activity semantics;
- **I.0**: local OnBlocked door-first resume;
- **I.1**: OnDisturbed inventory/theft foundation.

## Быстрый старт

1. Импортируйте все скрипты из `scripts/ambient_life`.
2. Подключите entry-скрипты к событиям area/module/NPC (см. `INSTALLATION.md`).
3. Проставьте locals NPC/waypoint/area по `docs/TOOLSET_CONTRACT.md`.
4. Проверьте smoke-сценарий из `TASKS.md`.

## Основные runtime-константы (по коду)

- area tick: `AL_AREA_TICK_SEC = 30.0`;
- слот времени: `GetTimeHour() / 4` (6 слотов);
- события шины: `AL_EVENT_SLOT_0..5 = 3100..3105`, `AL_EVENT_RESYNC = 3106`, `AL_EVENT_ROUTE_REPEAT = 3107`, `AL_EVENT_BLOCKED_RESUME = 3108`;
- лимит реестра: `AL_MAX_NPCS = 100`.

## Структура репозитория

- `scripts/ambient_life/` — runtime-код NWScript;
- `docs/ARCHITECTURE.md` — архитектура и границы подсистем;
- `docs/TOOLSET_CONTRACT.md` — канонический контракт locals;
- `docs/IMPLEMENTATION_ROADMAP.md` — статус стадий и следующие шаги;
- `INSTALLATION.md` — практическая настройка в toolset;
- `AUDIT.md` — актуальные риски и технический долг;
- `TASKS.md` — приоритетный рабочий backlog;
- `REPORT.md` — короткий прогресс-репорт по текущей итерации.
