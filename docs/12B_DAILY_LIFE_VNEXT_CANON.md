# Ambient Life v2 — Daily Life vNext Canon

Дата: 2026-03-18  
Статус: профильный канон Daily Life vNext  
Назначение: нормативная фиксация новой модели Daily Life как отдельного design-блока рядом с `12B`.

---

> Этот документ детализирует только новую модель Daily Life. Общий high-level канон проекта закреплён в `docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`. Runtime master summary остаётся в `docs/12B_RUNTIME_MASTER_PLAN.md`.

## 1) Назначение системы

Daily Life — это runtime-система повседневного поведения NPC.

Её задача — приводить NPC в правдоподобное состояние жизни относительно:
- времени движка;
- контекста места;
- профиля NPC;
- текущей директивы;
- статуса области активности.

Daily Life не обязана честно проигрывать каждую пропущенную минуту жизни NPC.

Daily Life обязана быстро восстанавливать локально убедимую картину жизни мира в активной области.

## 2) Границы Daily Life

Daily Life отвечает за повседневное поведение NPC в обычном режиме мира.

Daily Life работает на уровне:
- намерения NPC в текущем временном окне;
- выбора допустимого контекста пребывания;
- materialization NPC в корректное состояние;
- локального bounded execution в активной области;
- ограниченного resync после пауз, unload/load и смены tier.

Daily Life не является общей системой мировой истины.

Daily Life не является системой экономики города, правовой квалификации, клановой демографии, старения или глобального travel-графа.

## 3) Связи Daily Life с другими системами репозитория

### 3.1 Сильные связи

#### Unified Incident Context / City Response

Daily Life получает не отдельные ad-hoc флаги под пожар, болезнь или тревогу, а единый внешний контекст городских инцидентов.

Минимальный контракт внешнего контекста:
- `incident_type` = `none / fire / quarantine / alarm / curfew / riot / ...`;
- `incident_stage`;
- `incident_severity`;
- `incident_scope` = `city / district / area-set / anchor-local`;
- список area-level ограничений и сервисных точек.

Daily Life получает:
- текущий incident context города/района/area;
- допустимые city-level directives и ограничения по scope;
- сигналы старта, смены стадии, завершения и resync после инцидента.

Daily Life отдаёт:
- факт текущего локального состояния NPC;
- доступность/недоступность NPC для мирной рутины;
- материализованное присутствие NPC в HOT-area;
- подтверждение, что NPC переведён в временный override или возвращён в базовый профиль.

Нельзя:
- делать отдельный core-контур под каждый новый инцидент;
- подменять Daily Life частным fire/quarantine subsystem;
- смешивать routine pipeline и incident FSM в одну state machine;
- считать тревогу, карантин или пожар нормальным базовым режимом Daily Life.

#### Trade / City State

Daily Life получает:
- макропараметры города;
- population level;
- pressure/дефицитные модификаторы, влияющие на заполнение replaceable-функций.

Daily Life отдаёт:
- операционную проекцию локальной заселённости;
- сигналы о дефиците replaceable population;
- runtime-факты о наличии/отсутствии исполнителей функций.

Нельзя:
- трактовать Daily Life как источник макроэкономической истины;
- скрывать кризис города бесконечной materialization/respawn-компенсацией;
- выводить city population только из числа активных NPC в HOT-area.

#### Respawn / Population

Daily Life получает:
- политику replaceable/persistent;
- population level и лимиты заполнения;
- assignment-политику после respawn.

Daily Life отдаёт:
- дефицит функций и контекстов, которые должны быть заняты;
- требования к назначению после появления нового исполнителя;
- информацию о том, кого materialize-ить, а кого создавать заново нельзя.

Нельзя:
- смешивать materialization и respawn;
- возвращать named NPC через respawn как ту же личность;
- считать любой пустой слот основанием для немедленного спауна.

#### Homes / Buildings / Base Context

Daily Life получает:
- `base_id` и тип building/base context;
- пространственные anchors и доступные контексты внутри места;
- информацию о том, что место означает для NPC в разные окна времени.

