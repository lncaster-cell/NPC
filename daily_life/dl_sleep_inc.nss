const string DL_L_NPC_SLEEP_ROUTE_DONE = "dl_npc_sleep_route_done";
const string DL_L_NPC_SLEEP_ROUTE_TARGET = "dl_npc_sleep_route_target";

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
object DL_ResolveSleepRouteWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    int nSlot = DL_GetNpcHomeSlot(oNpc);
    string sAnchor = "dl_anchor_sleep_route_" + IntToString(nSlot);
    return DL_GetAreaAnchorWaypoint(
        oNpc,
        oHome,
        sAnchor,
        "dl_cache_sleep_route",
        FALSE
    );
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

    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_APPROACH,
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

    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_SLEEP_BED,
        "dl_sleep_",
        "_bed",
        "dl_sleep_bed_" + IntToString(nSlot)
    );
}
void DL_ClearSleepRouteState(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_ROUTE_DONE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_ROUTE_TARGET);
}
void DL_ClearSleepExecutionState(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_ClearSleepRouteState(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
}
void DL_SetSleepMissingState(object oNpc)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_NONE);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "missing_waypoints");
    SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_waypoints_missing");
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DL_ClearSleepRouteState(oNpc);
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
void DL_QueueJumpAction(object oNpc, location lTarget)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lTarget));
}
int DL_IsSleepRouteCompleted(object oNpc, object oRoute)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oRoute))
    {
        return FALSE;
    }

    return GetLocalInt(oNpc, DL_L_NPC_SLEEP_ROUTE_DONE) == TRUE &&
           GetLocalString(oNpc, DL_L_NPC_SLEEP_ROUTE_TARGET) == GetTag(oRoute);
}
void DL_MarkSleepRouteCompleted(object oNpc, object oRoute)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oRoute))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_SLEEP_ROUTE_DONE, TRUE);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_ROUTE_TARGET, GetTag(oRoute));
    if (GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == "moving_to_route")
    {
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "route_reached");
    }
}
int DL_ProgressSleepRouteWaypoint(object oNpc, object oRoute, int bCommittedToBed)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oRoute) || bCommittedToBed)
    {
        return FALSE;
    }

    if (DL_IsSleepRouteCompleted(oNpc, oRoute))
    {
        return FALSE;
    }

    if (DL_WaypointHasTransition(oRoute))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oRoute))
        {
            return TRUE;
        }
    }

    if (GetDistanceBetween(oNpc, oRoute) > DL_SLEEP_APPROACH_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) != "moving_to_route")
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "moving_to_route");
            DL_QueueMoveAction(oNpc, GetLocation(oRoute), TRUE);
        }
        return TRUE;
    }

    DL_MarkSleepRouteCompleted(oNpc, oRoute);
    return FALSE;
}
void DL_ExecuteSleepDirective(object oNpc)
{
    object oRoute = DL_ResolveSleepRouteWaypoint(oNpc);
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

    if (DL_ProgressSleepRouteWaypoint(oNpc, oRoute, bCommittedToBed))
    {
        return;
    }

    if (!bCommittedToBed && DL_WaypointHasTransition(oApproach))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oApproach))
        {
            return;
        }
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

    if (DL_WaypointHasTransition(oBed))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oBed))
        {
            return;
        }
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
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "on_bed");
    DL_LogChatDebugEvent(oNpc, "on_bed", "on_bed anchor=" + GetTag(oBed));
}
