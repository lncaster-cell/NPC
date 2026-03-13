// Ambient Life route cache helpers (extracted from al_route_inc).

const int AL_ROUTE_REBUILD_FAIL_COOLDOWN_TICKS = 2;

string AL_RouteAreaCacheStepsKey(string sRouteTag) { return "al_route_area_steps_" + sRouteTag; }
string AL_RouteAreaCacheTickKey(string sRouteTag) { return "al_route_area_tick_" + sRouteTag; }
string AL_RouteAreaStepKey(string sRouteTag, int nIdx) { return "al_route_area_step_" + sRouteTag + "_" + IntToString(nIdx); }
string AL_RouteAreaRebuildCooldownUntilKey(string sRouteTag) { return "al_route_area_rebuild_cooldown_until_" + sRouteTag; }
string AL_RouteAreaFingerprintKey(string sRouteTag) { return "al_route_area_fingerprint_" + sRouteTag; }
string AL_RouteAreaContentVersionKey(string sRouteTag) { return "al_route_area_content_ver_" + sRouteTag; }
string AL_RouteAreaCandidateCountKey(string sRouteTag) { return "al_route_area_candidate_count_" + sRouteTag; }
string AL_RouteAreaFingerprintTickKey(string sRouteTag) { return "al_route_fp_tick_" + sRouteTag; }
string AL_RouteAreaFingerprintValueKey(string sRouteTag) { return "al_route_fp_value_" + sRouteTag; }

string AL_RouteAreaFailTickKey(string sRouteTag) { return "al_route_area_fail_tick_" + sRouteTag; }
string AL_RouteAreaPendingKey(string sRouteTag) { return "al_route_area_pending_" + sRouteTag; }

int AL_RouteCanRebuildThisTick(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    if (nSyncTick <= 0)
    {
        return TRUE;
    }

    return GetLocalInt(oArea, "al_route_rebuild_sync_tick") != nSyncTick;
}

void AL_RouteMarkAreaPending(object oArea, string sRouteTag)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return;
    }

    if (GetLocalInt(oArea, AL_RouteAreaPendingKey(sRouteTag)) == TRUE)
    {
        return;
    }

    SetLocalInt(oArea, AL_RouteAreaPendingKey(sRouteTag), TRUE);
    SetLocalInt(oArea, "al_route_pending_rebuild", TRUE);
    SetLocalInt(oArea, "al_route_pending_count", GetLocalInt(oArea, "al_route_pending_count") + 1);
}

void AL_RouteClearAreaPending(object oArea, string sRouteTag)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return;
    }

    if (GetLocalInt(oArea, AL_RouteAreaPendingKey(sRouteTag)) != TRUE)
    {
        return;
    }

    DeleteLocalInt(oArea, AL_RouteAreaPendingKey(sRouteTag));

    int nPending = GetLocalInt(oArea, "al_route_pending_count") - 1;
    if (nPending < 0)
    {
        nPending = 0;
    }

    SetLocalInt(oArea, "al_route_pending_count", nPending);
    SetLocalInt(oArea, "al_route_pending_rebuild", nPending > 0);
}

int AL_RouteAreaCacheStepsValid(object oArea, string sRouteTag)
{
    int nSteps = GetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag));
    if (nSteps <= 0)
    {
        return FALSE;
    }

    int i = 0;
    while (i < nSteps)
    {
        object oStep = GetLocalObject(oArea, AL_RouteAreaStepKey(sRouteTag, i));
        if (!GetIsObjectValid(oStep) || GetObjectType(oStep) != OBJECT_TYPE_WAYPOINT || GetArea(oStep) != oArea)
        {
            return FALSE;
        }

        i = i + 1;
    }

    return TRUE;
}

int AL_RouteHashMix(int nHash, int nValue)
{
    int nMod = 1000003;
    int nMixed = ((nHash * 131) % nMod + (nValue % nMod)) % nMod;
    if (nMixed < 0)
    {
        nMixed = nMixed + nMod;
    }

    return nMixed;
}

int AL_RouteHashString(int nHash, string sValue)
{
    int nLen = GetStringLength(sValue);
    int i = 0;
    while (i < nLen)
    {
        string sChar = GetSubString(sValue, i, 1);
        int nCode = FindSubString("0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_-:.", sChar);
        if (nCode < 0)
        {
            nCode = 0;
        }

        nHash = AL_RouteHashMix(nHash, nCode + 1);
        i = i + 1;
    }

    return AL_RouteHashMix(nHash, nLen + 17);
}

