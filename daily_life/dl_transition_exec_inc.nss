// Daily Life canonical Transition Executor.
//
// Contract:
// - public transition execution entrypoint is ONLY: DL_ExecuteTransitionViaEntryWaypoint.
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Canonical execution path is DL_ExecuteTransitionEngine; legacy wrappers in dl_transition_inc only delegate to it.

// DO NOT DUPLICATE: canonical public transition entrypoint.
int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix)
{
    if (!DL_IsValidTransitionContext(oNpc, oEntryWp))
    {
        return FALSE;
    }

    // Business logic starts after guard-section.
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_PREPARE, "", "", "dl_tm_transition_dispatch_count");
    int bExecuted = DL_ExecuteTransitionEngine(oNpc, oEntryWp, sDiagPrefix);
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_PIPE_STEP_FINALIZE);
    return bExecuted;
}

// Extension point: domain-specific post-success hooks are allowed only through
// parameters/flags; transition locals remain executor-owned.
int DL_TryAdvanceViaTransitionOrRouteEx(object oNpc, object oTargetWp, string sRouteContext, int bMarkSleepNavigation)
{
    if (!DL_IsValidTransitionContext(oNpc, oTargetWp))
    {
        return FALSE;
    }

    // Business logic starts after guard-section.
    int bHasTransition = GetIsObjectValid(DL_TryGetTransitionExitWaypoint(oTargetWp));
    if (bHasTransition)
    {
        if (DL_ExecuteTransitionViaEntryWaypoint(oNpc, oTargetWp, sRouteContext))
        {
            if (bMarkSleepNavigation)
            {
                DL_MarkSleepNavigationInProgress(oNpc, GetTag(oTargetWp));
            }
            return TRUE;
        }
    }

    if (DL_TryRouteToTarget(oNpc, oTargetWp))
    {
        if (bMarkSleepNavigation)
        {
            DL_MarkSleepNavigationInProgress(oNpc, GetTag(oTargetWp));
        }
        return TRUE;
    }

    return FALSE;
}
