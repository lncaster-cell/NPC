// Ambient Life area health snapshot helpers (extracted from al_area_inc).

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
