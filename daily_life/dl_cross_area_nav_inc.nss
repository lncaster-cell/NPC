const int DL_CROSS_AREA_ROUTE_DEPTH = 4;
const string DL_L_NPC_CACHE_CROSS_NAV_ENTRY = "dl_cache_cross_nav_entry";

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

object DL_FindCrossAreaNavigationRouteEntryToTarget(object oNpc, object oTarget)
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

    object oArea = GetArea(oNpc);
    int nTier = DL_GetAreaTier(oArea);
    int nLifecycleSeq = GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ);
    string sCacheTag = GetTag(oTarget) + "|" + sCurrentZone + "|" + sTargetZone;
    object oCached = DL_GetCachedObject(oNpc, DL_L_NPC_CACHE_CROSS_NAV_ENTRY, sCacheTag, OBJECT_TYPE_WAYPOINT, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
    {
        DL_RecordCacheMetric(oArea, "nav", TRUE);
        return oCached;
    }

    DL_InvalidateCachedObject(oNpc, DL_L_NPC_CACHE_CROSS_NAV_ENTRY);
    object oResolved = DL_FindCrossAreaNavEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
    if (GetIsObjectValid(oResolved))
    {
        DL_SetCachedObject(oNpc, DL_L_NPC_CACHE_CROSS_NAV_ENTRY, oResolved, sCacheTag, OBJECT_TYPE_WAYPOINT, oArea, nTier, nLifecycleSeq);
        DL_RecordCacheMetric(oArea, "nav", FALSE);
    }
    else
    {
        DL_RecordCacheMetric(oArea, "nav", FALSE);
    }

    return oResolved;
}
