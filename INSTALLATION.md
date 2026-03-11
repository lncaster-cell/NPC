# Установка Ambient Life v2 (актуальная)

## 1. Импорт скриптов

Импортируйте **все** `.nss` из `scripts/ambient_life/` в модуль NWN2 и скомпилируйте.

## 2. Привязка entry scripts

### Area
- `OnEnter` → `al_area_onenter`
- `OnExit` → `al_area_onexit`
- `OnHeartbeat` / area tick hook → `al_area_tick` (если в модуле это отдельный entry)

### Module
- `OnClientLeave` → `al_mod_onleave`

### NPC (шаблон/экземпляр)
- `OnSpawn` → `al_npc_onspawn`
- `OnDeath` → `al_npc_ondeath`
- `OnUserDefined` → `al_npc_onud`
- `OnBlocked` → `al_npc_onblocked`
- `OnDisturbed` → `al_npc_ondisturbed`

## 3. Базовая настройка area locals

На area:
- `al_link_count` и `al_link_0..N` — опционально для WARM-подогрева linked areas.

Runtime сам ведёт:
- `al_player_count`, `al_tick_token`, `al_slot`, `al_sync_tick`, `al_warm_until_sync`, `al_sim_tier`, `al_npc_count`, `al_npc_<idx>`.

## 4. Базовая настройка NPC locals

Минимум:
- `alwp0..alwp5` — теги маршрутов на слоты суток;
- `al_default_activity` — fallback activity id.

Опционально для совместимости старых конфигов:
- `AL_WP_S0..AL_WP_S5`.

## 5. Настройка waypoint шагов маршрута

Для каждого waypoint шага:
- `al_step` (int, >= 0);
- `al_activity` (int, optional, иначе берётся `al_default_activity` NPC);
- `al_dur_sec` (int, optional).

Спец-шаги:
- transition: `al_trans_type`, `al_trans_src_wp`, `al_trans_dst_wp`;
- sleep: `al_bed_id` (+ `{bed}_approach`, `{bed}_pose` waypoint tags).

Полный список и правила — в `docs/TOOLSET_CONTRACT.md`.

## 6. Smoke check

1. Зайдите игроком в область с настроенными NPC.
2. Убедитесь, что при входе идёт `RESYNC` и NPC начинают routine.
3. Поменяйте игровое время на следующий 4-часовой слот — NPC должны перезапустить routine для нового маршрута.
4. Проверьте blocked кейс (дверь): должен сработать door-first и resume.
5. Проверьте disturbed кейс (добавление/кража предмета): реакция bounded, затем возврат в routine.

## 7. Частые ошибки

- Не назначен `OnUserDefined` у NPC → система почти «молчит».
- Не задан `al_step` у waypoint → шаг игнорируется в cache build.
- Маршрутный tag существует в другой area → шаги отфильтровываются.
- Переполнение area-реестра (`>100`) → лишние NPC не регистрируются.
