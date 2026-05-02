#include "dl_res_inc"

const string DL_L_MODULE_ENABLED = "dl_enabled";
const string DL_L_MODULE_CONTRACT_VERSION = "dl_contract_version";
const string DL_CONTRACT_VERSION_A0 = "a0";
const string DL_L_MODULE_CHAT_LOG = "dl_chat_log";
const string DL_L_MODULE_CHAT_LOG_INIT = "dl_chat_log_init";
const string DL_L_MODULE_RUNTIME_LOG = "dl_runtime_log";

// Focus diagnostics contract (stable machine codes + canonical human messages).

// Canonical runtime status codes.
const string DL_STATUS_MISSING_WAYPOINTS = "missing_waypoints";
const string DL_STATUS_MOVING_TO_ANCHOR = "moving_to_anchor";
const string DL_STATUS_ON_ANCHOR = "on_anchor";
const string DL_STATUS_MOVING_VIA_NAVIGATION = "moving_via_navigation";
const string DL_STATUS_ON_BED = "on_bed";
const string DL_STATUS_ON_CHILL_ANCHOR = "on_chill_anchor";
const string DL_STATUS_SITTING_CHILL_ATTEMPT = "sitting_chill_attempt";

// Canonical runtime diagnostic codes.
const string DL_DIAG_SLEEP_WAYPOINTS_MISSING = "sleep_waypoints_missing";
const string DL_DIAG_SLEEP_JUMP_INVALID_TARGET_LOCATION = "sleep_jump_invalid_target_location";
const string DL_DIAG_WORK_NEED_FORGE_AND_CRAFT_WAYPOINTS = "need_forge_and_craft_waypoints";

void DL_SetRuntimeState(object oNpc, string sStatusKey, string sStatus, string sDiagKey, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (sStatusKey != "" && GetLocalString(oNpc, sStatusKey) != sStatus)
    {
        SetLocalString(oNpc, sStatusKey, sStatus);
    }

    if (sDiagKey != "" && GetLocalString(oNpc, sDiagKey) != sDiagnostic)
    {
        SetLocalString(oNpc, sDiagKey, sDiagnostic);
    }
}
const string DL_DIAG_FOCUS_SOCIAL_PARTNER_SELF = "social_partner_self";
const string DL_DIAG_FOCUS_MISSING_MEAL_ANCHOR = "missing_meal_anchor";
const string DL_DIAG_FOCUS_MISSING_CHILL_CHAIR = "missing_chill_chair";
const string DL_DIAG_FOCUS_CHILL_CHAIR_OCCUPIED = "chill_chair_occupied";
const string DL_DIAG_FOCUS_MISSING_CHILL_SEAT = "missing_chill_seat";
const string DL_DIAG_FOCUS_MISSING_PUBLIC_ANCHOR = "missing_public_anchor";
const string DL_DIAG_FOCUS_SOCIAL_FALLBACK_TO_PUBLIC = "social_fallback_to_public";
const string DL_DIAG_FOCUS_MISSING_SOCIAL_POOL_PREFIX = "missing_social_pool_";

const string DL_MSG_FOCUS_FALLBACK_SOCIAL_PUBLIC = "fallback social->public";
const string DL_MSG_FOCUS_SOCIAL_PARTNER_LOOKUP = "social partner lookup";
const string DL_MSG_FOCUS_FALLBACK_MEAL_WORK = "fallback meal->work";
const string DL_MSG_FOCUS_FALLBACK_MEAL_HOME = "fallback meal->home";
const string DL_MSG_FOCUS_MISSING_PUBLIC_AREA = "has no public/social area for PUBLIC directive.";
const string DL_MSG_RESULT_FOUND_OUTSIDE_AREA = "found_outside_area";
const string DL_MSG_RESULT_TAG_NOT_FOUND = "tag_not_found";

