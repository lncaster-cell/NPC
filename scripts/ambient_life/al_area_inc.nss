// Ambient Life area lifecycle and single-loop tick runtime (Stage C).

#include "al_events_inc"
#include "al_registry_inc"
#include "al_dispatch_inc"

const float AL_AREA_TICK_SEC = 30.0;
const int AL_SIM_TIER_FREEZE = 0;
const int AL_SIM_TIER_WARM = 1;
const int AL_SIM_TIER_HOT = 2;
const int AL_WARM_RETENTION_TICKS = 2;
const int AL_WARM_MAINTENANCE_PERIOD = 4;
const int AL_WP_CACHE_TTL_TICKS = 10;
const int AL_HEALTH_RESYNC_WINDOW_TICKS = 8;
const string AL_COUNTED_AREA_LOCAL = "al_counted_area";
const string AL_TICK_SCHED_MARKER_LOCAL = "al_tick_from_scheduler";

int AL_ComputeHealthResyncWindowMask()
{
    int nWindowMask = 0;
    int i = 0;

    while (i < AL_HEALTH_RESYNC_WINDOW_TICKS)
    {
        nWindowMask = (nWindowMask * 2) + 1;
        i = i + 1;
    }

    return nWindowMask;
}

void AL_EnsureAreaHealthSnapshotInit(object oArea)
{
    if (GetLocalInt(oArea, "al_h_resync_window_mask") <= 0)
    {
        SetLocalInt(oArea, "al_h_resync_window_mask", AL_ComputeHealthResyncWindowMask());
    }
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

void AL_LookupSoftInvalidateAreaCache(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return;
    }

    int nTracked = GetLocalInt(oArea, "al_cache_wp_tag_count");
    int i = 0;
    while (i < nTracked)
    {
        string sTag = GetLocalString(oArea, "al_cache_wp_tag_" + IntToString(i));
        if (sTag != "")
        {
            SetLocalInt(oArea, AL_LookupWpTickKey(sTag), 0);
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

int AL_ComputeAreaSlot()
{
    return GetTimeHour() / 4;
}

int AL_GetLinkedAreaCount(object oArea)
{
    return GetLocalInt(oArea, "al_link_count");
}

void AL_RebuildLinkedAreaCache(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return;
    }

    int nCfgCount = GetLocalInt(oArea, "al_link_count");
    if (nCfgCount < 0)
    {
        nCfgCount = 0;
    }

    int nPrevCount = GetLocalInt(oArea, "al_link_obj_count");
    int nClearCount = nPrevCount;
    if (nCfgCount > nClearCount)
    {
        nClearCount = nCfgCount;
    }

    int i = 0;
    while (i < nClearCount)
    {
        DeleteLocalObject(oArea, "al_link_obj_" + IntToString(i));
        i = i + 1;
    }

    int nDebug = GetLocalInt(oArea, "al_debug");
    i = 0;
    while (i < nCfgCount)
    {
        string sTag = GetLocalString(oArea, "al_link_" + IntToString(i));
        object oLinked = OBJECT_INVALID;
        int bBroken = FALSE;
        int bAmbiguous = FALSE;

        if (sTag == "")
        {
            bBroken = TRUE;
        }
        else
        {
            oLinked = GetObjectByTag(sTag, 0);
            if (!GetIsObjectValid(oLinked) || GetObjectType(oLinked) != OBJECT_TYPE_AREA)
            {
                oLinked = OBJECT_INVALID;
                bBroken = TRUE;
            }
            else
            {
                object oSecond = GetObjectByTag(sTag, 1);
                if (GetIsObjectValid(oSecond))
                {
                    bAmbiguous = TRUE;
                }
            }
        }

        if (GetIsObjectValid(oLinked) && oLinked == oArea)
        {
            oLinked = OBJECT_INVALID;
            bBroken = TRUE;
        }

        SetLocalObject(oArea, "al_link_obj_" + IntToString(i), oLinked);

        if (nDebug > 0 && (bBroken || bAmbiguous))
        {
            string sReason = "broken";
            if (bAmbiguous)
            {
                sReason = "ambiguous";
            }

            WriteTimestampedLogEntry(
                "[AL][LinkedAreaCache] area=" + GetTag(oArea)
                + " idx=" + IntToString(i)
                + " tag='" + sTag + "'"
                + " reason=" + sReason
            );
        }

        i = i + 1;
    }

    SetLocalInt(oArea, "al_link_obj_count", nCfgCount);
    SetLocalInt(oArea, "al_link_cache_rev", GetLocalInt(oArea, "al_link_cfg_rev"));
}

int AL_GetLinkedAreaCachedCount(object oArea)
{
    if (GetLocalInt(oArea, "al_link_cache_rev") != GetLocalInt(oArea, "al_link_cfg_rev"))
    {
        AL_RebuildLinkedAreaCache(oArea);
    }

    return GetLocalInt(oArea, "al_link_obj_count");
}

object AL_GetLinkedAreaByIndex(object oArea, int nIdx)
{
    if (nIdx < 0)
    {
        return OBJECT_INVALID;
    }

    int bRebuilt = FALSE;
    if (GetLocalInt(oArea, "al_link_cache_rev") != GetLocalInt(oArea, "al_link_cfg_rev"))
    {
        AL_RebuildLinkedAreaCache(oArea);
        bRebuilt = TRUE;
    }

    if (nIdx >= GetLocalInt(oArea, "al_link_obj_count"))
    {
        AL_RebuildLinkedAreaCache(oArea);
        bRebuilt = TRUE;
    }

    object oLinked = GetLocalObject(oArea, "al_link_obj_" + IntToString(nIdx));
    if ((!GetIsObjectValid(oLinked) || GetObjectType(oLinked) != OBJECT_TYPE_AREA) && !bRebuilt)
    {
        AL_RebuildLinkedAreaCache(oArea);
        oLinked = GetLocalObject(oArea, "al_link_obj_" + IntToString(nIdx));
    }

    if (!GetIsObjectValid(oLinked) || GetObjectType(oLinked) != OBJECT_TYPE_AREA)
    {
        return OBJECT_INVALID;
    }

    return oLinked;
}

void AL_ScheduleAreaTick(object oArea, int nToken);

void AL_AreaSetTier(object oArea, int nTier)
{
    AL_EnsureAreaHealthSnapshotInit(oArea);

    int nOldTier = GetLocalInt(oArea, "al_sim_tier");
    if (nOldTier == nTier)
    {
        return;
    }

    SetLocalInt(oArea, "al_sim_tier", nTier);
    AL_LookupSoftInvalidateAreaCache(oArea);

    if (nTier == AL_SIM_TIER_FREEZE)
    {
        int nToken = GetLocalInt(oArea, "al_tick_token") + 1;
        SetLocalInt(oArea, "al_tick_token", nToken);
        SetLocalInt(oArea, "al_sync_tick", 0);
        AL_ResetDispatchPendingIndex(oArea);
        return;
    }

    int nToken = GetLocalInt(oArea, "al_tick_token") + 1;
    SetLocalInt(oArea, "al_tick_token", nToken);
    AL_RegistryCompact(oArea);

    if (GetLocalInt(oArea, "al_sync_tick") <= 0)
    {
        SetLocalInt(oArea, "al_sync_tick", 1);
    }

    if (nTier == AL_SIM_TIER_HOT)
    {
        int nSlot = AL_ComputeAreaSlot();
        SetLocalInt(oArea, "al_slot", nSlot);
        SetLocalInt(oArea, "al_h_last_resync_tick", GetLocalInt(oArea, "al_sync_tick") + 1);
        AL_DispatchEventToAreaRegistry(oArea, AL_EVENT_RESYNC);
    }

    AL_ScheduleAreaTick(oArea, nToken);
}

void AL_MarkAreaWarm(object oArea)
{
    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    if (nSyncTick <= 0)
    {
        nSyncTick = 1;
    }

    int nWarmUntil = nSyncTick + AL_WARM_RETENTION_TICKS;
    if (GetLocalInt(oArea, "al_warm_until_sync") < nWarmUntil)
    {
        SetLocalInt(oArea, "al_warm_until_sync", nWarmUntil);
    }

    if (GetLocalInt(oArea, "al_sim_tier") < AL_SIM_TIER_WARM)
    {
        AL_AreaSetTier(oArea, AL_SIM_TIER_WARM);
    }
}

void AL_RefreshLinkedAreasWarmth(object oArea)
{
    int nCount = AL_GetLinkedAreaCachedCount(oArea);
    int i = 0;

    while (i < nCount)
    {
        object oLinked = GetLocalObject(oArea, "al_link_obj_" + IntToString(i));
        if (GetIsObjectValid(oLinked) && oLinked != oArea)
        {
            AL_MarkAreaWarm(oLinked);
        }
        i = i + 1;
    }
}

int AL_HasLinkedHotSource(object oArea)
{
    int nCount = AL_GetLinkedAreaCachedCount(oArea);
    int i = 0;

    while (i < nCount)
    {
        object oLinked = GetLocalObject(oArea, "al_link_obj_" + IntToString(i));
        if (GetIsObjectValid(oLinked) && GetLocalInt(oLinked, "al_player_count") > 0)
        {
            return TRUE;
        }
        i = i + 1;
    }

    return FALSE;
}

int AL_ResolveAreaTier(object oArea)
{
    if (GetLocalInt(oArea, "al_player_count") > 0)
    {
        return AL_SIM_TIER_HOT;
    }

    if (AL_HasLinkedHotSource(oArea))
    {
        return AL_SIM_TIER_WARM;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    if (nSyncTick <= 0)
    {
        nSyncTick = 1;
    }

    if (GetLocalInt(oArea, "al_warm_until_sync") >= nSyncTick)
    {
        return AL_SIM_TIER_WARM;
    }

    return AL_SIM_TIER_FREEZE;
}

void AL_RunBatchedDispatch(object oArea);
void AL_StartBatchedDispatch(object oArea, int nEvent);

void AL_DequeueBatchedDispatch(object oArea)
{
    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    if (nLen <= 0)
    {
        return;
    }

    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    string sCycleKey = GetLocalString(oArea, AL_DispatchQueueKey("cycle", nHead));
    DeleteLocalInt(oArea, AL_DispatchQueueKey("event", nHead));
    DeleteLocalInt(oArea, AL_DispatchQueueKey("prio", nHead));
    DeleteLocalString(oArea, AL_DispatchQueueKey("cycle", nHead));
    AL_ClearDispatchPendingKey(oArea, sCycleKey);

    SetLocalInt(oArea, "al_dispatch_q_head", (nHead + 1) % AL_DISPATCH_QUEUE_CAPACITY);
    SetLocalInt(oArea, "al_dispatch_q_len", nLen - 1);
}

int AL_PickDispatchQueueIndex(object oArea)
{
    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int i = 0;
    int nFirstNormal = -1;
    int nFirstCritical = -1;
    int bHasNormal = FALSE;

    if (nLen <= 0)
    {
        return -1;
    }

    while (i < nLen)
    {
        int nIdx = (nHead + i) % AL_DISPATCH_QUEUE_CAPACITY;
        int nPriority = GetLocalInt(oArea, AL_DispatchQueueKey("prio", nIdx));
        if (nPriority == AL_DISPATCH_PRIORITY_CRITICAL)
        {
            if (nFirstCritical < 0)
            {
                nFirstCritical = nIdx;
            }
        }
        else
        {
            bHasNormal = TRUE;
            if (nFirstNormal < 0)
            {
                nFirstNormal = nIdx;
            }
        }

        i = i + 1;
    }

    int nCriticalStreak = GetLocalInt(oArea, "al_dispatch_critical_streak");
    if (nFirstCritical >= 0)
    {
        if (nCriticalStreak >= AL_DISPATCH_CRITICAL_BURST_QUOTA && bHasNormal)
        {
            return nFirstNormal;
        }

        return nFirstCritical;
    }

    if (nFirstNormal >= 0)
    {
        return nFirstNormal;
    }

    return nHead;
}

void AL_ActivateQueuedDispatch(object oArea)
{
    if (GetLocalInt(oArea, "al_dispatch_active") > 0)
    {
        return;
    }

    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    if (nLen <= 0)
    {
        AL_OnDispatchWorkDrained(oArea);
        return;
    }

    int nPickIdx = AL_PickDispatchQueueIndex(oArea);
    if (nPickIdx < 0)
    {
        AL_OnDispatchWorkDrained(oArea);
        return;
    }

    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    if (nPickIdx != nHead)
    {
        int nHeadEvent = GetLocalInt(oArea, AL_DispatchQueueKey("event", nHead));
        int nHeadPrio = GetLocalInt(oArea, AL_DispatchQueueKey("prio", nHead));
        string sHeadCycle = GetLocalString(oArea, AL_DispatchQueueKey("cycle", nHead));

        SetLocalInt(oArea, AL_DispatchQueueKey("event", nHead), GetLocalInt(oArea, AL_DispatchQueueKey("event", nPickIdx)));
        SetLocalInt(oArea, AL_DispatchQueueKey("prio", nHead), GetLocalInt(oArea, AL_DispatchQueueKey("prio", nPickIdx)));
        SetLocalString(oArea, AL_DispatchQueueKey("cycle", nHead), GetLocalString(oArea, AL_DispatchQueueKey("cycle", nPickIdx)));

        SetLocalInt(oArea, AL_DispatchQueueKey("event", nPickIdx), nHeadEvent);
        SetLocalInt(oArea, AL_DispatchQueueKey("prio", nPickIdx), nHeadPrio);
        SetLocalString(oArea, AL_DispatchQueueKey("cycle", nPickIdx), sHeadCycle);
    }

    int nEvent = GetLocalInt(oArea, AL_DispatchQueueKey("event", nHead));
    string sCycleKey = GetLocalString(oArea, AL_DispatchQueueKey("cycle", nHead));
    int nPriority = GetLocalInt(oArea, AL_DispatchQueueKey("prio", nHead));

    AL_DequeueBatchedDispatch(oArea);

    int nCycleId = GetLocalInt(oArea, "al_dispatch_cycle") + 1;
    SetLocalInt(oArea, "al_dispatch_cycle", nCycleId);
    SetLocalInt(oArea, "al_dispatch_cursor", 0);
    SetLocalInt(oArea, "al_dispatch_event", nEvent);
    SetLocalInt(oArea, "al_dispatch_active", 1);
    SetLocalString(oArea, "al_dispatch_cycle_key", sCycleKey);

    if (nPriority == AL_DISPATCH_PRIORITY_CRITICAL)
    {
        SetLocalInt(oArea, "al_dispatch_critical_streak", GetLocalInt(oArea, "al_dispatch_critical_streak") + 1);
    }
    else
    {
        SetLocalInt(oArea, "al_dispatch_critical_streak", 0);
    }

    AL_UpdateDispatchQueueMetrics(oArea);
    AL_RunBatchedDispatch(oArea);
}

void AL_StartBatchedDispatch(object oArea, int nEvent)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    string sCycleKey = IntToString(nEvent) + ":" + IntToString(GetLocalInt(oArea, "al_sync_tick"));
    SetLocalInt(oArea, "al_dispatch_dedupe_checks", GetLocalInt(oArea, "al_dispatch_dedupe_checks") + 1);

    if (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalInt(oArea, "al_dispatch_event") == nEvent
        && GetLocalString(oArea, "al_dispatch_cycle_key") == sCycleKey)
    {
        SetLocalInt(oArea, "al_dispatch_dedupe_hits", GetLocalInt(oArea, "al_dispatch_dedupe_hits") + 1);
        AL_UpdateDispatchQueueMetrics(oArea);
        return;
    }

    if (GetLocalInt(oArea, AL_DispatchPendingMemberKey(sCycleKey)) > 0
        || (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalString(oArea, "al_dispatch_cycle_key") == sCycleKey))
    {
        SetLocalInt(oArea, "al_dispatch_dedupe_hits", GetLocalInt(oArea, "al_dispatch_dedupe_hits") + 1);
        AL_UpdateDispatchQueueMetrics(oArea);
        return;
    }

    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");

    if (nLen >= AL_DISPATCH_QUEUE_CAPACITY)
    {
        SetLocalInt(oArea, "al_dispatch_q_overflow", GetLocalInt(oArea, "al_dispatch_q_overflow") + 1);
        AL_PruneDispatchPendingIndex(oArea);
        return;
    }

    int nTail = (nHead + nLen) % AL_DISPATCH_QUEUE_CAPACITY;
    SetLocalInt(oArea, AL_DispatchQueueKey("event", nTail), nEvent);
    SetLocalInt(oArea, AL_DispatchQueueKey("prio", nTail), AL_DispatchPriorityFromEvent(nEvent));
    SetLocalString(oArea, AL_DispatchQueueKey("cycle", nTail), sCycleKey);
    SetLocalInt(oArea, "al_dispatch_q_len", nLen + 1);

    SetLocalInt(oArea, AL_DispatchPendingKey(sCycleKey), 1);
    SetLocalInt(oArea, AL_DispatchPendingMemberKey(sCycleKey), 1);
    AL_TrackDispatchPendingKey(oArea, sCycleKey);
    AL_OnDispatchWorkQueued(oArea);
    AL_ActivateQueuedDispatch(oArea);
}

void AL_RunBatchedDispatch(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, "al_dispatch_active") <= 0)
    {
        return;
    }

    int nEvent = GetLocalInt(oArea, "al_dispatch_event");
    int nCount = GetLocalInt(oArea, "al_npc_count");
    int nCursor = GetLocalInt(oArea, "al_dispatch_cursor");
    int nCycleId = GetLocalInt(oArea, "al_dispatch_cycle");
    int nProcessed = 0;

    SetLocalInt(oArea, "al_dispatch_ticks", GetLocalInt(oArea, "al_dispatch_ticks") + 1);

    while (nCursor < nCount && nProcessed < AL_DISPATCH_BATCH_SIZE)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(nCursor));
        if (GetIsObjectValid(oNpc) && GetLocalInt(oNpc, "al_dispatch_seen_cycle") != nCycleId)
        {
            SetLocalInt(oNpc, "al_dispatch_seen_cycle", nCycleId);
            SignalEvent(oNpc, EventUserDefined(nEvent));
            nProcessed = nProcessed + 1;
        }

        nCursor = nCursor + 1;
    }

    SetLocalInt(oArea, "al_dispatch_cursor", nCursor);
    if (nCursor >= nCount)
    {
        SetLocalInt(oArea, "al_dispatch_active", 0);
        AL_ClearDispatchPendingKey(oArea, GetLocalString(oArea, "al_dispatch_cycle_key"));
        DeleteLocalString(oArea, "al_dispatch_cycle_key");
        AL_PruneDispatchPendingIndex(oArea);
        AL_ActivateQueuedDispatch(oArea);
        return;
    }

    DelayCommand(0.0, AL_RunBatchedDispatch(oArea));
}

