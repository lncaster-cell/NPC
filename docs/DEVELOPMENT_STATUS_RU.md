# Development Status (RU)

> Обновлено: **2026-04-15**

## Текущее состояние

- Runtime-контур Daily Life активен в `daily_life/`.
- Базовая модель: schedule-driven + area-driven, с bounded execution.
- Post-refactor audit (pass 4) подтверждает общую runtime-safe структуру, но фиксирует приоритетный performance-risk `R1`.

## Что уже подтверждено

- Worker проходит по budget/cursor модели.
- Lifecycle ingress (spawn/death/blocked) не потерял базовые инварианты.
- Cache-layer и include-decomposition работают без обнаруженных критичных побочных эффектов.

## Текущие приоритеты

1. `P1`: mitigation для `R1` (same-heartbeat dedupe при area-enter resync).
2. `P1`: снижение churn в SOCIAL partner lookup через безопасное cache-переиспользование.
3. `P2`: owner-run проверка weekend/public и негативных markup-кейсов.

## Ограничения и политика

- Все решения проверять через встроенные механики NWN2/NWScript и NWN Lexicon.
- Не вводить ad-hoc обходы, если есть штатная функция/паттерн.
- Любая правка runtime должна сопровождаться краткой синхронизацией статуса в этом файле.
