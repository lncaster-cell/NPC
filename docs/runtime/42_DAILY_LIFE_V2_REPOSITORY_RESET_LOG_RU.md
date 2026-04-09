# 42 — Daily Life v2 Repository Reset Log (RU)

> Первичный reset: 2026-04-08  
> Актуализация по фактическому состоянию: 2026-04-09

## Цель

Зафиксировать перевод репозитория в режим clean-room переписи Daily Life v2 и актуальное состояние активной папки.

## Что было сделано в reset-фазе

1. Legacy-runtime v1 был временно вынесен в архив для инспекции.
2. Активная рабочая зона `scripts/daily_life/` очищена для v2 шагов.
3. Навигационные и governance-документы переведены на v2 rewrite track.

## Дополнительная очистка (2026-04-09)

1. После фиксации полезного наследия полностью удалены legacy v1 скрипты:
   - `archive/daily_life_v1_legacy/scripts/daily_life/*.nss`
2. Сохранён reference со списком activity ID и константами анимаций:
   - `scripts/daily_life/dl_v2_activity_animation_constants_inc.nss`

## Фактическое текущее состояние (2026-04-09)

В `scripts/daily_life/` находятся:
- `dl_v2_runtime_inc.nss`
- `dl2_smoke_step_01.nss`
- `dl_v2_activity_animation_constants_inc.nss`

Это означает, что legacy v1 код полностью удалён из репозитория, а нужные константы сохранены в отдельном v2 reference include.

## Ограничения

- Legacy smoke/runbook документы v1 сохраняются как база сравнения.
- До утверждения baseline запрещено добавлять крупные runtime-подсистемы в v2.
- Каждый новый v2-файл добавляется только вместе с проверкой и doc-sync.
