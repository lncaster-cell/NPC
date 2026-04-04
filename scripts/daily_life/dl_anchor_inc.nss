#ifndef DL_ANCHOR_INC_NSS
#define DL_ANCHOR_INC_NSS

#include "dl_const_inc"
#include "dl_util_inc"
#include "dl_types_inc"

int DL_IsAnchorContextAllowed(object oNPC, object oPoint)
{
    // Anchor context is local-only:
    // 1) Anchor must be in the same area as NPC.
    // 2) Distance must be within hard cap.
    //
    // Cross-area anchors are never allowed here (even if "close" by world coords).
    // Any explicit long-range relocation must be handled by dedicated jump/teleport flow.
    float fMaxAnchorDistance = 100.0;

    if (!GetIsObjectValid(oPoint))
    {
        return FALSE;
    }
    if (!GetIsObjectValid(oNPC))
    {
        return FALSE;
    }

    return GetArea(oNPC) == GetArea(oPoint)
        && GetDistanceBetween(oNPC, oPoint) <= fMaxAnchorDistance;
}

object DL_FindAnchorByTag(object oArea, string sTag)
{
    object oObj;
    int nObjType;

    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        // Anchors are expected to be world markers.
        nObjType = GetObjectType(oObj);
        if ((nObjType == OBJECT_TYPE_WAYPOINT || nObjType == OBJECT_TYPE_PLACEABLE)
            && GetTag(oObj) == sTag)
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

    if (DL_IsAreaAnchor(oBase, oArea) && DL_IsAnchorContextAllowed(oNPC, oBase))
    {
        return oBase;
    }

    oPoint = DL_FindAnchorByTag(oArea, DL_GetSpecializedAnchorTagCandidate(oNPC, DL_AG_WAIT, 1));
    if (GetIsObjectValid(oPoint) && DL_IsAnchorContextAllowed(oNPC, oPoint))
    {
        return oPoint;
    }

    oPoint = DL_FindAnchorByTag(oArea, DL_GetAreaAnchorTagCandidate(oNPC, oArea, nAnchorGroup, 1));
    if (GetIsObjectValid(oPoint) && DL_IsAnchorContextAllowed(oNPC, oPoint))
    {
        return oPoint;
    }

    return OBJECT_INVALID;
}

object DL_FindAnchorPoint(object oNPC, object oArea, int nAnchorGroup)
{
    int i = 1;
    object oPoint;

    while (i <= 4)
    {
        oPoint = DL_FindAnchorByTag(oArea, DL_GetAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint) && DL_IsAnchorContextAllowed(oNPC, oPoint))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetBaseAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint) && DL_IsAnchorContextAllowed(oNPC, oPoint))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetSpecializedAnchorTagCandidate(oNPC, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint) && DL_IsAnchorContextAllowed(oNPC, oPoint))
        {
            return oPoint;
        }

        oPoint = DL_FindAnchorByTag(oArea, DL_GetAreaAnchorTagCandidate(oNPC, oArea, nAnchorGroup, i));
        if (GetIsObjectValid(oPoint) && DL_IsAnchorContextAllowed(oNPC, oPoint))
        {
            return oPoint;
        }
        i += 1;
    }

    return DL_FindFallbackAnchorPoint(oNPC, oArea, nAnchorGroup);
}

#endif
