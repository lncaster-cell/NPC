# Development Status (RU)

> Обновлено: **2026-04-15**

## Текущее состояние

- Runtime-контур Daily Life активен в `daily_life/`.
- Базовая модель: schedule-driven + area-driven, с bounded execution.
- Deep audit (pass 6) подтверждает закрытие `R1/R2/R3` и фиксирует/закрывает дополнительные риски `R6-1/R6-2` (same-area social partner validation и предсказуемый transition jump path).

## Что уже подтверждено

- Worker проходит по budget/cursor модели.
- Lifecycle ingress (spawn/death/blocked) не потерял базовые инварианты.
- Cache-layer и include-decomposition работают без обнаруженных критичных побочных эффектов.

## Текущие приоритеты

1. `P1`: owner-run проверка weekend/public и негативных markup-кейсов (включая межзоновые social/transition сценарии).
2. `P1`: telemetry по cache miss-rate для transition-driver и anchor lookup (`GetObjectByTag`).
3. `P2`: измерения hot-path стоимости directive skeleton (без функционального рефакторинга).

## Ограничения и политика

- Все решения проверять через встроенные механики NWN2/NWScript и NWN Lexicon.
- Не вводить ad-hoc обходы, если есть штатная функция/паттерн.
- Любая правка runtime должна сопровождаться краткой синхронизацией статуса в этом файле.


## Последний артефакт аудита

- `daily_life/post_refactor_audit_pass6_deep.md` — deep-аудит pass 6 с дополнительными рисками/фиксациями и обновлёнными приоритетами.
