#include "dl_activity_archive_anim_inc"
#include "dl_move_job_decl_inc"
#include "dl_transition_inc"

// Step 05+: resolver/materialization skeleton.
string DL_GetNpcProblemSummary(object oNpc);
// Scope: basic BLACKSMITH/GATE_POST/TRADER WORK/SLEEP window split.

const string DL_L_NPC_DIRECTIVE = "dl_npc_directive";
const string DL_L_NPC_MAT_REQ = "dl_npc_mat_req";
const string DL_L_NPC_MAT_TAG = "dl_npc_mat_tag";
const string DL_L_NPC_DIALOGUE_MODE = "dl_npc_dialogue_mode";
const string DL_L_NPC_SERVICE_MODE = "dl_npc_service_mode";
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
const string DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE = "dl_work_fastpath_presentation_minute";
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
const string DL_L_NPC_LAST_DIRECTIVE_CLEANUP = "dl_last_directive_cleanup";
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

const string DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE = "directive_preempted_old_move";
const string DL_L_NPC_DBG_OLD_MOVE_OWNER = "old_move_owner";
const string DL_L_NPC_DBG_OLD_MOVE_TARGET = "old_move_target";
const string DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV = "directive_change_prev";
const string DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT = "directive_change_next";
const string DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP = "directive_change_cleanup";
const string DL_L_NPC_MOVE_TICKET_BEFORE_DBG = "move_ticket_before";
const string DL_L_NPC_MOVE_TICKET_AFTER_DBG = "move_ticket_after";
const string DL_L_NPC_MOVE_RESULT_BEFORE_TICK_DBG = "move_result_before_tick";
const string DL_L_NPC_MOVE_RESULT_AFTER_TICK_DBG = "move_result_after_tick";
const string DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG = "move_result_regressed_to_running";
const string DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG = "move_result_regression_reason";
const string DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG = "move_result_regression_stage";
const string DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG = "invariant_violation_reached_move_still_running";
const string DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG = "reached_finalize_returned_true_but_state_still_running";
const string DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG = "reached_invariant_emergency_closed";
const string DL_L_NPC_REACHED_INVARIANT_OWNER_DBG = "reached_invariant_owner";
const string DL_L_NPC_REACHED_INVARIANT_TARGET_DBG = "reached_invariant_target";
const string DL_L_NPC_TRANSITION_MOVE_TICKED_DBG = "transition_move_ticked";
const string DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG = "transition_move_reissued";
const string DL_L_NPC_TRANSITION_MOVE_REACHED_DBG = "transition_move_reached";
const string DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG = "transition_execute_attempted";
const string DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG = "transition_execute_success";
const string DL_L_NPC_TRANSITION_MISMATCH_SUPPRESSED_DBG = "transition_mismatch_suppressed";

const string DL_L_NPC_MOVE_OWNER = "dl_move_owner";
const string DL_L_NPC_MOVE_PHASE = "dl_move_phase";
const string DL_L_NPC_MOVE_TARGET_TAG = "dl_move_target_tag";
const string DL_L_NPC_MOVE_TARGET_AREA = "dl_move_target_area";
const string DL_L_NPC_MOVE_RADIUS = "dl_move_radius";
const string DL_L_NPC_MOVE_TICKET = "dl_move_ticket";
const string DL_L_NPC_MOVE_RESULT = "dl_move_result";
const string DL_L_NPC_MOVE_DIAGNOSTIC = "dl_move_diagnostic";
const string DL_L_NPC_MOVE_TARGET_OBJ = "dl_move_target_obj";

const string DL_MOVE_RESULT_RUNNING = "running";
const string DL_MOVE_RESULT_REACHED = "reached";
const string DL_MOVE_RESULT_FAILED = "failed";

const string DL_MOVE_OWNER_SLEEP = "sleep";
const string DL_MOVE_OWNER_WORK = "work";
const string DL_MOVE_OWNER_MEAL = "meal";
const string DL_MOVE_OWNER_SOCIAL = "social";
const string DL_MOVE_OWNER_PUBLIC = "public";
const string DL_MOVE_OWNER_CHILL = "chill";
const string DL_MOVE_OWNER_TRANSITION = "transition";

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
const int DL_WORK_FASTPATH_PRESENTATION_REFRESH_MINUTES = 30;

// Forward declarations for symbols implemented in includes that are
// textually attached later in this file.
int DL_IsActivePipelineNpc(object oNpc);
int DL_IsAreaObject(object oObject);
object DL_GetHomeArea(object oNpc);
object DL_GetWorkArea(object oNpc);
object DL_ResolveChillWaypoint(object oNpc);
int DL_ShouldFallbackSocialToPublic(object oNpc);
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
int DL_DirectiveUsesFocusState(int nDirective)
{
    return nDirective == DL_DIR_MEAL ||
        nDirective == DL_DIR_SOCIAL ||
        nDirective == DL_DIR_PUBLIC ||
        nDirective == DL_DIR_CHILL;
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
void DL_LogChatDebugEvent(object oNpc, string sKind, string sPayload)
{
    // Old broad Daily Life chat/debug output was removed; use DL_BsmithTraceStage for the temporary blacksmith trace.
}
void DL_LogDirectiveChange(object oNpc, int nPrevDirective, int nDirective)
{
    if (nDirective == nPrevDirective)
    {
        return;
    }

    DL_LogChatDebugEvent(
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
    DL_LogChat("npc=" + GetTag(oNpc) +
              " stuck dir=" + DL_GetDirectiveDebugLabel(nDirective) +
              " state=" + sState +
              " target=" + sTarget);
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
#include "dl_presentation_inc"
#include "dl_sleep_inc"
#include "dl_anchor_move_inc"
#include "dl_move_job_inc"
#include "dl_work_inc"
#include "dl_focus_inc"

string DL_BsmithAreaTag(object oObj)
{
    if (!GetIsObjectValid(oObj))
    {
        return "";
    }
    object oArea = GetArea(oObj);
    if (GetIsObjectValid(oArea))
    {
        return GetTag(oArea);
    }
    return "";
}

string DL_BsmithObjectValid(object oObj)
{
    if (GetIsObjectValid(oObj))
    {
        return "1";
    }
    return "0";
}

void DL_BsmithTraceDisable(object oNpc)
{
    object oModule = GetModule();
    DeleteLocalInt(oModule, "dl_bsmith_trace");
    DeleteLocalInt(oModule, "dl_bsmith_trace_budget");
    if (GetIsObjectValid(oNpc))
    {
        DeleteLocalInt(oNpc, "dl_bsmith_trace");
        DeleteLocalInt(oNpc, "dl_bsmith_trace_budget");
    }
}

int DL_BsmithTraceBudget(object oNpc)
{
    int nBudget = 0;
    if (GetIsObjectValid(oNpc))
    {
        nBudget = GetLocalInt(oNpc, "dl_bsmith_trace_budget");
    }
    if (nBudget <= 0)
    {
        nBudget = GetLocalInt(GetModule(), "dl_bsmith_trace_budget");
    }
    return nBudget;
}

int DL_BsmithTraceEnabled(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetTag(oNpc) != "blacksmith01")
    {
        return FALSE;
    }

    int bTrace = GetLocalInt(GetModule(), "dl_bsmith_trace") == TRUE || GetLocalInt(oNpc, "dl_bsmith_trace") == TRUE;
    if (!bTrace)
    {
        return FALSE;
    }

    if (DL_BsmithTraceBudget(oNpc) <= 0)
    {
        DL_BsmithTraceDisable(oNpc);
        return FALSE;
    }

    return TRUE;
}

void DL_BsmithConsumeTraceBudget(object oNpc)
{
    int nBudget = DL_BsmithTraceBudget(oNpc);
    if (nBudget <= 1)
    {
        DL_BsmithTraceDisable(oNpc);
        return;
    }

    if (GetIsObjectValid(oNpc) && GetLocalInt(oNpc, "dl_bsmith_trace_budget") > 0)
    {
        SetLocalInt(oNpc, "dl_bsmith_trace_budget", nBudget - 1);
        return;
    }

    SetLocalInt(GetModule(), "dl_bsmith_trace_budget", nBudget - 1);
}

void DL_BsmithEmitLine(object oNpc, string sLine)
{
    if (!DL_BsmithTraceEnabled(oNpc))
    {
        return;
    }

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sLine);
        oPC = GetNextPC();
    }

    DL_BsmithConsumeTraceBudget(oNpc);
}

