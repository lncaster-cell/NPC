// Daily Life simple transition/navigation helper.
// Builder contract:
//   waypoint tag: <from_zone>__<to_zone>
//   route local:  route_<current_zone>__<target_zone> = <next_zone>

const string DL_L_NPC_NAV_ZONE_CURRENT = "dl_npc_nav_zone_current";
const string DL_L_NPC_NAV_ZONE_AREA = "dl_npc_nav_zone_area";
const string DL_L_NPC_TRANSITION_STATUS = "dl_npc_transition_status";
const string DL_L_NPC_TRANSITION_TARGET = "dl_npc_transition_target";
const string DL_L_NPC_TRANSITION_DIAGNOSTIC = "dl_npc_transition_diagnostic";
const string DL_L_NPC_NAV_DEBUG_CURRENT = "dl_nav_debug_current";
const string DL_L_NPC_NAV_DEBUG_TARGET = "dl_nav_debug_target";
const string DL_L_NPC_NAV_DEBUG_NEXT = "dl_nav_debug_next";
const string DL_L_NPC_NAV_DEBUG_REASON = "dl_nav_debug_reason";
const string DL_L_NPC_NAV_DEBUG_NPC_AREA = "dl_nav_debug_npc_area";
const string DL_L_NPC_NAV_DEBUG_TARGET_AREA = "dl_nav_debug_target_area";
const string DL_L_NPC_NAV_DEBUG_CURRENT_ZONE = "dl_nav_debug_current_zone";
const string DL_L_NPC_NAV_DEBUG_TARGET_ZONE = "dl_nav_debug_target_zone";
const string DL_L_NPC_NAV_DEBUG_OLD_TRANSITION_STATUS = "dl_nav_debug_old_transition_status";
const string DL_L_NPC_NAV_DEBUG_FOCUS_TARGET = "dl_nav_debug_focus_target";
const string DL_L_NPC_NAV_DEBUG_CURRENT_ACTION = "dl_nav_debug_current_action";
const string DL_L_NPC_NAV_DEBUG_TRANSITION_TARGET = "dl_nav_debug_transition_target";
const string DL_L_NPC_NAV_DEBUG_ANCHOR_TAG = "dl_nav_debug_anchor_tag";

const string DL_NAV_DELIMITER = "__";
const string DL_NAV_ROUTE_PREFIX = "route_";
const float DL_NAV_ENTRY_RADIUS = 1.60;
const float DL_NAV_ZONE_INFER_RADIUS = 1.80;
const string DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA = "transition_to_area";
const int DL_NAV_AREA_SCAN_CAP = 128;
const int DL_NAV_TRANSITION_TAG_SEARCH_CAP = 64;

const string DL_L_AREA_NAV_READY = "dl_area_nav_ready";
const string DL_L_AREA_NAV_COUNT = "dl_area_nav_count";
const string DL_L_AREA_NAV_SLOT_PREFIX = "dl_area_nav_";
const int DL_AREA_NAV_ROUTE_CAP = 32;
const string DL_L_AREA_NAV_ZONE_ID = "dl_nav_zone_id";

// Implemented in dl_worker_inc / dl_registry_inc; kept as narrow local forward
// declarations so transition code can finalize queued jumps without changing
// include order.
void DL_RequestTransitionRegistryHandoff(object oNpc, object oOldArea, object oTargetArea);
int DL_EnsureNpcRegisteredInCurrentArea(object oNpc);
void DL_ClearNpcRegistryLocals(object oNpc);
void DL_WorkerTouchNpc(object oNpc);
int DL_RemoveStaleNpcReferenceFromAreaRegistry(object oArea, object oNpc);
void DL_BsmithTraceStage(object oNpc, string sStage, string sNote);

string DL_GetAreaNavigationSlotKey(int nSlot)
{
    if (nSlot < 0) nSlot = 0;
    return DL_L_AREA_NAV_SLOT_PREFIX + IntToString(nSlot);
}

void DL_NavSetDebug(object oNpc, string sCurrentZone, string sTargetZone, string sNextZone, string sReason)
{
    if (!GetIsObjectValid(oNpc)) return;
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_CURRENT, sCurrentZone);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_TARGET, sTargetZone);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_NEXT, sNextZone);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_REASON, sReason);
}

