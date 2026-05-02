#include "dl_activity_archive_anim_inc"
#include "dl_cache_helpers_inc"
#include "dl_directive_pipeline_inc"
#include "dl_transition_inc"
#include "dl_transition_engine_inc"
#include "dl_cross_area_nav_inc"
#include "dl_transition_exec_inc"
#include "dl_nav_router_inc"

// Step 05+: resolver/materialization skeleton.
string DL_GetNpcProblemSummary(object oNpc);
// Scope: basic BLACKSMITH/GATE_POST/TRADER WORK/SLEEP window split.

const string DL_L_NPC_DIRECTIVE = "dl_npc_directive";
const string DL_L_NPC_MAT_REQ = "dl_npc_mat_req";
const string DL_L_NPC_MAT_TAG = "dl_npc_mat_tag";
const string DL_L_NPC_DIALOGUE_MODE = "dl_npc_dialogue_mode";
const string DL_L_NPC_SERVICE_MODE = "dl_service_mode";
const string DL_L_NPC_PROFILE_ID = "dl_profile_id";
const string DL_L_NPC_STATE = "dl_state";
const string DL_L_NPC_SLEEP_PHASE = "dl_npc_sleep_phase";
const string DL_L_NPC_SLEEP_STATUS = "dl_npc_sleep_status";
const string DL_L_NPC_SLEEP_TARGET = "dl_npc_sleep_target";
const string DL_L_NPC_SLEEP_DIAGNOSTIC = "dl_npc_sleep_diagnostic";
const string DL_L_NPC_WORK_KIND = "dl_npc_work_kind";
const string DL_L_NPC_WORK_TARGET = "dl_npc_work_target";
const string DL_L_NPC_WORK_STATUS = "dl_npc_work_status";
const string DL_L_NPC_WORK_DIAGNOSTIC = "dl_npc_work_diagnostic";
const string DL_L_NPC_GUARD_SHIFT_START = "dl_guard_shift_start";
const string DL_L_NPC_ACTIVITY_ID = "dl_npc_activity_id";
const string DL_L_NPC_ANIM_SET = "dl_npc_anim_set";
const string DL_L_NPC_CACHE_SLEEP_APPROACH = "dl_cache_sleep_approach";
const string DL_L_NPC_CACHE_SLEEP_BED = "dl_cache_sleep_bed";
const string DL_L_NPC_CACHE_WORK_FORGE = "dl_cache_work_forge";
const string DL_L_NPC_CACHE_WORK_CRAFT = "dl_cache_work_craft";
const string DL_L_NPC_CACHE_WORK_POST = "dl_cache_work_post";
const string DL_L_NPC_CACHE_WORK_TRADE = "dl_cache_work_trade";
const string DL_L_NPC_CACHE_MEAL = "dl_cache_meal";
const string DL_L_NPC_CACHE_SOCIAL_A = "dl_cache_social_a";
const string DL_L_NPC_CACHE_SOCIAL_B = "dl_cache_social_b";
const string DL_L_NPC_CACHE_PUBLIC = "dl_cache_public";
const string DL_L_NPC_CACHE_CHILL_SEAT = "dl_cache_chill_seat";
const string DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL = "dl_cache_chill_seat_missing_until";
const string DL_L_NPC_CACHE_WORK_PRIMARY = "dl_cache_work_primary";
const string DL_L_NPC_CACHE_WORK_SECONDARY = "dl_cache_work_secondary";
const string DL_L_NPC_CACHE_WORK_FETCH = "dl_cache_work_fetch";
const string DL_L_NPC_CACHE_HOME_AREA = "dl_cache_home_area";
const string DL_L_NPC_CACHE_WORK_AREA = "dl_cache_work_area";
const string DL_L_NPC_CACHE_MEAL_AREA = "dl_cache_meal_area";
const string DL_L_NPC_CACHE_SOCIAL_AREA = "dl_cache_social_area";
const string DL_L_NPC_CACHE_PUBLIC_AREA = "dl_cache_public_area";
const string DL_L_NPC_FOCUS_STATUS = "dl_npc_focus_status";
const string DL_L_NPC_FOCUS_TARGET = "dl_npc_focus_target";
const string DL_L_NPC_FOCUS_DIAGNOSTIC = "dl_npc_focus_diagnostic";
const string DL_L_NPC_SOCIAL_SLOT = "dl_social_slot";
const string DL_L_NPC_SOCIAL_PARTNER_TAG = "dl_social_partner_tag";
const string DL_L_NPC_WEEKEND_MODE = "dl_weekend_mode";
const string DL_L_NPC_WEEKEND_SHIFT_LENGTH = "dl_weekend_shift_length";
const string DL_L_NPC_HOME_AREA_TAG = "dl_home_area_tag";
const string DL_L_NPC_HOME_SLOT = "dl_home_slot";
const string DL_L_NPC_WORK_AREA_TAG = "dl_work_area_tag";
const string DL_L_NPC_MEAL_AREA_TAG = "dl_meal_area_tag";
const string DL_L_NPC_SOCIAL_AREA_TAG = "dl_social_area_tag";
const string DL_L_NPC_PUBLIC_AREA_TAG = "dl_public_area_tag";
const string DL_L_NPC_WAKE_HOUR = "dl_wake_hour";
const string DL_L_NPC_SLEEP_HOURS = "dl_sleep_hours";
const string DL_L_NPC_SHIFT_START = "dl_shift_start";
const string DL_L_NPC_SHIFT_LENGTH = "dl_shift_length";
const string DL_L_NPC_DIAG_LAST_KEY = "dl_diag_last_key";
const string DL_L_NPC_DIAG_LAST_MINUTE = "dl_diag_last_minute";
const string DL_L_MODULE_CHAT_DEBUG = "dl_chat_debug";
const string DL_L_MODULE_CHAT_DEBUG_NPC_TAG = "dl_chat_debug_npc_tag";
const string DL_L_NPC_CHAT_LAST_EVENT_SIG = "dl_chat_last_event_sig";
const string DL_L_NPC_CHAT_STUCK_SIG = "dl_chat_stuck_sig";
const string DL_L_NPC_CHAT_STUCK_SINCE = "dl_chat_stuck_since";
const string DL_L_NPC_CHAT_STUCK_LAST_LOG = "dl_chat_stuck_last_log";
const string DL_L_MODULE_CACHE_EPOCH = "dl_cache_epoch";
const string DL_L_MODULE_FORCE_CACHE_RESET = "dl_force_cache_reset";
const string DL_L_AREA_CACHE_EPOCH = "dl_area_cache_epoch";
const string DL_L_AREA_FORCE_CACHE_RESET = "dl_force_area_cache_reset";
const string DL_L_NPC_CACHE_EPOCH = "dl_npc_cache_epoch";
const string DL_L_NPC_FORCE_CACHE_RESET = "dl_force_npc_cache_reset";

