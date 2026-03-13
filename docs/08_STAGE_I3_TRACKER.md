# Ambient Life v2 — Stage I.3 Tracker (Reinforcement / Legal)

Дата: 2026-03-13

## 1. Контекст этапа
Stage I.3 продолжает Stage I.2 и добавляет legal/reinforcement поведение поверх уже существующего disturbed/crime/alarm слоя.

## 2. Трекер задач

| Направление | Статус | Что есть сейчас | Что нужно довести до Done |
|---|---|---|---|
| Reinforcement / guard spawn policy | Planned | Есть city alarm runtime и role/assignment события | Формализовать policy ограничений спавна и подкреплений (без world-wide scan), добавить контентные параметры и операционные лимиты |
| Surrender / arrest / trial pipeline | Planned | В `al_react_inc.nss` есть legal hook и `al_legal_followup_pending` | Реализовать конечную цепочку surrender -> arrest -> legal followup/trial с bounded handoff |
| Consequences expansion for crime incidents | Planned | Есть crime типизация и alarm эскалация | Добавить расширенные последствия инцидентов, не смешивая их с giant diplomacy simulator |
| QA smoke for legal/reinforcement | Planned | Есть общие operations/perf правила | Добавить специализированный smoke-runbook и критерии pass/fail для legal/reinforcement цепочки |

## 3. Критерии готовности Stage I.3

Этап считается завершённым, если:
1. Reinforcement policy задокументирована и реализована с лимитами по плотности/частоте.
2. Legal pipeline выполняется end-to-end без unbounded-обходов.
3. Есть воспроизводимый smoke-сценарий для QA с ожидаемыми outcome.
4. Обновлены `docs/02_MECHANICS.md`, `docs/03_OPERATIONS.md`, `docs/04_CONTENT_CONTRACTS.md` и статус-аудит.

## 4. Риски и анти-паттерны

- Запрещён переход к глобальным full-scan подходам.
- Нельзя смешивать city-level FSM и per-NPC routine state в одну неявную машину.
- Нельзя полагаться на ручное изменение runtime locals для «лечения» сценариев.

## 5. Следующие документы после старта реализации

1. `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` — сценарии и чек-лист QA.
2. `docs/10_DECISIONS_LOG.md` — фиксирование архитектурных решений/компромиссов.

## 6. Детализация механизмов Stage I.3

Подробная восстановленная спецификация планируемых механизмов вынесена в:  
`docs/09_PLANNED_MECHANISMS_RESTORED.md`.
