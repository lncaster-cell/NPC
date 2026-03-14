# NPC Ambient Life v2

`ambient_life` — это event-driven система симуляции «живого» поведения NPC в NWN2.
Проект строится вокруг **area-centric runtime** (без heartbeat-цикла на каждого NPC), разделения обязанностей между контентом и рантаймом, а также bounded-подхода ко всем тяжёлым контурам (dispatch, route, reactions, city alarm/crime).

Этот README — подробный, но читаемый вход в проект: что уже реализовано, как устроены подсистемы, где границы архитектуры и с чего начинать работу.

---

## 1) Назначение и целевая модель

Ambient Life v2 решает две задачи одновременно:

1. Даёт правдоподобный поведенческий цикл NPC (маршруты, активности, сон, переходы между area, реакции на события).
2. Поддерживает расширяемую модель городских инцидентов (crime/alarm) и правовых механизмов следующего этапа (I.3), не превращая систему в unbounded world simulator.

Ключевая проектная идея: **движок отвечает за мгновенную реакцию, проектный runtime — за оркестрацию и долгую согласованность поведения**.

---

## 2) Канон архитектуры (кратко)

На уровне мастер-пакета (`docs/12_MASTER_PLAN.md` + тематические `12A–12D`) проект фиксирует приоритетную модель, где:

- движковые механики NWN2 (perception/disturbed/listen/faction reaction) используются как сигналы и тактическая реакция;
- долговременная «правда мира» (законы, принадлежность, права, документы, статусы) относится к персистентному слою;
- сценарная и правовая логика строится в проектном слое и должна быть bounded.

Практический смысл для разработки: нельзя подменять правовые и политические сущности только фракциями движка; фракции остаются локальным ИИ-инструментом, а не моделью государства/права.

---

## 3) Главные принципы runtime

- **Area-centric execution**: периодическая работа инициируется area-уровнем.
- **Event-driven orchestration**: шаги рутины и реакции идут через события (`OnUserDefined` и профильные hooks).
- **Bounded processing**: у тяжёлых контуров есть лимиты/бюджеты; unbounded-поведение запрещено.
- **Content/runtime separation**: контент описывает intent, runtime хранит эфемерные state/queue/metrics.

Эти принципы являются инвариантами и обязательны для любых изменений в `scripts/ambient_life/al_*`.

---

## 4) Таблица спроектированных систем и уже придуманных решений

Ниже — рабочая «карта системы»: что уже спроектировано, что именно придумано/зафиксировано в реализации, и где лежит канонический код или документация.

| Подсистема | Что уже придумали и зафиксировали | Статус | Где смотреть |
|---|---|---|---|
| Core lifecycle | Area-centric orchestration вместо heartbeat на каждого NPC; единый lifecycle-контур area/NPC | ✅ Реализовано | `scripts/ambient_life/al_core_inc.nss`, `scripts/ambient_life/al_area_tick.nss` |
| Registry + dispatch | Реестры area/NPC, bounded dispatch queue, batched-обработка и управляемая деградация под нагрузкой | ✅ Реализовано | `scripts/ambient_life/al_registry_inc.nss`, `scripts/ambient_life/al_dispatch_inc.nss` |
| Cache/lookup | Route/cache и lookup-оптимизации, чтобы не сканировать мир unbounded-логикой | ✅ Реализовано | `scripts/ambient_life/al_route_cache_inc.nss`, `scripts/ambient_life/al_lookup_cache_inc.nss` |
| Route + transition | Канонический маршрутный pipeline + переходы между linked area без разрыва routine-состояний | ✅ Реализовано | `scripts/ambient_life/al_route_inc.nss`, `scripts/ambient_life/al_transition_inc.nss` |
| Sleep + activity + schedule | Суточный цикл NPC (активности, сон, расписание) как часть общей routine-машины | ✅ Реализовано | `scripts/ambient_life/al_sleep_inc.nss`, `scripts/ambient_life/al_activity_inc.nss`, `scripts/ambient_life/al_schedule_inc.nss` |
| Reactive layer | Реакции на blocked/disturbed и безопасный возврат в штатный режим | ✅ Реализовано | `scripts/ambient_life/al_react_inc.nss`, `scripts/ambient_life/al_blocked_inc.nss` |
| City layer (crime/alarm) | Локальный городской контур с FSM-эскалацией/деэскалацией, отделённый от персонального routine-NPC | ✅ Реализовано (I.0–I.2) | `scripts/ambient_life/al_city_crime_inc.nss`, `scripts/ambient_life/al_city_alarm_inc.nss` |
| Population respawn | Управляемый population lifecycle + respawn с pre-check и bounded-ограничениями | ✅ Реализовано | `scripts/ambient_life/al_city_population_inc.nss`, `docs/10_NPC_RESPAWN_MECHANICS.md` |
| NPC hooks / wrappers | Слой входных событий (onspawn/ondamaged/ondeath и др.) и action-сигналы | ✅ Реализовано | `scripts/ambient_life/al_npc_on*.nss`, `scripts/ambient_life/al_action_*.nss` |
| Diagnostics/support | Диагностический и сервисный слой для эксплуатации/дебага | ✅ Реализовано | `scripts/ambient_life/al_debug_inc.nss`, `scripts/ambient_life/al_events_inc.nss` |
| Reinforcement + legal chain | Policy-ограниченный reinforcement + цепочка surrender → arrest → trial/legal followup | 🟡 В проектировании (Stage I.3) | `docs/08_STAGE_I3_TRACKER.md`, `docs/12_MASTER_PLAN.md` |

