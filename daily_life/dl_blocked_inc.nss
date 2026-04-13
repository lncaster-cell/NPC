const string DL_L_NPC_BLOCKED_OBJ = "dl_npc_blocked_obj";
const string DL_L_NPC_BLOCKED_TAG = "dl_npc_blocked_tag";
const string DL_L_NPC_BLOCKED_TYPE = "dl_npc_blocked_type";
const string DL_L_NPC_BLOCKED_DIAGNOSTIC = "dl_npc_blocked_diagnostic";
const string DL_L_NPC_BLOCKED_BUSY = "dl_npc_blocked_busy";

const int DL_NPC_EVENT_BLOCKED = 3;
const float DL_BLOCKED_OPEN_COOLDOWN = 1.5;

void DL_ClearNpcBlockedSignal(object oNpc)
{
    DeleteLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_TAG);
    DeleteLocalInt(oNpc, DL_L_NPC_BLOCKED_TYPE);
}

void DL_ClearNpcBlockedBusySelf()
{
    DeleteLocalInt(OBJECT_SELF, DL_L_NPC_BLOCKED_BUSY);
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
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_busy");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    object oBlocker = GetLocalObject(oNpc, DL_L_NPC_BLOCKED_OBJ);
    if (!GetIsObjectValid(oBlocker))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_invalid_object");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    if (GetObjectType(oBlocker) != OBJECT_TYPE_DOOR)
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_by_creature");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (nDirective != DL_DIR_WORK && nDirective != DL_DIR_SLEEP)
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_outside_route_directive");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    if (!GetIsDoorActionPossible(oBlocker, DOOR_ACTION_OPEN))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "door_open_not_possible");
        DL_ClearNpcBlockedSignal(oNpc);
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_BLOCKED_BUSY, TRUE);
    SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "opening_blocking_door");
    DL_ClearNpcBlockedSignal(oNpc);

    AssignCommand(oNpc, ActionOpenDoor(oBlocker));
    DelayCommand(DL_BLOCKED_OPEN_COOLDOWN, DL_ClearNpcBlockedBusySelf());
}