void DL_BsmithContradiction(object oNpc, string sType, string sEvidence)
{
    if (!DL_BsmithTraceEnabled(oNpc))
    {
        return;
    }
    DL_BsmithEmitLine(oNpc, "BSMITH_CONTRADICTION type=" + sType + " evidence=" + sEvidence);
}

void DL_BsmithClassify(object oNpc, string sCategory, string sConfidence, string sReason)
{
    if (!DL_BsmithTraceEnabled(oNpc))
    {
        return;
    }
    string sSig = sCategory + "|" + sConfidence + "|" + sReason;
    if (GetLocalString(oNpc, "dl_bsmith_last_classify") == sSig)
    {
        return;
    }
    SetLocalString(oNpc, "dl_bsmith_last_classify", sSig);
    DL_BsmithEmitLine(oNpc, "BSMITH_CLASSIFY category=" + sCategory + " confidence=" + sConfidence + " reason=" + sReason);
}

object DL_BsmithFallbackObjectByTag(string sTag)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }
    return GetObjectByTag(sTag, 0);
}

object DL_BsmithMoveObject(object oNpc)
{
    return GetLocalObject(oNpc, DL_L_NPC_MOVE_TARGET_OBJ);
}

object DL_BsmithFocusObject(object oNpc)
{
    return DL_BsmithFallbackObjectByTag(GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET));
}

void DL_BsmithDetectContradictions(object oNpc, string sStage, object oMoveObj, object oFocusObj, float fMoveDist, float fFocusDist)
{
    object oNpcArea = GetArea(oNpc);
    object oRegArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    string sMoveTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    string sFocusTag = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    string sMoveResult = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    float fRadius = GetLocalFloat(oNpc, DL_L_NPC_MOVE_RADIUS);
    if (fRadius <= 0.0)
    {
        fRadius = DL_MOVE_DEFAULT_RADIUS;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_MOVE_LAST_PROGRESS_TICK) > 0 && GetLocalFloat(oNpc, DL_L_NPC_MOVE_LAST_DIST) == 0.0 && fMoveDist > fRadius)
    {
        DL_BsmithContradiction(oNpc, "DISTANCE_MISMATCH_ZERO_VS_REAL", "simple=0 real=" + FloatToString(fMoveDist, 1, 2));
        DL_BsmithClassify(oNpc, "DISTANCE_REPORTING_BUG", "high", "zero_vs_real_distance");
    }
    if (sMoveTag != "" && !GetIsObjectValid(oMoveObj))
    {
        DL_BsmithContradiction(oNpc, "MOVE_TARGET_INVALID", "tag=" + sMoveTag);
        DL_BsmithClassify(oNpc, "TARGET_RESOLUTION_BUG", "high", "move_target_invalid");
    }
    if (sFocusTag != "" && !GetIsObjectValid(oFocusObj))
    {
        DL_BsmithContradiction(oNpc, "FOCUS_TARGET_INVALID", "tag=" + sFocusTag);
        DL_BsmithClassify(oNpc, "TARGET_RESOLUTION_BUG", "high", "focus_target_invalid");
    }
    if (sMoveResult == DL_MOVE_RESULT_RUNNING && GetIsObjectValid(oMoveObj) && GetArea(oMoveObj) != oNpcArea)
    {
        DL_BsmithContradiction(oNpc, "MOVE_TARGET_WRONG_AREA", "npc_area=" + DL_BsmithAreaTag(oNpc) + " target_area=" + DL_BsmithAreaTag(oMoveObj));
    }
    if (sFocusStatus == "moving_to_anchor" && GetIsObjectValid(oFocusObj) && GetArea(oFocusObj) != oNpcArea)
    {
        DL_BsmithContradiction(oNpc, "FOCUS_TARGET_WRONG_AREA", "npc_area=" + DL_BsmithAreaTag(oNpc) + " target_area=" + DL_BsmithAreaTag(oFocusObj));
    }
    if (GetIsObjectValid(oRegArea) && GetIsObjectValid(oNpcArea) && oRegArea != oNpcArea)
    {
        DL_BsmithContradiction(oNpc, "REGISTRY_AREA_MISMATCH", "reg=" + GetTag(oRegArea) + " actual=" + GetTag(oNpcArea));
    }
    if (GetLocalString(oNpc, "dl_worker_touch_area") != "" && GetLocalString(oNpc, "dl_worker_touch_area") != DL_BsmithAreaTag(oNpc))
    {
        DL_BsmithContradiction(oNpc, "WORKER_AREA_MISMATCH", "worker=" + GetLocalString(oNpc, "dl_worker_touch_area") + " actual=" + DL_BsmithAreaTag(oNpc));
    }
    if (sMoveResult == DL_MOVE_RESULT_RUNNING && GetLocalInt(oNpc, DL_L_NPC_MOVE_CURRENT_ACTION_DBG) != ACTION_MOVETOPOINT)
    {
        int nBad = GetLocalInt(oNpc, "dl_bsmith_bad_action_samples") + 1;
        SetLocalInt(oNpc, "dl_bsmith_bad_action_samples", nBad);
        if (nBad >= 2)
        {
            DL_BsmithContradiction(oNpc, "ACTION_QUEUE_NOT_RUNNING", "result=running action=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_MOVE_CURRENT_ACTION_DBG)) + " samples=" + IntToString(nBad));
        }
    }
    else
    {
        DeleteLocalInt(oNpc, "dl_bsmith_bad_action_samples");
    }
    if (GetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_REASON_DBG) == "target_not_reached" && DL_IsMoveJobAtTargetNow(oNpc))
    {
        DL_BsmithContradiction(oNpc, "FINALIZE_DISTANCE_CONFLICT", "finalize=target_not_reached canonical_reached=1 raw=" + FloatToString(GetLocalFloat(oNpc, DL_L_NPC_MOVE_REACH_CHECK_RAW_DIST_DBG), 1, 2));
    }
    if (sMoveTag != "" && GetIsObjectValid(oMoveObj))
    {
        object oPrev = GetLocalObject(oNpc, "dl_bsmith_last_target_obj");
        if (GetLocalString(oNpc, "dl_bsmith_last_target_tag") == sMoveTag && GetIsObjectValid(oPrev) && oPrev != oMoveObj)
        {
            DL_BsmithContradiction(oNpc, "TARGET_IDENTITY_CHANGED", "tag=" + sMoveTag + " prev_area=" + GetLocalString(oNpc, "dl_bsmith_last_target_area") + " new_area=" + DL_BsmithAreaTag(oMoveObj));
            DL_BsmithClassify(oNpc, "TARGET_RESOLUTION_BUG", "medium", "target_identity_changed");
        }
        SetLocalString(oNpc, "dl_bsmith_last_target_tag", sMoveTag);
        SetLocalString(oNpc, "dl_bsmith_last_target_area", DL_BsmithAreaTag(oMoveObj));
        SetLocalObject(oNpc, "dl_bsmith_last_target_obj", oMoveObj);
    }
}

