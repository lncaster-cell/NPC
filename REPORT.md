# Ambient Life — Stage G Report (Sleep Runtime as Separate Subsystem over Stage E/F)

## Реализовано
- Сохранена Stage D/E/F основа:
  - area-scoped route cache по `alwp0..alwp5`,
  - bounded multi-step progression через `AL_EVENT_ROUTE_REPEAT`,
  - отдельная transition subsystem Stage F без смешивания с обычными шагами.
- Добавлен отдельный runtime-слой `al_sleep_inc.nss`, который вызывается только для sleep steps.
- Реализован канонический sleep pipeline:
  1. resolve `al_bed_id` из route step,
  2. resolve waypoint pair `<bed_id>_approach` + `<bed_id>_pose`,
  3. `move-to-approach -> dock-to-pose -> sleep dwell -> repeat`.
- Реализован честный fallback policy: при missing/invalid `al_bed_id` и/или missing/invalid pair waypoint применяется sleep on place.

## Sleep step detection (Stage G)
- Sleep step определяется как special-case route step по наличию `al_bed_id` на waypoint.
- В bounded routine progression sleep path запускается после проверки transition step и до обычного Stage E activity path.

## Новый runtime state (минимальный)
- `al_sleep_rt_active` — маркер активного sleep шага.
- `al_sleep_rt_bed_id` — текущий `bed_id` (очищается на fallback sleep on place).
- `al_sleep_rt_phase` — фаза sleep runtime (`place/approach/pose`).

## Интеграция и границы
- Sleep subsystem отделён от transition subsystem и не подменяет её.
- Stage E bounded progression остаётся прежним по модели и продолжает step-advance через `AL_EVENT_ROUTE_REPEAT`.
- HOT/WARM/FREEZE semantics сохранены: sleep runtime работает только в `HOT`.
- Heartbeat/polling/per-NPC timer архитектуры не добавлялись.

## Явно не реализовано в Stage G
- `ActionInteractObject`-based sleep.
- `rest` / `OnRested` / `AnimActionRest`.
- Reactions / blocked-disturbed / crime / alarm.
- Полная rich-semantics интерпретация `al_sleep_profile` (остается для последующих стадий).
