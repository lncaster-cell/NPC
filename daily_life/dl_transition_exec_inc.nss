// Daily Life canonical Transition Executor.
//
// Contract:
// - Canonical executor for all transition driver paths (routed + cross-area).
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Supports same-area and cross-area exit resolution.
// - Uses existing transition metadata and driver semantics.


int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix)
{
    // Validate
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    // Resolve
    string sResolvedPrefix = sDiagPrefix;

    // Prepare
    DL_PipelineUpdateStatus(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_PREPARE);

    // Execute
    int bExecuted = DL_ExecuteTransitionEngine(oNpc, oEntryWp, sResolvedPrefix);

    // Finalize
    DL_PipelineUpdateStatus(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_FINALIZE);
    return bExecuted;
}

int DL_TryExecuteRoutedTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntryWp, DL_DIAG_CTX_ROUTED);
}
