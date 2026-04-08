# 43 — Daily Life Unified Contour Digest (RU)

Дата: 2026-04-08  
Статус: owner-facing и agent-facing конспект-квинтэссенция (единый документ по контуру Daily Life)

---

## 1) Цель документа

Этот документ собирает в **единый, непротиворечивый конспект** весь контур Daily Life из канона, runtime-спецификаций, owner-презентации, implementation-снимков и аудитов.

Документ сделан как:
- единая точка чтения для владельца проекта;
- единая рабочая опора для агентов/разработчиков;
- anti-chaos слой: чтобы не держать десятки документов в голове при планировании следующего шага.

> Важно: этот digest не заменяет SoT-канон и не переопределяет runtime-контракты. Он конденсирует их в одном месте.

---

## 2) Источники, из которых собран конспект

### 2.1 Нормативная база (первичный приоритет)

1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md` — профильный канон Daily Life vNext.
2. `docs/canon/20_NPC_BEHAVIOR_SYSTEM_DESIGN_RU.md` — расширенный дизайн Daily Life vNext.
3. `docs/runtime/12B_DAILY_LIFE_V1_SOURCE_OF_TRUTH.md` — карта приоритетов для v1 runtime-доков.

### 2.2 Runtime-контур и реализация (операционный приоритет)

- `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md`
- `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
- `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_SLICE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`
- `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_INSPECTION_PATCH.md`
- `docs/runtime/12B_DAILY_LIFE_V1_DIALOGUE_BRIDGE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_DIRECTIVE_ACTIVITY_MATRIX.md`
- `docs/runtime/26_DAILY_LIFE_V1_TECHNICAL_SPEC_RU.md`
- `docs/runtime/35_DAILY_LIFE_V1_OWNER_PRESENTATION_RU.md`
- `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
- `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`

### 2.3 Проверки и валидирующие срезы

- `docs/audits/23_DAILY_LIFE_V1_CODE_AUDIT_2026-03-30.md`
- `docs/audits/34_RUNTIME_CONTOUR_EVENT_DRIVEN_AUDIT_2026-04-07.md`
- `docs/audits/35_GLOBAL_RUNTIME_CONTOUR_CANON_COMPLIANCE_AUDIT_2026-04-07.md`

---

## 3) Daily Life: смысл системы в одном блоке

Daily Life — это **runtime-система повседневного поведения NPC**, которая строит убедимую «живую сцену» в активной области города без полной симуляции каждой минуты жизни каждого NPC.

Ключевая формула:

`time-driven directives + profile/base context + external incident overrides + materialization + bounded HOT/WARM/FROZEN execution + resync + handoff во внешние домены`

Это означает:
- система не «честный симулятор мира», а быстрый rule-driven контур;
- локальная убедительность важнее тотальной полноты;
- приоритет — стабильность, производительность, контролируемые границы ответственности.

---

## 4) Границы ответственности (что входит / что не входит)

### 4.1 Daily Life **входит**

- вычисление директивы поведения NPC по времени/профилю/контексту/override;
- выбор anchor-группы и безопасной активности;
- materialization NPC в area (или мягкое скрытие при неактуальности);
- обновление интерактивного состояния (диалог/service mode);
- bounded execution по tier-политике HOT/WARM/FROZEN;
- resync после пропуска времени/смены режима/override-событий;
- handoff в функцию «вакансия/замещение» на событии отсутствия исполнителя.

### 4.2 Daily Life **не входит**

- legal truth/квалификация преступлений/судебные решения;
- макроэкономика, городской trade-balance, налоги и т.п.;
- полноформатный межгородской travel;
- клановая демография как самостоятельный runtime-движок;
- aging/succession как отдельная система истины;
- создание отдельного subsystem под каждый инцидент (fire/quarantine/riot должны идти через единый incident-layer).

---

## 5) Канонические сущности контура

### 5.1 Минимальное ядро данных

1. **NPC Profile**: family/subtype/identity/persistence + role.
2. **Schedule Profile**: шаблон окна дня + day-type + персональный сдвиг.
3. **Base Context**: домашняя/рабочая база и её доступность.
4. **Anchors**: группы целевых точек (work/social/rest/safe/hide и т.д.).
5. **Directive**: итог намерения (WORK, DUTY, SERVICE, SOCIAL, SLEEP, override-директивы и т.д.).
6. **Override Input**: внешний read-only контекст инцидента/ограничений.
7. **Area Tier State**: HOT/WARM/FROZEN.

### 5.2 Жёсткие правила по данным

- Resolver выбирает **директиву и anchor-group**, а не финальную анимацию.
- Activity layer выбирает конкретную визуальную активность по матрице Directive→Activity.
- Contract-first: enum/record/sig-подписи фиксируются до функционального расширения.
- Для первого Milestone нельзя размывать смысл `BASE_LOST` и нельзя смешивать `PUBLIC_PRESENCE` с `SOCIAL`.

---

## 6) Единый runtime pipeline (операционный контур)

### 6.1 Триггеры запуска

Daily Life должен запускаться событиями, а не постоянным глобальным polling:
- вход/выход игрока из area;
- тик area-level worker;
- изменение времени/окна расписания;
- изменения base/access;
- внешние override-события;
- population/slot события (handoff).

### 6.2 Поток обработки (area → npc)

1. **Area Controller** решает, активен ли контур для area и в каком tier.
2. **Scheduler/Worker** даёт bounded budget по jobs.
3. **Resolver** считает directive + anchor policy + interaction mode.
4. **Materialization** применяет план постановки (instant/local walk/soft hide).
5. **Execution refresh** обновляет service/dialogue locals.
6. **Handoff** вызывается при потере функционального исполнителя.
7. **Resync** выравнивает состояние после паузы/изменения контекста.

### 6.3 Tier-политика

- **HOT**: полный локальный runtime и materialization.
- **WARM**: урезанный/дешёвый режим поддержания согласованности.
- **FROZEN**: нулевой idle-runtime; только событие активации/перевода.

Главный инвариант: нельзя держать честную фоновую симуляцию для FROZEN и нельзя строить ядро на per-NPC heartbeat.

---

## 7) Интеграции с внешними доменами (контрактно)

### 7.1 Сильные связи

- **City Response / Unified Incident Context**: главный источник временных override.
- **Trade / City State**: поставляет контекст давления/деградации, но Daily Life не становится экономическим движком.
- **Respawn / Population**: handoff при отсутствии исполнителя роли.
- **Homes/Buildings**: base/building доступ и маршрутизация внутри контекста базы.

### 7.2 Средние связи

- **Legal/Witness/Crime**: read-only сигналы ограничений/статусов; без правовых решений внутри Daily Life.
- **Property**: read-only ownership/access signals; без изменения собственности из Daily Life.

### 7.3 Слабые связи

- **Clans**: только ограниченный контекст роли/принадлежности, не полный клановый симулятор.
- **Travel**: только факт `ABSENT/LEAVE_CITY` как внешний результат, не travel-маршруты внутри Daily Life.
- **Aging/Succession**: внешний контекст статуса, без логики наследования в контуре Daily Life.

---

## 8) Текущее состояние v1 (по сводным runtime-докам и аудитам)

### 8.1 Что уже стабилизировано

- Докконтур v1 в целом собран: ruleset + data contracts + runtime pipeline + checklist + tech spec.
- Milestone A описан как безопасная первая целевая точка (contract-first, bounded, event-driven).
- Проведены целевые аудиты docs↔code и глобальная проверка соответствия канону.

### 8.2 Что подтверждено аудитами

- Базовая модель event-driven/area-centric признана правильной для v1.
- Основные архитектурные границы (не смешивать legal/trade/travel/clan в ядро) соблюдаются как норматив.

### 8.3 Зафиксированные риск-зоны

1. **Binding integrity risk**: риск, что runtime-события не дойдут до нужного dispatcher path.
2. **Observability gap**: не везде формализованы счётчики деградации и эксплуатационные метрики.
3. **SLO formalization gap**: нужен явный micro-SLO профиль для Daily Life v1 как runtime-контракт.
4. **Owner-check fragmentation**: проверочные owner-сценарии частично разнесены между документами.

---

## 9) Практический контур верификации (для владельца и агента)

### 9.1 Минимум «система жива»

Проверить по trace/log и игровым сценариям, что есть:
1. реакция на area enter;
2. вычисление directive без хаотичных скачков;
3. корректный выбор anchor/activity по матрице;
4. обновление dialogue/service gate;
5. реакция на override;
6. корректный переход HOT↔WARM↔FROZEN;
7. controlled resync после паузы.

### 9.2 Симптомы архитектурного дрейфа

- попытка «дописать» правовые/экономические решения внутрь resolver;
- возврат к heartbeat-first модели;
- появление ad-hoc подсистем под отдельные инциденты в обход unified incident contract;
- размывание контрактов enum/record/сигнатур «ради быстрого фикса».

---

## 10) Контур развития v2 (без ломки v1)

Ветка v2 (rewrite program + design baseline) фиксирует осторожный протокол:
- «одна функция за шаг»;
- каждое расширение только после validation предыдущего шага;
- сначала минимальный data contract + event pipeline skeleton;
- рост функционала только через controlled increments.

Практический смысл: v2 должен эволюционно наследовать сильные стороны v1 (границы, event-driven, tier-policy), а не снова уходить в монолит/хаос.

---

## 11) Единое резюме (квинтэссенция)

Daily Life контур в репозитории — это **не «AI-симулятор всего города», а компактная, контрактная, событийно-управляемая система повседневного поведения NPC**.

Её обязательные опоры:
- profile/schedule/base/anchor/directive модель;
- external override через unified incident-layer;
- materialization + interaction refresh;
- bounded HOT/WARM/FROZEN execution;
- resync/handoff как отдельные управляемые этапы;
- жёсткая изоляция от legal/trade/travel/clan/aging truth-domain задач.

Если эти опоры соблюдены, система остаётся масштабируемой, проверяемой и понятной и владельцу проекта, и агентам разработки.
