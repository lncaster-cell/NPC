# Технический паспорт проекта: NPC Ambient Life v2 (NWN2)
<!-- DOCSYNC:2026-03-13 -->
> Documentation sync: 2026-03-13. This file was reviewed and aligned with the current repository structure.


## 1) Назначение документа

Этот документ — единая «точка входа» для инженеров и AI-агентов, которым нужно быстро понять:

- что делает система Ambient Life v2;
- как устроен runtime и какие инварианты нельзя нарушать;
- какие файлы за что отвечают;
- как правильно интегрировать, диагностировать и развивать систему.

Документ агрегирует ключевую информацию из `README`, архитектурных и операционных документов, а также из runtime-скриптов.

---

## 2) Что такое Ambient Life v2

Ambient Life v2 — это событийная система симуляции распорядка NPC в NWN2.

Ключевая идея: **никаких per-NPC heartbeat/polling циклов**. Вместо этого используется:

- area-centric цикл (`AL_ScheduleAreaTick` → `AL_AreaTick`),
- event bus на `OnUserDefined`,
- ограниченные (bounded) операции на каждом тике/событии.

Это снижает нагрузку и даёт предсказуемость при высокой плотности NPC.

---

## 3) Границы реализации (текущее состояние)

Реализованы стадии: **A–I.2**.

- A: контракты и основа архитектуры.
- B: event bus + area registry.
- C: lifecycle и LOD tiers (`FREEZE/WARM/HOT`).
- D/E: route cache + bounded routine progression.
- F: transition subsystem.
- G: sleep subsystem.
- H: activity subsystem.
- I.0: `OnBlocked` recovery.
- I.1: `OnDisturbed` foundation.
- I.2: локальный crime/alarm слой (в пределах area).

Вне границ текущего релиза (I.3+):

- guard spawn/reinforcements;
- surrender/arrest/trial/legal pipeline.

---

## 4) Архитектурные принципы (обязательные)

1. **Single runtime loop per area**: только scheduler на area-уровне.
2. **Event-driven orchestration**: NPC обрабатывают команды через `OnUserDefined`.
3. **Bounded execution**: маршруты, реактивные ветки и dispatch всегда ограничены по объёму.
4. **Content-configured behavior**: поведение задаётся locals в toolset.
5. **Runtime-owned locals immutable from content**: runtime-ключи руками не редактируются.

Нарушение любого из этих принципов ведёт к деградации производительности и/или рассинхронизации состояния.

---

## 5) Карта репозитория и зоны ответственности

### 5.1 Корневые документы

- `README.md` — обзор проекта, статус стадий, быстрый старт.
- `INSTALLATION.md` — пошаговая интеграция в модуль NWN2.
- `TASKS.md` — backlog и регулярные QA-практики.

### 5.2 Техническая документация

- `docs/ARCHITECTURE.md` — архитектура, инварианты, event bus, health snapshot.
- `docs/TOOLSET_CONTRACT.md` — полный контракт locals (NPC/Waypoint/Area).
- `docs/MECHANICS_DESIGN_BRIEFS.md` — краткие дизайн-доки ключевых механик.
- `docs/IMPLEMENTATION_ROADMAP.md` — дорожная карта развития.
- `docs/PERF_PROFILE.md` — регламент perf-профилирования.
- `docs/PERF_RUNBOOK.md` — воспроизводимый perf-runbook.

### 5.3 Runtime-скрипты (`scripts/ambient_life/`)

**Entry points (привязка к событиям движка):**

- `al_mod_onleave.nss` — `OnClientLeave` модуля.
- `al_area_onenter.nss` — `OnEnter` area.
- `al_area_onexit.nss` — `OnExit` area.
- `al_area_tick.nss` — legacy bootstrap hook (не основной тик).
- `al_npc_onspawn.nss` — `OnSpawn` NPC.
- `al_npc_ondeath.nss` — `OnDeath` NPC.
- `al_npc_onud.nss` — `OnUserDefined` NPC.
- `al_npc_onblocked.nss` — `OnBlocked` NPC.
- `al_npc_ondisturbed.nss` — `OnDisturbed` NPC.

**Core includes:**

