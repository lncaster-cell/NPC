# Ambient Life — Toolset Contract (Stage I.1)

Документ фиксирует, какие locals задаются руками, а какие принадлежат runtime.

## 1) NPC locals

### 1.1 Обязательные для контента

- `alwp0..alwp5` (string): route tag по слотам суток.
- `al_default_activity` (int): дефолтная активность, если шаг не задаёт `al_activity`.

### 1.2 Опциональные (совместимость)

- `AL_WP_S0..AL_WP_S5` (string): legacy-алиасы route tags.

### 1.3 Runtime-owned (не править вручную)

- registry/runtime: `al_last_area`, `al_last_slot`;
- route cache/runtime: `al_route_cache_*`, `al_route_rt_*`;
- transition runtime: `al_trans_rt_*`;
- sleep runtime: `al_sleep_rt_*`;
- blocked runtime: `al_blocked_rt_active`, `al_blocked_rt_retry`;
- react runtime: `al_react_active`, `al_react_type`, `al_react_resume_flag`, `al_react_last_source`, `al_react_last_item`;
- state markers: `al_mode`, `al_activity_current`.

## 2) Waypoint locals

### 2.1 Обычный route step

- `al_step` (int, >=0) — индекс шага;
- `al_activity` (int, optional);
- `al_dur_sec` (int, optional).

### 2.2 Transition step (Stage F)

- `al_trans_type`:
  - `1` = area helper;
  - `2` = intra teleport.
- `al_trans_src_wp` (string tag);
- `al_trans_dst_wp` (string tag).

### 2.3 Sleep step (Stage G)

- `al_bed_id` (string): id кровати.

Ожидаемые waypoint tags:
- `{al_bed_id}_approach`
- `{al_bed_id}_pose`

## 3) Area locals

### 3.1 Контентные (опционально)

- `al_link_count` (int)
- `al_link_0..N` (string, area tag)

### 3.2 Runtime-owned

- lifecycle: `al_player_count`, `al_sim_tier`, `al_slot`;
- tick: `al_tick_token`, `al_sync_tick`, `al_warm_until_sync`;
- registry: `al_npc_count`, `al_npc_<idx>`.

## 4) Ограничения и правила

- Не редактировать runtime locals через toolset-скрипты.
- Не использовать одинаковый route tag для разных логик в одной area без явной необходимости.
- Следить, чтобы transition source waypoint был в текущей area NPC.
- Учитывать cap реестра: не более 100 зарегистрированных NPC на area.
