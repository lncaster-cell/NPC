# Daily Life v1 — Multi-Agent Inspection, Optimization Plan, Bug & Conflict Register

Дата: 2026-04-07  
Статус: active (inspection snapshot + execution backlog)  
Роль: практический план продолжения работ, если нет прямой runtime-задачи в очереди.

---

## 1) Цель этого документа

1. Дать наблюдаемый backlog для параллельной работы агентов без конфликтов.
2. Зафиксировать план оптимизаций по low/medium-risk зонам, найденным в include-layer.
3. Сформировать стартовый реестр багов/конфликтов в документации и процессе.
4. Привязать рекомендации к внешним техническим практикам (Git/CI/release safety).

---

## 2) Что было инспектировано в этом проходе

- `scripts/daily_life/dl_activity_inc.nss`
- `scripts/daily_life/dl_anchor_inc.nss`
- `scripts/daily_life/dl_worker_inc.nss`
- `scripts/daily_life/dl_resync_inc.nss`
- `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`
- `docs/governance/24_PARALLEL_AGENT_COORDINATION_BOARD.md`
- `docs/governance/26_AGENT_COMMUNICATION_LOG.md`
- `docs/audits/30_AUDIT_AND_INSPECTION_INDEX.md`

---

## 3) Очередь задач (task list для следующих ходов)

| ID | Тип | Scope | Приоритет | Риск | Зависимости | Что получает следующий агент |
|---|---|---|---|---|---|---|
| T1 | code-cleanup | `dl_anchor_inc.nss` dedup поиска anchor-кандидатов | high | medium | нет | единый helper-итератор поиска + меньше copy-paste |
| T2 | code-cleanup | `dl_worker_inc.nss` unify `DL_Describe*` | medium | low | нет | компактный map/dispatcher без смены smoke-формата |
| T3 | safety-check | regression smoke после T1/T2 | high | medium | T1/T2 | подтверждение что `directive/dialogue/service` не деградировали |
| T4 | docs-fix | исправить порядок подпунктов `7.3/7.4` в control panel | medium | low | нет | меньше навигационной неоднозначности |
| T5 | process | заменить `pending` на SHA после merge-ready handoff | medium | low | нет | трассируемость handoff -> commit |
| T6 | tooling | добавить diff-aware SAST-скан в CI (docs-first) | medium | low | owner decision | раннее обнаружение дефектов в PR |
| T7 | release-safety | ввести canary-smoke gate для smoke сценариев A–E | medium | medium | T3 | безопасная инкрементальная проверка |
| T8 | conflict-audit | еженедельная сверка `README`/`21`/`30` | low | low | нет | снижение doc-drift между обзором и операционкой |

---

## 4) План оптимизаций (итерационный)

### Wave 1 (безопасный, low-regret)
- T2 (`DL_Describe*` unify) + T4 (doc numbering fix) + T5 (SHA discipline).
- Критерий done: только локальные изменения, без смены runtime-поведения.

### Wave 2 (умеренный риск)
- T1 (dedup anchor cascade) + T3 (обязательный smoke-run по runbook).
- Критерий done: anchor fallback/policy ветки дают те же финальные состояния NPC.

### Wave 3 (процесс и качество)
- T6 + T7 + T8.
- Критерий done: появляется повторяемый процесс раннего поиска дефектов и doc-sync.

---

## 5) Реестр багов/конфликтов (стартовый)

| ID | Категория | Наблюдение | Влияние | Статус | Safe fix |
|---|---|---|---|---|---|
| C-01 | docs-consistency | В `docs/21...` был нарушен порядок подпунктов (`7.4` перед `7.3`) | навигационная путаница | resolved (2026-04-07) | подпункты переставлены в корректный порядок без смысловых правок |
| C-02 | coordination-trace | В координационных логах часто остаётся `Commit(s): pending` после фактического commit | хуже трассируемость | open | правило: в следующем ходе обновлять SHA |
| C-03 | duplication-risk | Повторяющиеся anchor-search ветки в policy/ignoring-policy | рост стоимости сопровождения | open | helper-итератор + regression smoke |
| C-04 | duplication-risk | Повтор enum->string веток в `DL_Describe*` | мелкий шум и риск рассинхрона лог-имен | open | table/dispatcher helper |

---

## 6) Внешние рекомендации и готовые практики (internet-backed)

1. **Git rerere** — повторно использует ранее записанные resolution конфликтов, полезно при долгоживущих ветках и повторных merge-конфликтах.  
   Реф: https://git-scm.com/docs/git-rerere
2. **Git worktree** — позволяет вести несколько рабочих деревьев одновременно (например, отдельные ветки под T1/T2/T4 без переключения состояния).  
   Реф: https://git-scm.com/docs/git-worktree
3. **Git range-diff** — сравнение двух версий серии коммитов, полезно для ревью «v2 vs v1» после замечаний.  
   Реф: https://git-scm.com/docs/git-range-diff
4. **GitHub code scanning** — готовый контур для обнаружения и исправления уязвимостей/проблем в коде через PR-поток.  
   Реф: https://docs.github.com/en/code-security/concepts/code-scanning/about-code-scanning
5. **Semgrep CI (diff-aware)** — практичный SAST для CI, включая режим сканирования изменений в PR/MR.  
   Рефы: https://semgrep.dev/docs/deployment/add-semgrep-to-ci , https://semgrep.dev/docs/cli-reference
6. **Google SRE Workbook (Canarying Releases)** — успешный operational-кейс по постепенному rollout и снижению риска релизов.  
   Реф: https://sre.google/workbook/index/

---

## 7) Минимальный мультиагентный execution-протокол на следующую неделю

Для каждого нового task-ID обязательно:
1. `claimed` в `docs/governance/24_PARALLEL_AGENT_COORDINATION_BOARD.md`.
2. `in_progress` и `done` в Exchange Log (короткий формат).
3. Дублирование handoff в `docs/governance/26_AGENT_COMMUNICATION_LOG.md`.
4. Если есть commit — в следующем ходе заменить `pending` на SHA.

Это сохраняет наблюдаемость и снижает риск конфликтной работы между агентами.
