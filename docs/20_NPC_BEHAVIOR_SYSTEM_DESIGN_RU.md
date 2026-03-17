# Ambient Life v2 — Daily Life vNext (общий дизайн-документ)

Дата: 2026-03-17
Статус: проектный канон для новой реализации (заменяет старую слотную схему)
Область: повседневная жизнь NPC, materialization, active-area execution, интеграция с population policy.

---

## 1. Назначение документа

Этот документ фиксирует новую модель повседневной жизни NPC для Ambient Life v2 после отказа от старой схемы, где жизнь NPC была завязана на `alwp0..alwp5` и на прямую связь «временной слот → готовый waypoint tag».
Новая модель остаётся совместимой с инвариантами репозитория:
- area-centric orchestration;
- event-driven runtime;
- bounded processing;
- разделение контента и runtime;
- разрыв между legal truth и tactical response;
- отдельность Trade/City-State и runtime population response.

## 2. Главная цель

Daily Life vNext должен обеспечивать:
- города можно населять NPC;
- NPC живут правдоподобной повседневной жизнью;
- активная симуляция идёт только в области с игроком или активным локальным runtime;
- при прогреве области NPC материализуются сразу в корректном состоянии и месте;
- система не требует постоянной фоновой симуляции всего мира;
- система остаётся bounded и производительной при большом количестве NPC.

## 3. Что Daily Life делает

Daily Life отвечает за:
- обычный ритм жизни NPC;
- определение текущего повседневного состояния NPC;
- materialization NPC в правильном состоянии при активации области;
- локальное исполнение сна, работы, нахождения дома, службы, локальной социальной активности;
- bounded resync в активной области;
- корректный возврат к повседневной рутине после локальных отклонений;
- встраивание новых created/materialized NPC в повседневный контур.

## 4. Что Daily Life не делает

Daily Life не должен:
- юридически квалифицировать преступления;
- определять законность событий;
- моделировать макроэкономику города;
- решать ownership как правовой институт;
- управлять межрегиональными путешествиями;
- моделировать клановую политику;
- моделировать aging/succession в hot runtime.

## 5. Архитектурная позиция Daily Life

Daily Life остаётся частью runtime-слоя, но не строится как «маршрутная машина, где смысл жизни хранится в waypoint-слотах NPC».

Новая модель:

`время движка + профиль NPC + базовый контекст места + внешние ограничения/override → текущая директива → локальное исполнение`

Route, sleep, transition и activity остаются в системе, но становятся исполнителями директив, а не центральной моделью жизни NPC.

## 6. Базовый принцип новой системы

Старая схема:

`время → слот → waypoint tag`

Новая схема:

`время движка → поведенческая фаза/директива → база/здание/контекст → anchor/area/activity`

Время больше не выбирает «готовую точку», а выбирает то, что NPC должен делать сейчас, после чего это переводится в конкретное пространство мира.

## 7. Ключевые сущности

### 7.1 NPC Profile

Это лёгкий постоянный профиль NPC, который не хранит всю жизнь NPC в виде маршрутных тегов.

Минимум:
- `npc_role`
- `schedule_profile`
- `base_id`
- `work_id` или `duty_id`
- `npc_identity_type` (`named` / `unnamed`)
- `npc_persistence_type` (`persistent` / `replaceable`)

### 7.2 Schedule Profile

Это шаблон повседневного ритма, который хранит не waypoint tags, а временные окна поведения:
- сон;
- дом/базовый быт;
- работа;
- локальная социальная активность;
- служба/пост;
- возврат к базе.

Один `schedule_profile` может использоваться многими NPC одной категории.

### 7.3 Base Context

`base_id` — не обязательно «жилой дом», а любая базовая единица принадлежности NPC:
- дом;
- кузница;
- таверна;
- казарма;
- мастерская;
- shelter;
- районная точка принадлежности;
- иное служебное/бытовое место.

База может быть mixed-use (например, кузница одновременно дом и работа).

### 7.4 Anchors

Base context должен давать минимальные точки привязки:
- `sleep_anchor`
- `home_anchor`
- `work_anchor`
- `service_anchor`
- `duty_anchor`
- `entry_anchor`
- `exit_anchor`

Daily Life требует place-aware контекст, но не должен знать полную геометрию здания.

### 7.5 Directive

Минимальный набор директив первой версии:
- `SLEEP`
- `HOME_IDLE`
- `GO_HOME`
- `GO_WORK`
- `WORK`
- `SOCIAL_LOCAL`
- `DUTY`
- `GO_SHELTER`
- `HOLD_POST`
- `ESCORT`
- `DETENTION`
- `UNAVAILABLE`
- `RETURN_TO_BASE`

