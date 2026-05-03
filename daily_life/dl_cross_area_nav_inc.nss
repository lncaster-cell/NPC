const int DL_CROSS_AREA_ROUTE_DEPTH = 4;
const float DL_CROSS_AREA_SCORE_SCALE = 100.0;
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
            object oExit = DL_TryGetTransitionExitWaypoint(oEntry);
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

int DL_ScoreCrossAreaRouteCandidate(object oNpc, object oTarget, object oEntry, object oExit, object oTargetArea)
{
    if (!DL_IsValidNpcObject(oNpc) || !GetIsObjectValid(oTarget) ||
        !GetIsObjectValid(oEntry) || !GetIsObjectValid(oExit) || !GetIsObjectValid(oTargetArea))
    {
        return DL_SELECTION_SCORE_INF;
    }

    int nScore = FloatToInt(GetDistanceBetween(oNpc, oEntry) * DL_CROSS_AREA_SCORE_SCALE);
    if (GetArea(oExit) == oTargetArea)
    {
        nScore = nScore + FloatToInt(GetDistanceBetween(oExit, oTarget) * DL_CROSS_AREA_SCORE_SCALE);
    }
    return nScore;
}

int DL_IsCrossAreaCandidateValid(object oEntry, object oExit, object oExitArea, string sFromZone, string sExitZone, object oTargetArea, string sTargetZone)
{
    if (!DL_CrossNavEntryMatchesZone(oEntry, sFromZone) || !GetIsObjectValid(oExit) ||
        !GetIsObjectValid(oExitArea) || sExitZone == "")
    {
        return FALSE;
    }

    return DL_AreaCanReachTargetZoneWithinDepth(
        oExitArea,
        sExitZone,
        oTargetArea,
        sTargetZone,
        DL_CROSS_AREA_ROUTE_DEPTH - 1
    );
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
    int nBestScore = DL_SELECTION_SCORE_INF;
    string sBestTie = "";
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_GetAreaNavigationRouteAtSlot(oCurrentArea, i);
        if (DL_CrossNavEntryMatchesZone(oEntry, sFromZone))
        {
            object oExit = DL_TryGetTransitionExitWaypoint(oEntry);
            object oExitArea = GetArea(oExit);
            string sExitZone = DL_GetWaypointNavZone(oExit);
            if (DL_IsCrossAreaCandidateValid(oEntry, oExit, oExitArea, sFromZone, sExitZone, oTargetArea, sTargetZone))
            {
                int nScore = DL_ScoreCrossAreaRouteCandidate(oNpc, oTarget, oEntry, oExit, oTargetArea);
                string sTie = DL_SelectionBuildTieKey(oEntry, oExit, i);
                if (DL_SelectionCompare(nScore, nBestScore, sTie, sBestTie))
                {
                    oBestEntry = oEntry;
                    nBestScore = nScore;
                    sBestTie = sTie;
                }
            }
        }

        i = i + 1;
    }

    return oBestEntry;
}

// Public cache API: NPC-scoped cross-area route-entry cache.
// Expected lifetime: one NPC event sequence in the same source area/tier and same target+zone tuple.
// Invalidation triggers: explicit invalidate, area/tier context shift, or DL_L_NPC_EVENT_SEQ increment.
object DL_FindCrossAreaNavigationRouteEntryToTarget(object oNpc, object oTarget)
{
    if (!DL_IsValidNpcObject(oNpc) || !GetIsObjectValid(oTarget))
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
    string sCacheTag = DL_BuildTransitionRuntimeKey3(GetTag(oTarget), sCurrentZone, sTargetZone);
    object oCached = DL_GetCachedObject(oNpc, DL_L_NPC_CACHE_CROSS_NAV_ENTRY, sCacheTag, OBJECT_TYPE_WAYPOINT, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
    {
        DL_RecordCacheMetric(oArea, "nav", TRUE);
        return oCached;
    }

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
