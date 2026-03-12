# Toolset Contract (Stage I.2)
<!-- DOCSYNC:2026-03-12 -->
> Documentation sync: 2026-03-12. This file was reviewed and aligned with the current repository structure.


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
- `al_safe_wp_tag` (string) — канонический waypoint tag для civilian fallback-run при тревоге.
- `al_safe_wp` (string) — legacy alias для `al_safe_wp_tag` (поддерживается на переходный период).

### Runtime-owned (не редактировать вручную)
- area/slot markers: `al_last_area`, `al_last_slot`
- route runtime/cache: `al_route_cache_*`, `al_route_rt_*`
- transition runtime: `al_trans_rt_*`
- sleep runtime: `al_sleep_rt_*`
- blocked runtime: `al_blocked_rt_active`, `al_blocked_rt_retry`
- react runtime: `al_react_active`, `al_react_type`, `al_react_resume_flag`, `al_react_last_source`, `al_react_last_item`,
  `al_react_last_crime_tick`, `al_react_last_crime_source`, `al_react_last_crime_kind` (actor-local debounce),
  safe-waypoint lookup cache/counters: `al_safe_lookup_area`, `al_safe_lookup_tick`, `al_safe_lookup_wp`, `al_safe_lookup_hit`, `al_safe_lookup_miss`
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

### Safe-waypoint для react/flee
- Канонический явный маркер: `al_is_safe_wp = 1` (int local на waypoint).
- Legacy marker (переходный период): `al_safe_wp = 1` (int local на waypoint).
- Legacy fallback (если явный маркер не проставлен): подстрока `safe/SAFE` в `tag` или `name` waypoint.
- Runtime держит NPC-local tick cache для safe-waypoint lookup (`al_safe_lookup_area`, `al_safe_lookup_tick`, `al_safe_lookup_wp`).
- При cache-hit возвращается cached waypoint; при cache-miss выполняется nearest-scan через `GetNearestObject` (до 24 waypoint в area) с fallback по `safe/SAFE` в tag/name.

Миграция контента:
- Для новых сцен используйте `al_is_safe_wp=1` + `al_safe_wp_tag` на NPC.
- Для существующих сцен с `safe*` в тегах/именах мигрируйте постепенно:
  1) проставьте `al_is_safe_wp=1` (и при необходимости legacy `al_safe_wp=1`) на целевых safe-точках;
  2) сохраните старые теги/имена на переходный период;
  3) после валидации react/flee в area можно убрать зависимость от naming convention.

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
- area health snapshot (runtime diagnostics):
  - `al_h_npc_count` — mirror текущего `al_npc_count` на последнем `AL_AreaTick`.
  - `al_h_tier` — snapshot текущего tier (`0=FREEZE`, `1=WARM`, `2=HOT`).
  - `al_h_slot` — snapshot активного slot в момент тика.
  - `al_h_sync_tick` — последний обработанный `al_sync_tick`.
  - `al_h_reg_overflow_count` — накопленный счётчик registry overflow в area.
  - `al_h_route_overflow_count` — накопленный счётчик route overflow в area.
  - `al_h_recent_resync` — число тиков с `RESYNC` в скользящем окне последних `8` тиков (`0..8`).
  - служебные runtime-поля окна/логов: `al_h_recent_resync_mask`, `al_h_last_resync_tick`, `al_h_dbg_prev_*`.
- alarm runtime (Stage I.2):
  - `al_alarm_state` (`0..3`: none/suspicious/theft/hostile-legal)
  - `al_alarm_until` (`al_sync_tick` deadline)
  - `al_alarm_source` (object)
  - `al_alarm_last_tick`, `al_alarm_last_source`, `al_alarm_last_kind` (debounce)

## 4) Правила

- Единственный источник периодического area tick — внутренний `DelayCommand`-scheduler (`AL_ScheduleAreaTick`).
- `al_area_tick` в `OnHeartbeat` допускается только как bootstrap-вызов активации area; runtime loop через heartbeat запрещён.
- Не изменяйте runtime-owned locals из toolset-скриптов.
- Периодический area tick идёт только через runtime scheduler `AL_ScheduleAreaTick`.
- Toolset `OnHeartbeat` не используется как штатный источник периодического тика (допустим только legacy bootstrap-hook без дублирования цикла).
- Проверяйте area consistency waypoint-тегов в маршрутах.
- Не превышайте cap `AL_MAX_NPCS = 100` в активной area.
- Stage I.2 использует только area-local alarm scope (без global/world propagation) и bounded nearby fan-out в текущей area.
- Guard-response опирается на built-in faction/hostility слоя NWN2, где он уже даёт корректную legal hostility базу.
- Stage I.2 не реализует guard spawn/reinforcements и не реализует surrender/arrest/trial.

## 5) Операторский preflight locals (CI-ready)

Для сервисной проверки locals контента используйте:

```bash
python3 scripts/ambient_life/al_locals_preflight.py --input <locals.json>
```

- Формат по умолчанию: `json` (машиночитаемый для CI).
- Человеко-читаемый формат: `--format text`.
- Exit code:
  - `0` — нет `ERROR`,
  - `1` — есть хотя бы один `ERROR`,
  - `2` — фатальная ошибка входных данных/парсинга.

Минимальная структура входного JSON:

```json
{
  "npcs": [
    {
      "npc_tag": "npc_market_01",
      "locals": {
        "alwp0": "market_day",
        "al_default_activity": 1,
        "al_npc_role": 0
      }
    }
  ],
  "waypoints": [
    {
      "area_tag": "area_market",
      "route_tag": "market_day",
      "waypoint_tag": "market_day_00",
      "locals": {
        "al_step": 0
      }
    }
  ],
  "areas": [
    {
      "area_tag": "area_market",
      "locals": {
        "al_link_count": 1,
        "al_link_0": "area_gate",
        "al_debug": 0
      }
    }
  ]
}
```

Пример фрагмента JSON-отчёта:

```json
{
  "status": "ERROR",
  "summary": {
    "errors": 2,
    "warnings": 1,
    "total": 3
  },
  "issues": [
    {
      "level": "ERROR",
      "scope": "waypoint",
      "object_id": "wp_sleep_1",
      "code": "invalid_bed_id",
      "reason": "al_bed_id must be non-empty string"
    }
  ]
}
```

Интерпретация:
- `ERROR` — блокирующая проблема контента (CI/preflight должен падать).
- `WARN` — неблокирующее отклонение/legacy-конфиг, требующее ревью контент-командой.