Daily Life отдаёт:
- факт использования base/building как текущего жизненного контекста;
- потребность materialize NPC в определённом building context;
- локальное распределение NPC по контекстам места.

Нельзя:
- считать базу только домом;
- жёстко разводить «дом» и «работу», если в каноне это одно место;
- привязывать поведение только к waypoint-слотам без контекста здания.

### 3.2 Средние связи

#### Legal / Witness / Crime

Daily Life получает:
- read-only сигналы о запретах, тревоге, риске, допустимости присутствия;
- статусы, влияющие на routine override.

Daily Life отдаёт:
- наблюдаемые runtime-факты: кто где был, в каком контексте находился, был ли локально активен;
- входы для witness/crime pipeline через интеграционный слой.

Нельзя:
- принимать правовые решения внутри Daily Life;
- хранить юридическую истину в runtime-флагах Daily Life;
- превращать routine-систему в crime-движок.

#### Property

Daily Life получает:
- права доступа к зданиям/комнатам/зонам;
- ownership/use policy для отдельных base/building contexts.

Daily Life отдаёт:
- факты runtime-использования объекта;
- запросы на проверку допустимости пребывания в контексте.

Нельзя:
- менять ownership из Daily Life;
- трактовать факт нахождения NPC в доме как доказательство права собственности;
- решать имущественные конфликты через локальные behavior-флаги.

### 3.3 Слабые связи

#### Clans

Daily Life получает:
- профильный social/background context, если он уже выведен в role/base/schedule policy.

Daily Life отдаёт:
- только runtime-проекцию активности конкретного NPC.

Нельзя:
- строить Daily Life вокруг полной симуляции клана;
- делать clan runtime-источником обычного повседневного поведения всех NPC.

#### World Travel

Daily Life получает:
- факт отсутствия/недоступности NPC в локальном городе;
- разрешённые входы/выходы из area-контекста через внешний слой.

Daily Life отдаёт:
- локальное состояние до входа/после возврата в городскую зону.

Нельзя:
- использовать Daily Life как замену travel-системе;
- честно симулировать дальние поездки через local routine pipeline.

#### Aging / Succession

Daily Life получает:
- только уже готовые identity- и status-изменения.

Daily Life отдаёт:
- runtime-факты присутствия/отсутствия акторов.

Нельзя:
- использовать runtime identity как долгую истину линии преемственности;
- пытаться решать succession внутри Daily Life.

## 4) Что Daily Life делает

Daily Life:
- интерпретирует engine time как главный источник истины для текущего повседневного окна;
- определяет актуальную директиву NPC по profile + context;
- materialize-ит NPC в корректное состояние, когда область становится активной;
- исполняет локальную жизнь NPC только в HOT-area;
- подготавливает WARM-area без полной живой симуляции;
- делает bounded resync после пропуска времени, unload/load или возврата в область;
- работает и для named, и для unnamed NPC;
- использует replaceable/persistent policy при восстановлении населения;
- передаёт respawn-контру только задачу создания нового исполнителя функции.

## 5) Что Daily Life не делает

Daily Life не делает следующее:
- не считает `alwp0..alwp5` основой новой модели;
- не держит полную непрерывную симуляцию всех NPC города;
- не симулирует честно всю пропущенную жизнь в off-screen режиме;
- не держит активную жизнь в WARM и FROZEN областях;
- не респаунит named NPC как ту же личность;
- не заменяет City Response, Trade/City State, Legal, Travel, Aging или Clans;
- не строится на per-NPC heartbeat как главном runtime-контуре;
- не использует сетку `DelayCommand()` как основной планировщик.

## 6) Основные сущности

Минимальный набор сущностей новой модели:
- `Engine Time`;
- `NPC Profile`;
- `Schedule Profile`;
- `Directive`;
- `Base / Building Context`;
- `Anchor`;
- `Area Tier` (`HOT`, `WARM`, `FROZEN`);
- `Materialization State`;
- `Resync Request`;
- `Population Slot / Function`;
- `Replaceable / Persistent Policy`.

Эти сущности описывают намерение и контекст.

Они не требуют постоянной полной симуляции между всеми area мира.

## 7) Исторический legacy-контур

Старая схема `alwp0..alwp5` фиксируется только как исторический прототип.

