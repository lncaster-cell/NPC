# Risk Register (Post-refactor audit passes)

Источник: `post_refactor_audit_pass4.md` … `post_refactor_audit_pass14.md` + closure report `audit_artifacts_closure_2026-05-02.md`.

| Risk ID | Severity | Found in pass | Status | Implemented in | Touched files | Regression check |
|---|---|---|---|---|---|---|
| R1 | High | Pass 4 | Closed | `d56feb2` (`DL_ProcessAreaNpcByPassMode`, dedupe via `DL_L_NPC_LAST_TOUCH_TICK`) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass5.md` | Static: verify per-tick dedupe gate for worker/warm modes. Runtime: HOT area + area-enter resync should not double-touch same NPC in same tick. |
| R2 | Medium | Pass 4 | Closed | `d56feb2` (`DL_ReissueNpcDirectiveAfterBlocked`, `DL_ApplyDirectiveSkeleton`) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass5.md` | Static: blocked reissue path has no redundant pre-clear before skeleton. Runtime: blocked NPC reissues work/sleep without duplicated directive churn. |
| R3 | Medium | Pass 4 | Closed | `d56feb2` (`DL_ResolveSocialPartnerObject`) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass5.md` | Static: cached partner object is validated (object/tag/active). Runtime: repeated social ticks avoid full tag scan while preserving behavior after partner changes. |
| R4 | Low | Pass 4 | Closed (accepted tradeoff) | N/A | `docs/audits/post_refactor_audit_pass4.md`, `docs/audits/audit_artifacts_closure_2026-05-02.md` | Static: skeleton remains canonical clear/set/execute path. Runtime: monitor only on perf incident. |
| R6-1 | Medium | Pass 6 (deep) | Closed (no active incident) | N/A | `docs/audits/post_refactor_audit_pass6_deep.md`, `docs/audits/audit_artifacts_closure_2026-05-02.md` | Static: keep periodic review on boundary changes; no active regression tracked. |
| R6-2 | Low/Medium | Pass 6 (deep) | Closed (no active incident) | N/A | `docs/audits/post_refactor_audit_pass6_deep.md`, `docs/audits/audit_artifacts_closure_2026-05-02.md` | Static: boundedness invariant retained; monitor only during transition refactors. |
| R7-1 | Medium | Pass 7 | Closed | `d56feb2` (`DL_RunAreaNpcRoundRobinPass`, `DL_L_AREA_PASS_LAST_SEEN`) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass7.md` | Static: `LAST_SEEN` is based on observed active population. Runtime: fast-break scenarios should not repeatedly reset cursor window. |
| R8-1 | Medium | Pass 8 | Closed | `d56feb2` (`DL_RunAreaNpcRoundRobinPass`, wrap branch accounting) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass8.md` | Static: no double-count in wrap branch accumulation. Runtime: round-robin coverage remains smooth when cursor wraps. |
| R9-1 | Medium | Pass 9 | Closed | `d56feb2` (`DL_RunAreaNpcRoundRobinPass`, observed `nNpcSeenTotal`) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass9.md` | Static: no registry-count fallback for `LAST_SEEN` when observed set is zero. Runtime: stale registry should not keep non-zero cursor modulo basis. |
| R10-1 | Medium | Pass 10 | Closed | `d56feb2` (`DL_RunAreaWarmMaintenanceTick`, `DL_RunAreaWorkerTick`) | `daily_life/dl_worker_inc.nss`, `docs/audits/post_refactor_audit_pass10.md` | Static: cursor advance clamp handles `processed == 0 && seen > 0`. Runtime: worker/warm cursor must progress on skip-only windows. |
| R11-1 | High | Pass 11 | Closed | `f3650aa` (`DL_CR_GetEpisodeCooldownKey`), `3c11900` (`DL_CR_GetOffenderIdentityKey`) | `daily_life/dl_city_response_inc.nss`, `docs/audits/post_refactor_audit_pass11.md`, `docs/audits/post_refactor_audit_pass12.md` | Static: cooldown identity path prioritizes `GetPCPublicCDKey` and stable fallback chain. Runtime: two different PCs with same tag must not share cooldown episode state. |

## Regression check template (for new risk fixes)

Use this section verbatim in future audit passes and in PR notes:

### Regression check

- **Static checks (code-level):**
  - Which invariants were verified in source (locals/contracts/bounded loops/idempotent transitions).
  - Which exact functions were inspected or changed.
  - Why selected NWScript/NWN2 built-ins are sufficient (with NWN Lexicon reference note).
- **Runtime checks (behavior-level):**
  - Minimal reproduction scenario (area type, NPC count, trigger/event sequence).
  - Expected observable outcome (locals/cursor/cooldown/dialog/state transitions).
  - Negative check (what must *not* happen after fix).
  - Multiplayer check if identity/cooldown/ownership is involved.

