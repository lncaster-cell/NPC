// Ambient Life dispatch queue runtime helpers extracted from al_area_inc.

#include "al_events_inc"

const int AL_DISPATCH_QUEUE_CAPACITY_DEFAULT = 16;
const int AL_DISPATCH_QUEUE_CAPACITY_MIN = 4;
const int AL_DISPATCH_QUEUE_CAPACITY_MAX = 64;
const int AL_DISPATCH_PRIORITY_NORMAL = 0;
const int AL_DISPATCH_PRIORITY_CRITICAL = 1;
const int AL_DISPATCH_CRITICAL_BURST_QUOTA = 3;
const int AL_DISPATCH_METRICS_FULL_INTERVAL_TICKS = 6;
const int AL_DISPATCH_TIER_WARM = 1;
const int AL_DISPATCH_DRAIN_BUDGET_NORMAL_BASE = 8;
const int AL_DISPATCH_DRAIN_BUDGET_CRITICAL_BASE = 12;
const int AL_DISPATCH_DRAIN_BUDGET_BACKLOG_THRESHOLD = 6;
const int AL_DISPATCH_DRAIN_BUDGET_BACKLOG_BOOST = 4;
const int AL_DISPATCH_DRAIN_BUDGET_WARM_SOFT_CAP = 5;

string AL_DispatchQueueKey(string sField, int nIdx)
{
    return "al_dispatch_q_" + sField + "_" + IntToString(nIdx);
}

int AL_GetDispatchQueueCapacity(object oArea)
{
    int nCapacity = GetLocalInt(oArea, "al_dispatch_q_capacity");
    if (nCapacity <= 0)
    {
        nCapacity = AL_DISPATCH_QUEUE_CAPACITY_DEFAULT;
    }

    if (nCapacity < AL_DISPATCH_QUEUE_CAPACITY_MIN)
    {
        nCapacity = AL_DISPATCH_QUEUE_CAPACITY_MIN;
    }
    else if (nCapacity > AL_DISPATCH_QUEUE_CAPACITY_MAX)
    {
        nCapacity = AL_DISPATCH_QUEUE_CAPACITY_MAX;
    }

    return nCapacity;
}

string AL_DispatchPendingKey(int nCycleId)
{
    return "al_dispatch_pending_" + IntToString(nCycleId);
}

string AL_DispatchPendingMemberKey(int nCycleId)
{
    return "al_dispatch_pending_member_" + IntToString(nCycleId);
}

string AL_DispatchPendingTrackMarkKey(int nCycleId)
{
    return "al_dispatch_pending_track_mark_" + IntToString(nCycleId);
}

string AL_DispatchCycleRefIndexMarkKey(int nCycleId)
{
    return "al_dispatch_ref_idx_mark_" + IntToString(nCycleId);
}

string AL_DispatchCycleRefIndexEntryKey(int nIdx)
{
    return "al_dispatch_ref_idx_entry_" + IntToString(nIdx);
}

void AL_TrackDispatchPendingCycleId(object oArea, int nCycleId)
{
    if (nCycleId <= 0)
    {
        return;
    }

    if (GetLocalInt(oArea, AL_DispatchPendingTrackMarkKey(nCycleId)) > 0)
    {
        return;
    }

    int nTracked = GetLocalInt(oArea, "al_dispatch_pending_track_count");
    SetLocalInt(oArea, "al_dispatch_pending_track_" + IntToString(nTracked), nCycleId);
    SetLocalInt(oArea, AL_DispatchPendingTrackMarkKey(nCycleId), 1);
    SetLocalInt(oArea, "al_dispatch_pending_track_count", nTracked + 1);
}

void AL_ClearDispatchPendingCycleId(object oArea, int nCycleId)
{
    if (nCycleId <= 0)
    {
        return;
    }

    DeleteLocalInt(oArea, AL_DispatchPendingKey(nCycleId));
}

int AL_IsDispatchCycleReferenced(object oArea, int nCycleId)
{
    if (nCycleId <= 0)
    {
        return FALSE;
    }

    if (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalInt(oArea, "al_dispatch_cycle_id_active") == nCycleId)
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
        if (GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nIdx)) == nCycleId)
        {
            return TRUE;
        }
        i = i + 1;
    }

    return FALSE;
}

void AL_MarkDispatchCycleReference(object oArea, int nCycleId)
{
    if (nCycleId <= 0)
    {
        return;
    }

    if (GetLocalInt(oArea, AL_DispatchCycleRefIndexMarkKey(nCycleId)) > 0)
    {
        return;
    }

    int nCount = GetLocalInt(oArea, "al_dispatch_ref_idx_count");
    SetLocalInt(oArea, AL_DispatchCycleRefIndexEntryKey(nCount), nCycleId);
    SetLocalInt(oArea, AL_DispatchCycleRefIndexMarkKey(nCycleId), 1);
    SetLocalInt(oArea, "al_dispatch_ref_idx_count", nCount + 1);
}

