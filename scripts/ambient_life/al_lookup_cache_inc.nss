// Ambient Life waypoint lookup cache helpers (extracted from al_area_inc).

void AL_RecordLookupCacheHit(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_debug") <= 0)
    {
        return;
    }

    SetLocalInt(oArea, "al_cache_hit", GetLocalInt(oArea, "al_cache_hit") + 1);
}

void AL_RecordLookupCacheMiss(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_debug") <= 0)
    {
        return;
    }

    SetLocalInt(oArea, "al_cache_miss", GetLocalInt(oArea, "al_cache_miss") + 1);
}

string AL_LookupWpCountKey(string sTag)
{
    return "al_cache_wp_count_" + sTag;
}

string AL_LookupWpTickKey(string sTag)
{
    return "al_cache_wp_tick_" + sTag;
}

string AL_LookupWpItemKey(string sTag, int nIdx)
{
    return "al_cache_wp_item_" + sTag + "_" + IntToString(nIdx);
}

void AL_LookupTrackTag(object oArea, string sTag)
{
    int nTracked = GetLocalInt(oArea, "al_cache_wp_tag_count");
    int i = 0;
    while (i < nTracked)
    {
        if (GetLocalString(oArea, "al_cache_wp_tag_" + IntToString(i)) == sTag)
        {
            return;
        }
        i = i + 1;
    }

    SetLocalString(oArea, "al_cache_wp_tag_" + IntToString(nTracked), sTag);
    SetLocalInt(oArea, "al_cache_wp_tag_count", nTracked + 1);
}

void AL_LookupBuildWaypointListCache(object oArea, string sTag)
{
    int nOldCount = GetLocalInt(oArea, AL_LookupWpCountKey(sTag));
    int iClear = 0;
    while (iClear < nOldCount)
    {
        DeleteLocalObject(oArea, AL_LookupWpItemKey(sTag, iClear));
        iClear = iClear + 1;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nFound = 0;
    int nSearchIdx = 0;

    while (TRUE)
    {
        object oCandidate = GetObjectByTag(sTag, nSearchIdx);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        nSearchIdx = nSearchIdx + 1;
        if (GetObjectType(oCandidate) != OBJECT_TYPE_WAYPOINT || GetArea(oCandidate) != oArea)
        {
            continue;
        }

        SetLocalObject(oArea, AL_LookupWpItemKey(sTag, nFound), oCandidate);
        nFound = nFound + 1;
    }

    SetLocalInt(oArea, AL_LookupWpCountKey(sTag), nFound);
    SetLocalInt(oArea, AL_LookupWpTickKey(sTag), nSyncTick);
    AL_LookupTrackTag(oArea, sTag);
}

void AL_LookupInvalidateTagCache(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA || sTag == "")
    {
        return;
    }

    SetLocalInt(oArea, AL_LookupWpTickKey(sTag), 0);
}

void AL_LookupSoftInvalidateAreaCache(object oArea, string sReason, string sRouteTag)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return;
    }

    if (sReason == AL_LOOKUP_INVALIDATE_REASON_ROUTE && sRouteTag != "")
    {
        AL_LookupInvalidateTagCache(oArea, sRouteTag);
        return;
    }

    int nTracked = GetLocalInt(oArea, "al_cache_wp_tag_count");
    int i = 0;
    while (i < nTracked)
    {
        string sTag = GetLocalString(oArea, "al_cache_wp_tag_" + IntToString(i));
        if (sTag != "")
        {
            AL_LookupInvalidateTagCache(oArea, sTag);
        }
        i = i + 1;
    }
}

int AL_GetWaypointCandidatesCountCached(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA || sTag == "")
    {
        return 0;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nCachedTick = GetLocalInt(oArea, AL_LookupWpTickKey(sTag));
    int nCachedCount = GetLocalInt(oArea, AL_LookupWpCountKey(sTag));

    if (nSyncTick > 0 && nCachedTick > 0 && nSyncTick <= (nCachedTick + AL_WP_CACHE_TTL_TICKS))
    {
        int i = 0;
        while (i < nCachedCount)
        {
            object oCached = GetLocalObject(oArea, AL_LookupWpItemKey(sTag, i));
            if (!GetIsObjectValid(oCached) || GetObjectType(oCached) != OBJECT_TYPE_WAYPOINT || GetArea(oCached) != oArea)
            {
                break;
            }
            i = i + 1;
        }

        if (i == nCachedCount)
        {
            AL_RecordLookupCacheHit(oArea);
            return nCachedCount;
        }
    }

    AL_RecordLookupCacheMiss(oArea);
    AL_LookupBuildWaypointListCache(oArea, sTag);
    return GetLocalInt(oArea, AL_LookupWpCountKey(sTag));
}

object AL_GetWaypointCandidateCached(object oArea, string sTag, int nIdx)
{
    if (!GetIsObjectValid(oArea) || sTag == "" || nIdx < 0)
    {
        return OBJECT_INVALID;
    }

    int nCount = AL_GetWaypointCandidatesCountCached(oArea, sTag);
    if (nIdx >= nCount)
    {
        return OBJECT_INVALID;
    }

    object oWaypoint = GetLocalObject(oArea, AL_LookupWpItemKey(sTag, nIdx));
    if (!GetIsObjectValid(oWaypoint) || GetObjectType(oWaypoint) != OBJECT_TYPE_WAYPOINT || GetArea(oWaypoint) != oArea)
    {
        AL_RecordLookupCacheMiss(oArea);
        AL_LookupBuildWaypointListCache(oArea, sTag);
        if (nIdx >= GetLocalInt(oArea, AL_LookupWpCountKey(sTag)))
        {
            return OBJECT_INVALID;
        }

        oWaypoint = GetLocalObject(oArea, AL_LookupWpItemKey(sTag, nIdx));
    }

    return oWaypoint;
}

object AL_ResolveWaypointInAreaCached(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA || sTag == "")
    {
        return OBJECT_INVALID;
    }

    if (AL_GetWaypointCandidatesCountCached(oArea, sTag) <= 0)
    {
        return OBJECT_INVALID;
    }

    return AL_GetWaypointCandidateCached(oArea, sTag, 0);
}
