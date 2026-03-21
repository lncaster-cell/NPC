#ifndef AL_V1_UTIL_INC_NSS
#define AL_V1_UTIL_INC_NSS

#include "al_v1_const_inc"

int DLV1_IsValidCreature(object oNPC)
{
    return GetIsObjectValid(oNPC) && GetObjectType(oNPC) == OBJECT_TYPE_CREATURE;
}

int DLV1_IsAreaHot(object oArea)
{
    return GetLocalInt(oArea, DLV1_L_AREA_TIER) == DLV1_AREA_HOT;
}

int DLV1_IsAreaWarm(object oArea)
{
    return GetLocalInt(oArea, DLV1_L_AREA_TIER) == DLV1_AREA_WARM;
}

int DLV1_IsAreaFrozen(object oArea)
{
    return GetLocalInt(oArea, DLV1_L_AREA_TIER) == DLV1_AREA_FROZEN;
}

int DLV1_IsDirectiveVisible(int nDirective)
{
    return nDirective != DLV1_DIR_ABSENT && nDirective != DLV1_DIR_HIDE_SAFE;
}

int DLV1_HasAnyPlayers(object oArea)
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

int DLV1_IsAreaAnchor(object oPoint, object oArea)
{
    return GetIsObjectValid(oPoint) && GetArea(oPoint) == oArea;
}

string DLV1_GetAnchorGroupToken(int nAnchorGroup)
{
    if (nAnchorGroup == DLV1_AG_SLEEP)
    {
        return "sleep";
    }
    if (nAnchorGroup == DLV1_AG_WORK)
    {
        return "work";
    }
    if (nAnchorGroup == DLV1_AG_SERVICE)
    {
        return "service";
    }
    if (nAnchorGroup == DLV1_AG_SOCIAL)
    {
        return "social";
    }
    if (nAnchorGroup == DLV1_AG_DUTY)
    {
        return "duty";
    }
    if (nAnchorGroup == DLV1_AG_GATE)
    {
        return "gate";
    }
    if (nAnchorGroup == DLV1_AG_PATROL_POINT)
    {
        return "patrol";
    }
    if (nAnchorGroup == DLV1_AG_STREET_NEAR_BASE)
    {
        return "street";
    }
    if (nAnchorGroup == DLV1_AG_WAIT)
    {
        return "wait";
    }
    if (nAnchorGroup == DLV1_AG_HIDE)
    {
        return "hide";
    }
    return "none";
}

string DLV1_GetAnchorTagCandidate(object oNPC, int nAnchorGroup, int nIndex)
{
    string sNpcTag = GetTag(oNPC);
    string sGroup = DLV1_GetAnchorGroupToken(nAnchorGroup);
    return sNpcTag + "_" + sGroup + "_" + IntToString(nIndex);
}

#endif
