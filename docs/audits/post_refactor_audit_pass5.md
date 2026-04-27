# Post-refactor runtime audit (pass 5) — Daily Life

## Scope and method

- Scope: runtime paths in `daily_life/` (worker, resync, directive execution, blocked handling, transition helpers, caches).
- Method: static path audit of entry points and include-level call chains, with focus on hot-path churn and invariant safety.
- Policy baseline: prefer built-in NWScript/NWN2 engine primitives and existing Lexicon-level patterns over custom ad-hoc logic.

## 1) Delta from pass 4

Compared to pass 4, the previously prioritized risks were re-checked against current code:

1. `R1` (same-heartbeat duplicate orchestration during area-enter resync) — **mitigated**.
2. `R2` (blocked reissue redundant clear cycle) — **mitigated**.
3. `R3` (social partner uncached lookup each pass) — **mitigated**.

## 2) Re-validation notes

### 2.1 Worker/resync dedupe is now explicit

- `DL_ProcessAreaNpcByPassMode` now applies a per-tick dedupe gate via `DL_L_NPC_LAST_TOUCH_TICK` for worker/warm passes.
- Resync pass marks the same tick stamp after processing, so worker pass in the same area tick skips already-touched NPCs.
- Result: no repeated `Resolve + Apply` for the same NPC in one logical worker tick when area-enter resync is pending.

### 2.2 Blocked reissue path delegates to canonical skeleton

- `DL_ReissueNpcDirectiveAfterBlocked` now directly calls `DL_ApplyDirectiveSkeleton` for `WORK/SLEEP` without an extra pre-clear layer.
- Canonical clear/set semantics remain centralized in the skeleton path.
- Result: lower local-var churn with no behavior drift in blocked recovery.

### 2.3 SOCIAL partner lookup uses safe object cache

- `DL_ResolveSocialPartnerObject` checks a cached object first and validates object validity, tag equality, and active pipeline status.
- Falls back to `GetObjectByTag` only on miss/stale cache and refreshes cache on success.
- Result: reduced repeated global tag lookup cost on social-heavy passes.

## 3) Current risk snapshot

### Critical

- **None detected** in the audited paths.

### Medium

1. **Transition driver resolution remains tag-based on cache miss**
   - Path: `DL_ResolveTransitionDriverObject`.
   - On cold/stale cache, it still performs `GetObjectByTag` (then area-check and cache write).
   - Impact is bounded (cached on waypoint), but crowded modules with frequent invalidation may still pay lookup spikes.

### Low

1. **Directive skeleton intentionally re-applies clear/set state each touch**
   - This preserves deterministic behavior and avoids hidden branch drift.
   - Minor churn is acceptable at current architecture stage; optimization can be deferred.

## 4) Invariants check

### Worker/runtime invariants

- ✅ Budget-bounded processing remains intact.
- ✅ Cursor progression and wrap-around semantics remain intact.
- ✅ Same-tick duplicate worker orchestration is guarded.

### Lifecycle/blocked invariants

- ✅ Blocked handling keeps busy gate + delayed reissue pattern.
- ✅ Reissue path is narrow to route directives (`WORK/SLEEP`) and stays runtime-gated.

### Directive execution invariants

- ✅ Resolve/apply model remains centralized and predictable.
- ✅ SOCIAL fallback behavior remains safe when partner/anchor cannot be resolved.

## 5) Recommendations (minimal, no rewrite)

1. Keep current dedupe/cache mitigations unchanged; they are minimal and architecture-compatible.
2. If additional performance headroom is required, consider optional cache TTL/refresh telemetry for transition driver object lookup.
3. Continue owner-run scenario validation for weekend/public/negative-markup suites before any deeper micro-optimizations.

## Conclusion

Pass 5 confirms that the top pass 4 regressions are addressed with small, built-in-mechanism-compatible changes. Runtime profile in audited paths is now stable enough to keep focus on scenario validation and targeted hot-spot measurements instead of structural rewrites.
