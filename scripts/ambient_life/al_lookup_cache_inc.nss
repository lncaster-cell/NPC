// Ambient Life waypoint lookup cache helpers (extracted from al_area_inc).

const int AL_LOOKUP_TRACKED_TAGS_MAX = 256;
const int AL_LOOKUP_TAG_SCAN_BUDGET_PER_TICK = 64;

int AL_LookupNowSecondOfDay()
{
    return (GetTimeHour() * 3600) + (GetTimeMinute() * 60) + GetTimeSecond();
}

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

string AL_LookupWpCheckedTickKey(string sTag)
{
    return "al_cache_wp_checked_tick_" + sTag;
}

string AL_LookupWpBuildScanIdxKey(string sTag)
{
    return "al_cache_wp_build_scan_idx_" + sTag;
}

string AL_LookupWpBuildDoneKey(string sTag)
{
    return "al_cache_wp_build_done_" + sTag;
}

string AL_LookupWpBuildStartSecKey(string sTag)
{
    return "al_cache_wp_build_start_sec_" + sTag;
}

string AL_LookupWpScanItersLastKey(string sTag)
{
    return "al_cache_wp_scan_iters_last_" + sTag;
}

string AL_LookupWpScanItersTotalKey(string sTag)
{
    return "al_cache_wp_scan_iters_total_" + sTag;
}

string AL_LookupWpScanSecLastKey(string sTag)
{
    return "al_cache_wp_scan_sec_last_" + sTag;
}

string AL_LookupWpScanSecTotalKey(string sTag)
{
    return "al_cache_wp_scan_sec_total_" + sTag;
}

int AL_LookupAcquireTagScanBudget(object oArea)
{
    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nBudgetTick = GetLocalInt(oArea, "al_cache_wp_scan_budget_tick");
    int nBudgetUsed = GetLocalInt(oArea, "al_cache_wp_scan_budget_used");
    if (nBudgetTick != nSyncTick)
    {
        nBudgetTick = nSyncTick;
        nBudgetUsed = 0;
    }

    int nRemaining = AL_LOOKUP_TAG_SCAN_BUDGET_PER_TICK - nBudgetUsed;
    if (nRemaining < 0)
    {
        nRemaining = 0;
    }

    SetLocalInt(oArea, "al_cache_wp_scan_budget_tick", nBudgetTick);
    SetLocalInt(oArea, "al_cache_wp_scan_budget_used", nBudgetUsed);
    return nRemaining;
}