const string DL_PROFILE_BLACKSMITH = "blacksmith";
const string DL_PROFILE_GATE_POST = "gate_post";
const string DL_PROFILE_TRADER = "trader";
const string DL_PROFILE_DOMESTIC_WORKER = "domestic_worker";

const string DL_STATE_IDLE = "idle";
const string DL_STATE_SLEEP = "sleep";
const string DL_STATE_WORK = "work";
const string DL_STATE_SOCIAL = "social";
const string DL_STATE_MEAL = "meal";
const string DL_STATE_PUBLIC = "public";
const string DL_STATE_CHILL = "chill";

const string DL_DIALOGUE_IDLE = "idle";
const string DL_DIALOGUE_SLEEP = "sleep";
const string DL_DIALOGUE_WORK = "work";
const string DL_DIALOGUE_SOCIAL = "social";

const string DL_SERVICE_OFF = "off";
const string DL_SERVICE_AVAILABLE = "available";

const string DL_MAT_SLEEP = "sleep";
const string DL_MAT_WORK = "work";
const string DL_MAT_SOCIAL = "social";
const string DL_MAT_MEAL = "meal";
const string DL_MAT_PUBLIC = "public";
const string DL_MAT_CHILL = "chill";

const int DL_DIR_NONE = 0;
const int DL_DIR_SLEEP = 1;
const int DL_DIR_WORK = 2;
const int DL_DIR_SOCIAL = 3;
const int DL_DIR_MEAL = 4;
const int DL_DIR_PUBLIC = 5;
const int DL_DIR_CHILL = 6;
const int DL_SLEEP_PHASE_NONE = 0;
const int DL_SLEEP_PHASE_MOVING = 1;
const int DL_SLEEP_PHASE_JUMPING = 2;
const int DL_SLEEP_PHASE_ON_BED = 3;

