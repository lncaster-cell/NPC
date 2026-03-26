# Ambient Life v2 — Daily Life v1 Milestone A Checklist

Дата: 2026-03-20  
Статус: implementation execution checklist  
Назначение: жёсткий чек-лист для первой безопасной итерации Daily Life v1. Документ нужен как прямое задание агенту/разработчику: что делать в каком порядке, что считается готовым, какие сценарии нужно проверить до перехода дальше.

---

> Этот документ опирается на:
> - `docs/12B_DAILY_LIFE_VNEXT_CANON.md`
> - `docs/12B_DAILY_LIFE_V1_RULESET_REV1.md`
> - `docs/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
> - `docs/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
> - `docs/12B_DAILY_LIFE_V1_IMPLEMENTATION_SLICE.md`
> - `docs/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`
>
> Milestone A = первая безопасная точка, после которой можно расширять Daily Life v1 дальше.

## 1) Что такое Milestone A

Milestone A считается достигнутым только если одновременно выполняются все условия:
- есть единый слой констант и helper-access API;
- есть чистый deterministic resolver;
- есть materialization NPC в корректное состояние в `HOT-area`;
- есть обновление `dialogue_mode` и `service_mode` от текущей директивы;
- есть bounded area worker;
- нет явного ухода в hidden full simulation;
- нет смешения Daily Life с legal / trade / travel логикой.

Если хотя бы один из этих пунктов не выполнен, Milestone A не достигнут.

---

## 2) Порядок работ

Работы должны идти строго по шагам.

### Step A — Contracts foundation

Цель: создать единую базу констант и helper API.

Нужно сделать:
- `scripts/daily_life/dl_const_inc.nss`
- `scripts/daily_life/dl_log_inc.nss`
- `scripts/daily_life/dl_util_inc.nss`
- `scripts/daily_life/dl_types_inc.nss`

Минимальный результат:
- enum-like constants заведены;
- ключи locals заведены;
- чтение family/subtype/schedule/base идёт через helper-функции;
- нет raw magic numbers, размазанных по будущим файлам.

### Step B — Pure resolver

Цель: получить чистую rule-driven функцию, которая по входам выдаёт directive/anchor/dialogue/service result.

Нужно сделать:
- `scripts/daily_life/dl_schedule_inc.nss`
- `scripts/daily_life/dl_override_inc.nss`
- `scripts/daily_life/dl_resolver_inc.nss`

Минимальный результат:
- resolver не имеет side effects;
- умеет определить schedule window;
- умеет применить personal offset;
- умеет применить override;
- умеет выдать directive;
- умеет выдать `anchor_group`, `dialogue_mode`, `service_mode`.

### Step C — Materialization and interaction

Цель: по результату resolver уметь поставить NPC в правильное состояние.

Нужно сделать:
- `scripts/daily_life/dl_anchor_inc.nss`
- `scripts/daily_life/dl_activity_inc.nss`
- `scripts/daily_life/dl_materialize_inc.nss`
- `scripts/daily_life/dl_interact_inc.nss`

Минимальный результат:
- выбирается валидный anchor point;
- работает fallback цепочка;
- есть instant-place path;
- есть local-walk path только для коротких ситуаций в `HOT-area`;
- `dialogue_mode` и `service_mode` обновляются из результата resolver.

### Step D — Area worker and lifecycle

Цель: привязать Daily Life к area-tier и bounded worker.

Нужно сделать:
- `scripts/daily_life/dl_area_inc.nss`
- `scripts/daily_life/dl_worker_inc.nss`
- `scripts/daily_life/dl_resync_inc.nss`
- entrypoint hooks

Минимальный результат:
- area может быть `HOT / WARM / FROZEN`;
- `HOT-area` запускает bounded worker;
- `WARM-area` не ведёт полную жизнь;
- `FROZEN-area` молчит;
- вход в area инициирует resync/materialization.

### Step E — Stub handoff

Цель: подготовить внешний handoff, но не строить сразу всю population system.

