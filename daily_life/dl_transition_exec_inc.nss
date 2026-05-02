// Daily Life canonical Transition Executor.
//
// Contract:
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Supports same-area and cross-area exit resolution.
// - Uses existing transition metadata and driver semantics.

int DL_TryExecuteRoutedTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    if (!DL_WaypointHasTransition(oEntryWp))
    {
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_ID, sTransitionId);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, GetTag(oEntryWp));

    if (sExitTag == "" && (sKind == "" || sTransitionId == "") && !DL_IsAutoNavTag(GetTag(oEntryWp)))
    {
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "metadata_missing");
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_transition_exit_tag_or_kind_id_on_entry_waypoint");
        return TRUE;
    }

    if (GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oEntryWp)) > DL_TRANSITION_ENTRY_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "moving_to_entry")
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "moving_to_entry");
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "moving_to_routed_transition_entry");
            AssignCommand(oNpc, ClearAllActions(TRUE));
            AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntryWp), TRUE));
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveCrossAreaTransitionExitWaypointFromEntry(oEntryWp);
    if (!GetIsObjectValid(oExitWp))
    {
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "exit_missing");
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_valid_routed_transition_exit_waypoint");
        return TRUE;
    }

    location lExit = GetLocation(oExitWp);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "transitioning");
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "routed_transition_in_progress");
    DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);

    if (sDriver == "" || sDriver == DL_TRANSITION_DRIVER_NONE || sDriver == DL_TRANSITION_DRIVER_TRIGGER)
    {
        DL_JumpNpcToTransitionExit(oNpc, lExit, "transitioning", "routed_transition_in_progress");
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
        DL_JumpNpcToTransitionExit(oNpc, lExit, "transitioning", "routed_transition_in_progress");
        return TRUE;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "driver_unknown");
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "unknown_transition_driver");
    return TRUE;
}
