// Daily Life interzone transition helper layer.
// Adapter policy: add wrappers only for explicit API contract compatibility;
// no new pass-through adapters when canonical implementation exists.
// Transition business-logic contract:
// - Pass-mode semantics (worker/warm/resync/fallback) are owned by worker/registry includes;
//   this transition layer must stay mode-agnostic and preserve those runtime exceptions.
// - Canonical transition execution path lives only in
//   daily_life/dl_transition_engine_inc.nss::DL_ExecuteTransitionEngine.
// - Canonical transition jump/driver path lives only in
//   daily_life/dl_transition_engine_inc.nss::DL_Engine* helpers.
// - This include may keep only compatibility wrappers around that engine and
//   shared metadata/resolve helpers.
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
const string DL_L_WP_NAV_ZONE = "dl_nav_zone";

const string DL_L_WP_NAV_TO_AREA_TAG = "dl_nav_to_area_tag";
const int DL_CROSS_AREA_TAG_SEARCH_CAP = 32;

const string DL_L_NPC_TRANSITION_KIND = "dl_npc_transition_kind";
const string DL_L_NPC_TRANSITION_ID = "dl_npc_transition_id";
string DL_L_NPC_TRANSITION_TARGET = "dl_npc_transition_target";
string DL_L_NPC_TRANSITION_STATUS = "dl_npc_transition_status";
string DL_L_NPC_TRANSITION_DIAGNOSTIC = "dl_npc_transition_diagnostic";
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
const int DL_TRANSITION_DRIVER_LOOKUP_CAP = 4;
const int DL_TRANSITION_DRIVER_LOOKUP_CAP_MIN = 1;
const int DL_TRANSITION_DRIVER_LOOKUP_CAP_MAX = 16;

const string DL_L_AREA_NAV_READY = "dl_area_nav_ready";
const string DL_L_AREA_NAV_COUNT = "dl_area_nav_count";
const string DL_L_AREA_NAV_SLOT_PREFIX = "dl_area_nav_";
const int DL_AREA_NAV_ROUTE_CAP = 32;
const int DL_TRANSITION_TAG_SEARCH_CAP_LOCAL_DETERMINISTIC = 64;
const int DL_TRANSITION_TAG_SEARCH_CAP_GLOBAL_FALLBACK = 24;
const int DL_TRANSITION_TAG_SEARCH_CAP_NEAREST_FALLBACK = 12;
const float DL_AREA_NAV_SIDE_BIAS = 0.50;
const int DL_TAG_FALLBACK_NONE = 0;
const int DL_TAG_FALLBACK_GLOBAL = 1;
const int DL_TAG_FALLBACK_NEAREST = 2;
const string DL_LOOKUP_MODE_TRANSITION_POLICY = "transition_policy";
const string DL_LOOKUP_MODE_TRANSITION_CROSS_AREA = "transition_cross_area";

const float DL_TRANSITION_TAG_NEAREST_MAX_DISTANCE = 80.0;
const string DL_L_TRANSITION_TAG_MISS_SUPPRESS_PREFIX = "dl_transition_tag_miss_";

const string DL_NAV_TAG_PREFIX = "dl_nav_";
const int DL_NAV_TAG_PREFIX_LENGTH = 7;
const string DL_NAV_TAG_SEPARATOR = "_to_";
const int DL_NAV_TAG_SEPARATOR_LENGTH = 4;
const string DL_TRANSITION_KEY_SEPARATOR = "|";

// Runtime-state constructors (locals/cache keys used by gameplay state).
string DL_BuildTransitionRuntimeKey2(string sPartA, string sPartB)
{
    return sPartA + DL_TRANSITION_KEY_SEPARATOR + sPartB;
}

string DL_BuildTransitionRuntimeKey3(string sPartA, string sPartB, string sPartC)
{
    return DL_BuildTransitionRuntimeKey2(sPartA, sPartB) + DL_TRANSITION_KEY_SEPARATOR + sPartC;
}

// Telemetry/log constructors (diagnostics/log payload fragments).
string DL_BuildTransitionDiagnostic(string sDiagContext, string sDiagCode)
{
    if (sDiagCode == "")
    {
        return "";
    }
    if (sDiagContext == "")
    {
        return sDiagCode;
    }
    return sDiagContext + "_" + sDiagCode;
}