Нужно сделать:
- `scripts/daily_life/dl_slot_handoff_inc.nss`

Минимальный результат:
- есть функция request review пустого slot;
- есть callback assignment;
- допустимы заглушки без полной респаун-логики.

---

## 3) Жёсткий scope Milestone A

### Что обязательно должно работать
- `HOT-area` materialize-ит NPC в допустимое состояние;
- как минимум 3 семейства профилей должны быть проведены сквозным путём:
  - `LAW`
  - `CRAFT`
  - `TRADE_SERVICE`
- как минимум 4 директивы должны работать end-to-end:
  - `SLEEP`
  - `WORK`
  - `SERVICE`
  - `DUTY`
- как минимум 1 override должен менять поведение:
  - `QUARANTINE` или `FIRE`
- `dialogue_mode` и `service_mode` должны реально меняться от директивы.

### Что можно оставить stub / partial
- `CIVILIAN`, `ELITE_ADMIN`, `CLERGY` можно довести частично;
- `WANDERING_VENDOR` можно довести только как presence gating без rich content;
- population handoff может быть заглушкой;
- base reassignment может быть заглушкой;
- сложные political/race/clan suppressions можно оставить за флагами.

---

## 4) Критерии готовности по шагам

## 4.1 Step A acceptance

Step A считается готовым, если:
- все базовые enum-константы сведены в один файл;
- для family/subtype/schedule/base есть helper-access API;
- прямое чтение locals из будущих слоёв не требуется;
- debug/log helper существует.

## 4.2 Step B acceptance

Step B считается готовым, если:
- resolver можно вызвать отдельно от materialization;
- одинаковые входы дают одинаковый результат;
- resolver не двигает NPC и не меняет world state;
- есть явный результат: directive + anchor_group + dialogue_mode + service_mode.

## 4.3 Step C acceptance

Step C считается готовым, если:
- materialization работает от результата resolver;
- NPC можно поставить на допустимую точку сна/работы/сервиса;
- при недоступности точки есть fallback;
- interaction state реально обновляется;
- кузнец в `WORK` и кузнец в `SOCIAL` дают разное сервисное поведение.

## 4.4 Step D acceptance

Step D считается готовым, если:
- `HOT-area` запускает обработку;
- `WARM-area` не делает полную жизнь;
- `FROZEN-area` не тикает как живая area;
- worker имеет budget limit;
- вход игрока в area инициирует bounded resync.

## 4.5 Step E acceptance

Step E считается готовым, если:
- есть API request slot review;
- есть API on slot assigned;
- Daily Life не пытается сам респаунить NPC.

---

## 5) Базовые тестовые сценарии

Ниже сценарии, которые должны быть пройдены до признания Milestone A готовым.

## 5.1 Scenario A — кузнец, рабочее окно

Исходные данные:
- NPC family = `CRAFT`
- subtype = `BLACKSMITH`
- schedule = `EARLY_WORKER`
- время = рабочее окно
- override нет
- база валидна

Ожидается:
- directive = `WORK`
- anchor group = `WORK`
- materialization на forge/anvil/workbench
- service mode = `AVAILABLE` или `LIMITED`
- dialogue mode = `WORK`

## 5.2 Scenario B — кузнец, нерабочее окно / социалка

Исходные данные:
- тот же кузнец
- время = вечернее social/rest окно
- override нет

Ожидается:
- directive != `WORK`
- service не доступен как рабочий сервис
- dialogue mode не рабочий
- возможна постановка в `SOCIAL` anchor group

## 5.3 Scenario C — постовой на воротах

Исходные данные:
- NPC family = `LAW`
- subtype = `GATE_POST`
- schedule = `DUTY_ROTATION_DAY`
- время = дневное duty окно

Ожидается:
- directive = `DUTY` или `HOLD_POST`
- anchor group = `GATE` / `DUTY`
- activity = guard/idle duty
- dialogue mode = inspection/off-duty по окну

## 5.4 Scenario D — трактирщик поздним вечером