### Блок конфликтов идей: где чаще всего ломается архитектура

Ниже перечислены конфликтные места, на которые нужно смотреть в первую очередь при дизайне и код-ревью:

| Конфликт идей | Почему конфликтует | На что обратить внимание |
|---|---|---|
| «Сделаем всё на engine-faction» vs «Сохраним правовую модель проекта» | Фракции движка хорошо решают локальную тактику, но не заменяют юридическую/социальную «правду мира» | Право, статусы, документы и политические сущности держать в проектном/персистентном слое |
| «Быстрый full-scan мира» vs bounded runtime | Full-scan ломает предсказуемость latency и масштабируемость на живом модуле | Для legal/reinforcement/crime/population использовать только ограниченные выборки, очереди и бюджеты |
| «Смешаем city alarm FSM и personal routine NPC» vs разделение контуров | Смешение машин состояний даёт неявные баги эскалации и трудно дебажится | Держать городскую тревогу и персональный routine-пайплайн логически и кодово разделёнными |
| «Подправим runtime locals руками» vs контрактность данных | Ручные правки локалов маскируют системные ошибки и создают рассинхрон state-машин | Лечить причину в runtime-коде/контрактах, а не «горячими» правками локалов |
| «Добавим фичу любой ценой» vs инварианты A–I.2/I.3 | Локально рабочая фича может сломать канон архитектуры | Перед merge проверять соответствие инвариантам и наличие bounded-деградации |

---

## 5) Статус проекта и roadmap

### Реализовано (подтверждённый baseline)

- Стадии **A–H**: архитектурный каркас, registry/dispatch, lifecycle, route/transition, sleep/activity.
- Стадии **I.0–I.2**: blocked/disturbed pipeline и базовый local crime/alarm слой.

### Текущий следующий этап: **Stage I.3 — Reinforcement / Legal extensions**

План этапа:
1. Ограниченная policy для reinforcement/guard spawn (без world-wide scan).
2. Цепочка surrender → arrest → trial/legal followup поверх legal hooks.
3. Расширение последствий crime incidents без роста в «giant diplomacy simulator».
4. Отдельные smoke/QA сценарии для legal/reinforcement.

Критерий качества этапа I.3: end-to-end юридическая цепочка и операционно предсказуемое поведение под bounded-ограничениями.

---

## 6) Границы ответственности (критично)

### Контент отвечает за

- корректную разметку маршрутов, transitions и связей area;
- валидные локалы/теги для activity/sleep/population;
- соблюдение контрактов данных (без произвольных runtime-полей).

### Runtime отвечает за

