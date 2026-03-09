# Ambient Life Implementation Roadmap

## Stage 1 (current): Core lifecycle
- Event-driven area lifecycle.
- Area activation on first player, deactivation on last player/leave.
- Single area-level delayed tick loop with token invalidation.
- Dense NPC registry add/remove/swap-remove.
- Slot compute and dispatch (`RESYNC`, `SLOT_0..5`).
- OnUserDefined bus foundation and event namespace.

## Stage 2: Route execution
- Parse slot route assignment (`alwp0..alwp5`).
- Waypoint traversal by engine action queue.
- `ROUTE_REPEAT` runtime loop handling.

## Stage 3: Multi-step slot routines
- Step-level state machine from waypoint contract (`al_step`, `al_activity`, `al_dur_sec`).
- Per-slot composite behavior with deterministic transitions.

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
