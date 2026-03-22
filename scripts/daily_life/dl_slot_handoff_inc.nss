#ifndef DL_SLOT_HANDOFF_INC_NSS
#define DL_SLOT_HANDOFF_INC_NSS

#include "dl_const_inc"
#include "dl_log_inc"

void DL_RequestAssignedNpcResync(object oNPC)
{
    if (!GetIsObjectValid(oNPC))
    {
        return;
    }

    SetLocalInt(oNPC, DL_L_RESYNC_PENDING, TRUE);
    SetLocalInt(oNPC, DL_L_RESYNC_REASON, DL_RESYNC_SLOT_ASSIGNED);
}

void DL_RequestFunctionSlotReview(string sFunctionSlotId, int nReason)
{
    SetLocalString(GetModule(), DL_L_LAST_SLOT_REVIEW, sFunctionSlotId);
    SetLocalInt(GetModule(), DL_L_LAST_SLOT_REVIEW_REASON, nReason);
    DL_Log(DL_DEBUG_BASIC, "Slot review requested: " + sFunctionSlotId + ", reason=" + IntToString(nReason));
}

void DL_OnFunctionSlotAssigned(string sFunctionSlotId, object oNPC)
{
    if (sFunctionSlotId == "")
    {
        DL_Log(DL_DEBUG_BASIC, "Slot assigned callback ignored: empty function slot id");
        return;
    }

    SetLocalString(GetModule(), DL_L_LAST_SLOT_ASSIGNED, sFunctionSlotId);
    SetLocalInt(GetModule(), DL_L_LAST_SLOT_ASSIGNED_REASON, DL_RESYNC_SLOT_ASSIGNED);
    SetLocalObject(GetModule(), DL_L_SLOT_ASSIGNED_NPC, oNPC);
    if (GetIsObjectValid(oNPC))
    {
        SetLocalString(oNPC, DL_L_FUNCTION_SLOT_ID, sFunctionSlotId);
        DL_RequestAssignedNpcResync(oNPC);
    }
    DL_LogNpc(oNPC, DL_DEBUG_BASIC, "Slot assigned: " + sFunctionSlotId);
}

#endif
