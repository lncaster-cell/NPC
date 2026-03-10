# Ambient Life Toolset Contract

## Area locals
### Content-contract locals (toolset may set)
- `al_debug` (int, optional)

### Runtime-state locals (system-owned, do not set manually)
- `al_player_count` (int)
- `al_tick_token` (int)
- `al_slot` (int)
- `al_sync_tick` (int)
- `al_npc_count` (int)
- `al_npc_<idx>` (object)

## NPC locals
### Content-contract locals (toolset may set)
- `al_slot_offset_min` (int)
- `al_default_activity` (int, optional)
- `al_sleep_profile` (string, contract only)
- `alwp0`..`alwp5` (string route tags by slot)

### Runtime-state locals (system-owned, do not set manually)
- `al_last_slot` (int)
- `al_last_area` (object)
- `al_mode` (int, reserved runtime mode)
- `al_route_tag` (string)
- `al_route_active` (int bool)
- `al_route_index` (int)
- `al_route_step_count` (int)
- `al_route_step_obj_<idx>` (object; route-step cache)
- `al_route_dwell_until` (float; lightweight bookkeeping marker)

## Route waypoint contract
Waypoint locals (data-level contract):
- `al_step` (int, route order key)
- `al_activity` (int, step activity source of truth)
- `al_dur_sec` (int, dwell duration in seconds)
- `al_bed_id` (sleep metadata; not used by Stage 2 runtime)

## Stage 2 interpretation rules
- NPC selects route by current slot using `alwp<slot>`.
- Runtime collects all waypoints with selected route tag and sorts by `al_step`.
- Ordered route supports one or more steps.
- Broken/empty route falls back to safe local activity.
- Missing current step waypoint executes activity on current NPC position.
- Invalid activity falls back to `al_default_activity`, then idle.

## Sleep waypoint naming (future stage)
For each `al_bed_id = <bed_id>` sleep route:
- `<bed_id>_approach`
- `<bed_id>_pose`

If one is missing, runtime fallback is sleep on place.

## Authoring note for 00:00-08:00 sleep
It is valid to point both `alwp0` and `alwp1` to the same sleep route tag.
Difference between full 8h sleep vs 4h+micro-routine is defined by sleep profile + night-routine logic, not mandatory separate route tags.
