# Development Status (RU)

> Обновлено: **2026-04-17**

## Текущее состояние

- Runtime-контур Daily Life активен в `daily_life/`.
- Базовая модель: schedule-driven + area-driven, с bounded execution.
- Deep audit pass 7 подтверждает закрытие `R1/R2/R3`, `R6-1/R6-2` и дополнительно закрывает `R7-1` (устойчивый cursor modulo на наблюдаемом active-population в round-robin pass).

## Что уже подтверждено

- Worker проходит по budget/cursor модели.
- Lifecycle ingress (spawn/death/blocked) не потерял базовые инварианты.
- Cache-layer и include-decomposition работают без обнаруженных критичных побочных эффектов.
- В module minute-budget добавлен guard-контур `budget pressure`: при хроническом дефиците бюджета включается временный adaptive cap для worker/resync, что ограничивает накопление нагрузки в hot-area.

## Текущие приоритеты

1. `P1`: owner-run проверка weekend/public и негативных markup-кейсов на текущем runtime-контуре.
2. `P1`: наблюдение за переходами `budget pressure on/off` и калибровка порогов trigger/relief в реальном owner-run.
3. `P2`: точечный мониторинг transition-driver lookup churn в нагруженных локациях.

## Ограничения и политика

- Все решения проверять через встроенные механики NWN2/NWScript и NWN Lexicon.
- Не вводить ad-hoc обходы, если есть штатная функция/паттерн.
- Любая правка runtime должна сопровождаться краткой синхронизацией статуса в этом файле.


## Последний артефакт аудита

- `daily_life/post_refactor_audit_pass7.md` — аудит pass 7 с закрытием риска R7-1 (same-window reset курсора при fast-break).
