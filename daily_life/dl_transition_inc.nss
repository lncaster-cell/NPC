// Daily Life interzone transition helper layer.
// Backward compatible modes:
// 1) simple explicit mode: entry waypoint stores explicit exit tag in `dl_transition_exit_tag`
// 2) builder-friendly nav mode: waypoint tag is `dl_nav_<from_zone>_to_<to_zone>`;
//    the reverse waypoint is resolved in the same area as `dl_nav_<to_zone>_to_<from_zone>`
// 3) legacy mode: entry waypoint stores `dl_transition_kind` + `dl_transition_id`
// Entry waypoint tag can stay arbitrary in explicit/legacy modes.
// Bidirectional 2-waypoint same-area portal pairs are supported when each waypoint
// points to the other via `dl_transition_exit_tag` or when both use matching `dl_nav_*_to_*` tags.

const string DL_L_WP_TRANSITION_KIND = "dl_transition_kind";
const string DL_L_WP_TRANSITION_ID = "dl_transition_id";
const string DL_L_WP_TRANSITION_EXIT_TAG = "dl_transition_exit_tag";
const string DL_L_WP_TRANSITION_DRIVER = "dl_transition_driver";
const string DL_L_WP_TRANSITION_DRIVER_TAG = "dl_transition_driver_tag";
const string DL_L_WP_TRANSITION_EXIT_OBJ = "dl_transition_exit_obj";
const string DL_L_WP_TRANSITION_DRIVER_OBJ = "dl_transition_driver_obj";
const string DL_L_WP_TRANSITION_DRIVER_MISS_TICK = "dl_transition_driver_miss_tick";
const string DL_L_WP_NAV_ZONE = "dl_nav_zone";

const string DL_L_WP_NAV_TO_AREA_TAG = "dl_nav_to_area_tag";
const int DL_CROSS_AREA_TAG_SEARCH_CAP = 32;

const string DL_L_NPC_TRANSITION_KIND = "dl_npc_transition_kind";
const string DL_L_NPC_TRANSITION_ID = "dl_npc_transition_id";
const string DL_L_NPC_TRANSITION_TARGET = "dl_npc_transition_target";
const string DL_L_NPC_TRANSITION_STATUS = "dl_npc_transition_status";
const string DL_L_NPC_TRANSITION_DIAGNOSTIC = "dl_npc_transition_diagnostic";
const string DL_L_NPC_NAV_ZONE = "dl_npc_nav_zone";

// Transition diagnostic context prefixes.
const string DL_DIAG_CTX_ROUTED = "routed";
const string DL_DIAG_CTX_CROSS_AREA = "cross_area";

// Canonical transition status values.
const string DL_TRANSITION_STATUS_METADATA_MISSING = "metadata_missing";
const string DL_TRANSITION_STATUS_MOVING_TO_ENTRY = "moving_to_entry";
const string DL_TRANSITION_STATUS_EXIT_MISSING = "exit_missing";
const string DL_TRANSITION_STATUS_TRANSITIONING = "transitioning";
const string DL_TRANSITION_STATUS_DRIVER_MISSING = "driver_missing";
const string DL_TRANSITION_STATUS_DRIVER_UNKNOWN = "driver_unknown";

// Canonical transition diagnostic codes (suffix-only; context is added via helper).
const string DL_TRANSITION_DIAG_METADATA_REQUIRED = "need_transition_exit_tag_or_kind_id_on_entry_waypoint";
const string DL_TRANSITION_DIAG_MOVING_TO_ENTRY = "moving_to_transition_entry";
const string DL_TRANSITION_DIAG_EXIT_REQUIRED = "need_valid_transition_exit_waypoint";
const string DL_TRANSITION_DIAG_IN_PROGRESS = "transition_in_progress";
const string DL_TRANSITION_DIAG_DRIVER_REQUIRED = "need_valid_transition_door";
const string DL_TRANSITION_DIAG_DRIVER_UNKNOWN = "unknown_transition_driver";

const string DL_TRANSITION_KIND_AREA_LINK = "area_link";
const string DL_TRANSITION_KIND_LOCAL_JUMP = "local_jump";

const string DL_TRANSITION_DRIVER_NONE = "none";
const string DL_TRANSITION_DRIVER_DOOR = "door";
const string DL_TRANSITION_DRIVER_TRIGGER = "trigger";

