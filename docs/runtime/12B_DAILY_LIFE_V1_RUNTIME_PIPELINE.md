# Ambient Life v2 — Daily Life v1 Runtime Pipeline

Дата: 2026-03-20  
Статус: implementation contract draft  
Назначение: мост между Daily Life v1 design-правилами и реальной реализацией. Документ фиксирует минимальный runtime pipeline, набор API-функций, порядок вызовов и границы ответственности подсистем.

---

> Этот документ дополняет:
> - `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
> - `docs/archive/12B_DAILY_LIFE_V1_RULESET_legacy_2026-03-20.md`
> - `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md`
> - `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
>
> Его задача — описать, как именно Daily Life v1 должен исполняться в runtime: что вызывает area-контур, что делает resolver, что делает materialization, где происходит resync, где начинается handoff во внешние системы.

## 1) Главный принцип runtime

Daily Life v1 исполняется как последовательность дешёвых deterministic-этапов.

Система не должна:
- иметь per-NPC heartbeat как главный loop;
- пытаться честно проигрывать пропущенную жизнь NPC;
- выполнять тяжёлые полные сканы area на каждом тике;
- смешивать Daily Life с legal / trade / clan / travel логикой.

Система должна:
- работать полноценно в `HOT-area`;
- выполнять ограниченный bounded-cycle в `WARM-area` (без полной «живой» симуляции);
- использовать `FROZEN` как полную тишину;
- исполнять heavy work только через bounded worker / scheduler;
- выдавать один понятный runtime result: **какой NPC сейчас нужен, где он должен быть, что он делает, какой у него диалог и доступен ли сервис**.

---

## 2) Общая схема исполнения

Базовый цикл выглядит так:

1. area-controller определяет `area_tier`;
2. area-controller решает, нужна ли обработка Daily Life;
3. scheduler поднимает due-задачи;
4. для нужного NPC собирается `DL_ResolverInput`;
5. resolver вычисляет `DL_ResolverResult`;
6. materialization layer строит `DL_MaterializationPlan`;
7. execution layer применяет результат в area;
8. runtime state сохраняется локально;
9. если обнаружен дефицит функции или пустой replaceable slot — создаётся handoff во внешний population/respawn контур.

---

## 3) Слои runtime

## 3.1 Area Controller Layer

Отвечает за:
- определение `HOT / WARM / FROZEN`;
- запуск или молчание Daily Life в area;
- планирование area-level worker tick;
- handoff в соседние WARM-area;
- первичный вход/выход игрока.

Не отвечает за:
- выбор директивы конкретного NPC;
- выбор конкретного anchor;
- правовые решения;
- population respawn как отдельный домен.

## 3.2 Scheduler Layer

Отвечает за:
- due-time запуск задач;
- bounded dispatch;
- сбор просроченных resync/materialization jobs;
- ограничение объёма работы на один проход.

Не отвечает за смысл поведения NPC.

## 3.3 Resolver Layer

Отвечает за:
- вычисление текущей директивы;
- выбор целевой `anchor_group`;
- выбор `dialogue_mode`;
- выбор `service_mode`;
- принятие решения, должен ли NPC materialize-иться, скрываться или перейти в absent-state.

## 3.4 Materialization Layer

Отвечает за:
- выбор конкретной точки внутри `anchor_group`;
- построение `DL_MaterializationPlan`;
- разрешение instant-place vs local-walk;
- безопасную постановку NPC в корректное состояние.

## 3.5 Execution Layer

Отвечает за:
- применение результата в area;
- запуск короткого локального движения в `HOT-area`, если оно допустимо;
- запуск анимации/активности;
- обновление runtime state;
- обновление локальных флагов диалога/сервиса.

## 3.6 Handoff Layer

Отвечает за:
- сигнал `function slot empty`;
- сигнал `persistent NPC absent`;
- сигнал `replaceable slot suppressed by city state`;
- handoff в population/respawn контур;
- read-only handoff в legal/city response/trade слои.

---

## 4) События, которые запускают Daily Life

Daily Life v1 обязан реагировать на следующие trigger-события:

### 4.1 Area lifecycle
- игрок вошёл в area;
- игрок вышел из area;
- area стала `HOT`;
- area стала `WARM`;
- area стала `FROZEN`.

### 4.2 Time / resync
- загрузка сейва;
- большой скачок времени;
- смена типа дня;
- конец override-режима;
- возврат NPC после долгого отсутствия.

### 4.3 Base / access
- база стала невалидной;
- база сменила ownership / access policy;
- нужный контекст стал запрещённым.

### 4.4 Override input
- пожар;
- карантин;
- бунт;
- тревога города;
- collapse порядка;
- запрет расы / клана;
- упадок города.