// Shared City Response / Legal v1 contract locals (cross-include canonical symbols).
const string DL_L_MODULE_CR_DETAIN_DIALOG = "dl_cr_detain_dialog";
const string DL_L_MODULE_TRANSITION_DRIVER_LOOKUP_CAP = "dl_transition_driver_lookup_cap";
const string DL_L_PC_CR_DETAIN_PENDING = "dl_cr_detain_pending";
const string DL_L_PC_CR_DETAIN_PENDING_REASON = "dl_cr_detain_pending_reason";
const string DL_L_PC_CR_DETAIN_PENDING_RESOLUTION = "dl_cr_detain_pending_resolution";
const string DL_L_PC_CR_LAST_GUARD = "dl_cr_last_guard";
const string DL_L_NPC_CR_OFFENDER_UNTIL = "dl_cr_offender_until";
const string DL_L_NPC_CR_INVESTIGATE_TARGET = "dl_cr_investigate_target";
const string DL_L_NPC_CR_INVESTIGATE_UNTIL = "dl_cr_investigate_until";

// Canonical API (crime/legal detain handoff):
// - DL_CR_SetDetainPending(oPc, nUntilAbsMin, sReason)
// - DL_CR_ClearDetainPending(oPc, sResolution)
// - DL_CR_IsDetainPending(oPc)
// Do not mutate DL_L_PC_CR_DETAIN_PENDING directly outside these helpers.

const string DL_L_NPC_EVENT_KIND = "dl_npc_event_kind";
const string DL_L_NPC_EVENT_SEQ = "dl_npc_event_seq";

const string DL_L_MODULE_EVENT_SEQ = "dl_module_event_seq";
const string DL_L_MODULE_LAST_EVENT_KIND = "dl_module_last_event_kind";
const string DL_L_MODULE_LAST_EVENT_ACTOR = "dl_module_last_event_actor";
const string DL_L_MODULE_SPAWN_COUNT = "dl_module_spawn_count";
const string DL_L_MODULE_DEATH_COUNT = "dl_module_death_count";

// Runtime local key taxonomy (canonical suffix policy):
// - *_STATE: finite-state machine phase.
// - *_PENDING/*_ACTIVE: boolean runtime flags.
// - *_COUNT/*_SEQ: counters and monotonic sequence IDs.
// - *_ABS_MIN/*_TICK: time stamps in absolute minutes or area/module ticks.

// Canonical legal/crime contract values.
const string DL_LG_CASE_KIND_KILL = "kill";
const string DL_LG_CASE_KIND_ATTACK = "attack";
const string DL_LG_CASE_KIND_DOOR_LOCKPICK = "door_lockpick";
const string DL_LG_CASE_KIND_RESTRICTED_ENTRY = "restricted_entry";
const string DL_LG_CASE_KIND_CONTAINER_THEFT = "container_theft";
const string DL_LG_CASE_KIND_PICKPOCKET = "pickpocket";
const string DL_LG_CASE_KIND_PLACEABLE_LOCKPICK = "placeable_lockpick";
const string DL_LG_CASE_KIND_DETAIN_REFUSAL = "detain_refusal";

const string DL_LG_CASE_RESOLUTION_FINE = "fine";
const string DL_LG_CASE_RESOLUTION_DETAIN_COMPLETE = "detain_complete";

const string DL_CR_DIAG_STATUS_DETAIN_PENDING = "detain_pending";
const string DL_CR_DIAG_STATUS_DETAIN_ACCEPTED = "detain_accepted";
const string DL_CR_DIAG_STATUS_DETAIN_REFUSED = "detain_refused";
const string DL_CR_DIAG_STATUS_CRIME_WITNESSED = "crime_witnessed";