## 8. Временная модель

### 8.1 Источник времени

Источником истины является время движка, а не `alwp0..alwp5`.

### 8.2 Расписание

Расписание выражается как временные окна поведения, а не как «6 тегов маршрутов».

Пример:
- `00:00–06:00` → `SLEEP`
- `06:00–08:00` → `HOME_IDLE`
- `08:00–18:00` → `WORK`
- `18:00–21:00` → `SOCIAL_LOCAL`
- `21:00–24:00` → `GO_HOME` / `HOME_IDLE`

### 8.3 Почему не старая слотная модель

Слоты по 4 часа были удобным компромиссом, но слишком жёстко связывали время, смысл поведения и точку в мире. С появлением домов, интерьеров, mixed-use зданий и materialization схема становится слишком плоской.

### 8.4 Разрешённая дискретизация

Разрешено использовать фазы времени, но они должны быть частью `schedule_profile`, а не храниться как шесть готовых маршрутных тегов на NPC.

## 9. Materialization

### 9.1 Общий принцип

При активации области NPC не «прокручивает» пропущенную жизнь. Система должна:
1. взять текущее время;
2. определить текущую директиву;
3. определить нужную базу/здание/anchor;
4. материализовать NPC сразу в корректном месте и состоянии.

### 9.2 Что materialization делает

- определяет текущее состояние NPC;
- выбирает правильную area;
- выбирает нужный anchor;
- создаёт/возвращает NPC в активную область;
- не запускает тяжёлую ретроспективную симуляцию.

### 9.3 Что materialization не делает

- не считается респауном;
- не закрывает дефицит населения;
- не «оживляет убитого named NPC»;
- не является заменой population policy.

## 9A. Город как кластер областей

Город — это кластер связанных областей (экстерьеры, интерьеры, мастерские, казармы, административные зоны и т.д.), а не одна area.

Обязательное правило: нельзя проектировать Daily Life так, как будто все area города имеют одинаковый runtime-статус.

## 9B. Tier / LOD-модель областей

### HOT

Область, в которой есть игрок. Только в HOT-area разрешено:
- полное локальное исполнение Daily Life;
- materialization обычных NPC;
- bounded resync;
- локальные переходы;
- локальные реакции;
- активная city/runtime работа;
- population work / respawn pass;
- при необходимости — очень лёгкий heartbeat.

### WARM

Соседняя, связанная или заранее прогреваемая область.

Разрешено:
- bootstrap/prefetch;
- подготовка materialization;
- подготовка данных и anchors;
- лёгкий scheduler state;
- крайне ограничённый service prep.

Запрещено:
- полное исполнение повседневной жизни;
- массовая materialization обычных NPC;
- полноценный respawn;
- тяжёлый worker.

### FROZEN

Все остальные области.

Должно быть:
- никакого живого Daily Life runtime;
- никакого area worker;
- никакого population execution;
- никакого стандартного heartbeat;
- только логическое состояние мира и статические данные.

Канон:
- HOT = жизнь
- WARM = подготовка
- FROZEN = тишина

## 9C. Политика активации области

### OnEnter / активация области

Активация области не выполняет тяжёлую работу. Она делает только:
- перевод area в HOT;
- выставление `bootstrap_pending`;
- обновление activation timestamp;
- пересчёт связных WARM-областей;
- запуск/пробуждение сервисов при необходимости.

### Что запрещено в OnEnter

- массовая materialization всех NPC;
- population respawn;
- тяжёлый resync;
- пересборка всего района;
- дорогие обходы связных area.

### Исполнение после активации

Тяжёлая работа уходит в area tick / bounded worker и выполняется фазами:
- materialization pass;
- active-state resync;
- population pass;
- дополнительные bounded-задачи.

## 9D. Neighbor Warm-up Policy

Система поддерживает прогрев соседних областей только в ограниченном режиме.

Кандидаты на WARM:
- area, связанная дверью или переходом с HOT-area;
- соседний экстерьер;
- интерьер ближайшего здания;
- area с высокой вероятностью быстрого входа игрока.

Что даёт WARM:
- сокращение задержки при входе;
- готовность anchors/контекста;
- быстрая materialization без тяжёлого старта.

Чего WARM не даёт:
- полноценно живущих NPC;
- полноценной локальной симуляции;
- постоянной работы heartbeat и worker.

Ограничение: WARM-областей должно быть мало и bounded; нельзя «греть весь город», если игрок стоит в одной улице.

## 10. Активная жизнь в области

После materialization NPC входит в локальный active runtime. Разрешены:
- короткие перемещения;
- переходы между area;
- локальный сон;
- локальная работа/служба;
- bounded-реакции;
- редкий resync.

