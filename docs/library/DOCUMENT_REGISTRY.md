# Document Registry — Ambient Life v2

Дата: 2026-04-07  
Статус: active

## Цель

Снизить документационный хаос за счёт единого реестра: каждый документ относится к понятной папке/слою и имеет явную роль.

## 1) Слои документации (порядок чтения)

1. **Entry layer** — быстрый вход и маршрутизация.
2. **SoT layer** — канонические доменные документы.
3. **Runtime layer** — реализация и операции Daily Life.
4. **Governance layer** — решения, синхронизация, контроль активной разработки.
5. **Audit layer** — инспекции и traceability-снимки.
6. **Archive layer** — legacy и исторические материалы.

---

## 2) Реестр по слоям

### 2.1 Entry layer

- `README.md` — вход в проект.
- `docs/12_MASTER_PLAN.md` — краткий индекс библиотеки.
- `docs/00_PROJECT_LIBRARY.md` — routing-правила и чистота документации.
- `docs/library/DOMAIN_INDEX.md` — быстрый переход домен → primary source.

### 2.2 SoT layer (канон)

- `docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`
- `docs/12A_WORLD_MODEL_CANON.md`
- `docs/12B_DAILY_LIFE_VNEXT_CANON.md`
- `docs/12C_PLAYER_PROPERTY_SYSTEM.md`
- `docs/12D_WORLD_TRAVEL_CANON.md`
- `docs/12E_TRADE_AND_CITY_STATE_CANON.md`
- `docs/13_AGING_AND_CLAN_SUCCESSION.md`
- `docs/14_CLAN_SYSTEM_DESIGN.md`

### 2.3 Runtime layer (Daily Life v1 implementation)

- `docs/12B_RUNTIME_MASTER_PLAN.md`
- `docs/12B_DAILY_LIFE_V1_IMPLEMENTATION_SLICE.md`
- `docs/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
- `docs/12B_DAILY_LIFE_V1_RULESET_REV1.md`
- `docs/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
- `docs/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
- `docs/12B_DAILY_LIFE_V1_DIRECTIVE_ACTIVITY_MATRIX.md`
- `docs/12B_DAILY_LIFE_V1_DIALOGUE_BRIDGE.md`
- `docs/12B_DAILY_LIFE_V1_ACTIVITY_ANIMATION_REFERENCE.md`
- `docs/12B_DAILY_LIFE_V1_INCLUDE_POLICY.md`
- `docs/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md`
- `docs/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`
- `docs/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`
- `docs/26_DAILY_LIFE_V1_TECHNICAL_SPEC_RU.md`

### 2.4 Governance layer (синхронизация и управление)

- `docs/10_DECISIONS_LOG.md`
- `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md`
- `docs/18_REBUILD_RESET_CONTEXT.md`
- `docs/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`
- `docs/24_PARALLEL_AGENT_COORDINATION_BOARD.md`
- `docs/26_AGENT_COMMUNICATION_LOG.md`
- `docs/architecture/01_PROJECT_PASSPORT.md`
- `docs/architecture/02_OPEN_DESIGN_QUESTIONS.md`

### 2.5 Audit layer

- `docs/30_AUDIT_AND_INSPECTION_INDEX.md` (главный вход)
- `docs/23_DAILY_LIFE_V1_CODE_AUDIT_2026-03-30.md`
- `docs/23_CONFLICT_AUDIT_2026-04-02.md`
- `docs/24_DOCUMENTATION_CODE_INSPECTION_2026-04-01.md`
- `docs/25_DOCUMENTATION_CODE_INSPECTION_2026-04-02.md`
- `docs/27_DEEP_GLOBAL_AUDIT_2026-04-02.md`
- `docs/28_DEEP_GLOBAL_AUDIT_CONTINUATION_2026-04-02.md`
- `docs/29_DEEP_GLOBAL_AUDIT_CONTINUATION_2026-04-03.md`
- `docs/31_GLOBAL_AUDIT_2026-04-07.md`
- `docs/32_MULTI_AGENT_INSPECTION_AND_OPTIMIZATION_PLAN_2026-04-07.md`
- `docs/33_DOCUMENTATION_INSPECTION_AND_COORDINATION_2026-04-07.md`

### 2.6 Archive layer

- `docs/archive/*` — только legacy/история, не использовать как SoT.

---

## 3) Правила размещения новых документов

1. **Новый канон**: только в SoT layer (`12A–12E`, `13`, `14`, `17`).
2. **Текущая реализация Daily Life**: только в Runtime layer (`12B_*`, `26_*`).
3. **Процесс/координация/решения**: только в Governance layer.
4. **Инспекции и snapshot-отчёты**: только в Audit layer + обязательная ссылка из `30_AUDIT_AND_INSPECTION_INDEX.md`.
5. **Старые версии**: переносить в `docs/archive/` с пометкой `legacy`.

## 4) Минимальный anti-chaos DoD для документации

Перед merge любой doc-задачи:

- [ ] Документ добавлен в соответствующий слой этого реестра.
- [ ] Обновлён `docs/library/DOMAIN_INDEX.md`, если появился новый primary source.
- [ ] Обновлён `docs/00_PROJECT_LIBRARY.md` или `docs/12_MASTER_PLAN.md`, если изменился маршрут чтения.
- [ ] Для мультиагентной работы внесена короткая запись в `docs/26_AGENT_COMMUNICATION_LOG.md`.
