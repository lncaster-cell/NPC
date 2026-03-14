# Ambient Life v2 — Documentation Reorganization Plan (design-library mode)

Дата: 2026-03-14  
Статус: proposed  
Режим: documentation-only / design-only

---

## текущее состояние документации

Проект уже зафиксирован как documentation-first: код прошлой итерации удалён, документация является единственным рабочим носителем замысла. Текущая база содержит сильные канонические тома по отдельным доменам (`12A–12E`), обзор (`README`), индекс (`12_MASTER_PLAN`), журнал решений (`10_DECISIONS_LOG`), инвентарь/карты синхронизации (`16`, `15`), а также отдельные design-документы (`13`, `14`).

Ключевая проблема не в отсутствии материалов, а в **перекрытии ролей**:
- часть документов одновременно пытается быть и каноном, и onboard-обзором, и roadmap;
- домены «клан/наследование» пока не встроены в общий `12*`-канон на тех же правах, что property/travel/trade;
- governance-документы (inspection/inventory/index) местами пересекаются по функции;
- есть разрыв между «где domain primary source» и «где оперативно искать открытые вопросы по domain».

### Типы документов (целевая классификация)

1. **overview**
   - Назначение: объяснить «что это за проект» и его системную формулу.
   - Документ: `README.md`.

2. **master index / navigation**
   - Назначение: вести читателя по канону, а не переобъяснять его.
   - Документы: `docs/12_MASTER_PLAN.md`, `docs/00_PROJECT_LIBRARY.md`, `docs/library/DOMAIN_INDEX.md`.

3. **domain canon**
   - Назначение: нормативка по конкретному домену (single source of truth).
   - Документы: `docs/12A_WORLD_MODEL_CANON.md`, `docs/12B_RUNTIME_MASTER_PLAN.md`, `docs/12C_PLAYER_PROPERTY_SYSTEM.md`, `docs/12D_WORLD_TRAVEL_CANON.md`, `docs/12E_TRADE_AND_CITY_STATE_CANON.md`.

4. **inventory / sync map**
   - Назначение: карта идей, связей, конфликтов и статусов; не канон.
   - Документы: `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md`, `docs/15_DOCUMENTATION_INSPECTION_2026-03-14.md` (частично, как аудит-срез).

5. **decisions log**
   - Назначение: фиксировать архитектурные решения и их последствия.
   - Документ: `docs/10_DECISIONS_LOG.md`.

6. **tracker / smoke / frontier docs**
   - Назначение: контроль прогресса, проверки, пограничные/экспериментальные срезы; не source of truth.
   - Документы (по ссылкам в индексах): `docs/08_STAGE_I3_TRACKER.md`, `docs/09_LEGAL_REINFORCEMENT_SMOKE.md`, частично status-audit документы.

### Матрица ролей по ключевым документам

| Документ | Фактическая роль сейчас | Правильная роль | Пересечения | Риск дублирования |
|---|---|---|---|---|
| `README.md` | Обзор + вход в архитектуру + краткая карта систем | Только overview/passport | Пересекается с `12B` (runtime summary), `12A` (world/legal summary) | Средний: повтор канонических тезисов |
| `docs/12_MASTER_PLAN.md` | Индекс `12*` + политика синхронизации | Master index / navigation | Пересекается с `00_PROJECT_LIBRARY` и `DOMAIN_INDEX` | Низкий/средний: двойная навигация |
| `docs/12A_WORLD_MODEL_CANON.md` | Полный world/legal canon | Domain canon (Legal/World + Witness/Crime/Arrest/Trial) | Пересекается с `12C`, `14`, `12E` | Средний: захват соседних доменов правовыми формулировками |
| `docs/12B_RUNTIME_MASTER_PLAN.md` | Runtime canon + operations + roadmap + FAQ | Domain canon (NPC Daily Life + City Response runtime) + ссылки на ops | Пересекается с `README`, tracker/smoke | Высокий: canon и delivery в одном томе |
| `docs/12C_PLAYER_PROPERTY_SYSTEM.md` | Канон domain property | Domain canon (Player Property) | Пересекается с `12A`, `12E`, `14` | Средний: юридические и клановые границы |
| `docs/12D_WORLD_TRAVEL_CANON.md` | Канон domain travel | Domain canon (World Travel) | Пересекается с `12A`, `12E`, `12B` | Средний |
| `docs/12E_TRADE_AND_CITY_STATE_CANON.md` | Канон trade/city-state | Domain canon (Trade/City State) | Пересекается с `12B` (respawn/city), `12A` (law/order), `12C` | Средний/высокий: пересечение city-response и economy |
| `docs/13_AGING_AND_CLAN_SUCCESSION.md` | Специализированный design-док | Domain canon supplement (Aging/Succession) с явной привязкой к Clan domain | Пересекается с `14` | Высокий: два центра по succession/clan |
| `docs/14_CLAN_SYSTEM_DESIGN.md` | Широкий клановый design-том | Domain canon (Clan System) | Пересекается с `13`, `12A`, `12C` | Высокий |
| `docs/15_DOCUMENTATION_INSPECTION_2026-03-14.md` | Аудит-срез + отчёт синхронизации | Tracker/audit snapshot | Пересекается с `16`, `10` | Средний: частично повторяет decisions |
| `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md` | Inventory/sync карта | Inventory / sync map | Пересекается почти со всеми index/governance файлами | Высокий, если начнёт содержать нормативку |
| `docs/10_DECISIONS_LOG.md` | ADR/DEC журнал | Decisions log | Пересекается с `15` и `00_PROJECT_LIBRARY` в части «что решили» | Низкий |
| `docs/library/DOMAIN_INDEX.md` | Сжатый domain-nav | Master navigation (thin index) | Пересекается с `12_MASTER_PLAN`, `00_PROJECT_LIBRARY` | Средний: риск тройной навигации |