void DL_BsmithMaybeClassify(object oNpc, string sProblem)
{
    if (GetLocalInt(oNpc, DL_L_NPC_MOVE_NO_PROGRESS_COUNT) >= 3)
    {
        DL_BsmithClassify(oNpc, "PATHFINDING_OR_COLLISION_BLOCKED", "medium", "no_progress_reissues=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_MOVE_REISSUE_COUNT)));
    }
    if (GetLocalInt(oNpc, "dl_bsmith_bad_action_samples") >= 3)
    {
        DL_BsmithClassify(oNpc, "ACTION_QUEUE_NOT_RUNNING", "high", "running_without_moveto");
    }
    if (sProblem == "regular_worker_not_touching_registered_npc")
    {
        DL_BsmithClassify(oNpc, "WORKER_NOT_TOUCHING_NPC", "high", sProblem);
    }
    if (GetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_REASON_DBG) == "target_not_reached" && !DL_IsMoveJobAtTargetNow(oNpc))
    {
        DL_BsmithClassify(oNpc, "FINALIZE_REACHED_FAILED", "medium", "target_not_reached");
    }
    object oRegArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    if (GetIsObjectValid(oRegArea) && oRegArea != GetArea(oNpc))
    {
        DL_BsmithClassify(oNpc, "AREA_REGISTRY_STALE", "high", "registry_area_mismatch");
    }
    if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "" && GetLocalString(oNpc, "dl_post_jump_result") == "post_jump_finalizer_complete")
    {
        DL_BsmithClassify(oNpc, "TRANSITION_HANDOFF_STALE", "medium", "post_jump_with_transition_state");
    }
    if (sProblem != "ok" && GetLocalString(oNpc, "dl_bsmith_last_classify") == "")
    {
        DL_BsmithClassify(oNpc, "UNKNOWN_NEEDS_MORE_TRACE", "low", sProblem);
    }
}