string DL_BuildAutoNavReverseTag(string sFromZone, string sToZone)
{
    if (sFromZone == "" || sToZone == "")
    {
        return "";
    }

    return DL_NAV_TAG_PREFIX + sToZone + DL_NAV_TAG_SEPARATOR + sFromZone;
}

string DL_BuildTransitionLegacyExitTag(string sKind, string sTransitionId)
{
    // Compatibility wrapper only. Legacy branch logic is centralized in adapter.
    return DL_LegacyAdapterResolveExitTagFromKindId(sKind, sTransitionId);
}

// Forward declarations for helpers provided by other include units.
int DL_ClampInt(int nValue, int nMin, int nMax);
int DL_GetAreaTick(object oArea);
int DL_TryRouteToTarget(object oNpc, object oTarget);
int DL_ExecuteTransitionViaEntryWaypoint(object oNpc, object oEntryWp, string sDiagPrefix);
int DL_TryAdvanceViaTransitionOrRoute(object oNpc, object oTargetWp, string sRouteContext);
int DL_EngineJumpNpcToTransitionExit(object oNpc, location lExit, string sStatus = "", string sDiagnostic = "");
int DL_EngineExecuteTransitionDriver(object oNpc, object oEntryWp, location lExit, object oExitWp, string sJumpDiagnostic = DL_TRANSITION_DIAG_IN_PROGRESS);
int DL_ExecuteTransitionEngine(object oNpc, object oEntryWp, string sDiagPrefix);
void DL_MarkSleepNavigationInProgress(object oNpc, string sTargetTag);

int DL_GetAbsoluteMinute();
void DL_LogTransitionEvent(object oNpc, string sKind, string sPayload);
void DL_CommandSetFacing(object oObj, float fFacing);
int DL_SelectNearestObjectCandidate(object oCandidate, float fCandidateDist, string sCandidateTie, object oBest, float fBestDist, string sBestTie);

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
    return DL_ParseAutoNavTag(sTag, "dl_tmp_from", "dl_tmp_to");
}

int DL_ParseAutoNavTag(string sTag, string sFromLocal, string sToLocal)
{
    SetLocalString(GetModule(), sFromLocal, "");
    SetLocalString(GetModule(), sToLocal, "");

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

    string sFromOut = GetSubString(sTail, 0, nSep);
    string sToOut = GetSubString(sTail, nSep + DL_NAV_TAG_SEPARATOR_LENGTH, GetStringLength(sTail) - nSep - DL_NAV_TAG_SEPARATOR_LENGTH);
    if (sFromOut != "" && sToOut != "") { SetLocalString(GetModule(), sFromLocal, sFromOut); SetLocalString(GetModule(), sToLocal, sToOut); return TRUE; }
    return FALSE;
}

string DL_GetAutoNavFromZoneFromTag(string sTag)
{
    string sFrom = "";
    string sTo = "";
    if (!DL_ParseAutoNavTag(sTag, "dl_tmp_from", "dl_tmp_to"))
    {
        return "";
    }

    return GetLocalString(GetModule(), "dl_tmp_from");
}

string DL_GetAutoNavToZoneFromTag(string sTag)
{
    string sFrom = "";
    string sTo = "";
    if (!DL_ParseAutoNavTag(sTag, "dl_tmp_from", "dl_tmp_to"))
    {
        return "";
    }

    return GetLocalString(GetModule(), "dl_tmp_to");
}

