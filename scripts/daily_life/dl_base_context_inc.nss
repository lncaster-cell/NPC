#ifndef DL_BASE_CONTEXT_INC_NSS
#define DL_BASE_CONTEXT_INC_NSS

#include "dl_const_inc"
#include "dl_log_inc"
#include "dl_util_inc"

const string DL_L_BASE_ID = "dl_base_id";
const string DL_L_BASE_KIND = "dl_base_kind";
const string DL_L_BASE_EXTERIOR_AREA_TAG = "dl_base_exterior_area_tag";
const string DL_L_BASE_INTERIOR_AREA_TAG = "dl_base_interior_area_tag";
const string DL_L_BASE_ENTRY_EXTERIOR_TAG = "dl_base_entry_exterior_tag";
const string DL_L_BASE_ENTRY_INTERIOR_TAG = "dl_base_entry_interior_tag";
const string DL_L_BASE_WORK_AREA_TAG = "dl_base_work_area_tag";
const string DL_L_BASE_WORK_ANCHOR_TAG = "dl_base_work_anchor_tag";
const string DL_L_BASE_SLEEP_AREA_TAG = "dl_base_sleep_area_tag";
const string DL_L_BASE_SLEEP_ANCHOR_TAG = "dl_base_sleep_anchor_tag";
const string DL_L_BASE_SERVICE_AREA_TAG = "dl_base_service_area_tag";
const string DL_L_BASE_SERVICE_ANCHOR_TAG = "dl_base_service_anchor_tag";
const string DL_L_BASE_SOCIAL_AREA_TAG = "dl_base_social_area_tag";
const string DL_L_BASE_SOCIAL_ANCHOR_TAG = "dl_base_social_anchor_tag";
const string DL_L_BASE_PUBLIC_AREA_TAG = "dl_base_public_area_tag";
const string DL_L_BASE_PUBLIC_ANCHOR_TAG = "dl_base_public_anchor_tag";
const string DL_L_BASE_DUTY_AREA_TAG = "dl_base_duty_area_tag";
const string DL_L_BASE_DUTY_ANCHOR_TAG = "dl_base_duty_anchor_tag";
const string DL_L_BASE_GATE_AREA_TAG = "dl_base_gate_area_tag";
const string DL_L_BASE_GATE_ANCHOR_TAG = "dl_base_gate_anchor_tag";
const string DL_L_BASE_HIDE_AREA_TAG = "dl_base_hide_area_tag";
const string DL_L_BASE_HIDE_ANCHOR_TAG = "dl_base_hide_anchor_tag";

object DL_FindAreaByTag(string sAreaTag)
{
    int nIndex = 0;
    object oArea;

    if (sAreaTag == "")
    {
        return OBJECT_INVALID;
    }

    oArea = GetObjectByTag(sAreaTag, nIndex);
    while (GetIsObjectValid(oArea))
    {
        if (GetObjectType(oArea) == OBJECT_TYPE_AREA)
        {
            return oArea;
        }
        nIndex += 1;
        oArea = GetObjectByTag(sAreaTag, nIndex);
    }

    return OBJECT_INVALID;
}

string DL_GetBaseMappedAreaTag(object oBase, int nDirective, int nAnchorGroup)
{
    if (!GetIsObjectValid(oBase))
    {
        return "";
    }

    if (nAnchorGroup == DL_AG_GATE)
    {
        return GetLocalString(oBase, DL_L_BASE_GATE_AREA_TAG);
    }
    if (nAnchorGroup == DL_AG_DUTY || nAnchorGroup == DL_AG_PATROL_POINT)
    {
        return GetLocalString(oBase, DL_L_BASE_DUTY_AREA_TAG);
    }
    if (nDirective == DL_DIR_WORK)
    {
        return GetLocalString(oBase, DL_L_BASE_WORK_AREA_TAG);
    }
    if (nDirective == DL_DIR_SLEEP)
    {
        return GetLocalString(oBase, DL_L_BASE_SLEEP_AREA_TAG);
    }
    if (nDirective == DL_DIR_SERVICE)
    {
        return GetLocalString(oBase, DL_L_BASE_SERVICE_AREA_TAG);
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oBase, DL_L_BASE_SOCIAL_AREA_TAG);
    }
    if (nDirective == DL_DIR_PUBLIC_PRESENCE)
    {
        return GetLocalString(oBase, DL_L_BASE_PUBLIC_AREA_TAG);
    }
    if (nDirective == DL_DIR_LOCKDOWN_BASE || nDirective == DL_DIR_HIDE_SAFE)
    {
        return GetLocalString(oBase, DL_L_BASE_HIDE_AREA_TAG);
    }

    return "";
}