void DL_NavSetPostTransitionCompleteDebug(
    object oNpc,
    object oTargetAnchor,
    string sCurrentZone,
    string sTargetZone,
    string sOldTransitionStatus
)
{
    if (!GetIsObjectValid(oNpc)) return;

    object oNpcArea = GetArea(oNpc);
    object oTargetArea = GetArea(oTargetAnchor);
    string sNpcArea = "";
    string sTargetArea = "";
    if (GetIsObjectValid(oNpcArea)) sNpcArea = GetTag(oNpcArea);
    if (GetIsObjectValid(oTargetArea)) sTargetArea = GetTag(oTargetArea);

    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_NPC_AREA, sNpcArea);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_TARGET_AREA, sTargetArea);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_CURRENT_ZONE, sCurrentZone);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_TARGET_ZONE, sTargetZone);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_OLD_TRANSITION_STATUS, sOldTransitionStatus);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_FOCUS_TARGET, GetTag(oTargetAnchor));
    SetLocalInt(oNpc, DL_L_NPC_NAV_DEBUG_CURRENT_ACTION, GetCurrentAction(oNpc));
}

void DL_NavClearFocusMoveIssueStateAfterJump(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;

    // Focus movement may have been prepared before a same-area pseudo-transition.
    // After the jump, force the focus directive to issue a fresh local movement
    // command from the exit waypoint to the final anchor.
    DeleteLocalInt(oNpc, "dl_focus_anchor_action_stamp");
    DeleteLocalString(oNpc, "dl_focus_anchor_action_target");
}

string DL_NavMakeTransitionTag(string sFromZone, string sToZone)
{
    if (sFromZone == "" || sToZone == "") return "";
    return sFromZone + DL_NAV_DELIMITER + sToZone;
}

string DL_NavMakeRouteKey(string sCurrentZone, string sTargetZone)
{
    if (sCurrentZone == "" || sTargetZone == "") return "";
    return DL_NAV_ROUTE_PREFIX + sCurrentZone + DL_NAV_DELIMITER + sTargetZone;
}

string DL_NavGetNpcCurrentZone(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return "";
    return GetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
}

void DL_NavSetTransitionFinalizeSkippedDebug(
    object oNpc,
    object oTargetAnchor,
    string sReason,
    string sTransitionStatus
)
{
    if (!GetIsObjectValid(oNpc)) return;

    object oNpcArea = GetArea(oNpc);
    object oTargetArea = OBJECT_INVALID;
    if (GetIsObjectValid(oTargetAnchor)) oTargetArea = GetArea(oTargetAnchor);

    string sNpcArea = "";
    string sTargetArea = "";
    string sTransitionTarget = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    string sAnchorTag = "";

    if (GetIsObjectValid(oNpcArea)) sNpcArea = GetTag(oNpcArea);
    if (GetIsObjectValid(oTargetArea)) sTargetArea = GetTag(oTargetArea);
    if (GetIsObjectValid(oTargetAnchor)) sAnchorTag = GetTag(oTargetAnchor);

    DL_NavSetDebug(oNpc, DL_NavGetNpcCurrentZone(oNpc), sTransitionTarget, "", sReason);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC,
        sReason +
        " npc_area=" + sNpcArea +
        " target_area=" + sTargetArea +
        " transition_status=" + sTransitionStatus +
        " transition_target=" + sTransitionTarget +
        " anchor_tag=" + sAnchorTag
    );
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_NPC_AREA, sNpcArea);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_TARGET_AREA, sTargetArea);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_OLD_TRANSITION_STATUS, sTransitionStatus);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_TRANSITION_TARGET, sTransitionTarget);
    SetLocalString(oNpc, DL_L_NPC_NAV_DEBUG_ANCHOR_TAG, sAnchorTag);
}

void DL_NavSetNpcCurrentZone(object oNpc, string sZone)
{
    if (!GetIsObjectValid(oNpc)) return;
    if (sZone == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
        DeleteLocalString(oNpc, DL_L_NPC_NAV_ZONE_AREA);
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT, sZone);

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        SetLocalString(oNpc, DL_L_NPC_NAV_ZONE_AREA, GetTag(oArea));
    }
}

void DL_ClearTransitionExecutionState(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
}

