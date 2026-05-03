// Daily Life canonical Nav Router.
//
// Contract:
// - Selects the next transition entry needed to reach a target waypoint.
// - Delegates execution of that one transition to Transition Executor.
// - Does not reserve destinations and does not play animations.

object DL_FindDirectNavZoneEntryToTarget(object oNpc, object oTarget)
{
    string sTargetZone = DL_GetWaypointNavZone(oTarget);
    if (sTargetZone == "")
    {
        return OBJECT_INVALID;
    }

    string sCurrentZone = DL_InferNpcNavZoneFromAreaRoutes(oNpc);
    if (sCurrentZone == "")
    {
        return OBJECT_INVALID;
    }

    return DL_FindDirectNavZoneEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
}

object DL_FindTwoHopNavZoneEntryToTarget(object oNpc, object oTarget)
{
    string sTargetZone = DL_GetWaypointNavZone(oTarget);
    if (sTargetZone == "")
    {
        return OBJECT_INVALID;
    }

    string sCurrentZone = DL_InferNpcNavZoneFromAreaRoutes(oNpc);
    if (sCurrentZone == "")
    {
        return OBJECT_INVALID;
    }

    return DL_FindTwoHopNavZoneEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
}

object DL_FindNextTransitionEntryToTarget(object oNpc, object oTarget)
{
    if (!DL_IsValidNpcObject(oNpc) || !DL_IsValidWaypointObject(oTarget))
    {
        return OBJECT_INVALID;
    }

    object oEntry = DL_FindCrossAreaNavigationRouteEntryToTarget(oNpc, oTarget);
    if (GetIsObjectValid(oEntry))
    {
        return oEntry;
    }

    oEntry = DL_FindDirectNavZoneEntryToTarget(oNpc, oTarget);
    if (GetIsObjectValid(oEntry))
    {
        return oEntry;
    }

    return DL_FindTwoHopNavZoneEntryToTarget(oNpc, oTarget);
}

// DO NOT DUPLICATE: canonical router entrypoint (selects entry only).
int DL_TryRouteToTarget(object oNpc, object oTarget)
{
    if (!DL_IsValidNpcObject(oNpc) || !DL_IsValidWaypointObject(oTarget))
    {
        return FALSE;
    }

    object oEntry = DL_FindNextTransitionEntryToTarget(oNpc, oTarget);
    if (!DL_IsValidWaypointObject(oEntry))
    {
        return FALSE;
    }

    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oEntry, DL_DIAG_CTX_ROUTED);
}
