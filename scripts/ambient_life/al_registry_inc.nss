// Ambient Life dense registry (Stage B).

const int AL_MAX_NPCS = 100;
const int AL_REG_COMPACT_MIN_SYNC_TICKS = 4;
const int AL_REG_COMPACT_METRICS_WINDOW_TICKS = 100;

string AL_RegKey(int nIdx)
{
    return "al_npc_" + IntToString(nIdx);
}

int AL_FindNPCInRegistry(object oArea, object oNpc)
{
    if (GetLocalObject(oNpc, "al_reg_area") == oArea)
    {
        int nFastIdx = GetLocalInt(oNpc, "al_reg_idx");
        if (nFastIdx >= 0 && GetLocalObject(oArea, AL_RegKey(nFastIdx)) == oNpc)
        {
            return nFastIdx;
        }

        SetLocalInt(oArea, "al_reg_index_miss", GetLocalInt(oArea, "al_reg_index_miss") + 1);
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;

    while (i < nCount)
    {
        if (GetLocalObject(oArea, AL_RegKey(i)) == oNpc)
        {
            return i;
        }
        i = i + 1;
    }

    return -1;
}

int AL_UnregisterNPCFromArea(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int nIdx = AL_FindNPCInRegistry(oArea, oNpc);
    if (nIdx < 0 || nCount <= 0)
    {
        return FALSE;
    }

    int nLastIdx = nCount - 1;
    object oLast = GetLocalObject(oArea, AL_RegKey(nLastIdx));

    if (nIdx != nLastIdx)
    {
        SetLocalObject(oArea, AL_RegKey(nIdx), oLast);
        if (GetIsObjectValid(oLast))
        {
            SetLocalInt(oLast, "al_reg_idx", nIdx);
            SetLocalObject(oLast, "al_reg_area", oArea);
        }
    }

    DeleteLocalObject(oArea, AL_RegKey(nLastIdx));
    SetLocalInt(oArea, "al_npc_count", nLastIdx);

    DeleteLocalObject(oNpc, "al_reg_area");
    DeleteLocalInt(oNpc, "al_reg_idx");
    SetLocalInt(oArea, "al_reg_dirty", TRUE);

    return TRUE;
}

void AL_RegisterNPCInArea(object oNpc, object oArea)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalObject(oNpc, "al_last_area", oArea);

    if (AL_FindNPCInRegistry(oArea, oNpc) >= 0)
    {
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    if (nCount >= AL_MAX_NPCS)
    {
        AL_MarkRegistryOverflow(oArea, oNpc);
        return;
    }

    SetLocalObject(oArea, AL_RegKey(nCount), oNpc);
    SetLocalInt(oArea, "al_npc_count", nCount + 1);
    SetLocalObject(oNpc, "al_reg_area", oArea);
    SetLocalInt(oNpc, "al_reg_idx", nCount);
    SetLocalInt(oArea, "al_reg_dirty", TRUE);
}

void AL_TransferNPCRegistry(object oNpc, object oFromArea, object oToArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oToArea))
    {
        return;
    }

    if (GetIsObjectValid(oFromArea) && oFromArea != oToArea)
    {
        AL_UnregisterNPCFromArea(oNpc, oFromArea);
    }

    AL_RegisterNPCInArea(oNpc, oToArea);
    if (GetIsObjectValid(oToArea))
    {
        SetLocalInt(oToArea, "al_reg_dirty", TRUE);
    }
}

