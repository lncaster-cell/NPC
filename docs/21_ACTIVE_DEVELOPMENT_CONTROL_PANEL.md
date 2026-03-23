# Ambient Life v2 — Active Development Control Panel

Дата: 2026-03-22  
Статус: active execution control panel  
Роль: единая рабочая точка входа для соло-разработки в фазе активной реализации

---

## 1) Зачем нужен этот файл

Репозиторий проекта содержит сильную дизайн-базу, но исторически развивался как documentation/design library. Для перехода в режим активной реализации нужен один операционный файл, который отвечает не на вопрос «как устроен весь проект в идеале», а на вопрос:

**что сейчас является каноном, что уже можно кодить, что пока отложено, и какие решения должен принять владелец проекта.**

Этот файл не заменяет доменные SoT-документы. Его задача — связать их в понятный рабочий контур для одного разработчика.

---

## 2) Текущая фаза проекта

### Текущая фаза
- **Phase:** transition from design mode to active development
- **Главная цель фазы:** убрать навигационный хаос, зафиксировать один активный implementation target и не расползтись по всем доменам сразу
- **Текущий implementation target:** `Daily Life v1 — Milestone A`

### Что это означает practically
С этого момента репозиторий должен использоваться так:
1. сначала проверяется, какой документ является source of truth;
2. затем определяется, относится ли задача к текущему активному implementation target;
3. если да — задача превращается в кодовый или документарный шаг backlog;
4. если нет — задача либо откладывается, либо фиксируется как owner-decision / future milestone.

---

## 3) Нормальный маршрут чтения и работы

### Для общего понимания проекта
1. `README.md`
2. `docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`
3. `docs/12_MASTER_PLAN.md`

