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

## Следующий этап

### Stage I.2 — Crime/Alarm

Планируемые задачи:
1. Нормализация типа и тяжести события кражи/нарушения.
2. Локальное распространение тревоги в пределах area scope.
3. Роли guard/civilian и правила эскалации без глобального world scan.
4. Защитные fallback-пути при неполных данных source/item/context.

## Сопутствующие работы

- Набор эксплуатационных smoke-сценариев для QA.
- Диагностика runtime-отказов (регистрация, маршрут, реактивные события).
- Документированный процесс контент-валидации перед релизом.