int AL_ComputeRouteFingerprintFromCandidates(object oArea, string sRouteTag, int nCandidateCount)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return 0;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");

    int nFingerprint = AL_RouteHashString(23, sRouteTag);
    nFingerprint = AL_RouteHashMix(nFingerprint, nCandidateCount + 29);

    int nCandidateIdx = 0;
    while (nCandidateIdx < nCandidateCount)
    {
        object oWp = AL_GetWaypointCandidateCachedFast(oArea, sRouteTag, nCandidateIdx);
        nCandidateIdx = nCandidateIdx + 1;
        if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT || GetArea(oWp) != oArea)
        {
            continue;
        }

        nFingerprint = AL_RouteHashString(nFingerprint, GetTag(oWp));
        nFingerprint = AL_RouteHashMix(nFingerprint, GetLocalInt(oWp, "al_step") + 37);
        nFingerprint = AL_RouteHashMix(nFingerprint, GetLocalInt(oWp, "al_activity") + 41);
        nFingerprint = AL_RouteHashMix(nFingerprint, GetLocalInt(oWp, "al_dur_sec") + 43);

        int nTransitionType = GetLocalInt(oWp, "al_trans_type");
        nFingerprint = AL_RouteHashMix(nFingerprint, nTransitionType + 47);
        nFingerprint = AL_RouteHashString(nFingerprint, GetLocalString(oWp, "al_trans_src_wp"));
        nFingerprint = AL_RouteHashString(nFingerprint, GetLocalString(oWp, "al_trans_dst_wp"));

        nFingerprint = AL_RouteHashString(nFingerprint, GetLocalString(oWp, "al_bed_id"));
    }

    if (nSyncTick > 0)
    {
        SetLocalInt(oArea, AL_RouteAreaFingerprintTickKey(sRouteTag), nSyncTick);
        SetLocalInt(oArea, AL_RouteAreaFingerprintValueKey(sRouteTag), nFingerprint);
    }

    return nFingerprint;
}

int AL_RouteBuildFingerprint(object oArea, string sRouteTag)
{
    int nCandidateCount = AL_GetWaypointCandidatesCountCached(oArea, sRouteTag);
    return AL_ComputeRouteFingerprintFromCandidates(oArea, sRouteTag, nCandidateCount);
}

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

    int bHadCache = GetLocalInt(oNpc, "al_route_cache_valid") || nCachedSteps > 0;

    DeleteLocalString(oNpc, "al_route_cache_tag");
    DeleteLocalInt(oNpc, "al_route_cache_fingerprint");
    DeleteLocalObject(oNpc, "al_route_cache_area");
    SetLocalInt(oNpc, "al_route_cache_slot", -1);
    SetLocalInt(oNpc, "al_route_cache_steps", 0);
    SetLocalInt(oNpc, "al_route_cache_valid", FALSE);
    if (bHadCache)
    {
        SetLocalInt(oNpc, "route_cache_invalidations", GetLocalInt(oNpc, "route_cache_invalidations") + 1);
    }
}

void AL_RouteInvalidateAreaCache(object oArea, string sRouteTag)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return;
    }

    int nSteps = GetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag));
    int bHadCache = nSteps > 0 || GetLocalInt(oArea, AL_RouteAreaFingerprintKey(sRouteTag)) != 0;
    int i = 0;
    while (i < nSteps)
    {
        DeleteLocalObject(oArea, AL_RouteAreaStepKey(sRouteTag, i));
        i = i + 1;
    }

    SetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag), 0);
    SetLocalInt(oArea, AL_RouteAreaCacheTickKey(sRouteTag), 0);
    SetLocalInt(oArea, AL_RouteAreaRebuildCooldownUntilKey(sRouteTag), 0);
    DeleteLocalInt(oArea, AL_RouteAreaFingerprintKey(sRouteTag));
    DeleteLocalInt(oArea, AL_RouteAreaFingerprintTickKey(sRouteTag));
    DeleteLocalInt(oArea, AL_RouteAreaFingerprintValueKey(sRouteTag));
    DeleteLocalInt(oArea, AL_RouteAreaContentVersionKey(sRouteTag));
    DeleteLocalInt(oArea, AL_RouteAreaCandidateCountKey(sRouteTag));
    DeleteLocalInt(oArea, AL_RouteAreaFailTickKey(sRouteTag));
    if (bHadCache)
    {
        SetLocalInt(oArea, "route_cache_invalidations", GetLocalInt(oArea, "route_cache_invalidations") + 1);
    }
    AL_LookupSoftInvalidateAreaCache(oArea, AL_LOOKUP_INVALIDATE_REASON_ROUTE, sRouteTag);
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
        object oWp = AL_GetWaypointCandidateCachedFast(oArea, sRouteTag, nCandidateIdx);
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

    int nContentVersion = GetLocalInt(oArea, "al_content_version");
    if (nContentVersion <= 0)
    {
        nContentVersion = GetLocalInt(oArea, "al_area_content_version");
    }

    SetLocalInt(oArea, AL_RouteAreaCacheStepsKey(sRouteTag), nFound);
    SetLocalInt(oArea, AL_RouteAreaCacheTickKey(sRouteTag), GetLocalInt(oArea, "al_sync_tick"));
    SetLocalInt(oArea, AL_RouteAreaFingerprintKey(sRouteTag), AL_ComputeRouteFingerprintFromCandidates(oArea, sRouteTag, nCandidateCount));
    SetLocalInt(oArea, AL_RouteAreaContentVersionKey(sRouteTag), nContentVersion);
    SetLocalInt(oArea, AL_RouteAreaCandidateCountKey(sRouteTag), nCandidateCount);
    DeleteLocalString(oArea, "al_route_fail_reason");
    return TRUE;
}