void DL_NavSetState(object oNpc, string sStatus, string sTargetZone, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc)) return;
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, sStatus);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, sTargetZone);
    if (sDiagnostic == "") DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
    else SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sDiagnostic);
}

string DL_NavGetNextZone(object oNpc, string sTargetZone)
{
    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    string sRouteKey = DL_NavMakeRouteKey(sCurrentZone, sTargetZone);
    if (sRouteKey == "") return "";

    object oArea = GetArea(oNpc);
    string sNextZone = "";
    if (GetIsObjectValid(oArea)) sNextZone = GetLocalString(oArea, sRouteKey);
    if (sNextZone != "") return sNextZone;

    return GetLocalString(GetModule(), sRouteKey);
}

object DL_NavFindTransitionByTag(string sTag)
{
    if (sTag == "") return OBJECT_INVALID;

    int nIndex = 0;
    while (nIndex < DL_NAV_TRANSITION_TAG_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTag, nIndex);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetObjectType(oCandidate) == OBJECT_TYPE_WAYPOINT)
        {
            return oCandidate;
        }

        nIndex = nIndex + 1;
    }

    return OBJECT_INVALID;
}

object DL_NavFindTransitionInArea(object oArea, string sFromZone, string sToZone)
{
    if (!GetIsObjectValid(oArea)) return OBJECT_INVALID;

    string sTag = DL_NavMakeTransitionTag(sFromZone, sToZone);
    if (sTag == "") return OBJECT_INVALID;

    int nIndex = 0;
    while (nIndex < DL_NAV_TRANSITION_TAG_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTag, nIndex);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetObjectType(oCandidate) == OBJECT_TYPE_WAYPOINT && GetArea(oCandidate) == oArea)
        {
            return oCandidate;
        }

        nIndex = nIndex + 1;
    }

    return OBJECT_INVALID;
}

string DL_NavGetAreaZoneId(object oArea)
{
    if (!GetIsObjectValid(oArea)) return "";

    string sZone = GetLocalString(oArea, DL_L_AREA_NAV_ZONE_ID);
    if (sZone != "") return sZone;

    return GetTag(oArea);
}

string DL_NavTryResolveZoneFromTransitionWaypoints(object oSubject, int bRequireNearby)
{
    if (!GetIsObjectValid(oSubject)) return "";

    object oArea = GetArea(oSubject);
    if (!GetIsObjectValid(oArea)) return "";

    float fBestDistance = 1000000.0;
    string sBestZone = "";
    int nScanned = 0;
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj) && nScanned < DL_NAV_AREA_SCAN_CAP)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT)
        {
            string sTag = GetTag(oObj);
            int nDelimiter = FindSubString(sTag, DL_NAV_DELIMITER);
            if (nDelimiter > 0)
            {
                string sFromZone = GetSubString(sTag, 0, nDelimiter);
                if (sFromZone != "")
                {
                    float fDistance = GetDistanceBetween(oSubject, oObj);
                    if ((!bRequireNearby || fDistance <= DL_NAV_ZONE_INFER_RADIUS) && fDistance < fBestDistance)
                    {
                        fBestDistance = fDistance;
                        sBestZone = sFromZone;
                    }
                }
            }
        }

        oObj = GetNextObjectInArea(oArea);
        nScanned = nScanned + 1;
    }

    return sBestZone;
}

string DL_NavTryResolveCurrentZoneFromNearbyTransitionWaypoints(object oSubject)
{
    return DL_NavTryResolveZoneFromTransitionWaypoints(oSubject, TRUE);
}

string DL_NavTryResolveTargetZoneFromTransitionWaypoints(object oSubject)
{
    return DL_NavTryResolveZoneFromTransitionWaypoints(oSubject, FALSE);
}

string DL_NavGetAnchorZoneId(object oAnchor)
{
    if (!GetIsObjectValid(oAnchor)) return "";

    string sZone = GetLocalString(oAnchor, DL_L_AREA_NAV_ZONE_ID);
    if (sZone != "") return sZone;

    // Target anchors may be deep inside an isolated same-area pseudo-zone.
    // Use nearest transition waypoint without the short current-zone radius.
    string sZoneFromTransition = DL_NavTryResolveTargetZoneFromTransitionWaypoints(oAnchor);
    if (sZoneFromTransition != "") return sZoneFromTransition;

    return DL_NavGetAreaZoneId(GetArea(oAnchor));
}

