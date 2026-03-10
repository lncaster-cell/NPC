// Ambient Life area lifecycle and single-loop tick runtime (Stage B).

#include "al_events_inc"
#include "al_registry_inc"

const float AL_AREA_TICK_SEC = 30.0;

int AL_ComputeAreaSlot()
{
    return GetTimeHour() / 4;
}

void AL_DispatchEventToAreaRegistry(object oArea, int nEvent)
{
    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;

    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(i));
        if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc) || GetArea(oNpc) != oArea)
        {
            int nLastIdx = nCount - 1;
            object oLast = GetLocalObject(oArea, AL_RegKey(nLastIdx));
            if (i != nLastIdx)
            {
                SetLocalObject(oArea, AL_RegKey(i), oLast);
            }

            DeleteLocalObject(oArea, AL_RegKey(nLastIdx));
            nCount = nLastIdx;
            SetLocalInt(oArea, "al_npc_count", nCount);
            continue;
        }

        SignalEvent(oNpc, EventUserDefined(nEvent));
        i = i + 1;
    }
}

void AL_AreaTick(object oArea, int nToken);

void AL_ScheduleAreaTick(object oArea, int nToken)
{
    DelayCommand(AL_AREA_TICK_SEC, AL_AreaTick(oArea, nToken));
}

void AL_AreaActivate(object oArea)
{
    int nToken = GetLocalInt(oArea, "al_tick_token") + 1;
    SetLocalInt(oArea, "al_tick_token", nToken);

    AL_RegistryCompact(oArea);

    int nSlot = AL_ComputeAreaSlot();
    SetLocalInt(oArea, "al_slot", nSlot);
    SetLocalInt(oArea, "al_sync_tick", 1);

    AL_DispatchEventToAreaRegistry(oArea, AL_EVENT_RESYNC);
    AL_ScheduleAreaTick(oArea, nToken);
}

void AL_AreaDeactivate(object oArea)
{
    int nToken = GetLocalInt(oArea, "al_tick_token") + 1;
    SetLocalInt(oArea, "al_tick_token", nToken);
    SetLocalInt(oArea, "al_sync_tick", 0);
}

void AL_AreaTick(object oArea, int nToken)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, "al_player_count") <= 0)
    {
        return;
    }

    if (GetLocalInt(oArea, "al_tick_token") != nToken)
    {
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick") + 1;
    SetLocalInt(oArea, "al_sync_tick", nSyncTick);

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

    AL_ScheduleAreaTick(oArea, nToken);
}

void AL_OnAreaEnter(object oArea, object oEnter)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oEnter) || !GetIsPC(oEnter))
    {
        return;
    }

    int nPlayers = GetLocalInt(oArea, "al_player_count") + 1;
    SetLocalInt(oArea, "al_player_count", nPlayers);

    if (nPlayers == 1)
    {
        AL_AreaActivate(oArea);
    }
}

void AL_OnAreaExit(object oArea, object oExit)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oExit) || !GetIsPC(oExit))
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
        AL_AreaDeactivate(oArea);
    }
}

void AL_OnModuleLeave(object oPC)
{
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC))
    {
        return;
    }

    object oArea = GetArea(oPC);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    AL_OnAreaExit(oArea, oPC);
}
