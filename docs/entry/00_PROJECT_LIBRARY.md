# Ambient Life v2 — Project Library

Дата: 2026-04-09  
Статус: active routing layer

## 1) Роль документа
`00_PROJECT_LIBRARY.md` — служебный навигатор документации.
Он не дублирует механику и вторичен относительно SoT-слоя (`17`, `12A–12E`, `13`, `14`).

## 2) Рекомендуемый порядок чтения
1. `README.md`
2. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`
3. `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
5. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
6. Профильные SoT-документы: `12A–12E`, `13`, `14`, `17`

## 3) Routing-правила
- Меняется high-level канон и междоменные связи → `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`.
- Меняется Daily Life концепция/границы → `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`.
- Меняется актуальная реализация v2 → `docs/runtime/40_*`, `41_*`, `43_*`, и профильные runtime-спеки.
- Меняется процесс разработки/приоритеты → `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`.
- Меняется решение/компромисс → `docs/governance/10_DECISIONS_LOG.md`.

## 4) Правила «без хаоса»
- Не создавать новый «главный документ» вместо существующих SoT.
- Не держать устаревшие ссылки на несуществующие runtime-файлы.
- Не смешивать owner-facing краткое объяснение и инженерную спецификацию в одном документе.
- Любой runtime-шаг закрывать синхронной правкой документации.

## 5) Мини-чеклист перед merge
- [ ] Сверены ссылки на фактические файлы в `scripts/daily_life/`.
- [ ] Обновлены даты и статусы в затронутых docs.
- [ ] Обновлён `docs/library/DOCUMENT_REGISTRY.md`, если менялась структура.
- [ ] Зафиксирован краткий след в governance-журнале, если задача была мультиагентной.
