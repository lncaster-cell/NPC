const string DL_L_NPC_SLEEP_APPROACH_ACTION_STAMP = "dl_sleep_approach_action_stamp";
const string DL_L_NPC_SLEEP_BED_ACTION_STAMP = "dl_sleep_bed_action_stamp";
const int DL_SLEEP_ACTION_REISSUE_SECONDS = 6;

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
int DL_HasSleepExitBedPlacement(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);

    if (nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED)
    {
        return TRUE;
    }

    if (sStatus == "approach_reached" || sStatus == "jumping_to_bed" || sStatus == "on_bed")
    {
        return TRUE;
    }

    return FALSE;
}
int DL_GetSleepActionStamp()
{
    return (GetTimeHour() * 3600) + (GetTimeMinute() * 60) + GetTimeSecond();
}
int DL_ShouldReissueSleepAction(object oNpc, string sKey)
{
    int nNow = DL_GetSleepActionStamp();
    int nLast = GetLocalInt(oNpc, sKey);

    if (nLast <= 0 || nNow < nLast || (nNow - nLast) >= DL_SLEEP_ACTION_REISSUE_SECONDS)
    {
        return TRUE;
    }

    return FALSE;
}
int DL_ShouldReissueSleepMoveAction(object oNpc, string sKey)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) != ACTION_MOVETOPOINT)
    {
        return TRUE;
    }

    return DL_ShouldReissueSleepAction(oNpc, sKey);
}
void DL_MarkSleepActionIssued(object oNpc, string sKey)
{
    SetLocalInt(oNpc, sKey, DL_GetSleepActionStamp());
}
void DL_ClearSleepActionIssueState(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_APPROACH_ACTION_STAMP);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_BED_ACTION_STAMP);
}
void DL_DelayedSleepExitJumpToApproach(object oNpc, location lApproach)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (!GetIsObjectValid(GetAreaFromLocation(lApproach)))
    {
        SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_exit_approach_invalid_location");
        DL_LogChatDebugEvent(oNpc, "sleep_exit_failed", "approach_valid=0 reason=invalid_location");
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lApproach));
    DL_ClearTransitionExecutionState(oNpc);
    DL_LogChatDebugEvent(oNpc, "sleep_exit_return", "returned_to_approach=1");
}
int DL_TryExitSleepToApproach(object oNpc)
{
    if (!DL_HasSleepExitBedPlacement(oNpc))
    {
        return FALSE;
    }

    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    if (!GetIsObjectValid(oApproach))
    {
        AssignCommand(oNpc, ClearAllActions(TRUE));
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_exit_approach_missing");
        DL_LogChatDebugEvent(oNpc, "sleep_exit_failed", "approach_valid=0 reason=missing_waypoint");
        return TRUE;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, 0.1));
    DL_ClearTransitionExecutionState(oNpc);
    DL_LogChatDebugEvent(
        oNpc,
        "sleep_exit_queue_return",
        "approach_anchor=" + GetTag(oApproach)
    );

    DelayCommand(0.2, DL_DelayedSleepExitJumpToApproach(oNpc, GetLocation(oApproach)));

    DL_ClearSleepActionIssueState(oNpc);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    return TRUE;
}
void DL_StopSleepPresentationIfActive(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE) <= 0 &&
        GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == "" &&
        GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) == "")
    {
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, 0.1));
}
void DL_ClearSleepExecutionState(object oNpc)
{
    if (DL_TryExitSleepToApproach(oNpc))
    {
        return;
    }

    DL_StopSleepPresentationIfActive(oNpc);
    DL_ClearSleepActionIssueState(oNpc);
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);
}
void DL_SetSleepMissingState(object oNpc)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_NONE);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "missing_waypoints");
    SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_waypoints_missing");
    DL_ClearSleepActionIssueState(oNpc);
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
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionMoveToLocation(lTarget, bRun));
}
void DL_QueueMoveToObjectAction(object oNpc, object oTarget, int bRun, float fRange)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionMoveToObject(oTarget, bRun, fRange));
}
void DL_QueueJumpAction(object oNpc, location lTarget)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lTarget));
}
void DL_MarkSleepNavigationInProgress(object oNpc, string sTargetTag)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "moving_via_navigation");
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, sTargetTag);
}
int DL_ShouldAttemptSleepNavigation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return TRUE;
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
    DL_LogChatDebugEvent(
        oNpc,
        "target_sleep",
        "target dir=SLEEP area=" + GetTag(GetArea(oBed)) + " anchor=" + GetTag(oBed)
    );

    location lApproach = GetLocation(oApproach);
    location lBed = GetLocation(oBed);
    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    int bCommittedToBed = nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED;
    int bMayUseNavigation = DL_ShouldAttemptSleepNavigation(oNpc);

    DL_NavPrepareTargetZoneFromAnchor(oNpc, oApproach);
    if (!bCommittedToBed && bMayUseNavigation && DL_NavTryAdvanceToZoneForOwner(oNpc, GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET), DL_MOVE_OWNER_SLEEP))
    {
        DL_MarkSleepNavigationInProgress(oNpc, GetTag(oApproach));
        return;
    }


    if (!bCommittedToBed && GetDistanceBetween(oNpc, oApproach) > DL_SLEEP_APPROACH_RADIUS)
    {
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "moving_to_approach");
        SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, GetTag(oApproach));
        DL_BeginMoveJobToObject(oNpc, DL_MOVE_OWNER_SLEEP, "approach", oApproach, DL_SLEEP_APPROACH_RADIUS);
        return;
    }

    if (!bCommittedToBed)
    {
        DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_APPROACH_ACTION_STAMP);
        DL_ClearMoveJob(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "approach_reached");
        nPhase = DL_SLEEP_PHASE_JUMPING;
        sStatus = "approach_reached";
    }

    DL_NavPrepareTargetZoneFromAnchor(oNpc, oBed);
    if (bMayUseNavigation && DL_NavTryAdvanceToZoneForOwner(oNpc, GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET), DL_MOVE_OWNER_SLEEP))
    {
        DL_MarkSleepNavigationInProgress(oNpc, GetTag(oBed));
        return;
    }

    if (GetDistanceBetween(oNpc, oBed) > DL_SLEEP_BED_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_JUMPING ||
            sStatus != "jumping_to_bed" ||
            DL_ShouldReissueSleepAction(oNpc, DL_L_NPC_SLEEP_BED_ACTION_STAMP))
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "jumping_to_bed");
            DL_ClearTransitionExecutionState(oNpc);
            DL_MarkSleepActionIssued(oNpc, DL_L_NPC_SLEEP_BED_ACTION_STAMP);
            DL_QueueJumpAction(oNpc, lBed);
        }
        return;
    }

    if (nPhase != DL_SLEEP_PHASE_ON_BED || sStatus != "on_bed")
    {
        DL_PlaySleepAnimation(oNpc);
    }

    DL_ClearSleepActionIssueState(oNpc);
    DL_ClearMoveJob(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "on_bed");
    DL_LogChatDebugEvent(oNpc, "on_bed", "on_bed anchor=" + GetTag(oBed));
}
