// Ambient Life dense registry (Stage B).

const int AL_MAX_NPCS_DEFAULT = 100;
const int AL_MAX_NPCS_MIN = 20;
const int AL_MAX_NPCS_MAX = 200;
const int AL_REG_COMPACT_MIN_SYNC_TICKS = 4;
const int AL_REG_COMPACT_METRICS_WINDOW_TICKS = 100;
const int AL_REG_MAINTENANCE_PERIOD_TICKS = 5;
const int AL_REG_MAINTENANCE_MAX_CHECKS_PER_STEP = 6;
const int AL_REG_LINEAR_FALLBACK_MAX_SCANS_PER_TICK = 2;
const int AL_REG_MISS_LOG_WINDOW_TICKS = 20;
const int AL_REG_MISS_LOG_MIN_SAMPLES = 10;
const int AL_REG_MISS_LOG_THRESHOLD_PCT = 25;
const int AL_REG_MISS_LOG_COOLDOWN_TICKS = 50;

int AL_GetEffectiveNpcCap(object oArea)
{
    object oModule = GetModule();
    int nCap = 0;

    if (GetIsObjectValid(oArea))
    {
        nCap = GetLocalInt(oArea, "al_max_npcs");
    }

    if (nCap <= 0 && GetIsObjectValid(oModule))
    {
        nCap = GetLocalInt(oModule, "al_max_npcs");
    }

    if (nCap < AL_MAX_NPCS_MIN || nCap > AL_MAX_NPCS_MAX)
    {
        return AL_MAX_NPCS_DEFAULT;
    }

    return nCap;
}

void AL_SyncRegistryCapDiagnostics(object oArea, int nEffectiveCap)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nPrevCap = GetLocalInt(oArea, "al_reg_cap_effective");
    if (nPrevCap > 0 && nPrevCap != nEffectiveCap)
    {
        SetLocalInt(oArea, "al_reg_overflow_count_at_cap_change", GetLocalInt(oArea, "al_reg_overflow_count"));

        int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
        if (nSyncTick > 0)
        {
            SetLocalInt(oArea, "al_reg_cap_changed_sync_tick", nSyncTick);
        }
    }

    SetLocalInt(oArea, "al_reg_cap_effective", nEffectiveCap);
}

string AL_RegKey(int nIdx)
{
    return "al_npc_" + IntToString(nIdx);
}

string AL_RegStableId(object oNpc)
{
    return GetTag(oNpc) + "#" + ObjectToString(oNpc);
}

string AL_RegReverseKey(string sStableId)
{
    return "al_reg_rev_" + sStableId;
}

int AL_RegReverseGet(object oArea, object oNpc)
{
    int nStored = GetLocalInt(oArea, AL_RegReverseKey(AL_RegStableId(oNpc)));
    if (nStored <= 0)
    {
        return -1;
    }

    return nStored - 1;
}

void AL_RegReverseSet(object oArea, object oNpc, int nIdx)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNpc) || nIdx < 0)
    {
        return;
    }

    SetLocalInt(oArea, AL_RegReverseKey(AL_RegStableId(oNpc)), nIdx + 1);
}

void AL_RegReverseDelete(object oArea, object oNpc)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalInt(oArea, AL_RegReverseKey(AL_RegStableId(oNpc)));
}

int AL_RegValidateCandidateIdx(object oArea, object oNpc, int nCandidateIdx, int nCount)
{
    if (nCandidateIdx < 0 || nCandidateIdx >= nCount)
    {
        return -1;
    }

    if (GetLocalObject(oArea, AL_RegKey(nCandidateIdx)) != oNpc)
    {
        return -1;
    }

    AL_RegReverseSet(oArea, oNpc, nCandidateIdx);
    SetLocalObject(oNpc, "al_reg_area", oArea);
    SetLocalInt(oNpc, "al_reg_idx", nCandidateIdx);
    SetLocalInt(oArea, "al_reg_index_miss_fast_candidate_hit", GetLocalInt(oArea, "al_reg_index_miss_fast_candidate_hit") + 1);
    return nCandidateIdx;
}