/*
How to use bounded trace mode:
1. Set dl_bsmith_trace=1 and dl_bsmith_trace_budget=N on the module or blacksmith01.
2. Reproduce blacksmith01 behavior around 19:00 -> 21:00 in gotha_tavern.
3. Collect only BSMITH_TRACE / BSMITH_CONTRADICTION / BSMITH_CLASSIFY lines.
4. The trace auto-clears dl_bsmith_trace when the budget reaches 0.
*/
void DL_BsmithTraceStage(object oNpc, string sStage, string sNote)
{
    if (!DL_BsmithTraceEnabled(oNpc))
    {
        return;
    }

    object oMoveObj = DL_BsmithMoveObject(oNpc);
    object oFocusObj = DL_BsmithFocusObject(oNpc);
    float fMoveDist = -1.0;
    float fFocusDist = -1.0;
    if (GetIsObjectValid(oMoveObj) && GetArea(oMoveObj) == GetArea(oNpc))
    {
        fMoveDist = GetDistanceBetween(oNpc, oMoveObj);
    }
    if (GetIsObjectValid(oFocusObj) && GetArea(oFocusObj) == GetArea(oNpc))
    {
        fFocusDist = GetDistanceBetween(oNpc, oFocusObj);
    }

    int bCanonicalReached = GetLocalInt(oNpc, DL_L_NPC_MOVE_REACH_CHECK_RESULT_DBG);
    if (DL_HasMoveJob(oNpc))
    {
        bCanonicalReached = DL_IsMoveJobAtTargetNow(oNpc);
    }
    float fRawReachDist = GetLocalFloat(oNpc, DL_L_NPC_MOVE_REACH_CHECK_RAW_DIST_DBG);
    int nCurrentAction = GetCurrentAction(oNpc);
    string sProblem = DL_GetNpcProblemSummary(oNpc);
    vector vPos = GetPosition(oNpc);
    object oRegArea = GetLocalObject(oNpc, "dl_npc_reg_area");
    string sRegArea = "";
    if (GetIsObjectValid(oRegArea))
    {
        sRegArea = GetTag(oRegArea);
    }
    int nRegSlot = GetLocalInt(oNpc, "dl_npc_reg_slot");
    int bSlotSelf = FALSE;
    if (GetIsObjectValid(oRegArea) && nRegSlot >= 0)
    {
        bSlotSelf = GetLocalObject(oRegArea, "dl_reg_slot_" + IntToString(nRegSlot)) == oNpc;
    }

    string sSignature = sStage + "|" +
        DL_GetDirectiveDebugLabel(GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE)) + "|" +
        GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) + "|" +
        GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) + "|" +
        GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) + "|" +
        GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) + "|" +
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) + "|" +
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) + "|" +
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) + "|" +
        IntToString(nCurrentAction) + "|" +
        sProblem + "|" +
        sNote;
    string sSigKey = "dl_bsmith_trace_sig_" + sStage;
    string sTimeKey = "dl_bsmith_trace_min_" + sStage;
    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nLastAbsMin = GetLocalInt(oNpc, sTimeKey);
    if (GetLocalString(oNpc, sSigKey) == sSignature &&
        nLastAbsMin > 0 &&
        (nNowAbsMin - nLastAbsMin) < 5)
    {
        return;
    }
    SetLocalString(oNpc, sSigKey, sSignature);
    SetLocalInt(oNpc, sTimeKey, nNowAbsMin);
    SetLocalString(oNpc, "dl_bsmith_trace_last_stage", sStage);
    SetLocalString(oNpc, "dl_bsmith_trace_last_sig", sSignature);
    SetLocalString(oNpc, "dl_bsmith_trace_last_directive", DL_GetDirectiveDebugLabel(GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE)));
    SetLocalString(oNpc, "dl_bsmith_trace_last_move_owner", GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER));
    SetLocalString(oNpc, "dl_bsmith_trace_last_move_result", GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT));
    SetLocalString(oNpc, "dl_bsmith_trace_last_move_target", GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG));
    SetLocalString(oNpc, "dl_bsmith_trace_last_problem", sProblem);

    int nSeq = GetLocalInt(GetModule(), "dl_bsmith_trace_seq") + 1;
    SetLocalInt(GetModule(), "dl_bsmith_trace_seq", nSeq);

    string sLine = "BSMITH_TRACE seq=" + IntToString(nSeq) +
        " stage=" + sStage +
        " t=" + IntToString(GetTimeHour()) + ":" + IntToString(GetTimeMinute()) +
        " npc=" + GetTag(oNpc) +
        " area=" + DL_BsmithAreaTag(oNpc) +
        " pos=" + FloatToString(vPos.x, 1, 1) + "," + FloatToString(vPos.y, 1, 1) + "," + FloatToString(vPos.z, 1, 1) +
        " dir=" + DL_GetDirectiveDebugLabel(GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE)) +
        " state=" + GetLocalString(oNpc, DL_L_NPC_STATE) +
        " problem=" + sProblem +
        " move=" + GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) + "/" + GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) + "/" + GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) + "/" + GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) +
        " move_result=" + GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) +
        " move_owner=" + GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) +
        " move_target=" + GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) +
        " canonical_reached=" + IntToString(bCanonicalReached) +
        " raw_dist=" + FloatToString(fRawReachDist, 1, 2) +
        " current_action=" + IntToString(nCurrentAction) +
        " focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
        " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
        " move_ticket=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET)) +
        " mobj=" + DL_BsmithObjectValid(oMoveObj) + "/" + DL_BsmithAreaTag(oMoveObj) + "/" + FloatToString(fMoveDist, 1, 2) +
        " focus=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) + "/" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
        " fobj=" + DL_BsmithObjectValid(oFocusObj) + "/" + DL_BsmithAreaTag(oFocusObj) + "/" + FloatToString(fFocusDist, 1, 2) +
        " action=" + IntToString(nCurrentAction) +
        " worker=" + IntToString(GetLocalInt(oNpc, "npc_worker_touch_seq")) + "/" + GetLocalString(oNpc, "npc_touch_skipped_reason") +
        " reg=" + sRegArea + "/" + IntToString(nRegSlot) + "/" + IntToString(bSlotSelf) +
        " trans=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) + "/" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) +
        " note=" + sNote;

    DL_BsmithEmitLine(oNpc, sLine);
    DL_BsmithDetectContradictions(oNpc, sStage, oMoveObj, oFocusObj, fMoveDist, fFocusDist);
    DL_BsmithMaybeClassify(oNpc, sProblem);
}

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
    DL_ClearMoveJob(oNpc);
    SetLocalString(oNpc, DL_L_NPC_STATE, bSocial ? DL_STATE_SOCIAL : DL_STATE_IDLE);
    DL_SetInteractionModes(
        oNpc,
        bSocial ? DL_DIALOGUE_SOCIAL : DL_DIALOGUE_IDLE,
        DL_SERVICE_OFF
    );
    DL_ClearSleepExecutionState(oNpc);
    DL_ClearWorkExecutionState(oNpc);
    DL_ClearFocusExecutionState(oNpc);
    DL_ClearActivityPresentation(oNpc);
}
int DL_ResolveEffectiveDirective(object oNpc, int nDirective)
{
    if (nDirective == DL_DIR_SOCIAL && DL_ShouldFallbackSocialToPublic(oNpc))
    {
        return DL_DIR_PUBLIC;
    }

    return nDirective;
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

    if (nEffectiveDirective == DL_DIR_MEAL)
    {
        string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
        return GetSubString(sFocusStatus, 0, 15) == "on_meal_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_social_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "" &&
               !DL_HasMoveJob(oNpc);
    }

    if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_public_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "" &&
               !DL_HasMoveJob(oNpc);
    }

    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }

    return FALSE;
}
void DL_RefreshWorkPresentationOnFastPath(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_WORK ||
        GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) != "on_anchor" ||
        GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) == "")
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE);
    if (nLastMin > 0 && (nNowAbsMin - nLastMin) < DL_WORK_FASTPATH_PRESENTATION_REFRESH_MINUTES)
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE, nNowAbsMin);
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
}

object DL_ResolveFocusTargetInCurrentArea(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sTarget = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    if (sTarget == "")
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nIndex = 0;
    object oCandidate = GetObjectByTag(sTarget, nIndex);
    while (GetIsObjectValid(oCandidate) && nIndex < DL_WAYPOINT_TAG_SEARCH_CAP)
    {
        if (GetArea(oCandidate) == oArea)
        {
            return oCandidate;
        }

        nIndex = nIndex + 1;
        oCandidate = GetObjectByTag(sTarget, nIndex);
    }

    return OBJECT_INVALID;
}

int DL_IsFocusRecoverySocialTarget(object oNpc, object oTarget)
{
    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL)
    {
        return TRUE;
    }

    object oSocial = DL_ResolveSocialWaypoint(oNpc);
    if (GetIsObjectValid(oSocial) && oSocial == oTarget)
    {
        return TRUE;
    }

    return FALSE;
}

void DL_RecoverReachedFocusAnchorMoveState(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "moving_to_anchor")
    {
        return;
    }

    object oTarget = DL_ResolveFocusTargetInCurrentArea(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        return;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        return;
    }

    if (DL_IsFocusRecoverySocialTarget(oNpc, oTarget))
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_social_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
        AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
        DL_LogChatDebugEvent(
            oNpc,
            "social_recover_reached_anchor",
            "social_recover_reached_anchor anchor=" + GetTag(oTarget) +
                " dist=" + FloatToString(GetDistanceBetween(oNpc, oTarget), 1, 2) +
                " current_action=" + IntToString(GetCurrentAction(oNpc))
        );
        return;
    }

    if (GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
    {
        return;
    }

    DL_ClearFocusMoveIssueState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
}

