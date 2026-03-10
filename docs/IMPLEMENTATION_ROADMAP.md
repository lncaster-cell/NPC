# Ambient Life Implementation Roadmap

## Stage 1 (done): Core lifecycle
- Event-driven area lifecycle.
- Area activation on first player, deactivation on last player/leave.
- Single area-level delayed tick loop with token invalidation.
- Dense NPC registry add/remove/swap-remove.
- Slot compute with canonical `al_slot_offset_min` support.
- Slot dispatch (`RESYNC`, `SLOT_0..5`) as area bus events.
- OnUserDefined bus foundation and event namespace.

## Stage 2 (done): Ambient route baseline
- Parse slot route assignment (`alwp0..alwp5`).
- Build ordered route steps by `al_step` (deterministic ordering).
- Apply waypoint `al_activity` as step source of truth.
- Support dwell by waypoint `al_dur_sec` through engine action queue.
- Runtime route bookkeeping (`route tag`, `active flag`, `step index`, lightweight dwell marker).
- Route continuation through `AL_EVENT_ROUTE_REPEAT` without heartbeat/polling.
- Fallback policy for empty routes, missing waypoints, invalid activity.

## Stage 3: Multi-step slot routines expansion
- Broader activity vocabulary.
- Slot-level composite routine branching.
- Richer fallback profiles per NPC archetype.

## Stage 4: Sleep subsystem
- Sleep profile evaluation.
- Bed contract runtime (`<bed_id>_approach`, `<bed_id>_pose`).
- Fallback sleep on place.

## Stage 5: Blocked/disturbed reactions
- OnBlocked and OnDisturbed hook-up.
- Interrupt and resume policies applied to routine layer.

## Stage 6+: Crime/alarm and advanced systemic reactions
- Crime witnesses, alarms, social propagation.
- Additional reaction channels and escalation policies.
