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

string AL_RouteAreaCacheStepsKey(string sRouteTag) { return "al_route_area_steps_" + sRouteTag; }
string AL_RouteAreaCacheTickKey(string sRouteTag) { return "al_route_area_tick_" + sRouteTag; }
string AL_RouteAreaStepKey(string sRouteTag, int nIdx) { return "al_route_area_step_" + sRouteTag + "_" + IntToString(nIdx); }
string AL_RouteAreaRebuildCooldownUntilKey(string sRouteTag) { return "al_route_area_rebuild_cooldown_until_" + sRouteTag; }

void AL_RouteBlockedRuntimeReset(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, "al_blocked_rt_active", FALSE);
    SetLocalInt(oNpc, "al_blocked_rt_retry", 0);
}

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

    string sTag = GetLocalString(oNpc, "alwp" + IntToString(nSlot));
    if (sTag != "")
    {
        return sTag;
    }

    return GetLocalString(oNpc, "AL_WP_S" + IntToString(nSlot));
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

void AL_RouteInvalidateAreaCache(object oArea, string sRouteTag)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return;
    }

    int nSteps = GetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag));
    int i = 0;
    while (i < nSteps)
    {
        DeleteLocalObject(oArea, AL_RouteAreaStepKey(sRouteTag, i));
        i = i + 1;
    }

    SetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag), 0);
    SetLocalInt(oArea, AL_RouteAreaCacheTickKey(sRouteTag), 0);
    SetLocalInt(oArea, AL_RouteAreaRebuildCooldownUntilKey(sRouteTag), 0);
    AL_LookupSoftInvalidateAreaCache(oArea);
}

int AL_RouteBuildAreaCache(object oArea, string sRouteTag)
{
    AL_RouteInvalidateAreaCache(oArea, sRouteTag);

    DeleteLocalString(oArea, "al_route_fail_reason");
    SetLocalInt(oArea, "al_route_invalid_step_count", 0);
    SetLocalInt(oArea, "al_route_duplicate_step_count", 0);

    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return FALSE;
    }

    object aoStepRefs[AL_ROUTE_MAX_STEPS];
    int anStepOccupied[AL_ROUTE_MAX_STEPS];
    int nFound = 0;
    int nValidCandidates = 0;
    int nOverflowCandidates = 0;
    int nInvalidStepCandidates = 0;
    int nDuplicateStepCandidates = 0;
    int nCandidateCount = AL_GetWaypointCandidatesCountCached(oArea, sRouteTag);
    int nCandidateIdx = 0;

    while (nCandidateIdx < nCandidateCount)
    {
        object oWp = AL_GetWaypointCandidateCached(oArea, sRouteTag, nCandidateIdx);
        nCandidateIdx = nCandidateIdx + 1;
        if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT || GetArea(oWp) != oArea)
        {
            continue;
        }

        int nStep = GetLocalInt(oWp, "al_step");
        if (nStep < 0 || nStep >= AL_ROUTE_MAX_STEPS)
        {
            nInvalidStepCandidates = nInvalidStepCandidates + 1;
            continue;
        }

        nValidCandidates = nValidCandidates + 1;

        if (anStepOccupied[nStep])
        {
            nDuplicateStepCandidates = nDuplicateStepCandidates + 1;
            continue;
        }

        if (nFound >= AL_ROUTE_MAX_STEPS)
        {
            nOverflowCandidates = nOverflowCandidates + 1;
            continue;
        }

        anStepOccupied[nStep] = TRUE;
        aoStepRefs[nStep] = oWp;
        nFound = nFound + 1;

    }

    SetLocalInt(oArea, "al_route_invalid_step_count", nInvalidStepCandidates);
    SetLocalInt(oArea, "al_route_duplicate_step_count", nDuplicateStepCandidates);

    string sRejectDiag = "";
    if (nInvalidStepCandidates > 0)
    {
        sRejectDiag = sRejectDiag + "invalid_step=" + IntToString(nInvalidStepCandidates);
    }

    if (nDuplicateStepCandidates > 0)
    {
        if (sRejectDiag != "")
        {
            sRejectDiag = sRejectDiag + ";";
        }

        sRejectDiag = sRejectDiag + "duplicate_step=" + IntToString(nDuplicateStepCandidates);
    }

    if (nOverflowCandidates > 0)
    {
        SetLocalInt(oArea, "al_route_overflow_count", GetLocalInt(oArea, "al_route_overflow_count") + 1);
        SetLocalString(oArea, "al_route_overflow_tag", sRouteTag);

        string sFailReason = "overflow";
        if (sRejectDiag != "")
        {
            sFailReason = sFailReason + ";" + sRejectDiag;
        }

        SetLocalString(oArea, "al_route_fail_reason", sFailReason);

        if (GetLocalInt(oArea, "al_debug") > 0)
        {
            WriteTimestampedLogEntry(
                "[AL][RouteOverflow] area=" + GetTag(oArea)
                + " route_tag=" + sRouteTag
                + " valid_candidates=" + IntToString(nValidCandidates)
                + " unique_overflow=" + IntToString(nOverflowCandidates)
                + " max_steps=" + IntToString(AL_ROUTE_MAX_STEPS)
            );
        }

        AL_RouteInvalidateAreaCache(oArea, sRouteTag);
        return FALSE;
    }

    if (nFound <= 0)
    {
        string sFailReason = "empty";
        if (sRejectDiag != "")
        {
            sFailReason = sFailReason + ";" + sRejectDiag;
        }

        SetLocalString(oArea, "al_route_fail_reason", sFailReason);
        return FALSE;
    }

    if (!anStepOccupied[0])
    {
        string sFailReason = "missing_step_0";
        if (sRejectDiag != "")
        {
            sFailReason = sFailReason + ";" + sRejectDiag;
        }

        SetLocalString(oArea, "al_route_fail_reason", sFailReason);
        AL_RouteInvalidateAreaCache(oArea, sRouteTag);
        return FALSE;
    }

    int iCheck = 0;
    while (iCheck < nFound)
    {
        if (!anStepOccupied[iCheck])
        {
            string sFailReason = "non_contiguous";
            if (sRejectDiag != "")
            {
                sFailReason = sFailReason + ";" + sRejectDiag;
            }

            SetLocalString(oArea, "al_route_fail_reason", sFailReason);
            AL_RouteInvalidateAreaCache(oArea, sRouteTag);
            return FALSE;
        }

        SetLocalObject(oArea, AL_RouteAreaStepKey(sRouteTag, iCheck), aoStepRefs[iCheck]);
        iCheck = iCheck + 1;
    }

    SetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag), nFound);
    SetLocalInt(oArea, AL_RouteAreaCacheTickKey(sRouteTag), GetLocalInt(oArea, "al_sync_tick"));
    DeleteLocalString(oArea, "al_route_fail_reason");
    return TRUE;
}

