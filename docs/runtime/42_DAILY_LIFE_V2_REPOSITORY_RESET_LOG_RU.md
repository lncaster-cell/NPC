# 42 — Daily Life v2 Repository Reset Log (RU)

> Дата: 2026-04-08

## Цель

Зафиксировать, что репозиторий подготовлен к переписи Daily Life с нуля, а legacy v1 сохранён в архиве.

## Выполненные шаги

1. Legacy-runtime перенесён:
   - из `scripts/daily_life/*.nss`
   - в `archive/daily_life_v1_legacy/scripts/daily_life/`
2. Создан чистый active-workspace:
   - `scripts/daily_life/README.md`
   - `scripts/daily_life/dl_v2_bootstrap.nss`
3. Обновлены entry/governance/runtime-nav документы на v2-track.

## Проверка

- Активный каталог `scripts/daily_life/` содержит только v2-заготовки.
- Архив содержит полный набор legacy v1 скриптов.

## Ограничения

- Legacy smoke/runbook пока не удаляются: используются как ретроспективная база сравнения.
- До утверждения baseline запрещено добавлять крупные runtime-блоки в v2.
