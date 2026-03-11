// Ambient Life Stage I.1 reaction helper.
// Scope intentionally narrow: bounded OnDisturbed inventory/theft handling.

#include "al_area_inc"
#include "al_events_inc"

// Route/runtime hooks consumed by Stage I.1 disturbance layer.
string AL_RouteRtActiveKey();
int AL_RouteRoutineResumeCurrent(object oNpc);

const int AL_REACT_TYPE_NONE = 0;
const int AL_REACT_TYPE_ADDED = 1;
const int AL_REACT_TYPE_REMOVED = 2;
const int AL_REACT_TYPE_STOLEN = 3;

const int AL_REACT_STAGE_DISTURBED = 1;

int AL_ReactClassifyInventoryDisturb(int nDisturbType)
{
    if (nDisturbType == INVENTORY_DISTURB_TYPE_ADDED)
    {
        return AL_REACT_TYPE_ADDED;
    }

    if (nDisturbType == INVENTORY_DISTURB_TYPE_REMOVED)
    {
        return AL_REACT_TYPE_REMOVED;
    }

    if (nDisturbType == INVENTORY_DISTURB_TYPE_STOLEN)
    {
        return AL_REACT_TYPE_STOLEN;
    }

    return AL_REACT_TYPE_NONE;
}

int AL_ReactCanHandleDisturbed(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc))
    {
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
    {
        return FALSE;
    }

    if (!GetLocalInt(oNpc, AL_RouteRtActiveKey()))
    {
        return FALSE;
    }

    if (GetLocalInt(oNpc, "al_react_active"))
    {
        return FALSE;
    }

    return TRUE;
}

void AL_ReactQueueDisturbedResponse(object oNpc, int nReactType)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nActivity = 43; // Guard (Stage H canonical subset)
    int nDur = 2;

    if (nReactType == AL_REACT_TYPE_ADDED)
    {
        nActivity = 23; // StandChat - low-intensity acknowledgement.
        nDur = 1;
    }
    else if (nReactType == AL_REACT_TYPE_REMOVED)
    {
        nActivity = 8; // Angry.
        nDur = 2;
    }

    ClearAllActions(TRUE);
    ActionPlayAnimation(ANIMATION_LOOPING_PAUSE, 1.0, 1.0);
    ActionDoCommand(SetLocalInt(oNpc, "al_activity_current", nActivity));
    ActionWait(IntToFloat(nDur));
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_REACT_RESUME)));
}

void AL_ReactDisturbedCaptureContext(object oNpc, int nReactType, object oSource, object oItem)
{
    SetLocalInt(oNpc, "al_react_active", TRUE);
    SetLocalInt(oNpc, "al_react_type", nReactType);
    SetLocalInt(oNpc, "al_react_stage", AL_REACT_STAGE_DISTURBED);
    SetLocalInt(oNpc, "al_react_resume_flag", TRUE);
    SetLocalObject(oNpc, "al_react_last_source", oSource);
    SetLocalObject(oNpc, "al_react_last_item", oItem);
}

void AL_OnNpcDisturbed(object oNpc)
{
    if (!AL_ReactCanHandleDisturbed(oNpc))
    {
        return;
    }

    object oSource = GetLastDisturbed();
    int nReactType = AL_ReactClassifyInventoryDisturb(GetInventoryDisturbType());
    object oItem = GetInventoryDisturbItem();

    if (nReactType == AL_REACT_TYPE_NONE)
    {
        return;
    }

    AL_ReactDisturbedCaptureContext(oNpc, nReactType, oSource, oItem);
    AL_ReactQueueDisturbedResponse(oNpc, nReactType);
}

void AL_ReactRuntimeClear(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, "al_react_active", FALSE);
    SetLocalInt(oNpc, "al_react_type", AL_REACT_TYPE_NONE);
    SetLocalInt(oNpc, "al_react_stage", 0);
    SetLocalInt(oNpc, "al_react_resume_flag", FALSE);
}

void AL_OnNpcReactResume(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || !GetLocalInt(oNpc, "al_react_active"))
    {
        return;
    }

    int bResume = GetLocalInt(oNpc, "al_react_resume_flag");
    AL_ReactRuntimeClear(oNpc);

    if (!bResume)
    {
        return;
    }

    if (AL_RouteRoutineResumeCurrent(oNpc))
    {
        return;
    }

    SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
}
