#ifndef AL_ROUTE_INC_NSS
#define AL_ROUTE_INC_NSS

#include "al_events_inc"
#include "al_activity_inc"

const string AL_LOCAL_ROUTE_TAG = "al_route_tag";
const string AL_LOCAL_ROUTE_ACTIVE = "al_route_active";
const string AL_LOCAL_ROUTE_INDEX = "al_route_index";
const string AL_LOCAL_ROUTE_STEP_COUNT = "al_route_step_count";
const string AL_LOCAL_ROUTE_DWELL_UNTIL = "al_route_dwell_until";

const string AL_LOCAL_WP_PREFIX = "alwp";
const string AL_LOCAL_STEP = "al_step";
const string AL_LOCAL_ACTIVITY = "al_activity";
const string AL_LOCAL_DUR_SEC = "al_dur_sec";

const int AL_ROUTE_MAX_STEPS = 32;

string AL_GetRouteStepObjectKey(int nIndex)
{
    return "al_route_step_obj_" + IntToString(nIndex);
}

void AL_ClearRouteStepObjects(object oNpc)
{
    int nPrevCount = GetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT);
    int i = 0;
    while (i < nPrevCount)
    {
        DeleteLocalObject(oNpc, AL_GetRouteStepObjectKey(i));
        i = i + 1;
    }
    SetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT, 0);
}

string AL_GetSlotRouteTag(object oNpc, int nSlot)
{
    if (nSlot < 0 || nSlot > 5) return "";
    return GetLocalString(oNpc, AL_LOCAL_WP_PREFIX + IntToString(nSlot));
}

int AL_InsertRouteStep(object oNpc, object oWp, int nStep)
{
    int nCount = GetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT);
    if (nCount >= AL_ROUTE_MAX_STEPS) return nCount;

    int nInsert = nCount;
    int i = 0;
    while (i < nCount)
    {
        object oExisting = GetLocalObject(oNpc, AL_GetRouteStepObjectKey(i));
        int nExistingStep = GetLocalInt(oExisting, AL_LOCAL_STEP);
        if (nStep < nExistingStep)
        {
            nInsert = i;
            break;
        }
        i = i + 1;
    }

    i = nCount;
    while (i > nInsert)
    {
        object oPrev = GetLocalObject(oNpc, AL_GetRouteStepObjectKey(i - 1));
        SetLocalObject(oNpc, AL_GetRouteStepObjectKey(i), oPrev);
        i = i - 1;
    }

    SetLocalObject(oNpc, AL_GetRouteStepObjectKey(nInsert), oWp);
    SetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT, nCount + 1);
    return nCount + 1;
}

int AL_BuildRouteSteps(object oNpc, string sRouteTag)
{
    AL_ClearRouteStepObjects(oNpc);

    if (sRouteTag == "") return 0;

    int nNth = 1;
    int nCount = 0;
    object oWp = GetNearestObjectByTag(sRouteTag, oNpc, nNth);

    while (GetIsObjectValid(oWp) && nCount < AL_ROUTE_MAX_STEPS)
    {
        if (GetObjectType(oWp) == OBJECT_TYPE_WAYPOINT)
        {
            nCount = AL_InsertRouteStep(oNpc, oWp, GetLocalInt(oWp, AL_LOCAL_STEP));
        }

        nNth = nNth + 1;
        oWp = GetNearestObjectByTag(sRouteTag, oNpc, nNth);
    }

    return GetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT);
}

int AL_GetStepActivity(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return AL_GetSafeActivity(oNpc, -1);
    }

    return AL_GetSafeActivity(oNpc, GetLocalInt(oWp, AL_LOCAL_ACTIVITY));
}

float AL_GetStepDwellSec(object oWp)
{
    if (!GetIsObjectValid(oWp)) return 0.0;

    int nDurSec = GetLocalInt(oWp, AL_LOCAL_DUR_SEC);
    if (nDurSec < 0) nDurSec = 0;
    return IntToFloat(nDurSec);
}

void AL_QueueRouteRepeatSignal()
{
    ActionDoCommand(SignalEvent(OBJECT_SELF, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));
}

void AL_ExecuteRouteStep(object oNpc, int nIndex)
{
    int nCount = GetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT);
    if (nCount <= 0)
    {
        SetLocalInt(oNpc, AL_LOCAL_ROUTE_ACTIVE, FALSE);
        AL_QueueActivity(oNpc, AL_GetSafeActivity(oNpc, -1), 0.0);
        return;
    }

    if (nIndex < 0 || nIndex >= nCount)
    {
        nIndex = 0;
        SetLocalInt(oNpc, AL_LOCAL_ROUTE_INDEX, nIndex);
    }

    object oWp = GetLocalObject(oNpc, AL_GetRouteStepObjectKey(nIndex));
    int nActivity = AL_GetStepActivity(oNpc, oWp);
    float fDwellSec = AL_GetStepDwellSec(oWp);

    if (GetIsObjectValid(oWp))
    {
        ActionMoveToObject(oWp, TRUE);
    }

    AL_QueueActivity(oNpc, nActivity, fDwellSec);
    float fNowSec = IntToFloat((GetTimeHour() * 3600) + (GetTimeMinute() * 60) + GetTimeSecond());
    SetLocalFloat(oNpc, AL_LOCAL_ROUTE_DWELL_UNTIL, fNowSec + fDwellSec);
    AL_QueueRouteRepeatSignal();
}

void AL_StartSlotRoute(object oNpc, int nSlot)
{
    string sRouteTag = AL_GetSlotRouteTag(oNpc, nSlot);

    SetLocalString(oNpc, AL_LOCAL_ROUTE_TAG, sRouteTag);
    SetLocalInt(oNpc, AL_LOCAL_ROUTE_INDEX, 0);
    SetLocalFloat(oNpc, AL_LOCAL_ROUTE_DWELL_UNTIL, 0.0);

    int nStepCount = AL_BuildRouteSteps(oNpc, sRouteTag);
    if (nStepCount <= 0)
    {
        SetLocalInt(oNpc, AL_LOCAL_ROUTE_ACTIVE, FALSE);
        ClearAllActions(TRUE);
        AL_QueueActivity(oNpc, AL_GetSafeActivity(oNpc, -1), 0.0);
        return;
    }

    SetLocalInt(oNpc, AL_LOCAL_ROUTE_ACTIVE, TRUE);
    ClearAllActions(TRUE);
    AL_ExecuteRouteStep(oNpc, 0);
}

void AL_HandleRouteRepeat(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;
    if (!GetLocalInt(oNpc, AL_LOCAL_ROUTE_ACTIVE)) return;

    int nCount = GetLocalInt(oNpc, AL_LOCAL_ROUTE_STEP_COUNT);
    if (nCount <= 0)
    {
        SetLocalInt(oNpc, AL_LOCAL_ROUTE_ACTIVE, FALSE);
        AL_QueueActivity(oNpc, AL_GetSafeActivity(oNpc, -1), 0.0);
        return;
    }

    int nIndex = GetLocalInt(oNpc, AL_LOCAL_ROUTE_INDEX) + 1;
    if (nIndex >= nCount)
    {
        nIndex = 0;
    }

    SetLocalInt(oNpc, AL_LOCAL_ROUTE_INDEX, nIndex);
    AL_ExecuteRouteStep(oNpc, nIndex);
}

#endif
