#ifndef DL_MATERIALIZE_INC_NSS
#define DL_MATERIALIZE_INC_NSS

#include "dl_const_inc"
#include "dl_log_inc"
#include "dl_util_inc"
#include "dl_override_inc"
#include "dl_resolver_inc"
#include "dl_anchor_inc"
#include "dl_activity_inc"
#include "dl_interact_inc"
#include "dl_slot_handoff_inc"

int DL_ShouldInstantPlace(object oNPC, object oArea, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return FALSE;
    }
    if (DL_IsAreaHot(oArea))
    {
        return GetDistanceBetween(oNPC, oPoint) > 20.0;
    }
    return TRUE;
}

void DL_ApplyInstantPlacement(object oNPC, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return;
    }
    AssignCommand(oNPC, ClearAllActions());
    AssignCommand(oNPC, ActionJumpToObject(oPoint));
}

void DL_ApplyLocalWalk(object oNPC, object oPoint)
{
    if (!GetIsObjectValid(oPoint))
    {
        return;
    }
    AssignCommand(oNPC, ClearAllActions());
    AssignCommand(oNPC, ActionMoveToObject(oPoint, TRUE));
}

void DL_HideOrMarkAbsent(object oNPC, int nDirective)
{
    SetLocalInt(oNPC, DL_L_DIRECTIVE, nDirective);
    SetLocalInt(oNPC, DL_L_ANCHOR_GROUP, DL_AG_NONE);
    if (nDirective == DL_DIR_ABSENT)
    {
        SetPlotFlag(oNPC, FALSE);
    }
}

void DL_HandleUnassignedNpc(object oNPC)
{
    string sFunctionSlotId = DL_GetFunctionSlotId(oNPC);

    AssignCommand(oNPC, ClearAllActions());
    SetLocalInt(oNPC, DL_L_ACTIVITY_KIND, DL_ACT_NONE);
    SetLocalInt(oNPC, DL_L_ANCHOR_GROUP, DL_AG_NONE);
    DL_SetInteractionStateExplicit(oNPC, DL_DIR_UNASSIGNED, DL_DLG_UNAVAILABLE, DL_SERVICE_NONE);

    if (sFunctionSlotId != "")
    {
        DL_RequestFunctionSlotReview(sFunctionSlotId, DL_RESYNC_WORKER);
    }
    else
    {
        DL_LogNpc(oNPC, DL_DEBUG_BASIC, "base lost without function slot id");
    }
}

int DL_HandleBaseLostStub(object oNPC)
{
    if (DL_HasBase(oNPC))
    {
        return FALSE;
    }

    DL_LogNpc(oNPC, DL_DEBUG_BASIC, "base lost, applying milestone A stub");
    if (DL_IsNamed(oNPC) || DL_IsPersistent(oNPC))
    {
        DL_HideOrMarkAbsent(oNPC, DL_DIR_ABSENT);
        DL_SetInteractionStateExplicit(oNPC, DL_DIR_ABSENT, DL_DLG_UNAVAILABLE, DL_SERVICE_NONE);
        return TRUE;
    }

    DL_HandleUnassignedNpc(oNPC);
    return TRUE;
}

void DL_MaterializeNpc(object oNPC, object oArea)
{
    int nDirective;
    int nOverride;
    int nAnchorGroup;
    object oPoint;

    if (DL_HandleBaseLostStub(oNPC))
    {
        return;
    }

    nDirective = DL_ResolveDirective(oNPC, oArea);
    nOverride = DL_GetTopOverride(oNPC, oArea);
    nAnchorGroup = DL_ResolveAnchorGroup(oNPC, nDirective);

    SetLocalInt(oNPC, DL_L_DIRECTIVE, nDirective);
    SetLocalInt(oNPC, DL_L_ANCHOR_GROUP, nAnchorGroup);

    if (!DL_IsDirectiveVisible(nDirective) || DL_ShouldSuppressMaterialization(oNPC, nOverride))
    {
        DL_HideOrMarkAbsent(oNPC, nDirective);
        DL_RefreshInteractionState(oNPC, oArea);
        return;
    }

    oPoint = DL_FindAnchorPoint(oNPC, oArea, nAnchorGroup);
    if (!GetIsObjectValid(oPoint))
    {
        DL_LogNpc(oNPC, DL_DEBUG_BASIC, "anchor not found, marking absent");
        DL_HideOrMarkAbsent(oNPC, DL_DIR_ABSENT);
        DL_RefreshInteractionState(oNPC, oArea);
        return;
    }

    if (DL_ShouldInstantPlace(oNPC, oArea, oPoint))
    {
        DL_ApplyInstantPlacement(oNPC, oPoint);
    }
    else
    {
        DL_ApplyLocalWalk(oNPC, oPoint);
    }

    DL_ApplyActivity(oNPC, DL_ResolveActivityKind(oNPC, nDirective, nAnchorGroup), oPoint);
    DL_RefreshInteractionState(oNPC, oArea);
}

#endif
