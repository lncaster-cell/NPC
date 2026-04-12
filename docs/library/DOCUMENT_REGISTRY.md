# Document Registry — Ambient Life v2

Дата: 2026-04-11
Статус: active

## 1) Active documentation (strict)

Единственный активный набор документации (5 файлов):
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
5. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

## 2) Workspace path policy

Канонический runtime workspace path: `daily_life/`.

Любые упоминания `scripts/daily_life/` считаются legacy и не используются для новых шагов.

Короткое правило для авторов:
- legacy-пути допустимы только в архивах, исторических отчётах и immutable-журналах;
- в active set, шаблонах, действующих канонах и контрольных панелях legacy-пути недопустимы;
- в новых документах путь указывается только как `daily_life/`.

PR-чек-лист (docs):
- [ ] Нет новых вхождений `scripts/daily_life/` в active/template документах.

## 3) Operational reference (allowed but non-canonical)

Разрешённый ограниченный operational reference list (не расширяет canonical active set):
- `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
- `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`
- `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`

## 4) Остальные документы

- Все документы вне canonical active set и ограниченного operational reference list считаются reference/legacy.
- Они могут использоваться для исторического контекста, но не как источник новых обязательных требований.
- Новые “digest”/“meta-index” документы не создаются.
- `docs/runtime/54_DAILY_LIFE_V2_EXECUTION_TASK_LIST_RU.md` зафиксирован как **frozen redirect** и не используется как отдельный главный execution-план.
