#ifndef AL_V1_ANCHOR_INC_NSS
#define AL_V1_ANCHOR_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_util_inc"
#include "al_v1_types_inc"

int DLV1_IsAnchorContextAllowed(object oNPC, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return FALSE;
    }
    if (!GetIsObjectValid(oNPC))
    {
        return FALSE;
    }
    return GetDistanceBetween(oNPC, oPoint) <= 100.0 || GetArea(oNPC) == GetArea(oPoint);
}

object DLV1_FindFallbackAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    object oBase = DLV1_GetNpcBase(oNPC);
    if (DLV1_IsAreaAnchor(oBase, oArea))
    {
        return oBase;
    }

    string sFallbackTag = DLV1_GetAnchorTagCandidate(oNPC, DLV1_AG_WAIT, 1);
    object oPoint = GetObjectByTag(sFallbackTag);
    if (DLV1_IsAreaAnchor(oPoint, oArea))
    {
        return oPoint;
    }

    return OBJECT_INVALID;
}

object DLV1_FindAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    int i = 1;
    while (i <= 4)
    {
        object oPoint = GetObjectByTag(DLV1_GetAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (DLV1_IsAreaAnchor(oPoint, oArea) && DLV1_IsAnchorContextAllowed(oNPC, oPoint))
        {
            return oPoint;
        }
        i += 1;
    }

    return DLV1_FindFallbackAnchorPoint(oNPC, oArea, nAnchorGroup);
}

#endif