const float DL_SLEEP_APPROACH_RADIUS = 1.50;
const float DL_SLEEP_BED_RADIUS = 1.10;
const float DL_WORK_ANCHOR_RADIUS = 1.60;

const string DL_WORK_KIND_FORGE = "forge";
const string DL_WORK_KIND_CRAFT = "craft";
const string DL_WORK_KIND_FETCH = "fetch";
const string DL_WORK_KIND_POST = "post";
const string DL_WORK_KIND_TRADE = "trade";
const string DL_WORK_KIND_DOMESTIC = "domestic";
const string DL_WEEKEND_MODE_OFF_PUBLIC = "off_public";
const string DL_WEEKEND_MODE_REDUCED_WORK = "reduced_work";
const string DL_MEAL_KIND_BREAKFAST = "breakfast";
const string DL_MEAL_KIND_LUNCH = "lunch";
const string DL_MEAL_KIND_DINNER = "dinner";
const int DL_CHAT_STUCK_THRESHOLD_MIN = 5;
const int DL_CHAT_STUCK_LOG_INTERVAL_MIN = 5;
const int DL_CHAT_MARKUP_COOLDOWN_MIN = 120;

// Forward declarations for symbols implemented in includes that are
// textually attached later in this file.
int DL_IsActivePipelineNpc(object oNpc);
int DL_IsAreaObject(object oObject);
object DL_GetHomeArea(object oNpc);
object DL_GetWorkArea(object oNpc);
object DL_ResolveChillWaypoint(object oNpc);
void DL_MaybeRefreshNpcCachesForEpoch(object oNpc);
void DL_MaybeRefreshAreaCachesForEpoch(object oArea);

#include "dl_sched_inc"

void DL_LogChat(string sMessage)
{
    // Temporary: chat debug logging is disabled.
}
int DL_IsChatDebugEnabledForNpc(object oNpc)
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_CHAT_DEBUG) != TRUE)
    {
        return FALSE;
    }

    string sFilterTag = GetLocalString(oModule, DL_L_MODULE_CHAT_DEBUG_NPC_TAG);
    if (sFilterTag == "" || !GetIsObjectValid(oNpc))
    {
        return TRUE;
    }

    return GetTag(oNpc) == sFilterTag;
}
string DL_GetDirectiveDebugLabel(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP)
    {
        return "SLEEP";
    }
    if (nDirective == DL_DIR_WORK)
    {
        return "WORK";
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return "MEAL";
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return "SOCIAL";
    }
    if (nDirective == DL_DIR_PUBLIC)
    {
        return "PUBLIC";
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return "CHILL";
    }
    return "NONE";
}
void DL_LogDomainDebugEvent(object oNpc, string sDomain, string sEventCode, string sKeyContext)
{
    if (!GetIsObjectValid(oNpc) || !DL_IsChatDebugEnabledForNpc(oNpc))
    {
        return;
    }

    string sNpcTag = GetTag(oNpc);
    string sPayload = "domain=" + sDomain + " event_code=" + sEventCode + " npc_tag=" + sNpcTag + " key_context=" + sKeyContext;
    string sSig = sDomain + "|" + sEventCode + "|" + sNpcTag + "|" + sKeyContext;
    if (GetLocalString(oNpc, DL_L_NPC_CHAT_LAST_EVENT_SIG) == sSig)
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_CHAT_LAST_EVENT_SIG, sSig);
    DL_LogChat(sPayload);
}

