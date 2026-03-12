# Архитектура Ambient Life v2

## 1. Цель

Симулировать «живое» расписание NPC в NWN2 через события и area-centric runtime без per-NPC heartbeat loops.

## 2. Архитектурные принципы

- **Area-centric execution**: активность координируется из area tick scheduler (`AL_ScheduleAreaTick`).
- **Event-driven orchestration**: NPC получают сигналы через `OnUserDefined`.
- **Bounded processing**: маршруты, реакции и спец-шаги выполняются ограниченно и предсказуемо.
- **Content-configured behavior**: поведение задаётся locals на NPC/waypoints/areas.

## 3. Подсистемы

### 3.1 Lifecycle и tiers (Stage C)
- Константы tiers: `FREEZE=0`, `WARM=1`, `HOT=2`.
- HOT используется для активной симуляции; WARM — облегчённый режим удержания контекста.
- При уходе в FREEZE тик инвалидируется через token-механику.

### 3.2 Registry (Stage B)
- Плотный реестр `al_npc_0..N`, счётчик `al_npc_count`.
- Reverse-index `al_reg_rev_<stable-id> -> reg_idx+1` на area locals, где `stable-id = tag#ObjectToString(oNpc)`.
- Удаление — через swap-remove для сохранения плотности.
- Ограничение: `AL_MAX_NPCS = 100` на area.

### 3.3 Route engine (Stages D/E)
- Маршрут выбирается по слоту времени (6 слотов в сутки).
- Route cache ограничен `AL_ROUTE_MAX_STEPS = 16`.
- Для area+route-tag ведётся fingerprint-кэш на locals `al_route_fp_tick_<tag>` и `al_route_fp_value_<tag>`.
- Fingerprint считается валидным только в рамках текущего `al_sync_tick`: при повторном запросе в тот же тик возвращается сохранённое значение без повторного обхода waypoint-кандидатов.
- Сброс fingerprint-кэша выполняется теми же точками инвалидирования, что и route/lookup cache (`AL_RouteInvalidateAreaCache`, `AL_LookupSoftInvalidateAreaCache`).
- Выполнение routine bounded; при ошибках — безопасный fallback.

### 3.4 Transition subsystem (Stage F)
- Поддержка transition-step:
  - area helper;
  - intra-area teleport.
- После transition выполняется controlled route repeat.

### 3.5 Sleep subsystem (Stage G)
- Sleep-step активируется через `al_bed_id`.
- Используются точки `{bed}_approach` и `{bed}_pose`.
- При неполной разметке — fallback-поведение.

### 3.6 Activity subsystem (Stage H)
- Единый слой применения activity для route-шагов.
- Дефолтная активность задаётся на NPC.

### 3.7 Reactive subsystem (Stages I.0/I.1/I.2)
- I.0: `OnBlocked` → локальный bounded recovery.
- I.1: `OnDisturbed` → bounded override для inventory/theft, затем возврат к routine.
- I.2: локальный слой crime/alarm поверх I.1:
  - bounded классификация инцидента (`none/suspicious/theft/hostile-legal`);
  - area-local alarm state (`al_alarm_state`, `al_alarm_until`, `al_alarm_source`) с деэскалацией по `al_sync_tick`;
  - role split (`civilian/militia/guard`) без giant role framework;
  - guard-path опирается на built-in hostility/faction (`GetIsReactionTypeHostile`, `GetFactionEqual`) перед future legal-цепочкой;
  - debounce anti-spam для повторных `OnDisturbed` инцидентов (actor-local + area-local);
  - bounded локальный fan-out на nearby NPC текущей area (без world scan/spawn).

## 4. Event bus

- Slot events: `3100..3105`
- `3106`: RESYNC
- `3107`: ROUTE_REPEAT
- `3108`: BLOCKED_RESUME

Crime/alarm на Stage I.2 намеренно **не** добавляет новые события шины: эскалация выполняется внутри bounded `OnDisturbed` пути.

### 4.1 Dispatch runtime contract

- Все area-scoped события шины, потенциально затрагивающие много NPC, проходят через единый batched-dispatch путь (`AL_DispatchEventToAreaRegistry` → queue → `AL_RunBatchedDispatch`).
- Dispatch использует приоритеты:
  - `critical`: `ROUTE_REPEAT`, `BLOCKED_RESUME`;
  - `normal`: slot events + `RESYNC`.