string DL_NavTryResolveZoneFromNearbyAnchors(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return "";

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea)) return "";

    float fBestDistance = 1000000.0;
    string sBestZone = "";
    int nScanned = 0;
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj) && nScanned < DL_NAV_AREA_SCAN_CAP)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT)
        {
            string sZone = GetLocalString(oObj, DL_L_AREA_NAV_ZONE_ID);
            if (sZone != "")
            {
                float fDistance = GetDistanceBetween(oNpc, oObj);
                if (fDistance <= DL_NAV_ZONE_INFER_RADIUS && fDistance < fBestDistance)
                {
                    fBestDistance = fDistance;
                    sBestZone = sZone;
                }
            }
        }

        oObj = GetNextObjectInArea(oArea);
        nScanned = nScanned + 1;
    }

    return sBestZone;
}

string DL_NavResolveCurrentZoneFromPosition(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return "";

    string sCurrentZone = DL_NavTryResolveZoneFromNearbyAnchors(oNpc);
    if (sCurrentZone == "") sCurrentZone = DL_NavGetAreaZoneId(GetArea(oNpc));
    return sCurrentZone;
}

void DL_NavSyncCurrentZoneFromArea(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;

    // Same-area pseudo-zones are not discoverable from the area tag alone.
    // Preserve runtime zone state set by actual transition jumps while the NPC
    // remains in the same area. Without this, an NPC standing inside an isolated
    // bedroom can be repeatedly reset back to the area's default zone (for
    // example Hall) and try to re-enter the bedroom from inside it.
    string sExistingZone = GetLocalString(oNpc, DL_L_NPC_NAV_ZONE_CURRENT);
    if (sExistingZone != "")
    {
        object oExistingArea = GetArea(oNpc);
        string sExistingAreaTag = GetLocalString(oNpc, DL_L_NPC_NAV_ZONE_AREA);
        if (!GetIsObjectValid(oExistingArea) || sExistingAreaTag == "" || sExistingAreaTag == GetTag(oExistingArea))
        {
            return;
        }
    }

    string sCurrentZone = DL_NavResolveCurrentZoneFromPosition(oNpc);
    if (sCurrentZone != "")
    {
        DL_NavSetNpcCurrentZone(oNpc, sCurrentZone);
    }
}

void DL_NavPrepareTargetZoneFromAnchor(object oNpc, object oTargetAnchor)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTargetAnchor)) return;

    DL_NavSyncCurrentZoneFromArea(oNpc);

    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    string sTargetZone = DL_NavGetAnchorZoneId(oTargetAnchor);
    if (sTargetZone == "")
    {
        DL_NavSetDebug(oNpc, sCurrentZone, "", "", "target_zone_missing");
        DL_NavSetState(oNpc, "failed", "", "target_zone_missing");
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, sTargetZone);
    DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, "", "prepared");
}

int DL_WaypointHasTransition(object oWp)
{
    if (!GetIsObjectValid(oWp) || GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT) return FALSE;
    string sTag = GetTag(oWp);
    int nDelimiter = FindSubString(sTag, DL_NAV_DELIMITER);
    if (nDelimiter <= 0) return FALSE;
    if (nDelimiter >= GetStringLength(sTag) - 2) return FALSE;
    return TRUE;
}

object DL_ResolveTransitionExitWaypointFromEntry(object oEntryWp)
{
    if (!GetIsObjectValid(oEntryWp) || GetObjectType(oEntryWp) != OBJECT_TYPE_WAYPOINT)
    {
        return OBJECT_INVALID;
    }

    string sTag = GetTag(oEntryWp);
    int nDelimiter = FindSubString(sTag, DL_NAV_DELIMITER);
    if (nDelimiter <= 0 || nDelimiter >= GetStringLength(sTag) - 2)
    {
        return OBJECT_INVALID;
    }

    string sFrom = GetSubString(sTag, 0, nDelimiter);
    int nToStart = nDelimiter + 2;
    string sTo = GetSubString(sTag, nToStart, GetStringLength(sTag) - nToStart);
    if (sFrom == "" || sTo == "")
    {
        return OBJECT_INVALID;
    }

    return DL_NavFindTransitionByTag(DL_NavMakeTransitionTag(sTo, sFrom));
}

