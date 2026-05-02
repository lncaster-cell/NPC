const int DL_CROSS_AREA_ROUTE_DEPTH = 4;

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
            object oExit = DL_ResolveTransitionExitWaypointFromEntry(oEntry);
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
            object oExit = DL_ResolveTransitionExitWaypointFromEntry(oEntry);
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
    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntryWp, DL_DIAG_CTX_CROSS_AREA);
}

int DL_TryUseCrossAreaNavigationRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return OBJECT_INVALID;
    }

    string sTargetZone = DL_GetWaypointNavZone(oTarget);
    if (sTargetZone == "")
    {
        return OBJECT_INVALID;
    }

    string sCurrentZone = DL_InferNpcNavZoneFromAreaRoutes(oNpc);
    if (sCurrentZone == "")
    {
        return OBJECT_INVALID;
    }

    if (GetArea(oNpc) == GetArea(oTarget) && sCurrentZone == sTargetZone)
    {
        return OBJECT_INVALID;
    }

    return DL_FindCrossAreaNavEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
}

int DL_TryUseCrossAreaNavigationRouteToTarget(object oNpc, object oTarget)
{
    object oEntry = DL_FindCrossAreaNavigationRouteEntryToTarget(oNpc, oTarget);
    return GetIsObjectValid(oEntry);
}