string DL_GetAutoNavReverseTag(string sTag)
{
    string sFrom = "";
    string sTo = "";
    if (!DL_ParseAutoNavTag(sTag, "dl_tmp_from", "dl_tmp_to"))
    {
        return "";
    }

    return DL_BuildAutoNavReverseTag(GetLocalString(GetModule(), "dl_tmp_to"), GetLocalString(GetModule(), "dl_tmp_from"));
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

string DL_GetTransitionTagMissSuppressKey(string sTag, int nObjectType, object oArea, int nFallbackMode)
{
    return DL_L_TRANSITION_TAG_MISS_SUPPRESS_PREFIX + IntToString(nObjectType) + "_" + IntToString(nFallbackMode) + "_" + ObjectToString(oArea) + "_" + sTag;
}

int DL_IsTransitionTagMissSuppressedThisTick(string sTag, int nObjectType, object oArea, int nFallbackMode, int nTick)
{
    if (sTag == "" || !GetIsObjectValid(oArea) || nTick < 0)
    {
        return FALSE;
    }

    string sKey = DL_GetTransitionTagMissSuppressKey(sTag, nObjectType, oArea, nFallbackMode);
    return GetLocalInt(GetModule(), sKey) == nTick;
}

void DL_MarkTransitionTagMissThisTick(string sTag, int nObjectType, object oArea, int nFallbackMode, int nTick)
{
    if (sTag == "" || !GetIsObjectValid(oArea) || nTick < 0)
    {
        return;
    }

    string sKey = DL_GetTransitionTagMissSuppressKey(sTag, nObjectType, oArea, nFallbackMode);
    SetLocalInt(GetModule(), sKey, nTick);
}

void DL_ClearTransitionTagMissSuppressedTick(string sTag, int nObjectType, object oArea, int nFallbackMode)
{
    if (sTag == "" || !GetIsObjectValid(oArea))
    {
        return;
    }

    string sKey = DL_GetTransitionTagMissSuppressKey(sTag, nObjectType, oArea, nFallbackMode);
    DeleteLocalInt(GetModule(), sKey);
}

// Unified tag lookup policy for transition/nav entities.
// Policy contract:
// 1) Always try area-preferred deterministic lookup first: module area-tag cache,
//    then area-local deterministic scan when preferred area is valid.
// 2) Fallback behavior is explicit and centralized with dedicated caps:
//    - DL_TAG_FALLBACK_NONE: area-local deterministic only (DL_TRANSITION_TAG_SEARCH_CAP_LOCAL_DETERMINISTIC).
//    - DL_TAG_FALLBACK_GLOBAL: fallback to global typed lookup by tag (DL_TRANSITION_TAG_SEARCH_CAP_GLOBAL_FALLBACK for local pre-pass).
//    - DL_TAG_FALLBACK_NEAREST: fallback to nearest typed lookup with dedicated cap
//      (DL_TRANSITION_TAG_SEARCH_CAP_NEAREST_FALLBACK) and early-stop context guards (distance/area boundary).
// 3) Repeated misses are suppressed per tick by (tag, area, object_type, fallback_mode).
// 4) New modules must reuse this helper instead of introducing ad-hoc tag lookup flows.
object DL_ResolveObjectByTagWithPolicy(string sTag, int nObjectType, object oPreferredArea, int nDeterministicCap, int nFallbackMode)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oMemo = DL_MemoLookupObject(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode);
    if (GetIsObjectValid(oMemo))
    {
        return oMemo;
    }

    int nCap = nDeterministicCap;
    if (nCap <= 0)
    {
        nCap = DL_TRANSITION_TAG_SEARCH_CAP_NEAREST_FALLBACK;
    }
    else if (nFallbackMode == DL_TAG_FALLBACK_GLOBAL)
    {
        nCap = DL_TRANSITION_TAG_SEARCH_CAP_GLOBAL_FALLBACK;
    }

    if (nCap <= 0)
    {
        nCap = 1;
    }

        object oAreaCached = DL_GetAreaScopedCachedObjectByTag(OBJECT_SELF, sTag, nObjectType, oPreferredArea);
        if (GetIsObjectValid(oAreaCached))
        {
            DL_ClearTransitionTagMissSuppressedTick(sTag, nObjectType, oPreferredArea, nFallbackMode);
            DL_MemoStoreObject(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode, oAreaCached);
            return oAreaCached;
        }

    if (GetIsObjectValid(oPreferredArea))
    {
        object oLocal = DL_FindObjectByTagInAreaDeterministic(sTag, nObjectType, oPreferredArea, nCap);
        if (GetIsObjectValid(oLocal))
        {
            DL_ClearTransitionTagMissSuppressedTick(sTag, nObjectType, oPreferredArea, nFallbackMode);
            DL_MemoStoreObject(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode, oLocal);
            return oLocal;
        }
    }

    if (nFallbackMode == DL_TAG_FALLBACK_GLOBAL)
    {
        object oGlobal = GetObjectByTagAndType(sTag, nObjectType, 1);
        if (GetIsObjectValid(oGlobal) && GetIsObjectValid(oPreferredArea))
        {
            DL_ClearTransitionTagMissSuppressedTick(sTag, nObjectType, oPreferredArea, nFallbackMode);
            DL_MemoStoreObject(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode, oGlobal);
        }
        else if (!GetIsObjectValid(oGlobal) && GetIsObjectValid(oPreferredArea))
        {
            DL_MarkTransitionTagMissThisTick(sTag, nObjectType, oPreferredArea, nFallbackMode, DL_GetAreaTick(oPreferredArea));
            DL_MemoStoreMiss(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode);
        }
        return GetObjectByTagAndType(sTag, nObjectType, 1);
    }

    if (nFallbackMode == DL_TAG_FALLBACK_NEAREST)
    {
        int nNearestCap = nCap;
        if (nNearestCap <= 0)
        {
            return OBJECT_INVALID;
        }
        object oNearestOrigin = GetIsObjectValid(oPreferredArea) ? oPreferredArea : OBJECT_SELF;
        if (nNearestCap > DL_TRANSITION_TAG_SEARCH_CAP_NEAREST_FALLBACK)
        {
            nNearestCap = DL_TRANSITION_TAG_SEARCH_CAP_NEAREST_FALLBACK;
        }

        int nNth = 1;
        while (nNth <= nNearestCap)
        {
            object oNearest = GetNearestObjectByTag(sTag, oNearestOrigin, nNth);
            if (!GetIsObjectValid(oNearest))
            {
                break;
            }

            if (GetIsObjectValid(oPreferredArea) && GetArea(oNearest) != oPreferredArea)
            {
                break;
            }

            if (GetIsObjectValid(oPreferredArea) && GetDistanceBetween(oPreferredArea, oNearest) > DL_TRANSITION_TAG_NEAREST_MAX_DISTANCE)
            {
                break;
            }

            if (GetObjectType(oNearest) == nObjectType)
            {
                if (GetIsObjectValid(oPreferredArea))
                {
                    DL_ClearTransitionTagMissSuppressedTick(sTag, nObjectType, oPreferredArea, nFallbackMode);
                    DL_MemoStoreObject(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode, oNearest);
                }
                return oNearest;
            }
            nNth = nNth + 1;
        }
    }

    if (GetIsObjectValid(oPreferredArea))
    {
        DL_MarkTransitionTagMissThisTick(sTag, nObjectType, oPreferredArea, nFallbackMode, DL_GetAreaTick(oPreferredArea));
        DL_MemoStoreMiss(OBJECT_SELF, oPreferredArea, sTag, nObjectType, nFallbackMode);
    }
    return OBJECT_INVALID;
}

