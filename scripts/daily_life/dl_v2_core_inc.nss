#ifndef DL_V2_CORE_INC_NSS
#define DL_V2_CORE_INC_NSS

// Daily Life v2 core event ingress (clean-room).
// Step 01 (clean-room reset) scope: OnSpawn/OnDeath -> OnUserDefined bridge.

const string DL2_L_MODULE_ENABLED = "dl2_enabled";
const string DL2_L_MODULE_CONTRACT_VERSION = "dl2_contract_version";
const string DL2_CONTRACT_VERSION_A0 = "v2.a0";

const string DL2_L_NPC_EVENT_KIND = "dl2_npc_event_kind";
const string DL2_L_NPC_EVENT_SEQ = "dl2_npc_event_seq";

const string DL2_L_MODULE_EVENT_SEQ = "dl2_module_event_seq";
const string DL2_L_MODULE_LAST_EVENT_KIND = "dl2_module_last_event_kind";
const string DL2_L_MODULE_LAST_EVENT_ACTOR = "dl2_module_last_event_actor";
const string DL2_L_MODULE_SPAWN_COUNT = "dl2_module_spawn_count";
const string DL2_L_MODULE_DEATH_COUNT = "dl2_module_death_count";

const int DL2_NPC_EVENT_NONE = 0;
const int DL2_NPC_EVENT_SPAWN = 1;
const int DL2_NPC_EVENT_DEATH = 2;

const int DL2_UD_PIPELINE_NPC_EVENT = 2001;

int DL2_IsRuntimeEnabled()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL2_L_MODULE_ENABLED) != TRUE)
    {
        return FALSE;
    }

    return GetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION) == DL2_CONTRACT_VERSION_A0;
}

void DL2_InitModuleContract()
{
    object oModule = GetModule();
    int nEnabled = GetLocalInt(oModule, DL2_L_MODULE_ENABLED) == TRUE ? TRUE : FALSE;

    SetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION, DL2_CONTRACT_VERSION_A0);
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, nEnabled);

    if (GetLocalInt(oModule, DL2_L_MODULE_EVENT_SEQ) < 0)
    {
        SetLocalInt(oModule, DL2_L_MODULE_EVENT_SEQ, 0);
    }
}

int DL2_IsPipelineNpc(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetObjectType(oNpc) != OBJECT_TYPE_CREATURE)
    {
        return FALSE;
    }

    if (GetIsDM(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}

void DL2_RequestNpcLifecycleSignal(object oNpc, int nEventKind)
{
    if (!DL2_IsPipelineNpc(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL2_L_NPC_EVENT_KIND, nEventKind);
    SetLocalInt(oNpc, DL2_L_NPC_EVENT_SEQ, GetLocalInt(oNpc, DL2_L_NPC_EVENT_SEQ) + 1);

    SignalEvent(oNpc, EventUserDefined(DL2_UD_PIPELINE_NPC_EVENT));
}

void DL2_RecordNpcLifecycleEvent(object oNpc, int nEventKind)
{
    object oModule = GetModule();
    int nSeq = GetLocalInt(oModule, DL2_L_MODULE_EVENT_SEQ) + 1;

    SetLocalInt(oModule, DL2_L_MODULE_EVENT_SEQ, nSeq);
    SetLocalInt(oModule, DL2_L_MODULE_LAST_EVENT_KIND, nEventKind);
    SetLocalObject(oModule, DL2_L_MODULE_LAST_EVENT_ACTOR, oNpc);

    if (nEventKind == DL2_NPC_EVENT_SPAWN)
    {
        SetLocalInt(oModule, DL2_L_MODULE_SPAWN_COUNT, GetLocalInt(oModule, DL2_L_MODULE_SPAWN_COUNT) + 1);
        return;
    }

    if (nEventKind == DL2_NPC_EVENT_DEATH)
    {
        SetLocalInt(oModule, DL2_L_MODULE_DEATH_COUNT, GetLocalInt(oModule, DL2_L_MODULE_DEATH_COUNT) + 1);
    }
}

void DL2_HandleNpcUserDefined(object oNpc, int nUserDefined)
{
    if (nUserDefined != DL2_UD_PIPELINE_NPC_EVENT)
    {
        return;
    }

    if (!DL2_IsPipelineNpc(oNpc))
    {
        return;
    }

    if (!DL2_IsRuntimeEnabled())
    {
        return;
    }

    int nEventKind = GetLocalInt(oNpc, DL2_L_NPC_EVENT_KIND);
    if (nEventKind != DL2_NPC_EVENT_SPAWN && nEventKind != DL2_NPC_EVENT_DEATH)
    {
        return;
    }

    DL2_RecordNpcLifecycleEvent(oNpc, nEventKind);
}

#endif