Она была полезна как ранняя slot/waypoint-модель маршрутов, но не является основой Daily Life vNext.

В новой модели:
- время движка важнее slot-индекса;
- schedule profile важнее набора waypoint-слотов;
- directive resolver важнее линейного перехода по старой сетке;
- place-aware execution важнее «NPC всегда идёт по одному и тому же циклу точек».

Допустимо использовать legacy-данные как source material для миграции контента.

Недопустимо описывать legacy-модель как актуальный канон новой Daily Life.

## 8) NPC Profile

`NPC Profile` — это стабильное описание поведенческого типа NPC.

Профиль должен задавать:
- класс повседневной жизни;
- допустимые schedule profiles;
- роль в городе или месте;
- привязку к base/building context;
- identity policy (`named` / `unnamed`, `persistent` / `replaceable`);
- допустимые директивы и fallback-правила.

`NPC Profile` не равен waypoint-маршруту.

`NPC Profile` не равен одной только профессии.

Профиль должен быть достаточен, чтобы resolver мог определить, где NPC уместен по времени и контексту, даже если честного движения между всеми промежуточными шагами не было.

## 8A) External Incident Context

Внешний городской контекст должен быть единым архитектурным слоем, который временно модифицирует Daily Life без переписывания базовых routine.

Минимальная модель incident context:
- `incident_type`;
- `incident_stage`;
- `incident_severity`;
- `incident_scope`;
- `incident_priority`;
- `affected_roles`;
- `affected_areas`;
- `blocked_routes`;
- `safe_points`;
- `panic_points`;
- `incident_anchors`.

`incident_scope` обязан позволять как минимум три уровня:
- весь город;
- район/кластер;
- конкретный набор `area` или anchors.

Это нужно, чтобы пожар, карантин, бунт, комендантский час и другие режимы добавлялись как новые типы данных и role-policy, а не как отдельные hardcoded ветки core-логики.

## 8B) Base behavior и temporary override

Daily Life обязан разделять:
- базовый профиль поведения NPC;
- временный override-профиль на период внешнего инцидента;
- правило возврата к базовому профилю после завершения инцидента.

Минимальный паттерн:
- `citizen_normal` -> базовый мирный профиль;
- `citizen_quarantine` -> временный override на карантин;
- `citizen_panic` -> временный override на пожар/панический режим.

Override не переписывает базовое расписание навсегда. Он только временно меняет resolver directive и локальное исполнение для затронутого NPC или роли.

## 8C) Interrupt / temporary behavior / resync-resume contract

Для любого внешнего инцидента Daily Life должен иметь общий контракт:
1. `interrupt` — прервать текущую мирную активность без разрушения identity/profile слоя;
2. `temporary behavior` — перевести NPC в временную incident-реакцию по роли и scope;
3. `resync / resume` — после завершения инцидента пересчитать актуальную базовую директиву и вернуть NPC в нормальный цикл.

Без этого контракта пожар, карантин или другие массовые режимы будут ломать маршруты, очереди действий и возврат к обычной жизни.

## 8D) Event-driven lifecycle инцидентов

Инциденты должны входить в Daily Life как события, а не как постоянный per-NPC polling.

Минимальный набор событий:
- `incident_start`;
- `incident_stage_changed`;
- `incident_end`;
- `incident_resync_requested`.

Resolver и executor должны реагировать на эти события через bounded dispatch, чтобы не заставлять каждого NPC постоянно проверять, не начался ли пожар или карантин.

## 8E) Area-level incident metadata

У области и building context заранее должен существовать формат служебных incident-метаданных.

Минимально допустимые флаги и точки:
- `restricted_area`;
- `danger_area`;
- `blocked_routes`;
- `safe_point`;
- `panic_point`;
- `incident_anchor`.

Не обязательно сразу наполнять весь мир этими данными, но формат должен существовать в каноне, чтобы новые инциденты подключались без переделки структуры area/base context.

## 9) Schedule Profile

`Schedule Profile` — это не роль и не waypoint.

`Schedule Profile` — это шаблон временных окон поведения NPC.