---

## проблемы структуры

1. **Тройная навигация без жёсткой иерархии**
   - `12_MASTER_PLAN`, `00_PROJECT_LIBRARY`, `docs/library/DOMAIN_INDEX.md` выполняют близкие функции.
   - Нужна строгая лестница: passport → atlas → domain.

2. **Смешение канона и delivery-контекста**
   - Особенно заметно в runtime-томе (`12B`): архитектурный канон и planning/roadmap находятся в одном контейнере.

3. **Домен Clan/Aging split без единого владельца**
   - `13` и `14` пересекаются по succession, наследованию, семье, правовому статусу клана.

4. **Инвентарь и аудит могут дрейфовать в «квази-канон»**
   - `16` полезен как sync-map, но при расширении может начать дублировать доменные правила.

5. **Размытая граница между City Response и Trade/City State**
   - Реакции города на инциденты и экономическое состояние города пересекаются на уровне последствий и шкал.

6. **Legal/World domain перегружен**
   - `12A` охватывает world model, law, citizenship, titles, docs, crime, witness, alarm.
   - Это сильный канон, но в навигации нужен явный subdomain-map (чтобы не терялись владельцы тем).

---

## целевая структура design library

Принцип: **не giant master doc**, а библиотека с маршрутизацией по типам знания.

### 1) Atlas / Passport слой

- `README.md` → Project Passport (что за проект, формула, домены верхнего уровня).
- `docs/architecture/01_ATLAS.md` (новый, целевой) → единый входной atlas:
  - карта доменов;
  - primary source для каждого домена;
  - правила «куда вносить изменения».

### 2) Domain docs слой (source of truth)

- `docs/12A_WORLD_MODEL_CANON.md` → Legal / World Model + Witness/Crime/Arrest/Trial.
- `docs/12B_RUNTIME_MASTER_PLAN.md` → NPC Daily Life + City Response runtime-canon.
- `docs/12C_PLAYER_PROPERTY_SYSTEM.md` → Player Property.
- `docs/12D_WORLD_TRAVEL_CANON.md` → World Travel.
- `docs/12E_TRADE_AND_CITY_STATE_CANON.md` → Trade / City State.
- `docs/14_CLAN_SYSTEM_DESIGN.md` → Clan System (promote to explicit domain-canon).
- `docs/13_AGING_AND_CLAN_SUCCESSION.md` → Aging / Succession (как отдельный domain supplement, связанный с Clan).

### 3) Open Questions слой

- `docs/architecture/30_OPEN_DESIGN_QUESTIONS.md` (новый, целевой):
  - только незакрытые вопросы;
  - по каждому вопросу: домен-владелец, почему открыт, что блокирует решение;
  - без нормативных ответов.

### 4) Decisions слой

- `docs/10_DECISIONS_LOG.md` остаётся единственным журналом DEC.
- Любой закрытый вопрос из Open Questions фиксируется DEC-записью.

### 5) Navigation / Inventory слой

- `docs/architecture/01_ATLAS.md` (единый толстый навигатор).
- `docs/library/DOMAIN_INDEX.md` (тонкий индекс-таблица для быстрого перехода).
- `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md` (память/связи/статусы, но не канон).
- `docs/15_DOCUMENTATION_INSPECTION_*.md` (архивные audit snapshots).

---

## список доменов и их primary sources

Ниже — домены целевой design library и правила границ.

