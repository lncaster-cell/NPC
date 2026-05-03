const string DL_L_MODULE_ENABLED = "dl_enabled";
const string DL_L_MODULE_CONTRACT_VERSION = "dl_contract_version";
const string DL_CONTRACT_VERSION_A0 = "a0";
const string DL_L_MODULE_CHAT_LOG = "dl_chat_log";
const string DL_L_MODULE_CHAT_LOG_INIT = "dl_chat_log_init";
const string DL_L_MODULE_RUNTIME_LOG = "dl_runtime_log";

const int OBJECT_TYPE_AREA = 4;
location LOCATION_INVALID;

int DL_IsAreaObject(object oObject);
int DL_GetAreaTier(object oArea);
void DL_LogChatDebugEvent(object oNpc, string sKind, string sPayload);
int DL_AddLocalInt(object oTarget, string sKey, int nDelta);

int GetIsInConversation(object oCreature)
{
    return FALSE;
}

const int DL_RUNTIME_TIER_WARM = 1;
const int DL_RUNTIME_TIER_HOT = 2;

// Runtime statuses (terminal: stable until directive/phase changes).
const string DL_STATUS_MISSING_WAYPOINTS = "missing_waypoints";
const string DL_STATUS_MOVING_TO_ANCHOR = "moving_to_anchor";
const string DL_STATUS_ON_ANCHOR = "on_anchor";
const string DL_STATUS_MOVING_VIA_NAVIGATION = "moving_via_navigation";
const string DL_STATUS_ON_BED = "on_bed";
const string DL_STATUS_ON_CHILL_ANCHOR = "on_chill_anchor";

// Runtime statuses (transitional: short-lived during sleep/focus flow).
const string DL_STATUS_MOVING_TO_APPROACH = "moving_to_approach";
const string DL_STATUS_APPROACH_REACHED = "approach_reached";
const string DL_STATUS_JUMPING_TO_BED = "jumping_to_bed";
const string DL_STATUS_SITTING_CHILL_ATTEMPT = "sitting_chill_attempt";

// Transition/scheduler event statuses.
const string DL_STATUS_TARGET_SLEEP = "target_sleep";
const string DL_STATUS_TARGET_WORK = "target_work";
const string DL_STATUS_ON_WORK_ANCHOR = "on_work_anchor";
const string DL_STATUS_FALLBACK_MEAL_WORK = "fallback_meal_work";
const string DL_STATUS_FALLBACK_MEAL_HOME = "fallback_meal_home";

// Diagnostic codes (canonical: <domain>_<detail>). 
const string DL_DIAG_SLEEP_WAYPOINTS_MISSING = "sleep_waypoints_missing";
const string DL_DIAG_SLEEP_JUMP_INVALID_TARGET_LOCATION = "sleep_jump_invalid_target_location";
const string DL_DIAG_WORK_FORGE_AND_CRAFT_WAYPOINTS_REQUIRED = "work_forge_and_craft_waypoints_required";

void DL_SetRuntimeState(object oNpc, string sStatusKey, string sStatus, string sDiagKey, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc)) return;
    if (sStatusKey != "" && GetLocalString(oNpc, sStatusKey) != sStatus) SetLocalString(oNpc, sStatusKey, sStatus);
    if (sDiagKey != "" && GetLocalString(oNpc, sDiagKey) != sDiagnostic) SetLocalString(oNpc, sDiagKey, sDiagnostic);
}

const string DL_DIAG_FOCUS_SOCIAL_PARTNER_SELF = "social_partner_self";
const string DL_DIAG_FOCUS_MISSING_MEAL_ANCHOR = "missing_meal_anchor";
const string DL_DIAG_FOCUS_MISSING_CHILL_CHAIR = "missing_chill_chair";
const string DL_DIAG_FOCUS_CHILL_CHAIR_OCCUPIED = "chill_chair_occupied";
const string DL_DIAG_FOCUS_MISSING_CHILL_SEAT = "missing_chill_seat";
const string DL_DIAG_FOCUS_MISSING_PUBLIC_ANCHOR = "focus_missing_public_anchor";
const string DL_DIAG_FOCUS_SOCIAL_FALLBACK_TO_PUBLIC = "social_fallback_to_public";
const string DL_DIAG_FOCUS_MISSING_SOCIAL_POOL_PREFIX = "missing_social_pool_";

