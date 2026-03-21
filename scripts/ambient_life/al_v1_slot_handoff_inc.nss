#ifndef AL_V1_SLOT_HANDOFF_INC_NSS
#define AL_V1_SLOT_HANDOFF_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_log_inc"

void DLV1_RequestFunctionSlotReview(string sFunctionSlotId, int nReason)
{
    SetLocalString(GetModule(), DLV1_L_LAST_SLOT_REVIEW, sFunctionSlotId);
    DLV1_Log(DLV1_DEBUG_BASIC, "Slot review requested: " + sFunctionSlotId + ", reason=" + IntToString(nReason));
}

void DLV1_OnFunctionSlotAssigned(string sFunctionSlotId, object oNPC)
{
    SetLocalString(GetModule(), DLV1_L_LAST_SLOT_ASSIGNED, sFunctionSlotId);
    SetLocalObject(GetModule(), DLV1_L_SLOT_ASSIGNED_NPC, oNPC);
    DLV1_LogNpc(oNPC, DLV1_DEBUG_BASIC, "Slot assigned: " + sFunctionSlotId);
}

#endif