### 1) NPC Daily Life
- **Назначение:** повседневная симуляция NPC (lifecycle, schedule, sleep/activity, transitions).
- **Граница:** только оркестрация жизни и поведения в штатном режиме.
- **Primary source:** `docs/12B_RUNTIME_MASTER_PLAN.md`.
- **Secondary references:** `README.md`, runtime профили в docs.
- **Пересечения:** City Response, World Travel.
- **Типичная путаница:** смешение «повседневного цикла» с юридическими последствиями.

### 2) City Response
- **Назначение:** реакции города на инциденты (alarm/escalation/de-escalation, безопасность).
- **Граница:** operational response города, без полного world-law канона.
- **Primary source:** `docs/12B_RUNTIME_MASTER_PLAN.md`.
- **Secondary references:** `docs/12A_WORLD_MODEL_CANON.md`, `docs/12E_TRADE_AND_CITY_STATE_CANON.md`.
- **Пересечения:** Legal/World, Trade/City State.
- **Типичная путаница:** считать city-response частью экономики или наоборот.

### 3) Legal / World Model
- **Назначение:** мировая правовая модель (realm/settlement/law/documents/citizenship/authority).
- **Граница:** нормативка права и статусов мира.
- **Primary source:** `docs/12A_WORLD_MODEL_CANON.md`.
- **Secondary references:** `README.md`, `docs/10_DECISIONS_LOG.md`.
- **Пересечения:** Player Property, Clan System, Witness/Crime.
- **Типичная путаница:** пытаться выражать правду мира только через локальные тактические механики.

### 4) Witness / Crime / Arrest / Trial
- **Назначение:** контур преступлений, свидетелей, арестов, судебных процедур как часть правоприменения.
- **Граница:** юридические события и их доказательная/процедурная рамка.
- **Primary source:** `docs/12A_WORLD_MODEL_CANON.md`.
- **Secondary references:** `docs/12B_RUNTIME_MASTER_PLAN.md` (операционные реакции).
- **Пересечения:** City Response, Legal/World.
- **Типичная путаница:** смешение «кто увидел» (witness) и «кто имеет юрисдикцию» (law model).

### 5) Player Property
- **Назначение:** система владения активами игрока и их прав/лимитов.
- **Граница:** типы имущества, доступ, состояние, размещение, сервисы.
- **Primary source:** `docs/12C_PLAYER_PROPERTY_SYSTEM.md`.
- **Secondary references:** `docs/12A_WORLD_MODEL_CANON.md`, `docs/12E_TRADE_AND_CITY_STATE_CANON.md`.
- **Пересечения:** Legal/World, Clan, Trade.
- **Типичная путаница:** смешение личного, кланового и публично-городского владения.

### 6) World Travel
- **Назначение:** канон перемещений в мировой карте (земля/море/маршруты/ограничения).
- **Граница:** travel-логика и переходы между зонами мира.
- **Primary source:** `docs/12D_WORLD_TRAVEL_CANON.md`.
- **Secondary references:** `docs/12B_RUNTIME_MASTER_PLAN.md`, `docs/12A_WORLD_MODEL_CANON.md`.
- **Пересечения:** Player Property (судно), Trade (логистика), City Response (риски/контекст).
- **Типичная путаница:** считать travel частным случаем телепорта/локального перехода.

### 7) Trade / City State
- **Назначение:** городской макроконтур снабжения, дефицита, кризисов и влияния на мир.
- **Граница:** системное состояние города, не розничная микросимуляция каждого NPC.
- **Primary source:** `docs/12E_TRADE_AND_CITY_STATE_CANON.md`.
- **Secondary references:** `docs/12B_RUNTIME_MASTER_PLAN.md`, `docs/12A_WORLD_MODEL_CANON.md`, `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md`.
- **Пересечения:** City Response, Player Property, World Travel.
- **Типичная путаница:** смешение «экономического состояния города» и «оперативной реакции стражи».

### 8) Clan System
- **Назначение:** клан как социально-политическая сущность (игроковые и NPC-кланы, статус, отношения).
- **Граница:** структура, статус, престиж, дипломатия, представительство.
- **Primary source:** `docs/14_CLAN_SYSTEM_DESIGN.md`.
- **Secondary references:** `docs/12A_WORLD_MODEL_CANON.md`, `docs/13_AGING_AND_CLAN_SUCCESSION.md`.
- **Пересечения:** Legal/World, Aging/Succession, Player Property.
- **Типичная путаница:** смешение клана как политической сущности и клана как семейной линии.