const float DL_TRANSITION_ENTRY_RADIUS = 1.60;
const string DL_L_TRANSITION_DRIVER_LOOKUP_CAP = "dl_transition_driver_lookup_cap";

const string DL_L_AREA_NAV_READY = "dl_area_nav_ready";
const string DL_L_AREA_NAV_COUNT = "dl_area_nav_count";
const string DL_L_AREA_NAV_SLOT_PREFIX = "dl_area_nav_";
const int DL_AREA_NAV_ROUTE_CAP = 32;
const int DL_TRANSITION_TAG_SEARCH_CAP = 64;
const float DL_AREA_NAV_SIDE_BIAS = 0.50;

const string DL_NAV_TAG_PREFIX = "dl_nav_";
const int DL_NAV_TAG_PREFIX_LENGTH = 7;
const string DL_NAV_TAG_SEPARATOR = "_to_";
const int DL_NAV_TAG_SEPARATOR_LENGTH = 4;

// Forward declarations for helpers provided by other include units.
int DL_ClampInt(int nValue, int nMin, int nMax);
int DL_GetAreaTick(object oArea);

string DL_GetAreaNavigationSlotKey(int nSlot)
{
    if (nSlot < 0)
    {
        nSlot = 0;
    }
    return DL_L_AREA_NAV_SLOT_PREFIX + IntToString(nSlot);
}

int DL_IsAutoNavTag(string sTag)
{
    if (GetStringLength(sTag) <= (DL_NAV_TAG_PREFIX_LENGTH + DL_NAV_TAG_SEPARATOR_LENGTH + 1))
    {
        return FALSE;
    }

    if (GetStringLowerCase(GetSubString(sTag, 0, DL_NAV_TAG_PREFIX_LENGTH)) != DL_NAV_TAG_PREFIX)
    {
        return FALSE;
    }

    string sTail = GetSubString(sTag, DL_NAV_TAG_PREFIX_LENGTH, GetStringLength(sTag) - DL_NAV_TAG_PREFIX_LENGTH);
    int nSep = FindSubString(sTail, DL_NAV_TAG_SEPARATOR);
    if (nSep <= 0)
    {
        return FALSE;
    }

    string sFrom = GetSubString(sTail, 0, nSep);
    string sTo = GetSubString(sTail, nSep + DL_NAV_TAG_SEPARATOR_LENGTH, GetStringLength(sTail) - nSep - DL_NAV_TAG_SEPARATOR_LENGTH);
    return sFrom != "" && sTo != "";
}

string DL_GetAutoNavFromZoneFromTag(string sTag)
{
    if (!DL_IsAutoNavTag(sTag))
    {
        return "";
    }

    string sTail = GetSubString(sTag, DL_NAV_TAG_PREFIX_LENGTH, GetStringLength(sTag) - DL_NAV_TAG_PREFIX_LENGTH);
    int nSep = FindSubString(sTail, DL_NAV_TAG_SEPARATOR);
    return GetSubString(sTail, 0, nSep);
}

string DL_GetAutoNavToZoneFromTag(string sTag)
{
    if (!DL_IsAutoNavTag(sTag))
    {
        return "";
    }

    string sTail = GetSubString(sTag, DL_NAV_TAG_PREFIX_LENGTH, GetStringLength(sTag) - DL_NAV_TAG_PREFIX_LENGTH);
    int nSep = FindSubString(sTail, DL_NAV_TAG_SEPARATOR);
    return GetSubString(sTail, nSep + DL_NAV_TAG_SEPARATOR_LENGTH, GetStringLength(sTail) - nSep - DL_NAV_TAG_SEPARATOR_LENGTH);
}

string DL_GetAutoNavReverseTag(string sTag)
{
    string sFrom = DL_GetAutoNavFromZoneFromTag(sTag);
    string sTo = DL_GetAutoNavToZoneFromTag(sTag);
    if (sFrom == "" || sTo == "")
    {
        return "";
    }

    return DL_NAV_TAG_PREFIX + sTo + DL_NAV_TAG_SEPARATOR + sFrom;
}

object DL_GetTransitionWaypointByTag(string sTag)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oWp = GetWaypointByTag(sTag);
    if (!DL_IsValidWaypointObject(oWp))
    {
        return OBJECT_INVALID;
    }

    return oWp;
}

