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
const string AL_LOOKUP_INVALIDATE_REASON_ALL = "all";
const string AL_LOOKUP_INVALIDATE_REASON_ROUTE = "route";
const string AL_COUNTED_AREA_LOCAL = "al_counted_area";
const string AL_TICK_SCHED_MARKER_LOCAL = "al_tick_from_scheduler";

#include "al_lookup_cache_inc"
#include "al_health_inc"

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
    AL_LookupSoftInvalidateAreaCache(oArea, AL_LOOKUP_INVALIDATE_REASON_ALL, "");

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

string AL_DispatchCycleEventTickKey(int nEvent)
{
    return "al_dispatch_cycle_tick_event_" + IntToString(nEvent);
}

string AL_DispatchCycleEventIdKey(int nEvent)
{
    return "al_dispatch_cycle_id_event_" + IntToString(nEvent);
}

int AL_ResolveDispatchCycleId(object oArea, int nEvent)
{
    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    string sTickKey = AL_DispatchCycleEventTickKey(nEvent);
    string sIdKey = AL_DispatchCycleEventIdKey(nEvent);
    int nCycleId = GetLocalInt(oArea, sIdKey);

    if (nCycleId > 0 && GetLocalInt(oArea, sTickKey) == nSyncTick)
    {
        return nCycleId;
    }

    nCycleId = GetLocalInt(oArea, "al_dispatch_cycle_id") + 1;
    SetLocalInt(oArea, "al_dispatch_cycle_id", nCycleId);
    SetLocalInt(oArea, sTickKey, nSyncTick);
    SetLocalInt(oArea, sIdKey, nCycleId);
    return nCycleId;
}

int AL_CoalesceQueuedNormalDispatchForCurrentTick(object oArea, int nEvent, int nCycleId)
{
    if (AL_DispatchPriorityFromEvent(nEvent) != AL_DISPATCH_PRIORITY_NORMAL)
    {
        return FALSE;
    }

    if (GetLocalInt(oArea, "al_dispatch_active") > 0
        && GetLocalInt(oArea, "al_dispatch_event") == nEvent
        && GetLocalInt(oArea, "al_dispatch_cycle_id_active") == nCycleId)
    {
        return TRUE;
    }

    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int nCapacity = AL_GetDispatchQueueCapacity(oArea);
    int i = 0;
    while (i < nLen)
    {
        int nIdx = (nHead + i) % nCapacity;
        if (GetLocalInt(oArea, AL_DispatchQueueKey("prio", nIdx)) == AL_DISPATCH_PRIORITY_NORMAL
            && GetLocalInt(oArea, AL_DispatchQueueKey("event", nIdx)) == nEvent
            && GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nIdx)) == nCycleId)
        {
            SetLocalInt(oArea, AL_DispatchPendingKey(nCycleId), 1);
            SetLocalInt(oArea, AL_DispatchPendingMemberKey(nCycleId), 1);
            AL_TrackDispatchPendingCycleId(oArea, nCycleId);
            return TRUE;
        }

        i = i + 1;
    }

    return FALSE;
}

void AL_TryRelieveDispatchBackpressure(object oArea)
{
    if (GetLocalInt(oArea, "al_dispatch_bp_active") <= 0)
    {
        return;
    }

    if (GetLocalInt(oArea, "al_dispatch_q_len") >= AL_GetDispatchQueueCapacity(oArea))
    {
        return;
    }

    int nEvent = GetLocalInt(oArea, "al_dispatch_bp_event");
    SetLocalInt(oArea, "al_dispatch_bp_active", 0);
    DeleteLocalInt(oArea, "al_dispatch_bp_event");
    SetLocalInt(oArea, "al_dispatch_backpressure_relief", GetLocalInt(oArea, "al_dispatch_backpressure_relief") + 1);
    AL_StartBatchedDispatch(oArea, nEvent);
}

void AL_DequeueBatchedDispatch(object oArea)
{
    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    if (nLen <= 0)
    {
        return;
    }

    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int nCycleId = GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nHead));
    DeleteLocalInt(oArea, AL_DispatchQueueKey("event", nHead));
    DeleteLocalInt(oArea, AL_DispatchQueueKey("prio", nHead));
    DeleteLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nHead));
    AL_ClearDispatchPendingCycleId(oArea, nCycleId);

    SetLocalInt(oArea, "al_dispatch_q_head", (nHead + 1) % AL_GetDispatchQueueCapacity(oArea));
    SetLocalInt(oArea, "al_dispatch_q_len", nLen - 1);
    AL_UpdateDispatchQueueDepthFast(oArea);
}

