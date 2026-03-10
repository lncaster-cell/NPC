// Ambient Life Stage B core dispatcher.

#include "al_area_inc"
#include "al_events_inc"
#include "al_registry_inc"
#include "al_route_inc"
#include "al_sleep_inc"
#include "al_react_inc"

void AL_NpcHandleResync(object oNpc)
{
    // Stage B baseline hook; route/sleep/reaction runtime intentionally deferred.
}

void AL_NpcHandleSlotChanged(object oNpc, int nSlot)
{
    // Stage B baseline hook; per-NPC slot offset aware dispatch is deferred.
}

void AL_OnNpcUserDefined(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc))
    {
        return;
    }

    int nEvent = GetUserDefinedEventNumber();

    if (nEvent == AL_EVENT_RESYNC)
    {
        int nSlot = GetLocalInt(GetArea(oNpc), "al_slot");
        SetLocalInt(oNpc, "al_last_slot", nSlot);
        AL_NpcHandleResync(oNpc);
        return;
    }

    if (AL_IsSlotEvent(nEvent))
    {
        int nSlot = AL_SlotFromEvent(nEvent);
        if (nSlot < 0)
        {
            return;
        }

        int nLast = GetLocalInt(oNpc, "al_last_slot");
        if (nLast == nSlot)
        {
            return;
        }

        SetLocalInt(oNpc, "al_last_slot", nSlot);
        AL_NpcHandleSlotChanged(oNpc, nSlot);
        return;
    }

    if (nEvent == AL_EVENT_ROUTE_REPEAT)
    {
        // Reserved hook for Stage C+ route runtime.
        return;
    }
}

void AL_OnNpcSpawn(object oNpc)
{
    AL_RegisterNPC(oNpc);
    SetLocalString(oNpc, "al_mode", "idle");
}

void AL_OnNpcDeath(object oNpc)
{
    AL_UnregisterNPC(oNpc);
}

void AL_OnAreaTick(object oArea)
{
    AL_AreaTick(oArea, GetLocalInt(oArea, "al_tick_token"));
}
