const string DL_L_NPC_BLOCKED_OBJ = "dl_npc_blocked_obj";
const string DL_L_NPC_BLOCKED_TAG = "dl_npc_blocked_tag";
const string DL_L_NPC_BLOCKED_TYPE = "dl_npc_blocked_type";
const string DL_L_NPC_BLOCKED_BUSY = "dl_npc_blocked_busy";

const float DL_BLOCKED_OPEN_COOLDOWN = 3.0;
const float DL_BLOCKED_REISSUE_DELAY = 2.2;

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective);

string DL_GetBlockedDiagnosticLocal()
{
    return "dl_npc_blocked_diagnostic";
}

int DL_IsBlockedReissueDirective(int nDirective)
{
    return nDirective == DL_DIR_SLEEP ||
           nDirective == DL_DIR_WORK ||
           nDirective == DL_DIR_MEAL ||
           nDirective == DL_DIR_CHILL ||
           nDirective == DL_DIR_SOCIAL ||
           nDirective == DL_DIR_PUBLIC;
}

void DL_ClearNpcBlockedSignal(object oNpc)
{
    DeleteLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_TAG);
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE);
}

void DL_ClearNpcBlockedBusy(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY);
}

void DL_ReissueNpcDirectiveAfterBlocked(object oNpc)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (!DL_IsBlockedReissueDirective(nDirective))
    {
        SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "blocked_reissue_skipped_no_active_route_directive");
        return;
    }

    DeleteLocalString(oNpc, DL_GetBlockedDiagnosticLocal());
    DL_ApplyDirectiveSkeleton(oNpc, nDirective);
}

void DL_RequestNpcBlockedSignal(object oNpc, object oBlocker)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (!GetIsObjectValid(oBlocker))
    {
        return;
    }

    SetLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ, oBlocker);
    SetLocalString(oNpc, DL_L_NPC_BLOCKED_TAG, GetTag(oBlocker));
    SetLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE, GetObjectType(oBlocker));

    SetLocalInt(oNpc, DL_L_NPC_EVENT_KIND, DL_NPC_EVENT_BLOCKED);
    SetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ, GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ) + 1);

    SignalEvent(oNpc, EventUserDefined(DL_UD_PIPELINE_NPC_EVENT));
}

void DL_HandleNpcBlocked(object oNpc)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY) == TRUE)
    {
        SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "blocked_busy");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    object oBlocker = GetLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    if (!GetIsObjectValid(oBlocker))
    {
        SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "blocked_invalid_object");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    if (GetObjectType(oBlocker) != OBJECT_TYPE_DOOR)
    {
        SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "blocked_by_non_door");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (!DL_IsBlockedReissueDirective(nDirective))
    {
        SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "blocked_without_active_route_directive");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    if (!GetIsDoorActionPossible(oBlocker, DOOR_ACTION_OPEN))
    {
        SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "door_open_not_possible");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY, TRUE);
    SetLocalString(oNpc, DL_GetBlockedDiagnosticLocal(), "opening_blocking_door");
    DL_ClearNpcBlockedSignal(oNpc);

    DL_TryResetActionQueue(oNpc, TRUE, DL_RESET_REASON_BLOCKED);
    AssignCommand(oNpc, DoDoorAction(oBlocker, DOOR_ACTION_OPEN));
    DelayCommand(DL_BLOCKED_REISSUE_DELAY, DL_ReissueNpcDirectiveAfterBlocked(oNpc));
    DelayCommand(DL_BLOCKED_OPEN_COOLDOWN, DL_ClearNpcBlockedBusy(oNpc));
}
