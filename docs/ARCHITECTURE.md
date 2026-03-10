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
- Ambient Life canonical namespace root: `1100..1299`.
- Occupied now (Stage 1):
  - `1101`: `AL_EVENT_RESYNC`.
  - `1110..1115`: `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`.
  - `1120`: `AL_EVENT_ROUTE_REPEAT` (declared hook; runtime behavior deferred).
- Reserved by Ambient Life (do not use for unrelated internal systems):
  - `1100..1199`: Ambient Life core/routine expansion window.
  - `1200..1299`: Ambient Life reaction window.
- Internal subsystems outside Ambient Life must allocate events outside `1100..1299` unless explicitly coordinated.

## Toolset contract fields vs Stage 1 runtime status
- `al_slot_offset_min`:
  - Part of canonical NPC contract already.
  - Stage 1 slot computation reads this local and can produce offset-aware slot value.
  - Stage 1 dispatch remains area-global (`SLOT_0..SLOT_5` as shared event), so full per-NPC offset-aware dispatch is intentionally deferred.
  - Full behavior (offset-aware routine/runtime dispatch and route execution coupling) is planned for next stage.
- `al_mode`:
  - Reserved runtime field in canonical contract.
  - No canonical enum and no runtime mode switch implementation in Stage 1.
  - May be specified later when routine/runtime behavior is introduced.

## Fallback policy
- Missing route/activity handlers: keep NPC in default/no-op behavior.
- Stale registry references: cleaned by periodic area-level sync cleanup.
- Invalid delayed tick: dropped via token mismatch.

## Interrupt/resume policy (concept)
- Interrupt sources (blocked, disturbed, reactions, crime) are modeled as layer-specific state transitions.
- Core remains stateless about detailed behavior, only maintains deterministic dispatch cadence.
- Resume targets slot-consistent activity state, not arbitrary action queue rewrites.

## Canonical sleep contract (fixed now, implemented later)
- Sleep route references bed id and uses two waypoint tags:
  - `sleep_approach`: `<bed_id>_approach`
  - `sleep_pose`: `<bed_id>_pose`
- If either waypoint is missing: fallback to **sleep on place**.
- `ActionInteractObject` is explicitly excluded as baseline sleep path.