int AL_ShouldCompactRegistry(object oArea, int bFoundInvalid)
{
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_reg_dirty") != TRUE)
    {
        return FALSE;
    }

    if (bFoundInvalid)
    {
        return TRUE;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nLastCompactTick = GetLocalInt(oArea, "al_reg_compact_tick");
    if (nSyncTick <= 0)
    {
        return FALSE;
    }

    return (nSyncTick - nLastCompactTick) >= AL_REG_COMPACT_MIN_SYNC_TICKS;
}

void AL_MarkRegistryOverflow(object oArea, object oNpc)
{
    int nOverflowCount = GetLocalInt(oArea, "al_reg_overflow_count") + 1;
    SetLocalInt(oArea, "al_reg_overflow_count", nOverflowCount);
    SetLocalString(oArea, "al_reg_overflow_last_npc_tag", GetTag(oNpc));

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    if (nSyncTick > 0)
    {
        SetLocalInt(oArea, "al_reg_overflow_sync_tick", nSyncTick);
    }

    // Optional diagnostics: throttled module-log entries in debug mode.
    if (GetLocalInt(oArea, "al_debug") > 0)
    {
        int nLastLogTick = GetLocalInt(oArea, "al_reg_overflow_last_log_tick");
        if (nSyncTick <= 0 || nLastLogTick <= 0 || (nSyncTick - nLastLogTick) >= 50)
        {
            WriteTimestampedLogEntry(
                "[AL][RegistryOverflow] area=" + GetTag(oArea)
                + " npc=" + GetTag(oNpc)
                + " count=" + IntToString(GetLocalInt(oArea, "al_npc_count"))
                + " max=" + IntToString(AL_MAX_NPCS)
                + " overflows=" + IntToString(nOverflowCount)
                + " sync_tick=" + IntToString(nSyncTick)
            );

            if (nSyncTick > 0)
            {
                SetLocalInt(oArea, "al_reg_overflow_last_log_tick", nSyncTick);
            }
        }
    }
}

void AL_RegisterNPC(object oNpc)
{
    object oArea = GetArea(oNpc);
    AL_RegisterNPCInArea(oNpc, oArea);
}

void AL_UnregisterNPC(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetLocalObject(oNpc, "al_last_area");
    if (!GetIsObjectValid(oArea))
    {
        oArea = GetArea(oNpc);
    }

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    AL_UnregisterNPCFromArea(oNpc, oArea);
}

void AL_RegistryCompact(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nWindowStart = GetLocalInt(oArea, "al_reg_compact_window_start_tick");
    if (nSyncTick > 0 && (nWindowStart <= 0 || nSyncTick < nWindowStart || (nSyncTick - nWindowStart) >= AL_REG_COMPACT_METRICS_WINDOW_TICKS))
    {
        SetLocalInt(oArea, "al_reg_compact_window_start_tick", nSyncTick);
        SetLocalInt(oArea, "al_reg_compact_calls_window", 0);
        SetLocalInt(oArea, "al_reg_compact_removed_window", 0);
    }

    SetLocalInt(oArea, "al_reg_compact_calls", GetLocalInt(oArea, "al_reg_compact_calls") + 1);
    SetLocalInt(oArea, "al_reg_compact_calls_window", GetLocalInt(oArea, "al_reg_compact_calls_window") + 1);

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;
    int nRemoved = 0;

    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(i));
        int bInvalid = !AL_IsRuntimeNpc(oNpc) || (GetArea(oNpc) != oArea);

        if (bInvalid)
        {
            if (GetIsObjectValid(oNpc))
            {
                DeleteLocalObject(oNpc, "al_reg_area");
                DeleteLocalInt(oNpc, "al_reg_idx");
            }

            int nLastIdx = nCount - 1;
            object oLast = GetLocalObject(oArea, AL_RegKey(nLastIdx));

            if (i != nLastIdx)
            {
                SetLocalObject(oArea, AL_RegKey(i), oLast);
                if (GetIsObjectValid(oLast))
                {
                    SetLocalInt(oLast, "al_reg_idx", i);
                    SetLocalObject(oLast, "al_reg_area", oArea);
                }
            }

            DeleteLocalObject(oArea, AL_RegKey(nLastIdx));
            nCount = nLastIdx;
            SetLocalInt(oArea, "al_npc_count", nCount);
            nRemoved = nRemoved + 1;
            continue;
        }

        SetLocalObject(oNpc, "al_last_area", oArea);
        SetLocalObject(oNpc, "al_reg_area", oArea);
        SetLocalInt(oNpc, "al_reg_idx", i);
        i = i + 1;
    }

    SetLocalInt(oArea, "al_reg_compact_removed_total", GetLocalInt(oArea, "al_reg_compact_removed_total") + nRemoved);
    SetLocalInt(oArea, "al_reg_compact_removed_window", GetLocalInt(oArea, "al_reg_compact_removed_window") + nRemoved);
    SetLocalInt(oArea, "al_reg_compact_tick", nSyncTick);
    SetLocalInt(oArea, "al_reg_dirty", FALSE);
}
