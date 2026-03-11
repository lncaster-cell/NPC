// Ambient Life Stage E route cache + bounded multi-step routine execution.

#include "al_area_inc"
#include "al_activity_inc"

const int AL_ROUTE_MAX_STEPS = 16;

string AL_RouteRtActiveKey() { return "al_route_rt_active"; }
string AL_RouteRtIdxKey() { return "al_route_rt_idx"; }
string AL_RouteRtLeftKey() { return "al_route_rt_left"; }
string AL_RouteRtCycleKey() { return "al_route_rt_cycle"; }

string AL_RouteStepKey(int nIdx)
{
    return "al_route_step_" + IntToString(nIdx);
}

string AL_RouteTagFromSlot(object oNpc, int nSlot)
{
    if (!GetIsObjectValid(oNpc) || nSlot < 0 || nSlot > 5)
    {
        return "";
    }

    return GetLocalString(oNpc, "alwp" + IntToString(nSlot));
}

void AL_RouteInvalidateCache(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nCachedSteps = GetLocalInt(oNpc, "al_route_cache_steps");
    int i = 0;
    while (i < nCachedSteps)
    {
        DeleteLocalObject(oNpc, AL_RouteStepKey(i));
        i = i + 1;
    }

    DeleteLocalString(oNpc, "al_route_cache_tag");
    DeleteLocalObject(oNpc, "al_route_cache_area");
    SetLocalInt(oNpc, "al_route_cache_slot", -1);
    SetLocalInt(oNpc, "al_route_cache_steps", 0);
    SetLocalInt(oNpc, "al_route_cache_valid", FALSE);
}

void AL_RouteRuntimeClear(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, AL_RouteRtActiveKey(), FALSE);
    SetLocalInt(oNpc, AL_RouteRtIdxKey(), 0);
    SetLocalInt(oNpc, AL_RouteRtLeftKey(), 0);
}

void AL_RouteFallbackToDefault(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AL_RouteRuntimeClear(oNpc);
    int nFallback = GetLocalInt(oNpc, "al_default_activity");
    ClearAllActions(TRUE);
    AL_ActivityApplyBaseline(oNpc, nFallback, 6);
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

    int anStepVals[AL_ROUTE_MAX_STEPS];
    object aoStepRefs[AL_ROUTE_MAX_STEPS];
    int nFound = 0;
    int nSearchIdx = 0;

    while (nFound < AL_ROUTE_MAX_STEPS)
    {
        object oWp = GetObjectByTag(sRouteTag, nSearchIdx);
        if (!GetIsObjectValid(oWp))
        {
            break;
        }

        nSearchIdx = nSearchIdx + 1;
        if (GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT)
        {
            continue;
        }

        if (GetArea(oWp) != oNpcArea)
        {
            continue;
        }

        int nStep = GetLocalInt(oWp, "al_step");
        if (nStep < 0)
        {
            continue;
        }

        int bDuplicateStep = FALSE;
        int i = 0;
        while (i < nFound)
        {
            if (anStepVals[i] == nStep)
            {
                bDuplicateStep = TRUE;
                break;
            }
            i = i + 1;
        }

        if (bDuplicateStep)
        {
            continue;
        }

        anStepVals[nFound] = nStep;
        aoStepRefs[nFound] = oWp;
        nFound = nFound + 1;
    }

    if (nFound <= 0)
    {
        return FALSE;
    }

    int iSort = 0;
    while (iSort < nFound)
    {
        int iMin = iSort;
        int j = iSort + 1;

        while (j < nFound)
        {
            if (anStepVals[j] < anStepVals[iMin])
            {
                iMin = j;
            }
            j = j + 1;
        }

        if (iMin != iSort)
        {
            int nTmpStep = anStepVals[iSort];
            object oTmpRef = aoStepRefs[iSort];
            anStepVals[iSort] = anStepVals[iMin];
            aoStepRefs[iSort] = aoStepRefs[iMin];
            anStepVals[iMin] = nTmpStep;
            aoStepRefs[iMin] = oTmpRef;
        }

        iSort = iSort + 1;
    }

    int nExpected = anStepVals[0];
    int iCheck = 0;
    while (iCheck < nFound)
    {
        if (anStepVals[iCheck] != nExpected)
        {
            AL_RouteInvalidateCache(oNpc);
            return FALSE;
        }

        SetLocalObject(oNpc, AL_RouteStepKey(iCheck), aoStepRefs[iCheck]);
        nExpected = nExpected + 1;
        iCheck = iCheck + 1;
    }

    SetLocalString(oNpc, "al_route_cache_tag", sRouteTag);
    SetLocalObject(oNpc, "al_route_cache_area", oNpcArea);
    SetLocalInt(oNpc, "al_route_cache_slot", nSlot);
    SetLocalInt(oNpc, "al_route_cache_steps", nFound);
    SetLocalInt(oNpc, "al_route_cache_valid", TRUE);

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

    if (!bForceRebuild)
    {
        int bValid = GetLocalInt(oNpc, "al_route_cache_valid");
        int nCachedSlot = GetLocalInt(oNpc, "al_route_cache_slot");
        string sCachedTag = GetLocalString(oNpc, "al_route_cache_tag");
        object oCachedArea = GetLocalObject(oNpc, "al_route_cache_area");
        object oCurrentArea = GetArea(oNpc);
        if (bValid && nCachedSlot == nSlot && sCachedTag == sRouteTag && oCachedArea == oCurrentArea)
        {
            return TRUE;
        }
    }

    return AL_RouteBuildCache(oNpc, nSlot, sRouteTag);
}

int AL_RouteQueueStep(object oNpc, int nStepIdx)
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

    int nActivity = GetLocalInt(oTarget, "al_activity");
    if (nActivity <= AL_ACTIVITY_IDLE)
    {
        nActivity = GetLocalInt(oNpc, "al_default_activity");
    }

    int nDur = GetLocalInt(oTarget, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 6;
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oTarget, TRUE, 1.5);
    AL_ActivityApplyBaseline(oNpc, nActivity, nDur);
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    SetLocalInt(oNpc, AL_RouteRtIdxKey(), nStepIdx);
    SetLocalInt(oNpc, AL_RouteRtActiveKey(), TRUE);

    return TRUE;
}

void AL_RouteRoutineStart(object oNpc, int nSlot, int bForceRebuild)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
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

    SetLocalInt(oNpc, AL_RouteRtLeftKey(), nSteps);
    SetLocalInt(oNpc, AL_RouteRtCycleKey(), GetLocalInt(oNpc, AL_RouteRtCycleKey()) + 1);

    if (!AL_RouteQueueStep(oNpc, 0))
    {
        AL_RouteFallbackToDefault(oNpc);
    }
}

void AL_RouteRoutineAdvance(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
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
