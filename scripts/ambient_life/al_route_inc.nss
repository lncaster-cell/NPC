// Ambient Life Stage E/F route runtime (Stage E routines + Stage F transition steps).

#include "al_area_inc"
#include "al_activity_inc"
#include "al_transition_inc"
#include "al_sleep_inc"

const int AL_ROUTE_MAX_STEPS = 16;
const int AL_ROUTE_REBUILD_COOLDOWN_TICKS = 2;

string AL_RouteRtActiveKey() { return "al_route_rt_active"; }
string AL_RouteRtIdxKey() { return "al_route_rt_idx"; }
string AL_RouteRtLeftKey() { return "al_route_rt_left"; }
string AL_RouteRtCycleKey() { return "al_route_rt_cycle"; }

#include "al_route_cache_inc"

void AL_RouteRuntimeClear(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, AL_RouteRtActiveKey(), FALSE);
    SetLocalInt(oNpc, AL_RouteRtIdxKey(), 0);
    SetLocalInt(oNpc, AL_RouteRtLeftKey(), 0);
    AL_TransitionRuntimeClear(oNpc);
    AL_SleepRuntimeClear(oNpc);
    AL_RouteBlockedRuntimeReset(oNpc);
}

void AL_RouteFallbackToDefault(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AL_RouteRuntimeClear(oNpc);
    ClearAllActions(TRUE);
    AL_ActivityApplyStep(oNpc, AL_ACTIVITY_HIDDEN, 6);
}

void AL_RouteResetAreaOverflowMetrics(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oArea, "al_route_overflow_count", 0);
    SetLocalInt(oArea, "al_route_invalid_step_count", 0);
    SetLocalInt(oArea, "al_route_duplicate_step_count", 0);
    DeleteLocalString(oArea, "al_route_overflow_tag");
    DeleteLocalString(oArea, "al_route_fail_reason");
    SetLocalInt(oArea, "al_route_pending_rebuild", FALSE);
    SetLocalInt(oArea, "al_route_pending_count", 0);
    SetLocalInt(oArea, "route_cache_full_rehashes", 0);
}



int AL_RouteBuildCache(object oNpc, int nSlot, string sRouteTag)
{
    AL_RouteInvalidateCache(oNpc);

    if (!GetIsObjectValid(oNpc) || sRouteTag == "" || nSlot < 0 || nSlot > 5)
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    if (!GetIsObjectValid(oNpcArea))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, "al_route_overflow_count", 0);
    SetLocalInt(oNpc, "al_route_invalid_step_count", 0);
    SetLocalInt(oNpc, "al_route_duplicate_step_count", 0);
    DeleteLocalString(oNpc, "al_route_overflow_tag");
    DeleteLocalString(oNpc, "al_route_fail_reason");

    if (!AL_RouteEnsureAreaCache(oNpcArea, sRouteTag, FALSE))
    {
        SetLocalInt(oNpc, "al_route_overflow_count", GetLocalInt(oNpcArea, "al_route_overflow_count"));
        SetLocalInt(oNpc, "al_route_invalid_step_count", GetLocalInt(oNpcArea, "al_route_invalid_step_count"));
        SetLocalInt(oNpc, "al_route_duplicate_step_count", GetLocalInt(oNpcArea, "al_route_duplicate_step_count"));
        SetLocalString(oNpc, "al_route_fail_reason", GetLocalString(oNpcArea, "al_route_fail_reason"));
        return FALSE;
    }

    int nFound = GetLocalInt(oNpcArea, AL_RouteAreaCacheStepsKey(sRouteTag));
    if (nFound <= 0)
    {
        return FALSE;
    }

    int iCheck = 0;
    while (iCheck < nFound)
    {
        object oStep = GetLocalObject(oNpcArea, AL_RouteAreaStepKey(sRouteTag, iCheck));
        if (!GetIsObjectValid(oStep) || GetObjectType(oStep) != OBJECT_TYPE_WAYPOINT || GetArea(oStep) != oNpcArea)
        {
            AL_RouteInvalidateAreaCache(oNpcArea, sRouteTag);
            AL_RouteInvalidateCache(oNpc);
            return FALSE;
        }

        SetLocalObject(oNpc, AL_RouteStepKey(iCheck), oStep);
        iCheck = iCheck + 1;
    }

    SetLocalString(oNpc, "al_route_cache_tag", sRouteTag);
    SetLocalObject(oNpc, "al_route_cache_area", oNpcArea);
    SetLocalInt(oNpc, "al_route_cache_slot", nSlot);
    SetLocalInt(oNpc, "al_route_cache_steps", nFound);
    SetLocalInt(oNpc, "al_route_cache_valid", TRUE);
    SetLocalInt(oNpc, "al_route_cache_fingerprint", GetLocalInt(oNpcArea, AL_RouteAreaFingerprintKey(sRouteTag)));

    return TRUE;
}