int AL_PickDispatchQueueIndex(object oArea)
{
    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int nCapacity = AL_GetDispatchQueueCapacity(oArea);
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
        int nIdx = (nHead + i) % nCapacity;
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

    AL_TryRelieveDispatchBackpressure(oArea);

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
        int nHeadCycleId = GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nHead));

        SetLocalInt(oArea, AL_DispatchQueueKey("event", nHead), GetLocalInt(oArea, AL_DispatchQueueKey("event", nPickIdx)));
        SetLocalInt(oArea, AL_DispatchQueueKey("prio", nHead), GetLocalInt(oArea, AL_DispatchQueueKey("prio", nPickIdx)));
        SetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nHead), GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nPickIdx)));

        SetLocalInt(oArea, AL_DispatchQueueKey("event", nPickIdx), nHeadEvent);
        SetLocalInt(oArea, AL_DispatchQueueKey("prio", nPickIdx), nHeadPrio);
        SetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nPickIdx), nHeadCycleId);
    }

    int nEvent = GetLocalInt(oArea, AL_DispatchQueueKey("event", nHead));
    int nCycleId = GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nHead));
    int nPriority = GetLocalInt(oArea, AL_DispatchQueueKey("prio", nHead));

    AL_DequeueBatchedDispatch(oArea);

    int nDispatchCycle = GetLocalInt(oArea, "al_dispatch_cycle") + 1;
    SetLocalInt(oArea, "al_dispatch_cycle", nDispatchCycle);
    SetLocalInt(oArea, "al_dispatch_cursor", 0);
    SetLocalInt(oArea, "al_dispatch_event", nEvent);
    SetLocalInt(oArea, "al_dispatch_active", 1);
    SetLocalInt(oArea, "al_dispatch_cycle_id_active", nCycleId);

    if (nPriority == AL_DISPATCH_PRIORITY_CRITICAL)
    {
        SetLocalInt(oArea, "al_dispatch_critical_streak", GetLocalInt(oArea, "al_dispatch_critical_streak") + 1);
    }
    else
    {
        SetLocalInt(oArea, "al_dispatch_critical_streak", 0);
    }

    AL_UpdateDispatchQueueDepthFast(oArea);
    AL_RunBatchedDispatch(oArea);
}

