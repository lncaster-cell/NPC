# Builder-friendly Daily Life setup (RU)

> Обновлено: **2026-04-27**

## Цель

Снизить ручную настройку NPC в Toolset. Для обычного NPC в одной area должно быть достаточно:

```text
NPC local:
dl_profile_id = blacksmith
```

И стандартных waypoint tags в той же area.

## Минимальная настройка кузнеца

### NPC

На кузнеце обязательно только:

```text
dl_profile_id = blacksmith
```

Если NPC живёт и работает в текущей area, эти locals больше не обязательны:

```text
dl_home_area_tag
dl_work_area_tag
dl_meal_area_tag
dl_social_area_tag
dl_public_area_tag
```

Runtime использует текущую area NPC как fallback.

### Work waypoint tags

Для кузнеца можно не ставить area-local anchors, если в area есть стандартные waypoint tags:

```text
dl_work_forge
dl_work_craft
dl_work_fetch   // optional
```

Area anchors всё ещё поддерживаются и имеют приоритет:

```text
dl_anchor_work_primary
dl_anchor_work_secondary
dl_anchor_work_fetch
```

## Минимальная настройка сна

Если NPC спит в той же area, можно поставить стандартные waypoint tags:

```text
dl_sleep_approach_1
dl_sleep_bed_1
```

Тогда эти area locals не обязательны:

```text
dl_anchor_sleep_approach_1
dl_anchor_sleep_bed_1
```

Area anchors всё ещё поддерживаются и имеют приоритет над fallback tags.

## Минимальная настройка локального перехода

Для простого перехода внутри той же area больше не обязательно прописывать `dl_transition_exit_tag`.

Достаточно поставить пару waypoint tags по соглашению:

```text
dl_jump_<id>_from
dl_jump_<id>_to
```

Пример для лестницы/двери на второй этаж кузницы:

```text
dl_jump_smith_bedroom_from
dl_jump_smith_bedroom_to
```

Такой переход двусторонний по именам:

```text
dl_jump_smith_bedroom_from -> dl_jump_smith_bedroom_to
dl_jump_smith_bedroom_to   -> dl_jump_smith_bedroom_from
```

### Переход без двери

Никаких locals на waypoint не нужно. Система просто доводит NPC до ближайшей точки пары и делает jump на вторую.

### Переход с дверью

Если нужно открыть конкретную дверь, локалки всё ещё нужны только на entry-waypoint:

```text
dl_transition_driver = door
dl_transition_driver_tag = tag_двери
```

Для первого smoke-теста лучше начинать без двери. Когда jump заработал, подключать дверь отдельно.

### Сон на втором этаже

Для сна на втором этаже можно сделать так:

```text
dl_sleep_approach_1 = dl_jump_smith_bedroom_to
dl_sleep_bed_1
```

Где:

```text
dl_jump_smith_bedroom_from
```

стоит внизу у двери/лестницы, а

```text
dl_jump_smith_bedroom_to
```

стоит наверху у входа в комнату.

## Дефолтное расписание

Для обычных NPC не нужно вручную задавать:

```text
dl_wake_hour
dl_sleep_hours
dl_shift_start
dl_shift_length
dl_home_slot
```

Дефолты:

```text
dl_wake_hour   = 6
dl_sleep_hours = 8
dl_shift_start = 8
dl_shift_length = 8
dl_home_slot   = 1
```

## Практический минимум для теста кузнеца

1. Module:

```text
OnModuleLoad = dl_load
dl_enabled = 1
```

2. Area:

```text
OnEnter = dl_a_enter
OnExit = dl_a_exit
OnHeartbeat = dl_a_hb
```

3. NPC:

```text
OnSpawn = dl_spawn
OnDeath = dl_death
OnBlocked = dl_blocked
OnUserDefined = dl_userdef

dl_profile_id = blacksmith
```

4. Waypoints в той же area:

```text
dl_work_forge
dl_work_craft
```

5. Для сна добавить:

```text
dl_sleep_approach_1
dl_sleep_bed_1
```

6. Для сна через второй этаж/локальный переход:

```text
dl_jump_smith_bedroom_from
dl_jump_smith_bedroom_to
dl_sleep_bed_1
```

И использовать `dl_jump_smith_bedroom_to` как sleep approach target.

## Когда всё ещё нужны explicit area tags

Использовать `dl_home_area_tag`, `dl_work_area_tag`, `dl_meal_area_tag`, `dl_social_area_tag`, `dl_public_area_tag`, если NPC должен ходить в другую area или у него разные home/work/public области.

Для обычных NPC внутри одной area эти locals можно не ставить.

## Когда всё ещё нужны explicit transition locals

Использовать `dl_transition_exit_tag`, если tag-пара не следует соглашению `dl_jump_<id>_from/to` или если нужен нестандартный one-way переход.

Использовать `dl_transition_driver` и `dl_transition_driver_tag`, если переход должен взаимодействовать с door/trigger-driver.
