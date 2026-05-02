const string DL_L_WP_NAV_TO_AREA_TAG = "dl_nav_to_area_tag";
const int DL_CROSS_AREA_TAG_SEARCH_CAP = 32;
const int DL_CROSS_AREA_ROUTE_DEPTH = 4;

string DL_GetWaypointNavToAreaTag(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_NAV_TO_AREA_TAG);
}

object DL_GetCrossNavAreaByTag(string sAreaTag)
{
    if (sAreaTag == "")
    {
        return OBJECT_INVALID;
    }

    int nNth = 0;
    while (nNth < DL_CROSS_AREA_TAG_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sAreaTag, nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (DL_IsAreaObject(oCandidate))
        {
            return oCandidate;
        }

        nNth = nNth + 1;
    }

    return OBJECT_INVALID;
}

object DL_GetCrossAreaExitSearchArea(object oEntryWp)
{
    if (!GetIsObjectValid(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    string sToAreaTag = DL_GetWaypointNavToAreaTag(oEntryWp);
    if (sToAreaTag != "")
    {
        object oTargetArea = DL_GetCrossNavAreaByTag(sToAreaTag);
        if (GetIsObjectValid(oTargetArea))
        {
            return oTargetArea;
        }
    }

    return GetArea(oEntryWp);
}

object DL_ResolveCrossAreaTransitionExitWaypointFromEntry(object oEntryWp)
{
    if (!GetIsObjectValid(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    string sResolvedTag = DL_GetResolvedTransitionExitTag(oEntryWp);
    if (sResolvedTag == "")
    {
        return OBJECT_INVALID;
    }

    object oSearchArea = DL_GetCrossAreaExitSearchArea(oEntryWp);
    object oExit = DL_GetTransitionWaypointByTagInArea(sResolvedTag, oSearchArea);
    if (GetIsObjectValid(oExit))
    {
        return oExit;
    }

    return DL_ResolveTransitionExitWaypointFromEntry(oEntryWp);
}

int DL_CrossNavEntryMatchesZone(object oEntry, string sFromZone)
{
    if (!GetIsObjectValid(oEntry) || sFromZone == "")
    {
        return FALSE;
    }

    return DL_GetWaypointNavZone(oEntry) == sFromZone;
}

int DL_AreaCanReachTargetZoneWithinDepth(object oArea, string sFromZone, object oTargetArea, string sTargetZone, int nDepth)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oTargetArea) || sFromZone == "" || sTargetZone == "")
    {
        return FALSE;
    }

    if (GetIsObjectValid(oArea) && oArea == oTargetArea && sFromZone == sTargetZone)
    {
        return TRUE;
    }

    if (nDepth <= 0)
    {
        return FALSE;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oArea);
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_GetAreaNavigationRouteAtSlot(oArea, i);
        if (DL_CrossNavEntryMatchesZone(oEntry, sFromZone))
        {
            object oExit = DL_ResolveCrossAreaTransitionExitWaypointFromEntry(oEntry);
            if (GetIsObjectValid(oExit))
            {
                object oExitArea = GetArea(oExit);
                string sExitZone = DL_GetWaypointNavZone(oExit);
                if (GetIsObjectValid(oExitArea) && sExitZone != "")
                {
                    if (oExitArea == oTargetArea && sExitZone == sTargetZone)
                    {
                        return TRUE;
                    }

                    if (DL_AreaCanReachTargetZoneWithinDepth(oExitArea, sExitZone, oTargetArea, sTargetZone, nDepth - 1))
                    {
                        return TRUE;
                    }
                }
            }
        }

        i = i + 1;
    }

    return FALSE;
}

