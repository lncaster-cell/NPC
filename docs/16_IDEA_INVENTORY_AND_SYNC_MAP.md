# Ambient Life v2 — Карта идей и синхронизации (чтобы не перепридумывать)

Дата: 2026-03-14  
Статус: Active  
Назначение: быстрый реестр «что уже придумано», где это зафиксировано и в каком статусе находится.

---

## 1) Как пользоваться этим файлом

1. Перед любым новым дизайном сначала проверить этот реестр.
2. Если идея уже есть — дорабатываем существующую формулировку, а не создаём параллельную.
3. Если идеи нет — добавляем новую строку в раздел 2 и связываем с профильным документом.

**Правило:** один тип знания = один главный документ-источник, остальные документы только ссылаются.

## 1.1) Быстрый ответ «система уже есть или нет?»

Если нужно быстро понять статус конкретной идеи (например: свидетели, переходы, лагерь, торговля), смотри сначала эту таблицу.

**Легенда статусов:**
- **Реализовано** — механика уже присутствует в runtime/scripts.
- **Канон (дизайн)** — спецификация утверждена, но это не гарантия runtime-реализации.
- **Planned / Draft / Концепт** — идея зафиксирована, но не доведена до production.
- **Нет в каноне** — в текущих документах тема не оформлена как отдельная система.

| Система/идея | Текущий статус | Где смотреть в первую очередь | Примечание |
|---|---|---|---|
| Свидетели преступления (witness) | Канон (дизайн) + частично planned pipeline | `docs/12A_WORLD_MODEL_CANON.md`, `docs/08_STAGE_I3_TRACKER.md` | Связана с crime/alarm/legal chain; полноценный end-to-end в I.3 ещё planned |
| Переходы между зонами (transition) | Реализовано (Stage I.2) | `docs/02_MECHANICS.md` | Входит в бытовой pipeline Route → Transition → Activity/Sleep |
| Лагерь (camp) как отдельная система | Нет в каноне | — | Может существовать как контентный паттерн, но не выделен как отдельный системный блок |
| Торговля (trade/economy) как отдельная система | Нет в каноне | — | На текущем этапе не оформлена как самостоятельный runtime/legal subsystem |

> Если пункта нет в таблице выше, добавь его сюда в первую очередь, а уже потом расширяй общий реестр.

## 2) Реестр идей (по областям)

