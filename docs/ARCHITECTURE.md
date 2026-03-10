# Ambient Life Architecture Canon (Stage 1)

## System model
Ambient Life is an event-driven orchestration system for NPC daily life in NWN2.
Core principle: the engine executes actions; Ambient Life coordinates *when* and *what phase* should run.

### Layers
1. **Core orchestration layer**
   - Area activation/deactivation.
   - Single area-level tick while players are present.
   - Area dense NPC registry.
   - Slot changes and RESYNC broadcasts over OnUserDefined.
2. **Routine layer** (future stage 2/3)
   - Route execution.
   - Multi-step slot activities.
   - Interrupt/resume-aware routine state transitions.
3. **Reaction layer** (future stage 5+)
   - OnBlocked / OnDisturbed reactions.
   - Crime/alarm and social escalation.

## Engine responsibilities (trusted)
- **Action queue** is canonical for ordinary action sequencing.
- **Standard game events** (OnSpawn, OnDeath, OnEnter/OnExit, OnUserDefined, OnBlocked, OnDisturbed) are canonical triggers.

## System responsibilities (owned state)
- Runtime orchestration state (slot markers, active token, registry membership).
- Dispatch decisions (RESYNC/SLOT events).
- Fallback and guard policies.

Ambient Life does **not** reimplement action queue mechanics.

## Hard forbidden patterns
- NPC heartbeat orchestration.
- Per-NPC periodic timers.
- Polling-based waypoint arrival checks.
- AssignCommand-heavy orchestration architecture.
- DelayCommand as NPC heartbeat substitute.
- rest / OnRested / AnimActionRest in core.
- ActionInteractObject as sleep architecture foundation.
- Dynamic event rebinding via SetEventHandler.
- Monolithic single-file AI implementation.

## Module boundaries
- `al_core_inc.nss`: lifecycle primitives, tick token, event dispatch.
- `al_area_inc.nss`: area event handlers (enter/exit/tick).
- `al_registry_inc.nss`: dense add/remove/swap-remove and cleanup.
- `al_schedule_inc.nss`: time-slot derivation.
- `al_events_inc.nss`: internal OnUserDefined event namespace.
- `al_route_inc.nss`: route subsystem hooks (future runtime).
- `al_activity_inc.nss`: multi-step slot activity hooks.
- `al_sleep_inc.nss`: sleep contract and runtime hooks.
- `al_react_inc.nss`: reaction subsystem hooks.
- `al_debug_inc.nss`: optional diagnostics.

## Event namespace (OnUserDefined bus)
Ambient Life event namespace is **exclusive** for Ambient Life internals. Other internal subsystems must not emit arbitrary events inside these ranges.

- `1100..1199` — Ambient Life core/routine namespace.
  - Implemented in Stage 1:
    - `AL_EVENT_RESYNC = 1101`
    - `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5 = 1110..1115`
    - `AL_EVENT_ROUTE_REPEAT = 1120` (reserved runtime hook)
  - Remaining values in this range are reserved for future Ambient Life routine events.
- `1200..1299` — reserved for Ambient Life reaction events (future stages).
- Values outside these ranges are out of Ambient Life contract scope.

## Fallback policy
- Missing route/activity handlers: keep NPC in default/no-op behavior.
- Stale registry references: cleaned by periodic area-level sync cleanup.
- Invalid delayed tick: dropped via token mismatch.

## Interrupt/resume policy (concept)
- Interrupt sources (blocked, disturbed, reactions, crime) are modeled as layer-specific state transitions.
- Core remains stateless about detailed behavior, only maintains deterministic dispatch cadence.
- Resume targets slot-consistent activity state, not arbitrary action queue rewrites.

## Stage 1 scope clarifications
- `al_slot_offset_min` is canonical NPC contract data, but Stage 1 dispatch remains **area-global by current slot**.
- Per-NPC offset-aware routine dispatch is intentionally deferred to routine runtime stages (route execution + multi-step routines).
- This is a deliberate Stage 1 scope boundary, not a core lifecycle defect.

## `al_mode` status
- `al_mode` is a runtime-owned local reserved for routine/reaction/sleep mode switching.
- Stage 1 does not implement mode logic.
- Canonical enum values are intentionally deferred and will be fixed together with routine/reaction runtime in later stages.

## Canonical sleep contract (fixed now, implemented later)
- Sleep route references bed id and uses two waypoint tags:
  - `sleep_approach`: `<bed_id>_approach`
  - `sleep_pose`: `<bed_id>_pose`
- If either waypoint is missing: fallback to **sleep on place**.
- `ActionInteractObject` is explicitly excluded as baseline sleep path.
