// Daily Life interzone transition helper layer.
// Route-side configuration uses a single entry waypoint in the source area.
// The entry waypoint carries transition metadata and optional door/trigger driver.
// Exit waypoint remains a shared landing point in the destination context.

const string DL_L_WP_TRANSITION_KIND = "dl_transition_kind";
const string DL_L_WP_TRANSITION_ID = "dl_transition_id";
const string DL_L_WP_TRANSITION_DRIVER = "dl_transition_driver";
const string DL_L_WP_TRANSITION_DRIVER_TAG = "dl_transition_driver_tag";

const string DL_L_NPC_TRANSITION_KIND = "dl_npc_transition_kind";
const string DL_L_NPC_TRANSITION_ID = "dl_npc_transition_id";
const string DL_L_NPC_TRANSITION_TARGET = "dl_npc_transition_target";
const string DL_L_NPC_TRANSITION_STATUS = "dl_npc_transition_status";
const string DL_L_NPC_TRANSITION_DIAGNOSTIC = "dl_npc_transition_diagnostic";

const string DL_TRANSITION_KIND_AREA_LINK = "area_link";
const string DL_TRANSITION_KIND_LOCAL_JUMP = "local_jump";

const string DL_TRANSITION_DRIVER_NONE = "none";
const string DL_TRANSITION_DRIVER_DOOR = "door";
const string DL_TRANSITION_DRIVER_TRIGGER = "trigger";

const float DL_TRANSITION_ENTRY_RADIUS = 1.60;
const float DL_TRANSITION_DOOR_DELAY = 1.00;

object DL_GetTransitionWaypointByTag(string sTag)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oWp = GetWaypointByTag(sTag);
    if (!GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    return oWp;
}

string DL_GetWaypointTransitionKind(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_KIND);
}

string DL_GetWaypointTransitionId(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_ID);
}

string DL_GetWaypointTransitionDriver(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_DRIVER);
}

string DL_GetWaypointTransitionDriverTag(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_DRIVER_TAG);
}

void DL_ClearTransitionExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_KIND);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_ID);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
}

int DL_WaypointHasTransition(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return FALSE;
    }

    return DL_GetWaypointTransitionKind(oWp) != "" || DL_GetWaypointTransitionId(oWp) != "";
}

object DL_ResolveTransitionExitWaypoint(string sKind, string sTransitionId)
{
    if (sKind == DL_TRANSITION_KIND_AREA_LINK)
    {
        return DL_GetTransitionWaypointByTag("dl_xfer_" + sTransitionId + "_to");
    }

    if (sKind == DL_TRANSITION_KIND_LOCAL_JUMP)
    {
        return DL_GetTransitionWaypointByTag("dl_jump_" + sTransitionId + "_to");
    }

    return OBJECT_INVALID;
}

object DL_ResolveTransitionDriverObject(object oEntryWp)
{
    string sDriverTag = DL_GetWaypointTransitionDriverTag(oEntryWp);
    if (sDriverTag == "")
    {
        return OBJECT_INVALID;
    }

    object oDriver = GetObjectByTag(sDriverTag);
    if (!GetIsObjectValid(oDriver))
    {
        return OBJECT_INVALID;
    }

    if (GetArea(oDriver) != GetArea(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    return oDriver;
}

void DL_JumpNpcToTransitionExit(object oNpc, location lExit)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lExit));
}

int DL_TryExecuteTransitionAtWaypoint(object oNpc, object oEntryWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    if (sKind == "" && sTransitionId == "")
    {
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_ID, sTransitionId);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, GetTag(oEntryWp));

    if (sKind == "" || sTransitionId == "")
    {
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "metadata_missing");
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_transition_kind_and_id_on_entry_waypoint");
        return TRUE;
    }

    if (GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oEntryWp)) > DL_TRANSITION_ENTRY_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "moving_to_entry")
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "moving_to_entry");
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "moving_to_transition_entry");
            AssignCommand(oNpc, ClearAllActions(TRUE));
            AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntryWp), TRUE));
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveTransitionExitWaypoint(sKind, sTransitionId);
    if (!GetIsObjectValid(oExitWp))
    {
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "exit_missing");
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_transition_exit_waypoint");
        return TRUE;
    }

    location lExit = GetLocation(oExitWp);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "transitioning");
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "transition_in_progress");

    if (sDriver == "" || sDriver == DL_TRANSITION_DRIVER_NONE || sDriver == DL_TRANSITION_DRIVER_TRIGGER)
    {
        DL_JumpNpcToTransitionExit(oNpc, lExit);
        return TRUE;
    }

    if (sDriver == DL_TRANSITION_DRIVER_DOOR)
    {
        object oDoor = DL_ResolveTransitionDriverObject(oEntryWp);
        if (!GetIsObjectValid(oDoor) || GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "driver_missing");
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_valid_transition_door");
            return TRUE;
        }

        AssignCommand(oNpc, ClearAllActions(TRUE));
        if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
        {
            AssignCommand(oNpc, DoDoorAction(oDoor, DOOR_ACTION_OPEN));
        }
        AssignCommand(oNpc, DelayCommand(DL_TRANSITION_DOOR_DELAY, ActionJumpToLocation(lExit)));
        return TRUE;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "driver_unknown");
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "unknown_transition_driver");
    return TRUE;
}
