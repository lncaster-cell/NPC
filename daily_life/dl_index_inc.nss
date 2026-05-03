const string DL_L_AREA_INDEX_RUNTIME_SEQ = "dl_idx_runtime_seq";
const string DL_L_AREA_INDEX_BUILT_SEQ = "dl_idx_built_seq";
const string DL_L_AREA_INDEX_NPC_COUNT = "dl_idx_npc_count";
const string DL_L_AREA_INDEX_WP_COUNT = "dl_idx_wp_count";
const string DL_L_AREA_INDEX_WP_PREFIX = "dl_idx_wp_tag_";

void DL_InvalidateAreaIndex(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }
    SetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ, GetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ) + 1);
}

string DL_GetAreaIndexWpSlotKey(string sTag)
{
    return DL_L_AREA_INDEX_WP_PREFIX + sTag;
}

void DL_RebuildAreaIndex(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    object oObj = GetFirstObjectInArea(oArea);
    int nNpcCount = 0;
    while (GetIsObjectValid(oObj))
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_CREATURE && DL_IsActivePipelineNpc(oObj))
        {
            nNpcCount = nNpcCount + 1;
        }
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT)
        {
            string sTag = GetTag(oObj);
            if (sTag != "" && !GetIsObjectValid(GetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag))))
            {
                SetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag), oObj);
            }
        }
        oObj = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, DL_L_AREA_INDEX_NPC_COUNT, nNpcCount);
    SetLocalInt(oArea, DL_L_AREA_INDEX_BUILT_SEQ, GetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ));
}

void DL_EnsureAreaIndexBuilt(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, DL_L_AREA_INDEX_BUILT_SEQ) != GetLocalInt(oArea, DL_L_AREA_INDEX_RUNTIME_SEQ))
    {
        DL_RebuildAreaIndex(oArea);
    }
}

object DL_IndexGetWaypointByTag(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    DL_EnsureAreaIndexBuilt(oArea);
    object oWp = GetLocalObject(oArea, DL_GetAreaIndexWpSlotKey(sTag));
    if (GetIsObjectValid(oWp) && GetObjectType(oWp) == OBJECT_TYPE_WAYPOINT && GetArea(oWp) == oArea && GetTag(oWp) == sTag)
    {
        DL_RecordCacheMetricBatch(oArea, "index", 1, 0);
        return oWp;
    }

    DL_RecordCacheMetricBatch(oArea, "index", 0, 1);
    return OBJECT_INVALID;
}
