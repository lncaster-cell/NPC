#ifndef DL_SLOT_HANDOFF_INC_NSS
#define DL_SLOT_HANDOFF_INC_NSS

#include "dl_const_inc"
#include "dl_log_inc"

void DL_RequestFunctionSlotReview(string sFunctionSlotId, int nReason)
{
    SetLocalString(GetModule(), DL_L_LAST_SLOT_REVIEW, sFunctionSlotId);
    DL_Log(DL_DEBUG_BASIC, "Slot review requested: " + sFunctionSlotId + ", reason=" + IntToString(nReason));
}

void DL_OnFunctionSlotAssigned(string sFunctionSlotId, object oNPC)
{
    SetLocalString(GetModule(), DL_L_LAST_SLOT_ASSIGNED, sFunctionSlotId);
    SetLocalObject(GetModule(), DL_L_SLOT_ASSIGNED_NPC, oNPC);
    DL_LogNpc(oNPC, DL_DEBUG_BASIC, "Slot assigned: " + sFunctionSlotId);
}

#endif
