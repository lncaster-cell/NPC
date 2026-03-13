// Ambient Life Stage I.0 local OnBlocked runtime helper.
// Scope intentionally narrow: door-first local unblock, then bounded resync fallback.

#include "al_area_inc"
#include "al_events_inc"
#include "al_route_runtime_api_inc"

const int AL_BLOCKED_MAX_RETRY = 1;

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
    SetLocalInt(oNpc, "al_action_signal_event", AL_EVENT_BLOCKED_RESUME);
    ActionDoCommand(ExecuteScript("al_action_signal_ud", OBJECT_SELF));
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

    if (!AL_RouteRuntimeIsActive(oNpc))
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

    if (nRetry <= AL_BLOCKED_MAX_RETRY && AL_RouteRuntimeResumeSafe(oNpc))
    {
        SetLocalInt(oNpc, "al_blocked_rt_active", FALSE);
        return;
    }

    AL_RouteRuntimeResetSafe(oNpc);
    SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
}