void DL_SetPendingTransitionAfterJump(object oNpc, object oOldArea, object oTargetArea, string sTargetZone, string sExitTag)
{
    if (!GetIsObjectValid(oNpc)) return;

    string sOldArea = "";
    string sTargetArea = "";
    if (GetIsObjectValid(oOldArea))
    {
        sOldArea = GetTag(oOldArea);
    }
    if (GetIsObjectValid(oTargetArea))
    {
        sTargetArea = GetTag(oTargetArea);
    }

    object oOldRegArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    int nOldRegSlot = GetLocalInt(oNpc, "dl_npc_reg_slot");
    if (!GetIsObjectValid(oOldRegArea))
    {
        oOldRegArea = oOldArea;
        nOldRegSlot = -1;
    }
    SetLocalObject(oNpc, "dl_transition_old_reg_area", oOldRegArea);
    SetLocalInt(oNpc, "dl_transition_old_reg_slot", nOldRegSlot);

    SetLocalObject(oNpc, "dl_transition_pending_old_area", oOldArea);
    SetLocalString(oNpc, "dl_transition_pending_old_area_tag", sOldArea);
    SetLocalObject(oNpc, "dl_transition_pending_target_area", oTargetArea);
    SetLocalString(oNpc, "dl_transition_pending_target_area_tag", sTargetArea);
    SetLocalString(oNpc, "dl_transition_pending_target_zone", sTargetZone);
    SetLocalString(oNpc, "dl_transition_pending_exit_tag", sExitTag);
    SetLocalInt(oNpc, "dl_transition_pending_finalizer_expected", TRUE);

    SetLocalInt(oNpc, "dl_post_jump_finalizer_called", FALSE);
    SetLocalString(oNpc, "dl_post_jump_current_area", "");
    SetLocalString(oNpc, "dl_post_jump_expected_area", sTargetArea);
    SetLocalString(oNpc, "dl_post_jump_registered_area_after", "");
    SetLocalInt(oNpc, "dl_post_jump_worker_touch_called", FALSE);
    SetLocalString(oNpc, "dl_post_jump_result", "queued");
}