### 4.5 Population / slot
- replaceable function slot опустел;
- новый NPC назначен в slot;
- slot стал suppressed / disabled.

---

## 5) Area lifecycle pipeline

## 5.1 При входе игрока в area

`DL_OnAreaBecameHot(area)`

Порядок действий:
1. area-controller переводит area в `HOT`;
2. scheduler получает high-priority area activation job;
3. для NPC в area registry собираются resync-запросы по бюджету;
4. для каждого допустимого NPC вызывается resolver;
5. строится materialization plan;
6. NPC materialize-ится в корректное состояние;
7. execution layer включает локальную поведенческую обработку.

Нормативное правило:
- нельзя пытаться честно проиграть весь пропущенный путь NPC до его текущей точки.

## 5.2 При выходе игрока из area

`DL_OnAreaPlayerExit(area, exiting_player)`

Порядок действий:
1. area-controller оценивает, остаются ли в зоне другие игроки, и выбирает новый tier;
2. если после выхода игрока в area ещё есть игроки, зона переводится в `WARM`;
3. если игроков не остаётся, зона переводится в `FROZEN`;
4. при `WARM` полная жизнь выключается, остаётся только ограниченный слой;
5. при `FROZEN` отключаются локальные активные jobs и runtime state сохраняется как проекция.

## 5.3 При переводе area в WARM

`DL_OnAreaBecameWarm(area)`

Разрешено:
- ограниченный worker-dispatch по `WARM` budget;
- отложенный resync;
- подготовка materialization decisions;
- минимальные проверки готовности.

Запрещено:
- полная локальная жизнь;
- долгие маршруты;
- боевое/социальное живое шевеление ради видимости жизни.

Контракт Milestone A по tier:
- `HOT` -> worker включён, budget `6`;
- `WARM` -> worker включён ограниченно, budget `2`;
- `FROZEN` -> worker выключен, budget `0`.

## 5.4 При переводе area в FROZEN

`DL_OnAreaBecameFrozen(area)`

Обязательные действия:
- отключить локальные routine jobs;
- не держать heartbeat-шум;
- не исполнять локальные route steps;
- оставить только пассивное состояние и внешние persistent-факты.

---

## 6) NPC lifecycle pipeline

## 6.1 Полный pipeline одного NPC

`DL_ProcessNpc(npc_id, reason)`

Порядок действий:
1. собрать `DL_ResolverInput`;
2. вызвать `DL_ResolveDirective(input)`;
3. если `should_materialize = false` и `should_hide = true`, вызвать hide/absent path;
4. иначе вызвать `DL_BuildMaterializationPlan(result)`;
5. применить `DL_ApplyMaterializationPlan(plan)`;
6. обновить runtime state;
7. при необходимости зарегистрировать follow-up job.

## 6.2 Если NPC должен исчезнуть

`DL_HandleNpcAbsent(npc_id, result)`

Используется если:
- `DL_DIR_LEAVE_CITY`
- `DL_DIR_ABSENT`
- race/clan ban
- base lost без валидной замены
- replaceable slot suppressed

Правила:
- named NPC не удаляется как будто его никогда не было;
- replaceable NPC может быть деактивирован/снят с локальной сцены;
- runtime обязан оставить понятный внешний факт отсутствия.

## 6.3 Если NPC потерял базу

`DL_HandleBaseLost(npc_id)`

Порядок действий:
1. попытаться найти новую допустимую базу;
2. если найдена — обновить profile/base binding и запланировать resync;
3. если не найдена:
   - named/persistent -> `LEAVE_CITY` или `ABSENT`;
   - replaceable -> `UNASSIGNED` и handoff в slot layer.

---

## 7) Resolver API

## 7.1 Главная функция

`DL_ResolveDirective(input) -> DL_ResolverResult`

Функция обязана:
- быть чистой относительно world-truth;
- не создавать side effects;
- не делать тяжёлые сканы area;
- не обращаться к legal/trade/clan логике напрямую, кроме готовых read-only override входов.

## 7.2 Порядок вычисления внутри resolver

Нормативный порядок:
1. проверить критические override;
2. проверить валидность базы;
3. определить day type;
4. определить schedule window;
5. применить personal time offset;
6. применить family/subtype rule;
7. применить fallback;
8. вычислить directive;
9. вычислить anchor group;
10. вычислить dialogue/service mode.

## 7.3 Вспомогательные функции resolver

Минимальный набор:
- `DL_DetermineDayType(...)`
- `DL_DetermineScheduleWindow(...)`
- `DL_ApplyPersonalTimeOffset(...)`
- `DL_ResolveDirectiveFromSchedule(...)`
- `DL_ApplyOverrideToDirective(...)`
- `DL_ResolveAnchorGroup(...)`
- `DL_ResolveDialogueMode(...)`
- `DL_ResolveServiceMode(...)`