object DL_ResolveDirectiveAnchorForMoveBridge(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        return DL_ResolvePublicWaypoint(oNpc);
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return DL_ResolveSocialWaypoint(oNpc);
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return DL_ResolveMealWaypoint(oNpc, DL_ResolveMealKind(oNpc));
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return DL_ResolveChillWaypoint(oNpc);
    }

    return OBJECT_INVALID;
}

string DL_GetDirectiveMoveOwnerForBridge(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP) return DL_MOVE_OWNER_SLEEP;
    if (nDirective == DL_DIR_WORK) return DL_MOVE_OWNER_WORK;
    if (nDirective == DL_DIR_PUBLIC) return DL_MOVE_OWNER_PUBLIC;
    if (nDirective == DL_DIR_SOCIAL) return DL_MOVE_OWNER_SOCIAL;
    if (nDirective == DL_DIR_MEAL) return DL_MOVE_OWNER_MEAL;
    if (nDirective == DL_DIR_CHILL) return DL_MOVE_OWNER_CHILL;
    return "";
}

string DL_GetDirectiveDestinationZone(object oNpc, int nDirective)
{
    if (GetIsObjectValid(oNpc) &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) == DL_GetDirectiveMoveOwnerForBridge(nDirective) &&
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "")
    {
        return GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oAnchor))
    {
        return "";
    }

    string sZone = DL_NavGetAnchorZoneId(oAnchor);
    if (sZone != "")
    {
        return sZone;
    }

    return DL_NavGetAreaZoneId(GetArea(oAnchor));
}

int DL_IsTransitionMoveJobCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sPhase = GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    if (sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        // Legacy transition-owned jobs are accepted only through the explicit
        // transition compatibility checks below.
    }
    else
    {
        if (sPhase != DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA)
        {
            return FALSE;
        }

        if (sOwner != DL_GetDirectiveMoveOwnerForBridge(nDirective))
        {
            return FALSE;
        }
    }

    string sDirectiveZone = DL_GetDirectiveDestinationZone(oNpc, nDirective);
    if (sDirectiveZone == "")
    {
        return FALSE;
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (GetIsObjectValid(oAnchor))
    {
        if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea == oAnchorArea)
        {
            return FALSE;
        }
    }

    string sMoveTargetZone = GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET);
    if (sMoveTargetZone == "" && sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        sMoveTargetZone = GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE);
    }
    if (sMoveTargetZone != sDirectiveZone)
    {
        return FALSE;
    }

    string sMoveTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    string sCurrentZone = DL_NavGetNpcCurrentZone(oNpc);
    string sNextZone = DL_NavGetNextZone(oNpc, sDirectiveZone);
    if (sCurrentZone == "" || sNextZone == "")
    {
        return FALSE;
    }

    return sMoveTargetTag == DL_NavMakeTransitionTag(sCurrentZone, sNextZone);
}

int DL_ProcessTransitionMoveInApply(object oNpc, int nEffectiveDirective)
{
    if (!DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nEffectiveDirective))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_TICKED_DBG, TRUE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MISMATCH_SUPPRESSED_DBG, TRUE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REACHED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, FALSE);

    if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) == "")
    {
        DL_NavSetState(oNpc, "moving_to_entry", GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE), "");
    }

    DL_TickMoveJob(oNpc);
    if (GetLocalInt(oNpc, DL_L_NPC_MOVE_ACTION_REISSUED_DBG) == TRUE)
    {
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REISSUED_DBG, TRUE);
    }

    if (DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED || DL_IsMoveJobAtTargetNow(oNpc))
    {
        object oTargetWp = DL_ResolveMoveJobTarget(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_MOVE_REACHED_DBG, TRUE);
        SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_ATTEMPTED_DBG, TRUE);
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oTargetWp))
        {
            SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, TRUE);
        }
        else
        {
            SetLocalInt(oNpc, DL_L_NPC_TRANSITION_EXECUTE_SUCCESS_DBG, FALSE);
        }
        return TRUE;
    }

    return TRUE;
}

int DL_IsMoveJobOwnerCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    if (sOwner == "")
    {
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) == DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA)
    {
        return DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nDirective);
    }

    if (sOwner == DL_MOVE_OWNER_PUBLIC) return nDirective == DL_DIR_PUBLIC;
    if (sOwner == DL_MOVE_OWNER_SOCIAL) return nDirective == DL_DIR_SOCIAL;
    if (sOwner == DL_MOVE_OWNER_MEAL) return nDirective == DL_DIR_MEAL;
    if (sOwner == DL_MOVE_OWNER_CHILL) return nDirective == DL_DIR_CHILL;
    if (sOwner == DL_MOVE_OWNER_WORK) return nDirective == DL_DIR_WORK;
    if (sOwner == DL_MOVE_OWNER_SLEEP) return nDirective == DL_DIR_SLEEP;
    if (sOwner == DL_MOVE_OWNER_TRANSITION)
    {
        return DL_IsTransitionMoveJobCompatibleWithDirective(oNpc, nDirective);
    }

    return FALSE;
}

int DL_IsFocusStateCompatibleWithDirective(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sFocusStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    if (sFocusStatus == "")
    {
        return TRUE;
    }

    if (sFocusStatus == "on_public_anchor") return nDirective == DL_DIR_PUBLIC;
    if (sFocusStatus == "on_social_anchor") return nDirective == DL_DIR_SOCIAL;
    if (GetSubString(sFocusStatus, 0, 15) == "on_meal_anchor") return nDirective == DL_DIR_MEAL;
    if (sFocusStatus == "on_chill_anchor") return nDirective == DL_DIR_CHILL;

    if (sFocusStatus == "moving_to_anchor")
    {
        return DL_DirectiveUsesFocusState(nDirective) &&
               DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nDirective);
    }

    return DL_DirectiveUsesFocusState(nDirective);
}

void DL_ClearDirectiveChangeDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT);
    DeleteLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP);
}

