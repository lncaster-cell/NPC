# 42 — Daily Life v2 Repository Reset Log (RU)

> Первичный reset: 2026-04-08  
> Актуализация по фактическому состоянию: 2026-04-09

## Цель

Зафиксировать перевод репозитория в режим clean-room переписи Daily Life v2 и актуальное состояние активной папки.

## Что было сделано в reset-фазе

1. Legacy-runtime v1 перенесён в архив:
   - из `scripts/daily_life/*.nss`
   - в `archive/daily_life_v1_legacy/scripts/daily_life/`
2. Активная рабочая зона `scripts/daily_life/` очищена для v2 шагов.
3. Навигационные и governance-документы переведены на v2 rewrite track.

## Фактическое текущее состояние (2026-04-09)

В `scripts/daily_life/` находятся:
- `dl_v2_runtime_inc.nss`
- `dl2_smoke_step_01.nss`

Это означает, что ранние reset-заметки со ссылками на scripts/daily_life/README.md и scripts/daily_life/dl_v2_bootstrap.nss считаются историческими и больше не отражают текущий факт.

## Ограничения

- Legacy smoke/runbook документы v1 сохраняются как база сравнения.
- До утверждения baseline запрещено добавлять крупные runtime-подсистемы в v2.
- Каждый новый v2-файл добавляется только вместе с проверкой и doc-sync.
