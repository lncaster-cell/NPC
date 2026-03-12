// Ambient Life Stage G sleep runtime.
// Separate special routine subsystem over Stage E/F bounded progression.

#include "al_area_inc"
#include "al_events_inc"

void AL_SleepRuntimeClear(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }
}

int AL_SleepIsStep(object oStep)
{
    if (!GetIsObjectValid(oStep))
    {
        return FALSE;
    }

    return (GetLocalString(oStep, "al_bed_id") != "");
}

object AL_SleepResolveWaypoint(object oNpc, string sTag)
{
    if (!GetIsObjectValid(oNpc) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    return AL_ResolveWaypointInAreaCached(oArea, sTag);
}

int AL_SleepQueueOnPlace(object oNpc, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (nDurSec <= 0)
    {
        nDurSec = 20;
    }

    ClearAllActions(TRUE);
    SetLocalString(oNpc, "al_action_mode_value", "sleep");
    ActionDoCommand(ExecuteScript("al_action_set_mode", OBJECT_SELF));
    ActionWait(IntToFloat(nDurSec));
    SetLocalInt(oNpc, "al_action_signal_event", AL_EVENT_ROUTE_REPEAT);
    ActionDoCommand(ExecuteScript("al_action_signal_ud", OBJECT_SELF));

    return TRUE;
}

int AL_SleepQueueFromStep(object oNpc, object oStep)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oStep))
    {
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
    {
        return FALSE;
    }

    int nDur = GetLocalInt(oStep, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 20;
    }

    string sBedId = GetLocalString(oStep, "al_bed_id");
    if (sBedId == "")
    {
        return AL_SleepQueueOnPlace(oNpc, nDur);
    }

    object oApproach = AL_SleepResolveWaypoint(oNpc, sBedId + "_approach");
    object oPose = AL_SleepResolveWaypoint(oNpc, sBedId + "_pose");
    if (!GetIsObjectValid(oApproach) || !GetIsObjectValid(oPose))
    {
        return AL_SleepQueueOnPlace(oNpc, nDur);
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oApproach, TRUE, 1.5);
    ActionJumpToLocation(GetLocation(oPose));
    SetLocalString(oNpc, "al_action_mode_value", "sleep");
    ActionDoCommand(ExecuteScript("al_action_set_mode", OBJECT_SELF));
    ActionWait(IntToFloat(nDur));
    SetLocalInt(oNpc, "al_action_signal_event", AL_EVENT_ROUTE_REPEAT);
    ActionDoCommand(ExecuteScript("al_action_signal_ud", OBJECT_SELF));

    return TRUE;
}