const string DL_MSG_FOCUS_FALLBACK_SOCIAL_PUBLIC = "fallback social->public";
const string DL_MSG_FOCUS_SOCIAL_PARTNER_LOOKUP = "social partner lookup";
const string DL_MSG_FOCUS_FALLBACK_MEAL_WORK = "fallback meal->work";
const string DL_MSG_FOCUS_FALLBACK_MEAL_HOME = "fallback meal->home";
const string DL_MSG_FOCUS_MISSING_PUBLIC_AREA = "has no public/social area for PUBLIC directive.";
const string DL_MSG_RESULT_FOUND_OUTSIDE_AREA = "found_outside_area";
const string DL_MSG_RESULT_TAG_NOT_FOUND = "tag_not_found";

const string DL_L_MODULE_CR_DETAIN_DIALOG = "dl_cr_detain_dialog";
const string DL_L_MODULE_TRANSITION_DRIVER_LOOKUP_CAP = "dl_transition_driver_lookup_cap";
const string DL_L_PC_CR_DETAIN_PENDING = "dl_cr_detain_pending";
const string DL_L_PC_CR_DETAIN_PENDING_REASON = "dl_cr_detain_pending_reason";
const string DL_L_PC_CR_DETAIN_PENDING_RESOLUTION = "dl_cr_detain_pending_resolution";
const string DL_L_PC_CR_LAST_GUARD = "dl_cr_last_guard";
const string DL_L_NPC_CR_OFFENDER_UNTIL = "dl_cr_offender_until";
const string DL_L_NPC_CR_INVESTIGATE_TARGET = "dl_cr_investigate_target";
const string DL_L_NPC_CR_INVESTIGATE_UNTIL = "dl_cr_investigate_until";
const string DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN = "dl_lg_case_last_update_abs_min";

const string DL_L_NPC_EVENT_KIND = "dl_npc_event_kind";
const string DL_L_NPC_EVENT_SEQ = "dl_npc_event_seq";
const string DL_L_MODULE_EVENT_SEQ = "dl_module_event_seq";
const string DL_L_MODULE_LAST_EVENT_KIND = "dl_module_last_event_kind";
const string DL_L_MODULE_LAST_EVENT_ACTOR = "dl_module_last_event_actor";
const string DL_L_MODULE_SPAWN_COUNT = "dl_module_spawn_count";
const string DL_L_MODULE_DEATH_COUNT = "dl_module_death_count";
const string DL_L_MODULE_CLEANUP_CNT = "dl_module_cleanup_count";

const string DL_LG_CASE_KIND_KILL = "kill";
const string DL_LG_CASE_KIND_ATTACK = "attack";
const string DL_LG_CASE_KIND_DOOR_LOCKPICK = "door_lockpick";
const string DL_LG_CASE_KIND_RESTRICTED_ENTRY = "restricted_entry";
const string DL_LG_CASE_KIND_CONTAINER_THEFT = "container_theft";
const string DL_LG_CASE_KIND_PICKPOCKET = "pickpocket";
const string DL_LG_CASE_KIND_PLACEABLE_LOCKPICK = "placeable_lockpick";
const string DL_LG_CASE_KIND_DETAIN_REFUSAL = "detain_refusal";

const string DL_CR_EVT_PICKPOCKET = "pickpocket";
const string DL_CR_EVT_CONTAINER_THEFT = "container_theft";
const string DL_CR_EVT_DOOR_LOCKPICK = "door_lockpick";
const string DL_CR_EVT_PLACEABLE_LOCKPICK = "placeable_lockpick";
const string DL_CR_EVT_RESTRICTED_ENTRY = "restricted_entry";

const string DL_LG_CASE_RESOLUTION_FINE = "fine";
const string DL_LG_CASE_RESOLUTION_DETAIN_COMPLETE = "detain_complete";

const string DL_CR_DIAG_STATUS_DETAIN_PENDING = "detain_pending";
const string DL_CR_DIAG_STATUS_DETAIN_ACCEPTED = "detain_accepted";
const string DL_CR_DIAG_STATUS_DETAIN_REFUSED = "detain_refused";
const string DL_CR_DIAG_STATUS_CRIME_WITNESSED = "crime_witnessed";

