// Ambient Life area lifecycle and single-loop tick runtime (Stage C).

#include "al_events_inc"
#include "al_registry_inc"

const float AL_AREA_TICK_SEC = 30.0;
const int AL_SIM_TIER_FREEZE = 0;
const int AL_SIM_TIER_WARM = 1;
const int AL_SIM_TIER_HOT = 2;
const int AL_WARM_RETENTION_TICKS = 2;
const int AL_WARM_MAINTENANCE_PERIOD = 4;
const int AL_DISPATCH_BATCH_SIZE = 25;
const string AL_COUNTED_AREA_LOCAL = "al_counted_area";
const string AL_TICK_SCHED_MARKER_LOCAL = "al_tick_from_scheduler";

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
    int nOldTier = GetLocalInt(oArea, "al_sim_tier");
    if (nOldTier == nTier)
    {
        return;
    }

    SetLocalInt(oArea, "al_sim_tier", nTier);

    if (nTier == AL_SIM_TIER_FREEZE)
    {
        int nToken = GetLocalInt(oArea, "al_tick_token") + 1;
        SetLocalInt(oArea, "al_tick_token", nToken);
        SetLocalInt(oArea, "al_sync_tick", 0);
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

void AL_StartBatchedDispatch(object oArea, int nEvent)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, "al_dispatch_active") > 0 && GetLocalInt(oArea, "al_dispatch_event") == nEvent)
    {
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    if (nCount > GetLocalInt(oArea, "al_dispatch_queue_len_max"))
    {
        SetLocalInt(oArea, "al_dispatch_queue_len_max", nCount);
    }

    int nCycleId = GetLocalInt(oArea, "al_dispatch_cycle") + 1;
    SetLocalInt(oArea, "al_dispatch_cycle", nCycleId);
    SetLocalInt(oArea, "al_dispatch_cursor", 0);
    SetLocalInt(oArea, "al_dispatch_event", nEvent);
    SetLocalInt(oArea, "al_dispatch_active", 1);

    AL_RunBatchedDispatch(oArea);
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
        return;
    }

    DelayCommand(0.0, AL_RunBatchedDispatch(oArea));
}

void AL_DispatchEventToAreaRegistry(object oArea, int nEvent)
{
    AL_RegistryCompact(oArea);

    if (nEvent == AL_EVENT_RESYNC || AL_IsSlotEvent(nEvent))
    {
        AL_StartBatchedDispatch(oArea, nEvent);
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;

    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(i));
        if (GetIsObjectValid(oNpc))
        {
            SignalEvent(oNpc, EventUserDefined(nEvent));
        }
        i = i + 1;
    }
}

void AL_AreaTick(object oArea, int nToken);

void AL_RunScheduledAreaTick(object oArea, int nToken)
{
    SetLocalInt(oArea, AL_TICK_SCHED_MARKER_LOCAL, TRUE);
    AL_AreaTick(oArea, nToken);
    DeleteLocalInt(oArea, AL_TICK_SCHED_MARKER_LOCAL);
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
        if ((nSyncTick % AL_WARM_MAINTENANCE_PERIOD) == 0)
        {
            AL_RegistryCompact(oArea);
        }
    }

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
