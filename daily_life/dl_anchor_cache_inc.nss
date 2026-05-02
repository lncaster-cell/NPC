const int DL_WAYPOINT_TAG_SEARCH_CAP = 64;

object DL_GetNpcCachedWaypointByTag(object oNpc, string sCacheLocal, string sTag)
{
    if (!GetIsObjectValid(oNpc) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sCacheLocal);
    if (GetIsObjectValid(oCached) && GetTag(oCached) == sTag)
    {
        return oCached;
    }

    object oWp = GetWaypointByTag(sTag);
    if (!GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    SetLocalObject(oNpc, sCacheLocal, oWp);
    return oWp;
}
object DL_GetNpcCachedWaypointByTagInArea(object oNpc, string sCacheLocal, string sTag, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sCacheLocal);
    if (DL_IsCachedObjectValidForTagInArea(oCached, sTag, OBJECT_TYPE_WAYPOINT, oArea))
    {
        DL_RecordCacheMetric(oArea, "anchor", TRUE);
        return oCached;
    }

    DeleteLocalObject(oNpc, sCacheLocal);
    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, OBJECT_TYPE_WAYPOINT, oArea, DL_WAYPOINT_TAG_SEARCH_CAP);
    if (GetIsObjectValid(oResolved))
    {
        SetLocalObject(oNpc, sCacheLocal, oResolved);
        DL_RecordCacheMetric(oArea, "anchor", FALSE);
        return oResolved;
    }

    DL_RecordCacheMetric(oArea, "anchor", FALSE);
    return OBJECT_INVALID;
}
object DL_ResolveEffectiveWaypointForNpc(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    if (GetArea(oWp) == GetArea(oNpc))
    {
        return oWp;
    }

    if (DL_WaypointHasTransition(oWp))
    {
        object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oWp);
        if (GetIsObjectValid(oExitWp) && GetArea(oExitWp) == GetArea(oNpc))
        {
            return oExitWp;
        }
    }

    return OBJECT_INVALID;
}
object DL_ResolveNpcWaypointWithFallbackTag(
    object oNpc,
    string sCacheLocal,
    string sPersonalPrefix,
    string sPersonalSuffix,
    string sFallbackTag
)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sNpcTag = GetTag(oNpc);
    object oWp = DL_GetNpcCachedWaypointByTagInArea(
        oNpc,
        sCacheLocal,
        sPersonalPrefix + sNpcTag + sPersonalSuffix,
        oArea
    );
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_GetNpcCachedWaypointByTagInArea(oNpc, sCacheLocal, sFallbackTag, oArea);
}
object DL_ResolveNpcWaypointWithFallbackTagInArea(
    object oNpc,
    string sCacheLocal,
    object oArea,
    string sPersonalPrefix,
    string sPersonalSuffix,
    string sFallbackTag
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sNpcTag = GetTag(oNpc);
    object oWp = DL_GetNpcCachedWaypointByTagInArea(
        oNpc,
        sCacheLocal,
        sPersonalPrefix + sNpcTag + sPersonalSuffix,
        oArea
    );
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_GetNpcCachedWaypointByTagInArea(oNpc, sCacheLocal, sFallbackTag, oArea);
}
object DL_GetNpcAreaByTagCached(object oNpc, string sAreaTagLocal, string sAreaCacheLocal)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sAreaTag = GetLocalString(oNpc, sAreaTagLocal);
    if (sAreaTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sAreaCacheLocal);
    if (GetIsObjectValid(oCached) && GetTag(oCached) == sAreaTag)
    {
        return oCached;
    }

    object oArea = DL_FindObjectByTagWithChecks(sAreaTag, 32, -1, OBJECT_INVALID, OBJECT_INVALID, FALSE);
    if (GetIsObjectValid(oArea) && !DL_IsAreaObject(oArea))
    {
        oArea = OBJECT_INVALID;
    }

    if (!GetIsObjectValid(oArea))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "invalid_area_" + sAreaTagLocal + "_" + sAreaTag,
            "NPC " + GetTag(oNpc) + ": area tag '" + sAreaTag + "' is invalid for local '" + sAreaTagLocal + "'."
        );
        return OBJECT_INVALID;
    }

    SetLocalObject(oNpc, sAreaCacheLocal, oArea);
    return oArea;
}
object DL_GetNpcCurrentAreaFallback(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea) && DL_IsAreaObject(oArea))
    {
        return oArea;
    }

    return OBJECT_INVALID;
}
object DL_GetNpcAreaOrCurrentFallback(object oNpc, string sAreaTagLocal, string sAreaCacheLocal)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    if (GetLocalString(oNpc, sAreaTagLocal) != "")
    {
        return DL_GetNpcAreaByTagCached(oNpc, sAreaTagLocal, sAreaCacheLocal);
    }

    return DL_GetNpcCurrentAreaFallback(oNpc);
}
object DL_GetAreaAnchorWaypoint(object oNpc, object oArea, string sAnchorLocal, string sCacheLocal, int bRequired)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sWpTag = GetLocalString(oArea, sAnchorLocal);
    if (sWpTag == "")
    {
        if (bRequired)
        {
            DL_LogMarkupIssueOnce(
                oNpc,
                "missing_anchor_" + GetTag(oArea) + "_" + sAnchorLocal,
                "Area " + GetTag(oArea) + " misses required anchor '" + sAnchorLocal + "' for NPC " + GetTag(oNpc) + "."
            );
        }
        return OBJECT_INVALID;
    }

    object oWp = DL_GetNpcCachedWaypointByTagInArea(oNpc, sCacheLocal, sWpTag, oArea);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    // Backward-compatible transition handoff: an anchor may still point to an
    // entry waypoint in another area when that entry's exit lands in the target area.
    object oLegacyWp = DL_GetNpcCachedWaypointByTag(oNpc, sCacheLocal, sWpTag);
    if (GetIsObjectValid(oLegacyWp) && DL_WaypointHasTransition(oLegacyWp))
    {
        object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oLegacyWp);
        if (GetIsObjectValid(oExitWp) && GetArea(oExitWp) == oArea)
        {
            return oExitWp;
        }
    }

    if (!GetIsObjectValid(oLegacyWp))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "missing_wp_" + GetTag(oArea) + "_" + sAnchorLocal + "_" + sWpTag,
            "Area " + GetTag(oArea) + " anchor '" + sAnchorLocal + "' points to missing waypoint '" + sWpTag + "'."
        );
    }
    else
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "foreign_wp_" + GetTag(oArea) + "_" + sAnchorLocal + "_" + sWpTag,
            "Area " + GetTag(oArea) + " anchor '" + sAnchorLocal + "' points to foreign area waypoint '" + sWpTag + "'."
        );
    }

    return OBJECT_INVALID;
}
object DL_GetHomeArea(object oNpc)
{
    object oHome = DL_GetNpcAreaOrCurrentFallback(oNpc, DL_L_NPC_HOME_AREA_TAG, DL_L_NPC_CACHE_HOME_AREA);
    if (!GetIsObjectValid(oHome))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "missing_home_area",
            "NPC " + GetTag(oNpc) + " has no valid home area and no valid current area fallback."
        );
    }
    return oHome;
}
object DL_GetWorkArea(object oNpc)
{
    return DL_GetNpcAreaOrCurrentFallback(oNpc, DL_L_NPC_WORK_AREA_TAG, DL_L_NPC_CACHE_WORK_AREA);
}
object DL_GetMealArea(object oNpc)
{
    if (GetLocalString(oNpc, DL_L_NPC_MEAL_AREA_TAG) != "")
    {
        return DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_MEAL_AREA_TAG, DL_L_NPC_CACHE_MEAL_AREA);
    }

    object oArea = DL_GetHomeArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        return oArea;
    }

    oArea = DL_GetWorkArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        return oArea;
    }

    return DL_GetNpcCurrentAreaFallback(oNpc);
}
object DL_GetSocialArea(object oNpc)
{
    return DL_GetNpcAreaOrCurrentFallback(oNpc, DL_L_NPC_SOCIAL_AREA_TAG, DL_L_NPC_CACHE_SOCIAL_AREA);
}
object DL_GetPublicArea(object oNpc)
{
    return DL_GetNpcAreaOrCurrentFallback(oNpc, DL_L_NPC_PUBLIC_AREA_TAG, DL_L_NPC_CACHE_PUBLIC_AREA);
}