object DL_GetTransitionWaypointByTagInArea(string sTag, object oArea)
{
    if (sTag == "" || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, OBJECT_TYPE_WAYPOINT, oArea, DL_TRANSITION_TAG_SEARCH_CAP);
    DL_RecordCacheMetric(oArea, "nav", GetIsObjectValid(oResolved));
    return oResolved;
}

string DL_GetWaypointTransitionKind(object oWp)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_KIND);
}

string DL_GetWaypointTransitionId(object oWp)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_ID);
}

string DL_GetWaypointTransitionExitTag(object oWp)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_EXIT_TAG);
}

string DL_GetWaypointTransitionDriver(object oWp)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_DRIVER);
}

string DL_GetWaypointTransitionDriverTag(object oWp)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_DRIVER_TAG);
}

string DL_GetWaypointNavZone(object oWp)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return "";
    }

    string sZone = GetLocalString(oWp, DL_L_WP_NAV_ZONE);
    if (sZone != "")
    {
        return sZone;
    }

    return DL_GetAutoNavFromZoneFromTag(GetTag(oWp));
}

void DL_SetNpcNavZone(object oNpc, string sZone)
{
    if (!GetIsObjectValid(oNpc) || sZone == "")
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_NAV_ZONE, sZone);
}

void DL_SetNpcNavZoneFromWaypoint(object oNpc, object oWp)
{
    string sZone = DL_GetWaypointNavZone(oWp);
    if (sZone != "")
    {
        DL_SetNpcNavZone(oNpc, sZone);
    }
}

// Canonical transition state setter contract.
// Any new transition branches must set status/diagnostic only through this helper.
void DL_SetTransitionState(object oNpc, string sStatus, string sDiagnostic, string sDiagContext)
{
    if (!DL_IsValidNpcObject(oNpc))
    {
        return;
    }

    if (sDiagnostic == "")
    {
        DL_SetRuntimeState(oNpc, DL_L_NPC_TRANSITION_STATUS, sStatus, DL_L_NPC_TRANSITION_DIAGNOSTIC, "");
        return;
    }

    string sDiagnosticValue = sDiagnostic;
    if (sDiagContext != "")
    {
        sDiagnosticValue = sDiagContext + "_" + sDiagnostic;
    }
    DL_SetRuntimeState(oNpc, DL_L_NPC_TRANSITION_STATUS, sStatus, DL_L_NPC_TRANSITION_DIAGNOSTIC, sDiagnosticValue);
}

string DL_GetResolvedTransitionExitTag(object oEntryWp)
{
    if (!DL_IsValidWaypointObject(oEntryWp))
    {
        return "";
    }

    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
    if (sExitTag != "")
    {
        return sExitTag;
    }

    string sAutoReverse = DL_GetAutoNavReverseTag(GetTag(oEntryWp));
    if (sAutoReverse != "")
    {
        return sAutoReverse;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    if (sKind == DL_TRANSITION_KIND_AREA_LINK)
    {
        return "dl_xfer_" + sTransitionId + "_to";
    }

    if (sKind == DL_TRANSITION_KIND_LOCAL_JUMP)
    {
        return "dl_jump_" + sTransitionId + "_to";
    }

    return "";
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
    if (!DL_IsValidWaypointObject(oWp))
    {
        return FALSE;
    }

    if (DL_GetWaypointTransitionExitTag(oWp) != "")
    {
        return TRUE;
    }

    if (DL_IsAutoNavTag(GetTag(oWp)))
    {
        return TRUE;
    }

    string sKind = DL_GetWaypointTransitionKind(oWp);
    string sTransitionId = DL_GetWaypointTransitionId(oWp);
    return sKind != "" && sTransitionId != "";
}

void DL_BuildAreaNavigationRouteCache(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (GetLocalInt(oArea, DL_L_AREA_NAV_READY) == TRUE)
    {
        return;
    }

    int i = 0;
    while (i < DL_AREA_NAV_ROUTE_CAP)
    {
        DeleteLocalObject(oArea, DL_GetAreaNavigationSlotKey(i));
        i = i + 1;
    }

    int nCount = 0;
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj) && nCount < DL_AREA_NAV_ROUTE_CAP)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT && DL_WaypointHasTransition(oObj))
        {
            SetLocalObject(oArea, DL_GetAreaNavigationSlotKey(nCount), oObj);
            nCount = nCount + 1;
        }
        oObj = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, DL_L_AREA_NAV_COUNT, nCount);
    SetLocalInt(oArea, DL_L_AREA_NAV_READY, TRUE);
}