void AL_DispatchEventToAreaRegistry(object oArea, int nEvent)
{
    AL_RegistryCompact(oArea);
    AL_StartBatchedDispatch(oArea, nEvent);
}

void AL_AreaTick(object oArea, int nToken);


int AL_CountBits(int nValue)
{
    int nCount = 0;
    int nWork = nValue;

    while (nWork > 0)
    {
        if ((nWork & 1) == 1)
        {
            nCount = nCount + 1;
        }

        nWork = nWork / 2;
    }

    return nCount;
}

void AL_UpdateAreaHealthSnapshot(object oArea)
{
    AL_EnsureAreaHealthSnapshotInit(oArea);

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nResyncTick = GetLocalInt(oArea, "al_h_last_resync_tick");
    int nResyncMask = GetLocalInt(oArea, "al_h_recent_resync_mask");
    int nWindowMask = GetLocalInt(oArea, "al_h_resync_window_mask");

    int bResyncThisTick = FALSE;
    if (nResyncTick > 0 && nSyncTick > 0 && nResyncTick == nSyncTick)
    {
        bResyncThisTick = TRUE;
    }

    nResyncMask = (nResyncMask * 2) & nWindowMask;
    if (bResyncThisTick)
    {
        nResyncMask = nResyncMask | 1;
    }

    int nRecentResync = AL_CountBits(nResyncMask);

    int nNpcCount = GetLocalInt(oArea, "al_npc_count");
    int nTier = GetLocalInt(oArea, "al_sim_tier");
    int nSlot = GetLocalInt(oArea, "al_slot");
    int nRegOverflow = GetLocalInt(oArea, "al_reg_overflow_count");
    int nRouteOverflow = GetLocalInt(oArea, "al_route_overflow_count");

    SetLocalInt(oArea, "al_h_npc_count", nNpcCount);
    SetLocalInt(oArea, "al_h_tier", nTier);
    SetLocalInt(oArea, "al_h_slot", nSlot);
    SetLocalInt(oArea, "al_h_sync_tick", nSyncTick);
    SetLocalInt(oArea, "al_h_reg_overflow_count", nRegOverflow);
    SetLocalInt(oArea, "al_h_route_overflow_count", nRouteOverflow);
    SetLocalInt(oArea, "al_h_recent_resync", nRecentResync);
    SetLocalInt(oArea, "al_h_recent_resync_mask", nResyncMask);

    if (GetLocalInt(oArea, "al_debug") > 0)
    {
        int bChanged = FALSE;
        string sDelta = "";

        if (nNpcCount != GetLocalInt(oArea, "al_h_dbg_prev_npc_count"))
        {
            bChanged = TRUE;
            sDelta = sDelta + " npc=" + IntToString(nNpcCount);
        }

        if (nTier != GetLocalInt(oArea, "al_h_dbg_prev_tier"))
        {
            bChanged = TRUE;
            sDelta = sDelta + " tier=" + IntToString(nTier);
        }

        if (nSlot != GetLocalInt(oArea, "al_h_dbg_prev_slot"))
        {
            bChanged = TRUE;
            sDelta = sDelta + " slot=" + IntToString(nSlot);
        }

        if (nRegOverflow != GetLocalInt(oArea, "al_h_dbg_prev_reg_overflow"))
        {
            bChanged = TRUE;
            sDelta = sDelta + " reg_overflow=" + IntToString(nRegOverflow);
        }

        if (nRouteOverflow != GetLocalInt(oArea, "al_h_dbg_prev_route_overflow"))
        {
            bChanged = TRUE;
            sDelta = sDelta + " route_overflow=" + IntToString(nRouteOverflow);
        }

        if (nRecentResync != GetLocalInt(oArea, "al_h_dbg_prev_recent_resync"))
        {
            bChanged = TRUE;
            sDelta = sDelta + " recent_resync=" + IntToString(nRecentResync)
                + "/" + IntToString(AL_HEALTH_RESYNC_WINDOW_TICKS);
        }

        if (bChanged)
        {
            WriteTimestampedLogEntry(
                "[AL][AreaHealthDelta] area=" + GetTag(oArea)
                + " sync_tick=" + IntToString(nSyncTick)
                + sDelta
            );
        }
    }

    SetLocalInt(oArea, "al_h_dbg_prev_npc_count", nNpcCount);
    SetLocalInt(oArea, "al_h_dbg_prev_tier", nTier);
    SetLocalInt(oArea, "al_h_dbg_prev_slot", nSlot);
    SetLocalInt(oArea, "al_h_dbg_prev_reg_overflow", nRegOverflow);
    SetLocalInt(oArea, "al_h_dbg_prev_route_overflow", nRouteOverflow);
    SetLocalInt(oArea, "al_h_dbg_prev_recent_resync", nRecentResync);
}

