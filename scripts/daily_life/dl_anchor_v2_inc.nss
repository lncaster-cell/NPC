#ifndef DL_ANCHOR_V2_INC_NSS
#define DL_ANCHOR_V2_INC_NSS

#include "dl_const_inc"
#include "dl_util_inc"
#include "dl_types_inc"

const int DL_ANCHOR_SEARCH_MAX_INDEX = 4;

int DL_IsAnchorMarkerType(int nObjType)
{
    return nObjType == OBJECT_TYPE_WAYPOINT || nObjType == OBJECT_TYPE_PLACEABLE;
}

int DL_IsAnchorContextAllowed(object oNPC, object oPoint)
{
    if (!GetIsObjectValid(oPoint) || !GetIsObjectValid(oNPC))
    {
        return FALSE;
    }
    return GetArea(oNPC) == GetArea(oPoint);
}

int DL_IsAnchorInArea(object oPoint, object oArea)
{
    return GetIsObjectValid(oPoint) && GetIsObjectValid(oArea) && GetArea(oPoint) == oArea;
}

object DL_FindAnchorByTag(object oArea, string sTag)
{
    object oObj;
    int nObjType;

    if (!GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        nObjType = GetObjectType(oObj);
        if (DL_IsAnchorMarkerType(nObjType) && GetTag(oObj) == sTag)
        {
            return oObj;
        }
        oObj = GetNextObjectInArea(oArea);
    }

    return OBJECT_INVALID;
}

object DL_FindFallbackAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    object oBase = DL_GetNpcBase(oNPC);
    object oPoint;

    if (DL_IsAreaAnchor(oBase, oArea) && DL_IsAnchorInArea(oBase, oArea))
    {
        return oBase;
    }

    oPoint = DL_FindAnchorByTag(oArea, DL_GetSpecializedAnchorTagCandidate(oNPC, DL_AG_WAIT, 1));
    if (DL_IsAnchorInArea(oPoint, oArea))
    {
        return oPoint;
    }

    oPoint = DL_FindAnchorByTag(oArea, DL_GetAreaAnchorTagCandidate(oNPC, oArea, nAnchorGroup, 1));
    if (DL_IsAnchorInArea(oPoint, oArea))
    {
        return oPoint;
    }

    return OBJECT_INVALID;
}

object DL_FindFallbackAnchorPointIgnoringPolicy(object oNPC, object oArea, int nAnchorGroup)
{
    object oBase = DL_GetNpcBase(oNPC);
    object oPoint;

    if (DL_IsAreaAnchor(oBase, oArea))
    {
        return oBase;
    }

    oPoint = DL_FindAnchorByTag(oArea, DL_GetSpecializedAnchorTagCandidate(oNPC, DL_AG_WAIT, 1));
    if (GetIsObjectValid(oPoint))
    {
        return oPoint;
    }

    oPoint = DL_FindAnchorByTag(oArea, DL_GetAreaAnchorTagCandidate(oNPC, oArea, nAnchorGroup, 1));
    if (GetIsObjectValid(oPoint))
    {
        return oPoint;
    }

    return OBJECT_INVALID;
}

object DL_FindAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    int i = 1;
    object oPoint;

    while (i <= DL_ANCHOR_SEARCH_MAX_INDEX)
    {
        oPoint = DL_FindAnchorByTag(oArea, DL_GetAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (DL_IsAnchorInArea(oPoint, oArea))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetBaseAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (DL_IsAnchorInArea(oPoint, oArea))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetSpecializedAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (DL_IsAnchorInArea(oPoint, oArea))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetAreaAnchorTagCandidate(oNPC, oArea, nAnchorGroup, i));
        if (DL_IsAnchorInArea(oPoint, oArea))
        {
            return oPoint;
        }
        i += 1;
    }

    return DL_FindFallbackAnchorPoint(oNPC, oArea, nAnchorGroup);
}

object DL_FindAnchorPointIgnoringPolicy(object oNPC, object oArea, int nAnchorGroup)
{
    int i = 1;
    object oPoint;

    while (i <= DL_ANCHOR_SEARCH_MAX_INDEX)
    {
        oPoint = DL_FindAnchorByTag(oArea, DL_GetAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetBaseAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetSpecializedAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetAreaAnchorTagCandidate(oNPC, oArea, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint))
        {
            return oPoint;
        }
        i += 1;
    }

    return DL_FindFallbackAnchorPointIgnoringPolicy(oNPC, oArea, nAnchorGroup);
}

#endif