object DL_FindCrossAreaNavEntry(object oNpc, object oTarget, string sFromZone, string sTargetZone)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget) || sFromZone == "" || sTargetZone == "")
    {
        return OBJECT_INVALID;
    }

    object oCurrentArea = GetArea(oNpc);
    object oTargetArea = GetArea(oTarget);
    if (!GetIsObjectValid(oCurrentArea) || !GetIsObjectValid(oTargetArea))
    {
        return OBJECT_INVALID;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oCurrentArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = 1000000;
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_GetAreaNavigationRouteAtSlot(oCurrentArea, i);
        if (DL_CrossNavEntryMatchesZone(oEntry, sFromZone))
        {
            object oExit = DL_ResolveCrossAreaTransitionExitWaypointFromEntry(oEntry);
            if (GetIsObjectValid(oExit))
            {
                object oExitArea = GetArea(oExit);
                string sExitZone = DL_GetWaypointNavZone(oExit);
                if (GetIsObjectValid(oExitArea) && sExitZone != "" &&
                    DL_AreaCanReachTargetZoneWithinDepth(oExitArea, sExitZone, oTargetArea, sTargetZone, DL_CROSS_AREA_ROUTE_DEPTH - 1))
                {
                    int nScore = FloatToInt(GetDistanceBetween(oNpc, oEntry) * 100.0);
                    if (oExitArea == oTargetArea)
                    {
                        nScore = nScore + FloatToInt(GetDistanceBetween(oExit, oTarget) * 100.0);
                    }
                    if (!GetIsObjectValid(oBestEntry) || nScore < nBestScore)
                    {
                        oBestEntry = oEntry;
                        nBestScore = nScore;
                    }
                }
            }
        }

        i = i + 1;
    }

    return oBestEntry;
}

int DL_TryExecuteCrossAreaTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    if (!DL_WaypointHasTransition(oEntryWp))
    {
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_ID, sTransitionId);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, GetTag(oEntryWp));

    if (GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oEntryWp)) > DL_TRANSITION_ENTRY_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "moving_to_entry")
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "moving_to_entry");
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "moving_to_cross_area_transition_entry");
            AssignCommand(oNpc, ClearAllActions(TRUE));
            AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntryWp), TRUE));
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveCrossAreaTransitionExitWaypointFromEntry(oEntryWp);
    if (!GetIsObjectValid(oExitWp))
    {
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "cross_exit_missing");
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_valid_cross_area_transition_exit_waypoint");
        return TRUE;
    }

    location lExit = GetLocation(oExitWp);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "transitioning");
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "cross_area_transition_in_progress");
    DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);

    if (sDriver == DL_TRANSITION_DRIVER_DOOR)
    {
        object oDoor = DL_ResolveTransitionDriverObject(oEntryWp);
        AssignCommand(oNpc, ClearAllActions(TRUE));
        if (GetIsObjectValid(oDoor) && GetObjectType(oDoor) == OBJECT_TYPE_DOOR && GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
        {
            AssignCommand(oNpc, DoDoorAction(oDoor, DOOR_ACTION_OPEN));
        }
        DL_JumpNpcToTransitionExit(oNpc, lExit, "transitioning", "cross_area_transition_in_progress");
        return TRUE;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    DL_JumpNpcToTransitionExit(oNpc, lExit, "transitioning", "cross_area_transition_in_progress");
    return TRUE;
}

int DL_TryUseCrossAreaNavigationRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    string sTargetZone = DL_GetWaypointNavZone(oTarget);
    if (sTargetZone == "")
    {
        return FALSE;
    }

    string sCurrentZone = DL_InferNpcNavZoneFromAreaRoutes(oNpc);
    if (sCurrentZone == "")
    {
        return FALSE;
    }

    if (GetArea(oNpc) == GetArea(oTarget) && sCurrentZone == sTargetZone)
    {
        return FALSE;
    }

    object oEntry = DL_FindCrossAreaNavEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
    if (!GetIsObjectValid(oEntry))
    {
        return FALSE;
    }

    return DL_TryExecuteCrossAreaTransitionEntryWaypoint(oNpc, oEntry);
}
