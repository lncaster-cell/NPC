# Ambient Life v2 — Project Library

Дата: 2026-04-11  
Статус: active routing layer

## 1) Роль документа
`00_PROJECT_LIBRARY.md` — служебный навигатор документации.
Он не дублирует механику и вторичен относительно SoT-слоя (`17`, `12A–12E`, `13`, `14`).

## 2) Единый порядок чтения (канонический)
1. `README.md`
2. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
3. `docs/runtime/06_SYSTEM_INVARIANTS.md`
4. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
5. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
6. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`
7. Профильные SoT-документы: `12A`, `12C`, `12D`, `12E`, `13`, `14`, `17`

## 3) Routing-правила
- Меняется high-level канон и междоменные связи → `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`.
- Меняется Daily Life концепция/границы → `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`.
- Меняется runtime-инвариант или baseline → `docs/runtime/06_SYSTEM_INVARIANTS.md` и `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`.
- Меняется реализационный протокол шагов → `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`.
- Меняется процесс разработки/приоритеты → `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`.
- Меняется решение/компромисс → `docs/governance/10_DECISIONS_LOG.md`.

## 4) Правила «без хаоса»
- Не создавать новый «главный документ» вместо существующих SoT.
- Не заводить новые digest-файлы для дублирования текущего статуса.
- Не держать устаревшие ссылки на несуществующие пути (например, `scripts/daily_life/`, если фактический путь — `daily_life/`).
- Не смешивать owner-facing краткое объяснение и инженерную спецификацию в одном документе.
- Любой runtime-шаг закрывать синхронной правкой документации.

## 5) Мини-чеклист перед merge
- [ ] Сверены ссылки на фактические файлы в `daily_life/`.
- [ ] Обновлены даты и статусы в затронутых docs.
- [ ] Обновлён `docs/library/DOCUMENT_REGISTRY.md`, если менялась структура.
- [ ] Зафиксирован краткий след в governance-журнале, если задача была мультиагентной.
