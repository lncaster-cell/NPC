# Builder-friendly Daily Life setup (RU)

> Обновлено: **2026-04-29**

## Главное правило по waypoint tags

Одинаковые waypoint tags можно использовать в разных area.

Например, в каждой кузнице или доме можно иметь свои:

```text
dl_work_forge
dl_work_craft
dl_sleep_approach_1
dl_sleep_bed_1
wp_stairs_down
wp_stairs_up
```

Runtime ищет waypoint сначала в нужной area:

```text
если задан dl_work_area_tag  -> ищет work-точки в этой area
если задан dl_home_area_tag  -> ищет sleep-точки в этой area
если area tag не задан       -> ищет в текущей area NPC
```

Внутри одной area одинаковые tags всё ещё использовать не надо. Если в одной area два `dl_sleep_bed_1`, результат будет неоднозначным.

## Общая навигация / переходы

Переходы больше не должны настраиваться отдельно для каждого NPC или каждой директивы.

Один раз размеченный переход может использовать любой Daily Life target:

```text
SLEEP
WORK
MEAL
SOCIAL
PUBLIC
будущий CHILL / GUARD / SEARCH
```

Минимальная пара перехода внутри одной area:

```text
wp_stairs_down:
dl_transition_exit_tag = wp_stairs_up

wp_stairs_up:
dl_transition_exit_tag = wp_stairs_down
```

После этого NPC, которому нужна точка на другой стороне перехода, сначала использует переход, потом идёт к своей цели.

Пример сна на втором этаже:

```text
wp_stairs_down
wp_stairs_up
dl_sleep_approach_1
dl_sleep_bed_1
```

На area больше не нужно ставить:

```text
dl_anchor_sleep_route_1
```

Нужно только поставить обычные sleep-точки наверху:

```text
dl_sleep_approach_1
dl_sleep_bed_1
```

Для перехода через дверь можно дополнительно указать:

```text
dl_transition_driver = door
dl_transition_driver_tag = tag_двери
```

Для первого smoke-теста лучше начинать без двери:

```text
dl_transition_driver = none
```

или не задавать `dl_transition_driver` вообще.

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

Если спальня за локальным переходом внутри той же area, sleep-route local больше не нужен. Достаточно общей пары перехода и sleep-точек за переходом.

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
dl_wake_hour    = 6
dl_sleep_hours  = 8
dl_shift_start  = 8
dl_shift_length = 8
dl_home_slot    = 1
```

Это значит:

```text
22:00–06:00  SLEEP
06:00–07:00  MEAL / breakfast window
08:00–16:00  WORK
примерно 12:00 MEAL / lunch window, если shift_length >= 8
вечером       MEAL / dinner window перед сном
после работы  SOCIAL или PUBLIC, если есть соответствующие точки
остальное     NONE / idle
```

Точные окна еды/social/public чуть сдвигаются по tag NPC, чтобы все NPC не вставали и не ели в одну и ту же минуту.

## Индивидуальное расписание через локалки

Локалки расписания работают как override. Ставить их нужно только особым NPC.

Примеры:

```text
dl_wake_hour = 7
```

NPC просыпается в 07:00. При `dl_sleep_hours = 8` сон будет примерно 23:00–07:00.

```text
dl_shift_start = 10
dl_shift_length = 6
```

NPC работает примерно 10:00–16:00.

```text
dl_sleep_hours = 10
```

NPC спит дольше. Значение ограничивается safe-диапазоном 7–10 часов.

```text
dl_weekend_mode = off_public
```

В выходные не работает, может уходить в PUBLIC/SOCIAL при наличии точек.

```text
dl_weekend_mode = reduced_work
dl_weekend_shift_length = 4
```

В выходные работает укороченную смену.

## Приоритет директив

Если несколько окон пересекаются, порядок выбора такой:

```text
1. SLEEP
2. MEAL breakfast
3. MEAL lunch
4. MEAL dinner
5. SOCIAL / PUBLIC вне работы
6. WORK
7. NONE
```

Сон всегда важнее работы. Поэтому ночью NPC должен спать даже если рабочая смена длинная.

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

4. Work waypoints:

```text
dl_work_forge
dl_work_craft
```

5. Sleep waypoints:

```text
dl_sleep_approach_1
dl_sleep_bed_1
```

6. Если сон на втором этаже внутри этой же area, добавить общую пару перехода:

```text
wp_stairs_down:
dl_transition_exit_tag = wp_stairs_up

wp_stairs_up:
dl_transition_exit_tag = wp_stairs_down
```

## Когда всё ещё нужны explicit area tags

Использовать `dl_home_area_tag`, `dl_work_area_tag`, `dl_meal_area_tag`, `dl_social_area_tag`, `dl_public_area_tag`, если NPC должен ходить в другую area или у него разные home/work/public области.

Для обычных NPC внутри одной area эти locals можно не ставить.
