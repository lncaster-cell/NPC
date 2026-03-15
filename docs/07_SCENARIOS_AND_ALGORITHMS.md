# Ambient Life v2 — Сценарии, алгоритмы, системы и механики (каталог)

Цель: восстановить «карту того, что уже разработано» в одном документе и синхронизировать её с runtime-файлами.

## 1. Системы (верхний уровень)

1. **Core + Area lifecycle**
   - Файлы: `al_core_inc.nss`, `al_area_inc.nss`, `al_area_tick.nss`, `al_area_onenter.nss`, `al_area_onexit.nss`, `al_mod_onleave.nss`.
2. **Registry + lookup/cache + dispatch**
   - Файлы: `al_registry_inc.nss`, `al_lookup_cache_inc.nss`, `al_dispatch_inc.nss`, `al_events_inc.nss`.
3. **Route/transition/sleep/activity**
   - Файлы: `al_route_inc.nss`, `al_route_cache_inc.nss`, `al_route_runtime_api_inc.nss`, `al_transition_inc.nss`, `al_transition_post_area.nss`, `al_sleep_inc.nss`, `al_activity_inc.nss`, `al_acts_inc.nss`.
4. **Reactive + city layer**
   - Файлы: `al_blocked_inc.nss`, `al_react_inc.nss`, `al_react_apply_step.nss`, `al_react_resume_reset.nss`, `al_city_registry_inc.nss`, `al_city_crime_inc.nss`, `al_city_alarm_inc.nss`, `al_city_population_inc.nss`, `al_health_inc.nss`.
5. **Action wrappers и hook-скрипты NPC**
   - Файлы: `al_action_signal_ud.nss`, `al_action_set_mode.nss`, `al_npc_onspawn.nss`, `al_npc_onud.nss`, `al_npc_onblocked.nss`, `al_npc_ondisturbed.nss`, `al_npc_ondamaged.nss`, `al_npc_onphysicalattacked.nss`, `al_npc_onspellcastat.nss`, `al_npc_ondeath.nss`.

## 2. Разработанные сценарии (runtime)

### 2.1 Базовый lifecycle сценарий
- Вход NPC в area -> регистрация -> участие в area tick orchestration.
- Выход/удаление -> корректный уход из registry и служебных структур.

### 2.2 Сценарий routine по слотам суток
- Slot event (`AL_EVENT_SLOT_0..5`) выбирает route tag для текущего времени.
- Route step обрабатывается bounded-циклом, с fallback на safe/default поведение.

### 2.3 Сценарий маршрута с переходом между area
- Route step помечается transition-типом.
- Проверяются endpoint-ы и target area.
- Выполняется переход и post-area синхронизация registry.

### 2.4 Сценарий sleep lifecycle
- Step с `al_bed_id` переводит NPC в sleep-контур.
- Sleep выполняется отдельно от обычного activity исполнения.
- По wake-up NPC возвращается в routine pipeline.

### 2.5 Сценарий blocked recovery
- `OnBlocked` -> локальный door-first unblock.
- При неуспехе — bounded resync/resume через отдельный event hook.

### 2.6 Сценарий disturbed/crime escalation
- `OnDisturbed` и профильные producer hooks инициируют локальную реакцию.
- Crime типизируется (theft/assault/murder/spell-related cases).
- City alarm state изменяется через desired/live модель, без global аггро.

### 2.7 Сценарий alarm recovery
- После активной тревоги система переводится в recovery-стадию.
- Назначения/роли постепенно возвращаются в нормальный режим bounded-пачками.

### 2.8 Сценарий population respawn
- На `OnSpawn/OnDeath` поддерживаются alive/target/deficit счётчики city population runtime.
- Респаун выполняется только для unnamed-дефицита, с cooldown, budget и safe-distance ограничениями.
- Materialization и respawn разведены по разным контурам, чтобы не нарушать bounded-профиль.

## 3. Алгоритмы и стратегии (что реально используется)

1. **Bounded dispatch queue**
   - Очередь событий area-уровня с ограниченной глубиной, backpressure и дренаж-метриками.
2. **Dense area registry + diagnostics**
   - Индексированный учёт NPC, maintenance-компактизация, fallback lookup и диагностика miss-rate.
3. **Route-area cache**
   - Кэш шагов маршрута по тегу с fingerprint/content-version и контролируемым rebuild.
4. **Transition endpoint resolution**
   - Проверка source/destination waypoint + destination area с диагностикой неоднозначности.
5. **Sleep special-case execution**
   - Sleep IDs не исполняются обычным activity-путём и идут через отдельный runtime.
6. **City alarm FSM**
   - Состояния idle/pending/active/clearing/recovery и ограниченная материализация ролей.

## 4. Событийные контракты (внутренний bus)

- Slot events: `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`.
- Service events: `AL_EVENT_RESYNC`, `AL_EVENT_ROUTE_REPEAT`, `AL_EVENT_BLOCKED_RESUME`.
- City assignment events:
  - `AL_EVENT_CITY_ASSIGN_GO_SHELTER`
  - `AL_EVENT_CITY_ASSIGN_GO_ARSENAL`
  - `AL_EVENT_CITY_ASSIGN_HOLD_WAR_POST`
  - `AL_EVENT_CITY_ASSIGN_ALARM_RECOVERY`

## 5. Механики: статус синхронизации

- **Реализованы:** lifecycle, registry/dispatch, route-cache, routine, transition, sleep, activity, blocked/disturbed, локальный city crime/alarm, population respawn и runtime health checks.
- **Подготовлены hooks:** legal followup marker (`al_legal_followup_pending`).
- **Не завершены (Stage I.3):** reinforcement policy, surrender/arrest/trial pipeline, расширенный legal smoke контур.

## 6. Что считать источником правды

1. Runtime поведение: `scripts/ambient_life/*`.
2. Канон механик и операционных требований: `docs/02_MECHANICS.md`, `docs/03_OPERATIONS.md`, `docs/04_CONTENT_CONTRACTS.md`.
3. Статус «сделано/планируется/пробелы»: `docs/18_REBUILD_RESET_CONTEXT.md`.
