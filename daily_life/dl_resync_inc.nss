string DL_L_NPC_RESYNC_PENDING = "dl_npc_resync_pending";
string DL_L_NPC_RESYNC_REASON = "dl_npc_resync_reason";

const string DL_L_MODULE_RESYNC_REQ = "dl_module_resync_req";

const int DL_RESYNC_NONE = 0;
const int DL_RESYNC_SPAWN = 1;
const int DL_RESYNC_USER = 2;
const int DL_RESYNC_AREA_ENTER = 3;

void DL_SetNpcResyncState(object oNpc, int bPending, int nReason)
{
    SetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING, bPending == TRUE ? TRUE : FALSE);
    if (bPending == TRUE)
    {
        SetLocalInt(oNpc, DL_L_NPC_RESYNC_REASON, nReason);
        return;
    }

    DeleteLocalInt(oNpc, DL_L_NPC_RESYNC_REASON);
}

int DL_IsNpcResyncPending(object oNpc)
{
    return GetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING) == TRUE;
}

int DL_GetNpcResyncReason(object oNpc)
{
    return GetLocalInt(oNpc, DL_L_NPC_RESYNC_REASON);
}

void DL_RequestResync(object oNpc, int nReason)
{
    if (!DL_IsPipelineNpc(oNpc))
    {
        return;
    }

    if (nReason < DL_RESYNC_NONE || nReason > DL_RESYNC_AREA_ENTER)
    {
        nReason = DL_RESYNC_USER;
    }

    DL_SetNpcResyncState(oNpc, TRUE, nReason);

    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_RESYNC_REQ, GetLocalInt(oModule, DL_L_MODULE_RESYNC_REQ) + 1);
}

void DL_ProcessResync(object oNpc)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    DL_ReconcileNpcAreaRegistration(oNpc);

    if (!DL_IsNpcResyncPending(oNpc))
    {
        return;
    }

    int nReason = DL_GetNpcResyncReason(oNpc);
    if (nReason == DL_RESYNC_SPAWN || nReason == DL_RESYNC_USER || nReason == DL_RESYNC_AREA_ENTER)
    {
        int nDirective = DL_ResolveNpcDirective(oNpc);
        DL_ApplyDirectiveSkeleton(oNpc, nDirective);
        DL_MaybeLogNpcDiagnostic(oNpc, "resync", TRUE);
    }

    DL_SetNpcResyncState(oNpc, FALSE, DL_RESYNC_NONE);
}
