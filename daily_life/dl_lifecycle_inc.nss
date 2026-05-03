// Valid runtime lifecycle events start at 1.
const int DL_NPC_EVENT_SPAWN = 1;
const int DL_NPC_EVENT_DEATH = 2;
const int DL_NPC_EVENT_BLOCKED = 3;

// 3000+ range chosen for project-defined user events (avoid BioWare 1000..1011, 1510, 1511).
const int DL_UD_PIPELINE_NPC_EVENT = 3001;

// Lifecycle-owned directive execution reset mask bits.
const int DL_NPC_RESET_DIRECTIVE_EXEC_SLEEP  = 1;
const int DL_NPC_RESET_DIRECTIVE_EXEC_WORK   = 2;
const int DL_NPC_RESET_DIRECTIVE_EXEC_MEAL   = 4;
const int DL_NPC_RESET_DIRECTIVE_EXEC_CHILL  = 8;
const int DL_NPC_RESET_DIRECTIVE_EXEC_SOCIAL = 16;
const int DL_NPC_RESET_DIRECTIVE_EXEC_PUBLIC = 32;
const int DL_NPC_RESET_DIRECTIVE_EXEC_ALL    = 63;

// Pipeline-level runtime reset domains for directive transitions.
const int DL_NPC_RESET_DOMAIN_SLEEP = 1;
const int DL_NPC_RESET_DOMAIN_WORK  = 2;
const int DL_NPC_RESET_DOMAIN_FOCUS = 4;
const int DL_NPC_RESET_DOMAIN_ALL   = 7;

string DL_GetLifecycleResyncPendingLocal()
{
    return "dl_npc_resync_pending";
}

string DL_GetLifecycleResyncReasonLocal()
{
    return "dl_npc_resync_reason";
}

string DL_GetLifecycleWorkerSeqLocal()
{
    return "dl_npc_worker_seq";
}

string DL_GetLifecycleSocialReservedWpLocal()
{
    return "dl_social_reserved_wp";
}

#include "dl_blocked_inc"

// Transition rule: every directive-to-directive switch must pass through this API.
// Domain-specific cleanup hooks (animations/reservations/etc.) should wrap this helper
// instead of duplicating the baseline reset.
void DL_ResetNpcDirectiveState(object oNpc, int nDomainMask)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    // Mandatory base reset for any directive transition.
    DL_ClearTransitionExecutionState(oNpc);

    if (nDomainMask & DL_NPC_RESET_DOMAIN_SLEEP)
    {
        DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    }

    if (nDomainMask & DL_NPC_RESET_DOMAIN_WORK)
    {
        DeleteLocalString(oNpc, DL_L_NPC_WORK_KIND);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    }

    if (nDomainMask & DL_NPC_RESET_DOMAIN_FOCUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    }
}

void DL_ResetNpcDirectiveExecutionState(object oNpc, int nDirectiveMask)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_SLEEP)
    {
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_WORK)
    {
        DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_WORK_KIND);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_MEAL)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_CHILL)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_SOCIAL)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalObject(oNpc, DL_GetLifecycleSocialReservedWpLocal());
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_PUBLIC)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    }
}

void DL_InitNpcRuntimeState(object oNpc, string sIngressReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_EVENT_KIND, DL_NPC_EVENT_SPAWN);
    SetLocalInt(oNpc, DL_GetLifecycleResyncPendingLocal(), FALSE);
    SetLocalInt(oNpc, DL_GetLifecycleResyncReasonLocal(), 0);

    if (sIngressReason == "")
    {
        return;
    }
}

void DL_CleanupNpcRuntimeState(object oNpc, string sEgressReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DL_UnregisterNpc(oNpc);

    DeleteLocalInt(oNpc, DL_L_NPC_EVENT_KIND);
    DeleteLocalInt(oNpc, DL_L_NPC_EVENT_SEQ);
    SetLocalInt(oNpc, DL_GetLifecycleResyncPendingLocal(), FALSE);
    SetLocalInt(oNpc, DL_GetLifecycleResyncReasonLocal(), 0);
    DeleteLocalInt(oNpc, DL_GetLifecycleWorkerSeqLocal());

    DeleteLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_TAG);
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE);
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY);

    DL_ResetNpcDirectiveExecutionState(oNpc, DL_NPC_RESET_DIRECTIVE_EXEC_ALL);

    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_CLEANUP_CNT, GetLocalInt(oModule, DL_L_MODULE_CLEANUP_CNT) + 1);

    if (sEgressReason == "")
    {
        return;
    }
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

int DL_IsNpcLifecycleEventKind(int nEventKind)
{
    return nEventKind == DL_NPC_EVENT_SPAWN || nEventKind == DL_NPC_EVENT_DEATH;
}

void DL_HandleNpcUserDefined(object oNpc, int nUserDefined)
{
    if (nUserDefined != DL_UD_PIPELINE_NPC_EVENT)
    {
        return;
    }

    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nEventKind = GetLocalInt(oNpc, DL_L_NPC_EVENT_KIND);
    if (!DL_IsNpcLifecycleEventKind(nEventKind))
    {
        return;
    }

    if (nEventKind == DL_NPC_EVENT_DEATH)
    {
        DL_CleanupNpcRuntimeState(oNpc, "death");
        if (!DL_IsRuntimeEnabled())
        {
            return;
        }
    }
    else if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    DL_RecordNpcLifecycleEvent(oNpc, nEventKind);

    if (nEventKind == DL_NPC_EVENT_SPAWN)
    {
        if (!DL_IsActivePipelineNpc(oNpc))
        {
            return;
        }

        DL_InitNpcRuntimeState(oNpc, "spawn");

        DL_RegisterNpc(oNpc);
        DL_ReconcileNpcAreaRegistration(oNpc);
        DL_RequestResync(oNpc, 1);
        DL_ProcessResync(oNpc);
        return;
    }
}
