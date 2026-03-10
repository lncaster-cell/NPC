# Ambient Life Stage 2 Report

## Done
- Implemented slot-based route selection from NPC locals `alwp0..alwp5`.
- Implemented deterministic route-step model:
  - waypoint collection by route tag,
  - explicit ordering by `al_step`,
  - support for 1+ steps.
- Implemented minimal route runtime state on NPC:
  - `al_route_tag`,
  - `al_route_active`,
  - `al_route_index`,
  - `al_route_step_count` + step object cache,
  - `al_route_dwell_until` (lightweight marker).
- Implemented route execution that remains event-driven:
  - slot/resync events start route,
  - `AL_EVENT_ROUTE_REPEAT` advances step sequence,
  - sequencing uses engine action queue (`ActionMoveToObject`, `ActionWait`, `ActionDoCommand`).
- Implemented waypoint activity source-of-truth (`al_activity`) with safe fallback chain:
  - waypoint activity,
  - `al_default_activity`,
  - idle fallback.
- Implemented dwell support via waypoint `al_dur_sec` in action queue.
- Implemented clean fallback policy:
  - empty/broken route => route skipped + fallback activity,
  - missing step waypoint => activity at current NPC position,
  - invalid activity => safe fallback.
- Updated architecture/contract/roadmap docs to Stage 2 runtime reality.

## Intentionally deferred
- Sleep docking/profile runtime.
- OnBlocked/OnDisturbed reaction logic.
- Crime/alarm and social propagation.
- Rest subsystem.
- Perception-driven monolithic AI behavior.

## Fixed invariants
- Event-driven orchestration only.
- No heartbeat.
- No per-NPC periodic timers.
- No polling-based movement tracking.
- No AssignCommand as orchestration backbone.
- Runtime state is orchestration/bookkeeping only; engine action queue remains canonical for ordinary sequencing.