const string DL_L_NPC_FALLBACK_DOMAIN = "dl_npc_fallback_domain";
const string DL_L_NPC_FALLBACK_REASON_CODE = "dl_npc_fallback_reason_code";
const string DL_L_NPC_FALLBACK_SEVERITY = "dl_npc_fallback_severity";
const string DL_L_NPC_FALLBACK_NEXT_ACTION = "dl_npc_fallback_next_action";
const string DL_L_NPC_FALLBACK_LAST_EVENT = "dl_npc_fallback_last_event";

const string DL_FB_DOMAIN_SOCIAL = "social";
const string DL_FB_DOMAIN_TRANSITION = "transition";
const string DL_FB_DOMAIN_CRIME = "crime";
const string DL_FB_DOMAIN_WORKER = "worker";
const string DL_FB_DOMAIN_REGISTRY = "registry";

const string DL_FB_SEVERITY_INFO = "info";
const string DL_FB_SEVERITY_WARN = "warn";
const string DL_FB_NEXT_PUBLIC = "switch_public";
const string DL_FB_NEXT_WAIT_RETRY = "wait_retry";
const string DL_FB_NEXT_RECOVER_REGISTRY = "recover_registry";
const string DL_FB_REASON_SOCIAL_ANCHOR_OR_PARTNER_MISSING = "social_anchor_or_partner_missing";
const string DL_FB_REASON_SOCIAL_PARTNER_NOT_SOCIAL = "social_partner_not_social";
const string DL_FB_REASON_SOCIAL_PARTNER_ANCHOR_MISSING = "social_partner_anchor_missing";
const string DL_FB_REASON_TRANSITION_EXIT_MISSING = "transition_exit_missing";
const string DL_FB_REASON_TRANSITION_DRIVER_MISSING = "transition_driver_missing";
const string DL_FB_REASON_TRANSITION_IN_PROGRESS = "transition_in_progress";
const string DL_FB_REASON_REGISTRY_UNREGISTER_SLOT_INVALID = "registry_unregister_slot_invalid";
const string DL_FB_REASON_CRIME_DETAIN_PENDING_WITNESSED = "crime_detain_pending_witnessed";
const string DL_FB_REASON_CRIME_DETAIN_REFUSED = "crime_detain_refused";
const string DL_FB_REASON_WORKER_REGISTRY_RECOVERY = "worker_registry_recovery";
const string DL_FB_REASON_FOCUS_MISSING_MEAL_AREA = "focus_missing_meal_area";
const string DL_FB_REASON_FOCUS_MISSING_MEAL_AND_WORK_AREA = "focus_missing_meal_and_work_area";

// Compatibility aliases for pre-cleanup telemetry names.
const string DL_L_MODULE_WORKER_TICKS = "dl_module_worker_tick_count";
const string DL_L_AREA_WORKER_LAST_PROCESSED = "dl_area_worker_last_processed_tick";
const string DL_L_MODULE_WORKER_LAST_PROCESSED = "dl_module_worker_last_processed_tick";
const string DL_L_AREA_RESYNC_LAST_PROCESSED = "dl_area_resync_last_processed_tick";
const string DL_L_MODULE_RESYNC_LAST_PROCESSED = "dl_module_resync_last_processed_tick";

string DL_GetFallbackSeverityByDomain(string sDomain)
{
    if (sDomain == DL_FB_DOMAIN_REGISTRY) return DL_FB_SEVERITY_WARN;
    return DL_FB_SEVERITY_INFO;
}

void DL_ReportFallback(object oActor, string sDomain, string sReasonCode, string sNextAction)
{
    if (!GetIsObjectValid(oActor)) return;
    string sSeverity = DL_GetFallbackSeverityByDomain(sDomain);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_DOMAIN, sDomain);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_REASON_CODE, sReasonCode);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_SEVERITY, sSeverity);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_NEXT_ACTION, sNextAction);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_LAST_EVENT, sDomain + ":" + sReasonCode + ":" + sSeverity + ":" + sNextAction);
    DL_LogChatDebugEvent(oActor, "fallback", "fallback domain=" + sDomain + " reason_code=" + sReasonCode + " severity=" + sSeverity + " next_action=" + sNextAction);
}

void DL_SetReasonAndDiagnostic(object oActor, string sDomain, string sReasonCode, string sDiagnosticLocal, string sDiagnosticCode)
{
    if (!GetIsObjectValid(oActor)) return;
    SetLocalString(oActor, DL_L_NPC_FALLBACK_DOMAIN, sDomain);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_REASON_CODE, sReasonCode);
    if (sDiagnosticLocal != "") SetLocalString(oActor, sDiagnosticLocal, sDiagnosticCode);
}