Исходные данные:
- family = `TRADE_SERVICE`
- subtype = `INNKEEPER`
- schedule = `TAVERN_LATE`
- время = позднее service/social окно

Ожидается:
- directive = `SERVICE` или поздний social-compatible service state
- service доступен
- anchor group = `SERVICE` / `SOCIAL`

## 5.5 Scenario E — карантин

Исходные данные:
- обычный торговец
- schedule = `SHOP_DAY`
- override = `QUARANTINE`

Ожидается:
- directive = `LOCKDOWN_BASE` или equivalent suppress path
- public/service presence режется
- service mode = disabled/limited
- materialization в base/safe контекст, а не на открытую торговую точку

## 5.6 Scenario F — вход игрока в area

Исходные данные:
- area была неактивна
- игрок вошёл
- в area несколько NPC разных профилей

Ожидается:
- выполняется bounded resync;
- NPC materialize-ятся в правдоподобное текущее состояние;
- не проигрывается весь пропущенный путь;
- нет заметного хаотичного телепорта у игрока перед глазами.

## 5.7 Scenario G — WARM / FROZEN

Исходные данные:
- area переводится из `HOT` в `WARM`, затем в `FROZEN`

Ожидается:
- `WARM` не живёт как полноценная active-area;
- `FROZEN` молчит;
- нет full routine execution без игрока.

---

## 6) Что агент должен писать в лог

Во время Milestone A должны существовать читаемые лог-сообщения минимум для:
- area tier changes;
- resolver result;
- chosen directive;
- chosen anchor group;
- chosen point / fallback usage;
- dialogue/service refresh;
- resync reason;
- worker budget reached.
- smoke snapshot по ключевым NPC-сценариям (`LAW/CRAFT/TRADE_SERVICE`) при включённом флаге `dl_smoke_trace`.

Это нужно, чтобы отладка шла по фактам, а не наугад.

### 6.1 Runtime smoke trace (минимальный verification path)

- Для точечной проверки сценариев A–E можно включить module-local флаг `dl_smoke_trace = TRUE`.
- При включённом флаге worker после `DL_RunResync` пишет строку `smoke snapshot` с полями:
  - `reason`
  - `family`
  - `subtype`
  - `directive`
  - `dialogue`
  - `service`
  - `override`
- Это даёт быстрый журнал, по которому видно, что `dialogue_mode` и `service_mode` реально меняются по сценариям, а не только «ожидаются по коду».

---

## 7) Признаки провала Milestone A

Milestone A считается проваленным, если наблюдается хотя бы одно из следующего:
- resolver меняет world state;
- NPC получают состояние напрямую из waypoint-логики без директивы;
- `WARM-area` начинает жить как полноценная `HOT-area`;
- worker не bounded;
- диалоги сами решают, работает NPC или нет, вместо чтения runtime state;
- для простой смены времени суток приходится трогать много несвязанных файлов;
- логика работы, сна и сервиса размазана по разным слоям без единого resolver пути.

---

## 8) Что делать после Milestone A

Только после успешного закрытия Milestone A разрешается двигаться в:
- richer override matrix;
- population slot handoff с реальным внешним исполнением;
- более полные civilian / elite / clergy templates;
- rule sets для crisis/collapse режимов;
- базовый wandering vendor presence layer;
- расширенные interaction states.

До достижения Milestone A добавлять эти слои нельзя.

---

## 9) Нормативное резюме

Milestone A — это не «кусок кода написан».
Milestone A — это момент, когда Daily Life v1 уже работает как система:
- deterministic;
- bounded;
- area-tier aware;
- rule-driven;
- с materialization вместо симуляции;
- с реальным влиянием директивы на точку, анимацию, диалог и сервис.

Если после реализации этих шагов система всё ещё выглядит как набор разрозненных скриптов без единого resolver/materialization pipeline, значит Milestone A не достигнут и архитектуру нужно чинить до расширения функциональности.

Практическая фиксация результата выполняется в `docs/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`.
