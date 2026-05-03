int DL_GetNpcHomeSlot(object oNpc)
{
    int nSlot = GetLocalInt(oNpc, DL_L_NPC_HOME_SLOT);
    if (nSlot <= 0)
    {
        string sSlot = GetLocalString(oNpc, DL_L_NPC_HOME_SLOT);
        if (sSlot != "")
        {
            nSlot = StringToInt(sSlot);
        }
    }

    if (nSlot <= 0)
    {
        nSlot = 1;
    }

    return nSlot;
}

object DL_GetSleepHomeAreaOrCurrentFallback(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    if (GetIsObjectValid(oHome))
    {
        return oHome;
    }

    return DL_GetNpcCurrentAreaFallback(oNpc);
}

object DL_ResolveSleepWaypointLegacyFallback(object oNpc, string sCacheLocal, string sFallbackTag)
{
    if (!GetIsObjectValid(oNpc) || sFallbackTag == "")
    {
        return OBJECT_INVALID;
    }

    object oWp = DL_GetNpcCachedWaypointByTag(oNpc, sCacheLocal, sFallbackTag);
    if (!GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
}

object DL_ResolveSleepApproachWaypoint(object oNpc)
{
    object oHome = DL_GetSleepHomeAreaOrCurrentFallback(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
    string sFallbackTag = "dl_sleep_approach_" + IntToString(nSlot);
    string sAnchor = "dl_anchor_sleep_approach_" + IntToString(nSlot);
    object oWp = DL_GetAreaAnchorWaypoint(
        oNpc,
        oHome,
        sAnchor,
        DL_L_NPC_CACHE_SLEEP_APPROACH,
        FALSE
    );
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }

    oWp = DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_APPROACH,
        oHome,
        "dl_sleep_",
        "_approach",
        sFallbackTag
    );
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }

    return DL_ResolveSleepWaypointLegacyFallback(oNpc, DL_L_NPC_CACHE_SLEEP_APPROACH, sFallbackTag);
}
object DL_ResolveSleepBedWaypoint(object oNpc)
{
    object oHome = DL_GetSleepHomeAreaOrCurrentFallback(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
    string sFallbackTag = "dl_sleep_bed_" + IntToString(nSlot);
    string sAnchor = "dl_anchor_sleep_bed_" + IntToString(nSlot);
    object oWp = DL_GetAreaAnchorWaypoint(
        oNpc,
        oHome,
        sAnchor,
        DL_L_NPC_CACHE_SLEEP_BED,
        FALSE
    );
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }

