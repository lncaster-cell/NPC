# PysukSystems (NPC) — README

> Обновлено: **2026-04-11**.

Цель текущего этапа: прекратить рост мета-документации и развивать runtime-код в `daily_life/`.

## ACTIVE DOC SET (только 5 файлов)

Рабочими считаются только эти документы:
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
5. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

Все остальные docs — reference/legacy и не должны становиться источником новых требований.

## Канонический workspace path

Единый путь разработки runtime: `daily_life/`.

- новые `.nss` файлы и изменения вносятся только сюда;
- ссылки на `scripts/daily_life/` считаются устаревшими;
- документация должна ссылаться на `daily_life/` как на единственный активный путь.

## Практическое правило на следующий шаг

Следующие PR должны быть code-first:
- минимум 1 изменение в `daily_life/*.nss`,
- документация правится только как короткая синхронизация в active doc set.
