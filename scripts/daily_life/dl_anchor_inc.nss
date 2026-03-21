#ifndef DL_ANCHOR_INC_NSS
#define DL_ANCHOR_INC_NSS

#include "dl_const_inc"
#include "dl_util_inc"
#include "dl_types_inc"

int DL_IsAnchorContextAllowed(object oNPC, object oPoint)
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

object DL_FindFallbackAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    object oBase = DL_GetNpcBase(oNPC);
    if (DL_IsAreaAnchor(oBase, oArea))
    {
        return oBase;
    }

    string sFallbackTag = DL_GetAnchorTagCandidate(oNPC, DL_AG_WAIT, 1);
    object oPoint = GetObjectByTag(sFallbackTag);
    if (DL_IsAreaAnchor(oPoint, oArea))
    {
        return oPoint;
    }

    return OBJECT_INVALID;
}

object DL_FindAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    int i = 1;
    while (i <= 4)
    {
        object oPoint = GetObjectByTag(DL_GetAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (DL_IsAreaAnchor(oPoint, oArea) && DL_IsAnchorContextAllowed(oNPC, oPoint))
        {
            return oPoint;
        }
        i += 1;
    }

    return DL_FindFallbackAnchorPoint(oNPC, oArea, nAnchorGroup);
}

#endif