- `al_core_inc.nss` — центральный dispatcher и связка подсистем.
- `al_area_inc.nss` — lifecycle/tiers/tick loop + health snapshot.
- `al_dispatch_inc.nss` — queue-based dispatch, priorities, fairness, anti-dup.
- `al_registry_inc.nss` — плотный area registry (`al_npc_0..N`, swap-remove).
- `al_events_inc.nss` — константы шины событий.
- `al_route_inc.nss` — route cache + bounded routine.
- `al_transition_inc.nss` — transition runtime (area helper/intra-teleport).
- `al_sleep_inc.nss` — sleep runtime.
- `al_activity_inc.nss` + `al_acts_inc.nss` — activity semantics и канонические ID.
- `al_blocked_inc.nss` — локальное восстановление после `OnBlocked`.
- `al_react_inc.nss` — disturbed/crime/alarm реакции (I.1/I.2).
- `al_city_registry_inc.nss` — city-level registry (district membership/type, bells/arsenals/war posts/shelters, active case refs).
- `al_city_alarm_inc.nss` — city alarm FSM и district desired/live-state materialization.
- `al_city_crime_inc.nss` — city crime cases + escalation hooks (`OnDisturbed`/`OnPhysicalAttacked`/`OnDamaged`/`OnDeath`/`OnSpellCastAt`).
- `al_debug_inc.nss`, `al_schedule_inc.nss` — **DEPRECATED/STUB** файлы Stage A;
  оставлены только для обратной совместимости старых include-графов,
  в новом коде использовать нельзя.

### 5.4 Deprecated/STUB policy

- `al_debug_inc.nss` и `al_schedule_inc.nss` не содержат runtime-логики и считаются
  временными заглушками до полного удаления.
- Условие удаления: подтверждено отсутствие прямых и транзитивных подключений этих
  include в entry/core-скриптах и в модульном контенте.
- Для новых include действует запрет: нельзя добавлять зависимости на
  `al_debug_inc.nss` и `al_schedule_inc.nss`.

---

## 6) Сквозной runtime-поток (от и до)

### 6.1 Инициализация

1. Игрок входит в area → `al_area_onenter`.
2. Lifecycle активирует area, повышает tier до HOT при необходимости.
3. Запускается внутренний scheduler (`AL_ScheduleAreaTick`).

### 6.2 Периодический цикл

1. По интервалу `AL_AREA_TICK_SEC` выполняется `AL_AreaTick`.
2. Обновляются lifecycle/slot/sync-маркеры.
3. Формируются/очередятся area-события (slot/resync/служебные).
4. Dispatch обрабатывает события batched-очередью по приоритетам.
5. События доходят до NPC через `OnUserDefined`.
6. `al_core_inc` делегирует в route/sleep/transition/react/blocked логику.

### 6.3 Смена маршрута и routine progression

1. Для активного slot берётся route tag из `alwp0..alwp5`.
2. В area собираются waypoint с этим tag.
3. Шаги сортируются по `al_step`, валидируются и кешируются.
4. Для area+route-tag дополнительно поддерживается fingerprint-кэш (`al_route_fp_tick_<tag>`, `al_route_fp_value_<tag>`):
   - fingerprint считается валидным только в пределах текущего `al_sync_tick`;
   - повторные запросы fingerprint в тот же тик обязаны использовать локальный кэш без повторного обхода waypoint-списка;
   - fingerprint строится из семантически значимых locals шага: `al_step`, `al_activity`, `al_dur_sec`, transition (`al_trans_type`, `al_trans_src_wp`, `al_trans_dst_wp`) и sleep (`al_bed_id`);
   - сброс fingerprint выполняется в стандартных точках инвалидирования route/lookup (`AL_RouteInvalidateAreaCache`, `AL_LookupSoftInvalidateAreaCache`).
5. NPC выполняет bounded progression по шагам.
6. При спец-шаге включается transition/sleep слой.

### 6.4 Реактивные ветки

- `OnBlocked` → door-first attempt + bounded resume/fallback.
- `OnDisturbed` → классификация инцидента (none/suspicious/theft/hostile-legal),
  локальная тревога area, bounded fan-out на nearby NPC, затем возврат к routine.

