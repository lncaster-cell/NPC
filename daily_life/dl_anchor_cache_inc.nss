const int DL_AREA_PURPOSE_SLEEP = 1;
const int DL_AREA_PURPOSE_WORK = 2;
const int DL_AREA_PURPOSE_MEAL = 3;
const int DL_AREA_PURPOSE_SOCIAL = 4;
const int DL_AREA_PURPOSE_PUBLIC = 5;

object DL_GetSocialArea(object oNpc);
object DL_GetPublicArea(object oNpc);

void DL_LogInvalidAreaTagIssue(object oNpc, string sContext, string sAreaTag, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }
    DL_LogMarkupIssueOnce(oNpc, sContext + "|" + sAreaTag, "NPC " + GetTag(oNpc) + " has invalid area tag " + sAreaTag + " for " + sContext + ": " + sReason);
}

void DL_LogMissingAnchorIssue(object oNpc, object oArea, string sAnchorLocal, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }
    string sAreaTag = GetIsObjectValid(oArea) ? GetTag(oArea) : "";
    DL_LogMarkupIssueOnce(oNpc, sAnchorLocal + "|" + sAreaTag, "NPC " + GetTag(oNpc) + " has missing anchor " + sAnchorLocal + " in area " + sAreaTag + ": " + sReason);
}

void DL_LogForeignWaypointIssue(object oNpc, object oArea, string sAnchorLocal, string sWpTag, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }
    string sAreaTag = GetIsObjectValid(oArea) ? GetTag(oArea) : "";
    DL_LogMarkupIssueOnce(oNpc, sAnchorLocal + "|" + sWpTag, "NPC " + GetTag(oNpc) + " has invalid waypoint " + sWpTag + " for anchor " + sAnchorLocal + " in area " + sAreaTag + ": " + sReason);
}

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
// Public cache API: NPC-scoped anchor waypoint cache for (tag, area, tier, npc-event-seq).
// Expected lifetime: one NPC lifecycle sequence within stable area/tier context.
// Invalidation triggers: explicit invalidate, area tier change, or DL_L_NPC_EVENT_SEQ change.
object DL_GetNpcCachedWaypointByTagInArea(object oNpc, string sCacheLocal, string sTag, object oArea)
{
    return DL_GetNpcCachedObjectByTagInArea(
        oNpc,
        sCacheLocal,
        sTag,
        OBJECT_TYPE_WAYPOINT,
        oArea,
        DL_WAYPOINT_TAG_SEARCH_CAP,
        "anchor"
    );
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

    return DL_LegacyAdapterResolveForeignAnchorTransitionHandoff(oNpc, oWp);
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

    int nTier = 0;
    int nLifecycleSeq = GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ);
    object oCached = DL_GetCachedObject(oNpc, sAreaCacheLocal, sAreaTag, OBJECT_TYPE_AREA, OBJECT_INVALID, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached))
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
        DL_LogInvalidAreaTagIssue(oNpc, sAreaTagLocal, sAreaTag, "invalid_area_tag");
        return OBJECT_INVALID;
    }

    DL_SetCachedObject(oNpc, sAreaCacheLocal, oArea, sAreaTag, OBJECT_TYPE_AREA, OBJECT_INVALID, nTier, nLifecycleSeq);
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
            DL_LogMissingAnchorIssue(oNpc, oArea, sAnchorLocal, "missing_required_anchor");
        }
        return OBJECT_INVALID;
    }

    object oWp = DL_GetNpcCachedWaypointByTagInArea(oNpc, sCacheLocal, sWpTag, oArea);
    oWp = DL_ResolveEffectiveWaypointForNpc(oNpc, oWp);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    object oLegacyWp = DL_GetNpcCachedWaypointByTag(oNpc, sCacheLocal, sWpTag);
    object oEffectiveLegacyWp = DL_ResolveEffectiveWaypointForNpc(oNpc, oLegacyWp);
    if (GetIsObjectValid(oEffectiveLegacyWp) && GetArea(oEffectiveLegacyWp) == oArea)
    {
        return oEffectiveLegacyWp;
    }

    if (!GetIsObjectValid(oLegacyWp))
    {
        DL_LogForeignWaypointIssue(oNpc, oArea, sAnchorLocal, sWpTag, "missing_waypoint");
    }
    else
    {
        DL_LogForeignWaypointIssue(oNpc, oArea, sAnchorLocal, sWpTag, "foreign_waypoint_area");
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
object DL_ResolvePreferredAreaWithFallbacks(object oNpc, int nPurpose)
{
    if (nPurpose == DL_AREA_PURPOSE_SLEEP)
    {
        return DL_GetHomeArea(oNpc);
    }
    if (nPurpose == DL_AREA_PURPOSE_WORK)
    {
        return DL_GetWorkArea(oNpc);
    }
    if (nPurpose == DL_AREA_PURPOSE_MEAL)
    {
        string sMealTag = GetLocalString(oNpc, DL_L_NPC_MEAL_AREA_TAG);
        if (sMealTag != "")
        {
            object oMealArea = DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_MEAL_AREA_TAG, DL_L_NPC_CACHE_MEAL_AREA);
            if (GetIsObjectValid(oMealArea))
            {
                return oMealArea;
            }
        }

        object oHomeArea = DL_GetHomeArea(oNpc);
        if (GetIsObjectValid(oHomeArea))
        {
            return oHomeArea;
        }

        object oWorkArea = DL_GetWorkArea(oNpc);
        if (GetIsObjectValid(oWorkArea))
        {
            return oWorkArea;
        }

        return DL_GetNpcCurrentAreaFallback(oNpc);
    }
    if (nPurpose == DL_AREA_PURPOSE_SOCIAL)
    {
        object oSocialArea = DL_GetSocialArea(oNpc);
        if (GetIsObjectValid(oSocialArea))
        {
            return oSocialArea;
        }
        return DL_GetWorkArea(oNpc);
    }
    if (nPurpose == DL_AREA_PURPOSE_PUBLIC)
    {
        object oPublicArea = DL_GetPublicArea(oNpc);
        if (GetIsObjectValid(oPublicArea))
        {
            return oPublicArea;
        }
        return DL_GetSocialArea(oNpc);
    }
    return OBJECT_INVALID;
}
object DL_GetMealArea(object oNpc)
{
    return DL_ResolvePreferredAreaWithFallbacks(oNpc, DL_AREA_PURPOSE_MEAL);
}
object DL_GetSocialArea(object oNpc)
{
    return DL_GetNpcAreaOrCurrentFallback(oNpc, DL_L_NPC_SOCIAL_AREA_TAG, DL_L_NPC_CACHE_SOCIAL_AREA);
}
object DL_GetPublicArea(object oNpc)
{
    return DL_GetNpcAreaOrCurrentFallback(oNpc, DL_L_NPC_PUBLIC_AREA_TAG, DL_L_NPC_CACHE_PUBLIC_AREA);
}
