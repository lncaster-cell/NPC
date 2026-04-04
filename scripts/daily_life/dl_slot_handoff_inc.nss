#ifndef DL_SLOT_HANDOFF_INC_NSS
#define DL_SLOT_HANDOFF_INC_NSS

#include "dl_const_inc"
#include "dl_log_inc"

string DL_MakeSlotProfileKey(string sFunctionSlotId, string sField)
{
    return "dl_slot_profile_" + sFunctionSlotId + "_" + sField;
}

string DL_MakeBaseLostNpcKey(object oNPC, string sField)
{
    return "dl_base_lost_npc_" + ObjectToString(oNPC) + "_" + sField;
}

string DL_MakeBaseLostSlotKey(string sFunctionSlotId, string sField)
{
    return "dl_base_lost_slot_" + sFunctionSlotId + "_" + sField;
}

void DL_StageFunctionSlotProfile(string sFunctionSlotId, int nFamily, int nSubtype, int nSchedule, object oBase)
{
    object oModule = GetModule();

    if (sFunctionSlotId == "")
    {
        DL_Log(DL_DEBUG_BASIC, "Slot profile stage ignored: empty function slot id");
        return;
    }

    SetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "family"), nFamily);
    SetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "subtype"), nSubtype);
    SetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "schedule"), nSchedule);
    SetLocalObject(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "base"), oBase);
}

void DL_ClearFunctionSlotProfile(string sFunctionSlotId)
{
    object oModule = GetModule();

    if (sFunctionSlotId == "")
    {
        return;
    }

    DeleteLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "family"));
    DeleteLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "subtype"));
    DeleteLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "schedule"));
    DeleteLocalObject(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "base"));
}

int DL_HasStagedFunctionSlotProfile(string sFunctionSlotId)
{
    object oModule = GetModule();

    if (sFunctionSlotId == "")
    {
        return FALSE;
    }

    if (GetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "family")) > DL_FAMILY_NONE)
    {
        return TRUE;
    }
    if (GetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "subtype")) > DL_SUBTYPE_NONE)
    {
        return TRUE;
    }
    if (GetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "schedule")) > DL_SCH_NONE)
    {
        return TRUE;
    }
    if (GetIsObjectValid(GetLocalObject(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "base"))))
    {
        return TRUE;
    }
    return FALSE;
}

int DL_NormalizeSlotReviewReason(int nReason)
{
    if (nReason == DL_RESYNC_BASE_LOST || nReason == DL_RESYNC_SLOT_ASSIGNED)
    {
        return nReason;
    }
    return DL_RESYNC_BASE_LOST;
}

void DL_RecordBaseLostEvent(object oNPC, string sFunctionSlotId, int nDirective)
{
    object oModule = GetModule();

    SetLocalString(oModule, DL_MakeBaseLostNpcKey(oNPC, "slot"), sFunctionSlotId);
    SetLocalInt(oModule, DL_MakeBaseLostNpcKey(oNPC, "kind"), nDirective);

    if (sFunctionSlotId != "")
    {
        SetLocalObject(oModule, DL_MakeBaseLostSlotKey(sFunctionSlotId, "npc"), oNPC);
        SetLocalInt(oModule, DL_MakeBaseLostSlotKey(sFunctionSlotId, "kind"), nDirective);
    }

    SetLocalString(oModule, DL_L_LAST_BASE_LOST_SLOT, sFunctionSlotId);
    SetLocalObject(oModule, DL_L_LAST_BASE_LOST_NPC, oNPC);
    SetLocalInt(oModule, DL_L_LAST_BASE_LOST_KIND, nDirective);
}

void DL_ClearBaseLostEventForNpcOrSlot(object oNPC, string sFunctionSlotId)
{
    object oModule = GetModule();

    DeleteLocalString(oModule, DL_MakeBaseLostNpcKey(oNPC, "slot"));
    DeleteLocalInt(oModule, DL_MakeBaseLostNpcKey(oNPC, "kind"));

    if (sFunctionSlotId != "")
    {
        DeleteLocalObject(oModule, DL_MakeBaseLostSlotKey(sFunctionSlotId, "npc"));
        DeleteLocalInt(oModule, DL_MakeBaseLostSlotKey(sFunctionSlotId, "kind"));
    }
}

string DL_GetBaseLostSlotForNpc(object oNPC)
{
    return GetLocalString(GetModule(), DL_MakeBaseLostNpcKey(oNPC, "slot"));
}