void AL_StartBatchedDispatch(object oArea, int nEvent)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nCycleTick = GetLocalInt(oArea, "al_sync_tick");
    int nCycleId = AL_ResolveDispatchCycleId(oArea, nEvent);
    string sLegacyCycleKey = IntToString(nEvent) + ":" + IntToString(nCycleTick);
    SetLocalInt(oArea, "al_dispatch_dedupe_checks", GetLocalInt(oArea, "al_dispatch_dedupe_checks") + 1);

    if (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalInt(oArea, "al_dispatch_event") == nEvent
        && GetLocalInt(oArea, "al_dispatch_cycle_id_active") == nCycleId)
    {
        SetLocalInt(oArea, "al_dispatch_dedupe_hits", GetLocalInt(oArea, "al_dispatch_dedupe_hits") + 1);
        AL_UpdateDispatchQueueDepthFast(oArea);
        return;
    }

    if (GetLocalInt(oArea, AL_DispatchPendingMemberKey(nCycleId)) > 0
        || (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalInt(oArea, "al_dispatch_cycle_id_active") == nCycleId))
    {
        SetLocalInt(oArea, "al_dispatch_dedupe_hits", GetLocalInt(oArea, "al_dispatch_dedupe_hits") + 1);
        AL_UpdateDispatchQueueDepthFast(oArea);
        return;
    }

    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int nCapacity = AL_GetDispatchQueueCapacity(oArea);

    if (nLen >= nCapacity)
    {
        if (AL_CoalesceQueuedNormalDispatchForCurrentTick(oArea, nEvent, nCycleId))
        {
            SetLocalInt(oArea, "al_dispatch_dedupe_hits", GetLocalInt(oArea, "al_dispatch_dedupe_hits") + 1);
            SetLocalInt(oArea, "al_dispatch_q_coalesce_full_hits", GetLocalInt(oArea, "al_dispatch_q_coalesce_full_hits") + 1);
            AL_UpdateDispatchQueueDepthFast(oArea);
            return;
        }

        SetLocalInt(oArea, "al_dispatch_q_overflow", GetLocalInt(oArea, "al_dispatch_q_overflow") + 1);
        if (GetLocalInt(oArea, "al_dispatch_bp_active") > 0 && GetLocalInt(oArea, "al_dispatch_bp_event") != nEvent)
        {
            SetLocalInt(oArea, "al_dispatch_backpressure_shed", GetLocalInt(oArea, "al_dispatch_backpressure_shed") + 1);
        }
        else
        {
            SetLocalInt(oArea, "al_dispatch_bp_active", 1);
            SetLocalInt(oArea, "al_dispatch_bp_event", nEvent);
        }

        SetLocalInt(oArea, "al_dispatch_backpressure_count", GetLocalInt(oArea, "al_dispatch_backpressure_count") + 1);
        AL_PruneDispatchPendingIndex(oArea);
        return;
    }

    int nTail = (nHead + nLen) % nCapacity;
    SetLocalInt(oArea, AL_DispatchQueueKey("event", nTail), nEvent);
    SetLocalInt(oArea, AL_DispatchQueueKey("prio", nTail), AL_DispatchPriorityFromEvent(nEvent));
    SetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nTail), nCycleId);
    SetLocalInt(oArea, "al_dispatch_q_len", nLen + 1);

    SetLocalInt(oArea, AL_DispatchPendingKey(nCycleId), 1);
    SetLocalInt(oArea, AL_DispatchPendingMemberKey(nCycleId), 1);
    AL_TrackDispatchPendingCycleId(oArea, nCycleId);

    if (GetLocalInt(oArea, "al_debug") > 0)
    {
        WriteTimestampedLogEntry(
            "[AL][DispatchCycleTransition] area=" + GetTag(oArea)
            + " event=" + IntToString(nEvent)
            + " cycle_id=" + IntToString(nCycleId)
            + " legacy_cycle_key='" + sLegacyCycleKey + "'"
        );
    }
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
    int bFoundInvalid = FALSE;

    SetLocalInt(oArea, "al_dispatch_ticks", GetLocalInt(oArea, "al_dispatch_ticks") + 1);

    while (nCursor < nCount && nProcessed < AL_DISPATCH_BATCH_SIZE)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(nCursor));
        int bInvalid = !AL_IsRuntimeNpc(oNpc) || (GetArea(oNpc) != oArea);
        if (bInvalid)
        {
            bFoundInvalid = TRUE;
        }
        else if (GetLocalInt(oNpc, "al_dispatch_seen_cycle") != nCycleId)
        {
            SetLocalInt(oNpc, "al_dispatch_seen_cycle", nCycleId);
            SignalEvent(oNpc, EventUserDefined(nEvent));
            nProcessed = nProcessed + 1;
        }

        nCursor = nCursor + 1;
    }

    if (bFoundInvalid)
    {
        SetLocalInt(oArea, "al_reg_dirty", TRUE);
        SetLocalInt(oArea, "al_dispatch_found_invalid", TRUE);
    }

    SetLocalInt(oArea, "al_dispatch_cursor", nCursor);
    if (nCursor >= nCount)
    {
        int bCycleFoundInvalid = GetLocalInt(oArea, "al_dispatch_found_invalid") == TRUE;
        DeleteLocalInt(oArea, "al_dispatch_found_invalid");

        if (bCycleFoundInvalid && AL_ShouldCompactRegistry(oArea, TRUE))
        {
            AL_RegistryCompact(oArea);
        }

        SetLocalInt(oArea, "al_dispatch_active", 0);
        AL_ClearDispatchPendingCycleId(oArea, GetLocalInt(oArea, "al_dispatch_cycle_id_active"));
        DeleteLocalInt(oArea, "al_dispatch_cycle_id_active");
        AL_PruneDispatchPendingIndex(oArea);
        AL_ActivateQueuedDispatch(oArea);
        return;
    }

    DelayCommand(0.0, AL_RunBatchedDispatch(oArea));
}

void AL_DispatchEventToAreaRegistry(object oArea, int nEvent)
{
    if (AL_ShouldCompactRegistry(oArea, FALSE))
    {
        AL_RegistryCompact(oArea);
    }

    AL_StartBatchedDispatch(oArea, nEvent);
}

void AL_AreaTick(object oArea, int nToken);


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
    AL_TryRelieveDispatchBackpressure(oArea);
    AL_MaybeUpdateDispatchQueueMetricsFull(oArea, FALSE);

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
