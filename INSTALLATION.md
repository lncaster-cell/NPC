# Установка и подключение Ambient Life v2

## 1) Импорт скриптов

Импортируйте и скомпилируйте все `.nss` из `scripts/ambient_life/`.

## 2) Привязка entry scripts

### Area
- `OnEnter` → `al_area_onenter`
- `OnExit` → `al_area_onexit`
- `OnHeartbeat` (или отдельный area tick hook) → `al_area_tick`

### Module
- `OnClientLeave` → `al_mod_onleave`

### NPC
- `OnSpawn` → `al_npc_onspawn`
- `OnDeath` → `al_npc_ondeath`
- `OnUserDefined` → `al_npc_onud`
- `OnBlocked` → `al_npc_onblocked`
- `OnDisturbed` → `al_npc_ondisturbed`

## 3) Обязательная настройка контента

### NPC
- `alwp0..alwp5` — route tag по 6 слотам суток.
- `al_default_activity` — fallback activity.

(Опционально для legacy-контента: `AL_WP_S0..AL_WP_S5`.)

### Waypoint (обычные шаги)
- `al_step` (int, >=0)
- `al_activity` (int, optional)
- `al_dur_sec` (int, optional)

### Waypoint (спец-шаги)
- transition: `al_trans_type`, `al_trans_src_wp`, `al_trans_dst_wp`
- sleep: `al_bed_id` + waypoint tags `{bed}_approach`, `{bed}_pose`

### Area (опционально)
- `al_link_count`
- `al_link_0..N`

## 4) Smoke-check после подключения

1. Войти игроком в area с настроенными NPC.
2. Проверить запуск `RESYNC` и старт routine.
3. Сменить время на следующий 4-часовой слот — routine должен переключиться.
4. Проверить blocked-кейс (дверь/проход) — должен отработать resume/resync.
5. Проверить disturbed-кейс (инвентарь/кража) — bounded-реакция с возвратом к routine.

## 5) Типичные проблемы

- Нет `OnUserDefined` у NPC — core-логика не исполняется.
- Не задан `al_step` у waypoint — шаг не попадает в route cache.
- Route tag указывает на waypoint в другой area — шаги фильтруются, возможен fallback.
- В area больше 100 NPC — часть NPC не регистрируется в runtime.