### Для ежедневной активной работы
1. `docs/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` ← этот файл
2. `docs/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`
3. `docs/12B_DAILY_LIFE_V1_IMPLEMENTATION_SLICE.md`
4. `docs/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
5. `scripts/daily_life/`

### Если возникает конфликт формулировок
Приоритет для текущей фазы:
1. профильный canonical document / SoT;
2. inspection patch / accepted DEC;
3. этот control panel;
4. старые overview / archived draft документы.

---

## 4) Карта статусов документов

### 4.1 Главные канонические документы
- `docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md` — общий канон проекта
- `docs/12A_WORLD_MODEL_CANON.md` — world/legal канон
- `docs/12B_RUNTIME_MASTER_PLAN.md` — runtime и daily-life/runtime границы
- `docs/12C_PLAYER_PROPERTY_SYSTEM.md` — property
- `docs/12D_WORLD_TRAVEL_CANON.md` — travel
- `docs/12E_TRADE_AND_CITY_STATE_CANON.md` — trade/city-state
- `docs/13_AGING_AND_CLAN_SUCCESSION.md` — aging/succession
- `docs/14_CLAN_SYSTEM_DESIGN.md` — clans

### 4.2 Активные implementation-документы для текущего спринта
- `docs/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`
- `docs/12B_DAILY_LIFE_V1_IMPLEMENTATION_SLICE.md`
- `docs/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
- `docs/12B_DAILY_LIFE_V1_RULESET_REV1.md`
- `docs/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
- `docs/12B_DAILY_LIFE_V1_INSPECTION_PATCH.md`

### 4.3 Служебные / навигационные документы
- `README.md`
- `docs/12_MASTER_PLAN.md`
- `docs/architecture/01_PROJECT_PASSPORT.md`
- `docs/architecture/02_OPEN_DESIGN_QUESTIONS.md`
- `docs/10_DECISIONS_LOG.md`

### 4.4 Архивные / redirect-only документы
Эти файлы не должны использоваться как стартовая точка для новых правок по механикам:
- `docs/01_PROJECT_OVERVIEW.md`
- `docs/legal_system_design.md`

---

## 5) Активный implementation scope

### Сейчас разрешено делать
- реализацию и полировку `Daily Life v1 — Milestone A`;
- закрытие шагов A–E из checklist;
- правки в `scripts/daily_life/`, если они прямо работают на Milestone A;
- правки в implementation docs, если они устраняют неоднозначность текущего спринта;
- создание smoke/acceptance проверок под Milestone A сценарии.

### Сейчас запрещено расползаться вширь
- не начинать параллельно полную legal/court реализацию;
- не пытаться сразу построить полную population/respawn систему;
- не уходить в богатые cross-domain интеграции trade / travel / clan;
- не открывать новый большой milestone, пока Milestone A не доведён до проверяемого состояния.

---

## 6) Definition of Done для перехода к активной кодовой фазе

Репозиторий считается переведённым в управляемую активную фазу, если одновременно выполнены условия:
- есть один понятный текущий implementation target;
- есть один понятный рабочий файл-контроллер (этот документ);
- видно, какие документы канонические, какие служебные, какие архивные;
- backlog текущего milestone можно читать без археологии по всему репозиторию;
- открытые вопросы разделены на `block now` и `defer`;
- разработчик не обязан перечитывать весь проект, чтобы понять следующий шаг.

---

## 7) Текущий backlog: Daily Life v1 — Milestone A

### 7.1 Уже выглядит собранным на каркасном уровне
- Step A: constants / helper-access foundation
- Step B: schedule + override + resolver skeleton
- Step C: anchor / materialization / interaction skeleton
- Step D: area-tier / worker / resync skeleton
- Step E: slot handoff stub

### 7.2 Что нужно довести в первую очередь
1. провести checklist acceptance по Step A–E и отметить, что реально подтверждено, а что пока только "есть в коде";
2. добавить минимальный verification path для сценариев кузнеца, постового, трактирщика и override;
3. добить явные stub-зоны (`base lost`, `slot handoff`) до безопасного, но проверяемого состояния;
4. убедиться, что `dialogue_mode` и `service_mode` меняются не только по коду, но и по сценариям;
5. зафиксировать, какие family/subtype реально входят в first playable slice.

### 7.3 Что не является blocker для текущего спринта
- camp owner-domain;
- полная legal procedure детализация;
- world travel consequence matrix;
- rich trade/city-state integration;
- все вторичные семейства NPC beyond first slice.

---

## 8) Owner decisions: что должен решить владелец проекта

Ниже перечислены вопросы, по которым проекту нужен не «технический рефакторинг», а именно решение владельца замысла.

### Решение O-01 — Первый playable slice Daily Life
Нужно подтвердить, что первый реально доводимый slice остаётся таким:
- families: `LAW`, `CRAFT`, `TRADE_SERVICE`;
- directives: `SLEEP`, `WORK`, `SERVICE`, `DUTY`;
- один обязательный override: `QUARANTINE` **или** `FIRE`.

**Рекомендуемое решение:** оставить именно этот slice без расширения до завершения Milestone A.

### Решение O-02 — Базовый override для milestone smoke path
Для первой волны проверок нужно выбрать primary override:
- `QUARANTINE` — лучше для controlled suppression/service gating;
- `FIRE` — лучше для жёсткой emergency-ветки.

**Рекомендуемое решение:** взять `QUARANTINE` как основной smoke path, а `FIRE` держать вторым сценарием.

### Решение O-03 — Граница Daily Life vs City Response
Нужно подтвердить практическое правило текущей реализации:
- Daily Life имеет право на локальные мягкие отклонения;
- подтверждённый серьёзный инцидент должен передаваться в City Response, а не разрастаться внутри Daily Life.

**Рекомендуемое решение:** считать это правилом текущего спринта без попытки полностью канонизировать матрицу порогов прямо сейчас.

### Решение O-04 — Что считать достаточным подтверждением готовности Milestone A
Нужно выбрать целевой формат проверки:
- только manual smoke checklist;
- scripted smoke runs;
- scripted smoke runs + журнал ожидаемых состояний.

**Рекомендуемое решение:** scripted smoke runs + журнал ожидаемых состояний.

---

## 9) Технические blockers vs deferred questions

### Block now
- нет формального журнала подтверждения acceptance по Milestone A;
- нет одного файла, где сведены owner decisions для текущего implementation target;
- часть milestone-level логики остаётся в stub-safe состоянии и требует явной пометки как подтверждённая или временная.

### Defer
- большие междоменные consequence-матрицы;
- глубокая legal procedure automation;
- полная population ecology;
- расширенный набор социальных и политических suppressions.

---

## 10) Рабочее правило для всех следующих правок

Если новая задача:
1. не двигает `Daily Life v1 — Milestone A`,
2. не закрывает owner-decision,
3. не устраняет навигационный или implementation blocker,

то она по умолчанию **не относится к текущему активному спринту** и должна быть либо отложена, либо отдельно обоснована.

---

## 11) Следующий рекомендуемый шаг после этого cleanup

Следующий практический шаг разработки:

**создать и прогнать минимальный verification/inspection цикл для Milestone A, чтобы отделить “код существует” от “код подтверждён сценарием”.**

После этого можно переходить к целевым правкам `scripts/daily_life/` уже без организационного тумана.