void AL_LookupConsumeTagScanBudget(object oArea, int nConsumed)
{
    if (nConsumed <= 0)
    {
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nBudgetTick = GetLocalInt(oArea, "al_cache_wp_scan_budget_tick");
    int nBudgetUsed = GetLocalInt(oArea, "al_cache_wp_scan_budget_used");
    if (nBudgetTick != nSyncTick)
    {
        nBudgetTick = nSyncTick;
        nBudgetUsed = 0;
    }

    nBudgetUsed = nBudgetUsed + nConsumed;
    if (nBudgetUsed < 0)
    {
        nBudgetUsed = 0;
    }

    SetLocalInt(oArea, "al_cache_wp_scan_budget_tick", nBudgetTick);
    SetLocalInt(oArea, "al_cache_wp_scan_budget_used", nBudgetUsed);
}

string AL_LookupWpTagEnumKey(int nIdx)
{
    return "al_cache_wp_tag_" + IntToString(nIdx);
}

string AL_LookupWpTagMarkKey(string sTag)
{
    return "al_cache_wp_tag_mark_" + sTag;
}

string AL_LookupRouteFingerprintTickKey(string sTag)
{
    return "al_route_fp_tick_" + sTag;
}

string AL_LookupRouteFingerprintValueKey(string sTag)
{
    return "al_route_fp_value_" + sTag;
}

void AL_LookupInvalidateRouteFingerprintCache(object oArea, string sTag)
{
    if (sTag == "")
    {
        return;
    }

    DeleteLocalInt(oArea, AL_LookupRouteFingerprintTickKey(sTag));
    DeleteLocalInt(oArea, AL_LookupRouteFingerprintValueKey(sTag));
}

void AL_LookupClearTagCacheData(object oArea, string sTag, int bDeleteMark)
{
    if (sTag == "")
    {
        return;
    }

    int nOldCount = GetLocalInt(oArea, AL_LookupWpCountKey(sTag));
    int i = 0;
    while (i < nOldCount)
    {
        DeleteLocalObject(oArea, AL_LookupWpItemKey(sTag, i));
        i = i + 1;
    }

    DeleteLocalInt(oArea, AL_LookupWpCountKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpTickKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpCheckedTickKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpBuildScanIdxKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpBuildDoneKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpBuildStartSecKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpScanItersLastKey(sTag));
    DeleteLocalInt(oArea, AL_LookupWpScanSecLastKey(sTag));
    if (bDeleteMark)
    {
        DeleteLocalInt(oArea, AL_LookupWpTagMarkKey(sTag));
        DeleteLocalInt(oArea, AL_LookupWpScanItersTotalKey(sTag));
        DeleteLocalInt(oArea, AL_LookupWpScanSecTotalKey(sTag));
    }
}

void AL_LookupResetAreaCache(object oArea)
{
    int nTracked = GetLocalInt(oArea, "al_cache_wp_tag_count");
    int i = 0;
    while (i < nTracked)
    {
        string sTag = GetLocalString(oArea, AL_LookupWpTagEnumKey(i));
        if (sTag != "")
        {
            AL_LookupClearTagCacheData(oArea, sTag, TRUE);
            AL_LookupInvalidateRouteFingerprintCache(oArea, sTag);
        }
        DeleteLocalString(oArea, AL_LookupWpTagEnumKey(i));
        i = i + 1;
    }

    SetLocalInt(oArea, "al_cache_wp_tag_count", 0);
}

void AL_LookupTrackTag(object oArea, string sTag)
{
    if (GetLocalInt(oArea, AL_LookupWpTagMarkKey(sTag)) > 0)
    {
        return;
    }

    int nTracked = GetLocalInt(oArea, "al_cache_wp_tag_count");
    if (nTracked < 0)
    {
        nTracked = 0;
    }

    if (nTracked >= AL_LOOKUP_TRACKED_TAGS_MAX)
    {
        return;
    }

    SetLocalInt(oArea, AL_LookupWpTagMarkKey(sTag), 1);
    SetLocalString(oArea, AL_LookupWpTagEnumKey(nTracked), sTag);

    int nTrackedNew = nTracked + 1;
    SetLocalInt(oArea, "al_cache_wp_tag_count", nTrackedNew);
    if (nTrackedNew > GetLocalInt(oArea, "al_cache_wp_tag_count_peak"))
    {
        SetLocalInt(oArea, "al_cache_wp_tag_count_peak", nTrackedNew);
    }
}

void AL_LookupBuildWaypointListCache(object oArea, string sTag)
{
    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int bBuildDone = GetLocalInt(oArea, AL_LookupWpBuildDoneKey(sTag));
    int nSearchIdx = GetLocalInt(oArea, AL_LookupWpBuildScanIdxKey(sTag));
    int nFound = GetLocalInt(oArea, AL_LookupWpCountKey(sTag));

    if (bBuildDone > 0)
    {
        return;
    }

    if (nSearchIdx <= 0)
    {
        AL_LookupClearTagCacheData(oArea, sTag, FALSE);
        nSearchIdx = 0;
        nFound = 0;
        SetLocalInt(oArea, AL_LookupWpBuildStartSecKey(sTag), AL_LookupNowSecondOfDay());
    }

    int nBudget = AL_LookupAcquireTagScanBudget(oArea);
    int nIter = 0;

    if (nBudget <= 0)
    {
        SetLocalInt(oArea, AL_LookupWpScanItersLastKey(sTag), 0);
        SetLocalInt(oArea, AL_LookupWpScanSecLastKey(sTag), 0);
        SetLocalInt(oArea, AL_LookupWpTickKey(sTag), 0);
        AL_LookupTrackTag(oArea, sTag);
        return;
    }

    while (nIter < nBudget)
    {
        object oCandidate = GetObjectByTag(sTag, nSearchIdx);
        nIter = nIter + 1;
        if (!GetIsObjectValid(oCandidate))
        {
            bBuildDone = TRUE;
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

    AL_LookupConsumeTagScanBudget(oArea, nIter);
    SetLocalInt(oArea, AL_LookupWpBuildScanIdxKey(sTag), nSearchIdx);
    SetLocalInt(oArea, AL_LookupWpCountKey(sTag), nFound);
    SetLocalInt(oArea, AL_LookupWpBuildDoneKey(sTag), bBuildDone);
    SetLocalInt(oArea, AL_LookupWpScanItersLastKey(sTag), nIter);
    SetLocalInt(oArea, AL_LookupWpScanItersTotalKey(sTag), GetLocalInt(oArea, AL_LookupWpScanItersTotalKey(sTag)) + nIter);

    int nElapsedSec = 0;
    if (bBuildDone > 0)
    {
        int nStartSec = GetLocalInt(oArea, AL_LookupWpBuildStartSecKey(sTag));
        if (nStartSec > 0)
        {
            nElapsedSec = AL_LookupNowSecondOfDay() - nStartSec;
            if (nElapsedSec < 0)
            {
                nElapsedSec = nElapsedSec + 86400;
            }
        }
    }

    SetLocalInt(oArea, AL_LookupWpScanSecLastKey(sTag), nElapsedSec);
    SetLocalInt(oArea, AL_LookupWpScanSecTotalKey(sTag), GetLocalInt(oArea, AL_LookupWpScanSecTotalKey(sTag)) + nElapsedSec);
    if (bBuildDone > 0)
    {
        SetLocalInt(oArea, AL_LookupWpTickKey(sTag), nSyncTick);
        SetLocalInt(oArea, AL_LookupWpCheckedTickKey(sTag), nSyncTick);
    }
    else
    {
        SetLocalInt(oArea, AL_LookupWpTickKey(sTag), 0);
        DeleteLocalInt(oArea, AL_LookupWpCheckedTickKey(sTag));
    }

    AL_LookupTrackTag(oArea, sTag);
}

void AL_LookupInvalidateTagCache(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA || sTag == "")
    {
        return;
    }

    SetLocalInt(oArea, AL_LookupWpTickKey(sTag), 0);
    DeleteLocalInt(oArea, AL_LookupWpCheckedTickKey(sTag));
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
        AL_LookupInvalidateRouteFingerprintCache(oArea, sRouteTag);
        return;
    }

    if (sReason == AL_LOOKUP_INVALIDATE_REASON_ALL)
    {
        AL_LookupResetAreaCache(oArea);
        return;
    }

    int nTracked = GetLocalInt(oArea, "al_cache_wp_tag_count");
    int i = 0;
    while (i < nTracked)
    {
        string sTag = GetLocalString(oArea, AL_LookupWpTagEnumKey(i));
        if (sTag != "")
        {
            AL_LookupInvalidateTagCache(oArea, sTag);
            AL_LookupInvalidateRouteFingerprintCache(oArea, sTag);
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
        if (GetLocalInt(oArea, AL_LookupWpCheckedTickKey(sTag)) == nSyncTick)
        {
            AL_RecordLookupCacheHit(oArea);
            return nCachedCount;
        }

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
            SetLocalInt(oArea, AL_LookupWpCheckedTickKey(sTag), nSyncTick);
            AL_RecordLookupCacheHit(oArea);
            return nCachedCount;
        }
    }

    AL_RecordLookupCacheMiss(oArea);
    AL_LookupBuildWaypointListCache(oArea, sTag);
    return GetLocalInt(oArea, AL_LookupWpCountKey(sTag));
}

object AL_GetWaypointCandidateCachedFast(object oArea, string sTag, int nIdx)
{
    if (!GetIsObjectValid(oArea) || sTag == "" || nIdx < 0)
    {
        return OBJECT_INVALID;
    }

    return GetLocalObject(oArea, AL_LookupWpItemKey(sTag, nIdx));
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

    object oWaypoint = AL_GetWaypointCandidateCachedFast(oArea, sTag, nIdx);
    if (!GetIsObjectValid(oWaypoint) || GetObjectType(oWaypoint) != OBJECT_TYPE_WAYPOINT || GetArea(oWaypoint) != oArea)
    {
        AL_RecordLookupCacheMiss(oArea);
        AL_LookupBuildWaypointListCache(oArea, sTag);
        if (nIdx >= GetLocalInt(oArea, AL_LookupWpCountKey(sTag)))
        {
            return OBJECT_INVALID;
        }

        oWaypoint = AL_GetWaypointCandidateCachedFast(oArea, sTag, nIdx);
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
