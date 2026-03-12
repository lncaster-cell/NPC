// Ambient Life dispatch queue runtime helpers extracted from al_area_inc.

#include "al_events_inc"

const int AL_DISPATCH_QUEUE_CAPACITY = 16;
const int AL_DISPATCH_PRIORITY_NORMAL = 0;
const int AL_DISPATCH_PRIORITY_CRITICAL = 1;
const int AL_DISPATCH_CRITICAL_BURST_QUOTA = 3;

string AL_DispatchQueueKey(string sField, int nIdx)
{
    return "al_dispatch_q_" + sField + "_" + IntToString(nIdx);
}

string AL_DispatchPendingKey(string sCycleKey)
{
    return "al_dispatch_pending_" + sCycleKey;
}

void AL_TrackDispatchPendingKey(object oArea, string sCycleKey)
{
    int nTracked = GetLocalInt(oArea, "al_dispatch_pending_track_count");
    int i = 0;
    while (i < nTracked)
    {
        if (GetLocalString(oArea, "al_dispatch_pending_track_" + IntToString(i)) == sCycleKey)
        {
            return;
        }
        i = i + 1;
    }

    SetLocalString(oArea, "al_dispatch_pending_track_" + IntToString(nTracked), sCycleKey);
    SetLocalInt(oArea, "al_dispatch_pending_track_count", nTracked + 1);
}

void AL_ClearDispatchPendingKey(object oArea, string sCycleKey)
{
    if (sCycleKey == "")
    {
        return;
    }

    DeleteLocalInt(oArea, AL_DispatchPendingKey(sCycleKey));
}

int AL_IsDispatchCycleReferenced(object oArea, string sCycleKey)
{
    if (sCycleKey == "")
    {
        return FALSE;
    }

    if (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalString(oArea, "al_dispatch_cycle_key") == sCycleKey)
    {
        return TRUE;
    }

    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int i = 0;
    while (i < nLen)
    {
        int nIdx = (nHead + i) % AL_DISPATCH_QUEUE_CAPACITY;
        if (GetLocalString(oArea, AL_DispatchQueueKey("cycle", nIdx)) == sCycleKey)
        {
            return TRUE;
        }
        i = i + 1;
    }

    return FALSE;
}

void AL_PruneDispatchPendingIndex(object oArea)
{
    int nTracked = GetLocalInt(oArea, "al_dispatch_pending_track_count");
    if (nTracked <= 0)
    {
        return;
    }

    int nWrite = 0;
    int i = 0;
    while (i < nTracked)
    {
        string sCycleKey = GetLocalString(oArea, "al_dispatch_pending_track_" + IntToString(i));
        if (sCycleKey != "" && (GetLocalInt(oArea, AL_DispatchPendingKey(sCycleKey)) > 0 || AL_IsDispatchCycleReferenced(oArea, sCycleKey)))
        {
            if (nWrite != i)
            {
                SetLocalString(oArea, "al_dispatch_pending_track_" + IntToString(nWrite), sCycleKey);
            }
            nWrite = nWrite + 1;
        }
        else
        {
            AL_ClearDispatchPendingKey(oArea, sCycleKey);
        }

        i = i + 1;
    }

    while (nWrite < nTracked)
    {
        DeleteLocalString(oArea, "al_dispatch_pending_track_" + IntToString(nWrite));
        nWrite = nWrite + 1;
    }

    SetLocalInt(oArea, "al_dispatch_pending_track_count", nWrite);
}

void AL_ResetDispatchPendingIndex(object oArea)
{
    int nTracked = GetLocalInt(oArea, "al_dispatch_pending_track_count");
    int i = 0;
    while (i < nTracked)
    {
        string sCycleKey = GetLocalString(oArea, "al_dispatch_pending_track_" + IntToString(i));
        AL_ClearDispatchPendingKey(oArea, sCycleKey);
        DeleteLocalString(oArea, "al_dispatch_pending_track_" + IntToString(i));
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

int AL_HasPendingPriority(object oArea, int nPriority)
{
    int nLen = GetLocalInt(oArea, "al_dispatch_q_len");
    int nHead = GetLocalInt(oArea, "al_dispatch_q_head");
    int i = 0;

    while (i < nLen)
    {
        int nIdx = (nHead + i) % AL_DISPATCH_QUEUE_CAPACITY;
        if (GetLocalInt(oArea, AL_DispatchQueueKey("prio", nIdx)) == nPriority)
        {
            return TRUE;
        }
        i = i + 1;
    }

    return FALSE;
}

void AL_UpdateDispatchQueueMetrics(object oArea)
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

    int nDedupeChecks = GetLocalInt(oArea, "al_dispatch_dedupe_checks");
    int nDedupeHits = GetLocalInt(oArea, "al_dispatch_dedupe_hits");
    int nDedupePct = 0;
    if (nDedupeChecks > 0)
    {
        nDedupePct = (nDedupeHits * 100) / nDedupeChecks;
    }

    SetLocalInt(oArea, "al_dispatch_dedupe_hit_rate_pct", nDedupePct);
}

void AL_OnDispatchWorkQueued(object oArea)
{
    if (GetLocalInt(oArea, "al_dispatch_drain_started") <= 0)
    {
        SetLocalInt(oArea, "al_dispatch_drain_started", 1);
        SetLocalInt(oArea, "al_dispatch_drain_tick_start", GetLocalInt(oArea, "al_dispatch_ticks") + 1);
    }

    AL_UpdateDispatchQueueMetrics(oArea);
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
    AL_UpdateDispatchQueueMetrics(oArea);
}