string DL_GetBaseMappedAnchorTag(object oBase, int nDirective, int nAnchorGroup)
{
    if (!GetIsObjectValid(oBase))
    {
        return "";
    }

    if (nAnchorGroup == DL_AG_GATE)
    {
        return GetLocalString(oBase, DL_L_BASE_GATE_ANCHOR_TAG);
    }
    if (nAnchorGroup == DL_AG_DUTY || nAnchorGroup == DL_AG_PATROL_POINT)
    {
        return GetLocalString(oBase, DL_L_BASE_DUTY_ANCHOR_TAG);
    }
    if (nDirective == DL_DIR_WORK)
    {
        return GetLocalString(oBase, DL_L_BASE_WORK_ANCHOR_TAG);
    }
    if (nDirective == DL_DIR_SLEEP)
    {
        return GetLocalString(oBase, DL_L_BASE_SLEEP_ANCHOR_TAG);
    }
    if (nDirective == DL_DIR_SERVICE)
    {
        return GetLocalString(oBase, DL_L_BASE_SERVICE_ANCHOR_TAG);
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oBase, DL_L_BASE_SOCIAL_ANCHOR_TAG);
    }
    if (nDirective == DL_DIR_PUBLIC_PRESENCE)
    {
        return GetLocalString(oBase, DL_L_BASE_PUBLIC_ANCHOR_TAG);
    }
    if (nDirective == DL_DIR_LOCKDOWN_BASE || nDirective == DL_DIR_HIDE_SAFE)
    {
        return GetLocalString(oBase, DL_L_BASE_HIDE_ANCHOR_TAG);
    }

    return "";
}

string DL_GetDefaultBaseAreaTag(object oBase, int nDirective, int nAnchorGroup)
{
    string sExteriorAreaTag;
    string sInteriorAreaTag;

    if (!GetIsObjectValid(oBase))
    {
        return "";
    }

    sExteriorAreaTag = GetLocalString(oBase, DL_L_BASE_EXTERIOR_AREA_TAG);
    sInteriorAreaTag = GetLocalString(oBase, DL_L_BASE_INTERIOR_AREA_TAG);

    if (nAnchorGroup == DL_AG_GATE || nAnchorGroup == DL_AG_DUTY || nAnchorGroup == DL_AG_PATROL_POINT || nAnchorGroup == DL_AG_STREET_NEAR_BASE)
    {
        return sExteriorAreaTag;
    }
    if (nDirective == DL_DIR_PUBLIC_PRESENCE)
    {
        return sExteriorAreaTag;
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        if (sExteriorAreaTag != "")
        {
            return sExteriorAreaTag;
        }
        return sInteriorAreaTag;
    }
    if (nDirective == DL_DIR_WORK || nDirective == DL_DIR_SLEEP || nDirective == DL_DIR_SERVICE || nDirective == DL_DIR_LOCKDOWN_BASE || nDirective == DL_DIR_HIDE_SAFE)
    {
        if (sInteriorAreaTag != "")
        {
            return sInteriorAreaTag;
        }
        return sExteriorAreaTag;
    }

    if (sExteriorAreaTag != "")
    {
        return sExteriorAreaTag;
    }
    return sInteriorAreaTag;
}

string DL_GetDefaultBaseAnchorTag(object oBase, int nDirective, int nAnchorGroup)
{
    if (!GetIsObjectValid(oBase))
    {
        return "";
    }

    if (nAnchorGroup == DL_AG_GATE || nAnchorGroup == DL_AG_DUTY || nAnchorGroup == DL_AG_PATROL_POINT || nAnchorGroup == DL_AG_STREET_NEAR_BASE || nDirective == DL_DIR_PUBLIC_PRESENCE)
    {
        return GetLocalString(oBase, DL_L_BASE_ENTRY_EXTERIOR_TAG);
    }

    return GetLocalString(oBase, DL_L_BASE_ENTRY_INTERIOR_TAG);
}

object DL_ResolveBaseContextArea(object oNPC, object oFallbackArea, int nDirective, int nAnchorGroup)
{
    object oBase = DL_GetNpcBase(oNPC);
    object oArea;
    string sAreaTag;

    if (!GetIsObjectValid(oBase))
    {
        return oFallbackArea;
    }

    sAreaTag = DL_GetBaseMappedAreaTag(oBase, nDirective, nAnchorGroup);
    if (sAreaTag == "")
    {
        sAreaTag = DL_GetDefaultBaseAreaTag(oBase, nDirective, nAnchorGroup);
    }
    if (sAreaTag == "")
    {
        return oFallbackArea;
    }

    oArea = DL_FindAreaByTag(sAreaTag);
    if (GetIsObjectValid(oArea))
    {
        return oArea;
    }

    DL_LogNpc(oNPC, DL_DEBUG_BASIC, "base context area missing: area_tag=" + sAreaTag + ", directive=" + IntToString(nDirective));
    return oFallbackArea;
}

string DL_ResolveBaseContextAnchorTag(object oNPC, int nDirective, int nAnchorGroup)
{
    object oBase = DL_GetNpcBase(oNPC);
    string sAnchorTag;

    if (!GetIsObjectValid(oBase))
    {
        return "";
    }

    sAnchorTag = DL_GetBaseMappedAnchorTag(oBase, nDirective, nAnchorGroup);
    if (sAnchorTag != "")
    {
        return sAnchorTag;
    }

    return DL_GetDefaultBaseAnchorTag(oBase, nDirective, nAnchorGroup);
}

#endif