Он определяет:
- какие типы активности допустимы в данный интервал времени;
- к какому контексту места NPC должен тяготеть;
- какие anchors предпочтительны;
- какие fallback-состояния допустимы при отсутствии идеального контекста.

Примеры временных окон:
- сон;
- утренняя подготовка;
- рабочее окно;
- дежурство;
- публичное присутствие;
- отдых;
- вечерний возврат на базу.

Профиль расписания не обязан задавать точную минутную хореографию.

Он задаёт нормативное окно поведения, а не сценарий покадрового движения.

## 10) Base / Building Context

У NPC есть `base_id`.

`base_id` — это канонический опорный контекст места, к которому NPC привязан в обычной жизни.

База не обязана быть только домом.

В роли `base_id` могут выступать:
- дом;
- кузница;
- таверна;
- казарма;
- shelter;
- мастерская;
- районная база.

Одно и то же место может одновременно быть и домом, и работой.

`Base / Building Context` нужен для следующих решений:
- где NPC должен materialize-иться в спокойном состоянии;
- куда NPC возвращается по умолчанию;
- какие anchors допустимы в данном временном окне;
- как выбирать локальный контекст без полной симуляции пути.

## 11) Anchors

`Anchor` — это именованная точка или локальный контекст размещения внутри места/области.

Anchor может означать:
- кровать;
- стойку;
- рабочее место;
- стол;
- пост;
- вход;
- двор;
- улицу возле базы;
- зону ожидания.

Anchors используются как цель materialization и локального исполнения.

Anchor не является эквивалентом старого slot-маршрута.

Anchor отвечает на вопрос «где NPC должен оказаться в данном контексте», а не «как он прошёл каждую промежуточную точку». 

## 12) Directive model

Новая Daily Life строится как directive / intent-driven модель.

Порядок принятия решения:
1. берётся engine time;
2. выбирается активное окно schedule profile;
3. учитывается NPC profile;
4. учитывается base/building context;
5. учитывается локальный state area tier и внешний incident context / overrides;
6. resolver выдаёт директиву.

Директива описывает:
- что NPC сейчас должен делать;
- в каком типе контекста он должен находиться;
- какой anchor является предпочтительным;
- допускается ли локальное движение, idle, sleep, duty или hold;
- какой fallback допустим, если идеальный anchor недоступен.

Directive model нужна, чтобы новая Daily Life опиралась на intent, а не на слепой replay legacy-пути.

## 13) Materialization

`Materialization` — это постановка NPC сразу в правильное состояние по времени и контексту в момент активации области или входа в активную обработку.

Правила materialization:
- NPC должен появляться не «в дефолтной точке», а в состоянии, соответствующем engine time и директиве;
- нельзя честно симулировать всю пропущенную off-screen жизнь;
- materialization обязана учитывать base/building context и anchors;
- materialization может выбирать ближайший допустимый anchor, если идеальный недоступен;
- materialization должна быть bounded и быстрой.

`Materialization` и `Respawn` — разные контуры.

Materialization:
- не создаёт нового человека;
- не закрывает population deficit сама по себе;
- не должна менять identity policy NPC.

Respawn:
- создаёт нового исполнителя функции;
- работает только через population/assignment policy;
- не является способом вернуть того же named NPC.

## 14) Active-area execution

Полная локальная жизнь NPC исполняется только в `HOT-area`.

Это означает:
- локальные шаги поведения;
- реакцию на игрока и близкие события;
- короткие перемещения и действия внутри области;
- bounded updates по таймерам и событиям;
- реальный runtime presence.

`WARM-area` не является зоной полной жизни.

`WARM-area` нужна для:
- предварительной подготовки соседней области;
- подкачки контекста;
- расчёта materialization-ready состояния;
- мягкого resync перед входом игрока.

`FROZEN-area` — это полная тишина.

В `FROZEN-area` не должно быть живой симуляции NPC.

## 15) Resync

`Resync` — это bounded восстановление согласованности Daily Life после пропуска времени или смены контекста исполнения.

Resync нужен после:
- загрузки сейва;
- входа игрока в область;
- возврата области из `FROZEN` в `WARM` или `HOT`;
- больших скачков engine time;
- завершения override-состояния;
- окончания городского инцидента и перехода к resume/resync.