int AL_RebuildRouteAreaCacheByTag(object oArea, string sRouteTag)
{
    return AL_RouteBuildAreaCache(oArea, sRouteTag);
}

int AL_RouteEnsureAreaCache(object oArea, string sRouteTag, int bForceRebuild)
{
    if (!GetIsObjectValid(oArea) || sRouteTag == "")
    {
        return FALSE;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    int bCacheValid = AL_RouteAreaCacheStepsValid(oArea, sRouteTag);
    int nContentVersion = GetLocalInt(oArea, "al_content_version");
    if (nContentVersion <= 0)
    {
        nContentVersion = GetLocalInt(oArea, "al_area_content_version");
    }

    int nCandidateCount = AL_GetWaypointCandidatesCountCached(oArea, sRouteTag);
    int nLastContentVersion = GetLocalInt(oArea, AL_RouteAreaContentVersionKey(sRouteTag));
    int nLastCandidateCount = GetLocalInt(oArea, AL_RouteAreaCandidateCountKey(sRouteTag));
    int bTriggersChanged = (nContentVersion != nLastContentVersion) || (nCandidateCount != nLastCandidateCount);

    if (bCacheValid && !bTriggersChanged)
    {
        if (bForceRebuild)
        {
            SetLocalInt(oArea, "route_cache_hits", GetLocalInt(oArea, "route_cache_hits") + 1);
        }

        AL_RouteClearAreaPending(oArea, sRouteTag);
        return TRUE;
    }

    if (bCacheValid && bTriggersChanged)
    {
        SetLocalInt(oArea, "route_cache_full_rehashes", GetLocalInt(oArea, "route_cache_full_rehashes") + 1);
        int nCurrentFingerprint = AL_ComputeRouteFingerprintFromCandidates(oArea, sRouteTag, nCandidateCount);
        int nCachedFingerprint = GetLocalInt(oArea, AL_RouteAreaFingerprintKey(sRouteTag));
        if (nCurrentFingerprint != 0 && nCurrentFingerprint == nCachedFingerprint)
        {
            SetLocalInt(oArea, AL_RouteAreaContentVersionKey(sRouteTag), nContentVersion);
            SetLocalInt(oArea, AL_RouteAreaCandidateCountKey(sRouteTag), nCandidateCount);
            if (bForceRebuild)
            {
                SetLocalInt(oArea, "route_cache_hits", GetLocalInt(oArea, "route_cache_hits") + 1);
            }

            AL_RouteClearAreaPending(oArea, sRouteTag);
            return TRUE;
        }
    }

    if (!bForceRebuild)
    {
        int nCooldownUntil = GetLocalInt(oArea, AL_RouteAreaRebuildCooldownUntilKey(sRouteTag));
        if (nCooldownUntil > 0 && nSyncTick < nCooldownUntil)
        {
            return FALSE;
        }

        if (bCacheValid)
        {
            AL_RouteClearAreaPending(oArea, sRouteTag);
            return TRUE;
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

    SetLocalInt(oArea, "route_cache_rebuilds", GetLocalInt(oArea, "route_cache_rebuilds") + 1);
    SetLocalInt(oArea, "al_route_rebuild_sync_tick", nSyncTick);
    int bBuilt = AL_RouteBuildAreaCache(oArea, sRouteTag);
    if (!bBuilt && !bForceRebuild)
    {
        SetLocalInt(
            oArea,
            AL_RouteAreaRebuildCooldownUntilKey(sRouteTag),
            nSyncTick + AL_ROUTE_REBUILD_COOLDOWN_TICKS
        );
        SetLocalInt(oArea, AL_RouteAreaFailTickKey(sRouteTag), nSyncTick);
    }

    return bBuilt;
}
