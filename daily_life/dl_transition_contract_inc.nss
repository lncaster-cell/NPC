// Daily Life transition interface contracts (single source of truth).
// DO NOT DUPLICATE: keep all transition boundary contracts in this include.
//
// Boundaries and side effects:
// - Router: selects transition entry only; MUST NOT mutate domain statuses.
// - Executor: executes selected transition and writes transition runtime state.
// - Domain (work/focus/sleep): interprets transition results only; MUST NOT write
//   transition locals directly.
//
// Allowed extension points:
// - Add new router heuristics inside router implementation only.
// - Add new transition drivers/state fields inside executor/engine only.
// - Add domain reactions by interpreting return values/status reads only.

// Router API (selection + delegation; no domain mutations).
object DL_FindNextTransitionEntryToTarget(object oNpc, object oTarget);
int DL_TryRouteToTarget(object oNpc, object oTarget);

// Executor API (single-transition execution + transition-state writes).
// public compatibility API:
// - Entry point for router/domain callers: daily_life/dl_nav_router_inc.nss::DL_RouteNpcOneTransitionStep.
// - Canonical execution implementation: daily_life/dl_transition_engine_inc.nss::DL_ExecuteTransitionEngine.
int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix);
int DL_TryAdvanceViaTransitionOrRoute(object oNpc, object oTargetWp, string sRouteContext);

// Transition state API (transition-local ownership lives outside domains).
void DL_ClearTransitionExecutionState(object oNpc);
