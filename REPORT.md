# Ambient Life Stage 1 Report

## Done
- Fixed canonical architecture documents: layering, module boundaries, event namespace, contracts.
- Added modular script structure under `scripts/ambient_life/` with clear single responsibility per file.
- Implemented working core lifecycle:
  - area activation/deactivation by player presence,
  - single area-level tick loop,
  - tick token invalidation,
  - slot computation and slot-change dispatch,
  - RESYNC dispatch on activation,
  - dense NPC registry + periodic cleanup.
- Implemented internal OnUserDefined bus constants and routing hooks.
- Clarified Stage 1 contract/runtime boundaries:
  - `al_slot_offset_min` is canonical and read by slot computation, while runtime dispatch is still global-area slot based.
  - full per-NPC offset-aware dispatch is deferred with routine runtime / route execution.
  - `al_mode` remains reserved without canonical enum/runtime semantics in Stage 1.
- Clarified Ambient Life OnUserDefined namespace ownership for `1100..1299`.

## Intentionally deferred
- Route runtime execution.
- Multi-step slot routine runtime.
- Sleep docking/runtime behavior.
- OnBlocked/OnDisturbed reactions.
- Crime/alarm systems.

## Fixed invariants
- Event-driven orchestration only.
- No NPC heartbeat.
- No per-NPC periodic DelayCommand.
- No AssignCommand-based orchestration core.
- Action queue remains engine responsibility.

## Engine constraints respected
- Lifecycle loop runs at area level only while players are present.
- OnUserDefined used as internal dispatch bus.
- Core stores orchestration state only and does not replace action queue semantics.