void DL_LogTransitionEvent(object oNpc, string sEventCode, string sKeyContext)
{
    DL_LogDomainDebugEvent(oNpc, "transition", sEventCode, sKeyContext);
}
void DL_LogSocialEvent(object oNpc, string sEventCode, string sKeyContext)
{
    DL_LogDomainDebugEvent(oNpc, "social", sEventCode, sKeyContext);
}
void DL_LogCrimeEvent(object oNpc, string sEventCode, string sKeyContext)
{
    DL_LogDomainDebugEvent(oNpc, "crime", sEventCode, sKeyContext);
}

void DL_LogDirectiveChange(object oNpc, int nPrevDirective, int nDirective)
{
    if (nDirective == nPrevDirective)
    {
        return;
    }

    DL_LogTransitionEvent(
        oNpc,
        "directive",
        "dir=" + DL_GetDirectiveDebugLabel(nDirective) +
            " prev=" + DL_GetDirectiveDebugLabel(nPrevDirective) +
            " minute=" + IntToString(DL_GetNowMinuteOfDay())
    );
}
void DL_LogStuckState(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc) || !DL_IsChatDebugEnabledForNpc(oNpc))
    {
        return;
    }

    string sState = "";
    string sTarget = "";
    if (nDirective == DL_DIR_SLEEP)
    {
        sState = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
        if (sState == "moving_to_approach" || sState == "jumping_to_bed")
        {
            sTarget = GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
        }
    }
    else if (nDirective == DL_DIR_WORK)
    {
        sState = GetLocalString(oNpc, DL_L_NPC_WORK_STATUS);
        if (sState == "moving_to_anchor")
        {
            sTarget = GetLocalString(oNpc, DL_L_NPC_WORK_TARGET);
        }
    }
    else if (nDirective == DL_DIR_MEAL || nDirective == DL_DIR_SOCIAL || nDirective == DL_DIR_PUBLIC || nDirective == DL_DIR_CHILL)
    {
        sState = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        if (sState == "moving_to_anchor")
        {
            sTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
        }
    }

    if (sTarget == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_CHAT_STUCK_SIG);
        DeleteLocalInt(oNpc, DL_L_NPC_CHAT_STUCK_SINCE);
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    string sSig = DL_GetDirectiveDebugLabel(nDirective) + "|" + sState + "|" + sTarget;
    if (GetLocalString(oNpc, DL_L_NPC_CHAT_STUCK_SIG) != sSig)
    {
        SetLocalString(oNpc, DL_L_NPC_CHAT_STUCK_SIG, sSig);
        SetLocalInt(oNpc, DL_L_NPC_CHAT_STUCK_SINCE, nNowAbsMin);
        DeleteLocalInt(oNpc, DL_L_NPC_CHAT_STUCK_LAST_LOG);
        return;
    }

    int nSince = GetLocalInt(oNpc, DL_L_NPC_CHAT_STUCK_SINCE);
    int nLastLog = GetLocalInt(oNpc, DL_L_NPC_CHAT_STUCK_LAST_LOG);
    if ((nNowAbsMin - nSince) < DL_CHAT_STUCK_THRESHOLD_MIN ||
        (nLastLog > 0 && (nNowAbsMin - nLastLog) < DL_CHAT_STUCK_LOG_INTERVAL_MIN))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CHAT_STUCK_LAST_LOG, nNowAbsMin);
    DL_LogTransitionEvent(oNpc, "stuck_state", "dir=" + DL_GetDirectiveDebugLabel(nDirective) + " state=" + sState + " target=" + sTarget);
}
void DL_LogMarkupIssueOnce(object oNpc, string sKey, string sMessage)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    string sLastKey = GetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY);
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE);
    if (sLastKey == sKey && (nNowAbsMin - nLastMin) < DL_CHAT_MARKUP_COOLDOWN_MIN)
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY, sKey);
    SetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE, nNowAbsMin);
    if (DL_IsChatDebugEnabledForNpc(oNpc))
    {
        DL_LogChat(sMessage);
    }
}