// Unified fallback protocol contract.
const string DL_L_NPC_FALLBACK_DOMAIN = "dl_npc_fallback_domain";
const string DL_L_NPC_FALLBACK_REASON_CODE = "dl_npc_fallback_reason_code";
const string DL_L_NPC_FALLBACK_SEVERITY = "dl_npc_fallback_severity";
const string DL_L_NPC_FALLBACK_NEXT_ACTION = "dl_npc_fallback_next_action";
const string DL_L_NPC_FALLBACK_LAST_EVENT = "dl_npc_fallback_last_event";

const string DL_FB_DOMAIN_SOCIAL = "social";
const string DL_FB_DOMAIN_TRANSITION = "transition";
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
const string DL_FB_REASON_REGISTRY_UNREGISTER_SLOT_INVALID = "registry_unregister_slot_invalid";

string DL_GetFallbackSeverityByDomain(string sDomain)
{
    if (sDomain == DL_FB_DOMAIN_REGISTRY)
    {
        return DL_FB_SEVERITY_WARN;
    }
    return DL_FB_SEVERITY_INFO;
}

void DL_ReportFallback(object oActor, string sDomain, string sReasonCode, string sNextAction)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    string sSeverity = DL_GetFallbackSeverityByDomain(sDomain);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_DOMAIN, sDomain);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_REASON_CODE, sReasonCode);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_SEVERITY, sSeverity);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_NEXT_ACTION, sNextAction);
    SetLocalString(oActor, DL_L_NPC_FALLBACK_LAST_EVENT, sDomain + ":" + sReasonCode + ":" + sSeverity + ":" + sNextAction);

    DL_LogChatDebugEvent(
        oActor,
        "fallback",
        "fallback domain=" + sDomain + " reason_code=" + sReasonCode + " severity=" + sSeverity + " next_action=" + sNextAction
    );
}

int DL_IsRuntimeEnabled()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_ENABLED) != TRUE)
    {
        return FALSE;
    }

    return GetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION) == DL_CONTRACT_VERSION_A0;
}

int DL_IsRuntimeLogEnabled()
{
    return GetLocalInt(GetModule(), DL_L_MODULE_RUNTIME_LOG) == TRUE;
}

void DL_LogRuntime(string sLog)
{
    if (!DL_IsRuntimeLogEnabled())
    {
        return;
    }

    // Temporary: global runtime logging is disabled.
}


const string DL_L_NPC_ORCH_LAST_STATE = "dl_orch_last_state";
const string DL_L_NPC_ORCH_LAST_WINDOW = "dl_orch_last_window";

const int DL_ORCH_ACT_NONE = 0;
const int DL_ORCH_ACT_MOVE_OBJECT = 1;
const int DL_ORCH_ACT_MOVE_LOCATION = 2;
const int DL_ORCH_ACT_JUMP_LOCATION = 3;
const int DL_ORCH_ACT_START_CONVERSATION = 4;
const int DL_ORCH_ACT_ATTACK = 5;


void DL_OnNpcActionDispatched(
    object oActor,
    string sStatusKey = "",
    string sStatusValue = "",
    string sDiagKey = "",
    string sDiagValue = "",
    string sTelemetryKey = "",
    int nExecutionWindow = -1,
    string sNoopStateKey = "",
    string sNoopStateValue = ""
)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    if (sNoopStateKey != "" && sNoopStateValue != "" && nExecutionWindow >= 0)
    {
        if (GetLocalString(oActor, sNoopStateKey) == sNoopStateValue &&
            GetLocalInt(oActor, DL_L_NPC_ORCH_LAST_WINDOW) == nExecutionWindow &&
            GetLocalString(oActor, DL_L_NPC_ORCH_LAST_STATE) == sNoopStateValue)
        {
            return;
        }
    }

    DL_SetRuntimeState(oActor, sStatusKey, sStatusValue, sDiagKey, sDiagValue);
    if (sTelemetryKey != "")
    {
        SetLocalInt(oActor, sTelemetryKey, GetLocalInt(oActor, sTelemetryKey) + 1);
    }

    if (nExecutionWindow >= 0)
    {
        SetLocalInt(oActor, DL_L_NPC_ORCH_LAST_WINDOW, nExecutionWindow);
        SetLocalString(oActor, DL_L_NPC_ORCH_LAST_STATE, sNoopStateValue);
    }
}

