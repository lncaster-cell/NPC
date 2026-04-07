# Ambient Life v2 (NPC) — README

> Обновлено: **2026-04-07**.

Репозиторий содержит канон и рабочую реализацию систем «живого мира» для NWN2. Сейчас проект находится в фазе **active development** с фокусом на **Daily Life v1 / Milestone A**: архитектура уже формализована в документации, а в `scripts/daily_life/` реализован рабочий runtime-контур.

---

## 1) Краткая сводка проекта

**Цель проекта:** построить единую модель мира, где повседневная жизнь NPC, право, городская реакция и долгие социально-экономические последствия работают согласованно.

**Текущий активный контур:**
- `Daily Life v1` (Milestone A) — единственный implementation-priority.
- Проект **не** в состоянии «только документы»: runtime-скрипты уже используются для smoke/acceptance цикла.

**Ключевой архитектурный принцип:**
- фракции NWN2 — это инструмент локального runtime-поведения;
- юридическая квалификация, право собственности, институты и долгие последствия живут в отдельных канонических доменах.

---

## 2) Текущий прогресс (на 2026-04-07)

## Что уже реализовано

В коде собран каркас Milestone A (Steps A–E):
- **A — Contracts foundation:** константы, locals-контракты, утилиты, логгер.
- **B — Resolver:** deterministic цепочка `schedule -> directive -> anchor/dialogue/service`, override (`QUARANTINE`, `FIRE`).
- **C — Materialization/interaction:** anchor fallback, materialize path, обновление `dialogue_mode/service_mode`, safe fallback-ветки.
- **D — Area worker/lifecycle:** `HOT/WARM/FROZEN`, bounded worker budget, area/NPC hooks, resync path.
- **E — Stub handoff:** API для slot-review/slot-assigned и безопасные ветки `BASE_LOST -> ABSENT/UNASSIGNED`.

## Что ещё не закрыто

- Нет подтверждённого полного acceptance-цикла A–G со статусом PASS.
- Нет финального owner-run на целевой машине, который закрывает Milestone A.
- Часть зон остаётся намеренно stub-level до подтверждения smoke-прогонами.

---

## 3) Быстрая навигация (куда идти в первую очередь)

### Старт для понимания проекта
1. `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md` — общий канон и инварианты.
2. `docs/entry/12_MASTER_PLAN.md` — короткая карта всей библиотеки.
3. `docs/architecture/01_PROJECT_PASSPORT.md` — домены и границы.
4. `docs/library/DOCUMENT_REGISTRY.md` — отсортированный реестр документации по слоям.

### Старт для активной разработки (ежедневный контур)
1. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` — операционная точка входа.
2. `docs/runtime/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md` — шаги A–E и критерии.
3. `docs/runtime/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md` — как прогонять проверки.
4. `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md` — фиксация фактических результатов.
5. `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md` — снимок «что реально сделано в коде».

### Код
- Runtime-реализация: `scripts/daily_life/`.
- Базовая compile-safe точка входа include-слоя: `scripts/daily_life/dl_all_inc.nss`.

---

## 4) Планируемые механизмы vs реализованные механизмы

Ниже краткий статус по верхнеуровневым системам.

| Домен / механизм | План | Текущее состояние |
|---|---|---|
| **Daily Life (NPC routine)** | Полный цикл повседневной жизни NPC, recovery после отклонений, role-based расписания | **Частично реализовано (Milestone A):** рабочий runtime-каркас A–E, smoke/acceptance ещё в процессе |
| **City Response** | Полноценная стадийная реакция города (alarm/escalation/de-escalation) | **На уровне канона и границ**, без полноценной production-интеграции в текущем milestone |
| **Legal / World Model** | Единая правовая истина мира: юрисдикция, статусы, легитимность институтов | **Канон сформирован в документации**, runtime-интеграция отложена за рамки текущего milestone |
| **Witness / Crime / Arrest / Trial** | Сквозная процессуальная цепочка от сигнала до судебного решения | **Концептуально определено**, не является активным scope Milestone A |
| **Player Property** | Права владения/доступа/конфискации с legal-связкой | **Документарный канон**, не активная реализация в текущем спринте |
| **World Travel** | Межрегиональный перенос состояния и последствий | **Документарный канон**, runtime не в текущем execution scope |
| **Trade / City State** | Макродинамика снабжения/кризисов и городского состояния | **Документарный канон**, глубокая интеграция отложена |
| **Clan System** | Политико-социальные последствия, лояльности, конфликты | **Документарный канон**, не активная кодовая фаза |
| **Aging / Succession** | Поколенческий контур, наследование, длинная память мира | **Документарный канон**, реализация вне Milestone A |

---

## 5) Быстрый старт Daily Life v1 (Milestone A)

Минимальный setup для рабочего smoke-контура (единый checklist без дублирования):

| Scope | Что настроить |
|---|---|
| **Module** | `OnModuleLoad -> scripts/daily_life/dl_on_load`, local bool `dl_smoke_trace = TRUE` (опционально для подробных логов) |
| **Area** | `OnEnter -> scripts/daily_life/dl_area_enter`, `OnExit -> scripts/daily_life/dl_area_exit`, `OnHeartbeat -> scripts/daily_life/dl_area_tick`, local int `dl_area_tier = 2` (`HOT`) хотя бы в одной тестовой зоне |
| **NPC** | locals `dl_npc_family`, `dl_npc_subtype`, `dl_schedule_template`, `dl_npc_base`; флаг участия `dl_named=TRUE` **или** `dl_persistent=TRUE`; hooks `OnSpawn -> scripts/daily_life/dl_npc_onspawn`, `OnUserDefined -> scripts/daily_life/dl_npc_onud`, `OnDeath -> scripts/daily_life/dl_npc_ondeath` |

Smoke-команды:
- базовый запуск: `scripts/daily_life/dl_smoke_milestone_a.nss`;
- точечная проверка Step E: `scripts/daily_life/dl_smoke_step_e.nss`.

### 5.1) Readiness внутри smoke: подготовка к запуску

Отдельный preflight-скрипт не нужен: `scripts/daily_life/dl_smoke_milestone_a.nss` автоматически начинает прогон с readiness-проверки по checklist выше.

Перед запуском A–G сценариев скрипт пишет:
- `MilestoneA readiness summary ... errors=<N>`
- при проблемах: `MilestoneA smoke overall aborted due to readiness errors=<N>`

Если `errors > 0`, сначала исправляем контракт setup (Module/Area/NPC из таблицы), затем перезапускаем smoke.

Ожидаемые маркеры успеха в логах:
- `MilestoneA smoke A..G status=...`
- `smoke snapshot ... directive=... dialogue=... service=...`
- для Step E: `checked/absent/unassigned/last_kind/last_slot`

---

## 6) Границы, которые нельзя размывать

- **Daily Life ≠ City Response** (рутина ≠ режим тревоги).
- **City Response ≠ Legal System** (оперативная реакция ≠ юридическая квалификация).
- **Legal System ≠ Clan/Trade/Long-term effects** (разные уровни последствий).
- **World Travel ≠ Local area movement** (межрегиональный перенос ≠ локальная навигация).

---

## 7) Правило работы с документацией

Если меняется механика:
1. Сначала обновляется профильный SoT-документ (доменный канон).
2. Затем синхронизируются обзорные документы (`README.md`, `12_MASTER_PLAN`, control panel).
3. Если затронуты архитектурные компромиссы — фиксировать в `docs/governance/10_DECISIONS_LOG.md`.

README — это **маршрутизатор** и оперативная сводка, а не замена канонических документов.