int DL_GetBaseLostKindForNpc(object oNPC)
{
    return GetLocalInt(GetModule(), DL_MakeBaseLostNpcKey(oNPC, "kind"));
}

object DL_GetBaseLostNpcForSlot(string sFunctionSlotId)
{
    if (sFunctionSlotId == "")
    {
        return OBJECT_INVALID;
    }
    return GetLocalObject(GetModule(), DL_MakeBaseLostSlotKey(sFunctionSlotId, "npc"));
}

int DL_GetBaseLostKindForSlot(string sFunctionSlotId)
{
    if (sFunctionSlotId == "")
    {
        return DL_DIR_NONE;
    }
    return GetLocalInt(GetModule(), DL_MakeBaseLostSlotKey(sFunctionSlotId, "kind"));
}

void DL_ApplyAssignedSlotProfile(object oNPC, string sFunctionSlotId)
{
    object oModule = GetModule();
    int nFamily = GetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "family"));
    int nSubtype = GetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "subtype"));
    int nSchedule = GetLocalInt(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "schedule"));
    object oBase = GetLocalObject(oModule, DL_MakeSlotProfileKey(sFunctionSlotId, "base"));

    if (nFamily > DL_FAMILY_NONE)
    {
        SetLocalInt(oNPC, DL_L_NPC_FAMILY, nFamily);
    }
    if (nSubtype > DL_SUBTYPE_NONE)
    {
        SetLocalInt(oNPC, DL_L_NPC_SUBTYPE, nSubtype);
    }
    if (nSchedule > DL_SCH_NONE)
    {
        SetLocalInt(oNPC, DL_L_SCHEDULE_TEMPLATE, nSchedule);
    }
    if (GetIsObjectValid(oBase))
    {
        SetLocalObject(oNPC, DL_L_NPC_BASE, oBase);
    }
    else
    {
        DL_LogNpc(oNPC, DL_DEBUG_BASIC, "Slot profile base ignored: invalid base object for slot " + sFunctionSlotId);
    }
}

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
    object oModule = GetModule();

    if (sFunctionSlotId == "")
    {
        DL_Log(DL_DEBUG_BASIC, "Slot review requested with empty function slot id");
        return;
    }

    nReason = DL_NormalizeSlotReviewReason(nReason);

    if (GetLocalString(oModule, DL_L_LAST_SLOT_REVIEW) == sFunctionSlotId
        && GetLocalInt(oModule, DL_L_LAST_SLOT_REVIEW_REASON) == nReason)
    {
        DL_Log(DL_DEBUG_VERBOSE, "Slot review deduplicated: " + sFunctionSlotId + ", reason=" + IntToString(nReason));
        return;
    }

    SetLocalString(oModule, DL_L_LAST_SLOT_REVIEW, sFunctionSlotId);
    SetLocalInt(oModule, DL_L_LAST_SLOT_REVIEW_REASON, nReason);
    DL_Log(DL_DEBUG_BASIC, "Slot review requested: " + sFunctionSlotId + ", reason=" + IntToString(nReason));
}

void DL_OnFunctionSlotAssigned(string sFunctionSlotId, object oNPC)
{
    object oModule = GetModule();

    if (sFunctionSlotId == "")
    {
        DL_Log(DL_DEBUG_BASIC, "Slot assigned callback ignored: empty function slot id");
        return;
    }

    SetLocalString(oModule, DL_L_LAST_SLOT_ASSIGNED, sFunctionSlotId);
    SetLocalInt(oModule, DL_L_LAST_SLOT_ASSIGNED_REASON, DL_RESYNC_SLOT_ASSIGNED);
    SetLocalObject(oModule, DL_L_SLOT_ASSIGNED_NPC, oNPC);
    if (GetLocalString(oModule, DL_L_LAST_SLOT_REVIEW) == sFunctionSlotId)
    {
        DeleteLocalString(oModule, DL_L_LAST_SLOT_REVIEW);
        DeleteLocalInt(oModule, DL_L_LAST_SLOT_REVIEW_REASON);
    }

    if (GetIsObjectValid(oNPC))
    {
        DL_ApplyAssignedSlotProfile(oNPC, sFunctionSlotId);
        DL_ClearFunctionSlotProfile(sFunctionSlotId);
        SetLocalString(oNPC, DL_L_FUNCTION_SLOT_ID, sFunctionSlotId);
        DL_RequestAssignedNpcResync(oNPC);
    }
    DL_LogNpc(oNPC, DL_DEBUG_BASIC, "Slot assigned: " + sFunctionSlotId);
}

#endif