int AL_RouteEnsureCache(object oNpc, int nSlot, int bForceRebuild)
{
    if (!GetIsObjectValid(oNpc) || nSlot < 0 || nSlot > 5)
    {
        return FALSE;
    }

    string sRouteTag = AL_RouteTagFromSlot(oNpc, nSlot);
    if (sRouteTag == "")
    {
        AL_RouteInvalidateCache(oNpc);
        return FALSE;
    }

    object oCurrentArea = GetArea(oNpc);
    if (!GetIsObjectValid(oCurrentArea))
    {
        return FALSE;
    }

    int bValid = GetLocalInt(oNpc, "al_route_cache_valid");
    int nCachedSlot = GetLocalInt(oNpc, "al_route_cache_slot");
    string sCachedTag = GetLocalString(oNpc, "al_route_cache_tag");
    object oCachedArea = GetLocalObject(oNpc, "al_route_cache_area");
    if (bValid && nCachedSlot == nSlot && sCachedTag == sRouteTag && oCachedArea == oCurrentArea)
    {
        if (!bForceRebuild)
        {
            return TRUE;
        }

        int nCurrentFingerprint = GetLocalInt(oCurrentArea, AL_RouteAreaFingerprintKey(sRouteTag));
        int nCachedFingerprint = GetLocalInt(oNpc, "al_route_cache_fingerprint");
        if (nCurrentFingerprint != 0 && nCurrentFingerprint == nCachedFingerprint)
        {
            SetLocalInt(oNpc, "route_cache_hits", GetLocalInt(oNpc, "route_cache_hits") + 1);
            return TRUE;
        }
    }

    if (!AL_RouteEnsureAreaCache(oCurrentArea, sRouteTag, bForceRebuild))
    {
        AL_RouteInvalidateCache(oNpc);
        return FALSE;
    }

    SetLocalInt(oNpc, "route_cache_rebuilds", GetLocalInt(oNpc, "route_cache_rebuilds") + 1);
    return AL_RouteBuildCache(oNpc, nSlot, sRouteTag);
}