### 6.5 Деактивация

- При уходе игроков tier может снижаться HOT → WARM → FREEZE.
- При FREEZE тик-инвалидируется token-механикой.
- Повторная активация идёт через lifecycle события area.

---

## 7) Event bus и dispatch-контракт

### 7.1 События

- `AL_EVENT_SLOT_0..5 = 3100..3105`
- `AL_EVENT_RESYNC = 3106`
- `AL_EVENT_ROUTE_REPEAT = 3107`
- `AL_EVENT_BLOCKED_RESUME = 3108`

### 7.2 Политика обработки

- Все area-scoped массовые события идут через `AL_DispatchEventToAreaRegistry`.
- Очередь ограничена (`AL_DISPATCH_QUEUE_CAPACITY`).
- Приоритеты:
  - critical: `ROUTE_REPEAT`, `BLOCKED_RESUME`;
  - normal: slot events, `RESYNC`.
- Fairness: critical burst quota + anti-starvation normal.
- Cycle-guard не допускает дубликаты активных/ожидающих циклов.

### 7.3 Crime/alarm в I.2

- Новые event-коды шины **не** добавляются.
- Эскалация выполняется внутри bounded `OnDisturbed` пути.

---

## 8) Модель данных (locals)

### 8.1 NPC (content-owned)

Обязательные:

- `alwp0..alwp5` (route tags по слотам)
- `al_default_activity` (int)

Опциональные:

- `AL_WP_S0..AL_WP_S5` (legacy fallback)
- `al_npc_role` (`0` civilian / `1` militia / `2` guard)
- `al_safe_wp_tag` (канонический tag safe waypoint для fallback-поведения)
- `al_safe_wp` (legacy alias на переходный период)

### 8.2 Waypoint (content-owned)

- `al_step` (обязателен для route-шага)
- `al_activity`, `al_dur_sec` (опционально)
- transition: `al_trans_type`, `al_trans_src_wp`, `al_trans_dst_wp`
- sleep: `al_bed_id` + точки `{bed}_approach`, `{bed}_pose`
- safe-point marker: `al_is_safe_wp = 1` (канонический формат)
- legacy marker: `al_safe_wp = 1` (переходный период)

### 8.3 Area (content-owned)

- `al_link_count`
- `al_link_0..N`

### 8.4 Runtime-owned (из toolset не редактировать)

Примеры ключевых runtime locals:

- area lifecycle: `al_player_count`, `al_sim_tier`, `al_slot`, `al_sync_tick`;
- registry: `al_npc_count`, `al_npc_<idx>`;
- route/runtime: `al_route_cache_*`, `al_route_rt_*`;
- blocked/react/alarm runtime;
- health snapshot: `al_h_*`.

Полный контракт — в `docs/TOOLSET_CONTRACT.md`.

---

## 9) Константы и лимиты

- `AL_AREA_TICK_SEC = 30.0`
- `AL_MAX_NPCS_DEFAULT = 100` на area
- `al_max_npcs` (area/module local, optional): effective registry cap в диапазоне `20..200`; приоритет источников: area -> module -> `AL_MAX_NPCS_DEFAULT`
- `AL_ROUTE_MAX_STEPS = 16`
- `AL_WARM_RETENTION_TICKS = 2`
- `AL_WP_CACHE_TTL_TICKS = 10`
- `AL_HEALTH_RESYNC_WINDOW_TICKS = 8`

Ограничения важны: overflow по registry/route не должен считаться нормальным рабочим состоянием.

---

## 10) Наблюдаемость и диагностика

### 10.1 Area Health Snapshot (`al_h_*`)

Ключевые метрики и политика обновления:

- **Критичные (каждый тик):**
  - `al_h_sync_tick`
  - `al_h_recent_resync`
  - `al_h_recent_resync_mask`
  - `al_h_reg_index_miss_delta`
- **Квазистатичные (только при изменении):**
  - `al_h_npc_count`
  - `al_h_tier`
  - `al_h_slot`
  - `al_h_reg_overflow_count`
  - `al_h_route_overflow_count`