int DL_IsRuntimeEnabled()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_ENABLED) != TRUE) return FALSE;
    return GetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION) == DL_CONTRACT_VERSION_A0;
}

int DL_CanRunRuntimeForArea(object oArea)
{
    if (!DL_IsRuntimeEnabled()) return FALSE;
    if (!GetIsObjectValid(oArea)) return FALSE;
    return DL_IsAreaObject(oArea);
}

int DL_CanRunWorkerForArea(object oArea)
{
    if (!DL_CanRunRuntimeForArea(oArea)) return FALSE;
    int nTier = DL_GetAreaTier(oArea);
    return nTier == DL_RUNTIME_TIER_HOT || nTier == DL_RUNTIME_TIER_WARM;
}

int DL_CanRunWarmMaintenanceForArea(object oArea)
{
    if (!DL_CanRunRuntimeForArea(oArea)) return FALSE;
    return DL_GetAreaTier(oArea) == DL_RUNTIME_TIER_WARM;
}

int DL_CanRunResyncForArea(object oArea)
{
    if (!DL_CanRunRuntimeForArea(oArea)) return FALSE;
    return DL_GetAreaTier(oArea) == DL_RUNTIME_TIER_HOT;
}

int DL_CanRunCityResponseForArea(object oArea)
{
    if (!DL_CanRunRuntimeForArea(oArea)) return FALSE;
    if (GetLocalInt(GetModule(), "dl_city_response_enabled") != TRUE) return FALSE;
    return GetLocalInt(oArea, "dl_city_response_enabled") == TRUE;
}

int DL_CanRunTransitionForArea(object oArea)
{
    return DL_CanRunRuntimeForArea(oArea);
}

int DL_IsRuntimeLogEnabled()
{
    return GetLocalInt(GetModule(), DL_L_MODULE_RUNTIME_LOG) == TRUE;
}

void DL_LogRuntime(string sLog)
{
    if (!DL_IsRuntimeLogEnabled()) return;
}

const string DL_L_NPC_ORCH_LAST_STATE = "dl_orch_last_state";
const string DL_L_NPC_ORCH_LAST_WINDOW = "dl_orch_last_window";
const string DL_L_MODULE_RESET_POLICY = "dl_reset_policy";
const int DL_RESET_POLICY_TRANSITION_ONLY = 1;
const int DL_RESET_POLICY_LEGACY_ALWAYS = 2;
const string DL_L_NPC_LAST_RESET_TICK = "dl_npc_last_reset_tick";
const string DL_L_NPC_RESET_COUNTER_PREFIX = "dl_npc_reset_count_";
const int DL_RESET_REASON_ROUTINE = 1;
const int DL_RESET_REASON_BLOCKED = 2;
const int DL_RESET_REASON_RECOVERY = 3;
const int DL_RESET_REASON_RESYNC = 4;
const int DL_RESET_REASON_COMBAT = 5;
const int DL_RESET_REASON_TRANSITION = 6;
const string DL_L_NPC_DIRECTIVE_RESET_ALLOWED = "dl_npc_directive_reset_allowed";
const string DL_L_NPC_LAST_HARD_RESET_TICK = "dl_npc_last_hard_reset_tick";
const string DL_L_NPC_RESET_REASON_LAST = "dl_npc_reset_reason_last";
const string DL_L_NPC_RESET_REASON_DIRECTIVE_COUNT = "dl_npc_reset_reason_directive_count";
const string DL_L_NPC_RESET_REASON_RECOVERY_COUNT = "dl_npc_reset_reason_recovery_count";
const string DL_L_NPC_RESET_REASON_BLOCKED_COUNT = "dl_npc_reset_reason_blocked_count";
const string DL_L_NPC_RESET_REASON_RESYNC_COUNT = "dl_npc_reset_reason_resync_count";
const string DL_L_NPC_RESET_REASON_COMBAT_OVERRIDE_COUNT = "dl_npc_reset_reason_combat_override_count";
const int DL_ORCH_ACT_NONE = 0;
const int DL_ORCH_ACT_MOVE_OBJECT = 1;
const int DL_ORCH_ACT_MOVE_LOCATION = 2;
const int DL_ORCH_ACT_JUMP_LOCATION = 3;
const int DL_ORCH_ACT_START_CONVERSATION = 4;
const int DL_ORCH_ACT_ATTACK = 5;