int AL_RegTryConsumeLinearFallbackBudget(object oArea)
{
    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nBudgetTick = GetLocalInt(oArea, "al_reg_linear_fallback_tick");
    if (nBudgetTick != nSyncTick)
    {
        SetLocalInt(oArea, "al_reg_linear_fallback_tick", nSyncTick);
        SetLocalInt(oArea, "al_reg_linear_fallback_used", 0);
    }

    int nUsed = GetLocalInt(oArea, "al_reg_linear_fallback_used");
    if (nUsed >= AL_REG_LINEAR_FALLBACK_MAX_SCANS_PER_TICK)
    {
        SetLocalInt(oArea, "al_reg_linear_fallback_deferred", GetLocalInt(oArea, "al_reg_linear_fallback_deferred") + 1);
        SetLocalInt(oArea, "al_reg_linear_fallback_deferred_pending", GetLocalInt(oArea, "al_reg_linear_fallback_deferred_pending") + 1);
        return FALSE;
    }

    SetLocalInt(oArea, "al_reg_linear_fallback_used", nUsed + 1);
    SetLocalInt(oArea, "al_reg_linear_fallback_total", GetLocalInt(oArea, "al_reg_linear_fallback_total") + 1);
    return TRUE;
}

void AL_RegMaybeLogMissRate(object oArea)
{
    if (GetLocalInt(oArea, "al_debug") <= 0)
    {
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nChecks = GetLocalInt(oArea, "al_reg_lookup_window_total");
    int nMisses = GetLocalInt(oArea, "al_reg_lookup_window_miss");

    if (nChecks < AL_REG_MISS_LOG_MIN_SAMPLES)
    {
        return;
    }

    int nMissRatePct = (nMisses * 100) / nChecks;
    if (nMissRatePct < AL_REG_MISS_LOG_THRESHOLD_PCT)
    {
        return;
    }

    int nLastLogTick = GetLocalInt(oArea, "al_reg_miss_rate_last_log_tick");
    if (nSyncTick > 0 && nLastLogTick > 0 && (nSyncTick - nLastLogTick) < AL_REG_MISS_LOG_COOLDOWN_TICKS)
    {
        return;
    }

    WriteTimestampedLogEntry(
        "[AL][RegistryMissRate] area=" + GetTag(oArea)
        + " miss_rate_pct=" + IntToString(nMissRatePct)
        + " misses=" + IntToString(nMisses)
        + " checks=" + IntToString(nChecks)
        + " deferred_linear=" + IntToString(GetLocalInt(oArea, "al_reg_linear_fallback_deferred"))
        + " sync_tick=" + IntToString(nSyncTick)
    );

    if (nSyncTick > 0)
    {
        SetLocalInt(oArea, "al_reg_miss_rate_last_log_tick", nSyncTick);
    }
}

int AL_FindNPCInRegistry(object oArea, object oNpc)
{
    SetLocalInt(oArea, "al_reg_lookup_total", GetLocalInt(oArea, "al_reg_lookup_total") + 1);

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int nLookupWindowStart = GetLocalInt(oArea, "al_reg_lookup_window_start_tick");
    if (nLookupWindowStart <= 0 || nSyncTick <= 0 || nSyncTick < nLookupWindowStart || (nSyncTick - nLookupWindowStart) >= AL_REG_MISS_LOG_WINDOW_TICKS)
    {
        SetLocalInt(oArea, "al_reg_lookup_window_start_tick", nSyncTick);
        SetLocalInt(oArea, "al_reg_lookup_window_total", 0);
        SetLocalInt(oArea, "al_reg_lookup_window_miss", 0);
    }
    SetLocalInt(oArea, "al_reg_lookup_window_total", GetLocalInt(oArea, "al_reg_lookup_window_total") + 1);

    int nReverseIdx = AL_RegReverseGet(oArea, oNpc);
    if (nReverseIdx >= 0)
    {
        if (GetLocalObject(oArea, AL_RegKey(nReverseIdx)) == oNpc)
        {
            SetLocalInt(oArea, "al_reg_reverse_hit", GetLocalInt(oArea, "al_reg_reverse_hit") + 1);
            SetLocalObject(oNpc, "al_reg_area", oArea);
            SetLocalInt(oNpc, "al_reg_idx", nReverseIdx);
            return nReverseIdx;
        }
    }

    SetLocalInt(oArea, "al_reg_reverse_miss", GetLocalInt(oArea, "al_reg_reverse_miss") + 1);
    SetLocalInt(oArea, "al_reg_index_miss", GetLocalInt(oArea, "al_reg_index_miss") + 1);
    SetLocalInt(oArea, "al_reg_lookup_window_miss", GetLocalInt(oArea, "al_reg_lookup_window_miss") + 1);
    AL_RegMaybeLogMissRate(oArea);

    int bReverseMissing = (nReverseIdx < 0);
    if (bReverseMissing)
    {
        SetLocalInt(oArea, "al_reg_index_miss_cold_start", GetLocalInt(oArea, "al_reg_index_miss_cold_start") + 1);
        SetLocalString(oArea, "al_reg_index_miss_last_type", "cold-start");
    }
    else
    {
        SetLocalInt(oArea, "al_reg_index_miss_stale", GetLocalInt(oArea, "al_reg_index_miss_stale") + 1);
        SetLocalString(oArea, "al_reg_index_miss_last_type", "stale");
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");

    int nFastIdx = GetLocalInt(oNpc, "al_reg_idx");
    int nCandidate = AL_RegValidateCandidateIdx(oArea, oNpc, nFastIdx, nCount);
    if (nCandidate >= 0)
    {
        return nCandidate;
    }

    nCandidate = AL_RegValidateCandidateIdx(oArea, oNpc, nFastIdx - 1, nCount);
    if (nCandidate >= 0)
    {
        return nCandidate;
    }

    nCandidate = AL_RegValidateCandidateIdx(oArea, oNpc, nFastIdx + 1, nCount);
    if (nCandidate >= 0)
    {
        return nCandidate;
    }

    if (!AL_RegTryConsumeLinearFallbackBudget(oArea))
    {
        SetLocalString(oArea, "al_reg_index_miss_last_type", "deferred");
        return -1;
    }

    int i = 0;

    while (i < nCount)
    {
        if (GetLocalObject(oArea, AL_RegKey(i)) == oNpc)
        {
            // Miss был отработан fallback-ом: сразу восстанавливаем reverse-index.
            AL_RegReverseSet(oArea, oNpc, i);
            SetLocalObject(oNpc, "al_reg_area", oArea);
            SetLocalInt(oNpc, "al_reg_idx", i);
            return i;
        }
        i = i + 1;
    }

    // Reverse lookup не сошёлся и линейный fallback тоже не нашёл запись.
    SetLocalInt(oArea, "al_reg_index_miss_orphan", GetLocalInt(oArea, "al_reg_index_miss_orphan") + 1);
    SetLocalString(oArea, "al_reg_index_miss_last_type", "orphan");

    return -1;
}

void AL_RegistryMaintenanceStep(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    if (nSyncTick <= 0 || (nSyncTick % AL_REG_MAINTENANCE_PERIOD_TICKS) != 0)
    {
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    if (nCount <= 0)
    {
        SetLocalInt(oArea, "al_reg_maint_cursor", 0);
        return;
    }

    int nCursor = GetLocalInt(oArea, "al_reg_maint_cursor");
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    int nChecked = 0;
    int nFixed = 0;

    while (nChecked < AL_REG_MAINTENANCE_MAX_CHECKS_PER_STEP && nCursor < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(nCursor));
        if (AL_IsRuntimeNpc(oNpc) && GetArea(oNpc) == oArea)
        {
            int nReverseIdx = AL_RegReverseGet(oArea, oNpc);
            if (nReverseIdx != nCursor)
            {
                if (nReverseIdx < 0)
                {
                    SetLocalInt(oArea, "al_reg_maint_fixup_cold_start", GetLocalInt(oArea, "al_reg_maint_fixup_cold_start") + 1);
                    SetLocalInt(oArea, "al_reg_index_miss_cold_start_recovered", GetLocalInt(oArea, "al_reg_index_miss_cold_start_recovered") + 1);
                }
                else
                {
                    SetLocalInt(oArea, "al_reg_maint_fixup_stale", GetLocalInt(oArea, "al_reg_maint_fixup_stale") + 1);
                    SetLocalInt(oArea, "al_reg_index_miss_stale_recovered", GetLocalInt(oArea, "al_reg_index_miss_stale_recovered") + 1);
                }

                AL_RegReverseSet(oArea, oNpc, nCursor);
                nFixed = nFixed + 1;
            }
        }

        nCursor = nCursor + 1;
        nChecked = nChecked + 1;
    }

    if (nCursor >= nCount)
    {
        nCursor = 0;
    }

    SetLocalInt(oArea, "al_reg_maint_cursor", nCursor);
    SetLocalInt(oArea, "al_reg_maint_checks", GetLocalInt(oArea, "al_reg_maint_checks") + nChecked);
    SetLocalInt(oArea, "al_reg_maint_fixups", GetLocalInt(oArea, "al_reg_maint_fixups") + nFixed);
    SetLocalInt(oArea, "al_reg_maint_last_checked", nChecked);
    SetLocalInt(oArea, "al_reg_maint_last_fixed", nFixed);
    SetLocalInt(oArea, "al_reg_maint_last_tick", nSyncTick);

    int nDeferredPending = GetLocalInt(oArea, "al_reg_linear_fallback_deferred_pending");
    if (nDeferredPending > 0)
    {
        int nResolved = nDeferredPending;
        if (nResolved > nFixed)
        {
            nResolved = nFixed;
        }

        if (nResolved > 0)
        {
            SetLocalInt(oArea, "al_reg_linear_fallback_deferred_pending", nDeferredPending - nResolved);
            SetLocalInt(oArea, "al_reg_linear_fallback_deferred_resolved", GetLocalInt(oArea, "al_reg_linear_fallback_deferred_resolved") + nResolved);
        }
    }
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

    AL_RegReverseDelete(oArea, oNpc);

    if (nIdx != nLastIdx)
    {
        SetLocalObject(oArea, AL_RegKey(nIdx), oLast);
        if (GetIsObjectValid(oLast))
        {
            SetLocalInt(oLast, "al_reg_idx", nIdx);
            SetLocalObject(oLast, "al_reg_area", oArea);
            AL_RegReverseSet(oArea, oLast, nIdx);
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

    // Линейный fallback может быть отложен лимитом; не дублируем запись,
    // если NPC уже помечен как принадлежащий этой area.
    if (GetLocalObject(oNpc, "al_reg_area") == oArea)
    {
        return;
    }

    int nCap = AL_GetEffectiveNpcCap(oArea);
    AL_SyncRegistryCapDiagnostics(oArea, nCap);

    int nCount = GetLocalInt(oArea, "al_npc_count");
    if (nCount >= nCap)
    {
        AL_MarkRegistryOverflow(oArea, oNpc);
        return;
    }

    SetLocalObject(oArea, AL_RegKey(nCount), oNpc);
    SetLocalInt(oArea, "al_npc_count", nCount + 1);
    SetLocalObject(oNpc, "al_reg_area", oArea);
    SetLocalInt(oNpc, "al_reg_idx", nCount);
    AL_RegReverseSet(oArea, oNpc, nCount);
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
    int nCap = AL_GetEffectiveNpcCap(oArea);
    AL_SyncRegistryCapDiagnostics(oArea, nCap);

    int nOverflowCount = GetLocalInt(oArea, "al_reg_overflow_count") + 1;
    SetLocalInt(oArea, "al_reg_overflow_count", nOverflowCount);
    SetLocalInt(oArea, "al_reg_overflow_count_cap", nOverflowCount - GetLocalInt(oArea, "al_reg_overflow_count_at_cap_change"));
    SetLocalInt(oArea, "al_reg_overflow_last_cap", nCap);
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
                + " cap=" + IntToString(nCap)
                + " overflows=" + IntToString(nOverflowCount)
                + " overflows_cap=" + IntToString(GetLocalInt(oArea, "al_reg_overflow_count_cap"))
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
                AL_RegReverseDelete(oArea, oNpc);
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
                    AL_RegReverseSet(oArea, oLast, i);
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
        AL_RegReverseSet(oArea, oNpc, i);
        i = i + 1;
    }

    SetLocalInt(oArea, "al_reg_compact_removed_total", GetLocalInt(oArea, "al_reg_compact_removed_total") + nRemoved);
    SetLocalInt(oArea, "al_reg_compact_removed_window", GetLocalInt(oArea, "al_reg_compact_removed_window") + nRemoved);
    SetLocalInt(oArea, "al_reg_compact_tick", nSyncTick);
    SetLocalInt(oArea, "al_reg_dirty", FALSE);
}
