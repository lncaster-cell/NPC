#ifndef AL_AREA_INC_NSS
#define AL_AREA_INC_NSS

#include "al_core_inc"

void AL_HandleAreaPlayerEnter(object oArea)
{
    int nPrev = GetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT);
    AL_IncrementPlayerCount(oArea);

    if (nPrev <= 0)
    {
        AL_ActivateArea(oArea);
    }
}

void AL_HandleAreaPlayerExit(object oArea)
{
    AL_DecrementPlayerCount(oArea);

    if (GetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT) <= 0)
    {
        AL_DeactivateArea(oArea);
    }
}

void AL_HandleAreaTick(object oArea)
{
    if (!GetIsObjectValid(oArea)) return;
    if (GetLocalInt(oArea, AL_LOCAL_PLAYER_COUNT) <= 0) return;

    int nPrevSlot = GetLocalInt(oArea, AL_LOCAL_SLOT);
    int nSlot = AL_GetCurrentSlot(oArea, OBJECT_INVALID);

    if (nSlot != nPrevSlot)
    {
        SetLocalInt(oArea, AL_LOCAL_SLOT, nSlot);
        AL_DispatchEventToAreaNpcs(oArea, AL_GetSlotEvent(nSlot));
    }

    int nSyncTick = GetLocalInt(oArea, AL_LOCAL_SYNC_TICK) + 1;
    SetLocalInt(oArea, AL_LOCAL_SYNC_TICK, nSyncTick);

    if ((nSyncTick % AL_SYNC_CLEANUP_PERIOD) == 0)
    {
        AL_SyncCleanupRegistry(oArea);
    }

    int nToken = GetLocalInt(oArea, AL_LOCAL_TICK_TOKEN);
    DelayCommand(AL_AREA_TICK_SEC, AL_DelayedAreaTick(oArea, nToken));
}

#endif
