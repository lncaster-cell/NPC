# Ambient Life v2 — Daily Life v1 Implementation Slice

Дата: 2026-03-20  
Статус: implementation slice draft  
Назначение: зафиксировать первый безопасный кодовый срез Daily Life v1: какие `.nss`-файлы нужны, какие функции должны появиться в первой итерации, какие части системы входят в старт, а какие сознательно откладываются.

---

> Этот документ опирается на:
> - `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
> - `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md`
> - `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
> - `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
>
> Он не содержит полный код. Его задача — исключить расползание первой реализации и дать агенту жёсткую карту файлов и функций.

## 1) Что такое первый implementation slice

Первая итерация Daily Life v1 должна сделать только следующее:
- создать минимальный runtime-каркас;
- реализовать deterministic resolver;
- реализовать materialization plan;
- реализовать bounded area worker;
- реализовать HOT/WARM/FROZEN поведение на базовом уровне;
- реализовать обновление диалога и сервиса от текущей директивы.

Первая итерация не должна пытаться завершить всю систему.

Она не должна включать:
- полный population/respawn слой;
- богатую интеграцию с legal/world model;
- сложные city-scale override-матрицы;
- межгородское отсутствие/миграцию как полноценную подсистему;
- все типы контента и все edge case сценарии.

---

## 2) Граница первого кодового шага

### Входит в первую реализацию
- enum-константы и локальные ключи Daily Life;
- contracts-helper слой;
- чистый resolver;
- materialization plan builder;
- apply-layer для `HOT-area`;
- resync вызов по area activation;
- area worker tick с bounded dispatch;
- refresh interaction state (`dialogue_mode`, `service_mode`).

### Не входит в первую реализацию
- реальный respawn нового NPC;
- функция поиска новой базы по миру;
- автоматическая миграция между городами;
- сложная race/clan suppression matrix;
- тяжёлые integration hooks в court/trial/trade systems;
- расширенный social pair behavior.

---

## 3) Предлагаемая карта файлов

Ниже даётся рекомендуемая карта `scripts/daily_life/` для первой итерации.

### 3.1 Базовые include-файлы

#### `scripts/daily_life/dl_const_inc.nss`
Назначение:
- enum-константы;
- имена локальных переменных;
- базовые лимиты и budget-классы;
- значения `HOT/WARM/FROZEN`;
- значения directive/dialogue/service enums.

#### `scripts/daily_life/dl_types_inc.nss`
Назначение:
- helper-контракты и packing/unpacking данных;
- единые соглашения по representation runtime state;
- lightweight helper API для profile / schedule / directive / anchor.

#### `scripts/daily_life/dl_log_inc.nss`
Назначение:
- логирование;
- log levels;
- debug flags;
- единый формат логов для Daily Life v1.

#### `scripts/daily_life/dl_util_inc.nss`
Назначение:
- безопасные utility-функции;
- проверки валидности объектов;
- дешёвые helper-предикаты;
- common guard clauses.

---

### 3.2 Resolver / ruleset

#### `scripts/daily_life/dl_resolver_inc.nss`
Назначение:
- чистый resolver;
- вычисление day type;
- вычисление schedule window;
- вычисление directive;
- вычисление anchor group;
- вычисление dialogue/service mode.

#### `scripts/daily_life/dl_schedule_inc.nss`
Назначение:
- helper-функции расписаний;
- выбор окна по времени;
- применение personal offset;
- day type modifiers.

#### `scripts/daily_life/dl_override_inc.nss`
Назначение:
- чтение read-only override-флагов;
- приоритет override;
- helper-логика применения override к directive и service/dialogue.

---

### 3.3 Materialization / execution

#### `scripts/daily_life/dl_anchor_inc.nss`
Назначение:
- выбор `anchor_group`;
- выбор конкретной точки внутри группы;
- fallback-цепочка;
- проверка допустимости anchor-контекста.

#### `scripts/daily_life/dl_materialize_inc.nss`
Назначение:
- build materialization plan;
- instant-place vs local-walk decision;
- apply materialization plan;
- hide/absent path.

#### `scripts/daily_life/dl_activity_inc.nss`
Назначение:
- выбор `activity_kind`;
- запуск нужной анимации;
- визуальное применение directive на точке.

#### `scripts/daily_life/dl_interact_inc.nss`
Назначение:
- refresh interaction state;
- установка `dialogue_mode`;
- установка `service_mode`;
- helper-флаги для диалогов и сервисов.

---

### 3.4 Area / worker / resync

#### `scripts/daily_life/dl_area_inc.nss`
Назначение:
- area tier helper API;
- определение `HOT/WARM/FROZEN`;
- area lifecycle hooks;
- registry iteration helper без полного хаотичного скана.

#### `scripts/daily_life/dl_worker_inc.nss`
Назначение:
- bounded area worker;
- due jobs dispatch;
- job budget enforcement;
- обработка ограниченного числа NPC за проход.

#### `scripts/daily_life/dl_resync_inc.nss`
Назначение:
- bounded resync;
- сравнение старого и нового runtime state;
- постановка materialization jobs;
- обработка причин `AREA_ENTER / TIER_UP / SAVE_LOAD / TIME_JUMP / OVERRIDE_END`.

---

### 3.5 Внешний handoff

#### `scripts/daily_life/dl_slot_handoff_inc.nss`
Назначение:
- сигнализация о пустом function slot;
- request review во внешний population/respawn слой;
- обработка назначения NPC в slot как read-only callback.

Нормативное правило:
- этот файл в первой итерации может содержать только каркас и заглушки вызовов.

---

### 3.6 Точки входа

#### `scripts/daily_life/dl_area_enter.nss`
Назначение:
- входной area hook для `HOT`-активации.

#### `scripts/daily_life/dl_area_exit.nss`
Назначение:
- обработка ухода последнего игрока;
- downgrade area tier.

#### `scripts/daily_life/dl_area_tick.nss`
Назначение:
- area worker gate;
- запуск bounded worker.

#### `scripts/daily_life/dl_on_load.nss`
Назначение:
- startup / load recovery hooks;
- initial resync requests.

Примечание:
- конкретные названия hook-файлов можно подстроить под текущую архитектуру модуля, но логические точки входа должны остаться именно такими.

---

## 4) Минимальный набор функций по файлам

## 4.1 `dl_const_inc.nss`

Должно содержать:
- enum constants;
- local var keys;
- worker budget constants;
- debug toggles.

Минимальные функции:
- `int DL_GetDefaultWorkerBudget();`
- `int DL_GetDefaultAreaTierBudget(int nTier);`

---

## 4.2 `dl_types_inc.nss`

Минимальные функции:
- `int DL_IsNamed(object oNPC);`
- `int DL_IsPersistent(object oNPC);`
- `int DL_GetNpcFamily(object oNPC);`
- `int DL_GetNpcSubtype(object oNPC);`
- `int DL_GetScheduleTemplate(object oNPC);`
- `object DL_GetNpcBase(object oNPC);`

Нормативное правило:
- если часть контрактов временно сидит в locals, access к ним всё равно должен идти через helper-функции, а не напрямую из всех файлов.

---

## 4.3 `dl_schedule_inc.nss`

Минимальные функции:
- `int DL_DetermineDayType(object oArea);`
- `int DL_GetPersonalTimeOffset(object oNPC);`
- `int DL_GetCurrentMinuteOfDay();`
- `int DL_DetermineScheduleWindow(int nTemplate, int nDayType, int nMinuteOfDay, int nOffset);`

---

## 4.4 `dl_override_inc.nss`

Минимальные функции:
- `int DL_HasCriticalOverride(object oNPC, object oArea);`
- `int DL_GetTopOverride(object oNPC, object oArea);`
- `int DL_ShouldSuppressMaterialization(object oNPC, int nOverrideKind);`
- `int DL_ShouldDisableService(object oNPC, int nOverrideKind);`

---

## 4.5 `dl_resolver_inc.nss`

Главная функция:
- `int DL_ResolveDirective(object oNPC, object oArea);`

Вспомогательные функции:
- `int DL_ResolveDirectiveFromSchedule(object oNPC, int nScheduleWindow, int nDayType);`
- `int DL_ApplyOverrideToDirective(object oNPC, int nDirective, int nOverrideKind);`
- `int DL_ResolveAnchorGroup(object oNPC, int nDirective);`
- `int DL_ResolveDialogueMode(object oNPC, int nDirective, int nOverrideKind);`
- `int DL_ResolveServiceMode(object oNPC, int nDirective, int nOverrideKind);`

Нормативное правило:
- resolver не должен иметь скрытых side effects.

---

## 4.6 `dl_anchor_inc.nss`

Минимальные функции:
- `object DL_FindAnchorPoint(object oNPC, object oArea, int nAnchorGroup);`
- `object DL_FindFallbackAnchorPoint(object oNPC, object oArea, int nAnchorGroup);`
- `int DL_IsAnchorContextAllowed(object oNPC, object oPoint);`

---

## 4.7 `dl_activity_inc.nss`

Минимальные функции:
- `int DL_ResolveActivityKind(object oNPC, int nDirective, int nAnchorGroup);`
- `void DL_ApplyActivity(object oNPC, int nActivityKind, object oPoint);`

---

## 4.8 `dl_materialize_inc.nss`

Минимальные функции:
- `int DL_ShouldInstantPlace(object oNPC, object oArea, object oPoint);`
- `void DL_ApplyInstantPlacement(object oNPC, object oPoint);`
- `void DL_ApplyLocalWalk(object oNPC, object oPoint);`
- `void DL_MaterializeNpc(object oNPC, object oArea);`
- `void DL_HideOrMarkAbsent(object oNPC, int nDirective);`

Нормативное правило:
- `DL_MaterializeNpc()` должна использовать resolver и anchor helpers, а не принимать решения сама “из головы”.

---

## 4.9 `dl_interact_inc.nss`

Минимальные функции:
- `void DL_SetDialogueMode(object oNPC, int nDialogueMode);`
- `void DL_SetServiceMode(object oNPC, int nServiceMode);`
- `void DL_RefreshInteractionState(object oNPC, object oArea);`

---

## 4.10 `dl_area_inc.nss`

Минимальные функции:
- `int DL_GetAreaTier(object oArea);`
- `void DL_SetAreaTier(object oArea, int nTier);`
- `int DL_ShouldRunDailyLife(object oArea);`
- `void DL_OnAreaBecameHot(object oArea);`
- `void DL_OnAreaBecameWarm(object oArea);`
- `void DL_OnAreaBecameFrozen(object oArea);`

---

## 4.11 `dl_worker_inc.nss`

Минимальные функции:
- `void DL_AreaWorkerTick(object oArea);`
- `int DL_GetWorkerBudget(object oArea);`
- `void DL_DispatchDueJobs(object oArea, int nBudget);`
- `void DL_ProcessNpcBudgeted(object oArea, object oNPC);`

Нормативное правило:
- worker должен ограничивать число обрабатываемых NPC за проход.

---

## 4.12 `dl_resync_inc.nss`

Минимальные функции:
- `void DL_RequestResync(object oNPC, int nReason);`
- `void DL_RunResync(object oNPC, object oArea, int nReason);`
- `int DL_ShouldResync(object oNPC, int nReason);`

---

## 4.13 `dl_slot_handoff_inc.nss`

Минимальные функции:
- `void DL_RequestFunctionSlotReview(string sFunctionSlotId, int nReason);`
- `void DL_OnFunctionSlotAssigned(string sFunctionSlotId, object oNPC);`

Нормативное правило:
- в первой итерации допустим каркас без полного population-layer исполнения.

---

## 5) Порядок реализации по шагам

## Step 1
Сделать только:
- `dl_const_inc.nss`
- `dl_log_inc.nss`
- `dl_util_inc.nss`
- `dl_types_inc.nss`

Цель:
- единая база enum’ов, ключей, helper-access API.

## Step 2
Сделать:
- `dl_schedule_inc.nss`
- `dl_override_inc.nss`
- `dl_resolver_inc.nss`

Цель:
- получить чистый resolver.

## Step 3
Сделать:
- `dl_anchor_inc.nss`
- `dl_activity_inc.nss`
- `dl_materialize_inc.nss`
- `dl_interact_inc.nss`

Цель:
- получить materialization + interaction refresh.

## Step 4
Сделать:
- `dl_area_inc.nss`
- `dl_worker_inc.nss`
- `dl_resync_inc.nss`
- hook entrypoints

Цель:
- получить area lifecycle и bounded worker.

## Step 5
Добавить:
- `dl_slot_handoff_inc.nss`

Цель:
- подготовить интеграцию с population/respawn без полной реализации всех внешних систем.

---

## 6) Что агенту запрещено делать в первой итерации

Запрещено:
- писать сразу всю систему целиком;
- пропускать helper/API слой и работать только через raw locals из всех мест;
- делать resolver, который сам меняет мир;
- смешивать materialization, worker и legal/trade integration в одном файле;
- строить первую версию через самодельную сетку `DelayCommand()`;
- тащить в первую версию travel-симуляцию wandering vendors.

---

## 7) Первый safe milestone

Первая безопасная точка, после которой можно переходить к следующему шагу:

### Milestone A
Работают:
- area tier helper;
- чистый resolver;
- materialization в `HOT-area`;
- refresh interaction state;
- bounded worker для ограниченного числа NPC.

Если Milestone A не достигнут стабильно, подключать дальше slot handoff и richer overrides нельзя.

---

## 8) Нормативное резюме

Первая кодовая реализация Daily Life v1 должна быть разбита на узкие include-модули с чёткой ответственностью.

Главное требование:
- resolver должен решать;
- materialization должен ставить;
- worker должен ограничивать;
- resync должен восстанавливать;
- interaction layer должен только обновлять доступность диалога и сервиса;
- handoff layer должен только сигналить наружу.

Если реализация начинает снова смешивать эти роли в несколько больших файлов с неявной логикой, значит implementation slice нарушен и систему нужно упрощать обратно.