void DL_CommandMoveToObject(object oActor, object oTarget, int bRun = TRUE, float fRange = 1.0);
void DL_CommandMoveToLocation(object oActor, location lTarget, int bRun = TRUE);
void DL_CommandJumpToLocation(object oActor, location lTarget);
void DL_DispatchMoveToLocation(object oActor, location lTarget, int bRun = TRUE);

int DL_ShouldRedispatchMovement(object oNpc, string sStatusLocal, string sExpectedStatus, float fDistance, float fRadius)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (fDistance <= fRadius)
    {
        return FALSE;
    }

    return GetLocalString(oNpc, sStatusLocal) != sExpectedStatus;
}

void DL_QueueMoveAction(object oNpc, location lTarget, int bRun)
{
    DL_DispatchMoveToLocation(oNpc, lTarget, bRun);
}

void DL_CommandStartConversation(object oActor, object oListener, string sDialogResRef, int bPrivateConversation = TRUE, int bPlayHello = TRUE);
void DL_CommandAttack(object oActor, object oTarget);
int DL_GetResetPolicyMode();
int DL_ShouldResetQueueNow(object oActor, int nReason, int nTickStamp);
string DL_GetResetReasonCounterKey(int nReason);
int DL_TryResetActionQueue(object oActor, int bForce = FALSE, int nReason = DL_RESET_REASON_ROUTINE);
void DL_MarkDirectiveTransitionResetAllowed(object oActor, int bAllowed = TRUE);

int DL_GetResetPolicyMode()
{
    object oModule = GetModule();
    int nMode = GetLocalInt(oModule, DL_L_MODULE_RESET_POLICY);
    if (nMode == DL_RESET_POLICY_LEGACY_ALWAYS) return DL_RESET_POLICY_LEGACY_ALWAYS;
    return DL_RESET_POLICY_TRANSITION_ONLY;
}

void DL_MarkDirectiveTransitionResetAllowed(object oActor, int bAllowed = TRUE)
{
    if (!GetIsObjectValid(oActor)) return;
    SetLocalInt(oActor, DL_L_NPC_DIRECTIVE_RESET_ALLOWED, bAllowed == TRUE ? TRUE : FALSE);
}

string DL_GetResetReasonCounterKey(int nReason)
{
    return DL_L_NPC_RESET_COUNTER_PREFIX + IntToString(nReason);
}

int DL_ShouldResetQueueNow(object oActor, int nReason, int nTickStamp)
{
    if (!GetIsObjectValid(oActor)) return FALSE;
    if (GetLocalInt(oActor, DL_L_NPC_LAST_RESET_TICK) == nTickStamp) return FALSE;

    if (nReason == DL_RESET_REASON_BLOCKED ||
        nReason == DL_RESET_REASON_RECOVERY ||
        nReason == DL_RESET_REASON_RESYNC ||
        nReason == DL_RESET_REASON_COMBAT ||
        nReason == DL_RESET_REASON_TRANSITION)
    {
        return TRUE;
    }

    if (DL_GetResetPolicyMode() != DL_RESET_POLICY_TRANSITION_ONLY)
    {
        return TRUE;
    }

    if (GetLocalInt(oActor, DL_L_NPC_DIRECTIVE_RESET_ALLOWED) != TRUE)
    {
        return FALSE;
    }

    DeleteLocalInt(oActor, DL_L_NPC_DIRECTIVE_RESET_ALLOWED);
    return TRUE;
}

int DL_TryResetActionQueue(object oActor, int bForce = FALSE, int nReason = DL_RESET_REASON_ROUTINE)
{
    if (!GetIsObjectValid(oActor)) return FALSE;
    int nTick = GetTimeMillisecond();
    int nEffectiveReason = nReason;
    if (bForce == TRUE && nReason == DL_RESET_REASON_ROUTINE) nEffectiveReason = DL_RESET_REASON_TRANSITION;

    if (!DL_ShouldResetQueueNow(oActor, nEffectiveReason, nTick)) return FALSE;

    AssignCommand(oActor, ClearAllActions(TRUE));
    SetLocalInt(oActor, DL_L_NPC_LAST_RESET_TICK, nTick);
    string sCounterKey = DL_GetResetReasonCounterKey(nEffectiveReason);
    SetLocalInt(oActor, sCounterKey, GetLocalInt(oActor, sCounterKey) + 1);
    return TRUE;
}

