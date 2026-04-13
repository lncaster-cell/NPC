# Document Registry — Ambient Life v2

Дата: 2026-04-13  
Статус: active

## 1) Active documentation (strict)

Единственный активный набор документации (только реально существующие файлы):
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
5. `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`

## 2) Workspace path policy

Канонический runtime workspace path: `daily_life/`.

Любые упоминания `scripts/daily_life/` считаются legacy и не используются для новых шагов.

Короткое правило для авторов:
- legacy-пути допустимы только в архивах, исторических отчётах и immutable-журналах;
- в active set, шаблонах, действующих канонах и контрольных панелях legacy-пути недопустимы;
- в новых документах путь указывается только как `daily_life/`.

PR-чек-лист (docs):
- [ ] Нет новых вхождений `scripts/daily_life/` в active/template документах.
- [ ] Этот документ не дублирует существующий статус.

## 3) Остальные документы

- Все документы вне active set считаются reference/legacy.
- Они могут использоваться для исторического контекста, но не как источник новых обязательных требований.
- Новые “digest”/“meta-index” документы не создаются.
- Единая legacy redirect точка входа: `docs/entry/01_PROJECT_OVERVIEW.md` (historical compatibility only).
