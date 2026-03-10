# Ambient Life — Stage B Report (Core Lifecycle Runtime)

## Реализовано
- Area lifecycle:
  - активация на первом PC (`al_player_count: 0 -> 1`),
  - деактивация на последнем выходе PC и на module leave,
  - runtime учитывает только area-level состояние и locals контракта.
- Один area-level tick loop:
  - ровно один DelayCommand loop на area,
  - token invalidation через `al_tick_token`,
  - stale delayed ticks отбрасываются,
  - loop работает только при `al_player_count > 0`.
- Dense registry:
  - регистрация NPC на spawn,
  - удаление на death,
  - swap-remove для O(1) удаления по хвосту,
  - хранение `al_npc_count` + `al_npc_<idx>`,
  - редкая compact-cleanup при area activation.
- Slot orchestration backbone:
  - вычисление `al_slot` по времени зоны,
  - dispatch только при реальной смене слота,
  - `RESYNC` dispatch при activation.
- OnUserDefined internal bus:
  - `AL_EVENT_RESYNC`,
  - `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`,
  - `AL_EVENT_ROUTE_REPEAT` оставлен как reserved hook.
- NPC OnUD baseline:
  - приём внутренних событий,
  - обновление `al_last_slot`,
  - базовый `RESYNC` handler,
  - чистые hooks/stubs для следующих stage.

## Сознательно отложено
- Per-NPC offset-aware dispatch/runtime (`al_slot_offset_min` остаётся canonical полем, но dispatch Stage B area-global).
- Route cache/runtime и multi-step routines.
- Sleep runtime.
- Reactions (blocked/disturbed/crime/alarm).

## Соблюдённые инварианты
- Event-driven orchestration.
- Нет NPC heartbeat.
- Нет per-NPC periodic timers.
- Один area-level tick loop на активную area.
- Нет repeated area full-scan в hot path.
- Нет `AssignCommand` как backbone.
- Нет `DelayCommand` как heartbeat substitute для NPC.
- Нет `rest` / `OnRested` / `AnimActionRest` / `ActionInteractObject`-sleep runtime.

## Учтённые engine constraints
- DelayCommand stale-call race закрыт token invalidation pattern.
- OnUD доставка реализована через `SignalEvent(EventUserDefined(...))`.
- Registry cleanup сделан редким и lifecycle-driven, без отдельной фоновой системы.
