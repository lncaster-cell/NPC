object DL_ResolveBlacksmithForgeWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_FORGE,
        "dl_work_",
        "_forge",
        "dl_work_forge"
    ));
}
object DL_ResolveBlacksmithCraftWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_secondary", DL_L_NPC_CACHE_WORK_SECONDARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_CRAFT,
        "dl_work_",
        "_craft",
        "dl_work_craft"
    ));
}

object DL_ResolveBlacksmithFetchWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_fetch", DL_L_NPC_CACHE_WORK_FETCH, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }

    return OBJECT_INVALID;
}
object DL_ResolveGatePostWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_POST,
        "dl_work_",
        "_post",
        "dl_work_post"
    ));
}
object DL_ResolveTraderWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    }
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_TRADE,
        "dl_work_",
        "_trade",
        "dl_work_trade"
    ));
}
object DL_ResolveDomesticWorkerWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oHome))
    {
        return OBJECT_INVALID;
    }

    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE));
}

object DL_ResolveDomesticWorkerSecondaryWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oHome))
    {
        return OBJECT_INVALID;
    }

    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_work_secondary", DL_L_NPC_CACHE_WORK_SECONDARY, FALSE));
}

object DL_ResolveDomesticWorkerFetchWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oHome))
    {
        return OBJECT_INVALID;
    }

    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_work_fetch", DL_L_NPC_CACHE_WORK_FETCH, FALSE));
}

string DL_ResolveDomesticWorkerWorkKind(object oNpc, int bHasFetch)
{
    int nTick = (GetTimeHour() * 60 + GetTimeMinute()) / 10;
    int nPhase = (nTick + DL_GetTagDeterministicOffset(GetTag(oNpc), 101, 0)) % 10;

    // Primary chores (cooking) are dominant.
    if (nPhase <= 5)
    {
        return DL_WORK_KIND_DOMESTIC;
    }

    // Secondary chores (crafting/maintenance) are regular.
    if (nPhase <= 8)
    {
        return DL_WORK_KIND_CRAFT;
    }

    if (bHasFetch)
    {
        return DL_WORK_KIND_FETCH;
    }

    return DL_WORK_KIND_CRAFT;
}
void DL_ClearWorkExecutionState(object oNpc)
{
    DL_ResetNpcDirectiveState(oNpc, DL_NPC_RESET_DOMAIN_WORK);
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
    DL_SetRuntimeState(oNpc, DL_L_NPC_WORK_STATUS, DL_STATUS_MISSING_WAYPOINTS, DL_L_NPC_WORK_DIAGNOSTIC, sDiagnostic);
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
// Domain contract: interpret navigation result only; do not mutate transition locals directly.
int DL_ProgressWorkAtTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (DL_TryAdvanceViaTransitionOrRoute(oNpc, oTarget, DL_DIAG_CTX_ROUTED))
    {
        return TRUE;
    }

    location lTarget = GetLocation(oTarget);
    float fTargetDistance = GetDistanceBetween(oNpc, oTarget);
    if (fTargetDistance > DL_WORK_ANCHOR_RADIUS)
    {
        if (DL_ShouldRedispatchMovement(oNpc, DL_L_NPC_WORK_STATUS, DL_STATUS_MOVING_TO_ANCHOR, fTargetDistance, DL_WORK_ANCHOR_RADIUS))
        {
            DL_SetRuntimeState(oNpc, DL_L_NPC_WORK_STATUS, DL_STATUS_MOVING_TO_ANCHOR, "", "");
            DL_QueueMoveAction(oNpc, lTarget, TRUE);
        }
        return TRUE;
    }

    DL_OnNpcArrivedAtAnchor(oNpc, oTarget, DL_L_NPC_WORK_STATUS, DL_STATUS_ON_ANCHOR, DL_L_NPC_WORK_DIAGNOSTIC, "", TRUE);
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
    DL_LogTransitionEvent(oNpc, "on_work_anchor", DL_BuildAnchorTelemetry(oNpc, oTarget, "", "work"));
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
            DL_SetWorkMissingState(oNpc, sKind, DL_DIAG_WORK_FORGE_AND_CRAFT_WAYPOINTS_REQUIRED);
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
        DL_LogTransitionEvent(
            oNpc,
            "target_work",
            DL_BuildAnchorTelemetry(oNpc, oTarget, "target dir=WORK kind=" + sKind, "work")
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
        DL_LogTransitionEvent(
            oNpc,
            "target_work",
            DL_BuildAnchorTelemetry(oNpc, oPost, "target dir=WORK kind=" + DL_WORK_KIND_POST, "work")
        );
        DL_ProgressWorkAtTarget(oNpc, oPost);
        return;
    }

    if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        object oPrimary = DL_ResolveDomesticWorkerWaypoint(oNpc);
        object oSecondary = DL_ResolveDomesticWorkerSecondaryWaypoint(oNpc);
        object oFetch = DL_ResolveDomesticWorkerFetchWaypoint(oNpc);
        int bHasFetch = GetIsObjectValid(oFetch);

        if (!GetIsObjectValid(oPrimary) || !GetIsObjectValid(oSecondary))
        {
            DL_SetWorkMissingState(oNpc, DL_WORK_KIND_DOMESTIC, "need_home_domestic_anchors");
            return;
        }

        string sKind = DL_ResolveDomesticWorkerWorkKind(oNpc, bHasFetch);
        object oHomeWork = oPrimary;
        if (sKind == DL_WORK_KIND_CRAFT)
        {
            oHomeWork = oSecondary;
        }
        else if (sKind == DL_WORK_KIND_FETCH)
        {
            oHomeWork = oFetch;
        }

        DL_SetWorkTargetState(oNpc, sKind, oHomeWork);
        DL_LogTransitionEvent(
            oNpc,
            "target_work",
            DL_BuildAnchorTelemetry(oNpc, oHomeWork, "target dir=WORK kind=" + sKind, "work")
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
    DL_LogTransitionEvent(
        oNpc,
        "target_work",
        DL_BuildAnchorTelemetry(oNpc, oTrade, "target dir=WORK kind=" + DL_WORK_KIND_TRADE, "work")
    );
    DL_ProgressWorkAtTarget(oNpc, oTrade);
}
