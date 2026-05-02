// Daily Life canonical Transition Executor.
//
// Contract:
// - Canonical executor for all transition driver paths (routed + cross-area).
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Supports same-area and cross-area exit resolution.
// - Uses existing transition metadata and driver semantics.


int DL_TryExecuteRoutedTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    return DL_ExecuteTransitionEngine(oNpc, oEntryWp, DL_DIAG_CTX_ROUTED);
}
