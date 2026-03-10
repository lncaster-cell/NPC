# Ambient Life Architecture Canon (Stage 2)

## System model
Ambient Life is an event-driven orchestration system for NPC daily life in NWN2.
Core principle: the engine executes actions; Ambient Life coordinates *when* and *what phase* should run.

### Layers
1. **Core orchestration layer**
   - Area activation/deactivation.
   - Single area-level tick while players are present.
   - Area dense NPC registry.
   - Slot changes and RESYNC broadcasts over OnUserDefined.
2. **Routine layer** (Stage 2 baseline)
   - Route selection by slot (`alwp0..alwp5`).
   - Ordered route steps by `al_step`.
   - Waypoint-driven activity (`al_activity`) + dwell (`al_dur_sec`).
   - Route repeat via `AL_EVENT_ROUTE_REPEAT` in OnUserDefined bus.
3. **Reaction layer** (future stage 5+)
   - OnBlocked / OnDisturbed reactions.
   - Crime/alarm and social escalation.

## Engine responsibilities (trusted)
- **Action queue** is canonical for ordinary action sequencing.
- **Standard game events** (OnSpawn, OnDeath, OnEnter/OnExit, OnUserDefined, OnBlocked, OnDisturbed) are canonical triggers.

## System responsibilities (owned state)
- Runtime orchestration state (slot markers, active token, registry membership).
- Route bookkeeping state (`al_route_tag`, `al_route_index`, `al_route_active`, step cache count, dwell-until marker).
- Dispatch decisions (RESYNC/SLOT/ROUTE_REPEAT events).
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
- `al_route_inc.nss`: route subsystem runtime (selection, step ordering, step execution, repeat).
- `al_activity_inc.nss`: activity sanitization and action-queue activity application.
- `al_sleep_inc.nss`: sleep contract and runtime hooks (deferred).
- `al_react_inc.nss`: reaction subsystem hooks (deferred).
- `al_debug_inc.nss`: optional diagnostics.

## Event namespace (OnUserDefined bus)
- Ambient Life canonical namespace root: `1100..1299`.
- Occupied now:
  - `1101`: `AL_EVENT_RESYNC`.
  - `1110..1115`: `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`.
  - `1120`: `AL_EVENT_ROUTE_REPEAT`.
- Reserved by Ambient Life (do not use for unrelated internal systems):
  - `1100..1199`: Ambient Life core/routine expansion window.
  - `1200..1299`: Ambient Life reaction window.
- Internal subsystems outside Ambient Life must allocate events outside `1100..1299` unless explicitly coordinated.

## Stage 2 routine guarantees
- Active route is selected from NPC slot locals `alwp<slot>`.
- Route steps are collected by route tag and ordered deterministically via `al_step`.
- `al_activity` on waypoint is source of truth for step activity.
- `al_dur_sec` on waypoint is source of truth for dwell duration.
- Ordinary step sequencing is action-queue driven and chained by `AL_EVENT_ROUTE_REPEAT`; no arrival polling.

## Fallback policy
- Missing route tag or empty/broken route => route is skipped and fallback activity is used.
- Missing current waypoint object => activity is executed on current NPC position.
- Invalid `al_activity` => fallback to `al_default_activity`, then to safe idle.
- Sleep metadata (`al_bed_id`) is contract-only in Stage 2 and not used for docking runtime.
- Stale registry references are cleaned by periodic area-level sync cleanup.
- Invalid delayed area tick is dropped via token mismatch.

## Interrupt/resume policy (deferred)
- Interrupt sources (blocked, disturbed, reactions, crime) are modeled as layer-specific state transitions in later stages.
- Stage 2 keeps routine loop narrow and deterministic without reaction integration.

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
