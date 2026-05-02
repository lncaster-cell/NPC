// Daily Life unified transition execution engine.
// Canonical input contract:
// - oNpc: NPC being transitioned
// - oEntryWp: route-discovered transition entry waypoint
// - sDiagPrefix: execution context prefix ("", "routed", "cross_area", ...)

int DL_JumpNpcToTransitionExit(object oNpc, location lExit, string sStatus = "", string sDiagnostic = "")
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    object oExitArea = GetAreaFromLocation(lExit);
    if (!GetIsObjectValid(oExitArea) || GetObjectType(oExitArea) != OBJECT_TYPE_AREA)
    {
        if (sStatus != "")
        {
            DL_SetTransitionState(oNpc, sStatus, sDiagnostic, "");
        }
        return FALSE;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lExit));
    return TRUE;
}

int DL_ExecuteTransitionDriver(object oNpc, object oEntryWp, location lExit, object oExitWp, string sJumpDiagnostic = DL_TRANSITION_DIAG_IN_PROGRESS)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    if (sDriver == "" || sDriver == DL_TRANSITION_DRIVER_NONE || sDriver == DL_TRANSITION_DRIVER_TRIGGER)
    {
        DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);
        DL_JumpNpcToTransitionExit(oNpc, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sJumpDiagnostic);
        return TRUE;
    }

    if (sDriver == DL_TRANSITION_DRIVER_DOOR)
    {
        object oDoor = DL_ResolveTransitionDriverObject(oEntryWp);
        if (!GetIsObjectValid(oDoor) || GetObjectType(oDoor) != OBJECT_TYPE_DOOR)
        {
            DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_DRIVER_MISSING, DL_TRANSITION_DIAG_DRIVER_REQUIRED, "");
            return TRUE;
        }

        DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);
        AssignCommand(oNpc, ClearAllActions(TRUE));
        if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN))
        {
            AssignCommand(oNpc, DoDoorAction(oDoor, DOOR_ACTION_OPEN));
        }
        DL_JumpNpcToTransitionExit(oNpc, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sJumpDiagnostic);
        return TRUE;
    }

    DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_DRIVER_UNKNOWN, DL_TRANSITION_DIAG_DRIVER_UNKNOWN, "");
    return TRUE;
}

int DL_ExecuteTransitionEngine(object oNpc, object oEntryWp, string sDiagPrefix)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    if (!DL_WaypointHasTransition(oEntryWp))
    {
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
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
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != DL_TRANSITION_STATUS_MOVING_TO_ENTRY)
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
    return DL_ExecuteTransitionDriver(oNpc, oEntryWp, lExit, oExitWp, sDiagPrefix + "_" + DL_TRANSITION_DIAG_IN_PROGRESS);
}