void DL_PreemptOldDirectiveState(object oNpc, int nPrevDirective, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sOldMoveOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sOldMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    int bHadMoveJob = DL_HasMoveJob(oNpc);
    int bClearedFocus = FALSE;
    int bClearedTransition = FALSE;

    SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, bHadMoveJob);
    SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER, sOldMoveOwner);
    SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET, sOldMoveTarget);
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV, DL_GetDirectiveDebugLabel(nPrevDirective));
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT, DL_GetDirectiveDebugLabel(nEffectiveDirective));

    DL_ClearMoveJob(oNpc);

    if (DL_DirectiveUsesFocusState(nPrevDirective) ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "" ||
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "")
    {
        DL_ClearFocusExecutionState(oNpc);
        bClearedFocus = TRUE;
        bClearedTransition = TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "" ||
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "" ||
        GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC) != "")
    {
        DL_ClearTransitionExecutionState(oNpc);
        bClearedTransition = TRUE;
    }

    if (DL_DirectiveUsesFocusState(nPrevDirective) ||
        nPrevDirective == DL_DIR_WORK ||
        nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearActivityPresentation(oNpc);
    }

    SetLocalString(
        oNpc,
        DL_L_NPC_LAST_DIRECTIVE_CLEANUP,
        "prev=" + DL_GetDirectiveDebugLabel(nPrevDirective) +
            " next=" + DL_GetDirectiveDebugLabel(nEffectiveDirective) +
            " old_move_owner=" + sOldMoveOwner +
            " old_move_target=" + sOldMoveTarget +
            " cleared_move=" + IntToString(bHadMoveJob) +
            " cleared_focus=" + IntToString(bClearedFocus) +
            " cleared_transition=" + IntToString(bClearedTransition)
    );
    SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP, GetLocalString(oNpc, DL_L_NPC_LAST_DIRECTIVE_CLEANUP));
}

int DL_HasDistantSameAreaDirectiveAnchor(object oNpc, int nDirective)
{
    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea != oAnchorArea)
    {
        return FALSE;
    }

    return GetDistanceBetween(oNpc, oAnchor) > DL_WORK_ANCHOR_RADIUS;
}

int DL_BridgeLegacyDirectiveAnchorMoveJob(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc) || DL_HasMoveJob(oNpc) || !DL_DirectiveUsesFocusState(nDirective))
    {
        return FALSE;
    }

    object oAnchor = DL_ResolveDirectiveAnchorForMoveBridge(oNpc, nDirective);
    if (!GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    object oNpcArea = GetArea(oNpc);
    object oAnchorArea = GetArea(oAnchor);
    if (!GetIsObjectValid(oNpcArea) || !GetIsObjectValid(oAnchorArea) || oNpcArea != oAnchorArea)
    {
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oAnchor) <= DL_WORK_ANCHOR_RADIUS)
    {
        return FALSE;
    }

    string sOwner = DL_GetDirectiveMoveOwnerForBridge(nDirective);
    if (sOwner == "")
    {
        return FALSE;
    }

    string sReason = "bridge_" + sOwner + "_anchor";
    if (nDirective == DL_DIR_PUBLIC &&
        (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) == "transitioning" ||
            GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == ""))
    {
        sReason = "bridge_public_anchor_after_transition";
    }

    DL_ClearTransitionExecutionState(oNpc);
    DL_ClearFocusMoveIssueState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "moving_to_anchor");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oAnchor));
    DL_BeginMoveJobToObject(oNpc, sOwner, "anchor", oAnchor, DL_WORK_ANCHOR_RADIUS);
    string sAnchorZone = DL_NavGetAnchorZoneId(oAnchor);
    DL_NavSetDebug(oNpc, DL_NavGetNpcCurrentZone(oNpc), sAnchorZone, sAnchorZone, sReason);
    DL_LogChatDebugEvent(
        oNpc,
        sReason,
        sReason +
            " owner=" + sOwner +
            " anchor=" + GetTag(oAnchor) +
            " area=" + GetTag(oAnchorArea) +
            " dist=" + FloatToString(GetDistanceBetween(oNpc, oAnchor), 1, 2)
    );
    return TRUE;
}

void DL_SetReachedFinalizeDebug(object oNpc, int bAttempted, int bSuccess, string sReason, int nDirective, string sOwner, string sTargetTag)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_ATTEMPTED_DBG, bAttempted);
    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_SUCCESS_DBG, bSuccess);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_REASON_DBG, sReason);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_DIRECTIVE_DBG, DL_GetDirectiveDebugLabel(nDirective));
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_OWNER_DBG, sOwner);
    SetLocalString(oNpc, DL_L_NPC_REACHED_FINALIZE_TARGET_DBG, sTargetTag);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_AFTER_REACHED_FINALIZE_DBG, GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS));
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_AFTER_REACHED_FINALIZE_DBG, GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT));
}

int DL_FinalizeReachedDirectiveMoveJob(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_REACHED_FINALIZE_USED_FOCUS_DBG, FALSE);

    DL_BsmithTraceStage(oNpc, "FINALIZE_ENTER", DL_GetDirectiveDebugLabel(nEffectiveDirective));

    if (!DL_HasMoveJob(oNpc))
    {
        DL_SetReachedFinalizeDebug(oNpc, FALSE, FALSE, "no_move_job", nEffectiveDirective, "", "");
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "no_move_job");
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "checking", nEffectiveDirective, sOwner, sTargetTag);

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        object oUnreachedTarget = DL_ResolveMoveJobTarget(oNpc);
        if (!GetIsObjectValid(oUnreachedTarget))
        {
            DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "missing_target", nEffectiveDirective, sOwner, sTargetTag);
            DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "missing_target");
            return FALSE;
        }

        object oNpcAreaCheck = GetArea(oNpc);
        object oTargetAreaCheck = GetArea(oUnreachedTarget);
        if (!GetIsObjectValid(oNpcAreaCheck) || !GetIsObjectValid(oTargetAreaCheck) || oNpcAreaCheck != oTargetAreaCheck)
        {
            DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "target_area_mismatch", nEffectiveDirective, sOwner, sTargetTag);
            DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "target_area_mismatch");
            return FALSE;
        }

        DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "target_not_reached", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "target_not_reached");
        return FALSE;
    }

    DL_MarkMoveJobReachedNow(oNpc, "finalize_at_target");
    object oTarget = DL_ResolveMoveJobTarget(oNpc);
    if (!GetIsObjectValid(oTarget))
    {
        DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "missing_target_after_reach", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "missing_target_after_reach");
        return FALSE;
    }

    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT, DL_MOVE_RESULT_REACHED);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_REACHED_FINALIZED_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_OWNER_DBG, sOwner);
    SetLocalString(oNpc, DL_L_NPC_REACHED_MOVE_TARGET_DBG, sTargetTag);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);

    if (sOwner == DL_MOVE_OWNER_PUBLIC && nEffectiveDirective == DL_DIR_PUBLIC)
    {
        string sAnim = "pause";
        if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
        {
            sAnim = "talk01";
        }
        DL_ClearMoveJob(oNpc);
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_public_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
        PlayCustomAnimation(oNpc, sAnim, TRUE);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "public_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "public_anchor_finalized");
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SOCIAL && nEffectiveDirective == DL_DIR_SOCIAL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteSocialDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "social_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "social_anchor_finalized");
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_MEAL && nEffectiveDirective == DL_DIR_MEAL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteMealDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "meal_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "meal_anchor_finalized");
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_CHILL && nEffectiveDirective == DL_DIR_CHILL)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteChillDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "chill_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "chill_anchor_finalized");
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_WORK && nEffectiveDirective == DL_DIR_WORK)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteWorkDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "work_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "work_anchor_finalized");
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SLEEP && nEffectiveDirective == DL_DIR_SLEEP)
    {
        DL_ClearMoveJob(oNpc);
        DL_ExecuteSleepDirective(oNpc);
        DL_SetReachedFinalizeDebug(oNpc, TRUE, TRUE, "sleep_anchor_finalized", nEffectiveDirective, sOwner, sTargetTag);
        DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "sleep_anchor_finalized");
        return TRUE;
    }

    DL_SetReachedFinalizeDebug(oNpc, TRUE, FALSE, "owner_directive_mismatch", nEffectiveDirective, sOwner, sTargetTag);
    DL_BsmithTraceStage(oNpc, "FINALIZE_RESULT", "owner_directive_mismatch");
    return FALSE;
}

