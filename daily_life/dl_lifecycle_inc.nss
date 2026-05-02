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
const int DL_NPC_RESET_DIRECTIVE_EXEC_ALL    =
    DL_NPC_RESET_DIRECTIVE_EXEC_SLEEP |
    DL_NPC_RESET_DIRECTIVE_EXEC_WORK |
    DL_NPC_RESET_DIRECTIVE_EXEC_MEAL |
    DL_NPC_RESET_DIRECTIVE_EXEC_CHILL |
    DL_NPC_RESET_DIRECTIVE_EXEC_SOCIAL |
    DL_NPC_RESET_DIRECTIVE_EXEC_PUBLIC;

void DL_ResetNpcDirectiveExecutionState(object oNpc, int nDirectiveMask)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_SLEEP)
    {
        DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_TARGET_VALID);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_WORK)
    {
        DeleteLocalObject(oNpc, DL_L_NPC_WORK_TARGET);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_MEAL)
    {
        DeleteLocalObject(oNpc, DL_L_NPC_MEAL_TARGET);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_CHILL)
    {
        DeleteLocalObject(oNpc, DL_L_NPC_CHILL_TARGET);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_SOCIAL)
    {
        DeleteLocalObject(oNpc, DL_L_NPC_SOCIAL_TARGET);
        DeleteLocalObject(oNpc, DL_L_NPC_SOCIAL_PARTNER);
    }
    if (nDirectiveMask & DL_NPC_RESET_DIRECTIVE_EXEC_PUBLIC)
    {
        DeleteLocalObject(oNpc, DL_L_NPC_PUBLIC_TARGET);
    }
}

void DL_InitNpcRuntimeState(object oNpc, string sIngressReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    // lifecycle ownership map (NPC locals):
    // - DL_L_NPC_EVENT_KIND
    // - DL_L_NPC_EVENT_SEQ
    // - DL_L_NPC_RESYNC_PENDING
    // - DL_L_NPC_RESYNC_REASON
    SetLocalInt(oNpc, DL_L_NPC_EVENT_KIND, DL_NPC_EVENT_SPAWN);
    SetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_RESYNC_REASON, DL_RESYNC_NONE);

    // Keep explicit no-op use to make ingress reason part of canonical API contract.
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
    SetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_RESYNC_REASON, DL_RESYNC_NONE);
    DeleteLocalInt(oNpc, DL_L_NPC_WORKER_SEQ);

    // blocked lifecycle cleanup
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

    // Death cleanup is an invariant: runtime state must be cleaned even if runtime is disabled.
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
        // Spawn processing remains runtime-gated by design.
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
        DL_RequestResync(oNpc, DL_RESYNC_SPAWN);
        DL_ProcessResync(oNpc);
        return;
    }
}