void DL_OnNpcActionDispatched(object oActor, string sStatusKey = "", string sStatusValue = "", string sDiagKey = "", string sDiagValue = "", string sTelemetryKey = "", int nExecutionWindow = -1, string sNoopStateKey = "", string sNoopStateValue = "")
{
    if (!GetIsObjectValid(oActor)) return;
    if (sNoopStateKey != "" && sNoopStateValue != "" && nExecutionWindow >= 0)
    {
        if (GetLocalString(oActor, sNoopStateKey) == sNoopStateValue && GetLocalInt(oActor, DL_L_NPC_ORCH_LAST_WINDOW) == nExecutionWindow && GetLocalString(oActor, DL_L_NPC_ORCH_LAST_STATE) == sNoopStateValue) return;
    }
    DL_SetRuntimeState(oActor, sStatusKey, sStatusValue, sDiagKey, sDiagValue);
    if (sTelemetryKey != "") SetLocalInt(oActor, sTelemetryKey, GetLocalInt(oActor, sTelemetryKey) + 1);
    if (nExecutionWindow >= 0)
    {
        SetLocalInt(oActor, DL_L_NPC_ORCH_LAST_WINDOW, nExecutionWindow);
        SetLocalString(oActor, DL_L_NPC_ORCH_LAST_STATE, sNoopStateValue);
    }
}

int DL_OrchestrateRuntimeAction(object oActor, int nActionKind, object oTarget, location lTarget, string sDialogResRef = "", int bResetQueue = FALSE, string sPreStatusKey = "", string sPreStatus = "", string sPreDiagKey = "", string sPreDiag = "", string sPostStatusKey = "", string sPostStatus = "", string sPostDiagKey = "", string sPostDiag = "", string sNoopStateKey = "", string sNoopStateValue = "", int nExecutionWindow = -1, int bRun = TRUE, float fRange = 1.0, int bPrivateConversation = TRUE, int bPlayHello = TRUE)
{
    if (!GetIsObjectValid(oActor)) return FALSE;
    if (sNoopStateKey != "" && sNoopStateValue != "" && nExecutionWindow >= 0)
    {
        if (GetLocalString(oActor, sNoopStateKey) == sNoopStateValue && GetLocalInt(oActor, DL_L_NPC_ORCH_LAST_WINDOW) == nExecutionWindow && GetLocalString(oActor, DL_L_NPC_ORCH_LAST_STATE) == sNoopStateValue) return FALSE;
    }
    DL_SetRuntimeState(oActor, sPreStatusKey, sPreStatus, sPreDiagKey, sPreDiag);
    if (bResetQueue) DL_TryResetActionQueue(oActor);
    if (nActionKind == DL_ORCH_ACT_NONE) {}
    else if (nActionKind == DL_ORCH_ACT_MOVE_OBJECT) DL_CommandMoveToObject(oActor, oTarget, bRun, fRange);
    else if (nActionKind == DL_ORCH_ACT_MOVE_LOCATION) DL_CommandMoveToLocation(oActor, lTarget, bRun);
    else if (nActionKind == DL_ORCH_ACT_JUMP_LOCATION) DL_CommandJumpToLocation(oActor, lTarget);
    else if (nActionKind == DL_ORCH_ACT_START_CONVERSATION) DL_CommandStartConversation(oActor, oTarget, sDialogResRef, bPrivateConversation, bPlayHello);
    else if (nActionKind == DL_ORCH_ACT_ATTACK) DL_CommandAttack(oActor, oTarget);
    else return FALSE;
    DL_OnNpcActionDispatched(oActor, sPostStatusKey, sPostStatus, sPostDiagKey, sPostDiag, "", nExecutionWindow, sNoopStateKey, sNoopStateValue);
    return TRUE;
}