void DL_TraceApplyPipeline(object oNpc, string sStage)
{
    DL_BsmithTraceStage(
        oNpc,
        sStage,
        "move_result=" + GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) +
            " move_owner=" + GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) +
            " move_target=" + GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) +
            " canonical_reached=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_MOVE_REACH_CHECK_RESULT_DBG)) +
            " raw_dist=" + FloatToString(GetLocalFloat(oNpc, DL_L_NPC_MOVE_REACH_CHECK_RAW_DIST_DBG), 1, 2) +
            " current_action=" + IntToString(GetCurrentAction(oNpc)) +
            " focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
            " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
            " move_ticket=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET))
    );
}

int DL_IsDirectiveStableAfterReachedFinalize(object oNpc, int nEffectiveDirective)
{
    if (nEffectiveDirective == DL_DIR_PUBLIC)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_public_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_SOCIAL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_social_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_MEAL)
    {
        return GetSubString(GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS), 0, 15) == "on_meal_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_CHILL)
    {
        return GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_WORK)
    {
        return GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) == "on_anchor" &&
               GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) != "";
    }
    if (nEffectiveDirective == DL_DIR_SLEEP)
    {
        return GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) == "on_bed" &&
               GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) != "";
    }
    return TRUE;
}

void DL_VerifyReachedFinalizeClosure(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if ((DL_HasMoveJob(oNpc) && GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING) ||
        !DL_IsDirectiveStableAfterReachedFinalize(oNpc, nEffectiveDirective))
    {
        SetLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC, DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
        DL_BsmithTraceStage(oNpc, "INVARIANT", DL_L_NPC_REACHED_FINALIZE_HARD_DIAG_DBG);
    }
}

int DL_EmergencyCloseReachedMoveInvariant(object oNpc, int nEffectiveDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
    string sTargetTag = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    if (sTargetTag == "")
    {
        sTargetTag = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    }

    if (sOwner == DL_MOVE_OWNER_PUBLIC && nEffectiveDirective == DL_DIR_PUBLIC && sTargetTag != "")
    {
        DL_ClearMoveJob(oNpc);
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_public_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        SetLocalInt(oNpc, DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_OWNER_DBG, sOwner);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_TARGET_DBG, sTargetTag);
        DL_BsmithTraceStage(oNpc, "INVARIANT", "reached_invariant_emergency_closed=1 reached_invariant_owner=public reached_invariant_target=" + sTargetTag);
        return TRUE;
    }

    if (sOwner == DL_MOVE_OWNER_SOCIAL && nEffectiveDirective == DL_DIR_SOCIAL && sTargetTag != "")
    {
        DL_ClearMoveJob(oNpc);
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_social_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sTargetTag);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalString(oNpc, DL_L_NPC_MOVE_DIAGNOSTIC);
        SetLocalInt(oNpc, DL_L_NPC_REACHED_INVARIANT_EMERGENCY_CLOSED_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_OWNER_DBG, sOwner);
        SetLocalString(oNpc, DL_L_NPC_REACHED_INVARIANT_TARGET_DBG, sTargetTag);
        DL_BsmithTraceStage(oNpc, "INVARIANT", "reached_invariant_emergency_closed=1 reached_invariant_owner=social reached_invariant_target=" + sTargetTag);
        return TRUE;
    }

    return FALSE;
}

void DL_DetectApplyMoveRegression(object oNpc, int bReachedOrClearedEarlier, int nMoveTicketBefore, string sMoveTargetBefore, string sStage, int nEffectiveDirective)
{
    if (!bReachedOrClearedEarlier)
    {
        return;
    }

    if (sMoveTargetBefore != "" &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING &&
        GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET) == nMoveTicketBefore &&
        GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG) == sMoveTargetBefore)
    {
        SetLocalInt(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG, sStage);
        SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG, "same_tick_reopened_reached_move");
        DL_BsmithTraceStage(oNpc, "INVARIANT", "move_result_regressed_to_running stage=" + sStage + " reason=same_tick_reopened_reached_move");
        if (DL_IsMoveJobAtTargetNow(oNpc))
        {
            DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective);
            if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
            {
                DL_EmergencyCloseReachedMoveInvariant(oNpc, nEffectiveDirective);
            }
        }
    }
}