### 9) Aging / Succession
- **Назначение:** возраст, смерть, наследование, смена поколений.
- **Граница:** жизненный цикл персонажа и перенос линий владения/власти между поколениями.
- **Primary source:** `docs/13_AGING_AND_CLAN_SUCCESSION.md`.
- **Secondary references:** `docs/14_CLAN_SYSTEM_DESIGN.md`, `docs/12A_WORLD_MODEL_CANON.md`.
- **Пересечения:** Clan, Legal/World, Player Property.
- **Типичная путаница:** где заканчивается «семейная преемственность» и начинается «политика клана».

---

## список конфликтов и дублей

### Дубли

1. Навигационный слой дублируется между `12_MASTER_PLAN`, `00_PROJECT_LIBRARY`, `DOMAIN_INDEX`.
2. Кланово-наследственный слой дублируется между `13` и `14`.
3. Часть обзорных формулировок повторяется между `README` и `12B`/`12A`.

### Противоречия/напряжения

1. `12B` одновременно позиционируется как runtime canon и как roadmap/rebuild-план.
2. `12C` имеет мета-формулировку «главный onboarding-документ проекта», что конфликтует с ролью `README`.
3. В governance уже закреплён anti-duplication, но текущая структура всё ещё допускает конкурирующие «центры входа».

### Размытые границы

1. City Response (операционное поведение) vs Trade/City State (макросостояние города).
2. Legal/World vs Witness/Crime operational flow.
3. Clan System vs Aging/Succession.
4. Player Property vs Clan ownership/authority.

### Незакрытые design gaps

1. Явная политика владения доменом: кто authoritative owner для cross-domain вопросов.
2. Формальный шаблон «Domain Charter» (назначение, граница, SoT, anti-confusion, open questions).
3. Единый список открытых design-вопросов в одном месте (сейчас распределены по разным документам).
4. Формат фиксации conflict-resolution между доменами до DEC-принятия.

### Темы, требующие отдельного решения

1. Граница между клановым имуществом и личным имуществом персонажа.
2. Юридический статус кланов в связке с правовой моделью поселений.
3. Связь travel и городского снабжения (что является предметом travel-канона, а что trade-канона).
4. Как связывать city alarm/escalation с городскими шкалами кризиса без смешения доменов.
5. Модель «арест/суд» как отдельный поддомен внутри legal canon или как самостоятельный canon-док.

---

## список открытых design questions

1. Нужен ли отдельный канонический том для `Witness/Crime/Arrest/Trial`, или это остаётся поддоменом `12A`?
2. Нужен ли отдельный канонический том для `City Response`, если runtime- и world-аспекты продолжают расширяться?
3. Где проходит каноническая граница между `Clan System` и `Aging/Succession` по вопросам наследования власти/активов?
4. Что является первичным при конфликте: правовой статус (`12A`) или клановый статус (`14`) для прав на собственность (`12C`)?
5. Как избежать эволюции `16_IDEA_INVENTORY_AND_SYNC_MAP.md` в «теневой канон»?
6. Нужна ли единая терминологическая глоссарная страница (одно определение на термин для всех доменов)?
7. Должны ли все domain-документы иметь стандартный раздел `Out of Scope` для анти-дублирования?

---

## рекомендуемый порядок наведения порядка

1. **Шаг 1 — Утвердить архитектуру библиотеки**
   - Принять эту схему как организационный план документации.

2. **Шаг 2 — Зафиксировать единый Atlas**
   - Создать `docs/architecture/01_ATLAS.md` как главный навигационный узел.
   - Свести `12_MASTER_PLAN` к роли индекса пакета `12*` без мета-навигации уровня всей библиотеки.

3. **Шаг 3 — Развести domain ownership**
   - Формально закрепить, что `14` — primary для Clan, `13` — primary для Aging/Succession.
   - В обоих документах добавить перекрёстные anti-confusion ссылки.

4. **Шаг 4 — Отделить open questions от канона**
   - Создать `30_OPEN_DESIGN_QUESTIONS.md` и вынести туда незакрытые вопросы.
   - В канонических доменах оставить только решения и локальные ссылки на вопросы.

5. **Шаг 5 — Стабилизировать inventory как memory-layer**
   - Оставить `16` как карту статусов/ссылок/конфликтов.
   - Запретить в `16` появление новых нормативных формулировок.

6. **Шаг 6 — Усилить DEC-контур**
   - Любой закрытый вопрос из open-questions оформлять через `10_DECISIONS_LOG.md`.

7. **Шаг 7 — Регулярный документационный smoke-cycle**
   - На каждом цикле обновления проверять: один тип знания = один source of truth, tracker не превращается в канон, inventory не превращается в master-tome.

---

Этот план сохраняет принцип design library: **паспорт проекта + атлас навигации + доменные каноны + открытые вопросы + журнал решений**, без схлопывания всего в один giant master document.