Resync не является полной ретроспективной симуляцией.

Resync должен:
- пересчитать актуальную директиву;
- выбрать допустимый контекст места;
- обновить materialized state;
- ограничить объём работы по бюджету.

`Bounded resync` означает:
- нет replay всех пропущенных шагов;
- нет глубокого исторического прогонa дня;
- нет попытки вычислить каждую промежуточную встречу NPC.

## 16) Named / unnamed NPC

Daily Life работает и для named, и для unnamed NPC.

`Named NPC`:
- имеет индивидуальную идентичность;
- не должен автоматически возвращаться через respawn как та же личность;
- может иметь более жёсткую persistent policy;
- materialize-ится как тот же логический персонаж, пока он существует в каноне мира.

`Unnamed NPC`:
- может быть replaceable-исполнителем функции;
- может входить в population fill policy;
- допускает более гибкую замещаемость по role/schedule/base context.

Допустимо, что функция погибшего named NPC позже будет занята unnamed NPC.

Допустимо ручное превращение `unnamed -> named` как DM-операция.

Такое превращение должно считаться отдельным управляющим действием, а не автоматическим следствием обычной materialization.

## 17) Replaceable / persistent policy

Каждый NPC или population slot должен явно подпадать под policy:
- `persistent`;
- `replaceable`.

`Persistent` означает:
- важна конкретная личность;
- автоматическая замена тем же identity недопустима;
- отсутствие NPC должно быть видимым системам мира.

`Replaceable` означает:
- важна функция или заполняемая роль;
- допустима замена новым исполнителем;
- допускается частичное незаполнение при плохом состоянии города.

Политика replaceable/persistent влияет на:
- eligibility к respawn;
- требования к assignment после respawn;
- допустимую деградацию населения;
- правила materialization в пустых контекстах.

## 18) Respawn integration

Respawn — отдельный контур относительно materialization.

Его задача — создать нового исполнителя функции, а не вернуть того же человека.

После respawn обязателен assignment:
- `role`;
- `schedule_profile`;
- `base_id`;
- `work/duty context`.

Без assignment новый NPC не считается встроенным в Daily Life.

Respawn должен учитывать:
- replaceable/persistent policy;
- population level города;
- локальный дефицит функций;
- ограничения города и area tier;
- budgets/cooldowns population-layer.

Respawn не должен маскировать отсутствие persistent NPC.

Respawn не должен создавать ложную иллюзию, что история конкретной личности «продолжилась».

## 19) Population level города

У города есть макропараметр населения.

Он может быть выражен, например, шкалой `0..100`.

Этот параметр не равен числу реально активных NPC в runtime.

`Population level` влияет на:
- степень заполнения replaceable slots;
- плотность безымянного населения;
- частоту и ceiling respawn-восстановления;
- допустимую деградацию повседневной жизни города.

Возможные состояния проекции:
- высокая заполненность;
- средняя заполненность;
- частичное незаполнение;
- деградация вплоть до обезлюдивания.

Daily Life должна уметь показывать город как частично опустевший.

Она не должна автоматически выравнивать любой кризис до «нормы» только потому, что область стала активной.

## 20) HOT / WARM / FROZEN area policy

Tier-модель обязательна, потому что город может состоять из многих area.

### `HOT`

`HOT` = область с игроком.

Здесь разрешены:
- materialized NPC;
- полное локальное routine execution;
- ограниченные таймеры и события;
- короткие реактивные переключения;
- прямое наблюдаемое поведение.

### `WARM`

`WARM` = соседняя прогреваемая область.

Здесь разрешены:
- подготовка контекста;
- отложенный resync;
- подготовка materialization decisions;
- минимальные служебные проверки готовности.

Здесь не разрешены:
- полная живая симуляция;
- постоянные heartbeat-циклы;
- активная локальная жизнь как в `HOT`.

### `FROZEN`

`FROZEN` = полная тишина.

Здесь не должно быть:
- живой симуляции;
- локального heartbeat;
- route execution;
- фонового tick-шума ради видимости «жизни».

## 21) Heartbeat policy

