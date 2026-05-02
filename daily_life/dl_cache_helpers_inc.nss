const string DL_L_MODULE_CACHE_METRIC_PREFIX = "dl_metric_cache_";

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

object DL_FindObjectByTagInAreaDeterministic(string sTag, int nObjectType, object oArea, int nSearchCap)
{
    if (sTag == "" || !GetIsObjectValid(oArea) || nSearchCap <= 0)
    {
        return OBJECT_INVALID;
    }

    int nNth = 0;
    while (nNth < nSearchCap)
    {
        object oCandidate = GetObjectByTag(sTag, nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetObjectType(oCandidate) == nObjectType && GetArea(oCandidate) == oArea)
        {
            return oCandidate;
        }

        nNth = nNth + 1;
    }

    return OBJECT_INVALID;
}
