// Ambient Life debug helpers.

void AL_DebugLogRegIndexMissStatus(
    object oArea,
    int nSyncTick,
    int nRegIndexMissStatus,
    int nRegIndexMissWindowDelta,
    int nRegIndexMissWindowTicks,
    int nRegIndexMissTickDelta,
    int nRegIndexMissTotal
)
{
    if (GetLocalInt(oArea, "al_debug") <= 0 || nRegIndexMissStatus <= 0)
    {
        return;
    }

    int nLastWarnTick = GetLocalInt(oArea, "al_h_reg_index_miss_warn_last_tick");
    int nPrevWarnStatus = GetLocalInt(oArea, "al_h_reg_index_miss_warn_prev_status");
    if (nSyncTick <= 0 || nLastWarnTick <= 0 || (nSyncTick - nLastWarnTick) >= AL_HEALTH_RESYNC_WINDOW_TICKS || nRegIndexMissStatus != nPrevWarnStatus)
    {
        string sWarnStatus = "WARN";
        if (nRegIndexMissStatus >= 2)
        {
            sWarnStatus = "CRITICAL";
        }

        WriteTimestampedLogEntry(
            "[AL][RegIndexMiss] area=" + GetTag(oArea)
            + " status=" + sWarnStatus
            + " sync_tick=" + IntToString(nSyncTick)
            + " window_delta=" + IntToString(nRegIndexMissWindowDelta)
            + " window_ticks=" + IntToString(nRegIndexMissWindowTicks)
            + " tick_delta=" + IntToString(nRegIndexMissTickDelta)
            + " total=" + IntToString(nRegIndexMissTotal)
        );

        if (nSyncTick > 0)
        {
            SetLocalInt(oArea, "al_h_reg_index_miss_warn_last_tick", nSyncTick);
        }
    }
}