// Call-site policy contract (transitions):
// - transition/route waypoint resolution is deterministic-in-area only (FALLBACK_NONE).
// - global fallback is allowed only via explicit legacy adapter branch where required for old content.
object DL_GetTransitionWaypointByTagInArea(string sTag, object oArea)
{
    if (sTag == "" || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oResolved = DL_IndexGetWaypointByTag(oArea, sTag);
    if (GetIsObjectValid(oResolved))
    {
        return oResolved;
    }

    DL_RecordCacheMetricBatch(oArea, "index_fallback", 0, 1);
    oResolved = DL_ResolveObjectByTagWithPolicy(
        sTag,
        OBJECT_TYPE_WAYPOINT,
        oArea,
        DL_TRANSITION_TAG_SEARCH_CAP_LOCAL_DETERMINISTIC,
        DL_TAG_FALLBACK_NONE // Non-critical nav lookup: deterministic area-local only to avoid cross-area ambiguity.
    );
    DL_RecordCacheMetricBatch(oArea, "index_fallback", GetIsObjectValid(oResolved), !GetIsObjectValid(oResolved));
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


void DL_ApplyTransitionNavZoneUpdate(object oNpc, object oExitWp, int bOnSuccessfulDispatchOnly)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oExitWp))
    {
        return;
    }

    // When bOnSuccessfulDispatchOnly=TRUE this helper must be called strictly
    // from the success branch of jump dispatch.
    DL_SetNpcNavZoneFromWaypoint(oNpc, oExitWp);
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

    string sDiagnosticValue = DL_BuildTransitionDiagnostic(sDiagContext, sDiagnostic);
    DL_SetRuntimeState(oNpc, DL_L_NPC_TRANSITION_STATUS, sStatus, DL_L_NPC_TRANSITION_DIAGNOSTIC, sDiagnosticValue);
}