void DL_FinalizeTransitionAfterQueuedJump(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;

    SetLocalInt(oNpc, "dl_post_jump_finalizer_called", TRUE);
    SetLocalInt(oNpc, "dl_post_jump_worker_touch_called", FALSE);

    object oCurrentArea = GetArea(oNpc);
    object oExpectedArea = GetLocalObject(oNpc, "dl_transition_pending_target_area");
    object oOldArea = GetLocalObject(oNpc, "dl_transition_pending_old_area");
    string sTargetZone = GetLocalString(oNpc, "dl_transition_pending_target_zone");
    string sCurrentArea = "";
    string sExpectedArea = GetLocalString(oNpc, "dl_transition_pending_target_area_tag");
    string sOldArea = GetLocalString(oNpc, "dl_transition_pending_old_area_tag");
    string sResult = "post_jump_finalizer_ok";

    if (GetIsObjectValid(oCurrentArea))
    {
        sCurrentArea = GetTag(oCurrentArea);
    }
    if (sExpectedArea == "" && GetIsObjectValid(oExpectedArea))
    {
        sExpectedArea = GetTag(oExpectedArea);
    }
    if (sOldArea == "" && GetIsObjectValid(oOldArea))
    {
        sOldArea = GetTag(oOldArea);
    }

    SetLocalString(oNpc, "dl_post_jump_current_area", sCurrentArea);
    SetLocalString(oNpc, "dl_post_jump_expected_area", sExpectedArea);
    SetLocalString(oNpc, "dl_transition_registry_current_physical_area", sCurrentArea);
    SetLocalString(oNpc, "dl_transition_registry_npc_area", sCurrentArea);

    if (GetLocalInt(oNpc, "dl_transition_pending_finalizer_expected") != TRUE)
    {
        sResult = "post_jump_finalizer_not_expected";
        SetLocalString(oNpc, "dl_post_jump_result", sResult);
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sResult);
        SetLocalString(oNpc, "dl_transition_registry_problem", sResult);
        DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", sResult);
        return;
    }

    string sPendingExitTag = GetLocalString(oNpc, "dl_transition_pending_exit_tag");
    object oPendingExit = DL_NavFindTransitionByTag(sPendingExitTag);
    int bPendingExitValid = GetIsObjectValid(oPendingExit);
    int bJumpTargetWasValid = GetIsObjectValid(oExpectedArea);

    if (GetIsObjectValid(oCurrentArea) &&
        oCurrentArea == oOldArea &&
        oCurrentArea == oExpectedArea &&
        sTargetZone != "" &&
        (bPendingExitValid || bJumpTargetWasValid))
    {
        DL_ClearTransitionExecutionState(oNpc);
        DL_NavClearFocusMoveIssueStateAfterJump(oNpc);
        DL_NavSetNpcCurrentZone(oNpc, sTargetZone);
        DL_NavSetDebug(oNpc, sTargetZone, sTargetZone, "", "post_jump_finalizer_same_area_complete");
        if (GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc" ||
            GetLocalString(oNpc, "dl_transition_registry_problem") == "post_jump_finalizer_area_not_changed" ||
            GetLocalString(oNpc, "dl_transition_registry_problem") == "post_jump_finalizer_registry_repair_failed" ||
            GetLocalString(oNpc, "dl_transition_registry_problem") == "post_jump_finalizer_registry_area_mismatch")
        {
            DeleteLocalString(oNpc, "dl_transition_registry_problem");
        }

        DL_WorkerTouchNpc(oNpc);
        SetLocalInt(oNpc, "dl_post_jump_worker_touch_called", TRUE);
        SetLocalString(oNpc, "dl_transition_registry_worker_touch_area", GetLocalString(oNpc, "dl_worker_touch_area"));
        SetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called", FALSE);

        sResult = "post_jump_finalizer_same_area_complete";
        SetLocalString(oNpc, "dl_post_jump_result", sResult);
        DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", sResult);
        DeleteLocalInt(oNpc, "dl_transition_pending_finalizer_expected");
        return;
    }

    if (!GetIsObjectValid(oCurrentArea) || oCurrentArea == oOldArea)
    {
        sResult = "post_jump_finalizer_area_not_changed";
        SetLocalString(oNpc, "dl_post_jump_result", sResult);
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC,
            sResult +
            " current_area=" + sCurrentArea +
            " expected_area=" + sExpectedArea +
            " old_area=" + sOldArea +
            " target_zone=" + sTargetZone +
            " exit_tag=" + sPendingExitTag
        );
        SetLocalString(oNpc, "dl_transition_registry_problem", sResult);
        return;
    }

    object oRegisteredArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    if (oRegisteredArea != oCurrentArea)
    {
        DL_ClearNpcRegistryLocals(oNpc);
    }

    if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
    {
        sResult = "post_jump_finalizer_registry_repair_failed";
        SetLocalString(oNpc, "dl_post_jump_result", sResult);
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sResult);
        SetLocalString(oNpc, "dl_transition_registry_problem", sResult);
        return;
    }

    oRegisteredArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    object oOldRegArea = GetLocalObject(oNpc, "dl_transition_old_reg_area");
    if (GetIsObjectValid(oOldRegArea) && oOldRegArea != oCurrentArea)
    {
        DL_RemoveStaleNpcReferenceFromAreaRegistry(oOldRegArea, oNpc);
    }
    string sRegisteredAreaAfter = "";
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredAreaAfter = GetTag(oRegisteredArea);
    }
    SetLocalString(oNpc, "dl_post_jump_registered_area_after", sRegisteredAreaAfter);
    SetLocalString(oNpc, "dl_transition_registry_registered_area", sRegisteredAreaAfter);
    SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredAreaAfter);
    SetLocalString(oNpc, "dl_transition_registry_registry_area_after_repair", sRegisteredAreaAfter);

    if (oRegisteredArea != oCurrentArea)
    {
        sResult = "post_jump_finalizer_registry_area_mismatch";
        SetLocalString(oNpc, "dl_post_jump_result", sResult);
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, sResult);
        SetLocalString(oNpc, "dl_transition_registry_problem", sResult);
        return;
    }

    if (GetIsObjectValid(oExpectedArea) && oCurrentArea == oExpectedArea)
    {
        DL_ClearTransitionExecutionState(oNpc);
        DL_NavClearFocusMoveIssueStateAfterJump(oNpc);
        DL_NavSetNpcCurrentZone(oNpc, sTargetZone);
        DL_NavSetDebug(oNpc, sTargetZone, sTargetZone, "", "post_jump_finalizer_complete");
        if (GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc" ||
            GetLocalString(oNpc, "dl_transition_registry_problem") == "post_jump_finalizer_area_not_changed" ||
            GetLocalString(oNpc, "dl_transition_registry_problem") == "post_jump_finalizer_registry_repair_failed" ||
            GetLocalString(oNpc, "dl_transition_registry_problem") == "post_jump_finalizer_registry_area_mismatch")
        {
            DeleteLocalString(oNpc, "dl_transition_registry_problem");
        }
    }
    else
    {
        sResult = "post_jump_finalizer_unexpected_area";
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC,
            sResult +
            " current_area=" + sCurrentArea +
            " expected_area=" + sExpectedArea +
            " exit_tag=" + GetLocalString(oNpc, "dl_transition_pending_exit_tag")
        );
        SetLocalString(oNpc, "dl_transition_registry_problem", sResult);
    }

    DL_WorkerTouchNpc(oNpc);
    SetLocalInt(oNpc, "dl_post_jump_worker_touch_called", TRUE);
    SetLocalString(oNpc, "dl_transition_registry_worker_touch_area", GetLocalString(oNpc, "dl_worker_touch_area"));
    SetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called", TRUE);

    if (GetIsObjectValid(oExpectedArea) && oCurrentArea == oExpectedArea)
    {
        DL_RequestTransitionRegistryHandoff(oNpc, oOldArea, oExpectedArea);
        sResult = "post_jump_finalizer_complete";
    }

    SetLocalString(oNpc, "dl_post_jump_result", sResult);
    DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", sResult);
    DeleteLocalInt(oNpc, "dl_transition_pending_finalizer_expected");
}