- безопасный lifecycle и dispatch/queue orchestration;
- устойчивую обработку реактивных сценариев;
- bounded latency/нагрузку и диагностируемость;
- согласованность crime/alarm/legal pipeline по инвариантам.

### Жёсткий запрет

Runtime locals (очереди, курсоры, state-machine flags, служебные счётчики) не лечатся ручными правками «на лету» в контенте.

---

## 7) Инварианты, которые нельзя нарушать

1. Нет перехода к per-NPC heartbeat как базовой модели.
2. Нет unbounded full-scan подходов в legal/reinforcement/crime/population.
3. Route/transition/sleep/react не должны ломать друг другу канонический pipeline.
4. City alarm FSM и персональная routine-машина NPC должны оставаться логически разделёнными.
5. Любое расширение dispatch/route/react обязано сохранять bounded-поведение и проверяемую деградацию.

Если изменение конфликтует хотя бы с одним инвариантом, решение считается архитектурно неверным даже при локально «рабочем» результате.

---

## 8) Практический onboarding (для нового участника)

Рекомендуемый порядок входа в проект:

1. Прочитать обзор: `docs/01_PROJECT_OVERVIEW.md`.
2. Прочитать инварианты: `docs/06_SYSTEM_INVARIANTS.md`.
3. Свериться со статусом и roadmap: `docs/05_STATUS_AUDIT.md`, `docs/08_STAGE_I3_TRACKER.md`.
4. Изучить индекс мастер-плана: `docs/12_MASTER_PLAN.md`, затем тематические документы `docs/12A-12D` (см. ссылки внутри индекса).
5. Перед правками runtime проверить контракты: `docs/04_CONTENT_CONTRACTS.md`.

Минимум перед merge:
- пройти smoke-сценарии из операционного контура;
- убедиться, что изменение bounded и не вводит full-scan;
- обновить документацию, если изменена механика/контракт/операционный процесс.

---

## 9) Ключевая документация

### Что запрещено архитектурно

- Подменять правовую/политическую модель только engine-фракциями.
- Делать unbounded-сканирования мира для legal/reinforcement/population задач.
- Ломать контракты locals/events и «чинить» это ad-hoc правками без системного решения.

### Навигация по полной документации

- Индекс мастер-плана: `docs/12_MASTER_PLAN.md`
- Мировая модель и legal-канон: `docs/12A_WORLD_MODEL_CANON.md`
- Runtime master-план: `docs/12B_RUNTIME_MASTER_PLAN.md`
- Система имущества игрока: `docs/12C_PLAYER_PROPERTY_SYSTEM.md`
- Система перемещений по миру: `docs/12D_WORLD_TRAVEL_CANON.md`
- Обзор проекта: `docs/01_PROJECT_OVERVIEW.md`
- Механики: `docs/02_MECHANICS.md`
- Эксплуатация и валидация: `docs/03_OPERATIONS.md`
- Контракты контента: `docs/04_CONTENT_CONTRACTS.md`
- Статус-аудит: `docs/05_STATUS_AUDIT.md`
- Инварианты системы: `docs/06_SYSTEM_INVARIANTS.md`
- Сценарии и алгоритмы: `docs/07_SCENARIOS_AND_ALGORITHMS.md`
- Трекер Stage I.3: `docs/08_STAGE_I3_TRACKER.md`
- Smoke-runbook legal/reinforcement (Stage I.3): `docs/09_LEGAL_REINFORCEMENT_SMOKE.md`
- Журнал архитектурных решений: `docs/10_DECISIONS_LOG.md`
- Карта идей и синхронизации: `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md`
- Механика респауна населения: `docs/10_NPC_RESPAWN_MECHANICS.md`
- Старение и клановое наследование (v1): `docs/13_AGING_AND_CLAN_SUCCESSION.md`
- Дизайн-блок системы кланов: `docs/14_CLAN_SYSTEM_DESIGN.md`
- Инспекция документации (2026-03-14): `docs/15_DOCUMENTATION_INSPECTION_2026-03-14.md`

---

## 10) Ограничение для аудитов и инспекций

При аудитах и инспекциях:

- **не анализируем и не изменяем** директорию `third party`;
- **не анализируем и не изменяем** компилятор внутри неё.
