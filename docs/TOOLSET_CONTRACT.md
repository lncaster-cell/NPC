# Toolset Contract (Stage I.2)

Документ определяет, какие locals задаются контентом, а какие принадлежат runtime.

## 1) NPC locals

### Контентные (обязательные)
- `alwp0..alwp5` (string) — route tag по слотам суток (primary lookup).
- `al_default_activity` (int) — дефолтная активность NPC.

### Контентные (опциональные, legacy)
- `AL_WP_S0..AL_WP_S5` (string) — legacy fallback-алиасы route tags (используются, только если `alwp*` пустой).
- `al_npc_role` (int) — role hint для I.2 crime/alarm:
  - `0` civilian (default)
  - `1` militia
  - `2` guard/enforcer
- `al_safe_wp` (string) — waypoint tag для civilian fallback-run при тревоге.

### Runtime-owned (не редактировать вручную)
- area/slot markers: `al_last_area`, `al_last_slot`
- route runtime/cache: `al_route_cache_*`, `al_route_rt_*`
- transition runtime: `al_trans_rt_*`
- sleep runtime: `al_sleep_rt_*`
- blocked runtime: `al_blocked_rt_active`, `al_blocked_rt_retry`
- react runtime: `al_react_active`, `al_react_type`, `al_react_resume_flag`, `al_react_last_source`, `al_react_last_item`,
  `al_react_last_crime_tick`, `al_react_last_crime_source`, `al_react_last_crime_kind` (actor-local debounce)
- crime/alarm runtime: `al_legal_followup_pending` (future legal hook marker)
- current state: `al_mode`, `al_activity_current`

## 2) Waypoint locals

### Обычный маршрутный шаг
- `al_step` (int, >=0; ожидается строгая последовательность шагов `0..N` без пропусков)
- `al_activity` (int, optional)
- `al_dur_sec` (int, optional)
- Ограничение контента: для каждого `route tag` в одной area допускается не более `16` уникальных
  валидных шагов (`AL_ROUTE_MAX_STEPS`). При превышении route-cache помечается как невалидный
  (hard-fail + fallback), а runtime пишет диагностику `al_route_overflow_count`/`al_route_overflow_tag`
  на NPC и area.

### Transition-step
- `al_trans_type`:
  - `1` — area helper
  - `2` — intra teleport
- `al_trans_src_wp` (string)
- `al_trans_dst_wp` (string)

### Sleep-step
- `al_bed_id` (string)
- ожидаемые теги waypoint:
  - `{al_bed_id}_approach`
  - `{al_bed_id}_pose`

## 3) Area locals

### Контентные (опциональные)
- `al_link_count` (int)
- `al_link_0..N` (string)

### Runtime-owned
- lifecycle/tier: `al_player_count`, `al_sim_tier`, `al_slot`
- tick/runtime: `al_tick_token`, `al_sync_tick`, `al_warm_until_sync`
- registry: `al_npc_count`, `al_npc_<idx>`
- alarm runtime (Stage I.2):
  - `al_alarm_state` (`0..3`: none/suspicious/theft/hostile-legal)
  - `al_alarm_until` (`al_sync_tick` deadline)
  - `al_alarm_source` (object)
  - `al_alarm_last_tick`, `al_alarm_last_source`, `al_alarm_last_kind` (debounce)

## 4) Правила

- Не изменяйте runtime-owned locals из toolset-скриптов.
- Периодический area tick идёт только через runtime scheduler `AL_ScheduleAreaTick`.
- Toolset `OnHeartbeat` не используется как штатный источник периодического тика (допустим только legacy bootstrap-hook без дублирования цикла).
- Проверяйте area consistency waypoint-тегов в маршрутах.
- Не превышайте cap `AL_MAX_NPCS = 100` в активной area.
- Stage I.2 использует только area-local alarm scope (без global/world propagation) и bounded nearby fan-out в текущей area.
- Guard-response опирается на built-in faction/hostility слоя NWN2, где он уже даёт корректную legal hostility базу.
- Stage I.2 не реализует guard spawn/reinforcements и не реализует surrender/arrest/trial.
