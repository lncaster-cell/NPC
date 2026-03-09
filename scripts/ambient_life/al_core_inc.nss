#ifndef AL_CORE_INC_NSS
#define AL_CORE_INC_NSS

#include "al_events_inc"
#include "al_registry_inc"
#include "al_schedule_inc"

const string AL_LOCAL_PLAYER_COUNT = "al_player_count";
const string AL_LOCAL_TICK_TOKEN = "al_tick_token";
const string AL_LOCAL_SLOT = "al_slot";
const string AL_LOCAL_SYNC_TICK = "al_sync_tick";

const float AL_AREA_TICK_SEC = 6.0;
const int AL_SYNC_CLEANUP_PERIOD = 10;

void AL_DelayedAreaTick(object oArea, int nToken)
{
    if (!GetIsObjectValid(oArea)) return;
    if (GetLocalInt(oArea, AL_LOCAL_TICK_TOKEN) != nToken) return;
    ExecuteScript("al_area_tick", oArea);
}

void AL_AreaTickBootstrap(object oArea, int nToken)
{
    if (!GetIsObjectValid(oArea)) return;
    DelayCommand(AL_AREA_TICK_SEC, AL_DelayedAreaTick(oArea, nToken));
}

void AL_IncrementPlayerCount(object oArea)
{
    int nCount = GetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT);
    SetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT, nCount + 1);
}

void AL_DecrementPlayerCount(object oArea)
{
    int nCount = GetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT);
    if (nCount > 0) nCount = nCount - 1;
    SetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT, nCount);
}

void AL_DispatchEventToAreaNpcs(object oArea, int nEvent)
{
    int nCount = AL_GetNpcCount(oArea);
    int i = 0;
    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_GetNpcKey(i));
        if (GetIsObjectValid(oNpc) && !GetIsDead(oNpc))
        {
            SignalEvent(oNpc, EventUserDefined(nEvent));
        }
        i = i + 1;
    }
}

void AL_ActivateArea(object oArea)
{
    if (!GetIsObjectValid(oArea)) return;

    int nToken = GetLocalInt(oArea, AL_LOCAL_TICK_TOKEN) + 1;
    SetLocalInt(oArea, AL_LOCAL_TICK_TOKEN, nToken);

    int nSlot = AL_GetCurrentSlot(oArea, OBJECT_INVALID);
    SetLocalInt(oArea, AL_LOCAL_SLOT, nSlot);

    // Immediate resync on first player entry.
    AL_DispatchEventToAreaNpcs(oArea, AL_EVENT_RESYNC);

    // Start one area-level loop.
    AL_AreaTickBootstrap(oArea, nToken);
}

void AL_DeactivateArea(object oArea)
{
    if (!GetIsObjectValid(oArea)) return;

    // Token bump invalidates delayed ticks from previous active cycle.
    int nToken = GetLocalInt(oArea, AL_LOCAL_TICK_TOKEN) + 1;
    SetLocalInt(oArea, AL_LOCAL_TICK_TOKEN, nToken);
}

#endif
