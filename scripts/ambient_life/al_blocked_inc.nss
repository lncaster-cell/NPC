// Ambient Life Stage I.0 local OnBlocked runtime helper.
// Scope intentionally narrow: door-first local unblock, then bounded resync fallback.

#include "al_area_inc"
#include "al_events_inc"

const int AL_BLOCKED_MAX_RETRY = 1;

// Route runtime hooks consumed by Stage I.0 local unblock layer.
string AL_RouteRtActiveKey();
int AL_RouteRoutineResumeCurrent(object oNpc);
void AL_RouteBlockedRuntimeReset(object oNpc);

int AL_BlockedTryDoorFirst(object oNpc)
{
    object oDoor = GetBlockingDoor();
    if (!GetIsObjectValid(oDoor) || GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
    {
        return FALSE;
    }

    if (GetPlotFlag(oDoor) || GetLocked(oDoor))
    {
        return FALSE;
    }

    ClearAllActions(TRUE);
    ActionOpenDoor(oDoor);
    ActionWait(0.2);
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_BLOCKED_RESUME)));
    return TRUE;
}

void AL_OnNpcBlocked(object oNpc)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (!AL_IsHotArea(oArea))
    {
        return;
    }

    if (!GetLocalInt(oNpc, AL_RouteRtActiveKey()))
    {
        return;
    }

    if (GetLocalInt(oNpc, "al_blocked_rt_active"))
    {
        return;
    }

    SetLocalInt(oNpc, "al_blocked_rt_active", TRUE);

    if (AL_BlockedTryDoorFirst(oNpc))
    {
        return;
    }

    int nRetry = GetLocalInt(oNpc, "al_blocked_rt_retry") + 1;
    SetLocalInt(oNpc, "al_blocked_rt_retry", nRetry);

    if (nRetry <= AL_BLOCKED_MAX_RETRY && AL_RouteRoutineResumeCurrent(oNpc))
    {
        SetLocalInt(oNpc, "al_blocked_rt_active", FALSE);
        return;
    }

    AL_RouteBlockedRuntimeReset(oNpc);
    SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
}
