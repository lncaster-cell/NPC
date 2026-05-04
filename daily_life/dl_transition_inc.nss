// Daily Life interzone transition helper layer.
// Backward compatible modes:
// 1) simple mode: entry waypoint stores explicit exit tag in `dl_transition_exit_tag`
// 2) legacy mode: entry waypoint stores `dl_transition_kind` + `dl_transition_id`
// Entry waypoint tag can stay arbitrary in both cases.
// Bidirectional 2-waypoint same-area portal pairs are supported when each waypoint
// points to the other via `dl_transition_exit_tag`.

const string DL_L_WP_TRANSITION_KIND = "dl_transition_kind";
const string DL_L_WP_TRANSITION_ID = "dl_transition_id";
const string DL_L_WP_TRANSITION_EXIT_TAG = "dl_transition_exit_tag";
const string DL_L_WP_TRANSITION_DRIVER = "dl_transition_driver";
const string DL_L_WP_TRANSITION_DRIVER_TAG = "dl_transition_driver_tag";
const string DL_L_WP_TRANSITION_EXIT_OBJ = "dl_transition_exit_obj";
const string DL_L_WP_TRANSITION_DRIVER_OBJ = "dl_transition_driver_obj";
const string DL_L_WP_TRANSITION_DRIVER_MISS_TICK = "dl_transition_driver_miss_tick";

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
const int DL_TRANSITION_DRIVER_LOOKUP_CAP = 4;
const int DL_TRANSITION_DRIVER_LOOKUP_CAP_MIN = 1;
const int DL_TRANSITION_DRIVER_LOOKUP_CAP_MAX = 16;
const string DL_L_TRANSITION_DRIVER_LOOKUP_CAP = "dl_transition_driver_lookup_cap";

const string DL_L_AREA_NAV_READY = "dl_area_nav_ready";
const string DL_L_AREA_NAV_COUNT = "dl_area_nav_count";
const string DL_L_AREA_NAV_SLOT_PREFIX = "dl_area_nav_";
const int DL_AREA_NAV_ROUTE_CAP = 32;
const float DL_AREA_NAV_SIDE_BIAS = 0.50;

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

string DL_GetWaypointTransitionExitTag(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return "";
    }

    return GetLocalString(oWp, DL_L_WP_TRANSITION_EXIT_TAG);
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

string DL_GetResolvedTransitionExitTag(object oEntryWp)
{
    if (!GetIsObjectValid(oEntryWp))
    {
        return "";
    }

    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
    if (sExitTag != "")
    {
        return sExitTag;
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
    if (!GetIsObjectValid(oWp))
    {
        return FALSE;
    }

    if (DL_GetWaypointTransitionExitTag(oWp) != "")
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

int DL_IsValidTransitionWaypointForTag(object oWp, string sExpectedTag)
{
    if (!GetIsObjectValid(oWp))
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

object DL_ResolveTransitionExitWaypointFromEntry(object oEntryWp)
{
    if (!GetIsObjectValid(oEntryWp))
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
        GetObjectType(oCached) == OBJECT_TYPE_WAYPOINT &&
        GetTag(oCached) == sResolvedTag)
    {
        return oCached;
    }
    DeleteLocalObject(oEntryWp, DL_L_WP_TRANSITION_EXIT_OBJ);

    object oExit = DL_GetTransitionWaypointByTag(sResolvedTag);
    if (GetIsObjectValid(oExit) && GetObjectType(oExit) == OBJECT_TYPE_WAYPOINT)
    {
        SetLocalObject(oEntryWp, DL_L_WP_TRANSITION_EXIT_OBJ, oExit);
        return oExit;
    }

    return OBJECT_INVALID;
}

int DL_IsBidirectionalTransitionPair(object oWpA, object oWpB)
{
    if (!GetIsObjectValid(oWpA) || !GetIsObjectValid(oWpB))
    {
        return FALSE;
    }

    if (GetObjectType(oWpA) != OBJECT_TYPE_WAYPOINT ||
        GetObjectType(oWpB) != OBJECT_TYPE_WAYPOINT)
    {
        return FALSE;
    }

    object oBack = DL_ResolveTransitionExitWaypointFromEntry(oWpB);
    if (!GetIsObjectValid(oBack))
    {
        return FALSE;
    }

    if (GetObjectType(oBack) != OBJECT_TYPE_WAYPOINT)
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
    int nCap = GetLocalInt(GetModule(), DL_L_TRANSITION_DRIVER_LOOKUP_CAP);
    if (nCap <= 0)
    {
        return DL_TRANSITION_DRIVER_LOOKUP_CAP;
    }
    return DL_ClampInt(nCap, DL_TRANSITION_DRIVER_LOOKUP_CAP_MIN, DL_TRANSITION_DRIVER_LOOKUP_CAP_MAX);
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

void DL_JumpNpcToTransitionExit(object oNpc, location lExit)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lExit));
}

int DL_TryExecuteTransitionEntryWaypoint(object oNpc, object oEntryWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oEntryWp))
    {
        return FALSE;
    }

    string sKind = DL_GetWaypointTransitionKind(oEntryWp);
    string sTransitionId = DL_GetWaypointTransitionId(oEntryWp);
    string sExitTag = DL_GetWaypointTransitionExitTag(oEntryWp);
    string sDriver = DL_GetWaypointTransitionDriver(oEntryWp);

    if (sExitTag == "" && sKind == "" && sTransitionId == "")
    {
        DL_ClearTransitionExecutionState(oNpc);
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_ID, sTransitionId);
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET, GetTag(oEntryWp));

    if (sExitTag == "" && (sKind == "" || sTransitionId == ""))
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
            SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "moving_to_transition_entry");
            AssignCommand(oNpc, ClearAllActions(TRUE));
            AssignCommand(oNpc, ActionMoveToLocation(GetLocation(oEntryWp), TRUE));
        }
        return TRUE;
    }

    object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oEntryWp);
    if (!GetIsObjectValid(oExitWp))
    {
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "exit_missing");
        SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "need_valid_transition_exit_waypoint");
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
        AssignCommand(oNpc, ActionJumpToLocation(lExit));
        return TRUE;
    }

    SetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS, "driver_unknown");
    SetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC, "unknown_transition_driver");
    return TRUE;
}

int DL_TryExecuteTransitionAtWaypoint(object oNpc, object oTargetWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTargetWp))
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