int DL_GetAreaNavigationRouteCount(object oArea)
{
    DL_BuildAreaNavigationRouteCache(oArea);
    int nCount = GetLocalInt(oArea, DL_L_AREA_NAV_COUNT);
    if (nCount < 0)
    {
        return 0;
    }
    if (nCount > DL_AREA_NAV_ROUTE_CAP)
    {
        return DL_AREA_NAV_ROUTE_CAP;
    }
    return nCount;
}

object DL_GetAreaNavigationRouteAtSlot(object oArea, int nSlot)
{
    if (!GetIsObjectValid(oArea) || nSlot < 0 || nSlot >= DL_AREA_NAV_ROUTE_CAP)
    {
        return OBJECT_INVALID;
    }

    DL_BuildAreaNavigationRouteCache(oArea);
    return GetLocalObject(oArea, DL_GetAreaNavigationSlotKey(nSlot));
}

string DL_InferNpcNavZoneFromAreaRoutes(object oNpc)
{
    if (!DL_IsValidNpcObject(oNpc))
    {
        return "";
    }

    string sCached = GetLocalString(oNpc, DL_L_NPC_NAV_ZONE);
    if (sCached != "")
    {
        return sCached;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return "";
    }

    int nCount = DL_GetAreaNavigationRouteCount(oArea);
    object oBest = OBJECT_INVALID;
    float fBestDistance = 100000.0;
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_GetAreaNavigationRouteAtSlot(oArea, i);
        string sZone = DL_GetWaypointNavZone(oEntry);
        if (GetIsObjectValid(oEntry) && sZone != "")
        {
            float fDistance = GetDistanceBetween(oNpc, oEntry);
            if (!GetIsObjectValid(oBest) || fDistance < fBestDistance)
            {
                oBest = oEntry;
                fBestDistance = fDistance;
            }
        }
        i = i + 1;
    }

    if (GetIsObjectValid(oBest))
    {
        string sBestZone = DL_GetWaypointNavZone(oBest);
        DL_SetNpcNavZone(oNpc, sBestZone);
        return sBestZone;
    }

    return "";
}

int DL_IsValidTransitionWaypointForTag(object oWp, string sExpectedTag)
{
    if (!DL_IsValidWaypointObject(oWp))
    {
        return FALSE;
    }

    if (GetObjectType(oWp) != OBJECT_TYPE_WAYPOINT)
    {
        return FALSE;
    }

    if (GetTag(oWp) != sExpectedTag)
    {
        return FALSE;
    }

    return DL_WaypointHasTransition(oWp);
}