- **Тяжёлые диагностические (sampling):**
  - `al_h_reg_index_miss_window_delta`
  - `al_h_reg_index_miss_window_ticks`
  - `al_h_reg_index_miss_warn_status`

Sampling-политика для тяжёлых полей:

- `HOT`: обновление раз в 2 тика;
- `WARM`: обновление раз в 4 тика;
- при новом инциденте (`al_h_reg_index_miss_delta > 0`) тяжёлые поля пишутся немедленно, вне периода sampling.

### 10.2 Dispatch-метрики

- `al_dispatch_queue_depth`
- `al_dispatch_ticks_to_drain`
- `al_dispatch_max_backlog`

### 10.3 Alarm runtime

- `al_alarm_state`, `al_alarm_until`, `al_alarm_source`
- debounce-поля (`al_alarm_last_*`, `al_react_last_crime_*`)

Эти поля используются как основной операторский срез состояния системы.

---

## 11) Интеграция в модуль NWN2 (кратко)

1. Импортировать все `scripts/ambient_life/*.nss`, скомпилировать.
2. Привязать скрипты на Module/Area/NPC события.
3. Заполнить контентные locals по контракту.
4. Пройти smoke-check и perf-check.

Важно:

- `OnHeartbeat` area не используется как основной периодический путь;
- `al_area_tick` допускается только как legacy bootstrap.

Подробно — `INSTALLATION.md`.

---

## 12) Производительность и QA-практика

- Использовать `docs/PERF_RUNBOOK.md` для сцен L/M/H.
- Сверять KPI и отчёт «до/после» по шаблону из `docs/PERF_PROFILE.md`.
- В регулярной QA-практике контролировать пороги health snapshot и признаки overflow/backlog.

### 12.1 Интерпретация overflow при dynamic cap

- `al_reg_overflow_count` — монотонный счётчик за lifetime area (не обнуляется при смене cap).
- `al_reg_overflow_count_at_cap_change` — снимок общего overflow на момент последней смены effective-cap.
- `al_reg_overflow_count_cap = al_reg_overflow_count - al_reg_overflow_count_at_cap_change` — overflow в текущем cap-контексте.
- `al_reg_cap_effective` — фактически применённый cap после clamp/fallback.

Операторское правило: для оценки «здоровья» после изменения `al_max_npcs` использовать именно `al_reg_overflow_count_cap`, а `al_reg_overflow_count` — как общий исторический счётчик area.

Контракт `al_max_npcs`:
- тип: `int`;
- область: area local (приоритет), module local (fallback);
- валидный диапазон: `20..200` включительно;
- невалидные значения (`<=19`, `>=201`, `0`, отрицательные) не применяются и переводят cap на следующий fallback-источник;
- при отсутствии валидного local используется `AL_MAX_NPCS_DEFAULT`.

### 12.2 Perf-сравнение S80/S100/S120 для выбора cap (операторская матрица)

Сравнение выполняется в `docs/PERF_PROFILE.md`-шаблоне на сценариях S80/S100/S120 при трёх профилях cap: `80`, `100`, `120`.

| Сценарий | Cap=80 | Cap=100 | Cap=120 | Рекомендация |
| --- | --- | --- | --- | --- |
| S80 | допустимо только при стабильном составе NPC; риск всплесков `al_reg_overflow_count_cap` при миграциях | **базовый безопасный профиль** | избыточный запас, возможен лишний runtime-footprint | `100` (по умолчанию) |
| S100 | систематический overflow при пиках регистрации | **целевой профиль** | безопасный запас при burst-событиях | `100` для обычных area, `120` для пиковых |
| S120 | ожидаемый постоянный overflow | вероятен WARN/CRITICAL по overflow | **единственный рабочий профиль без штатного overflow** | `120` для high-density area |

Практическое правило выбора:
1. Стартовать с `al_max_npcs=100` (или без local, что эквивалентно).
2. Если в S100 наблюдается рост `al_reg_overflow_count_cap`, повышать до `120`.
3. Значение `80` использовать только для намеренно ограниченных area (контент-гейтинг), а не как perf-оптимизацию общего профиля.
4. В smoke-отчёте по cap-профилям (`80/100/120`) обязательно фиксировать `al_reg_overflow_count` и `al_dispatch_q_overflow` для каждого профиля.

