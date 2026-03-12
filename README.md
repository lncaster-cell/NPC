# NPC Ambient Life v2 (NWN2)

Система событийной симуляции NPC без heartbeat/polling на каждом NPC.

## Текущий статус

Репозиторий содержит рабочую реализацию **Stages A–I.2**.

### Готовность механик

| Механика | Статус | Комментарий |
| --- | --- | --- |
| Stage A: архитектурная основа и контракты | ✅ Готово | Базовая модель и контракты зафиксированы. |
| Stage B: event bus + area registry | ✅ Готово | Плотный реестр NPC по area и event-константы в продакшн-контуре. |
| Stage C: lifecycle + LOD tiers | ✅ Готово | FREEZE/WARM/HOT, linked-area retention включены. |
| Stage D: route cache | ✅ Готово | Маршруты кешируются и переиспользуются. |
| Stage E: bounded routine progression | ✅ Готово | Продвижение по рутине ограничено и стабилизировано. |
| Stage F: transition subsystem | ✅ Готово | Переходные шаги применяются в runtime. |
| Stage G: sleep subsystem | ✅ Готово | Sleep-логика и специальные sleep-коды подключены. |
| Stage H: activity subsystem | ✅ Готово | Канонические activity-коды и семантика в рабочем потоке. |
| Stage I.0: OnBlocked recovery | ✅ Готово | Локальное восстановление после block-событий. |
| Stage I.1: OnDisturbed foundation | ✅ Готово | База для inventory/theft-инцидентов. |
| Stage I.2: local Crime/Alarm | ✅ Готово | Локальная эскалация/деэскалация (civilian/militia/guard split). |
| Stage I.3: reinforcement/legal extensions | 🟡 Запланировано | Guard spawn/reinforcement, arrest/trial pipeline, расширение legal chain. |

### Открытые задачи (backlog)

- P0: диагностика отказа `AL_RegisterNPC` при `AL_MAX_NPCS`.
- P0: унификация подключения `al_area_tick` для разных шаблонов модулей.
- P1: чек-лист валидации маршрутов.
- P1: шаблон контент-подготовки sleep-точек (`_approach`/`_pose`).
- P1: операторский гайд по linked areas (`al_link_*`) и warm-policy.
- P2: сервисный валидатор locals (NPC/waypoints/areas).
- P2: профилирование производительности на сценах с высокой плотностью NPC.

## Коды активностей (канонический список)

Источник: `scripts/ambient_life/al_acts_inc.nss`.

> Поддержка activity-таблицы (группы кодов и возвращаемые анимации/waypoint tags) ведётся в `scripts/ambient_life/al_acts_inc.nss`
> в блоке helper-предикатов `AL_IsActivityInGroup*` и в публичных мапперах `AL_GetActivity*`.