void AL_ScheduleAreaTick(object oArea, int nToken)
{
    DelayCommand(AL_AREA_TICK_SEC, AL_RunScheduledAreaTick(oArea, nToken));
}

void AL_AreaActivate(object oArea)
{
    int nTier = AL_ResolveAreaTier(oArea);
    AL_AreaSetTier(oArea, nTier);
}

void AL_AreaDeactivate(object oArea)
{
    AL_AreaSetTier(oArea, AL_SIM_TIER_FREEZE);
}

void AL_AreaTick(object oArea, int nToken)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    // Единый контракт: периодический тик выполняется только из внутреннего DelayCommand-scheduler.
    if (GetLocalInt(oArea, AL_TICK_SCHED_MARKER_LOCAL) != TRUE)
    {
        return;
    }

    if (GetLocalInt(oArea, "al_tick_token") != nToken)
    {
        return;
    }

    int nTier = AL_ResolveAreaTier(oArea);
    AL_AreaSetTier(oArea, nTier);
    if (nTier == AL_SIM_TIER_FREEZE)
    {
        AL_UpdateAreaHealthSnapshot(oArea);
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick") + 1;
    SetLocalInt(oArea, "al_sync_tick", nSyncTick);

    if (nTier == AL_SIM_TIER_HOT)
    {
        AL_MarkAreaWarm(oArea);
        AL_RefreshLinkedAreasWarmth(oArea);
    }

    if (nTier == AL_SIM_TIER_HOT)
    {
        int nSlotOld = GetLocalInt(oArea, "al_slot");
        int nSlotNew = AL_ComputeAreaSlot();

        if (nSlotNew != nSlotOld)
        {
            SetLocalInt(oArea, "al_slot", nSlotNew);
            int nEvent = AL_EventFromSlot(nSlotNew);
            if (nEvent >= 0)
            {
                AL_DispatchEventToAreaRegistry(oArea, nEvent);
            }
        }
    }
    else
    {
        if ((nSyncTick % AL_WARM_MAINTENANCE_PERIOD) == 0 && GetLocalInt(oArea, "al_reg_dirty") == TRUE)
        {
            int nLastCompactTick = GetLocalInt(oArea, "al_reg_compact_tick");
            if (nLastCompactTick <= 0 || (nSyncTick - nLastCompactTick) >= AL_WARM_COMPACT_MIN_SYNC_TICKS)
            {
                AL_RegistryCompact(oArea);
            }
        }
    }

    AL_UpdateAreaHealthSnapshot(oArea);

    AL_ScheduleAreaTick(oArea, nToken);
}