object DL_GetCrossNavAreaByTag(string sAreaTag)
{
    if (sAreaTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCandidate = DL_FindObjectByTagWithChecks(sAreaTag, DL_CROSS_AREA_TAG_SEARCH_CAP, -1, OBJECT_INVALID, OBJECT_INVALID, FALSE);
    if (GetIsObjectValid(oCandidate) && DL_IsAreaObject(oCandidate))
    {
        return oCandidate;
    }

    return OBJECT_INVALID;
}

object DL_GetTransitionExitSearchAreaFromEntry(object oEntryWp)
{
    if (!DL_IsValidWaypointObject(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    string sToAreaTag = GetLocalString(oEntryWp, DL_L_WP_NAV_TO_AREA_TAG);
    if (sToAreaTag != "")
    {
        object oTargetArea = DL_GetCrossNavAreaByTag(sToAreaTag);
        if (GetIsObjectValid(oTargetArea))
        {
            return oTargetArea;
        }
    }

    return GetArea(oEntryWp);
}

object DL_ResolveTransitionExitWaypointFromEntrySimple(object oEntryWp)
{
    if (!DL_IsValidWaypointObject(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    string sResolvedTag = DL_GetResolvedTransitionExitTag(oEntryWp);
    if (sResolvedTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oEntryWp, DL_L_WP_TRANSITION_EXIT_OBJ);
    if (GetIsObjectValid(oCached) &&
        DL_IsValidWaypointObject(oCached) &&
        GetTag(oCached) == sResolvedTag)
    {
        return oCached;
    }
    DeleteLocalObject(oEntryWp, DL_L_WP_TRANSITION_EXIT_OBJ);

    object oExit = OBJECT_INVALID;
    object oEntryArea = GetArea(oEntryWp);
    if (DL_IsAutoNavTag(GetTag(oEntryWp)))
    {
        oExit = DL_GetTransitionWaypointByTagInArea(sResolvedTag, oEntryArea);
    }
    else
    {
        oExit = DL_GetTransitionWaypointByTagInArea(sResolvedTag, oEntryArea);
        if (!GetIsObjectValid(oExit))
        {
            oExit = DL_GetTransitionWaypointByTag(sResolvedTag);
        }
    }

    if (DL_IsValidWaypointObject(oExit))
    {
        SetLocalObject(oEntryWp, DL_L_WP_TRANSITION_EXIT_OBJ, oExit);
        return oExit;
    }

    return OBJECT_INVALID;
}

object DL_ResolveTransitionExitWaypointFromEntry(object oEntryWp)
{
    if (!DL_IsValidWaypointObject(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    string sResolvedTag = DL_GetResolvedTransitionExitTag(oEntryWp);
    if (sResolvedTag == "")
    {
        return OBJECT_INVALID;
    }

    object oSearchArea = DL_GetTransitionExitSearchAreaFromEntry(oEntryWp);
    object oExit = DL_GetTransitionWaypointByTagInArea(sResolvedTag, oSearchArea);
    if (GetIsObjectValid(oExit))
    {
        return oExit;
    }

    return DL_ResolveTransitionExitWaypointFromEntrySimple(oEntryWp);
}

int DL_IsBidirectionalTransitionPair(object oWpA, object oWpB)
{
    if (!DL_IsValidWaypointObject(oWpA) || !DL_IsValidWaypointObject(oWpB))
    {
        return FALSE;
    }

    object oBack = DL_ResolveTransitionExitWaypointFromEntry(oWpB);
    if (!DL_IsValidWaypointObject(oBack))
    {
        return FALSE;
    }

    if (oBack == oWpA)
    {
        return TRUE;
    }

    // Legacy fallback for tag-based metadata when exact object identity cannot be trusted.
    return GetArea(oBack) == GetArea(oWpA) && GetTag(oBack) == GetTag(oWpA);
}

int DL_IsTransitionDriverTypeMatch(string sDriverKind, object oDriver)
{
    if (!GetIsObjectValid(oDriver))
    {
        return FALSE;
    }

    int nType = GetObjectType(oDriver);
    if (sDriverKind == DL_TRANSITION_DRIVER_DOOR)
    {
        return nType == OBJECT_TYPE_DOOR;
    }
    if (sDriverKind == DL_TRANSITION_DRIVER_TRIGGER)
    {
        return nType == OBJECT_TYPE_TRIGGER;
    }
    if (sDriverKind == DL_TRANSITION_DRIVER_NONE)
    {
        return FALSE;
    }

    // Legacy/empty kind: allow classic door/trigger drivers.
    return nType == OBJECT_TYPE_DOOR || nType == OBJECT_TYPE_TRIGGER;
}

int DL_GetTransitionDriverLookupCap()
{
    return DL_GetConfigInt(
        DL_L_TRANSITION_DRIVER_LOOKUP_CAP,
        DL_CFG_TRANSITION_DRIVER_LOOKUP_CAP_DEFAULT,
        DL_CFG_TRANSITION_DRIVER_LOOKUP_CAP_MIN,
        DL_CFG_TRANSITION_DRIVER_LOOKUP_CAP_MAX
    );
}

object DL_ResolveTransitionDriverObject(object oEntryWp)
{
    string sDriverTag = DL_GetWaypointTransitionDriverTag(oEntryWp);
    if (sDriverTag == "")
    {
        return OBJECT_INVALID;
    }

    string sDriverKind = DL_GetWaypointTransitionDriver(oEntryWp);
    if (sDriverKind == DL_TRANSITION_DRIVER_NONE)
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oEntryWp);
    int nNowTick = DL_GetAreaTick(oArea);
    object oCached = GetLocalObject(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ);
    if (GetLocalInt(oEntryWp, DL_L_WP_TRANSITION_DRIVER_MISS_TICK) == nNowTick)
    {
        if (GetIsObjectValid(oCached) &&
            GetTag(oCached) == sDriverTag &&
            GetArea(oCached) == GetArea(oEntryWp) &&
            DL_IsTransitionDriverTypeMatch(sDriverKind, oCached))
        {
            DeleteLocalInt(oEntryWp, DL_L_WP_TRANSITION_DRIVER_MISS_TICK);
            return oCached;
        }

        if (!GetIsObjectValid(oCached))
        {
            return OBJECT_INVALID;
        }

        return OBJECT_INVALID;
    }

    if (GetIsObjectValid(oCached) &&
        GetTag(oCached) == sDriverTag &&
        GetArea(oCached) == GetArea(oEntryWp) &&
        DL_IsTransitionDriverTypeMatch(sDriverKind, oCached))
    {
        DeleteLocalInt(oEntryWp, DL_L_WP_TRANSITION_DRIVER_MISS_TICK);
        return oCached;
    }

    int nLookupCap = DL_GetTransitionDriverLookupCap();
    int nNth = 1;
    while (nNth <= nLookupCap)
    {
        object oDriver = GetNearestObjectByTag(sDriverTag, oEntryWp, nNth);
        if (!GetIsObjectValid(oDriver))
        {
            break;
        }

        if (GetArea(oDriver) == GetArea(oEntryWp))
        {
            if (DL_IsTransitionDriverTypeMatch(sDriverKind, oDriver))
            {
                SetLocalObject(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ, oDriver);
                DeleteLocalInt(oEntryWp, DL_L_WP_TRANSITION_DRIVER_MISS_TICK);
                return oDriver;
            }
        }

        nNth = nNth + 1;
    }

    SetLocalInt(oEntryWp, DL_L_WP_TRANSITION_DRIVER_MISS_TICK, nNowTick);
    return OBJECT_INVALID;
}

int DL_JumpNpcToTransitionExit(object oNpc, location lExit, string sStatus = "", string sDiagnostic = "")
{
    if (!DL_IsValidNpcObject(oNpc))
    {
        return FALSE;
    }

    object oExitArea = GetAreaFromLocation(lExit);
    if (!DL_IsValidAreaObject(oExitArea))
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


int DL_ExecuteTransitionDriver(object oNpc, object oEntryWp, location lExit, object oExitWp, string sJumpDiagnostic = "transition_in_progress")
{
    if (!DL_IsValidNpcObject(oNpc) || !DL_IsValidWaypointObject(oEntryWp))
    {
        return FALSE;
    }

    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    // single source of truth: all transition driver execution paths must go through this helper.
    if (sDriver == "" || sDriver == DL_TRANSITION_DRIVER_NONE || sDriver == DL_TRANSITION_DRIVER_TRIGGER)
    {
        DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);
        DL_JumpNpcToTransitionExit(oNpc, lExit, DL_TRANSITION_STATUS_TRANSITIONING, sJumpDiagnostic);
        return TRUE;
    }

    if (sDriver == DL_TRANSITION_DRIVER_DOOR)
    {
        object oDoor = DL_ResolveTransitionDriverObject(oEntryWp);
        if (!DL_IsValidDoorObject(oDoor))
        {
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_TRANSITION_STATUS_DRIVER_MISSING);
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, DL_TRANSITION_DIAG_DRIVER_REQUIRED);
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

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_TRANSITION_STATUS_DRIVER_UNKNOWN);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, DL_TRANSITION_DIAG_DRIVER_UNKNOWN);
    return TRUE;
}

int DL_TryExecuteTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    if (!DL_IsValidNpcObject(oNpc) || !DL_IsValidWaypointObject(oEntryWp))
    {
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
    if (!DL_WaypointHasTransition(oEntryWp))
    {
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_ID, sTransitionId);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, GetTag(oEntryWp));

    if (sExitTag == "" && (sKind == "" || sTransitionId == "") && !DL_IsAutoNavTag(GetTag(oEntryWp)))
    {
        DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_METADATA_MISSING, DL_TRANSITION_DIAG_METADATA_REQUIRED, "");
        return TRUE;
    }

    if (GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oEntryWp)) > DL_TRANSITION_ENTRY_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "moving_to_entry")
        {
            DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_MOVING_TO_ENTRY, DL_TRANSITION_DIAG_MOVING_TO_ENTRY, "");
            AssignCommand(oNpc, ClearAllActions(TRUE));
            AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntryWp), TRUE));
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oEntryWp);
    if (!GetIsObjectValid(oExitWp))
    {
        DL_SetTransitionState(oNpc, DL_TRANSITION_STATUS_EXIT_MISSING, DL_TRANSITION_DIAG_EXIT_REQUIRED, "");
        DL_ReportFallback(oNpc, DL_FB_DOMAIN_TRANSITION, DL_FB_REASON_TRANSITION_EXIT_MISSING, DL_FB_NEXT_WAIT_RETRY);
        return TRUE;
    }

    location lExit = GetLocation(oExitWp);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, DL_TRANSITION_STATUS_TRANSITIONING);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "transition_in_progress");
    return DL_ExecuteTransitionDriver(oNpc, oEntryWp, lExit, oExitWp, "transition_in_progress");
}