int AL_RouteEnsureAreaCache(object oArea, string sRouteTag, int bForceRebuild)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return FALSE;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");

    if (!bForceRebuild)
    {
        int nCooldownUntil = GetLocalInt(oArea, AL_RouteAreaRebuildCooldownUntilKey(sRouteTag));
        int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
        if (nCooldownUntil > 0 && nSyncTick < nCooldownUntil)
        {
            return FALSE;
        }

        int nSteps = GetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag));
        if (nSteps > 0)
        {
            int i = 0;
            while (i < nSteps)
            {
                object oStep = GetLocalObject(oArea, AL_RouteAreaStepKey(sRouteTag, i));
                if (!GetIsObjectValid(oStep) || GetObjectType(oStep) != OBJECT_TYPE_WAYPOINT || GetArea(oStep) != oArea)
                {
                    break;
                }

                i = i + 1;
            }

            if (i == nSteps)
            {
                AL_RouteClearAreaPending(oArea, sRouteTag);
                return TRUE;
            }
        }

        int nLastFailTick = GetLocalInt(oArea, AL_RouteAreaFailTickKey(sRouteTag));
        if (nLastFailTick > 0 && nSyncTick > 0 && (nSyncTick - nLastFailTick) < AL_ROUTE_REBUILD_FAIL_COOLDOWN_TICKS)
        {
            return FALSE;
        }

        if (!AL_RouteCanRebuildThisTick(oArea))
        {
            AL_RouteMarkAreaPending(oArea, sRouteTag);
            SetLocalString(oArea, "al_route_fail_reason", "budget_deferred");
            return FALSE;
        }
    }

    int bBuilt = AL_RouteBuildAreaCache(oArea, sRouteTag);
    if (!bBuilt && !bForceRebuild)
    {
        int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
        SetLocalInt(
            oArea,
            AL_RouteAreaRebuildCooldownUntilKey(sRouteTag),
            nSyncTick + AL_ROUTE_REBUILD_COOLDOWN_TICKS
        );
    }

    return bBuilt;
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

    object oCurrentArea = GetArea(oNpc);
    if (!GetIsObjectValid(oCurrentArea))
    {
        return FALSE;
    }

    if (!AL_RouteEnsureAreaCache(oCurrentArea, sRouteTag, bForceRebuild))
    {
        AL_RouteInvalidateCache(oNpc);
        return FALSE;
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
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    SetLocalInt(oNpc, AL_RouteRtIdxKey(), nStepIdx);
    SetLocalInt(oNpc, AL_RouteRtActiveKey(), TRUE);

    return TRUE;
}

int AL_RouteRoutineResumeCurrent(object oNpc)
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

    int nCurrent = GetLocalInt(oNpc, AL_RouteRtIdxKey());
    return AL_RouteQueueStep(oNpc, nCurrent);
}

void AL_RouteResyncCurrentArea(object oNpc, int nSlot)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc))
    {
        return;
    }

    AL_RouteInvalidateCache(oNpc);
    AL_RouteRoutineStart(oNpc, nSlot, TRUE);
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