void DL_EnforceReachedMoveApplyExitInvariant(object oNpc, int nEffectiveDirective)
{
    if (DL_IsMoveJobAtTargetNow(oNpc) &&
        (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING ||
            GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "moving_to_anchor"))
    {
        SetLocalInt(oNpc, DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG, TRUE);
        DL_BsmithTraceStage(oNpc, "INVARIANT", "invariant_violation_reached_move_still_running");
        if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
        {
            DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
        }
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
        {
            DL_EmergencyCloseReachedMoveInvariant(oNpc, nEffectiveDirective);
        }
    }
}

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    DL_MaybeRefreshNpcCachesForEpoch(oNpc);

    int nEffectiveDirective = DL_ResolveEffectiveDirective(oNpc, nDirective);
    int nPrevDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    int nApplyStartMoveTicket = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    string sApplyStartMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
    DL_BsmithTraceStage(oNpc, "DIRECTIVE_RESOLVED", DL_GetDirectiveDebugLabel(nEffectiveDirective));
    DL_TraceApplyPipeline(oNpc, "APPLY_ENTER");

    if (nPrevDirective != nEffectiveDirective)
    {
        DL_PreemptOldDirectiveState(oNpc, nPrevDirective, nEffectiveDirective);
    }
    else
    {
        DL_ClearDirectiveChangeDebug(oNpc);
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER) != DL_MOVE_OWNER_TRANSITION &&
            GetLocalString(oNpc, DL_L_NPC_MOVE_PHASE) != DL_NAV_MOVE_PHASE_TRANSITION_TO_AREA &&
            DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective) &&
            DL_IsMoveJobAtTargetNow(oNpc))
        {
            DL_TraceApplyPipeline(oNpc, "BEFORE_FINALIZE_REACHED");
            if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
            {
                DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            }
            DL_TraceApplyPipeline(oNpc, "AFTER_FINALIZE_REACHED");
        }
        DL_RecoverReachedFocusAnchorMoveState(oNpc);
        if (DL_ProcessTransitionMoveInApply(oNpc, nEffectiveDirective))
        {
            DL_TraceApplyPipeline(oNpc, "APPLY_EXIT");
            DL_LogStuckState(oNpc, nEffectiveDirective);
            return;
        }
        if (!DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective))
        {
            string sBadMoveOwner = GetLocalString(oNpc, DL_L_NPC_MOVE_OWNER);
            string sBadMoveTarget = GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG);
            DL_ClearMoveJob(oNpc);
            SetLocalInt(oNpc, DL_L_NPC_DBG_DIRECTIVE_PREEMPTED_OLD_MOVE, TRUE);
            SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_OWNER, sBadMoveOwner);
            SetLocalString(oNpc, DL_L_NPC_DBG_OLD_MOVE_TARGET, sBadMoveTarget);
            SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_PREV, DL_GetDirectiveDebugLabel(nPrevDirective));
            SetLocalString(oNpc, DL_L_NPC_DBG_DIRECTIVE_CHANGE_NEXT, DL_GetDirectiveDebugLabel(nEffectiveDirective));
            SetLocalString(
                oNpc,
                DL_L_NPC_DBG_DIRECTIVE_CHANGE_CLEANUP,
                "move_owner_mismatch_cleared old_move_owner=" + sBadMoveOwner +
                    " old_move_target=" + sBadMoveTarget
            );
        }
        DL_BridgeLegacyDirectiveAnchorMoveJob(oNpc, nEffectiveDirective);
    }

    int nMoveTicketBefore = nApplyStartMoveTicket;
    string sMoveTargetBefore = sApplyStartMoveTarget;
    string sMoveResultBeforeTick = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    int bReachedOrClearedEarlier = sMoveResultBeforeTick == DL_MOVE_RESULT_REACHED || !DL_HasMoveJob(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET_BEFORE_DBG, nMoveTicketBefore);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_BEFORE_TICK_DBG, sMoveResultBeforeTick);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSED_TO_RUNNING_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_REASON_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_MOVE_RESULT_REGRESSION_STAGE_DBG);
    SetLocalInt(oNpc, DL_L_NPC_INVARIANT_REACHED_MOVE_STILL_RUNNING_DBG, FALSE);

    int bMoveJobTicked = FALSE;
    if (nPrevDirective == nEffectiveDirective && DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nEffectiveDirective))
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_TICK_MOVE_JOB");
        bMoveJobTicked = DL_TickMoveJob(oNpc);
        if (bMoveJobTicked && DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_REACHED)
        {
            DL_TraceApplyPipeline(oNpc, "BEFORE_FINALIZE_REACHED");
            if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
            {
                DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            }
            DL_TraceApplyPipeline(oNpc, "AFTER_FINALIZE_REACHED");
            bReachedOrClearedEarlier = TRUE;
        }
        DL_TraceApplyPipeline(oNpc, "AFTER_TICK_MOVE_JOB");
    }
    else
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_TICK_MOVE_JOB");
        DL_TraceApplyPipeline(oNpc, "AFTER_TICK_MOVE_JOB");
    }

    if (!DL_HasMoveJob(oNpc) || GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_REACHED)
    {
        bReachedOrClearedEarlier = TRUE;
    }
    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_TICK_MOVE_JOB", nEffectiveDirective);

    if (bMoveJobTicked && DL_GetMoveJobResult(oNpc) == DL_MOVE_RESULT_RUNNING)
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_FINALIZE_REACHED");
        if (DL_FinalizeReachedDirectiveMoveJob(oNpc, nEffectiveDirective))
        {
            DL_VerifyReachedFinalizeClosure(oNpc, nEffectiveDirective);
            bReachedOrClearedEarlier = TRUE;
        }
        DL_TraceApplyPipeline(oNpc, "AFTER_FINALIZE_REACHED");
        if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) == DL_MOVE_RESULT_RUNNING)
        {
            DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
        }
    }

    int nMoveTicketAfter = GetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET);
    string sMoveResultAfterTick = GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT);
    SetLocalInt(oNpc, DL_L_NPC_MOVE_TICKET_AFTER_DBG, nMoveTicketAfter);
    SetLocalString(oNpc, DL_L_NPC_MOVE_RESULT_AFTER_TICK_DBG, sMoveResultAfterTick);
    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "BEFORE_DIRECTIVE_EXECUTOR", nEffectiveDirective);

    if (nPrevDirective == nEffectiveDirective && DL_ShouldUseDirectiveFastPath(oNpc, nEffectiveDirective))
    {
        DL_TraceApplyPipeline(oNpc, "BEFORE_DIRECTIVE_EXECUTOR");
        if (nEffectiveDirective == DL_DIR_WORK)
        {
            DL_RefreshWorkPresentationOnFastPath(oNpc);
        }
        DL_TraceApplyPipeline(oNpc, "AFTER_DIRECTIVE_EXECUTOR");

        DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_DIRECTIVE_EXECUTOR", nEffectiveDirective);
        DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
        DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
        DL_TraceApplyPipeline(oNpc, "APPLY_EXIT");
        DL_LogStuckState(oNpc, nEffectiveDirective);
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DIRECTIVE, nEffectiveDirective);
    DL_LogDirectiveChange(oNpc, nPrevDirective, nEffectiveDirective);

    DL_TraceApplyPipeline(oNpc, "BEFORE_DIRECTIVE_EXECUTOR");
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
        DeleteLocalInt(oNpc, DL_L_NPC_WORK_FASTPATH_PRESENTATION_MINUTE);
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
    DL_TraceApplyPipeline(oNpc, "AFTER_DIRECTIVE_EXECUTOR");

    DL_DetectApplyMoveRegression(oNpc, bReachedOrClearedEarlier, nMoveTicketBefore, sMoveTargetBefore, "AFTER_DIRECTIVE_EXECUTOR", nEffectiveDirective);
    DL_ApplyMaterializationSkeleton(oNpc, nEffectiveDirective);
    DL_EnforceReachedMoveApplyExitInvariant(oNpc, nEffectiveDirective);
    DL_TraceApplyPipeline(oNpc, "APPLY_EXIT");
    DL_LogStuckState(oNpc, nEffectiveDirective);
}