int DL_TryExecuteTransitionAtWaypoint(object oNpc, object oTargetWp)
{
    if (!DL_IsValidNpcObject(oNpc) || !DL_IsValidWaypointObject(oTargetWp))
    {
        return FALSE;
    }

    object oActualEntry = oTargetWp;
    object oPairedWp = DL_ResolveTransitionExitWaypointFromEntry(oTargetWp);

    if (GetIsObjectValid(oPairedWp) &&
        GetArea(oPairedWp) == GetArea(oNpc) &&
        GetArea(oTargetWp) == GetArea(oNpc) &&
        DL_IsBidirectionalTransitionPair(oTargetWp, oPairedWp))
    {
        float fTargetDist = GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oTargetWp));
        float fPairedDist = GetDistanceBetweenLocations(GetLocation(oNpc), GetLocation(oPairedWp));

        if (fTargetDist <= DL_TRANSITION_ENTRY_RADIUS)
        {
            DL_ClearTransitionExecutionState(oNpc);
            return FALSE;
        }

        if (fPairedDist < fTargetDist)
        {
            oActualEntry = oPairedWp;
        }
    }

    return DL_TryExecuteTransitionEntryWaypoint(oNpc, oActualEntry);
}

int DL_ShouldUseNavigationEntryForTarget(object oNpc, object oTarget, object oEntry, object oExit)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget) ||
        !GetIsObjectValid(oEntry) || !GetIsObjectValid(oExit))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oTargetArea = GetArea(oTarget);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oTargetArea) || GetArea(oEntry) != oNpcArea)
    {
        return FALSE;
    }

    object oExitArea = GetArea(oExit);
    if (!GetIsObjectValid(oExitArea))
    {
        return FALSE;
    }

    // Cross-area route: use an entry in the current area whose exit lands in the target area.
    if (oNpcArea != oTargetArea)
    {
        return oExitArea == oTargetArea;
    }

    // Same-area route: use the transition only when target and NPC appear to be
    // on opposite sides of a bidirectional local pair, e.g. first floor/second floor.
    if (oExitArea != oTargetArea || !DL_IsBidirectionalTransitionPair(oEntry, oExit))
    {
        return FALSE;
    }

    float fNpcToEntry = GetDistanceBetween(oNpc, oEntry);
    float fNpcToExit = GetDistanceBetween(oNpc, oExit);
    float fTargetToEntry = GetDistanceBetween(oTarget, oEntry);
    float fTargetToExit = GetDistanceBetween(oTarget, oExit);

    int bNpcOnEntrySide = (fNpcToEntry + DL_AREA_NAV_SIDE_BIAS) < fNpcToExit;
    int bTargetOnExitSide = (fTargetToExit + DL_AREA_NAV_SIDE_BIAS) < fTargetToEntry;

    return bNpcOnEntrySide && bTargetOnExitSide;
}