Heartbeat не является главным runtime-контуром новой Daily Life.

Heartbeat допустим только как:
- лёгкий gate;
- будильник;
- dirty-check;
- trigger на включение bounded worker.

В неактивных area heartbeat должен быть отключён.

Нельзя держать холостой heartbeat на интерьерах без игрока.

Нельзя строить Daily Life на постоянном per-NPC heartbeat polling.

## 22) Timer queue / scheduler policy

Основной механизм отложенного исполнения — централизованная timer queue / scheduler.

Требования:
- due-time ориентированный запуск;
- централизованный учёт просроченных задач;
- bounded dispatch;
- контролируемые бюджеты;
- отсутствие хаотической сетки независимых отложенных вызовов.

Как правило:
- лёгкая активация может приходить через heartbeat-gate;
- heavy work должен исполняться только bounded worker'ом;
- `DelayCommand()` не должен быть основным механизмом системного планирования.

## 23) Performance invariants

Новая модель Daily Life обязана соблюдать следующие инварианты:
- engine time — единственный базовый clock source;
- нет полной симуляции всех NPC города вне `HOT`;
- нет unbounded replay пропущенного времени;
- любая тяжёлая операция bounded по бюджету;
- materialization дешевле честного off-screen simulation;
- resync ограничен и не превращается в скрытую полную симуляцию;
- WARM/FROZEN tier уменьшают работу, а не только меняют названия режимов;
- respawn budget и population policy ограничивают восстановление населения;
- named/persistent контур не подменяется массовыми replaceable-спаунами.

## 24) Anti-patterns

Запрещённые или нежелательные решения:
- описывать `alwp0..alwp5` как основу новой Daily Life;
- пытаться проигрывать честный день каждого NPC вне экрана;
- держать heartbeat на каждом NPC как постоянный основной loop;
- использовать WARM как «почти HOT, только без игрока»;
- держать heartbeat на пустых интерьерах;
- смешивать materialization и respawn в один lifecycle;
- респаунить named NPC как ту же личность;
- считать число активных NPC прямым эквивалентом population level города;
- забивать пустоты города мгновенным спамом replaceable NPC;
- строить scheduler из большой сети `DelayCommand()`;
- тащить legal/trade/clan/travel-логику внутрь Daily Life runtime state.

## 25) Phased implementation roadmap

### Phase 1 — Canon and contracts

Зафиксировать:
- новую модель времени;
- contracts для `NPC Profile`, `Schedule Profile`, `Directive`, `Base / Building Context`, `Anchor`;
- named/unnamed и replaceable/persistent policy;
- разделение materialization и respawn.

### Phase 2 — Resolver and materialization

Реализовать:
- engine-time based directive resolver;
- materialization по profile + schedule + place context;
- bounded resync при входе area в активную обработку;
- role-based override через внешний incident context.

### Phase 3 — HOT/WARM/FROZEN execution

Реализовать:
- tier-policy для area;
- полную локальную жизнь только в `HOT`;
- WARM-подготовку без живой симуляции;
- гарантированное молчание `FROZEN`-area.

### Phase 4 — Population and respawn integration

Реализовать:
- replaceable slot fill policy;
- population-level aware respawn ceilings;
- обязательный assignment после respawn;
- видимую деградацию населения города при кризисе.

### Phase 5 — Cross-system integration hardening

Ужесточить:
- handoff с Unified Incident Context / City Response;
- read-only границу с Legal/Property;
- связь с Trade/City State через population level и городские pressure-модификаторы;
- контракты отсутствия/возврата для travel и долгих статусов.

## 26) Нормативное резюме

Новая Daily Life определяется так:
- источник истины времени — engine time;
- поведение NPC — profile-based;
- оперативное решение — directive / intent-driven;
- восстановление локальной правдоподобности — через materialization;
- полная жизнь идёт только в `HOT-area`;
- `WARM` и `FROZEN` существуют для ограничения runtime-стоимости;
- resync bounded;
- respawn отделён от materialization;
- legacy `alwp0..alwp5` остаётся только историческим прототипом.

Это и есть каноническое направление Daily Life vNext для данного репозитория.
