// Ambient Life route cache helpers (extracted from al_route_inc).

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
