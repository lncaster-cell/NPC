#ifndef AL_V1_MATERIALIZE_INC_NSS
#define AL_V1_MATERIALIZE_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_log_inc"
#include "al_v1_util_inc"
#include "al_v1_override_inc"
#include "al_v1_resolver_inc"
#include "al_v1_anchor_inc"
#include "al_v1_activity_inc"

int DLV1_ShouldInstantPlace(object oNPC, object oArea, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return FALSE;
    }
    if (DLV1_IsAreaHot(oArea))
    {
        return GetDistanceBetween(oNPC, oPoint) > 20.0;
    }
    return TRUE;
}

void DLV1_ApplyInstantPlacement(object oNPC, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return;
    }
    AssignCommand(oNPC, ClearAllActions());
    AssignCommand(oNPC, ActionJumpToObject(oPoint));
}

void DLV1_ApplyLocalWalk(object oNPC, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return;
    }
    AssignCommand(oNPC, ClearAllActions());
    AssignCommand(oNPC, ActionMoveToObject(oPoint, TRUE));
}

void DLV1_HideOrMarkAbsent(object oNPC, int nDirective)
{
    SetLocalInt(oNPC, DLV1_L_DIRECTIVE, nDirective);
    SetLocalInt(oNPC, DLV1_L_ANCHOR_GROUP, DLV1_AG_NONE);
    if (nDirective == DLV1_DIR_ABSENT)
    {
        SetPlotFlag(oNPC, FALSE);
    }
}

void DLV1_MaterializeNpc(object oNPC, object oArea)
{
    int nDirective = DLV1_ResolveDirective(oNPC, oArea);
    int nOverride = DLV1_GetTopOverride(oNPC, oArea);
    int nAnchorGroup = DLV1_ResolveAnchorGroup(oNPC, nDirective);

    SetLocalInt(oNPC, DLV1_L_DIRECTIVE, nDirective);
    SetLocalInt(oNPC, DLV1_L_ANCHOR_GROUP, nAnchorGroup);

    if (!DLV1_IsDirectiveVisible(nDirective) || DLV1_ShouldSuppressMaterialization(oNPC, nOverride))
    {
        DLV1_HideOrMarkAbsent(oNPC, nDirective);
        return;
    }

    object oPoint = DLV1_FindAnchorPoint(oNPC, oArea, nAnchorGroup);
    if (!GetIsObjectValid(oPoint))
    {
        DLV1_LogNpc(oNPC, DLV1_DEBUG_BASIC, "anchor not found, marking absent");
        DLV1_HideOrMarkAbsent(oNPC, DLV1_DIR_ABSENT);
        return;
    }

    if (DLV1_ShouldInstantPlace(oNPC, oArea, oPoint))
    {
        DLV1_ApplyInstantPlacement(oNPC, oPoint);
    }
    else
    {
        DLV1_ApplyLocalWalk(oNPC, oPoint);
    }

    DLV1_ApplyActivity(oNPC, DLV1_ResolveActivityKind(oNPC, nDirective, nAnchorGroup), oPoint);
}

#endif