int DL_NavTryFinalizeCompletedTransition(object oNpc, object oTargetAnchor)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOldTransitionStatus = GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    if (!GetIsObjectValid(oTargetAnchor))
    {
        if (sOldTransitionStatus == "transitioning")
        {
            DL_NavSetTransitionFinalizeSkippedDebug(oNpc, oTargetAnchor, "finalize_skip_target_invalid", sOldTransitionStatus);
        }
        DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", "finalize_skip_target_invalid");
        return FALSE;
    }

    if (sOldTransitionStatus != "transitioning" && sOldTransitionStatus != "moving_to_entry")
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oTargetArea = GetArea(oTargetAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oTargetArea))
    {
        if (sOldTransitionStatus == "transitioning")
        {
            DL_NavSetTransitionFinalizeSkippedDebug(oNpc, oTargetAnchor, "finalize_skip_area_invalid", sOldTransitionStatus);
        }
        DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", "finalize_skip_area_invalid");
        return FALSE;
    }

    if (oNpcArea != oTargetArea)
    {
        if (sOldTransitionStatus == "transitioning")
        {
            DL_NavSetTransitionFinalizeSkippedDebug(oNpc, oTargetAnchor, "finalize_skip_area_mismatch", sOldTransitionStatus);
        }
        DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", "finalize_skip_area_mismatch");
        return FALSE;
    }

    string sFinalZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sFinalZone == "")
    {
        sFinalZone = DL_NavGetAnchorZoneId(oTargetAnchor);
    }
    if (sFinalZone == "")
    {
        sFinalZone = DL_NavGetAreaZoneId(oTargetArea);
    }

    DL_ClearTransitionExecutionState(oNpc);
    DL_NavClearFocusMoveIssueStateAfterJump(oNpc);
    DL_NavSetNpcCurrentZone(oNpc, sFinalZone);
    DL_NavSetDebug(oNpc, sFinalZone, sFinalZone, "", "post_transition_complete");
    DL_NavSetPostTransitionCompleteDebug(oNpc, oTargetAnchor, sFinalZone, sFinalZone, sOldTransitionStatus);
    DL_BsmithTraceStage(oNpc, "TRANSITION_FINALIZER", "post_transition_complete");
    return TRUE;
}