void AL_ClearDispatchCycleReferenceIndex(object oArea)
{
    int nCount = GetLocalInt(oArea, "al_dispatch_ref_idx_count");
    int i = 0;
    while (i < nCount)
    {
        int nCycleId = GetLocalInt(oArea, AL_DispatchCycleRefIndexEntryKey(i));
        DeleteLocalInt(oArea, AL_DispatchCycleRefIndexMarkKey(nCycleId));
        DeleteLocalInt(oArea, AL_DispatchCycleRefIndexEntryKey(i));
        i = i + 1;
    }

    SetLocalInt(oArea, "al_dispatch_ref_idx_count", 0);
}

void AL_BuildDispatchCycleReferenceIndex(object oArea)
{
    AL_ClearDispatchCycleReferenceIndex(oArea);

    if (GetLocalInt(oArea, "al_dispatch_active") > 0)
    {
        AL_MarkDispatchCycleReference(oArea, GetLocalInt(oArea, "al_dispatch_cycle_id_active"));
    }

    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int i = 0;
    while (i < nLen)
    {
        int nIdx = (nHead + i) % AL_GetDispatchQueueCapacity(oArea);
        AL_MarkDispatchCycleReference(oArea, GetLocalInt(oArea, AL_DispatchQueueKey("cycle_id", nIdx)));
        i = i + 1;
    }
}

void AL_PruneDispatchPendingIndex(object oArea)
{
    int nTracked = GetLocalInt(oArea, "al_dispatch_pending_track_count");
    if (nTracked <= 0)
    {
        return;
    }

    AL_BuildDispatchCycleReferenceIndex(oArea);

    int nWrite = 0;
    int i = 0;
    while (i < nTracked)
    {
        int nCycleId = GetLocalInt(oArea, "al_dispatch_pending_track_" + IntToString(i));
        int bKeep = FALSE;
        if (nCycleId > 0)
        {
            int bPending = GetLocalInt(oArea, AL_DispatchPendingKey(nCycleId)) > 0;
            if (bPending)
            {
                bKeep = TRUE;
            }
            else
            {
                bKeep = GetLocalInt(oArea, AL_DispatchCycleRefIndexMarkKey(nCycleId)) > 0;
            }
        }

        if (bKeep)
        {
            if (nWrite != i)
            {
                SetLocalInt(oArea, "al_dispatch_pending_track_" + IntToString(nWrite), nCycleId);
            }
            nWrite = nWrite + 1;
        }
        else
        {
            AL_ClearDispatchPendingCycleId(oArea, nCycleId);
            DeleteLocalInt(oArea, AL_DispatchPendingMemberKey(nCycleId));
            DeleteLocalInt(oArea, AL_DispatchPendingTrackMarkKey(nCycleId));
        }

        i = i + 1;
    }

    while (nWrite < nTracked)
    {
        DeleteLocalInt(oArea, "al_dispatch_pending_track_" + IntToString(nWrite));
        nWrite = nWrite + 1;
    }

    SetLocalInt(oArea, "al_dispatch_pending_track_count", nWrite);
    AL_ClearDispatchCycleReferenceIndex(oArea);
}

void AL_ResetDispatchPendingIndex(object oArea)
{
    int nTracked = GetLocalInt(oArea, "al_dispatch_pending_track_count");
    int i = 0;
    while (i < nTracked)
    {
        int nCycleId = GetLocalInt(oArea, "al_dispatch_pending_track_" + IntToString(i));
        AL_ClearDispatchPendingCycleId(oArea, nCycleId);
        DeleteLocalInt(oArea, AL_DispatchPendingMemberKey(nCycleId));
        DeleteLocalInt(oArea, AL_DispatchPendingTrackMarkKey(nCycleId));
        DeleteLocalInt(oArea, "al_dispatch_pending_track_" + IntToString(i));
        i = i + 1;
    }

    SetLocalInt(oArea, "al_dispatch_pending_track_count", 0);
}

int AL_DispatchPriorityFromEvent(int nEvent)
{
    if (nEvent == AL_EVENT_ROUTE_REPEAT || nEvent == AL_EVENT_BLOCKED_RESUME)
    {
        return AL_DISPATCH_PRIORITY_CRITICAL;
    }

    return AL_DISPATCH_PRIORITY_NORMAL;
}

