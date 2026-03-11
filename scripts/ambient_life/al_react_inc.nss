// Ambient Life Stage I.1 disturbed reaction foundation.
// Scope intentionally narrow: inventory/theft disturbance capture + bounded local override/resume.

#include "al_area_inc"
#include "al_events_inc"

const int AL_REACT_TYPE_NONE = 0;
const int AL_REACT_TYPE_ADDED = 1;
const int AL_REACT_TYPE_REMOVED = 2;
const int AL_REACT_TYPE_STOLEN = 3;
const int AL_REACT_TYPE_UNKNOWN = 4;

// Route runtime hooks consumed by Stage I.1 reaction layer.
string AL_RouteRtActiveKey();
int AL_RouteRoutineResumeCurrent(object oNpc);
void AL_RouteBlockedRuntimeReset(object oNpc);

int AL_ReactTypeFromDisturb(int nDisturbType)
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

    return AL_REACT_TYPE_UNKNOWN;
}

int AL_ReactShouldOverrideRoutine(object oActor)
{
    if (!GetIsObjectValid(oActor) || GetObjectType(oActor) != OBJECT_TYPE_CREATURE || GetIsPC(oActor))
    {
        return FALSE;
    }

    object oArea = GetArea(oActor);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
    {
        return FALSE;
    }

    return GetLocalInt(oActor, AL_RouteRtActiveKey());
}

void AL_ReactRuntimeClear(object oActor)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    SetLocalInt(oActor, "al_react_active", FALSE);
    SetLocalInt(oActor, "al_react_resume_flag", FALSE);
}

void AL_ReactRuntimeBegin(object oActor, int nReactType, object oSource, object oItem)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    SetLocalInt(oActor, "al_react_active", TRUE);
    SetLocalInt(oActor, "al_react_type", nReactType);

    if (GetIsObjectValid(oSource))
    {
        SetLocalObject(oActor, "al_react_last_source", oSource);
    }
    else
    {
        DeleteLocalObject(oActor, "al_react_last_source");
    }

    if (GetIsObjectValid(oItem))
    {
        SetLocalObject(oActor, "al_react_last_item", oItem);
    }
    else
    {
        DeleteLocalObject(oActor, "al_react_last_item");
    }
}

void AL_ReactRunBoundedOverride(object oNpc, int bHasCredibleSource)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    ClearAllActions(TRUE);

    if (bHasCredibleSource)
    {
        object oSource = GetLocalObject(oNpc, "al_react_last_source");
        ActionMoveToObject(oSource, TRUE, 2.0);
    }

    ActionWait(0.8);
}

void AL_ReactFinishCreature(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int bResume = GetLocalInt(oNpc, "al_react_resume_flag");

    AL_ReactRuntimeClear(oNpc);

    if (!bResume)
    {
        return;
    }

    if (!AL_RouteRoutineResumeCurrent(oNpc))
    {
        AL_RouteBlockedRuntimeReset(oNpc);
        SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
    }
}

void AL_OnDisturbed(object oActor)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    if (GetLocalInt(oActor, "al_react_active"))
    {
        return;
    }

    object oSource = GetLastDisturbed();
    int nDisturbType = GetInventoryDisturbType();
    object oItem = GetInventoryDisturbItem();

    int nReactType = AL_ReactTypeFromDisturb(nDisturbType);
    AL_ReactRuntimeBegin(oActor, nReactType, oSource, oItem);

    if (nReactType == AL_REACT_TYPE_ADDED)
    {
        AL_ReactRuntimeClear(oActor);
        return;
    }

    int bCanOverride = AL_ReactShouldOverrideRoutine(oActor);
    SetLocalInt(oActor, "al_react_resume_flag", bCanOverride);

    // Creature theft context can be partial in toolset/runtime edge cases.
    // Treat missing source/item on stolen as suspicious but bounded; no crime/alarm escalation here.
    int bHasCredibleSource = GetIsObjectValid(oSource) && oSource != oActor;

    if (bCanOverride)
    {
        AL_ReactRunBoundedOverride(oActor, bHasCredibleSource);
    }

    AL_ReactFinishCreature(oActor);
}