| Код | Константа |
| ---: | --- |
| 0 | `AL_ACT_NPC_HIDDEN` |
| 1 | `AL_ACT_NPC_ACT_ONE` |
| 2 | `AL_ACT_NPC_ACT_TWO` |
| 3 | `AL_ACT_NPC_DINNER` |
| 4 | `AL_ACT_NPC_MIDNIGHT_BED` |
| 5 | `AL_ACT_NPC_SLEEP_BED` |
| 6 | `AL_ACT_NPC_WAKE` |
| 7 | `AL_ACT_NPC_AGREE` |
| 8 | `AL_ACT_NPC_ANGRY` |
| 9 | `AL_ACT_NPC_SAD` |
| 10 | `AL_ACT_NPC_COOK` |
| 11 | `AL_ACT_NPC_DANCE_FEMALE` |
| 12 | `AL_ACT_NPC_DANCE_MALE` |
| 13 | `AL_ACT_NPC_DRUM` |
| 14 | `AL_ACT_NPC_FLUTE` |
| 15 | `AL_ACT_NPC_FORGE` |
| 16 | `AL_ACT_NPC_GUITAR` |
| 17 | `AL_ACT_NPC_WOODSMAN` |
| 18 | `AL_ACT_NPC_MEDITATE` |
| 19 | `AL_ACT_NPC_POST` |
| 20 | `AL_ACT_NPC_READ` |
| 21 | `AL_ACT_NPC_SIT` |
| 22 | `AL_ACT_NPC_SIT_DINNER` |
| 23 | `AL_ACT_NPC_STAND_CHAT` |
| 24 | `AL_ACT_NPC_TRAINING_ONE` |
| 25 | `AL_ACT_NPC_TRAINING_TWO` |
| 26 | `AL_ACT_NPC_TRAINER_PACE` |
| 27 | `AL_ACT_NPC_WWP` |
| 28 | `AL_ACT_NPC_CHEER` |
| 29 | `AL_ACT_NPC_COOK_MULTI` |
| 30 | `AL_ACT_NPC_FORGE_MULTI` |
| 31 | `AL_ACT_NPC_MIDNIGHT_90` |
| 32 | `AL_ACT_NPC_SLEEP_90` |
| 33 | `AL_ACT_NPC_THIEF` |
| 36 | `AL_ACT_NPC_THIEF2` |
| 37 | `AL_ACT_NPC_ASSASSIN` |
| 38 | `AL_ACT_NPC_MERCHANT_MULTI` |
| 39 | `AL_ACT_NPC_KNEEL_TALK` |
| 41 | `AL_ACT_NPC_BARMAID` |
| 42 | `AL_ACT_NPC_BARTENDER` |
| 43 | `AL_ACT_NPC_GUARD` |
| 91 | Locate-wrapper activity |
| 92 | Locate-wrapper activity |
| 93 | Locate-wrapper activity |
| 94 | Locate-wrapper activity |
| 95 | Locate-wrapper activity |
| 96 | Locate-wrapper activity |
| 97 | Locate-wrapper activity |
| 98 | Locate-wrapper activity |

## Быстрый старт

1. Импортировать все скрипты из `scripts/ambient_life/` в модуль.
2. Привязать entry scripts (см. `INSTALLATION.md`).
3. Настроить locals у NPC/waypoints/areas (см. `docs/TOOLSET_CONTRACT.md`).
4. Пройти smoke-check из `TASKS.md`.
5. Выполнить perf-check по `docs/PERF_RUNBOOK.md` (как часть регулярного QA).

## Ключевые runtime-константы

- `AL_AREA_TICK_SEC = 30.0`
- `AL_MAX_NPCS = 100`
- `AL_ROUTE_MAX_STEPS = 16`
- события шины: `AL_EVENT_SLOT_0..5 = 3100..3105`, `AL_EVENT_RESYNC = 3106`, `AL_EVENT_ROUTE_REPEAT = 3107`, `AL_EVENT_BLOCKED_RESUME = 3108`

## Границы Stage I.2

- Crime/alarm работает только в пределах текущей area (без global/world alarm), с bounded nearby реакцией уже существующих NPC.
- Используются уже существующие NPC в runtime-контексте; guard spawn/reinforcements не реализованы.
- Guard-path учитывает built-in hostility/faction NWN2; surrender/arrest/trial не реализованы (оставлены future hooks).
- Ordinary Stage D/E/F/G/H flow остаётся default path вне локальных инцидентов.

## Структура репозитория

- `scripts/ambient_life/` — NWScript runtime.
- `docs/ARCHITECTURE.md` — архитектурная модель и инварианты.
- `docs/TECH_PASSPORT.md` — единый технический паспорт системы (архитектура, runtime-поток, роли файлов, инварианты, диагностика).
- `docs/TOOLSET_CONTRACT.md` — контракт locals для toolset.
- `docs/IMPLEMENTATION_ROADMAP.md` — дорожная карта.
- `INSTALLATION.md` — установка и подключение в модуле.
- `AUDIT.md` — текущие риски и контрольные меры.
- `TASKS.md` — активный backlog.
- `docs/PERF_RUNBOOK.md` — воспроизводимый perf-протокол и PR-шаблон отчёта «до/после».

## Что важно помнить

- Централизованный area tick — единственный runtime loop.
- Обработка событий идёт через `OnUserDefined` NPC.
- Переполнение area-реестра (`>100`) приводит к отказу регистрации дополнительных NPC.
