# Implementation Roadmap

## Завершено

- ✅ Stage A — архитектурная основа и контракты.
- ✅ Stage B — event constants/helpers и плотный area registry.
- ✅ Stage C — lifecycle + tier policy + linked-area warm retention.
- ✅ Stage D — route cache.
- ✅ Stage E — bounded routine progression.
- ✅ Stage F — transition subsystem.
- ✅ Stage G — sleep subsystem.
- ✅ Stage H — activity subsystem.
- ✅ Stage I.0 — OnBlocked local recovery.
- ✅ Stage I.1 — OnDisturbed inventory/theft foundation.
- ✅ Stage I.2 — local Crime/Alarm layer (area-local only, bounded escalation/de-escalation).

## Следующий этап

### Stage I.3 — Reinforcement/Legal extensions

Планируемые задачи:
1. Guard spawn / reinforcement policy (опционально, без world-wide scan).
2. Surrender / arrest / trial pipeline поверх Stage I.2 legal hooks.
3. Расширение последствий crime incidents без giant diplomacy simulator.
4. QA-smoke для расширенной legal/reinforcement цепочки.

## Сопутствующие работы

- Набор эксплуатационных smoke-сценариев для QA.
- Диагностика runtime-отказов (регистрация, маршрут, реактивные события).
- Документированный процесс контент-валидации перед релизом.