---

## 13) Известные риски и техдолг

Приоритетные темы (по backlog/аудиту):

- диагностика отказа `AL_RegisterNPC` при effective-cap (`AL_MAX_NPCS_DEFAULT`/`al_max_npcs`);
- унификация подключения `al_area_tick` в разных шаблонах модулей;
- контент-валидация маршрутов и locals;
- расширение legal/reinforcement цепочек (Stage I.3).

---

## 14) Правила безопасных изменений для AI-агентов

1. Не вводить heartbeat-loop на NPC/area.
2. Не обходить dispatch-очередь для массовых area-событий.
3. Сохранять bounded-характер любых новых веток.
4. Не писать вручную в runtime-owned locals.
5. Для новых механик сначала фиксировать контракт locals и инварианты в документации.
6. Любые изменения Stage I.2+ проверять на совместимость с:
   - role split (civilian/militia/guard),
   - area-local scope,
   - anti-spam/debounce.

---

## 15) Быстрый глоссарий

- **Area-centric runtime** — единый цикл симуляции на area.
- **Slot** — 4-часовой интервал времени суток (`0..5`).
- **Route tag** — тег маршрута, связывающий NPC и waypoint-группу.
- **Bounded** — ограниченное, предсказуемое по объёму выполнение.
- **RESYNC** — синхронизация NPC с актуальным slot/route-состоянием.
- **WARM retention** — кратковременное удержание контекста area без полного HOT-режима.

---

## 16) Ссылки на первоисточники

- `README.md`
- `INSTALLATION.md`
- `docs/ARCHITECTURE.md`
- `docs/TOOLSET_CONTRACT.md`
- `docs/MECHANICS_DESIGN_BRIEFS.md`
- `docs/PERF_RUNBOOK.md`
- `docs/PERF_PROFILE.md`
- `docs/IMPLEMENTATION_ROADMAP.md`
- `TASKS.md`


### 7.4 City Alarm FSM + district runtime (Phase 2)
- States: `IDLE`, `PENDING_ALARM`, `ACTIVE_ALARM`, `CLEARING`, `RECOVERY`.
- Runtime source of truth: city locals on module keyed by `al_city_id`.
- Integration: `AL_AreaTick` (HOT only) calls district runtime step `AL_CityAlarmRuntimeTickHot` with bounded batches; no per-NPC heartbeats added.
- PENDING_ALARM bell workflow has timeout fallback (`AL_CITY_ALARM_BELL_TIMEOUT_TICKS`) so state cannot hang forever.
- ACTIVE_ALARM behavior in HOT district:
  - civilian -> `go_shelter`;
  - militia -> `go_arsenal` (hide/show + alarm loadout) then `hold_war_post`;
  - guard -> `hold_war_post` to nearest free post.
- war-post occupancy:
  - shared guard/militia pool;
  - hard cap `AL_CITY_WAR_POST_CAPACITY=5` per post;
  - nearest-free selection;
  - if no free post exists, NPC keeps routine/guard path (no forced invalid assignment).
- CLEARING/RECOVERY path:
  - recovery assignment is issued in bounded batches;
  - militia returns to arsenal and restores normal loadout;
  - civilians/others are resynced back to routine model via existing `RESYNC` path.
- non-HOT district:
  - only desired state (`al_city_alarm_desired_state`) is stored;
  - on area activate/NPC spawn runtime materializes expected state (sheltered civilians, militia alarm-loadout, war-post-ready defenders) without offscreen live simulation.

### 7.5 City Crime foundation (Phase 2 escalation contract)
- Theft opens city crime case only (no city alarm escalation).
- Assault/hostile damage/spell opens assault case and escalates alarm via `PENDING_ALARM` (or reinforces ACTIVE if alarm already running).
- Single-NPC interior death opens latent `HIDDEN_MURDER` case (no immediate alarm and no synthetic offscreen discovery).
- Enemy clear path depends on creature-level enemy registry; alarm clear re-checks active enemies and enters CLEARING/RECOVERY.
