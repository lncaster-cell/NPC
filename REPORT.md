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

## Intentionally deferred
- Route runtime execution.
- Per-NPC offset-aware routine dispatch (`al_slot_offset_min` is contract-only in Stage 1).
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

## Clarifications after Stage 1
- Stage 1 slot dispatch is area-global; `al_slot_offset_min` is canonical content data but not yet a full runtime dispatch driver.
- `al_mode` remains runtime-reserved; mode enum values are intentionally deferred to later runtime stages.
- Ambient Life event ranges `1100..1199` and `1200..1299` are reserved and must not be reused by unrelated internal systems.