int DL_NavTryAdvanceToZoneForOwner(object oNpc, string sTargetZone, string sMoveOwner)
{
    if (!GetIsObjectValid(oNpc) || sTargetZone == "")
    {
        if (GetIsObjectValid(oNpc))
        {
            DL_NavSetDebug(oNpc, DL_NavGetNpcCurrentZone(oNpc), sTargetZone, "", "target_empty");
        }
        return FALSE;
    }

    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    if (sCurrentZone == "")
    {
        DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, "", "current_zone_missing");
        DL_NavSetState(oNpc, "idle", sTargetZone, "current_zone_missing");
        return FALSE;
    }

    if (sCurrentZone == sTargetZone)
    {
        DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, "", "same_zone");
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    string sNextZone = DL_NavGetNextZone(oNpc, sTargetZone);
    if (sNextZone == "")
    {
        DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, "", "route_missing");
        DL_NavSetState(oNpc, "failed", sTargetZone, "route_missing");
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    string sEntryTag = DL_NavMakeTransitionTag(sCurrentZone, sNextZone);
    string sExitTag = DL_NavMakeTransitionTag(sNextZone, sCurrentZone);
    object oEntry = DL_NavFindTransitionInArea(oArea, sCurrentZone, sNextZone);
    object oExit = DL_NavFindTransitionByTag(sExitTag);

    if (!GetIsObjectValid(oEntry) || !GetIsObjectValid(oExit))
    {
        string sReason = "transition_missing";
        if (!GetIsObjectValid(oEntry) && !GetIsObjectValid(oExit))
        {
            sReason = "transition_missing_entry_exit";
        }
        else if (!GetIsObjectValid(oEntry))
        {
            sReason = "transition_missing_entry";
        }
        else
        {
            sReason = "transition_missing_exit";
        }

        DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, sNextZone, sReason);
        DL_NavSetState(oNpc, "failed", sTargetZone, sReason + " entry=" + sEntryTag + " exit=" + sExitTag);
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oEntry) > DL_NAV_ENTRY_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) == "moving_to_entry" &&
            GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) == sTargetZone &&
            GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
        {
            DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, sNextZone, "moving_to_entry_active");
            return TRUE;
        }

        if (sMoveOwner == "")
        {
            sMoveOwner = "transition";
        }
        string sMovePhase = sTargetZone;
        if (sMoveOwner != "transition")
        {
            sMovePhase = DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA;
        }
        DL_BeginMoveJob(oNpc, sMoveOwner, sMovePhase, GetTag(oEntry), DL_NAV_ENTRY_RADIUS);
        DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, sNextZone, "moving_to_entry");
        DL_NavSetState(oNpc, "moving_to_entry", sTargetZone, "");
        return TRUE;
    }

    object oOldArea = GetArea(oNpc);
    object oTargetArea = GetArea(oExit);

    DL_SetPendingTransitionAfterJump(oNpc, oOldArea, oTargetArea, sNextZone, sExitTag);
    DL_ClearMoveJob(oNpc);
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(GetLocation(oExit)));
    AssignCommand(oNpc, ActionDoCommand(DL_FinalizeTransitionAfterQueuedJump(oNpc)));
    DL_NavSetDebug(oNpc, sCurrentZone, sTargetZone, sNextZone, "transitioning");
    DL_NavSetState(oNpc, "transitioning", sTargetZone, "");
    return TRUE;
}

int DL_NavTryAdvanceToZone(object oNpc, string sTargetZone)
{
    return DL_NavTryAdvanceToZoneForOwner(oNpc, sTargetZone, "transition");
}

int DL_TryUseNavigationRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget)) return FALSE;
    string sTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sTargetZone == "") return FALSE;

    string sMoveOwner = GetLocalString(oNpc, "dl_move_owner");
    if (sMoveOwner == "") sMoveOwner = "transition";
    return DL_NavTryAdvanceToZoneForOwner(oNpc, sTargetZone, sMoveOwner);
}

int DL_TryExecuteTransitionAtWaypoint(object oNpc, object oTargetWp)
{
    if (!GetIsObjectValid(oNpc)) return FALSE;
    string sTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sTargetZone == "") return FALSE;

    string sMoveOwner = GetLocalString(oNpc, "dl_move_owner");
    if (sMoveOwner == "") sMoveOwner = "transition";
    return DL_NavTryAdvanceToZoneForOwner(oNpc, sTargetZone, sMoveOwner);
}