Вне активной области — lazy/materialization-based модель; в активной — ограниченно живая симуляция.

## 11. Resync

Resync нужен для:
- снятия залипаний;
- корректировки NPC к правильной директиве;
- возврата из сбоя в корректный state;
- синхронизации active-area жизни с текущим временем и контекстом.

Resync должен быть редким и bounded.

## 12. Дома, здания и базы

### 12.1 Общий принцип

Daily Life не требует, чтобы «дом» и «работа» были разными. База NPC может быть:
- чисто жилой;
- чисто служебной;
- смешанной.

### 12.2 Mixed-use сценарии

Поддерживаемый кейс: кузница = дом и работа.

Пример:
- `base_id = smithy_01`
- `sleep_anchor` и `work_anchor` могут быть в одном building context
- `SLEEP` и `WORK` ведут в разные anchors одного места

Это не special-case, а нормальный сценарий.

### 12.3 Интерьер/экстерьер

Дом/здание — логическая запись, связанная с exterior entry, interior area, внутренними anchors и city/district context.

## 13. Named и unnamed NPC

### 13.1 Daily Life работает для обоих

Именные и безымянные NPC одинаково участвуют в повседневной жизни.

### 13.2 Разница в политике замещения

`named/persistent`:
- живёт по тем же правилам Daily Life;
- может быть встроен DM вручную на лету;
- не респаунится автоматически как та же личность.

`unnamed/replaceable`:
- участвует в Daily Life;
- после смерти может быть заменён новым unnamed NPC;
- замещение зависит от population policy, а не «воскрешения личности».

### 13.3 Promote unnamed → named

Допускается односторонняя операция перевода текущего unnamed NPC в named/persistent.

## 14. Respawn и Daily Life

### 14.1 Что уже зафиксировано

Population respawn:
- city-scoped;
- закрывает только дефицит unnamed;
- не респаунит named NPC;
- не равен materialization;
- живёт в area tick, а не в heartbeat NPC и не в трупе.

### 14.2 Что нужно добавить

После respawn новый unnamed NPC обязан пройти assignment-фазу:
- выбрать/получить `npc_role`;
- получить `schedule_profile`;
- получить `base_id`;
- получить `work_id/duty_id` при необходимости;
- получить anchors/контекст жизни.

### 14.3 Главный принцип

`population deficit → выбор типа нового NPC → assignment в базовый контекст → entry into Daily Life`

Respawn создаёт не «того же человека», а нового исполнителя функции.

## 15. Население города и визуальное заполнение

### 15.1 Агрегированное население

Город имеет макропараметр населения (например, шкала `0..100`) как индикатор живости, а не число реально активных NPC.

### 15.2 Что он регулирует

Population level влияет на:
- визуальное заполнение города;
- число replaceable NPC, которых имеет смысл поддерживать;
- политику замещения пустых слотов;
- возможность деградации города до обезлюдивания.

### 15.3 Следствие

- высокий уровень: replaceable-слоты заполняются активно;
- средний уровень: часть пустых слотов может оставаться пустой;
- низкий уровень: respawn жёстко ограничен;
- нулевой уровень: авто-respawn обычного населения запрещён.

## 16. Связи Daily Life с другими доменами

### 16.1 Сильные связи

- City Response
- Trade / City State
- Respawn / Population
- Homes / Buildings / Base Context

### 16.2 Средние связи

- Legal / Witness / Crime
- Property

### 16.3 Слабые связи

- Clans
- World Travel
- Aging / Succession

### 16.4 Правило

Daily Life принимает контекст, ограничения и override, но не поглощает другие домены и не решает их задачи.

## 17. Heartbeat, timer queue и scheduler policy

### 17.1 Heartbeat — только под управлением tier-политики

Heartbeat не является базовым runtime-контуром и не разрешён по умолчанию на всех area.

Правило: area без игрока не должна держать живой heartbeat вхолостую.

Heartbeat допустим только если одновременно:
- area находится в разрешённом tier (HOT, редко WARM);
- heartbeat делает только очень дешёвую работу;
- heartbeat гарантированно снимается при исчезновении условий.

Heartbeat может делать:
- дешёвый time check;
- dirty-check;
- wake-up scheduler;
- проверку due-задач;
- лёгкий watchdog;
- простые cooldown-gates.

Heartbeat не может:
- обходить NPC;
- materialize population;
- запускать массовый respawn;
- строить маршруты;
- выполнять тяжёлый resync;
- заменять area worker.

### 17.2 Heartbeat Gate

Нужен отдельный механизм `Heartbeat Gate / Heartbeat Supervisor`, который:
- включает heartbeat только где это полезно;
- выключает heartbeat, где он не нужен;
- не допускает idle-heartbeat на FROZEN-area;
- не допускает бессмысленной фоновой работы на интерьерах без игрока.