void DL_HandleTransitionFailure(object oNpc, string sStatus, string sDiag, string sFallbackReason, string sCtx)
{
    if (!DL_IsValidNpcObject(oNpc))
    {
        return;
    }

    DL_SetTransitionState(oNpc, sStatus, sDiag, sCtx);
    if (sFallbackReason != "")
    {
        DL_ReportFallback(oNpc, DL_FB_DOMAIN_TRANSITION, sFallbackReason, DL_FB_NEXT_WAIT_RETRY);
    }

    string sKeyContext = "status=" + sStatus + " diag=" + DL_BuildTransitionDiagnostic(sCtx, sDiag);
    if (sFallbackReason != "")
    {
        sKeyContext += " fallback_reason=" + sFallbackReason;
    }
    DL_LogTransitionEvent(oNpc, "transition_failure", sKeyContext);
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
    return DL_LegacyAdapterResolveExitTagFromKindId(sKind, sTransitionId);
}

void DL_ClearTransitionExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_KIND);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_ID);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
}

void DL_OnNpcArrivedAtAnchor(object oNpc, object oTarget, string sStatusLocal, string sStatusValue, string sDiagLocal, string sAnim, int bSetFacing)
{
    if (!DL_IsValidNpcObject(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    DL_ClearTransitionExecutionState(oNpc);
    if (sDiagLocal != "")
    {
        DeleteLocalString(oNpc, sDiagLocal);
    }

    if (sStatusLocal != "")
    {
        SetLocalString(oNpc, sStatusLocal, sStatusValue);
    }

    if (bSetFacing)
    {
        DL_CommandSetFacing(oNpc, GetFacing(oTarget));
    }

    if (sAnim != "")
    {
        PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
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

// Public cache API: area-scoped navigation route cache.
// Expected lifetime: current area epoch while transition waypoint topology is unchanged.
// Invalidation triggers: explicit route metadata/tag mutation, area cache epoch reset, or forced area cache reset flag.
void DL_InvalidateAreaNavigationRouteCache(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int i = 0;
    while (i < DL_AREA_NAV_ROUTE_CAP)
    {
        DeleteLocalObject(oArea, DL_GetAreaNavigationSlotKey(i));
        i = i + 1;
    }

    DeleteLocalInt(oArea, DL_L_AREA_NAV_READY);
    DeleteLocalInt(oArea, DL_L_AREA_NAV_COUNT);
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

    DL_InvalidateAreaNavigationRouteCache(oArea);

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
            string sCandidateTie = DL_SelectionBuildTieKey(oEntry, OBJECT_INVALID, i);
            string sBestTie = DL_SelectionBuildTieKey(oBest, OBJECT_INVALID, 0);
            if (DL_SelectNearestObjectCandidate(oEntry, fDistance, sCandidateTie, oBest, fBestDistance, sBestTie))
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

    object oMemoized = DL_GetTickMemoizedLookup(GetModule(), OBJECT_SELF, DL_GetAbsoluteMinute(), sAreaTag, -1, OBJECT_INVALID, DL_LOOKUP_MODE_TRANSITION_CROSS_AREA, "dl_tmp_memo_miss");
    if (GetIsObjectValid(oMemoized))
    {
        return oMemoized;
    }
    int bMemoMiss = GetLocalInt(GetModule(), "dl_tmp_memo_miss");
    if (bMemoMiss)
    {
        return OBJECT_INVALID;
    }

    object oCandidate = DL_FindObjectByTagWithChecks(sAreaTag, DL_CROSS_AREA_TAG_SEARCH_CAP, -1, OBJECT_INVALID, OBJECT_INVALID, FALSE);
    if (GetIsObjectValid(oCandidate) && DL_IsAreaObject(oCandidate))
    {
        DL_SetTickMemoizedLookup(GetModule(), OBJECT_SELF, DL_GetAbsoluteMinute(), sAreaTag, -1, OBJECT_INVALID, DL_LOOKUP_MODE_TRANSITION_CROSS_AREA, oCandidate);
        return oCandidate;
    }

    DL_SetTickMemoizedLookup(GetModule(), OBJECT_SELF, DL_GetAbsoluteMinute(), sAreaTag, -1, OBJECT_INVALID, DL_LOOKUP_MODE_TRANSITION_CROSS_AREA, OBJECT_INVALID);
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
    oExit = DL_ResolveObjectByTagWithPolicy(
        sResolvedTag,
        OBJECT_TYPE_WAYPOINT,
        oEntryArea,
        DL_TRANSITION_TAG_SEARCH_CAP_LOCAL_DETERMINISTIC,
        DL_TAG_FALLBACK_NONE // Non-critical transition pairing: do not broaden search to global/nearest to prevent wrong exit binding.
    );

    if (!DL_IsAutoNavTag(GetTag(oEntryWp)) && !GetIsObjectValid(oExit))
    {
        // Legacy functional requirement:
        // global fallback is permitted only for non-auto-nav legacy transitions.
        oExit = DL_LegacyAdapterResolveGlobalTransitionWaypointByTag(sResolvedTag);
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


object DL_TryGetTransitionExitWaypoint(object oEntryWp)
{
    if (!DL_IsValidWaypointObject(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    if (!DL_WaypointHasTransition(oEntryWp))
    {
        return OBJECT_INVALID;
    }

    object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oEntryWp);
    if (!DL_IsValidWaypointObject(oExitWp))
    {
        return OBJECT_INVALID;
    }

    return oExitWp;
}

object DL_TryGetTransitionExitWaypointWithDiag(object oNpc, object oEntryWp, string sDiagLocal, string sDiagCode)
{
    object oExitWp = DL_TryGetTransitionExitWaypoint(oEntryWp);
    if (GetIsObjectValid(oExitWp))
    {
        return oExitWp;
    }

    if (GetIsObjectValid(oNpc) && sDiagCode != "")
    {
        if (sDiagLocal == DL_L_NPC_TRANSITION_DIAGNOSTIC)
        {
            DL_HandleTransitionFailure(
                oNpc,
                GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS),
                sDiagCode,
                DL_FB_REASON_TRANSITION_EXIT_MISSING,
                ""
            );
        }
        else if (sDiagLocal != "")
        {
            SetLocalString(oNpc, sDiagLocal, sDiagCode);
        }
    }

    return OBJECT_INVALID;
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

    return DL_LegacyAdapterIsTransitionDriverTypeMatch(sDriverKind, oDriver);
}

int DL_GetTransitionDriverLookupCap()
{
    int nCap = GetLocalInt(GetModule(), DL_L_MODULE_TRANSITION_DRIVER_LOOKUP_CAP);
    if (nCap <= 0)
    {
        return DL_TRANSITION_DRIVER_LOOKUP_CAP;
    }
    return DL_ClampInt(nCap, DL_TRANSITION_DRIVER_LOOKUP_CAP_MIN, DL_TRANSITION_DRIVER_LOOKUP_CAP_MAX);
}

object DL_ResolveTransitionDriverObject(object oEntryWp)
{
    // Housekeeping: keep driver-resolve branches linear for a single transition pipeline.
    // Call-site policy contract (drivers):
    // - nearest lookup in the same area only; no global typed fallback.
    // - lookup cap is independently tunable via DL_L_MODULE_TRANSITION_DRIVER_LOOKUP_CAP.
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
    int bCachedMatch = GetIsObjectValid(oCached) &&
        GetTag(oCached) == sDriverTag &&
        GetArea(oCached) == oArea &&
        DL_IsTransitionDriverTypeMatch(sDriverKind, oCached);

    if (bCachedMatch)
    {
        DL_ClearCacheMissSuppressedTick(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ);
        return oCached;
    }

    if (DL_IsCacheMissSuppressedThisTick(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ, nNowTick))
    {
        return OBJECT_INVALID;
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

        if (GetArea(oDriver) == oArea &&
            DL_IsTransitionDriverTypeMatch(sDriverKind, oDriver))
        {
            SetLocalObject(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ, oDriver);
            DL_ClearCacheMissSuppressedTick(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ);
            return oDriver;
        }

        nNth = nNth + 1;
    }

    DL_MarkCacheMissThisTick(oEntryWp, DL_L_WP_TRANSITION_DRIVER_OBJ, nNowTick);
    return OBJECT_INVALID;
}

int DL_ShouldUseNavigationEntryForTarget(object oNpc, object oTarget, object oEntry, object oExit)
{
    if (!DL_IsValidNpcObject(oNpc) || !GetIsObjectValid(oTarget) ||
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

    return DL_CompareSidesForBidirectionalPair(
        oNpc,
        oTarget,
        oEntry,
        oExit,
        DL_AREA_NAV_SIDE_BIAS,
        FALSE
    );
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
    if (!DL_IsValidNpcAreaContext(oNpc, oNpcArea))
    {
        return OBJECT_INVALID;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oNpcArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = DL_SELECTION_SCORE_INF;
    string sBestTie = "";
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
            if (DL_SelectionConsiderTransitionCandidate(nScore, oEntry, oExit, i, nBestScore, sBestTie))
            {
                oBestEntry = oEntry;
                nBestScore = nScore;
                sBestTie = DL_SelectionBuildTieKey(oEntry, oExit, i);
            }
        }
        i = i + 1;
    }

    return oBestEntry;
}

object DL_FindTwoHopNavZoneEntry(object oNpc, object oTarget, string sFromZone, string sToZone)
{
    object oNpcArea = GetArea(oNpc);
    if (!DL_IsValidNpcAreaContext(oNpc, oNpcArea))
    {
        return OBJECT_INVALID;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oNpcArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = DL_SELECTION_SCORE_INF;
    string sBestTie = "";
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
                    if (DL_SelectionConsiderTransitionCandidate(nScore, oEntryA, oEntryB, i, nBestScore, sBestTie))
                    {
                        oBestEntry = oEntryA;
                        nBestScore = nScore;
                        sBestTie = DL_SelectionBuildTieKey(oEntryA, oEntryB, i);
                    }
                }
                j = j + 1;
            }
        }
        i = i + 1;
    }

    return oBestEntry;
}

int DL_TryAdvanceViaTransitionOrRoute(object oNpc, object oTargetWp, string sRouteContext)
{
    if (!DL_IsValidTransitionContext(oNpc, oTargetWp))
    {
        return FALSE;
    }

    // Business logic starts after guard-section.
    if (!DL_WaypointHasTransition(oTargetWp))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oTargetArea = GetArea(oTargetWp);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oTargetArea))
    {
        return FALSE;
    }

    return TRUE;
}

int DL_TryNavigateToTargetViaTransition(object oNpc, object oTargetWp, int bAllowRouterFallback)
{
    if (!DL_IsTransitionNavigableTarget(oNpc, oTargetWp))
    {
        return FALSE;
    }

    if (DL_ExecuteTransitionViaEntryWaypoint(oNpc, oTargetWp, DL_DIAG_CTX_ROUTED))
    {
        return TRUE;
    }

    if (DL_TryRouteToTarget(oNpc, oTargetWp))
    {
        return TRUE;
    }

    return FALSE;
}

int DL_TryUseNavigationRouteToTarget(object oNpc, object oTarget)
{
    if (!DL_IsValidNpcObject(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    if (!DL_IsValidNpcAreaContext(oNpc, oNpcArea))
    {
        return FALSE;
    }

    // Business logic starts after guard-section.
    if (DL_TryRouteToTarget(oNpc, oTarget))
    {
        return TRUE;
    }

    int nCount = DL_GetAreaNavigationRouteCount(oNpcArea);
    object oBestEntry = OBJECT_INVALID;
    int nBestScore = DL_SELECTION_SCORE_INF;
    string sBestTie = "";
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
                if (DL_SelectionConsiderTransitionCandidate(nScore, oEntry, oExit, i, nBestScore, sBestTie))
                {
                    oBestEntry = oEntry;
                    nBestScore = nScore;
                    sBestTie = DL_SelectionBuildTieKey(oEntry, oExit, i);
                }
            }
        }
        i = i + 1;
    }

    if (!GetIsObjectValid(oBestEntry))
    {
        return FALSE;
    }

    return DL_ExecuteTransitionViaEntryWaypoint(oNpc, oBestEntry, DL_DIAG_CTX_ROUTED);
}
