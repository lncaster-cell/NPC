# Ambient Life v2 (NPC) — README

> Обновлено: **2026-04-08**.

Репозиторий содержит канон и реализацию систем «живого мира» для NWN2.
С **2026-04-08** проект переведён в режим **полной переписи Daily Life-контура с нуля**: прежняя реализация `Daily Life v1` заархивирована, активная разработка ведётся как `Daily Life v2` по шагам «одна функция → проверка → следующая функция».

---

## 1) Краткая сводка проекта

**Цель проекта:** построить единую модель мира, где повседневная жизнь NPC, право, городская реакция и долгие социально-экономические последствия работают согласованно.

**Текущий активный контур:**
- `Daily Life v2` — clean-room перепись с нуля (инкрементально, функция за функцией).
- `Daily Life v1` сохранён как legacy-архив и используется только как референс.

**Ключевой архитектурный принцип:**
- фракции NWN2 — это инструмент локального runtime-поведения;
- юридическая квалификация, право собственности, институты и долгие последствия живут в отдельных канонических доменах.

---

## 2) Текущий прогресс (на 2026-04-08)

## Что уже сделано

- **Daily Life v1** сохранён в архив для анализа и точечного переиспользования решений:
  - `archive/daily_life_v1_legacy/scripts/daily_life/`.
- Подготовлен чистый рабочий каталог для `Daily Life v2`:
  - `scripts/daily_life/README.md`
  - `scripts/daily_life/dl_v2_bootstrap.nss`
- Запущен отдельный план переписи:
  - `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`.

## Что ещё не закрыто

- Нужно спроектировать v2-контур на основе канона и уроков v1 (до написания рабочего кода).
- Нужно последовательно собрать v2-runtime с проверками на каждом шаге.
- Нужно обновить связанные документы и runbook под новую стратегию разработки.

---

## 3) Быстрая навигация (куда идти в первую очередь)

### Старт для понимания проекта
1. `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md` — общий канон и инварианты.
2. `docs/entry/12_MASTER_PLAN.md` — короткая карта всей библиотеки.
3. `docs/architecture/01_PROJECT_PASSPORT.md` — домены и границы.
4. `docs/library/DOCUMENT_REGISTRY.md` — отсортированный реестр документации по слоям.

### Старт для активной разработки (ежедневный контур)
1. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` — операционная точка входа.
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md` — проектирование и пошаговый протокол v2.
3. `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md` — зафиксированное состояние и уроки v1.
4. `docs/runtime/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md` — legacy-runbook (для ретроспективной сверки поведения v1).

### Код
- Legacy runtime v1: `archive/daily_life_v1_legacy/scripts/daily_life/`.
- Активный runtime v2 (чистый старт): `scripts/daily_life/`.

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

## 5) Legacy-ссылка: Daily Life v1 (архивный контур)

Эта секция оставлена как историческая справка для сравнения поведения со старым контуром.
Активная разработка ведётся по v2-программе: `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`.

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