int DL_OrchestrateRuntimeAction(
    object oActor,
    int nActionKind,
    object oTarget = OBJECT_INVALID,
    location lTarget = LOCATION_INVALID,
    string sDialogResRef = "",
    int bResetQueue = TRUE,
    string sPreStatusKey = "",
    string sPreStatus = "",
    string sPreDiagKey = "",
    string sPreDiag = "",
    string sPostStatusKey = "",
    string sPostStatus = "",
    string sPostDiagKey = "",
    string sPostDiag = "",
    string sNoopStateKey = "",
    string sNoopStateValue = "",
    int nExecutionWindow = -1,
    int bRun = TRUE,
    float fRange = 1.0,
    int bPrivateConversation = TRUE,
    int bPlayHello = TRUE
)
{
    if (!GetIsObjectValid(oActor))
    {
        return FALSE;
    }

    if (sNoopStateKey != "" && sNoopStateValue != "" && nExecutionWindow >= 0)
    {
        if (GetLocalString(oActor, sNoopStateKey) == sNoopStateValue &&
            GetLocalInt(oActor, DL_L_NPC_ORCH_LAST_WINDOW) == nExecutionWindow &&
            GetLocalString(oActor, DL_L_NPC_ORCH_LAST_STATE) == sNoopStateValue)
        {
            return FALSE;
        }
    }

    DL_SetRuntimeState(oActor, sPreStatusKey, sPreStatus, sPreDiagKey, sPreDiag);
    if (bResetQueue)
    {
        AssignCommand(oActor, ClearAllActions(TRUE));
    }

    if (nActionKind == DL_ORCH_ACT_NONE)
    {
        // queue/state orchestration only
    }
    else if (nActionKind == DL_ORCH_ACT_MOVE_OBJECT)
    {
        DL_CommandMoveToObject(oActor, oTarget, bRun, fRange);
    }
    else if (nActionKind == DL_ORCH_ACT_MOVE_LOCATION)
    {
        DL_CommandMoveToLocation(oActor, lTarget, bRun);
    }
    else if (nActionKind == DL_ORCH_ACT_JUMP_LOCATION)
    {
        DL_CommandJumpToLocation(oActor, lTarget);
    }
    else if (nActionKind == DL_ORCH_ACT_START_CONVERSATION)
    {
        DL_CommandStartConversation(oActor, oTarget, sDialogResRef, bPrivateConversation, bPlayHello);
    }
    else if (nActionKind == DL_ORCH_ACT_ATTACK)
    {
        DL_CommandAttack(oActor, oTarget);
    }
    else
    {
        return FALSE;
    }

    DL_OnNpcActionDispatched(
        oActor,
        sPostStatusKey,
        sPostStatus,
        sPostDiagKey,
        sPostDiag,
        "",
        nExecutionWindow,
        sNoopStateKey,
        sNoopStateValue
    );

    return TRUE;
}
void DL_CommandMoveToObject(object oActor, object oTarget, int bRun = TRUE, float fRange = 1.0)
{
    AssignCommand(oActor, ActionMoveToObject(oTarget, bRun, fRange));
}

void DL_CommandMoveToObjectResetQueue(object oActor, object oTarget, int bRun = TRUE, float fRange = 1.0)
{
    AssignCommand(oActor, ClearAllActions(TRUE));
    DL_CommandMoveToObject(oActor, oTarget, bRun, fRange);
}

void DL_CommandMoveToLocation(object oActor, location lTarget, int bRun = TRUE)
{
    AssignCommand(oActor, ActionMoveToLocation(lTarget, bRun));
}

