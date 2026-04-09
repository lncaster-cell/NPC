#ifndef DL_CORE_INC_NSS
#define DL_CORE_INC_NSS

// Daily Life core event ingress (clean-room).
// Ingress scope: OnSpawn/OnDeath -> OnUserDefined bridge.

const string DL_L_MODULE_ENABLED = "dl_enabled";
const string DL_L_MODULE_CONTRACT_VERSION = "dl_contract_version";
const string DL_CONTRACT_VERSION_A0 = "a0";

const string DL_L_NPC_EVENT_KIND = "dl_npc_event_kind";
const string DL_L_NPC_EVENT_SEQ = "dl_npc_event_seq";

const string DL_L_MODULE_EVENT_SEQ = "dl_module_event_seq";
const string DL_L_MODULE_LAST_EVENT_KIND = "dl_module_last_event_kind";
const string DL_L_MODULE_LAST_EVENT_ACTOR = "dl_module_last_event_actor";
const string DL_L_MODULE_SPAWN_COUNT = "dl_module_spawn_count";
const string DL_L_MODULE_DEATH_COUNT = "dl_module_death_count";


const string DL_L_AREA_TIER = "dl_area_tier";

const int DL_TIER_FROZEN = 0;
const int DL_TIER_WARM = 1;
const int DL_TIER_HOT = 2;

const int DL_NPC_EVENT_NONE = 0;
const int DL_NPC_EVENT_SPAWN = 1;
const int DL_NPC_EVENT_DEATH = 2;

// 3000+ range chosen for project-defined user events (avoid BioWare 1000..1011, 1510, 1511).
const int DL_UD_PIPELINE_NPC_EVENT = 3001;

int DL_IsRuntimeEnabled()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_ENABLED) != TRUE)
    {
        return FALSE;
    }

    return GetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION) == DL_CONTRACT_VERSION_A0;
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
}


int DL_AreaHasPlayer(object oArea)
{
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        if (GetIsPC(oObj) && !GetIsDM(oObj))
        {
            return TRUE;
        }
        oObj = GetNextObjectInArea(oArea);
    }
    return FALSE;
}

int DL_GetAreaTier(object oArea)
{
    int nTier = GetLocalInt(oArea, DL_L_AREA_TIER);
    if (nTier < DL_TIER_FROZEN || nTier > DL_TIER_HOT)
    {
        return DL_TIER_WARM;
    }
    return nTier;
}

void DL_SetAreaTier(object oArea, int nTier)
{
    if (nTier < DL_TIER_FROZEN)
    {
        nTier = DL_TIER_FROZEN;
    }
    if (nTier > DL_TIER_HOT)
    {
        nTier = DL_TIER_HOT;
    }
    SetLocalInt(oArea, DL_L_AREA_TIER, nTier);
}

void DL_BootstrapAreaTier(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return;
    }

    int nTier = DL_GetAreaTier(oArea);
    if (DL_AreaHasPlayer(oArea))
    {
        nTier = DL_TIER_HOT;
    }
    else if (nTier < DL_TIER_WARM)
    {
        nTier = DL_TIER_WARM;
    }

    DL_SetAreaTier(oArea, nTier);
}

void DL_OnAreaEnterBootstrap(object oArea, object oEnter)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oEnter))
    {
        return;
    }

    if (GetIsPC(oEnter) && !GetIsDM(oEnter))
    {
        DL_SetAreaTier(oArea, DL_TIER_HOT);
        return;
    }

    DL_BootstrapAreaTier(oArea);
}

void DL_OnAreaExitBootstrap(object oArea, object oExit)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oExit))
    {
        return;
    }

    if (GetIsPC(oExit) && !GetIsDM(oExit) && !DL_AreaHasPlayer(oArea))
    {
        DL_SetAreaTier(oArea, DL_TIER_WARM);
        return;
    }

    DL_BootstrapAreaTier(oArea);
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

    if (GetIsDM(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}

void DL_RequestNpcLifecycleSignal(object oNpc, int nEventKind)
{
    if (!DL_IsPipelineNpc(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_EVENT_KIND, nEventKind);
    SetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ, GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ) + 1);

    SignalEvent(oNpc, EventUserDefined(DL_UD_PIPELINE_NPC_EVENT));
}

void DL_RecordNpcLifecycleEvent(object oNpc, int nEventKind)
{
    object oModule = GetModule();
    int nSeq = GetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ) + 1;

    SetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ, nSeq);
    SetLocalInt(oModule, DL_L_MODULE_LAST_EVENT_KIND, nEventKind);
    SetLocalObject(oModule, DL_L_MODULE_LAST_EVENT_ACTOR, oNpc);

    if (nEventKind == DL_NPC_EVENT_SPAWN)
    {
        SetLocalInt(oModule, DL_L_MODULE_SPAWN_COUNT, GetLocalInt(oModule, DL_L_MODULE_SPAWN_COUNT) + 1);
        return;
    }

    if (nEventKind == DL_NPC_EVENT_DEATH)
    {
        SetLocalInt(oModule, DL_L_MODULE_DEATH_COUNT, GetLocalInt(oModule, DL_L_MODULE_DEATH_COUNT) + 1);
    }
}

void DL_HandleNpcUserDefined(object oNpc, int nUserDefined)
{
    if (nUserDefined != DL_UD_PIPELINE_NPC_EVENT)
    {
        return;
    }

    if (!DL_IsPipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    int nEventKind = GetLocalInt(oNpc, DL_L_NPC_EVENT_KIND);
    if (nEventKind != DL_NPC_EVENT_SPAWN && nEventKind != DL_NPC_EVENT_DEATH)
    {
        return;
    }

    DL_RecordNpcLifecycleEvent(oNpc, nEventKind);
}

#endif
