// Ambient Life Stage D route cache + baseline route execution.

#include "al_area_inc"
#include "al_activity_inc"

const int AL_ROUTE_MAX_STEPS = 16;

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

void AL_RouteExecuteBaseline(object oNpc, int nSlot, int bForceRebuild)
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
        int nFallback = GetLocalInt(oNpc, "al_default_activity");
        ClearAllActions(TRUE);
        AL_ActivityApplyBaseline(oNpc, nFallback, 6);
        return;
    }

    object oTarget = GetLocalObject(oNpc, AL_RouteStepKey(0));
    if (!GetIsObjectValid(oTarget))
    {
        AL_RouteInvalidateCache(oNpc);
        int nFallback = GetLocalInt(oNpc, "al_default_activity");
        ClearAllActions(TRUE);
        AL_ActivityApplyBaseline(oNpc, nFallback, 6);
        return;
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
}