void DL_CommandMoveToLocationResetQueue(object oActor, location lTarget, int bRun = TRUE)
{
    AssignCommand(oActor, ClearAllActions(TRUE));
    DL_CommandMoveToLocation(oActor, lTarget, bRun);
}

void DL_CommandJumpToLocation(object oActor, location lTarget)
{
    AssignCommand(oActor, ActionJumpToLocation(lTarget));
}

void DL_CommandJumpToLocationResetQueue(object oActor, location lTarget)
{
    AssignCommand(oActor, ClearAllActions(TRUE));
    DL_CommandJumpToLocation(oActor, lTarget);
}

void DL_CommandStartConversation(object oActor, object oListener, string sDialogResRef, int bPrivateConversation = TRUE, int bPlayHello = TRUE)
{
    AssignCommand(oActor, ActionStartConversation(oListener, sDialogResRef, bPrivateConversation, bPlayHello));
}

void DL_CommandStartConversationResetQueue(object oActor, object oListener, string sDialogResRef, int bPrivateConversation = TRUE, int bPlayHello = TRUE)
{
    AssignCommand(oActor, ClearAllActions(TRUE));
    DL_CommandStartConversation(oActor, oListener, sDialogResRef, bPrivateConversation, bPlayHello);
}

void DL_CommandAttack(object oActor, object oTarget)
{
    AssignCommand(oActor, ActionAttack(oTarget));
}

void DL_CommandAttackResetQueue(object oActor, object oTarget)
{
    AssignCommand(oActor, ClearAllActions(TRUE));
    DL_CommandAttack(oActor, oTarget);
}

void DL_InitModuleContract()
{
    object oModule = GetModule();
    int nEnabled = GetLocalInt(oModule, DL_L_MODULE_ENABLED) == TRUE ? TRUE : FALSE;

    SetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION, DL_CONTRACT_VERSION_A0);
    SetLocalInt(oModule, DL_L_MODULE_ENABLED, nEnabled);

    if (GetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ) < 0)
    {
        SetLocalInt(oModule, DL_L_MODULE_EVENT_SEQ, 0);
    }

    if (GetLocalInt(oModule, DL_L_MODULE_CHAT_LOG_INIT) != TRUE)
    {
        SetLocalInt(oModule, DL_L_MODULE_CHAT_LOG, TRUE);
        SetLocalInt(oModule, DL_L_MODULE_CHAT_LOG_INIT, TRUE);
    }
}


// Canonical object validators for Daily Life modules.
// NWScript object handles are typeless at compile time, so callers MUST validate
// both handle validity (OBJECT_INVALID guard via GetIsObjectValid) and expected
// runtime type before using type-specific APIs.
int DL_IsValidDoorObject(object oObj)
{
    return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_DOOR;
}

int DL_IsValidNpcObject(object oObj)
{
    return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_CREATURE;
}

int DL_IsValidWaypointObject(object oObj)
{
    return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_WAYPOINT;
}

int DL_IsValidAreaObject(object oObj)
{
    return GetIsObjectValid(oObj) && GetObjectType(oObj) == OBJECT_TYPE_AREA;
}

int DL_IsAreaObject(object oObject)
{
    return DL_IsValidAreaObject(oObject);
}

int DL_IsPipelineNpc(object oNpc)
{
    if (!DL_IsValidNpcObject(oNpc))
    {
        return FALSE;
    }

    if (GetIsPC(oNpc))
    {
        return FALSE;
    }

    if (GetIsDM(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}

int DL_IsActivePipelineNpc(object oNpc)
{
    if (!DL_IsPipelineNpc(oNpc))
    {
        return FALSE;
    }

    if (GetIsDead(oNpc))
    {
        return FALSE;
    }

    return TRUE;
}

int DL_IsRuntimePlayer(object oCreature)
{
    if (!DL_IsValidNpcObject(oCreature))
    {
        return FALSE;
    }

    return GetIsPC(oCreature) && !GetIsDM(oCreature);
}
