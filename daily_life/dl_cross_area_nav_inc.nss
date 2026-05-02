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
    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntryWp, "cross_area");
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
