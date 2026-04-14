object DL_ResolveBlacksmithForgeWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_FORGE,
        "dl_work_",
        "_forge",
        "dl_work_forge"
    );
}
object DL_ResolveBlacksmithCraftWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_secondary", DL_L_NPC_CACHE_WORK_SECONDARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_CRAFT,
        "dl_work_",
        "_craft",
        "dl_work_craft"
    );
}

object DL_ResolveBlacksmithFetchWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_fetch", DL_L_NPC_CACHE_WORK_FETCH, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return OBJECT_INVALID;
}
object DL_ResolveGatePostWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_POST,
        "dl_work_",
        "_post",
        "dl_work_post"
    );
}
object DL_ResolveTraderWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_TRADE,
        "dl_work_",
        "_trade",
        "dl_work_trade"
    );
}
object DL_ResolveDomesticWorkerWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oHome))
    {
        return OBJECT_INVALID;
    }

    int nTick = (GetTimeHour() * 60 + GetTimeMinute()) / 10;
    int nPhase = (nTick + DL_GetTagDeterministicOffset(GetTag(oNpc), 101, 0)) % 5;
    int nSlot = DL_GetNpcHomeSlot(oNpc);

    if (nPhase == 0)
    {
        object oMeal = DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_meal", DL_L_NPC_CACHE_MEAL, FALSE);
        if (GetIsObjectValid(oMeal))
        {
            return oMeal;
        }
    }
    else if (nPhase == 1)
    {
        object oPublic = DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_public", DL_L_NPC_CACHE_PUBLIC, FALSE);
        if (GetIsObjectValid(oPublic))
        {
            return oPublic;
        }
    }

    return DL_GetAreaAnchorWaypoint(
        oNpc,
        oHome,
        "dl_anchor_sleep_approach_" + IntToString(nSlot),
        DL_L_NPC_CACHE_SLEEP_APPROACH,
        TRUE
    );
}
void DL_ClearWorkExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_WORK_KIND);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);
}
string DL_ResolveBlacksmithWorkKindAtHour(object oNpc)
{
    int nHour = DL_NormalizeHour(GetTimeHour());
    int nMinute = GetTimeMinute();
    int nSlot = (nHour * 6) + (nMinute / 10);
    int nOffset = DL_GetTagDeterministicOffset(GetTag(oNpc), 4, 0);
    int nPhase = (nSlot + nOffset) % 12;

    if (nPhase == 4 || nPhase == 9)
    {
        return DL_WORK_KIND_FETCH;
    }

    if ((nPhase % 2) == 0)
    {
        return DL_WORK_KIND_FORGE;
    }

    return DL_WORK_KIND_CRAFT;
}
void DL_SetWorkMissingState(object oNpc, string sKind, string sDiagnostic)
{
    SetLocalString(oNpc, DL_L_NPC_WORK_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, "missing_waypoints");
    SetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC, sDiagnostic);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
    DL_ClearActivityPresentation(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
}
void DL_SetWorkTargetState(object oNpc, string sKind, object oTarget)
{
    SetLocalString(oNpc, DL_L_NPC_WORK_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_TARGET, GetTag(oTarget));
    DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
}
int DL_ProgressWorkAtTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (DL_WaypointHasTransition(oTarget))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oTarget))
        {
            return TRUE;
        }
    }

    location lTarget = GetLocation(oTarget);
    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) != "moving_to_anchor")
        {
            SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, "moving_to_anchor");
            DL_QueueMoveAction(oNpc, lTarget, TRUE);
        }
        return TRUE;
    }

    DL_ClearTransitionExecutionState(oNpc);
    SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, "on_anchor");
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
    DL_LogChatDebugEvent(oNpc, "on_work_anchor", "on_work_anchor anchor=" + GetTag(oTarget));
    return TRUE;
}
void DL_ExecuteWorkDirective(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);

    if (sProfile != DL_PROFILE_BLACKSMITH &&
        sProfile != DL_PROFILE_GATE_POST &&
        sProfile != DL_PROFILE_TRADER &&
        sProfile != DL_PROFILE_DOMESTIC_WORKER)
    {
        DL_ClearWorkExecutionState(oNpc);
        return;
    }

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        string sKind = DL_ResolveBlacksmithWorkKindAtHour(oNpc);
        object oForge = DL_ResolveBlacksmithForgeWaypoint(oNpc);
        object oCraft = DL_ResolveBlacksmithCraftWaypoint(oNpc);
        object oFetch = DL_ResolveBlacksmithFetchWaypoint(oNpc);

        if (!GetIsObjectValid(oForge) || !GetIsObjectValid(oCraft))
        {
            DL_SetWorkMissingState(oNpc, sKind, "need_forge_and_craft_waypoints");
            return;
        }

        object oTarget = oForge;
        if (sKind == DL_WORK_KIND_CRAFT)
        {
            oTarget = oCraft;
        }
        else if (sKind == DL_WORK_KIND_FETCH)
        {
            if (GetIsObjectValid(oFetch))
            {
                oTarget = oFetch;
            }
            else
            {
                sKind = DL_WORK_KIND_CRAFT;
                oTarget = oCraft;
            }
        }

        DL_SetWorkTargetState(oNpc, sKind, oTarget);
        DL_LogChatDebugEvent(
            oNpc,
            "target_work",
            "target dir=WORK area=" + GetTag(GetArea(oTarget)) + " anchor=" + GetTag(oTarget) + " kind=" + sKind
        );
        DL_ProgressWorkAtTarget(oNpc, oTarget);
        return;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        object oPost = DL_ResolveGatePostWaypoint(oNpc);

        if (!GetIsObjectValid(oPost))
        {
            DL_SetWorkMissingState(oNpc, DL_WORK_KIND_POST, "need_post_waypoint");
            return;
        }

        DL_SetWorkTargetState(oNpc, DL_WORK_KIND_POST, oPost);
        DL_LogChatDebugEvent(
            oNpc,
            "target_work",
            "target dir=WORK area=" + GetTag(GetArea(oPost)) + " anchor=" + GetTag(oPost) + " kind=" + DL_WORK_KIND_POST
        );
        DL_ProgressWorkAtTarget(oNpc, oPost);
        return;
    }

    if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        object oHomeWork = DL_ResolveDomesticWorkerWaypoint(oNpc);
        if (!GetIsObjectValid(oHomeWork))
        {
            DL_SetWorkMissingState(oNpc, DL_WORK_KIND_DOMESTIC, "need_home_domestic_anchors");
            return;
        }

        DL_SetWorkTargetState(oNpc, DL_WORK_KIND_DOMESTIC, oHomeWork);
        DL_LogChatDebugEvent(
            oNpc,
            "target_work",
            "target dir=WORK area=" + GetTag(GetArea(oHomeWork)) + " anchor=" + GetTag(oHomeWork) + " kind=" + DL_WORK_KIND_DOMESTIC
        );
        DL_ProgressWorkAtTarget(oNpc, oHomeWork);
        return;
    }

    object oTrade = DL_ResolveTraderWaypoint(oNpc);

    if (!GetIsObjectValid(oTrade))
    {
        DL_SetWorkMissingState(oNpc, DL_WORK_KIND_TRADE, "need_trade_waypoint");
        return;
    }

    DL_SetWorkTargetState(oNpc, DL_WORK_KIND_TRADE, oTrade);
    DL_LogChatDebugEvent(
        oNpc,
        "target_work",
        "target dir=WORK area=" + GetTag(GetArea(oTrade)) + " anchor=" + GetTag(oTrade) + " kind=" + DL_WORK_KIND_TRADE
    );
    DL_ProgressWorkAtTarget(oNpc, oTrade);
}