- На каждом dispatch-тик вычисляется `drain_budget`: базовый для normal/critical, с backlog-boost при превышении порога backlog и с мягким cap для `WARM`-tier.
- Планировщик применяет critical-burst quota (несколько critical подряд), после чего принудительно даёт пройти normal-событию (как минимум одному при наличии normal-очереди) — anti-starvation.
- Введён cycle-guard на ключе `(event + cycle key)`: повторный старт одинакового цикла не допускается, дубликаты в active/queued состоянии отбрасываются.
- Метрики runtime-loop для диагностики шины:
  - `al_dispatch_queue_depth` — текущая глубина (active + queued);
  - `al_dispatch_ticks_to_drain` — ticks до полного опустошения очереди за последний цикл drain;
  - `al_dispatch_max_backlog` — максимальный observed backlog за lifetime area;
  - `al_dispatch_budget_current` — текущий drain budget для активного dispatch-тика;
  - `al_dispatch_processed_tick` — число NPC-событий, обработанных в текущем dispatch-тике;
  - `al_dispatch_backlog_before` / `al_dispatch_backlog_after` — backlog до и после обработки dispatch-тика.


### 4.2 Area health snapshot locals

Для быстрой runtime-диагностики area-loop обновляет health snapshot locals (`AL_UpdateAreaHealthSnapshot`) с разными классами частоты:

- **Критичные (каждый тик):**
  - `al_h_sync_tick` — последний sync tick, попавший в snapshot;
  - `al_h_recent_resync_mask` — rolling bitmask resync-событий за окно `AL_HEALTH_RESYNC_WINDOW_TICKS`;
  - `al_h_recent_resync` — popcount для `al_h_recent_resync_mask` (кол-во resync в текущем rolling окне);
  - `al_h_reg_index_miss_delta` — инкремент miss-счётчика за последний тик.
- **Квазистатичные (write-on-change):**
  - `al_h_npc_count` — текущее значение `al_npc_count`;
  - `al_h_tier` — текущий tier area (`FREEZE/WARM/HOT`);
  - `al_h_slot` — текущий вычисленный слот времени для HOT area;
  - `al_h_reg_overflow_count` — накопленный счётчик overflow реестра NPC;
  - `al_h_route_overflow_count` — накопленный счётчик overflow route cache;
  - `al_h_resync_window_mask` — предвычисленная маска окна (`(1 << AL_HEALTH_RESYNC_WINDOW_TICKS) - 1`) для поддержания rolling-семантики без пересчёта на каждом тикe.
- **Тяжёлые диагностические (sampling):**
  - `al_h_reg_index_miss_window_delta`;
  - `al_h_reg_index_miss_window_ticks`;
  - `al_h_reg_index_miss_warn_status`.

Sampling тяжёлых диагностических полей:

- в `HOT` обновление выполняется раз в 2 тика;
- в `WARM` обновление выполняется раз в 4 тика;
- при свежем miss-инциденте (`al_h_reg_index_miss_delta > 0`) тяжёлые поля обновляются немедленно, вне расписания sampling.

## 5. Инварианты

- Нет heartbeat/polling loop на NPC.
- Центральный runtime loop — только area tick scheduler (`AL_ScheduleAreaTick` → `DelayCommand` → `AL_AreaTick`).
- Toolset `OnHeartbeat` не является штатным периодическим путём и не должен дублировать scheduler-цикл.
- Dispatch событий работает по текущему area registry.
- Event bus должен оставаться bounded: запуск через queue с защитой от дубликатов циклов и с fairness между critical/normal приоритетами.
- Stage I.2 не включает guard spawn/reinforcements и не включает surrender/arrest/trial (оставлены только future hooks `al_legal_followup_pending`).

### 5.1 Единые guard-инварианты

- Базовые precondition-проверки вынесены в общий include `al_area_inc.nss`:
  - `AL_IsRuntimeNpc(oNpc)` — валидный непользовательский creature для runtime-пайплайнов (`route/react/blocked/registry/core`).
  - `AL_IsHotArea(oArea)` — валидная area в `AL_SIM_TIER_HOT`, где разрешена активная симуляция.
- Во всех ранних `return`-ветках используется прежняя семантика: guards только централизуют проверку, не меняя порядок и поведение fallback-логики.

### 5.2 Инвариант консистентности registry/reverse-index

- Для каждого валидного `i` в диапазоне `[0, al_npc_count)` объект `oNpc = al_npc_i` обязан иметь:
  - `oNpc.al_reg_area == oArea`;
  - `oNpc.al_reg_idx == i`;
  - `oArea.al_reg_rev_<stable-id(oNpc)> == i + 1` (смещение на +1 нужно, чтобы `0` оставался sentinel-значением «нет записи»).
- Любая операция, меняющая позицию NPC в dense-array (`register`, `unregister`, `transfer`, `compact`, `swap-with-last`), обязана синхронно обновлять reverse-index для перемещённого/удалённого NPC.
- `AL_FindNPCInRegistry` сначала читает reverse-index (быстрый путь), а линейный scan используется только как fallback/самовосстановление при рассинхроне. Для observability ведутся счётчики `al_reg_reverse_hit` / `al_reg_reverse_miss`.