void AL_UpdateDispatchQueueDepthFast(object oArea)
{
    int nDepth = GetLocalInt(oArea, "al_dispatch_q_len");
    if (GetLocalInt(oArea, "al_dispatch_active") > 0)
    {
        nDepth = nDepth + 1;
    }

    SetLocalInt(oArea, "al_dispatch_queue_depth", nDepth);

    if (nDepth > GetLocalInt(oArea, "al_dispatch_max_backlog"))
    {
        SetLocalInt(oArea, "al_dispatch_max_backlog", nDepth);
        // Backward-compatible metric key used by existing observability tooling.
        SetLocalInt(oArea, "al_dispatch_queue_len_max", nDepth);
    }
}

void AL_UpdateDispatchQueueMetricsFull(object oArea)
{
    AL_UpdateDispatchQueueDepthFast(oArea);

    int nDedupeChecks = GetLocalInt(oArea, "al_dispatch_dedupe_checks");
    int nDedupeHits = GetLocalInt(oArea, "al_dispatch_dedupe_hits");
    int nDedupePct = 0;
    if (nDedupeChecks > 0)
    {
        nDedupePct = (nDedupeHits * 100) / nDedupeChecks;
    }

    SetLocalInt(oArea, "al_dispatch_dedupe_hit_rate_pct", nDedupePct);
    SetLocalInt(oArea, "al_dispatch_metrics_full_sync_tick", GetLocalInt(oArea, "al_sync_tick"));
}

void AL_MaybeUpdateDispatchQueueMetricsFull(object oArea, int bForce)
{
    if (bForce)
    {
        AL_UpdateDispatchQueueMetricsFull(oArea);
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nLastSyncTick = GetLocalInt(oArea, "al_dispatch_metrics_full_sync_tick");
    if (nLastSyncTick <= 0 || nSyncTick <= 0 || (nSyncTick - nLastSyncTick) >= AL_DISPATCH_METRICS_FULL_INTERVAL_TICKS)
    {
        AL_UpdateDispatchQueueMetricsFull(oArea);
    }
}

void AL_OnDispatchWorkQueued(object oArea)
{
    if (GetLocalInt(oArea, "al_dispatch_drain_started") <= 0)
    {
        SetLocalInt(oArea, "al_dispatch_drain_started", 1);
        SetLocalInt(oArea, "al_dispatch_drain_tick_start", GetLocalInt(oArea, "al_dispatch_ticks") + 1);
    }

    AL_UpdateDispatchQueueDepthFast(oArea);
    AL_MaybeUpdateDispatchQueueMetricsFull(oArea, FALSE);
}

void AL_OnDispatchWorkDrained(object oArea)
{
    int nStartTick = GetLocalInt(oArea, "al_dispatch_drain_tick_start");
    if (nStartTick > 0)
    {
        int nTicksToDrain = GetLocalInt(oArea, "al_dispatch_ticks") - nStartTick + 1;
        if (nTicksToDrain < 1)
        {
            nTicksToDrain = 1;
        }

        SetLocalInt(oArea, "al_dispatch_ticks_to_drain", nTicksToDrain);
    }

    SetLocalInt(oArea, "al_dispatch_drain_started", 0);
    SetLocalInt(oArea, "al_dispatch_drain_tick_start", 0);
    AL_UpdateDispatchQueueDepthFast(oArea);
    AL_MaybeUpdateDispatchQueueMetricsFull(oArea, TRUE);
}

int AL_GetDispatchBacklogDepth(object oArea)
{
    int nDepth = GetLocalInt(oArea, "al_dispatch_q_len");
    if (GetLocalInt(oArea, "al_dispatch_active") > 0)
    {
        nDepth = nDepth + 1;
    }

    if (nDepth < 0)
    {
        nDepth = 0;
    }

    return nDepth;
}

int AL_ComputeDispatchDrainBudget(object oArea, int nEvent, int nBacklogDepth)
{
    int nBudget = AL_DISPATCH_DRAIN_BUDGET_NORMAL_BASE;
    if (AL_DispatchPriorityFromEvent(nEvent) == AL_DISPATCH_PRIORITY_CRITICAL)
    {
        nBudget = AL_DISPATCH_DRAIN_BUDGET_CRITICAL_BASE;
    }

    if (nBacklogDepth >= AL_DISPATCH_DRAIN_BUDGET_BACKLOG_THRESHOLD)
    {
        nBudget = nBudget + AL_DISPATCH_DRAIN_BUDGET_BACKLOG_BOOST;
    }

    if (GetLocalInt(oArea, "al_sim_tier") == AL_DISPATCH_TIER_WARM && nBudget > AL_DISPATCH_DRAIN_BUDGET_WARM_SOFT_CAP)
    {
        nBudget = AL_DISPATCH_DRAIN_BUDGET_WARM_SOFT_CAP;
    }

    if (nBudget < 1)
    {
        nBudget = 1;
    }

    return nBudget;
}