int DL_TransitionConnectsNavZones(object oEntry, object oExit, string sFromZone, string sToZone)
{
    if (!GetIsObjectValid(oEntry) || !GetIsObjectValid(oExit) || sFromZone == "" || sToZone == "")
    {
        return FALSE;
    }

    return DL_GetWaypointNavZone(oEntry) == sFromZone && DL_GetWaypointNavZone(oExit) == sToZone;
}

object DL_FindDirectNavZoneEntry(object oNpc, object oTarget, string sFromZone, string sToZone)
{
    object oNpcArea = GetArea(oNpc);
    if (!GetIsObjectValid(oNpcArea))
    {
        return OBJECT_INVALID;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oNpcArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = 1000000;
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_GetAreaNavigationRouteAtSlot(oNpcArea, i);
        object oExit = DL_ResolveTransitionExitWaypointFromEntry(oEntry);
        if (DL_TransitionConnectsNavZones(oEntry, oExit, sFromZone, sToZone))
        {
            int nScore = FloatToInt(GetDistanceBetween(oNpc, oEntry) * 100.0);
            if (GetArea(oExit) == GetArea(oTarget))
            {
                nScore = nScore + FloatToInt(GetDistanceBetween(oExit, oTarget) * 100.0);
            }
            if (!GetIsObjectValid(oBestEntry) || nScore < nBestScore)
            {
                oBestEntry = oEntry;
                nBestScore = nScore;
            }
        }
        i = i + 1;
    }