void DL_ApplyMaterializationSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirective == DL_DIR_SLEEP)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SLEEP);
        return;
    }

    if (nDirective == DL_DIR_WORK)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_WORK);
        return;
    }

    if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SOCIAL);
        return;
    }

    if (nDirective == DL_DIR_MEAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_MEAL);
        return;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_PUBLIC);
        return;
    }

    if (nDirective == DL_DIR_CHILL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_CHILL);
        return;
    }

    DeleteLocalInt(oNpc, DL_L_NPC_MAT_REQ);
    DeleteLocalString(oNpc, DL_L_NPC_MAT_TAG);
}

#include "dl_anchor_cache_inc"
#include "dl_social_pool_inc"
#include "dl_presentation_inc"
#include "dl_sleep_inc"
#include "dl_work_inc"
#include "dl_focus_inc"

int DL_GetModuleCacheEpoch()
{
    object oModule = GetModule();
    int nEpoch = GetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH);
    if (nEpoch <= 0)
    {
        nEpoch = 1;
        SetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH, nEpoch);
    }
    return nEpoch;
}
void DL_ConsumeModuleCacheResetRequest()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_FORCE_CACHE_RESET) != TRUE)
    {
        return;
    }

    int nEpoch = DL_GetModuleCacheEpoch() + 1;
    SetLocalInt(oModule, DL_L_MODULE_CACHE_EPOCH, nEpoch);
    DeleteLocalInt(oModule, DL_L_MODULE_FORCE_CACHE_RESET);
}
void DL_ClearAreaNavigationCache(object oArea)
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
void DL_MaybeRefreshAreaCachesForEpoch(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    DL_ConsumeModuleCacheResetRequest();
    int nEpoch = DL_GetModuleCacheEpoch();
    if (GetLocalInt(oArea, DL_L_AREA_FORCE_CACHE_RESET) == TRUE ||
        GetLocalInt(oArea, DL_L_AREA_CACHE_EPOCH) != nEpoch)
    {
        DL_ClearAreaNavigationCache(oArea);
        SetLocalInt(oArea, DL_L_AREA_CACHE_EPOCH, nEpoch);
        DeleteLocalInt(oArea, DL_L_AREA_FORCE_CACHE_RESET);
    }
}
void DL_ClearNpcWaypointCaches(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SLEEP_APPROACH);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SLEEP_BED);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_FORGE);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_CRAFT);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_POST);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_TRADE);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_PRIMARY);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_SECONDARY);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_FETCH);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_MEAL);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_A);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_B);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_PUBLIC);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_CHILL_SEAT);
    DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
    DL_ClearNpcSocialReservation(oNpc);
}
void DL_ClearNpcAreaCaches(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_HOME_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_WORK_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_AREA);
    DeleteLocalObject(oNpc, DL_L_NPC_CACHE_PUBLIC_AREA);
}
void DL_ClearNpcRuntimeCaches(object oNpc)
{
    DL_ClearNpcWaypointCaches(oNpc);
    DL_ClearNpcAreaCaches(oNpc);
}
void DL_MaybeRefreshNpcCachesForEpoch(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (GetIsObjectValid(oArea))
    {
        DL_MaybeRefreshAreaCachesForEpoch(oArea);
    }
    else
    {
        DL_ConsumeModuleCacheResetRequest();
    }

    int nEpoch = DL_GetModuleCacheEpoch();
    if (GetLocalInt(oNpc, DL_L_NPC_FORCE_CACHE_RESET) == TRUE ||
        GetLocalInt(oNpc, DL_L_NPC_CACHE_EPOCH) != nEpoch)
    {
        DL_ClearNpcRuntimeCaches(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_CACHE_EPOCH, nEpoch);
        DeleteLocalInt(oNpc, DL_L_NPC_FORCE_CACHE_RESET);
    }
}

