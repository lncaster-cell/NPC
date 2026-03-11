# Ambient Life — Implementation Roadmap (актуализировано)

## Реализовано

- ✅ Stage A: contracts/architecture baseline.
- ✅ Stage B: dense area registry + event constants/helpers.
- ✅ Stage C: area lifecycle, LOD tiers, linked warm-retention.
- ✅ Stage D: route cache by slot/tag.
- ✅ Stage E: bounded routine progression.
- ✅ Stage F: transition step subsystem.
- ✅ Stage G: sleep subsystem.
- ✅ Stage H: canonical activity layer.
- ✅ Stage I.0: OnBlocked local recovery.
- ✅ Stage I.1: OnDisturbed inventory/theft foundation.

## В работе (следующая цель)

### Stage I.2 — Crime/Alarm reactions

План:
1. Классификация источника и тяжести события кражи.
2. Локальное распространение тревоги (bounded area scope).
3. Правила эскалации guard/civilian без глобального сканирования мира.
4. Безопасные fallback-пути при неполном контексте source/item.

## Технический долг

- Инструментальный лог/метрики на отказ регистрации при переполнении (`AL_MAX_NPCS`).
- Единый debug-toggle для реактивных подсистем I.0/I.1/I.2.
- Автоматизируемый smoke-набор сценариев для handoff тестирования контента.
