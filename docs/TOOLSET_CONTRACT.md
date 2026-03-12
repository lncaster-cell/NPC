# Toolset Contract (Stage I.1)

Документ определяет, какие locals задаются контентом, а какие принадлежат runtime.

## 1) NPC locals

### Контентные (обязательные)
- `alwp0..alwp5` (string) — route tag по слотам суток.
- `al_default_activity` (int) — дефолтная активность NPC.

### Контентные (опциональные, legacy)
- `AL_WP_S0..AL_WP_S5` (string) — алиасы route tags.

### Runtime-owned (не редактировать вручную)
- area/slot markers: `al_last_area`, `al_last_slot`
- route runtime/cache: `al_route_cache_*`, `al_route_rt_*`
- transition runtime: `al_trans_rt_*`
- sleep runtime: `al_sleep_rt_*`
- blocked runtime: `al_blocked_rt_active`, `al_blocked_rt_retry`
- react runtime: `al_react_active`, `al_react_type`, `al_react_resume_flag`, `al_react_last_source`, `al_react_last_item`
- current state: `al_mode`, `al_activity_current`

## 2) Waypoint locals

### Обычный маршрутный шаг
- `al_step` (int, >=0)
- `al_activity` (int, optional)
- `al_dur_sec` (int, optional)

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

## 4) Правила

- Не изменяйте runtime-owned locals из toolset-скриптов.
- Проверяйте area consistency waypoint-тегов в маршрутах.
- Не превышайте cap `AL_MAX_NPCS = 100` в активной area.