| Область | Что уже придумано | Статус | Главный источник | Связанные документы |
|---|---|---|---|---|
| Архитектурный каркас runtime | Area-centric orchestration вместо per-NPC heartbeat; event-driven bus; bounded budgets/caps | Реализовано (база) | `docs/12B_RUNTIME_MASTER_PLAN.md` | `docs/06_SYSTEM_INVARIANTS.md`, `docs/03_OPERATIONS.md` |
| Границы ответственности | Жёсткое разделение content vs runtime; запрет ручной правки runtime locals как «лечения» | Канон (обязательный) | `docs/04_CONTENT_CONTRACTS.md` | `README.md`, `docs/12B_RUNTIME_MASTER_PLAN.md` |
| Поведение NPC (бытовой цикл) | Route + transition + sleep + activity + schedule как единый pipeline | Реализовано (Stage I.2) | `docs/02_MECHANICS.md` | `docs/07_SCENARIOS_AND_ALGORITHMS.md`, `docs/05_STATUS_AUDIT.md` |
| Реактивный слой | Disturbed/blocked реакция с безопасным возвратом в routine | Реализовано (Stage I.2) | `docs/02_MECHANICS.md` | `docs/07_SCENARIOS_AND_ALGORITHMS.md`, `docs/03_OPERATIONS.md` |
| Городской контур | Crime + alarm FSM + role assignments, с деэскалацией `active -> recovery -> normal` | Реализовано (Stage I.2) | `docs/12B_RUNTIME_MASTER_PLAN.md` | `docs/02_MECHANICS.md`, `docs/03_OPERATIONS.md` |
| Популяция города | Respawn unnamed населения по policy (таргеты/бюджеты/cooldowns) | Реализовано | `docs/10_NPC_RESPAWN_MECHANICS.md` | `docs/05_STATUS_AUDIT.md`, `docs/12B_RUNTIME_MASTER_PLAN.md` |
| Legal/world-модель | 3 слоя: NWN2 engine signals + persistent world + project legal logic; не подменять закон фракциями | Канон (приоритет) | `docs/12A_WORLD_MODEL_CANON.md` | `docs/01_PROJECT_OVERVIEW.md`, `README.md` |
| Закон и правоприменение | LawProfile, режимы закона, citizenship/titles/documents, crime/witness/alarm связка | Канон (дизайн) | `docs/12A_WORLD_MODEL_CANON.md` | `docs/14_CLAN_SYSTEM_DESIGN.md` |
| Stage I.3 Reinforcement | Бounded policy подкреплений/guards без world-wide scan | Planned | `docs/08_STAGE_I3_TRACKER.md` | `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` |
| Stage I.3 Legal pipeline | Surrender -> arrest -> legal followup/trial как конечная цепочка | Planned | `docs/08_STAGE_I3_TRACKER.md` | `docs/09_LEGAL_REINFORCEMENT_SMOKE.md`, `docs/12A_WORLD_MODEL_CANON.md` |
| Stage I.3 QA | Отдельный smoke-runbook для legal/reinforcement | Draft (готов к применению) | `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` | `docs/03_OPERATIONS.md`, `docs/08_STAGE_I3_TRACKER.md` |
| Журнал решений | Обязательная фиксация архитектурных решений/компромиссов (DEC-формат) | Active | `docs/10_DECISIONS_LOG.md` | `docs/15_DOCUMENTATION_INSPECTION_2026-03-14.md` |
| Система имущества игрока | Ownership/title/rights and constraints как отдельный дизайн-блок | Канон (дизайн) | `docs/12C_PLAYER_PROPERTY_SYSTEM.md` | `docs/12A_WORLD_MODEL_CANON.md` |
| Система travel | Node/edge world travel, land/sea pipelines, event encounters, engine limits | Канон (дизайн) | `docs/12D_WORLD_TRAVEL_CANON.md` | `docs/03_OPERATIONS.md` |
| Старение и наследование (v1) | Возрастной цикл + смерть + клановый transfer имущества/статуса | Концепт v1 (отдельная ветка дизайна) | `docs/13_AGING_AND_CLAN_SUCCESSION.md` | `docs/14_CLAN_SYSTEM_DESIGN.md` |
| Дизайн системы кланов | Клановая структура, роли, эволюция, социальная динамика | Концепт/дизайн-блок | `docs/14_CLAN_SYSTEM_DESIGN.md` | `docs/13_AGING_AND_CLAN_SUCCESSION.md` |

### 2.1) Явно не покрыто как отдельные системы (чтобы не искать по кругу)

| Тема | Статус | Комментарий |
|---|---|---|
| Camp / лагеря (как системный модуль) | Не оформлено | Нет выделенного canon/design документа под отдельную camp-систему |
| Trade / экономика / торговые циклы (как системный модуль) | Не оформлено | Нет выделенного canon/design документа под отдельную trade-систему |

## 3) Что уже «придумано окончательно» (не переизобретать)

1. Базовая runtime-архитектура: area-centric + event-driven + bounded.
2. Набор инвариантов (запрет per-NPC heartbeat и world-wide full-scan).
3. Разделение content/runtime и контрактная дисциплина locals/events.
4. Канон legal/world слоя: фракции = тактика ИИ, а не правовая модель государства.
5. Структура мастер-пакета: `12_MASTER_PLAN` как индекс + тематические тома `12A–12D`.

## 4) Что ещё не придумано «до конца» (чтобы фокусироваться)

1. Stage I.3 в статусе Planned: reinforcement policy, legal end-to-end pipeline, последствия инцидентов.
2. Полная эксплуатационная матрица для I.3 (после старта этапа расширяется из smoke-runbook).
3. Прикладная интеграция кланового/возрастного блока с legal/world каноном (на уровне roadmap, не runtime-факта).

## 5) Анти-дублирование: куда вносить изменения

- Меняем механику runtime → сначала `docs/02_MECHANICS.md`, затем синхронизация в `12B`.
- Меняем эксплуатацию/валидацию → сначала `docs/03_OPERATIONS.md`, затем `09`/`12B`.
- Меняем контракты данных → сначала `docs/04_CONTENT_CONTRACTS.md`, затем `12B`.
- Меняем legal/world канон → `12A` как первичный источник, остальные документы только выравниваются.
- Новое архитектурное решение → фиксируем в `10_DECISIONS_LOG.md`.

## 6) Мини-чек перед новой идеей

1. Есть ли уже похожая идея в разделе 2?  
2. Если да, в чём именно gap, а не «новая параллельная версия»?  
3. Обновлён ли главный документ-источник?  
4. Добавлена ли запись в `10_DECISIONS_LOG.md`, если решение архитектурное?
