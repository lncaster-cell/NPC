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
object DL_ResolveSleepApproachWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
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
        return oWp;
    }

    return DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_APPROACH,
        oHome,
        "dl_sleep_",
        "_approach",
        "dl_sleep_approach_" + IntToString(nSlot)
    );
}
object DL_ResolveSleepBedWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
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
        return oWp;
    }

    return DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_BED,
        oHome,
        "dl_sleep_",
        "_bed",
        "dl_sleep_bed_" + IntToString(nSlot)
    );
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
    AssignCommand(oNpc, ClearAllActions(TRUE));
    if (GetIsObjectValid(oApproach))
    {
        AssignCommand(oNpc, JumpToLocation(GetLocation(oApproach)));
    }

    // NWN2 stock script documentation for PlayCustomAnimation says "%"
    // resets the creature to idle / clears the current custom animation.
    PlayCustomAnimation(oNpc, "%", FALSE);
}
void DL_ClearSleepExecutionState(object oNpc)
{
    DL_StopSleepPresentationIfActive(oNpc);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);
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
void DL_QueueMoveAction(object oNpc, location lTarget, int bRun)
{
    DL_CommandMoveToLocationResetQueue(oNpc, lTarget, bRun);
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

    DL_CommandJumpToLocationResetQueue(oNpc, lTarget);
    return TRUE;
}
void DL_MarkSleepNavigationInProgress(object oNpc, string sTargetTag)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
    DL_SetRuntimeState(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_MOVING_VIA_NAVIGATION, "", "");
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, sTargetTag);
}
int DL_ShouldAttemptSleepNavigation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) != DL_STATUS_MOVING_VIA_NAVIGATION;
}
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
        "area=" + GetTag(GetArea(oBed)) + " anchor=" + GetTag(oBed)
    );

    location lApproach = GetLocation(oApproach);
    location lBed = GetLocation(oBed);
    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    int bCommittedToBed = nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED;
    int bMayUseNavigation = DL_ShouldAttemptSleepNavigation(oNpc);

    if (!bCommittedToBed && bMayUseNavigation && DL_WaypointHasTransition(oApproach))
    {
        if (DL_TryExecuteRoutedTransitionEntryWaypoint(oNpc, oApproach))
        {
            DL_MarkSleepNavigationInProgress(oNpc, GetTag(oApproach));
            return;
        }
    }

    if (!bCommittedToBed && bMayUseNavigation && DL_TryRouteToTarget(oNpc, oApproach))
    {
        DL_MarkSleepNavigationInProgress(oNpc, GetTag(oApproach));
        return;
    }

    if (!bCommittedToBed && GetDistanceBetween(oNpc, oApproach) > DL_SLEEP_APPROACH_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_MOVING || sStatus != "moving_to_approach")
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "moving_to_approach");
            DL_QueueMoveAction(oNpc, lApproach, TRUE);
        }
        return;
    }

    if (!bCommittedToBed)
    {
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "approach_reached");
        nPhase = DL_SLEEP_PHASE_JUMPING;
        sStatus = "approach_reached";
    }

    if (bMayUseNavigation && DL_WaypointHasTransition(oBed))
    {
        if (DL_TryExecuteRoutedTransitionEntryWaypoint(oNpc, oBed))
        {
            DL_MarkSleepNavigationInProgress(oNpc, GetTag(oBed));
            return;
        }
    }

    if (bMayUseNavigation && DL_TryRouteToTarget(oNpc, oBed))
    {
        DL_MarkSleepNavigationInProgress(oNpc, GetTag(oBed));
        return;
    }

    if (GetDistanceBetween(oNpc, oBed) > DL_SLEEP_BED_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_JUMPING || sStatus != "jumping_to_bed")
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "jumping_to_bed");
            DL_QueueJumpAction(oNpc, lBed);
        }
        return;
    }

    if (nPhase != DL_SLEEP_PHASE_ON_BED || sStatus != "on_bed")
    {
        DL_PlaySleepAnimation(oNpc);
    }

    DL_ClearTransitionExecutionState(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
    DL_SetRuntimeState(oNpc, DL_L_NPC_SLEEP_STATUS, DL_STATUS_ON_BED, "", "");
    DL_LogTransitionEvent(oNpc, "on_bed", "anchor=" + GetTag(oBed));
}
