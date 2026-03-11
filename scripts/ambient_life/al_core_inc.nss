// Ambient Life Stage E core dispatcher.

#include "al_area_inc"
#include "al_events_inc"
#include "al_registry_inc"
#include "al_route_inc"
#include "al_sleep_inc"
#include "al_react_inc"

void AL_NpcHandleResync(object oNpc)
{
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
    {
        return;
    }

    int nSlot = GetLocalInt(oArea, "al_slot");
    AL_RouteRoutineStart(oNpc, nSlot, TRUE);
}

void AL_NpcHandleSlotChanged(object oNpc, int nSlot)
{
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
    {
        return;
    }

    AL_RouteRoutineStart(oNpc, nSlot, FALSE);
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
        AL_RouteRoutineAdvance(oNpc);
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