void DL_SetInteractionModes(object oNpc, string sDialogue, string sService)
{
    SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, sDialogue);
    SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, sService);
}
int DL_IsProfileServiceAvailable(string sProfile)
{
    return sProfile != DL_PROFILE_GATE_POST;
}
void DL_ApplyIdleLikeDirectiveState(object oNpc, int bSocial)
{
    SetLocalString(oNpc, DL_L_NPC_STATE, bSocial ? DL_STATE_SOCIAL : DL_STATE_IDLE);
    DL_SetInteractionModes(
        oNpc,
        bSocial ? DL_DIALOGUE_SOCIAL : DL_DIALOGUE_IDLE,
        DL_SERVICE_OFF
    );
    DL_ClearSleepExecutionState(oNpc);
    DL_ClearWorkExecutionState(oNpc);
    DL_ClearFocusExecutionState(oNpc);
    DL_ClearNpcSocialReservation(oNpc);
    DL_ClearActivityPresentation(oNpc);
}
// Deprecated: legacy external fallback predicate; SOCIAL fallback now runs
// atomically inside SOCIAL execution branch.
int DL_ShouldFallbackSocialToPublic(object oNpc)
{
    return FALSE;
}
int DL_ShouldUseDirectiveFastPath(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "" ||
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "" ||
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC) != "")
    {
        return FALSE;
    }

    if (DL_GetNpcProblemSummary(oNpc) != "ok")
    {
        return FALSE;
    }

    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        return GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE) == DL_SLEEP_PHASE_ON_BED &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == "on_bed" &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_WORK)
    {
        return GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == "on_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    return FALSE;
}

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DL_MaybeRefreshNpcCachesForEpoch(oNpc);

    int nEffectiveDirective = nDirective;
    int nPrevDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);

    if (nPrevDirective != nEffectiveDirective)
    {
        DL_ClearNpcSocialReservation(oNpc);
    }

    if (nPrevDirective == nEffectiveDirective && DL_ShouldUseDirectiveFastPath(oNpc, nEffectiveDirective))
    {
        DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
        DL_LogStuckState(oNpc, nEffectiveDirective);
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DIRECTIVE, nEffectiveDirective);
    DL_LogDirectiveChange(oNpc, nPrevDirective, nEffectiveDirective);

    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearWorkExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SLEEP);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SLEEP, DL_SERVICE_OFF);
        DL_ApplyArchiveActivityPresentation(oNpc, nEffectiveDirective);
        DL_ExecuteSleepDirective(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_WORK);
        string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
        DL_SetInteractionModes(
            oNpc,
            DL_DIALOGUE_WORK,
            DL_IsProfileServiceAvailable(sProfile) ? DL_SERVICE_AVAILABLE : DL_SERVICE_OFF
        );

        DL_ClearSleepExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        DL_ExecuteWorkDirective(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_MEAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_MEAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteMealDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SOCIAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SOCIAL, DL_SERVICE_OFF);
        DL_ExecuteSocialDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_PUBLIC);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecutePublicDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nEffectiveDirective == DL_DIR_CHILL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_CHILL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteChillDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else
    {
        DL_ApplyIdleLikeDirectiveState(oNpc, FALSE);
    }

    DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
    DL_LogStuckState(oNpc, nEffectiveDirective);
}
