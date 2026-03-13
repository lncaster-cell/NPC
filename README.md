# NPC Ambient Life v2

Система скриптов `ambient_life` для управления жизненным циклом NPC: рутины, маршруты, переходы между area, реакции на события, сон и городские crime/alarm механики.

## Текущий этап разработки

Согласно дорожной карте, завершены стадии **A–I.2** (архитектурная основа, registry/dispatch, lifecycle, route cache, routines, transitions, sleep, activity, blocked/disturbed и базовый local Crime/Alarm).

**Текущий следующий этап:** **Stage I.3 — Reinforcement/Legal extensions**.

План на этап I.3:
1. Политика guard spawn / reinforcement (без world-wide scan).
2. Surrender / arrest / trial pipeline поверх legal hooks Stage I.2.
3. Расширение последствий crime incidents без усложнения до «giant diplomacy simulator».
4. QA smoke для legal/reinforcement цепочки.

Источник: `docs/IMPLEMENTATION_ROADMAP.md`.

## Лист активностей

- Поддержка и развитие подсистемы рутин и расписаний NPC.
- Поддержка маршрутизации и переходов между area.
- Поддержка реактивного слоя (blocked/disturbed, восстановление поведения).
- Поддержка sleep lifecycle.
- Поддержка city crime/alarm и подготовка к legal/reinforcement расширениям.
- Эксплуатационные smoke-сценарии для QA.
- Диагностика runtime-отказов (регистрация, маршрут, реактивные события).
- Контент-валидация перед релизом.

## Ключевая документация (актуально в репозитории)

- Обзор проекта: `docs/01_PROJECT_OVERVIEW.md`
- Механики: `docs/02_MECHANICS.md`
- Эксплуатация и валидация: `docs/03_OPERATIONS.md`
- Контракт контента: `docs/04_CONTENT_CONTRACTS.md`
- Статус-аудит (что реализовано/что планируется): `docs/05_STATUS_AUDIT.md`
- Perf baselines и шаблоны отчётов: `docs/perf/baselines/*`

## Ограничение для аудитов и инспекций

При аудитах, инспекциях и аналогичных процедурах:
- **не анализируем и не изменяем** директорию `third party`;
- **не анализируем и не изменяем** находящийся внутри неё компилятор.
