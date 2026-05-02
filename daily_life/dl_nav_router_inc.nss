// Daily Life canonical Nav Router.
//
// Contract:
// - Selects the next transition entry needed to reach a target waypoint.
// - Delegates execution of that one transition to Transition Executor.
// - Does not reserve destinations and does not play animations.

object DL_FindNextTransitionEntryToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return OBJECT_INVALID;
    }

    object oEntry = DL_FindCrossAreaNavigationRouteEntryToTarget(oNpc, oTarget);
    if (GetIsObjectValid(oEntry))
    {
        return oEntry;
    }

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

    oEntry = DL_FindDirectNavZoneEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
    if (GetIsObjectValid(oEntry))
    {
        return oEntry;
    }

    return DL_FindTwoHopNavZoneEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
}

int DL_TryRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    object oEntry = DL_FindNextTransitionEntryToTarget(oNpc, oTarget);
    if (!GetIsObjectValid(oEntry))
    {
        return FALSE;
    }

    return DL_TryExecuteRoutedTransitionEntryWaypoint(oNpc, oEntry);
}
