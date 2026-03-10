# Ambient Life Implementation Roadmap

## Stage 1 (current): Core lifecycle
- Event-driven area lifecycle.
- Area activation on first player, deactivation on last player/leave.
- Single area-level delayed tick loop with token invalidation.
- Dense NPC registry add/remove/swap-remove.
- Slot compute with canonical `al_slot_offset_min` support.
- Slot dispatch (`RESYNC`, `SLOT_0..5`) is still area-global in Stage 1.
- OnUserDefined bus foundation and event namespace.
- `al_mode` kept as reserved runtime field (no canonical enum, no Stage 1 runtime behavior).

## Stage 2: Route execution
- Parse slot route assignment (`alwp0..alwp5`).
- Waypoint traversal by engine action queue.
- `ROUTE_REPEAT` runtime loop handling.
- Introduce per-NPC offset-aware runtime dispatch path (coupled with routine runtime).

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