    return oBestEntry;
}

object DL_FindTwoHopNavZoneEntry(object oNpc, object oTarget, string sFromZone, string sToZone)
{
    object oNpcArea = GetArea(oNpc);
    if (!GetIsObjectValid(oNpcArea))
    {
        return OBJECT_INVALID;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oNpcArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = 1000000;
    int i = 0;
    while (i < nCount)
    {
        object oEntryA = DL_GetAreaNavigationRouteAtSlot(oNpcArea, i);
        object oExitA = DL_ResolveTransitionExitWaypointFromEntry(oEntryA);
        string sMidZone = DL_GetWaypointNavZone(oExitA);
        if (DL_TransitionConnectsNavZones(oEntryA, oExitA, sFromZone, sMidZone) &&
            sMidZone != "" && sMidZone != sFromZone && sMidZone != sToZone)
        {
            int j = 0;
            while (j < nCount)
            {
                object oEntryB = DL_GetAreaNavigationRouteAtSlot(oNpcArea, j);
                object oExitB = DL_ResolveTransitionExitWaypointFromEntry(oEntryB);
                if (DL_TransitionConnectsNavZones(oEntryB, oExitB, sMidZone, sToZone))
                {
                    int nScore = FloatToInt(GetDistanceBetween(oNpc, oEntryA) * 100.0) +
                                 FloatToInt(GetDistanceBetween(oExitA, oEntryB) * 100.0);
                    if (GetArea(oExitB) == GetArea(oTarget))
                    {
                        nScore = nScore + FloatToInt(GetDistanceBetween(oExitB, oTarget) * 100.0);
                    }
                    if (!GetIsObjectValid(oBestEntry) || nScore < nBestScore)
                    {
                        oBestEntry = oEntryA;
                        nBestScore = nScore;
                    }
                }
                j = j + 1;
            }
        }
        i = i + 1;
    }

    return oBestEntry;
}

int DL_TryUseNavZoneRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    string sTargetZone = DL_GetWaypointNavZone(oTarget);
    if (sTargetZone == "")
    {
        return FALSE;
    }

    string sCurrentZone = DL_InferNpcNavZoneFromAreaRoutes(oNpc);
    if (sCurrentZone == "" || sCurrentZone == sTargetZone)
    {
        return FALSE;
    }

    object oEntry = DL_FindDirectNavZoneEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
    if (!GetIsObjectValid(oEntry))
    {
        oEntry = DL_FindTwoHopNavZoneEntry(oNpc, oTarget, sCurrentZone, sTargetZone);
    }

    if (!GetIsObjectValid(oEntry))
    {
        return FALSE;
    }

    return DL_TryExecuteTransitionEntryWaypoint(oNpc, oEntry);
}

int DL_TryUseNavigationRouteToTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    if (!GetIsObjectValid(oNpcArea))
    {
        return FALSE;
    }

    if (DL_TryUseNavZoneRouteToTarget(oNpc, oTarget))
    {
        return TRUE;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oNpcArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = 1000000;
    int i = 0;
    while (i < nCount)
    {
        object oEntry = DL_GetAreaNavigationRouteAtSlot(oNpcArea, i);
        if (GetIsObjectValid(oEntry) && DL_WaypointHasTransition(oEntry))
        {
            object oExit = DL_ResolveTransitionExitWaypointFromEntry(oEntry);
            if (DL_ShouldUseNavigationEntryForTarget(oNpc, oTarget, oEntry, oExit))
            {
                int nScore = FloatToInt(GetDistanceBetween(oNpc, oEntry) * 100.0) +
                             FloatToInt(GetDistanceBetween(oExit, oTarget) * 100.0);
                if (!GetIsObjectValid(oBestEntry) || nScore < nBestScore)
                {
                    oBestEntry = oEntry;
                    nBestScore = nScore;
                }
            }
        }
        i = i + 1;
    }

    if (!GetIsObjectValid(oBestEntry))
    {
        return FALSE;
    }

    return DL_TryExecuteTransitionEntryWaypoint(oNpc, oBestEntry);
}
