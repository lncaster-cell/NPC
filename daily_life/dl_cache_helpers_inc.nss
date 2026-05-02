const string DL_L_MODULE_CACHE_METRIC_PREFIX = "dl_metric_cache_";
const string DL_L_CACHE_CTX_PREFIX = "dl_cache_ctx_";

const int DL_TAG_ENUM_DEFAULT_CAP = 32;

int DL_GetSafeTagSearchCap(int nRequestedCap)
{
    if (nRequestedCap <= 0)
    {
        return DL_TAG_ENUM_DEFAULT_CAP;
    }

    return nRequestedCap;
}

object DL_FindObjectByTagWithChecks(
    string sTag,
    int nSearchCap,
    int nObjectType,
    object oArea,
    object oExclude,
    int bRequireActivePipelineNpc
)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    int nCap = DL_GetSafeTagSearchCap(nSearchCap);
    int nNth = 0;
    while (nNth < nCap)
    {
        object oCandidate = GetObjectByTag(sTag, nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetIsObjectValid(oExclude) && oCandidate == oExclude)
        {
            nNth = nNth + 1;
            continue;
        }

        if (nObjectType >= 0 && GetObjectType(oCandidate) != nObjectType)
        {
            nNth = nNth + 1;
            continue;
        }

        if (GetIsObjectValid(oArea) && GetArea(oCandidate) != oArea)
        {
            nNth = nNth + 1;
            continue;
        }

        if (bRequireActivePipelineNpc && !DL_IsActivePipelineNpc(oCandidate))
        {
            nNth = nNth + 1;
            continue;
        }

        return oCandidate;
    }

    return OBJECT_INVALID;
}



string DL_GetCacheMetricKey(string sScope, string sMetric)
{
    return DL_L_MODULE_CACHE_METRIC_PREFIX + sScope + "_" + sMetric;
}

void DL_RecordCacheMetric(object oArea, string sScope, int bHit)
{
    object oModule = GetModule();
    string sMetric = bHit ? "hit" : "miss";
    SetLocalInt(oModule, DL_GetCacheMetricKey("module_" + sScope, sMetric), GetLocalInt(oModule, DL_GetCacheMetricKey("module_" + sScope, sMetric)) + 1);

    if (GetIsObjectValid(oArea))
    {
        SetLocalInt(oArea, DL_GetCacheMetricKey("area_" + sScope, sMetric), GetLocalInt(oArea, DL_GetCacheMetricKey("area_" + sScope, sMetric)) + 1);
    }
}

int DL_IsCachedObjectValidForTagInArea(object oCached, string sTag, int nObjectType, object oArea)
{
    return GetIsObjectValid(oCached) &&
        GetTag(oCached) == sTag &&
        GetObjectType(oCached) == nObjectType &&
        GetArea(oCached) == oArea;
}

string DL_GetCachedObjectContextKey(string sCacheLocal, string sSuffix)
{
    return DL_L_CACHE_CTX_PREFIX + sCacheLocal + "_" + sSuffix;
}

void DL_SetCachedObject(object oOwner, string sCacheLocal, object oValue, string sTag, int nObjectType, object oArea, int nTier, int nLifecycleSeq)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return;
    }

    if (!GetIsObjectValid(oValue))
    {
        DL_InvalidateCachedObject(oOwner, sCacheLocal);
        return;
    }

    SetLocalObject(oOwner, sCacheLocal, oValue);
    SetLocalString(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tag"), sTag);
    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "type"), nObjectType);
    SetLocalObject(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "area"), oArea);
    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tier"), nTier);
    SetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "life"), nLifecycleSeq);
}

void DL_InvalidateCachedObject(object oOwner, string sCacheLocal)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return;
    }

    DeleteLocalObject(oOwner, sCacheLocal);
    DeleteLocalString(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tag"));
    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "type"));
    DeleteLocalObject(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "area"));
    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tier"));
    DeleteLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "life"));
}

int DL_IsCachedObjectValid(object oOwner, string sCacheLocal, string sExpectedTag, int nExpectedObjectType, object oExpectedArea, int nExpectedTier, int nExpectedLifecycleSeq)
{
    if (!GetIsObjectValid(oOwner) || sCacheLocal == "")
    {
        return FALSE;
    }

    object oCached = GetLocalObject(oOwner, sCacheLocal);
    if (!GetIsObjectValid(oCached))
    {
        return FALSE;
    }

    if (GetLocalString(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tag")) != sExpectedTag) return FALSE;
    if (GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "type")) != nExpectedObjectType) return FALSE;
    if (GetLocalObject(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "area")) != oExpectedArea) return FALSE;
    if (GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "tier")) != nExpectedTier) return FALSE;
    if (GetLocalInt(oOwner, DL_GetCachedObjectContextKey(sCacheLocal, "life")) != nExpectedLifecycleSeq) return FALSE;

    return GetTag(oCached) == sExpectedTag && GetObjectType(oCached) == nExpectedObjectType && GetArea(oCached) == oExpectedArea;
}

object DL_GetCachedObject(object oOwner, string sCacheLocal, string sExpectedTag, int nExpectedObjectType, object oExpectedArea, int nExpectedTier, int nExpectedLifecycleSeq)
{
    if (!DL_IsCachedObjectValid(oOwner, sCacheLocal, sExpectedTag, nExpectedObjectType, oExpectedArea, nExpectedTier, nExpectedLifecycleSeq))
    {
        return OBJECT_INVALID;
    }

    return GetLocalObject(oOwner, sCacheLocal);
}

object DL_FindObjectByTagInAreaDeterministic(string sTag, int nObjectType, object oArea, int nSearchCap)
{
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    return DL_FindObjectByTagWithChecks(sTag, nSearchCap, nObjectType, oArea, OBJECT_INVALID, FALSE);
}
