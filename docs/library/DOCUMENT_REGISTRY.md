# Document Registry — Ambient Life v2

Дата: 2026-04-09
Статус: active

## Цель
Единый реестр слоёв документации, чтобы не терять актуальность и не дублировать SoT.

## 1) Слои документации (порядок чтения)
1. **Entry layer** — быстрый вход.
2. **SoT layer** — канонические доменные документы.
3. **Runtime layer** — текущая реализация и эксплуатационный контур Daily Life.
4. **Governance layer** — управление разработкой и решения.
5. **Audit layer** — проверочные снимки и инспекции.
6. **Archive layer** — legacy/история.

---

## 2) Реестр по слоям

### 2.1 Entry layer
- `README.md`
- `docs/entry/00_PROJECT_LIBRARY.md`
- `docs/entry/12_MASTER_PLAN.md`
- `docs/library/DOMAIN_INDEX.md`

### 2.2 SoT layer
- `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`
- `docs/canon/12A_WORLD_MODEL_CANON.md`
- `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- `docs/canon/12C_PLAYER_PROPERTY_SYSTEM.md`
- `docs/canon/12D_WORLD_TRAVEL_CANON.md`
- `docs/canon/12E_TRADE_AND_CITY_STATE_CANON.md`
- `docs/canon/13_AGING_AND_CLAN_SUCCESSION.md`
- `docs/canon/14_CLAN_SYSTEM_DESIGN.md`

### 2.3 Runtime layer
- `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
- `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
- `docs/runtime/42_DAILY_LIFE_V2_REPOSITORY_RESET_LOG_RU.md`
- `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
- `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`
- `docs/runtime/06_SYSTEM_INVARIANTS.md`
- `docs/runtime/12B_DAILY_LIFE_V1_SOURCE_OF_TRUTH.md`
- `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
- прочие `docs/runtime/12B_*`, `26_*`, `35_*`, `02_*`, `03_*`, `04_*`, `07_*`, `10_*`, `22_*`

### 2.4 Governance layer
- `docs/governance/10_DECISIONS_LOG.md`
- `docs/governance/16_IDEA_INVENTORY_AND_SYNC_MAP.md`
- `docs/governance/18_REBUILD_RESET_CONTEXT.md`
- `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`
- `docs/governance/24_PARALLEL_AGENT_COORDINATION_BOARD.md`
- `docs/governance/26_AGENT_COMMUNICATION_LOG.md`
- `docs/architecture/01_PROJECT_PASSPORT.md`
- `docs/architecture/02_OPEN_DESIGN_QUESTIONS.md`
- `docs/24_PARALLEL_AGENT_COORDINATION_BOARD.md` *(redirect stub)*
- `docs/26_AGENT_COMMUNICATION_LOG.md` *(redirect stub)*

### 2.5 Audit layer
- `docs/audits/30_AUDIT_AND_INSPECTION_INDEX.md` (главный вход)
- все `docs/audits/*.md` по датированным инспекциям

### 2.6 Archive layer
- `docs/archive/*`
- `archive/daily_life_v1_legacy/*`

---

## 3) Правила размещения новых документов
1. Канон и доменные правила — только в SoT layer.
2. Текущая реализация Daily Life — только в Runtime layer.
3. Процесс/координация/решения — только в Governance layer.
4. Инспекции — только в Audit layer + ссылка из `30_AUDIT_AND_INSPECTION_INDEX.md`.
5. Устаревшие версии — перенос в Archive layer с пометкой `legacy`.

## 4) Anti-chaos DoD для документации
- [ ] Ссылки в обновлённых файлах ведут на существующие артефакты.
- [ ] Изменённые документы учтены в реестре и индексах.
- [ ] Runtime-факты согласованы с фактическим содержимым `scripts/daily_life/`.
- [ ] В governance-слое отражён текущий этап работы.