void AL_DecrementAreaPlayerCount(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nPlayers = GetLocalInt(oArea, "al_player_count") - 1;
    if (nPlayers < 0)
    {
        nPlayers = 0;
    }

    SetLocalInt(oArea, "al_player_count", nPlayers);

    if (nPlayers == 0)
    {
        AL_MarkAreaWarm(oArea);
    }

    AL_AreaActivate(oArea);
}

void AL_OnAreaEnter(object oArea, object oEnter)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oEnter) || !GetIsPC(oEnter))
    {
        return;
    }

    object oPrevArea = GetLocalObject(oEnter, AL_COUNTED_AREA_LOCAL);
    if (GetIsObjectValid(oPrevArea) && oPrevArea == oArea)
    {
        return;
    }

    if (GetIsObjectValid(oPrevArea) && oPrevArea != oArea)
    {
        AL_DecrementAreaPlayerCount(oPrevArea);
    }

    int nPlayers = GetLocalInt(oArea, "al_player_count") + 1;
    SetLocalInt(oArea, "al_player_count", nPlayers);
    SetLocalObject(oEnter, AL_COUNTED_AREA_LOCAL, oArea);

    AL_AreaActivate(oArea);
    AL_MarkAreaWarm(oArea);
    AL_RefreshLinkedAreasWarmth(oArea);
}

void AL_OnAreaExit(object oArea, object oExit)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oExit) || !GetIsPC(oExit))
    {
        return;
    }

    object oCountedArea = GetLocalObject(oExit, AL_COUNTED_AREA_LOCAL);
    if (!GetIsObjectValid(oCountedArea))
    {
        return;
    }

    if (oCountedArea != oArea)
    {
        // Enter/exit callbacks can be reordered for area transitions, so this exit may
        // arrive for an area that is no longer the actor's counted area. Clearing the
        // local here risks dropping the new counted area and desynchronizing counts.
        return;
    }

    DeleteLocalObject(oExit, AL_COUNTED_AREA_LOCAL);
    AL_DecrementAreaPlayerCount(oArea);
}

void AL_OnModuleLeave(object oPC)
{
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC))
    {
        return;
    }

    object oArea = GetLocalObject(oPC, AL_COUNTED_AREA_LOCAL);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    AL_OnAreaExit(oArea, oPC);
}
