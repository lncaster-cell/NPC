// Daily Life canonical Transition Executor.
//
// Contract:
// - Canonical executor for all transition driver paths (routed + cross-area).
// - Executes exactly one transition entry selected by Nav Router.
// - Does not choose routes.
// - Supports same-area and cross-area exit resolution.
// - Uses existing transition metadata and driver semantics.


int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix)
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
        DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_METADATA_MISSING, DL_TRANSITION_DIAG_METADATA_REQUIRED, sDiagPrefix);
        return TRUE;
    }

    if (GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oEntryWp)) > DL_TRANSITION_ENTRY_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "moving_to_entry")
        {
            DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_MOVING_TO_ENTRY, DL_TRANSITION_DIAG_MOVING_TO_ENTRY, sDiagPrefix);
            AssignCommand(oNpc, ClearAllActions(TRUE));
            AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntryWp), TRUE));
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oEntryWp);
    if (!GetIsObjectValid(oExitWp))
    {
        DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_EXIT_MISSING, DL_TRANSITION_DIAG_EXIT_REQUIRED, sDiagPrefix);
        return TRUE;
    }

    location lExit = GetLocation(oExitWp);
    DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_TRANSITIONING, DL_TRANSITION_DIAG_IN_PROGRESS, sDiagPrefix);
    DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);

    if (sDriver == "" || sDriver == DL_TRANSITION_DRIVER_NONE || sDriver == DL_TRANSITION_DRIVER_TRIGGER)
    {
        DL_JumpNpcToTransitionExit(oNpc, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sDiagPrefix + "_" + DL_TRANSITION_DIAG_IN_PROGRESS);
        return TRUE;
    }

    if (sDriver == DL_TRANSITION_DRIVER_DOOR)
    {
        object oDoor = DL_ResolveTransitionDriverObject(oEntryWp);
        if (!GetIsObjectValid(oDoor) || GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
        {
            DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_DRIVER_MISSING, DL_TRANSITION_DIAG_DRIVER_REQUIRED, sDiagPrefix);
            return TRUE;
        }

        AssignCommand(oNpc, ClearAllActions(TRUE));
        if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
        {
            AssignCommand(oNpc, DoDoorAction(oDoor, DOOR_ACTION_OPEN));
        }
        DL_JumpNpcToTransitionExit(oNpc, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sDiagPrefix + "_" + DL_TRANSITION_DIAG_IN_PROGRESS);
        return TRUE;
    }

    DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_DRIVER_UNKNOWN, DL_TRANSITION_DIAG_DRIVER_UNKNOWN, sDiagPrefix);
    return TRUE;
}

int DL_TryExecuteRoutedTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntryWp, DL_DIAG_CTX_ROUTED);
}