Все эти функции должны быть максимально дешёвыми и deterministic.

---

## 8) Materialization API

## 8.1 Главная функция

`DL_BuildMaterializationPlan(npc_id, resolver_result) -> DL_MaterializationPlan`

Задача функции:
- выбрать конкретную точку внутри anchor group;
- выбрать activity kind;
- решить, допустим ли instant-place;
- вернуть план, но не применять его напрямую.

## 8.2 Применение плана

`DL_ApplyMaterializationPlan(npc_id, plan)`

Задача функции:
- поставить NPC в нужный runtime state;
- запустить короткий локальный walk только если это разрешено;
- включить нужную анимацию;
- обновить dialogue/service flags.

## 8.3 Правила instant-place vs local-walk

### Instant-place разрешён
- если игрока нет в area;
- если area только стала `HOT` и ещё нет устойчивого визуального контакта;
- если NPC materialize-ится в off-screen или безопасной точке.

### Local-walk разрешён
- только в `HOT-area`;
- только на короткой дистанции;
- только как bounded execution;
- только если это не ломает производительность и не требует сложного replay всей прошлой жизни.

### Запрещено
- телепортировать NPC у игрока перед глазами без причины;
- пытаться честно прогонять полный маршрут из off-screen прошлого.

---

## 9) Resync API

## 9.1 Главная функция

`DL_RunResync(npc_id, resync_reason)`

Resync обязан:
- быть bounded;
- не replay-ить прошлую жизнь;
- пересчитать только актуальное состояние;
- использовать текущие read-only world inputs.

## 9.2 Когда resync обязателен
- `AREA_ENTER`
- `TIER_UP`
- `SAVE_LOAD`
- `TIME_JUMP`
- `OVERRIDE_END`

## 9.3 Что делает resync
1. собирает `DL_ResolverInput`;
2. вызывает resolver;
3. сравнивает старое и новое runtime state;
4. строит новый materialization plan при необходимости;
5. применяет результат по бюджету.

## 9.4 Что resync не делает
- не проигрывает каждую пропущенную встречу NPC;
- не восстанавливает честно весь прошедший путь;
- не запускает скрытую heavy simulation.

---

## 10) Scheduler / worker API

## 10.1 Area-level gate

`DL_AreaWorkerTick(area)`

Это единственная допустимая точка регулярного запуска для Daily Life слоя area.

Функция должна:
- проверить tier area;
- собрать due jobs;
- исполнить bounded число задач;
- остановиться по бюджету.

## 10.2 Job types

### `DL_JOB_TYPE`
- `DL_JOB_AREA_RESYNC`
- `DL_JOB_NPC_RESYNC`
- `DL_JOB_MATERIALIZE`
- `DL_JOB_LOCAL_STEP`
- `DL_JOB_DIALOGUE_REFRESH`
- `DL_JOB_SERVICE_REFRESH`
- `DL_JOB_SLOT_HANDOFF`

## 10.3 Бюджеты

Daily Life v1 должен иметь хотя бы три класса бюджета:
- `DL_BUDGET_LOW`
- `DL_BUDGET_NORMAL`
- `DL_BUDGET_HIGH`

Нормативное правило:
- ни один проход area worker не должен пытаться «догнать весь мир сразу».

---

## 11) Dialogue / service refresh API

## 11.1 Обновление NPC-интеракции

`DL_RefreshNpcInteractionState(npc_id, resolver_result)`

Функция обязана:
- установить `dialogue_mode`;
- установить `service_mode`;
- обновить локальные флаги, которые будут читаться диалогом/сервисом.

## 11.2 Диалоговый контракт

Диалог не должен определять состояние NPC сам.

Диалоговый слой должен только читать уже подготовленные Daily Life флаги:
- `current_directive`
- `dialogue_mode`
- `service_mode`
- `current_area_tier`
- `override_flags`

Это нужно, чтобы не дублировать runtime-логику в диалогах.

---

## 12) Function slot / population handoff API

## 12.1 Когда делать handoff

Handoff во внешний слой нужен если:
- replaceable slot пуст;
- slot suppressed;
- slot disabled;
- named NPC ушёл, а функция осталась;
- база потеряна и replaceable NPC стал `UNASSIGNED`.

## 12.2 Главная функция handoff

`DL_RequestFunctionSlotReview(function_slot_id, reason)`

Daily Life не должен сам респаунить нового исполнителя функции.

Он должен только сообщить:
- slot пуст;
- функция сейчас недоукомплектована;
- нужен внешний population/respawn review.

Опционально внешний слой может заранее подготовить профиль для назначения:

`DL_StageFunctionSlotProfile(function_slot_id, family, subtype, schedule, base)`

## 12.3 Обратный handoff

Когда внешний слой назначил нового NPC в slot:

`DL_OnFunctionSlotAssigned(function_slot_id, npc_id)`

Дальше Daily Life:
1. обновляет profile/binding нового NPC (если внешний слой заранее положил slot-profile в module locals);
2. записывает `function_slot_id` в локальный binding NPC;
3. помечает `resync_pending` с причиной `DL_RESYNC_SLOT_ASSIGNED`;
4. materialize-ит NPC по обычным правилам.

После применения staged slot-profile профиль очищается:

`DL_ClearFunctionSlotProfile(function_slot_id)`

---

## 13) Внешние интеграции

## 13.1 City Response

Разрешено:
- Daily Life получает override-директивы и режимы тревоги;
- law-family может быть переведён в `DUTY / HOLD_POST / ASSIST_RESPONSE`;
- civilian-family может быть переведён в `HIDE_SAFE / LOCKDOWN_BASE`.

Запрещено:
- смешивать City Response FSM с ordinary routine FSM в одну машину состояний.

## 13.2 Legal

Разрешено:
- Daily Life читает read-only сигналы вроде quarantine / outlaw / restriction.

Запрещено:
- принимать правовые решения внутри Daily Life.

## 13.3 Trade / City State

Разрешено:
- Daily Life читает population pressure, city decline, service suppression.

Запрещено:
- считать Daily Life источником макроэкономической истины.

## 13.4 Travel

Разрешено:
- Daily Life может получить `LEAVE_CITY` / `ABSENT` как внешний результат.

Запрещено:
- симулировать нормальным NPC настоящие межгородские переходы внутри Daily Life.

---

## 14) Минимальный набор runtime-функций

Ниже — минимальный набор функций, который нужен для старта реализации.

### Area / lifecycle
- `DL_OnAreaBecameHot(area)`
- `DL_OnAreaBecameWarm(area)`
- `DL_OnAreaBecameFrozen(area)`
- `DL_AreaWorkerTick(area)`

### NPC processing
- `DL_ProcessNpc(npc_id, reason)`
- `DL_HandleNpcAbsent(npc_id, result)`
- `DL_HandleBaseLost(npc_id)`

### Resolver
- `DL_ResolveDirective(input)`
- `DL_DetermineDayType(...)`
- `DL_DetermineScheduleWindow(...)`
- `DL_ResolveAnchorGroup(...)`
- `DL_ResolveDialogueMode(...)`
- `DL_ResolveServiceMode(...)`

### Materialization
- `DL_BuildMaterializationPlan(npc_id, result)`
- `DL_ApplyMaterializationPlan(npc_id, plan)`

### Resync
- `DL_RunResync(npc_id, resync_reason)`

### Interaction refresh
- `DL_RefreshNpcInteractionState(npc_id, result)`

### Function slot handoff
- `DL_RequestFunctionSlotReview(function_slot_id, reason)`
- `DL_OnFunctionSlotAssigned(function_slot_id, npc_id)`

---

## 15) Anti-patterns реализации

Запрещено:
- делать один огромный `ProcessEverythingInArea()` с перемешанной логикой;
- телепортировать NPC без materialization plan;
- обновлять диалог/сервис отдельной произвольной логикой в каждом NPC-диалоге;
- тащить real travel, legal reasoning и macro trade calculation в Daily Life worker;
- использовать хаотическую сетку `DelayCommand()` как основу scheduler;
- делать WARM почти равным HOT;
- превращать resync в скрытую полную симуляцию.

---

## 16) Первый кодовый шаг

Если нужно начинать реализацию прямо сейчас, минимальный безопасный путь такой:

### Step A
Сделать enum-ы и data contracts.

### Step B
Сделать resolver без side effects.

### Step C
Сделать materialization plan builder.

### Step D
Сделать apply-layer для HOT-area.

### Step E
Сделать area worker с bounded dispatch.

### Step F
Сделать resync и interaction refresh.

### Step G
Только потом подключать slot handoff и richer overrides.

---

## 17) Нормативное резюме

Daily Life v1 должен исполняться как компактный runtime pipeline:
- area-controller решает, когда Daily Life вообще работает;
- resolver решает, что NPC должен делать;
- materialization layer решает, где и как он должен появиться;
- execution layer применяет состояние в area;
- resync восстанавливает актуальное состояние без честной симуляции прошлого;
- handoff layer сообщает во внешние системы о пустых функциях и отсутствии NPC.

Если реализация снова начинает смешивать эти этапы в одну неявную процедуру, значит Daily Life v1 уходит от канона и создаёт риск performance- и architecture-drift.
