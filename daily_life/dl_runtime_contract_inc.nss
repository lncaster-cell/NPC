#include "dl_res_inc"

const string DL_L_MODULE_ENABLED = "dl_enabled";
const string DL_L_MODULE_CONTRACT_VERSION = "dl_contract_version";
const string DL_CONTRACT_VERSION_A0 = "a0";
const string DL_L_MODULE_CHAT_LOG = "dl_chat_log";
const string DL_L_MODULE_CHAT_LOG_INIT = "dl_chat_log_init";

// Shared City Response / Legal v1 contract locals (cross-include canonical symbols).
const string DL_L_MODULE_CR_DETAIN_DIALOG = "dl_cr_detain_dialog";
const string DL_L_MODULE_TRANSITION_DRIVER_LOOKUP_CAP = "dl_transition_driver_lookup_cap";
const string DL_L_PC_CR_DETAIN_PENDING = "dl_cr_detain_pending";
const string DL_L_PC_CR_LAST_GUARD = "dl_cr_last_guard";
const string DL_L_NPC_CR_OFFENDER_UNTIL = "dl_cr_offender_until";
const string DL_L_NPC_CR_INVESTIGATE_TARGET = "dl_cr_investigate_target";
const string DL_L_NPC_CR_INVESTIGATE_UNTIL = "dl_cr_investigate_until";

const string DL_L_NPC_EVENT_KIND = "dl_npc_event_kind";
const string DL_L_NPC_EVENT_SEQ = "dl_npc_event_seq";

const string DL_L_MODULE_EVENT_SEQ = "dl_module_event_seq";
const string DL_L_MODULE_LAST_EVENT_KIND = "dl_module_last_event_kind";
const string DL_L_MODULE_LAST_EVENT_ACTOR = "dl_module_last_event_actor";
const string DL_L_MODULE_SPAWN_COUNT = "dl_module_spawn_count";
const string DL_L_MODULE_DEATH_COUNT = "dl_module_death_count";

int DL_IsRuntimeEnabled()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_ENABLED) != TRUE)
    {
        return FALSE;
    }

    return GetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION) == DL_CONTRACT_VERSION_A0;
}

void DL_LogRuntime(string sLog)
{
    // Temporary: global runtime logging is disabled.
}

void DL_InitModuleContract()
{
    object oModule = GetModule();
    int nEnabled = GetLocalInt(oModule, DL_L_MODULE_ENABLED) == TRUE ? TRUE : FALSE;

    SetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION, DL_CONTRACT_VERSION_A0);
    SetLocalInt(oModule, DL_L_MODULE_ENABLED, nEnabled);

    if (GetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ) < 0)
    {
        SetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ, 0);
    }

    if (GetLocalInt(oModule, DL_L_MODULE_CHAT_LOG_INIT) != TRUE)
    {
        SetLocalInt(oModule, DL_L_MODULE_CHAT_LOG, TRUE);
        SetLocalInt(oModule, DL_L_MODULE_CHAT_LOG_INIT, TRUE);
    }
}

int DL_IsAreaObject(object oObject)
{
    if (!GetIsObjectValid(oObject))
    {
        return FALSE;
    }

    return GetArea(oObject) == oObject;
}

int DL_IsPipelineNpc(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetObjectType(oNpc) != OBJECT_TYPE_CREATURE)
    {
        return FALSE;
    }

    if (GetIsPC(oNpc))
    {
        return FALSE;
    }

    if (GetIsDM(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}

int DL_IsActivePipelineNpc(object oNpc)
{
    if (!DL_IsPipelineNpc(oNpc))
    {
        return FALSE;
    }

    if (GetIsDead(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}

int DL_IsRuntimePlayer(object oCreature)
{
    if (!GetIsObjectValid(oCreature))
    {
        return FALSE;
    }

    return GetIsPC(oCreature) && !GetIsDM(oCreature);
}