### 17.3 Timer Queue

`Timer Queue` — основной механизм отложенной bounded-работы:
- resync later;
- retry later;
- recovery later;
- population later;
- scheduler jobs.

### 17.4 Worker

Worker исполняет тяжёлые задачи только там, где разрешает tier:
- HOT → полноценный bounded worker;
- WARM → prep-only;
- FROZEN → no worker.

Итоговая формула:
- Heartbeat = будильник
- Timer Queue = расписание задач
- Worker = дозированная работа
- Tier Policy = где это вообще разрешено

## 18. Активация области

### 18.1 Что нельзя делать в OnEnter

Запрещено:
- тяжёлая materialization;
- тяжёлый respawn;
- пересборка всего района;
- крупные циклы.

### 18.2 Что нужно делать

OnEnter/активация области должны:
- перевести область в active/bootstrap-ready;
- поднять pending-флаг;
- запланировать bootstrap-фазы.

### 18.3 Что делает area tick

Area tick дозированно выполняет:
- materialization pass;
- active-state resync;
- population respawn pass.

## 18A. Materialization и tier-политика

- HOT: полноценная materialization NPC в корректном состоянии.
- WARM: только подготовка (данные, anchors, context, readiness flags).
- FROZEN: materialization обычных NPC не выполняется.

## 18B. Respawn и tier-политика

Respawn сохраняет канонические ограничения (только unnamed, через city/population policy, отдельно от materialization) и дополняется правилом:
- respawn разрешён только в HOT-area execution phase;
- в WARM-area допускается только подготовка;
- в FROZEN-area respawn запрещён.

## 19. Антипаттерны

Запрещено:
- возвращаться к `alwp0..alwp5` как центральной модели жизни NPC;
- честно симулировать весь город вне активных областей;
- строить поведение на per-NPC heartbeat;
- делать world-wide scan как регулярный способ поддержки NPC;
- смешивать materialization и respawn;
- заставлять Property, Trade или Legal напрямую рулить route loop;
- класть тяжёлую логику в heartbeat;
- держать area heartbeat везде «на всякий случай».

## 20. Инварианты производительности

Система корректна только если:
- активная симуляция ограничена активной областью;
- вне активной области используется lazy/materialization-based модель;
- решения о поведении принимаются редко и по событиям/времени;
- тяжёлая работа размазывается через queue + budget;
- respawn не создаёт взрывной волны NPC;
- NPC можно поставить в нужное состояние без долгого прогрева;
- новые домены не превращают Daily Life в монолит;
- город из десятков area не держится в живом runtime одновременно;
- HOT/WARM/FROZEN — обязательная часть архитектуры;
- HOT-area — единственное место полной повседневной симуляции;
- WARM-area используется только для bounded-прогрева соседних зон;
- FROZEN-area не держит холостой heartbeat и живой worker;
- активация области не выполняет тяжёлую работу прямо в обработчике входа;
- heartbeat запрещён как вечный фон на интерьерах без игрока;
- нельзя греть весь город ради одного игрока в одной area;
- все LOD-переходы bounded и наблюдаемы.

## 21. Этапы реализации

### R1 — Core redesign
- новая временная модель;
- NPC Profile;
- Schedule Profile;
- Directive Resolver;
- Materialization core.

### R2 — Base/Building integration
- `base_id`;
- home/work/duty anchors;
- interior/exterior handling;
- mixed-use bases.

### R3 — Active-area execution
- executor logic;
- bounded resync;
- route/sleep/activity как executors.

### R4 — Respawn integration
- assignment after respawn;
- replaceable/persistent policy;
- population level → fill policy.

### R5 — External overrides
- City Response overrides;
- Legal flags integration;
- Property access constraints;
- Trade/City context modifiers.

## 21A. Anti-patterns для городов из многих area

Запрещено:
- держать heartbeat на всех интерьерах города;
- считать любой интерьер рядом с игроком полноценной HOT-area;
- выполнять respawn на активации области;
- выполнять массовую materialization прямо в OnEnter;
- прогревать весь городской кластер одновременно;
- использовать WARM как скрытый HOT;
- оставлять area heartbeat «на всякий случай» без игрока и без нужного сервиса.

## 22. Итоговая формула системы

`Ambient Life Daily Life vNext = engine time + NPC profile + base/building context + directive resolver + materialization + bounded active-area execution + population-aware replacement`

Обновлённая короткая формула:

`Daily Life vNext = time-driven directives + place-aware materialization + bounded HOT-area execution + neighbor warm-up + zero-idle FROZEN policy`
