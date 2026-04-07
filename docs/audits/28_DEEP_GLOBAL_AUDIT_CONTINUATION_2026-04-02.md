# Продолжение глубокого всеобщего аудита — 2026-04-02 (Phase 2)

Дата: 2026-04-02  
Аудитор: Codex  
Связанный отчёт: `docs/audits/27_DEEP_GLOBAL_AUDIT_2026-04-02.md`

---

## 1) Цель Phase 2

Уточнить предыдущий «глобальный» аудит количественно:  
- где именно остаются legacy-ссылки на `ambient_life`;  
- насколько покрывается `al_* -> dl_*` простым rename;  
- какие документы нужно править в первую очередь, чтобы быстро снизить риск drift.

---

## 2) Инвентаризация legacy-ссылок (факт)

### 2.1 Файлы с прямым `scripts/ambient_life`

На текущем проходе найдено **11** markdown-файлов с прямым упоминанием `scripts/ambient_life`:

1. `docs/runtime/07_SCENARIOS_AND_ALGORITHMS.md`
2. `docs/runtime/10_NPC_RESPAWN_MECHANICS.md`
3. `docs/canon/12A_WORLD_MODEL_CANON.md`
4. `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`
5. `docs/canon/12C_PLAYER_PROPERTY_SYSTEM.md`
6. `docs/canon/12D_WORLD_TRAVEL_CANON.md`
7. `docs/governance/16_IDEA_INVENTORY_AND_SYNC_MAP.md`
8. `docs/runtime/06_SYSTEM_INVARIANTS.md`
9. `docs/library/IDEA_CARD_TEMPLATE.md`
10. `docs/audits/24_DOCUMENTATION_CODE_INSPECTION_2026-04-01.md`
11. `docs/audits/27_DEEP_GLOBAL_AUDIT_2026-04-02.md` (как ссылка на обнаруженную проблему)

### 2.2 Файлы с явными `al_*.nss`-именами

Найдено **5** документов, где перечисляются legacy runtime-файлы `al_*.nss`:

- `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`
- `docs/runtime/07_SCENARIOS_AND_ALGORITHMS.md`
- `docs/governance/16_IDEA_INVENTORY_AND_SYNC_MAP.md`
- `docs/runtime/10_NPC_RESPAWN_MECHANICS.md`
- `docs/runtime/12B_DAILY_LIFE_V1_ACTIVITY_ANIMATION_REFERENCE.md`

Уникальных legacy имён `al_*.nss`: **39**.

---

## 3) Проверка «простого rename» (`al_ -> dl_`)

Сопоставление выполнено механически: `al_xxx.nss` -> `dl_xxx.nss`, затем проверка наличия файла в `scripts/daily_life/`.

Итог:
- Всего проверено legacy имён: **39**.
- Прямое совпадение после rename: **4**.
  - `al_activity_inc.nss -> dl_activity_inc.nss`
  - `al_area_inc.nss -> dl_area_inc.nss`
  - `al_area_tick.nss -> dl_area_tick.nss`
  - `al_schedule_inc.nss -> dl_schedule_inc.nss`
- Не совпало/отсутствует в текущем runtime: **35**.

Вывод: drift не сводится к простому массовому префикс-rename; нужен ручной mapping-слой «legacy design names -> Milestone A runtime files/модули».

---

## 4) Runtime-текущая база (контрольная точка)

Каталог `scripts/daily_life/` содержит **21** `.nss` файл.  
Проверка include-цепочек по этим 21 файлам в данном проходе: **0 missing include**.

Это подтверждает, что основная проблема остаётся документационной (navigation/spec sync), а не структурной целостностью скриптового каталога.

---

## 5) Приоритетная программа правок (конкретизация)

### Wave A (операционный минимум, 1 проход)

Обновить обзорные/операционные документы, которые чаще всего открываются в ежедневной работе:
1. `README.md` (краткая оговорка про legacy-имена + ссылка на mapping).
2. `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` (главный список runtime-файлов).
3. `docs/runtime/07_SCENARIOS_AND_ALGORITHMS.md` (runtime-разделы с `al_*`).
4. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` (добавить ссылку на mapping appendix при необходимости).

### Wave B (канон/рамки)

5. `docs/canon/12A_WORLD_MODEL_CANON.md`, `docs/canon/12C_PLAYER_PROPERTY_SYSTEM.md`, `docs/canon/12D_WORLD_TRAVEL_CANON.md` — привести scope-блоки к `scripts/daily_life/*` или нейтральной формулировке без жёсткого path.
6. `docs/runtime/06_SYSTEM_INVARIANTS.md` и `docs/library/IDEA_CARD_TEMPLATE.md` — убрать legacy путь из инвариантов/шаблонов.

### Wave C (архив/история)

7. `docs/audits/24_DOCUMENTATION_CODE_INSPECTION_2026-04-01.md` оставить как исторический артефакт, но добавить короткую пометку «legacy references preserved intentionally».

---

## 6) Рекомендуемый артефакт закрытия

Чтобы не «размазывать» замену по десяткам файлов вслепую, рекомендуется сначала создать отдельный документ:

- `docs/runtime/12B_DAILY_LIFE_V1_LEGACY_TO_RUNTIME_MAPPING.md`

Минимальное содержимое mapping-документа:
1. Таблица `legacy name / legacy role / current file / status (implemented|merged|dropped|vNext)`.
2. Правило обратной совместимости для чтения старых design-доков.
3. Дата последней валидации mapping-таблицы.

---

## 7) Итог Phase 2

Предыдущий вердикт подтверждён количественно:  
- документационный legacy drift — системный и широкий;  
- прямой `al_ -> dl_` rename покрывает только малую долю ссылок (4/39);  
- для безопасной синхронизации нужен отдельный mapping-артефакт и волновой план обновления документов.