    oWp = DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_BED,
        oHome,
        "dl_sleep_",
        "_bed",
        sFallbackTag
    );
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }

    return DL_ResolveSleepWaypointLegacyFallback(oNpc, DL_L_NPC_CACHE_SLEEP_BED, sFallbackTag);
}
int DL_HasActiveSleepExecutionState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE) > 0 ||
           GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) != "" ||
           GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
}
void DL_StopSleepPresentationIfActive(object oNpc)
{
    if (!DL_HasActiveSleepExecutionState(oNpc))
    {
        return;
    }

    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    if (GetIsObjectValid(oApproach))
    {
        DL_DispatchJumpToLocation(oNpc, GetLocation(oApproach));
    }

    // NWN2 stock script documentation for PlayCustomAnimation says "%"
    // resets the creature to idle / clears the current custom animation.
    PlayCustomAnimation(oNpc, "%", FALSE);
}
void DL_ClearSleepExecutionState(object oNpc)
{
    DL_StopSleepPresentationIfActive(oNpc);
    DL_ResetNpcDirectiveState(oNpc, DL_NPC_RESET_DOMAIN_SLEEP);
}
void DL_SetSleepMissingState(object oNpc)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_NONE);
    DL_SetRuntimeState(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_MISSING_WAYPOINTS, DL_L_NPC_SLEEP_DIAGNOSTIC, DL_DIAG_SLEEP_WAYPOINTS_MISSING);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DL_ClearTransitionExecutionState(oNpc);
}
void DL_SetSleepTargetState(object oNpc, object oBed)
{
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, GetTag(oBed));
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
}
int DL_QueueJumpAction(object oNpc, location lTarget)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    object oTargetArea = GetAreaFromLocation(lTarget);
    if (!GetIsObjectValid(oTargetArea) || GetObjectType(oTargetArea) != OBJECT_TYPE_AREA)
    {
        DL_SetRuntimeState(oNpc, "", "", DL_L_NPC_SLEEP_DIAGNOSTIC, DL_DIAG_SLEEP_JUMP_INVALID_TARGET_LOCATION);
        return FALSE;
    }

    DL_DispatchJumpToLocation(oNpc, lTarget);
    return TRUE;
}
// Extension point: sleep-domain progress marker only; transition-state ownership stays in executor.
void DL_MarkSleepNavigationInProgress(object oNpc, string sTargetTag)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
    DL_SetRuntimeState(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_MOVING_VIA_NAVIGATION, "", "");
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, sTargetTag);
}
void DL_OnNpcArrivedAtSleepBed(object oNpc, object oBed)
{
    DL_OnNpcArrivedAtAnchor(oNpc, oBed, DL_L_NPC_SLEEP_STATUS, DL_STATUS_ON_BED, DL_L_NPC_SLEEP_DIAGNOSTIC, "", FALSE);
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
}
int DL_ShouldAttemptSleepNavigation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) != DL_STATUS_MOVING_VIA_NAVIGATION;
}
// Domain contract: sleep interprets transition/router outcome and updates only sleep locals.
void DL_ExecuteSleepDirective(object oNpc)
{
    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    object oBed = DL_ResolveSleepBedWaypoint(oNpc);

    if (!GetIsObjectValid(oApproach) || !GetIsObjectValid(oBed))
    {
        DL_SetSleepMissingState(oNpc);
        return;
    }

    DL_SetSleepTargetState(oNpc, oBed);
    DL_LogTransitionEvent(
        oNpc,
        "target_sleep",
        DL_BuildAnchorTelemetry(oNpc, oBed, "", "sleep")
    );

    location lApproach = GetLocation(oApproach);
    location lBed = GetLocation(oBed);
    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    int bCommittedToBed = nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED;
    int bMayUseNavigation = DL_ShouldAttemptSleepNavigation(oNpc);

    if (!bCommittedToBed && bMayUseNavigation &&
        DL_TryAdvanceViaTransitionOrRouteEx(oNpc, oApproach, DL_DIAG_CTX_ROUTED, TRUE))
    {
        return;
    }

    float fApproachDistance = GetDistanceBetween(oNpc, oApproach);
    if (!bCommittedToBed && fApproachDistance > DL_SLEEP_APPROACH_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_MOVING || DL_ShouldRedispatchMovement(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_MOVING_TO_APPROACH, fApproachDistance, DL_SLEEP_APPROACH_RADIUS))
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_MOVING_TO_APPROACH);
            DL_QueueMoveAction(oNpc, lApproach, TRUE);
        }
        return;
    }

    if (!bCommittedToBed)
    {
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_APPROACH_REACHED);
        nPhase = DL_SLEEP_PHASE_JUMPING;
    }

    if (bMayUseNavigation &&
        DL_TryAdvanceViaTransitionOrRouteEx(oNpc, oBed, DL_DIAG_CTX_ROUTED, TRUE))
    {
        return;
    }

    float fBedDistance = GetDistanceBetween(oNpc, oBed);
    if (fBedDistance > DL_SLEEP_BED_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_JUMPING || DL_ShouldRedispatchMovement(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_JUMPING_TO_BED, fBedDistance, DL_SLEEP_BED_RADIUS))
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_JUMPING_TO_BED);
            DL_QueueJumpAction(oNpc, lBed);
        }
        return;
    }

    if (nPhase != DL_SLEEP_PHASE_ON_BED || GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) != DL_STATUS_ON_BED)
    {
        DL_PlaySleepAnimation(oNpc);
    }

    DL_ClearTransitionExecutionState(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
    DL_SetRuntimeState(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_ON_BED, "", "");
    DL_LogTransitionEvent(oNpc, "on_bed", DL_BuildAnchorTelemetry(oNpc, oBed, "", "sleep"));
}
