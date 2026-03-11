// Ambient Life Stage G sleep runtime.
// Separate special routine subsystem over Stage E/F bounded progression.

#include "al_area_inc"
#include "al_events_inc"

const int AL_SLEEP_PHASE_NONE = 0;
const int AL_SLEEP_PHASE_PLACE = 1;
const int AL_SLEEP_PHASE_APPROACH = 2;
const int AL_SLEEP_PHASE_POSE = 3;

string AL_SleepRtActiveKey() { return "al_sleep_rt_active"; }
string AL_SleepRtBedIdKey() { return "al_sleep_rt_bed_id"; }
string AL_SleepRtPhaseKey() { return "al_sleep_rt_phase"; }

void AL_SleepRuntimeClear(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, AL_SleepRtActiveKey(), FALSE);
    SetLocalInt(oNpc, AL_SleepRtPhaseKey(), AL_SLEEP_PHASE_NONE);
    DeleteLocalString(oNpc, AL_SleepRtBedIdKey());
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

    object oWp = GetObjectByTag(sTag, 0);
    if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT)
    {
        return OBJECT_INVALID;
    }

    if (GetArea(oWp) != GetArea(oNpc))
    {
        return OBJECT_INVALID;
    }

    return oWp;
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
    ActionWait(IntToFloat(nDurSec));
    ActionDoCommand(SetLocalString(oNpc, "al_mode", "sleep"));
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    SetLocalInt(oNpc, AL_SleepRtActiveKey(), TRUE);
    SetLocalInt(oNpc, AL_SleepRtPhaseKey(), AL_SLEEP_PHASE_PLACE);
    DeleteLocalString(oNpc, AL_SleepRtBedIdKey());

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
    ActionDoCommand(SetLocalInt(oNpc, AL_SleepRtPhaseKey(), AL_SLEEP_PHASE_POSE));
    ActionWait(IntToFloat(nDur));
    ActionDoCommand(SetLocalString(oNpc, "al_mode", "sleep"));
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    SetLocalInt(oNpc, AL_SleepRtActiveKey(), TRUE);
    SetLocalInt(oNpc, AL_SleepRtPhaseKey(), AL_SLEEP_PHASE_APPROACH);
    SetLocalString(oNpc, AL_SleepRtBedIdKey(), sBedId);

    return TRUE;
}
