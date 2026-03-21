#ifndef DL_UTIL_INC_NSS
#define DL_UTIL_INC_NSS

#include "dl_const_inc"

int DL_IsValidCreature(object oNPC)
{
    return GetIsObjectValid(oNPC) && GetObjectType(oNPC) == OBJECT_TYPE_CREATURE;
}

int DL_IsAreaHot(object oArea)
{
    return GetLocalInt(oArea, DL_L_AREA_TIER) == DL_AREA_HOT;
}

int DL_IsAreaWarm(object oArea)
{
    return GetLocalInt(oArea, DL_L_AREA_TIER) == DL_AREA_WARM;
}

int DL_IsAreaFrozen(object oArea)
{
    return GetLocalInt(oArea, DL_L_AREA_TIER) == DL_AREA_FROZEN;
}

int DL_IsDirectiveVisible(int nDirective)
{
    return nDirective != DL_DIR_ABSENT && nDirective != DL_DIR_HIDE_SAFE;
}

int DL_HasAnyPlayers(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetIsPC(oObject) && !GetIsDM(oObject))
        {
            return TRUE;
        }
        oObject = GetNextObjectInArea(oArea);
    }
    return FALSE;
}

int DL_IsAreaAnchor(object oPoint, object oArea)
{
    return GetIsObjectValid(oPoint) && GetArea(oPoint) == oArea;
}

string DL_GetAnchorGroupToken(int nAnchorGroup)
{
    if (nAnchorGroup == DL_AG_SLEEP)
    {
        return "sleep";
    }
    if (nAnchorGroup == DL_AG_WORK)
    {
        return "work";
    }
    if (nAnchorGroup == DL_AG_SERVICE)
    {
        return "service";
    }
    if (nAnchorGroup == DL_AG_SOCIAL)
    {
        return "social";
    }
    if (nAnchorGroup == DL_AG_DUTY)
    {
        return "duty";
    }
    if (nAnchorGroup == DL_AG_GATE)
    {
        return "gate";
    }
    if (nAnchorGroup == DL_AG_PATROL_POINT)
    {
        return "patrol";
    }
    if (nAnchorGroup == DL_AG_STREET_NEAR_BASE)
    {
        return "street";
    }
    if (nAnchorGroup == DL_AG_WAIT)
    {
        return "wait";
    }
    if (nAnchorGroup == DL_AG_HIDE)
    {
        return "hide";
    }
    return "none";
}

string DL_GetAnchorTagCandidate(object oNPC, int nAnchorGroup, int nIndex)
{
    string sNpcTag = GetTag(oNPC);
    string sGroup = DL_GetAnchorGroupToken(nAnchorGroup);
    return sNpcTag + "_" + sGroup + "_" + IntToString(nIndex);
}

#endif