int AL_RouteQueueStep(object oNpc, int nStepIdx)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    if (!AL_IsHotArea(oArea))
    {
        return FALSE;
    }

    int nSteps = GetLocalInt(oNpc, "al_route_cache_steps");
    if (nSteps <= 0 || nStepIdx < 0 || nStepIdx >= nSteps)
    {
        return FALSE;
    }

    object oTarget = GetLocalObject(oNpc, AL_RouteStepKey(nStepIdx));
    if (!GetIsObjectValid(oTarget))
    {
        AL_RouteInvalidateCache(oNpc);
        return FALSE;
    }

    if (GetArea(oTarget) != oArea)
    {
        AL_RouteInvalidateCache(oNpc);
        return FALSE;
    }

    if (AL_TransitionTypeFromStep(oTarget) != AL_TRANSITION_NONE)
    {
        if (!AL_TransitionQueueFromStep(oNpc, oTarget))
        {
            return FALSE;
        }

        SetLocalInt(oNpc, AL_RouteRtIdxKey(), nStepIdx);
        SetLocalInt(oNpc, AL_RouteRtActiveKey(), TRUE);
        return TRUE;
    }

    if (AL_SleepIsStep(oTarget))
    {
        AL_TransitionRuntimeClear(oNpc);
        if (!AL_SleepQueueFromStep(oNpc, oTarget))
        {
            return FALSE;
        }

        SetLocalInt(oNpc, AL_RouteRtIdxKey(), nStepIdx);
        SetLocalInt(oNpc, AL_RouteRtActiveKey(), TRUE);
        return TRUE;
    }

    AL_TransitionRuntimeClear(oNpc);
    AL_SleepRuntimeClear(oNpc);

    int nActivity = GetLocalInt(oTarget, "al_activity");

    int nDur = GetLocalInt(oTarget, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 6;
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oTarget, TRUE, 1.5);
    AL_ActivityApplyStep(oNpc, nActivity, nDur);
    SetLocalInt(oNpc, "al_action_signal_event", AL_EVENT_ROUTE_REPEAT);
    ActionDoCommand(ExecuteScript("al_action_signal_ud", OBJECT_SELF));

    SetLocalInt(oNpc, AL_RouteRtIdxKey(), nStepIdx);
    SetLocalInt(oNpc, AL_RouteRtActiveKey(), TRUE);

    return TRUE;
}

int AL_RouteRoutineResumeCurrent(object oNpc)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    if (!AL_IsHotArea(oArea))
    {
        return FALSE;
    }

    if (!GetLocalInt(oNpc, AL_RouteRtActiveKey()))
    {
        return FALSE;
    }

    int nCurrent = GetLocalInt(oNpc, AL_RouteRtIdxKey());
    return AL_RouteQueueStep(oNpc, nCurrent);
}

void AL_RouteResyncCurrentArea(object oNpc, int nSlot)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    AL_RouteInvalidateCache(oNpc);
    AL_RouteRoutineStart(oNpc, nSlot, TRUE);
}

void AL_RouteRoutineStart(object oNpc, int nSlot, int bForceRebuild)
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

    if (!AL_RouteEnsureCache(oNpc, nSlot, bForceRebuild))
    {
        AL_RouteFallbackToDefault(oNpc);
        return;
    }

    int nSteps = GetLocalInt(oNpc, "al_route_cache_steps");
    if (nSteps <= 0)
    {
        AL_RouteRuntimeClear(oNpc);
        return;
    }

    AL_RouteBlockedRuntimeReset(oNpc);

    SetLocalInt(oNpc, AL_RouteRtLeftKey(), nSteps);
    SetLocalInt(oNpc, AL_RouteRtCycleKey(), GetLocalInt(oNpc, AL_RouteRtCycleKey()) + 1);

    if (!AL_RouteQueueStep(oNpc, 0))
    {
        AL_RouteFallbackToDefault(oNpc);
    }
}

void AL_RouteRoutineAdvance(object oNpc)
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

    int nSteps = GetLocalInt(oNpc, "al_route_cache_steps");
    if (nSteps <= 0)
    {
        AL_RouteRuntimeClear(oNpc);
        return;
    }

    int nLeft = GetLocalInt(oNpc, AL_RouteRtLeftKey()) - 1;
    SetLocalInt(oNpc, AL_RouteRtLeftKey(), nLeft);
    if (nLeft <= 0)
    {
        AL_RouteRuntimeClear(oNpc);
        return;
    }

    int nCurrent = GetLocalInt(oNpc, AL_RouteRtIdxKey());
    int nNext = nCurrent + 1;
    if (nNext >= nSteps)
    {
        nNext = 0;
    }

    if (!AL_RouteQueueStep(oNpc, nNext))
    {
        AL_RouteFallbackToDefault(oNpc);
    }
}
