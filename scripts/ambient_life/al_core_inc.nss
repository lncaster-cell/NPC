// Ambient Life Stage F core dispatcher (Stage E routines + separate transitions).

#include "al_area_inc"
#include "al_events_inc"
#include "al_registry_inc"
#include "al_route_inc"
#include "al_sleep_inc"
#include "al_react_inc"
#include "al_blocked_inc"
#include "al_city_crime_inc"
#include "al_city_population_inc"

void AL_NpcHandleResync(object oNpc)
{
    object oArea = GetArea(oNpc);
    if (!AL_IsHotArea(oArea))
    {
        return;
    }

    int nSlot = GetLocalInt(oArea, "al_slot");
    AL_RouteResyncCurrentArea(oNpc, nSlot);
}

void AL_NpcHandleSlotChanged(object oNpc, int nSlot)
{
    object oArea = GetArea(oNpc);
    if (!AL_IsHotArea(oArea))
    {
        return;
    }

    AL_RouteRoutineStart(oNpc, nSlot, FALSE);
}


void AL_CityAlarmHandleAssignment(object oNpc, int nEvent)
{
    object oTarget = GetLocalObject(oNpc, "al_city_alarm_assignment_target");

    if (nEvent == AL_EVENT_CITY_ASSIGN_GO_SHELTER)
    {
        if (GetIsObjectValid(oTarget))
        {
            AssignCommand(oNpc, ActionMoveToObject(oTarget, TRUE, 1.0));
        }
        return;
    }

    if (nEvent == AL_EVENT_CITY_ASSIGN_GO_ARSENAL)
    {
        if (GetIsObjectValid(oTarget))
        {
            AssignCommand(oNpc, ActionMoveToObject(oTarget, TRUE, 1.0));
            AssignCommand(oNpc, ActionDoCommand(SetLocalInt(OBJECT_SELF, "al_city_alarm_hidden_in_arsenal", TRUE)));
            AssignCommand(oNpc, ActionWait(0.2));
            AssignCommand(oNpc, ActionDoCommand(DeleteLocalInt(OBJECT_SELF, "al_city_alarm_hidden_in_arsenal")));
            AssignCommand(oNpc, ActionDoCommand(AL_CityAlarmSetMilitiaAlarmLoadout(OBJECT_SELF, TRUE)));
        }
        return;
    }

    if (nEvent == AL_EVENT_CITY_ASSIGN_HOLD_WAR_POST)
    {
        if (GetIsObjectValid(oTarget))
        {
            AssignCommand(oNpc, ActionMoveToObject(oTarget, TRUE, 1.0));
        }
        return;
    }

    if (nEvent == AL_EVENT_CITY_ASSIGN_ALARM_RECOVERY)
    {
        int nRole = AL_ReactGetNpcRole(oNpc);
        if (nRole == AL_NPC_ROLE_MILITIA)
        {
            object oArea = GetArea(oNpc);
            object oArsenal = AL_CityAlarmResolvePoint(oArea, AL_CityAlarmPointTag(oArea, "al_city_arsenal_tag"));
            if (GetIsObjectValid(oArsenal))
            {
                AssignCommand(oNpc, ActionMoveToObject(oArsenal, TRUE, 1.0));
            }
            AssignCommand(oNpc, ActionDoCommand(AL_CityAlarmSetMilitiaAlarmLoadout(OBJECT_SELF, FALSE)));
        }

        DeleteLocalString(oNpc, "al_city_alarm_assignment");
        DeleteLocalObject(oNpc, "al_city_alarm_assignment_target");
        SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
        return;
    }
}

void AL_OnNpcUserDefined(object oNpc)
{
    if (!AL_IsRuntimeNpc(oNpc))
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

    if (nEvent == AL_EVENT_CITY_ASSIGN_GO_SHELTER
        || nEvent == AL_EVENT_CITY_ASSIGN_GO_ARSENAL
        || nEvent == AL_EVENT_CITY_ASSIGN_HOLD_WAR_POST
        || nEvent == AL_EVENT_CITY_ASSIGN_ALARM_RECOVERY)
    {
        AL_CityAlarmHandleAssignment(oNpc, nEvent);
        return;
    }

    if (nEvent == AL_EVENT_ROUTE_REPEAT)
    {
        AL_RouteBlockedRuntimeReset(oNpc);
        AL_RouteRoutineAdvance(oNpc);
        return;
    }

    if (nEvent == AL_EVENT_BLOCKED_RESUME)
    {
        if (!AL_RouteRoutineResumeCurrent(oNpc))
        {
            AL_RouteBlockedRuntimeReset(oNpc);
            SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
            return;
        }

        SetLocalInt(oNpc, "al_blocked_rt_active", FALSE);
        return;
    }
}

void AL_OnNpcSpawn(object oNpc)
{
    AL_CityPopulationOnNpcSpawn(oNpc);
    AL_RegisterNPC(oNpc);

    object oArea = GetArea(oNpc);
    if (AL_IsHotArea(oArea))
    {
        int nSlot = GetLocalInt(oArea, "al_slot");
        SetLocalInt(oNpc, "al_last_slot", nSlot);
        AL_RouteRoutineStart(oNpc, nSlot, FALSE);
    }

    AL_RouteBlockedRuntimeReset(oNpc);
    SetLocalString(oNpc, "al_mode", "idle");
    AL_CityAlarmMaterializeNpc(oNpc);
}

void AL_OnNpcDeath(object oNpc)
{
    AL_CityPopulationOnNpcDeath(oNpc);
    AL_CityCrimeOnDeath(oNpc);
    AL_UnregisterNPC(oNpc);
}

void AL_OnNpcPhysicalAttacked(object oNpc)
{
    AL_CityCrimeOnPhysicalAttacked(oNpc);
}

void AL_OnNpcDamaged(object oNpc)
{
    AL_CityCrimeOnDamaged(oNpc);
}

void AL_OnNpcSpellCastAt(object oNpc)
{
    AL_CityCrimeOnSpellCastAt(oNpc);
}

void AL_OnAreaTickBootstrap(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return;
    }

    // Bootstrap-only entrypoint (toolset OnHeartbeat safety hook).
    // Periodic loop is owned exclusively by AL_ScheduleAreaTick/AL_AreaTick.
    AL_AreaActivate(oArea);
}