void DL_CommandMoveToObject(object oActor, object oTarget, int bRun = TRUE, float fRange = 1.0) { AssignCommand(oActor, ActionMoveToObject(oTarget, bRun, fRange)); }
void DL_CommandMoveToObjectResetQueue(object oActor, object oTarget, int bRun = TRUE, float fRange = 1.0) { DL_TryResetActionQueue(oActor, TRUE, DL_RESET_REASON_RECOVERY); DL_CommandMoveToObject(oActor, oTarget, bRun, fRange); }
void DL_CommandMoveToLocation(object oActor, location lTarget, int bRun = TRUE) { AssignCommand(oActor, ActionMoveToLocation(lTarget, bRun)); }
void DL_CommandMoveToLocationResetQueue(object oActor, location lTarget, int bRun = TRUE) { DL_TryResetActionQueue(oActor, TRUE, DL_RESET_REASON_RECOVERY); DL_CommandMoveToLocation(oActor, lTarget, bRun); }
void DL_DispatchMoveToLocation(object oActor, location lTarget, int bRun = TRUE) { DL_CommandMoveToLocation(oActor, lTarget, bRun); }
void DL_CommandJumpToLocation(object oActor, location lTarget) { AssignCommand(oActor, ActionJumpToLocation(lTarget)); }
void DL_CommandJumpToLocationResetQueue(object oActor, location lTarget) { DL_TryResetActionQueue(oActor, TRUE, DL_RESET_REASON_RECOVERY); DL_CommandJumpToLocation(oActor, lTarget); }
void DL_DispatchJumpToLocation(object oActor, location lTarget) { DL_CommandJumpToLocation(oActor, lTarget); }

void DL_CommandStartConversation(object oActor, object oListener, string sDialogResRef, int bPrivateConversation = TRUE, int bPlayHello = TRUE) { AssignCommand(oActor, ActionStartConversation(oListener, sDialogResRef, bPrivateConversation, bPlayHello)); }
void DL_CommandStartConversationResetQueue(object oActor, object oListener, string sDialogResRef, int bPrivateConversation = TRUE, int bPlayHello = TRUE) { DL_TryResetActionQueue(oActor, TRUE, DL_RESET_REASON_RECOVERY); DL_CommandStartConversation(oActor, oListener, sDialogResRef, bPrivateConversation, bPlayHello); }
void DL_CommandAttack(object oActor, object oTarget) { AssignCommand(oActor, ActionAttack(oTarget)); }
void DL_CommandAttackResetQueue(object oActor, object oTarget) { DL_TryResetActionQueue(oActor, TRUE, DL_RESET_REASON_COMBAT); DL_CommandAttack(oActor, oTarget); }

void DL_InitModuleContract()
{
    object oModule = GetModule();
    int nEnabled = GetLocalInt(oModule, DL_L_MODULE_ENABLED) == TRUE ? TRUE : FALSE;
    SetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION, DL_CONTRACT_VERSION_A0);
    SetLocalInt(oModule, DL_L_MODULE_ENABLED, nEnabled);
    if (GetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ) < 0) SetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ, 0);
    if (GetLocalInt(oModule, DL_L_MODULE_CHAT_LOG_INIT) != TRUE)
    {
        SetLocalInt(oModule, DL_L_MODULE_CHAT_LOG, TRUE);
        SetLocalInt(oModule, DL_L_MODULE_CHAT_LOG_INIT, TRUE);
    }
}

int DL_IsValidDoorObject(object oObj) { return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_DOOR; }
int DL_IsValidNpcObject(object oObj) { return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_CREATURE; }
int DL_IsValidWaypointObject(object oObj) { return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT; }
int DL_IsValidAreaObject(object oObj) { return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_AREA; }
int DL_IsAreaObject(object oObject) { return DL_IsValidAreaObject(oObject); }

int DL_IsValidTransitionContext(object oNpc, object oEntryWp)
{
    return DL_IsValidNpcObject(oNpc) && DL_IsValidWaypointObject(oEntryWp);
}

int DL_IsValidNpcAreaContext(object oNpc, object oArea)
{
    return DL_IsValidNpcObject(oNpc) && DL_IsValidAreaObject(oArea);
}

int DL_IsPipelineNpc(object oNpc)
{
    if (!DL_IsValidNpcObject(oNpc)) return FALSE;
    if (GetIsPC(oNpc)) return FALSE;
    if (GetIsDM(oNpc)) return FALSE;
    return TRUE;
}

int DL_IsActivePipelineNpc(object oNpc)
{
    if (!DL_IsPipelineNpc(oNpc)) return FALSE;
    if (GetIsDead(oNpc)) return FALSE;
    return TRUE;
}

int DL_IsRuntimePlayer(object oCreature)
{
    if (!DL_IsValidNpcObject(oCreature)) return FALSE;
    return GetIsPC(oCreature) && !GetIsDM(oCreature);
}
