# PysukSystems (NPC) — README

> Обновлено: **2026-04-11**.

Цель текущего этапа: прекратить рост мета-документации и развивать runtime-код в `daily_life/`.

## ACTIVE DOC SET (только 5 файлов)

Основной канонический маршрут:
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
5. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

Важно: это **основной маршрут**, но не запрет на использование операционных reference-документов текущего этапа.
Для уточнения acceptance-статуса и фактической рабочей точки также используются:
- `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
- `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`
- `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`

## Канонический workspace path

Единый путь разработки runtime: `daily_life/`.

- новые `.nss` файлы и изменения вносятся только сюда;
- ссылки на `scripts/daily_life/` считаются устаревшими;
- документация должна ссылаться на `daily_life/` как на единственный активный путь.

### Правило для авторов: legacy-paths

- **Где legacy-пути допустимы:** только в архивах, исторических отчётах и immutable-журналах (для фиксации факта прошлого состояния).
- **Где legacy-пути недопустимы:** в active set документах, шаблонах и действующих канонах/контрольных панелях.
- **Как писать путь в новых документах:** использовать единый стандарт `daily_life/` (без новых вхождений `scripts/ambient_life` и `scripts/daily_life` в активных материалах).

### PR-чек-лист для docs

- [ ] Нет новых вхождений `scripts/ambient_life` в active/template документах.

## Практическое правило на следующий шаг

Следующие PR должны быть code-first:
- минимум 1 изменение в `daily_life/*.nss`,
- документация правится только как короткая синхронизация в active doc set.
