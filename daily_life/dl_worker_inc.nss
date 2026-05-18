const string DL_L_MODULE_WORKER_SEQ = "dl_module_worker_seq";
const string DL_L_MODULE_WORKER_TICKS = "dl_module_worker_ticks";
const string DL_L_MODULE_WORKER_LAST_PROCESSED = "dl_module_worker_last_processed";
const string DL_L_MODULE_RESYNC_LAST_PROCESSED = "dl_module_resync_last_processed";
const string DL_L_AREA_WORKER_LAST_PROCESSED = "dl_area_worker_last_processed";
const string DL_L_AREA_RESYNC_LAST_PROCESSED = "dl_area_resync_last_processed";
const string DL_L_NPC_LAST_TOUCH_TICK = "dl_npc_last_touch_tick";
const string DL_L_AREA_WORKER_TICK_AREA_DBG = "area_worker_tick_area";
const string DL_L_AREA_WORKER_TICK_SEQ_DBG = "area_worker_tick_seq";
const string DL_L_NPC_WORKER_TOUCH_SEQ_DBG = "npc_worker_touch_seq";
const string DL_L_NPC_LAST_WORKER_TOUCH_HOUR_DBG = "npc_last_worker_touch_hour";
const string DL_L_NPC_LAST_WORKER_TOUCH_MINUTE_DBG = "npc_last_worker_touch_minute";
const string DL_L_NPC_LAST_WORKER_TOUCH_ABS_MIN_DBG = "npc_last_worker_touch_abs_minute";
const string DL_L_NPC_PROCESSED_BY_RR_DBG = "npc_processed_by_round_robin";
const string DL_L_NPC_REGISTRY_SLOT_DBG = "npc_registry_slot";
const string DL_L_NPC_REGISTRY_COUNT_DBG = "npc_registry_count";
const string DL_L_NPC_SLOT_CONTAINS_SELF_DBG = "npc_slot_contains_self";
const string DL_L_AREA_WORKER_PASS_MODE_DBG = "area_worker_pass_mode";
const string DL_L_AREA_WORKER_BUDGET_DBG = "area_worker_budget";
const string DL_L_AREA_WORKER_CURSOR_BEFORE_DBG = "area_worker_cursor_before";
const string DL_L_AREA_WORKER_CURSOR_AFTER_DBG = "area_worker_cursor_after";
const string DL_L_NPC_SEEN_BY_RR_DBG = "npc_seen_by_round_robin";
const string DL_L_NPC_TOUCH_SKIPPED_REASON_DBG = "npc_touch_skipped_reason";
const string DL_L_NPC_WORKER_TOUCH_SEQ_BEFORE_DBG = "npc_worker_touch_seq_before";
const string DL_L_NPC_WORKER_TOUCH_SEQ_AFTER_DBG = "npc_worker_touch_seq_after";
const string DL_L_AREA_CACHED_PLAYER_COUNT_DBG = "area_cached_player_count";
const string DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG = "area_actual_player_count";
const string DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG = "area_tier_before_lifecycle";
const string DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG = "area_tier_after_lifecycle";
const string DL_L_AREA_HOTNESS_REPAIRED_DBG = "area_hotness_repaired";
const string DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG = "area_worker_forced_hot_due_to_player";
const string DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG = "area_player_count_stale_repaired";
const string DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG = "area_hotness_bug_player_present";
const string DL_L_NPC_CRITICAL_WORKER_TOUCH_DBG = "critical_worker_touch";
const string DL_L_NPC_CRITICAL_REASON_DBG = "critical_reason";
const string DL_L_NPC_CRITICAL_BYPASSED_LAST_TOUCH_DBG = "critical_bypassed_last_touch_gate";
const string DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG = "critical_bypassed_warm_gate";
const string DL_L_NPC_CRITICAL_SEEN_NOT_TOUCHED_DBG = "critical_seen_but_not_touched";
const string DL_L_NPC_CRITICAL_PROCESS_FAILED_REASON_DBG = "critical_process_failed_reason";
const string DL_L_NPC_CRITICAL_SLOT_DBG = "critical_slot";
const string DL_L_NPC_CRITICAL_AREA_DBG = "critical_area";
const string DL_L_NPC_CRITICAL_REGISTRY_COUNT_DBG = "critical_registry_count";
const string DL_L_NPC_CRITICAL_PASS_MODE_DBG = "critical_pass_mode";
const string DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG = "emergency_worker_touch_for_stale_reached";

const int DL_AREA_PASS_MODE_WORKER = 1;
const int DL_AREA_PASS_MODE_RESYNC = 2;
const int DL_AREA_PASS_MODE_WARM = 3;
const string DL_L_AREA_PASS_LAST_CANDIDATES = "dl_area_pass_last_candidates";
const string DL_L_AREA_PASS_FALLBACK_COUNT = "dl_area_pass_fallback_count";
const string DL_L_MODULE_PASS_FALLBACK_COUNT = "dl_module_pass_fallback_count";
const string DL_L_AREA_PASS_FALLBACK_LAST_TICK = "dl_area_pass_fallback_last_tick";
const string DL_L_AREA_REGISTRY_REBUILD_PENDING = "dl_area_registry_rebuild_pending";
const string DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR = "dl_area_registry_rebuild_obj_cursor";
const string DL_L_AREA_REGISTRY_REPAIR_CURSOR = "dl_area_registry_repair_cursor";
const string DL_L_AREA_TRANSITION_HANDOFF_SLOT_PREFIX = "dl_area_transition_handoff_slot_";
const string DL_L_AREA_TRANSITION_HANDOFF_CURSOR = "dl_area_transition_handoff_cursor";

const int DL_FALLBACK_OBJECT_HOP_MULTIPLIER = 8;
const int DL_TRANSITION_HANDOFF_SLOT_COUNT = 4;

void DL_WorkerTouchNpc(object oNpc);
int DL_TouchNpcFromAreaWorker(object oNpc, object oArea, int nPassMode, int nTickStamp, int nBudget, int nCursorBefore, int nCursorAfter);
void DL_SetNpcRegularWorkerDebug(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter, int bSeenByRoundRobin, int bProcessedByRoundRobin, string sSkipReason);
int DL_ProcessAreaNpcByPassMode(object oArea, object oNpc, int nPassMode, int nTickStamp, int nBudget, int nCursorBefore, int nCursorAfter);
int DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(object oArea, object oNpc, int nSlot);
int DL_IsNpcRegistryOwnerForArea(object oNpc, object oArea);

int DL_GetCursorAdvance(int nNpcProcessed, int nCandidatesSeen, int nNpcSeen)
{
    int nAdvance = nNpcProcessed;
    if (nAdvance <= 0)
    {
        // If pass-mode dedupe skipped processing, advance by scanned window size.
        nAdvance = nCandidatesSeen;
    }
    if (nAdvance <= 0)
    {
        // Final safety net to guarantee forward progress.
        nAdvance = 1;
    }

    if (nNpcSeen > 0)
    {
        // Round-robin pass is bounded by registry count; clamp keeps contract explicit.
        nAdvance = DL_ClampInt(nAdvance, 1, nNpcSeen);
    }

    return nAdvance;
}

void DL_MarkAreaRegistryRebuildPending(object oArea)
{
    SetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING, TRUE);
}

void DL_ClearAreaRegistryRebuildPending(object oArea)
{
    DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING);
    DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR);
    DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
}

string DL_GetAreaTransitionHandoffSlotKey(int nSlot)
{
    if (nSlot < 0)
    {
        nSlot = 0;
    }
    return DL_L_AREA_TRANSITION_HANDOFF_SLOT_PREFIX + IntToString(nSlot);
}

void DL_SetTransitionRegistryHandoffDebug(object oNpc, object oOldArea, object oTargetArea)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    object oNpcArea = GetArea(oNpc);
    string sOldArea = "";
    string sTargetArea = "";
    string sRegisteredArea = "";
    string sNpcArea = "";

    if (GetIsObjectValid(oOldArea))
    {
        sOldArea = GetTag(oOldArea);
    }
    else
    {
        sOldArea = GetLocalString(oNpc, "dl_transition_registry_old_area");
    }
    if (GetIsObjectValid(oTargetArea))
    {
        sTargetArea = GetTag(oTargetArea);
    }
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredArea = GetTag(oRegisteredArea);
    }
    if (GetIsObjectValid(oNpcArea))
    {
        sNpcArea = GetTag(oNpcArea);
    }

    SetLocalString(oNpc, "dl_transition_registry_handoff", "transition_registry_handoff");
    SetLocalString(oNpc, "dl_transition_registry_old_area", sOldArea);
    SetLocalString(oNpc, "dl_transition_registry_target_area", sTargetArea);
    SetLocalString(oNpc, "dl_transition_registry_registered_area", sRegisteredArea);
    SetLocalString(oNpc, "dl_transition_registry_npc_area", sNpcArea);
    SetLocalString(oNpc, "dl_transition_registry_npc_tag", GetTag(oNpc));
    SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredArea);
    SetLocalString(oNpc, "dl_transition_registry_current_physical_area", sNpcArea);
    SetLocalString(oNpc, "dl_transition_registry_registry_area_before_repair", GetLocalString(oNpc, "dl_registry_area_before_repair"));
    SetLocalString(oNpc, "dl_transition_registry_registry_area_after_repair", GetLocalString(oNpc, "dl_registry_area_after_repair"));
    SetLocalString(oNpc, "dl_transition_registry_worker_touch_area", GetLocalString(oNpc, "dl_worker_touch_area"));
    SetLocalInt(oNpc, "dl_transition_registry_repair_current_tick", GetLocalInt(oNpc, "dl_registry_repair_current_tick"));
    SetLocalInt(oNpc, "dl_transition_registry_repair_owner_changed", GetLocalInt(oNpc, "dl_registry_repair_owner_changed"));
    SetLocalInt(oNpc, "dl_transition_registry_reg_on", GetLocalInt(oNpc, DL_L_NPC_REG_ON));
    SetLocalInt(oNpc, "dl_transition_registry_reg_slot", GetLocalInt(oNpc, DL_L_NPC_REG_SLOT));
    SetLocalInt(oNpc, "dl_transition_registry_rebuild_pending", GetLocalInt(oTargetArea, DL_L_AREA_REGISTRY_REBUILD_PENDING));
    SetLocalInt(oNpc, "dl_transition_registry_resync_pending", GetLocalInt(oTargetArea, DL_L_AREA_ENTER_RESYNC_PENDING));
    if (GetLocalInt(oTargetArea, DL_L_AREA_REGISTRY_REBUILD_PENDING) == TRUE &&
        GetLocalString(oNpc, "dl_transition_registry_worker_tick_area") != sTargetArea)
    {
        SetLocalString(oNpc, "dl_transition_registry_problem", "target_area_worker_not_ticking_or_not_owning_npc");
    }
    else if (GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc")
    {
        DeleteLocalString(oNpc, "dl_transition_registry_problem");
    }
}

void DL_QueueTransitionRegistryHandoff(object oTargetArea, object oNpc)
{
    if (!DL_IsAreaObject(oTargetArea) || !GetIsObjectValid(oNpc))
    {
        return;
    }

    int nSlot = -1;
    int i = 0;
    while (i < DL_TRANSITION_HANDOFF_SLOT_COUNT)
    {
        object oQueued = GetLocalObject(oTargetArea, DL_GetAreaTransitionHandoffSlotKey(i));
        if (oQueued == oNpc)
        {
            nSlot = i;
            i = DL_TRANSITION_HANDOFF_SLOT_COUNT;
        }
        else if (nSlot < 0 && !GetIsObjectValid(oQueued))
        {
            nSlot = i;
        }
        i = i + 1;
    }

    if (nSlot < 0)
    {
        nSlot = GetLocalInt(oTargetArea, DL_L_AREA_TRANSITION_HANDOFF_CURSOR);
        if (nSlot < 0 || nSlot >= DL_TRANSITION_HANDOFF_SLOT_COUNT)
        {
            nSlot = 0;
        }
        SetLocalInt(oTargetArea, DL_L_AREA_TRANSITION_HANDOFF_CURSOR, (nSlot + 1) % DL_TRANSITION_HANDOFF_SLOT_COUNT);
    }

    SetLocalObject(oTargetArea, DL_GetAreaTransitionHandoffSlotKey(nSlot), oNpc);
}

void DL_RequestTransitionRegistryHandoff(object oNpc, object oOldArea, object oTargetArea)
{
    if (!GetIsObjectValid(oNpc) || !DL_IsAreaObject(oTargetArea))
    {
        return;
    }

    DL_MarkAreaRegistryRebuildPending(oTargetArea);
    DL_QueueTransitionRegistryHandoff(oTargetArea, oNpc);

    DL_EnsureAreaPlayerCountSeeded(oTargetArea);
    if (DL_GetAreaTier(oTargetArea) == DL_TIER_HOT || DL_GetAreaPlayerCount(oTargetArea) > 0)
    {
        DL_TransitionAreaToHot(oTargetArea, TRUE);
    }

    DL_SetTransitionRegistryHandoffDebug(oNpc, oOldArea, oTargetArea);
}

void DL_RepairAreaRegistrySlot(object oArea, int nSlot, int nCount)
{
    int nLastSlot = nCount - 1;
    object oTailNpc = OBJECT_INVALID;
    if (nSlot != nLastSlot)
    {
        oTailNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nLastSlot);
    }

    DL_DeleteAreaRegistrySlot(oArea, nLastSlot);

    if (nSlot != nLastSlot)
    {
        DL_SetAreaRegistryNpcAtSlot(oArea, nSlot, oTailNpc);
        if (GetIsObjectValid(oTailNpc))
        {
            SetLocalInt(oTailNpc, DL_L_NPC_REG_SLOT, nSlot);
            SetLocalObject(oTailNpc, DL_L_NPC_REG_AREA, oArea);
        }
    }

    SetLocalInt(oArea, DL_L_AREA_REG_COUNT, nLastSlot);
    SetLocalInt(oArea, DL_L_AREA_REG_SEQ, GetLocalInt(oArea, DL_L_AREA_REG_SEQ) + 1);
}

string DL_GetAreaWorkerPassModeDebugLabel(int nPassMode)
{
    if (nPassMode == DL_AREA_PASS_MODE_WORKER) return "worker";
    if (nPassMode == DL_AREA_PASS_MODE_RESYNC) return "resync";
    if (nPassMode == DL_AREA_PASS_MODE_WARM) return "warm";
    return "unknown";
}

string DL_GetAreaTierDebugLabel(int nTier)
{
    if (nTier == DL_TIER_HOT) return "HOT";
    if (nTier == DL_TIER_WARM) return "WARM";
    if (nTier == DL_TIER_FROZEN) return "FROZEN";
    return "UNKNOWN";
}

void DL_SetAreaHotnessDebug(
    object oArea,
    int nCachedPlayers,
    int nActualPlayers,
    int nTierBefore,
    int nTierAfter,
    int bHotnessRepaired,
    int bForcedHotDueToPlayer,
    int bStaleRepaired
)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oArea, DL_L_AREA_CACHED_PLAYER_COUNT_DBG, nCachedPlayers);
    SetLocalInt(oArea, DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG, nActualPlayers);
    SetLocalString(oArea, DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG, DL_GetAreaTierDebugLabel(nTierBefore));
    SetLocalString(oArea, DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG, DL_GetAreaTierDebugLabel(nTierAfter));
    SetLocalInt(oArea, DL_L_AREA_HOTNESS_REPAIRED_DBG, bHotnessRepaired);
    SetLocalInt(oArea, DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG, bForcedHotDueToPlayer);
    SetLocalInt(oArea, DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG, bStaleRepaired);
}

void DL_CopyAreaHotnessDebugToNpc(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_AREA_CACHED_PLAYER_COUNT_DBG, GetLocalInt(oArea, DL_L_AREA_CACHED_PLAYER_COUNT_DBG));
    SetLocalInt(oNpc, DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG, GetLocalInt(oArea, DL_L_AREA_ACTUAL_PLAYER_COUNT_DBG));
    SetLocalString(oNpc, DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG, GetLocalString(oArea, DL_L_AREA_TIER_BEFORE_LIFECYCLE_DBG));
    SetLocalString(oNpc, DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG, GetLocalString(oArea, DL_L_AREA_TIER_AFTER_LIFECYCLE_DBG));
    SetLocalInt(oNpc, DL_L_AREA_HOTNESS_REPAIRED_DBG, GetLocalInt(oArea, DL_L_AREA_HOTNESS_REPAIRED_DBG));
    SetLocalInt(oNpc, DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG, GetLocalInt(oArea, DL_L_AREA_WORKER_FORCED_HOT_PLAYER_DBG));
    SetLocalInt(oNpc, DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG, GetLocalInt(oArea, DL_L_AREA_PLAYER_COUNT_STALE_REPAIRED_DBG));
    SetLocalInt(oNpc, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG, GetLocalInt(oArea, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG));
}

void DL_ClearCriticalWorkerDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_WORKER_TOUCH_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_REASON_DBG);
}

void DL_SetCriticalWorkerDebug(object oNpc, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_WORKER_TOUCH_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_CRITICAL_REASON_DBG, sReason);
}

void DL_SetCriticalProcessFailedDebug(object oNpc, object oArea, int nSlot, int nCount, int nPassMode, string sReason)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_SEEN_NOT_TOUCHED_DBG, TRUE);
    SetLocalString(oNpc, DL_L_NPC_CRITICAL_PROCESS_FAILED_REASON_DBG, sReason);
    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_SLOT_DBG, nSlot);
    if (GetIsObjectValid(oArea))
    {
        SetLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG, GetTag(oArea));
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG, "");
    }
    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_REGISTRY_COUNT_DBG, nCount);
    SetLocalString(oNpc, DL_L_NPC_CRITICAL_PASS_MODE_DBG, DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    DL_BsmithTraceStage(
        oNpc,
        "WORKER_SKIP",
        "reason=critical_seen_but_not_touched critical_process_failed_reason=" + sReason +
            " critical_slot=" + IntToString(nSlot) +
            " critical_area=" + GetLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG) +
            " critical_registry_count=" + IntToString(nCount) +
            " critical_pass_mode=" + DL_GetAreaWorkerPassModeDebugLabel(nPassMode)
    );
}

void DL_ClearCriticalProcessFailedDebug(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_SEEN_NOT_TOUCHED_DBG, FALSE);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_PROCESS_FAILED_REASON_DBG);
    DeleteLocalInt(oNpc, DL_L_NPC_CRITICAL_SLOT_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_AREA_DBG);
    DeleteLocalInt(oNpc, DL_L_NPC_CRITICAL_REGISTRY_COUNT_DBG);
    DeleteLocalString(oNpc, DL_L_NPC_CRITICAL_PASS_MODE_DBG);
}

int DL_IsRegisteredCurrentAreaStaleReachedMoveCritical(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    if (!DL_HasMoveJob(oNpc))
    {
        return FALSE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) != DL_MOVE_RESULT_RUNNING)
    {
        return FALSE;
    }

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) == ACTION_MOVETOPOINT)
    {
        return FALSE;
    }

    if (GetArea(oNpc) != oArea)
    {
        return FALSE;
    }

    if (GetLocalObject(oNpc, DL_L_NPC_REG_AREA) != oArea)
    {
        return FALSE;
    }

    return TRUE;
}

int DL_EmergencyTouchCriticalStaleReachedNpc(object oNpc, object oArea, int nPassMode, int nTickStamp, int nSlot, int nCount, string sReason)
{
    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return FALSE;
    }

    if (!DL_IsRegisteredCurrentAreaStaleReachedMoveCritical(oNpc, oArea))
    {
        return FALSE;
    }

    if (nSlot < 0 || nSlot >= nCount)
    {
        return FALSE;
    }

    if (DL_GetAreaRegistryNpcAtSlot(oArea, nSlot) != oNpc)
    {
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG, TRUE);
    DL_SetCriticalProcessFailedDebug(oNpc, oArea, nSlot, nCount, nPassMode, sReason);
    DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, DL_WORKER_BUDGET_MIN, nSlot, nSlot, TRUE, FALSE, sReason);
    DL_BsmithTraceStage(oNpc, "WORKER_TOUCH_ENTER", "emergency_worker_touch_for_stale_reached");
    DL_WorkerTouchNpc(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
    DL_BsmithTraceStage(oNpc, "WORKER_TOUCH_EXIT", "emergency_worker_touch_for_stale_reached");
    return TRUE;
}

void DL_SetAreaWorkerPassDebug(object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursorBefore, int nCursorAfter)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalString(oArea, DL_L_AREA_WORKER_TICK_AREA_DBG, GetTag(oArea));
    SetLocalInt(oArea, DL_L_AREA_WORKER_TICK_SEQ_DBG, nTickStamp);
    SetLocalString(oArea, DL_L_AREA_WORKER_PASS_MODE_DBG, DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    SetLocalInt(oArea, DL_L_AREA_WORKER_BUDGET_DBG, nBudget);
    SetLocalInt(oArea, DL_L_AREA_WORKER_CURSOR_BEFORE_DBG, nCursorBefore);
    SetLocalInt(oArea, DL_L_AREA_WORKER_CURSOR_AFTER_DBG, nCursorAfter);
}

void DL_SetNpcRegularWorkerDebug(
    object oNpc,
    object oArea,
    int nTickStamp,
    int nPassMode,
    int nBudget,
    int nCursorBefore,
    int nCursorAfter,
    int bSeenByRoundRobin,
    int bProcessedByRoundRobin,
    string sSkipReason
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return;
    }

    if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
    {
        DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nCursorBefore);
        return;
    }

    int nSlot = GetLocalInt(oNpc, DL_L_NPC_REG_SLOT);
    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    int bSlotContainsSelf = FALSE;
    if (nSlot >= 0 && nSlot < nCount)
    {
        bSlotContainsSelf = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot) == oNpc;
    }

    SetLocalString(oNpc, DL_L_AREA_WORKER_TICK_AREA_DBG, GetTag(oArea));
    SetLocalInt(oNpc, DL_L_AREA_WORKER_TICK_SEQ_DBG, nTickStamp);
    SetLocalString(oNpc, DL_L_AREA_WORKER_PASS_MODE_DBG, DL_GetAreaWorkerPassModeDebugLabel(nPassMode));
    SetLocalInt(oNpc, DL_L_AREA_WORKER_BUDGET_DBG, nBudget);
    SetLocalInt(oNpc, DL_L_AREA_WORKER_CURSOR_BEFORE_DBG, nCursorBefore);
    SetLocalInt(oNpc, DL_L_AREA_WORKER_CURSOR_AFTER_DBG, nCursorAfter);
    SetLocalInt(oNpc, DL_L_NPC_SEEN_BY_RR_DBG, bSeenByRoundRobin);
    SetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG, bProcessedByRoundRobin);
    SetLocalInt(oNpc, DL_L_NPC_REGISTRY_SLOT_DBG, nSlot);
    SetLocalInt(oNpc, DL_L_NPC_REGISTRY_COUNT_DBG, nCount);
    SetLocalInt(oNpc, DL_L_NPC_SLOT_CONTAINS_SELF_DBG, bSlotContainsSelf);
    DL_CopyAreaHotnessDebugToNpc(oNpc, oArea);
    if (sSkipReason == "")
    {
        DeleteLocalString(oNpc, DL_L_NPC_TOUCH_SKIPPED_REASON_DBG);
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_TOUCH_SKIPPED_REASON_DBG, sSkipReason);
        DL_BsmithTraceStage(oNpc, "WORKER_SKIP", "reason=" + sSkipReason);
    }
}

int DL_IsStaleReachedMoveJobCritical(object oNpc)
{
    if (!DL_HasMoveJob(oNpc))
    {
        return FALSE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_MOVE_RESULT) != DL_MOVE_RESULT_RUNNING)
    {
        return FALSE;
    }

    if (!DL_IsMoveJobAtTargetNow(oNpc))
    {
        return FALSE;
    }

    if (GetCurrentAction(oNpc) != ACTION_MOVETOPOINT)
    {
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "moving_to_anchor" &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == GetLocalString(oNpc, DL_L_NPC_MOVE_TARGET_TAG))
    {
        return TRUE;
    }

    return FALSE;
}

int DL_NpcNeedsCriticalWorkerTouch(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    DL_ClearCriticalWorkerDebug(oNpc);

    int nStoredDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    int nResolvedDirective = DL_ResolveEffectiveDirective(oNpc, DL_ResolveNpcDirective(oNpc));
    if (nStoredDirective != nResolvedDirective)
    {
        DL_SetCriticalWorkerDebug(oNpc, "directive_changed");
        return TRUE;
    }

    if (DL_HasMoveJob(oNpc))
    {
        if (!DL_IsMoveJobOwnerCompatibleWithDirective(oNpc, nResolvedDirective))
        {
            DL_SetCriticalWorkerDebug(oNpc, "move_owner_directive_mismatch");
            return TRUE;
        }

        if (DL_IsStaleReachedMoveJobCritical(oNpc))
        {
            DL_SetCriticalWorkerDebug(oNpc, "stale_reached_move_job");
            DL_BsmithTraceStage(oNpc, "CRITICAL_WORKER", "stale_reached_move_job");
            return TRUE;
        }
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "moving_to_anchor" && DL_IsMoveJobAtTargetNow(oNpc))
    {
        DL_SetCriticalWorkerDebug(oNpc, "focus_anchor_reached");
        return TRUE;
    }

    if (GetLocalString(oNpc, "dl_post_jump_result") == "post_jump_finalizer_complete" &&
        (GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) != "" ||
            GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) != "" ||
            GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC) != ""))
    {
        DL_SetCriticalWorkerDebug(oNpc, "stale_transition_after_post_jump");
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC) == "regular_worker_not_touching_registered_npc")
    {
        DL_SetCriticalWorkerDebug(oNpc, "regular_worker_not_touching_registered_npc");
        return TRUE;
    }

    if (DL_GetNpcProblemSummary(oNpc) == "regular_worker_not_touching_registered_npc")
    {
        DL_SetCriticalWorkerDebug(oNpc, "regular_worker_not_touching_registered_npc");
        return TRUE;
    }

    return FALSE;
}

int DL_ShouldBypassLastTouchGate(object oNpc)
{
    return DL_NpcNeedsCriticalWorkerTouch(oNpc);
}

object DL_GetAreaWorkerCursorNpc(object oArea)
{
    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        return OBJECT_INVALID;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    return DL_GetAreaRegistryNpcAtSlot(oArea, nCursor);
}

void DL_TraceAreaWorkerTickForRegisteredNpc(object oNpc, object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursor)
{
    if (!GetIsObjectValid(oNpc) || GetTag(oNpc) != "blacksmith01")
    {
        return;
    }

    string sAreaTag = "";
    if (GetIsObjectValid(oArea))
    {
        sAreaTag = GetTag(oArea);
    }

    DL_BsmithTraceStage(
        oNpc,
        "AREA_WORKER_TICK",
        "area=" + sAreaTag +
            " tick=" + IntToString(nTickStamp) +
            " pass=" + DL_GetAreaWorkerPassModeDebugLabel(nPassMode) +
            " budget=" + IntToString(nBudget) +
            " cursor=" + IntToString(nCursor)
    );
}

int DL_ProcessCriticalAreaCursorNpc(object oArea, int nPassMode, int nTickStamp, string sBypassKind)
{
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        return FALSE;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    int nAttempts = 0;
    int nSlot = 0;
    object oNpc = OBJECT_INVALID;
    while (nAttempts < nCount)
    {
        nSlot = (nCursor + nAttempts) % nCount;
        oNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);
        if (GetIsObjectValid(oNpc))
        {
            DL_TraceAreaWorkerTickForRegisteredNpc(oNpc, oArea, nTickStamp, nPassMode, DL_WORKER_BUDGET_MIN, nCursor);
            DL_BsmithTraceStage(oNpc, "WORKER_REGISTRY_SEEN", "critical_stale_scan slot=" + IntToString(nSlot) + " bypass=" + sBypassKind);
            if (DL_IsActivePipelineNpc(oNpc) && GetArea(oNpc) == oArea && GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea)
            {
                if (DL_IsRegisteredCurrentAreaStaleReachedMoveCritical(oNpc, oArea))
                {
                    DL_ClearCriticalProcessFailedDebug(oNpc);
                    SetLocalInt(oNpc, DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG, FALSE);
                    DL_SetCriticalWorkerDebug(oNpc, "stale_reached_move_job");
                    DL_BsmithTraceStage(oNpc, "CRITICAL_BYPASS", "stale_reached_move_job bypass=" + sBypassKind + " slot=" + IntToString(nSlot));
                    if (DL_TouchNpcFromAreaWorker(oNpc, oArea, nPassMode, nTickStamp, DL_WORKER_BUDGET_MIN, nSlot, nSlot))
                    {
                        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
                        return TRUE;
                    }
                    DL_SetCriticalProcessFailedDebug(oNpc, oArea, nSlot, nCount, nPassMode, "critical_stale_area_worker_touch_failed");
                    if (DL_EmergencyTouchCriticalStaleReachedNpc(oNpc, oArea, nPassMode, nTickStamp, nSlot, nCount, "critical_stale_area_worker_touch_failed"))
                    {
                        return TRUE;
                    }
                    DL_BsmithTraceStage(oNpc, "WORKER_SKIP", "reason=critical_stale_process_failed slot=" + IntToString(nSlot));
                }
            }
            else if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
            {
                DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nSlot);
                nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
                if (nCount <= 0)
                {
                    return FALSE;
                }
                if (nCursor >= nCount)
                {
                    nCursor = 0;
                }
            }
        }

        nAttempts = nAttempts + 1;
    }

    nAttempts = 0;
    while (nAttempts < nCount)
    {
        nSlot = (nCursor + nAttempts) % nCount;
        oNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);
        if (GetIsObjectValid(oNpc))
        {
            DL_TraceAreaWorkerTickForRegisteredNpc(oNpc, oArea, nTickStamp, nPassMode, DL_WORKER_BUDGET_MIN, nCursor);
            DL_BsmithTraceStage(oNpc, "WORKER_REGISTRY_SEEN", "critical_scan slot=" + IntToString(nSlot) + " bypass=" + sBypassKind);
            if (DL_IsActivePipelineNpc(oNpc) && GetArea(oNpc) == oArea && GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea)
            {
                if (DL_NpcNeedsCriticalWorkerTouch(oNpc))
                {
                    string sCriticalReason = GetLocalString(oNpc, DL_L_NPC_CRITICAL_REASON_DBG);
                    if (sCriticalReason == "")
                    {
                        sCriticalReason = "critical_worker_touch";
                    }
                    if (sBypassKind == "warm")
                    {
                        SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, TRUE);
                    }
                    else if (sBypassKind == "budget")
                    {
                        SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, TRUE);
                    }

                    DL_ClearCriticalProcessFailedDebug(oNpc);
                    SetLocalInt(oNpc, DL_L_NPC_EMERGENCY_STALE_REACHED_TOUCH_DBG, FALSE);
                    DL_BsmithTraceStage(oNpc, "CRITICAL_BYPASS", sCriticalReason + " bypass=" + sBypassKind + " slot=" + IntToString(nSlot));
                    if (DL_ProcessAreaNpcByPassMode(oArea, oNpc, nPassMode, nTickStamp, DL_WORKER_BUDGET_MIN, nSlot, nSlot))
                    {
                        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
                        return TRUE;
                    }
                    DL_SetCriticalProcessFailedDebug(oNpc, oArea, nSlot, nCount, nPassMode, "critical_process_failed");
                    if (DL_EmergencyTouchCriticalStaleReachedNpc(oNpc, oArea, nPassMode, nTickStamp, nSlot, nCount, "critical_process_failed"))
                    {
                        return TRUE;
                    }
                    DL_BsmithTraceStage(oNpc, "WORKER_SKIP", "reason=critical_process_failed slot=" + IntToString(nSlot));
                }
            }
            else if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
            {
                DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nSlot);
                nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
                if (nCount <= 0)
                {
                    return FALSE;
                }
                if (nCursor >= nCount)
                {
                    nCursor = 0;
                }
            }
        }

        nAttempts = nAttempts + 1;
    }

    return FALSE;
}

int DL_TouchNpcFromAreaWorker(object oNpc, object oArea, int nPassMode, int nTickStamp, int nBudget, int nCursorBefore, int nCursorAfter)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    int nSeqBefore = GetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_DBG);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_BEFORE_DBG, nSeqBefore);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_AFTER_DBG, nSeqBefore);
    DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "");
    DL_BsmithTraceStage(oNpc, "WORKER_TOUCH_ENTER", "area_worker");
    DL_WorkerTouchNpc(oNpc);
    int nSeqAfter = GetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_DBG);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_AFTER_DBG, nSeqAfter);
    if (nSeqAfter != nSeqBefore)
    {
        DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, TRUE, "");
        DL_BsmithTraceStage(oNpc, "WORKER_TOUCH_EXIT", "processed");
        return TRUE;
    }

    DL_BsmithTraceStage(oNpc, "WORKER_TOUCH_EXIT", "not_processed");
    DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "skip_unknown");
    return FALSE;
}

void DL_MarkAreaCursorNpcSkipped(object oArea, int nTickStamp, int nPassMode, int nBudget, int nCursor, string sReason)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        return;
    }

    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    object oNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nCursor);
    if (GetIsObjectValid(oNpc))
    {
        if (DL_IsActivePipelineNpc(oNpc) && !DL_IsNpcRegistryOwnerForArea(oNpc, oArea))
        {
            DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nCursor);
            return;
        }
        DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursor, nCursor, FALSE, FALSE, sReason);
    }
}

int DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(object oArea, object oNpc, int nSlot)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0 || nSlot < 0 || nSlot >= nCount)
    {
        return DL_RemoveStaleNpcReferenceFromAreaRegistry(oArea, oNpc);
    }

    if (DL_GetAreaRegistryNpcAtSlot(oArea, nSlot) == oNpc)
    {
        DL_RepairAreaRegistrySlot(oArea, nSlot, nCount);
        if (GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea)
        {
            DL_ClearNpcRegistryLocals(oNpc);
        }
        DL_SetStaleOldAreaRegistryDebug(oNpc, oArea, nSlot, TRUE);
        return TRUE;
    }

    return DL_RemoveStaleNpcReferenceFromAreaRegistry(oArea, oNpc);
}

int DL_IsNpcRegistryOwnerForArea(object oNpc, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    return GetArea(oNpc) == oArea && GetLocalObject(oNpc, DL_L_NPC_REG_AREA) == oArea;
}

void DL_ClearStaleTransitionHandoffProblemIfOwned(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oCurrentArea = GetArea(oNpc);
    object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    if (GetLocalString(oNpc, "dl_post_jump_result") == "post_jump_finalizer_complete" &&
        GetIsObjectValid(oCurrentArea) &&
        oRegisteredArea == oCurrentArea &&
        GetLocalString(oNpc, "dl_transition_registry_problem") == "target_area_worker_not_ticking_or_not_owning_npc")
    {
        DeleteLocalString(oNpc, "dl_transition_registry_problem");
    }
}

int DL_RunAreaRegistryFallbackIntegrityRepair(object oArea, int nRepairBudget)
{
    if (nRepairBudget < DL_WORKER_BUDGET_MIN)
    {
        nRepairBudget = DL_WORKER_BUDGET_MIN;
    }

    int nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nCount <= 0)
    {
        DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
        return FALSE;
    }

    int nCursor = GetLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    int nScanned = 0;
    int bMutated = FALSE;
    while (nScanned < nRepairBudget && nCount > 0)
    {
        int nSlot = (nCursor + nScanned) % nCount;
        object oCandidate = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);

        int bSlotValid = GetIsObjectValid(oCandidate) &&
                         GetObjectType(oCandidate) == OBJECT_TYPE_CREATURE &&
                         GetIsPC(oCandidate) == FALSE &&
                         GetIsDM(oCandidate) == FALSE &&
                         GetLocalInt(oCandidate, DL_L_NPC_REG_ON) == TRUE &&
                         GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) == oArea &&
                         GetLocalInt(oCandidate, DL_L_NPC_REG_SLOT) == nSlot;

        if (!bSlotValid)
        {
            DL_RepairAreaRegistrySlot(oArea, nSlot, nCount);
            nCount = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
            bMutated = TRUE;
            if (nCount <= 0)
            {
                nCursor = 0;
                break;
            }
            if (nCursor >= nCount)
            {
                nCursor = 0;
            }
            continue;
        }

        nScanned = nScanned + 1;
    }

    if (nCount > 0)
    {
        SetLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR, (nCursor + nScanned) % nCount);
    }
    else
    {
        DeleteLocalInt(oArea, DL_L_AREA_REGISTRY_REPAIR_CURSOR);
    }

    return bMutated;
}

int DL_RunAreaRegistryFallbackCatchupScan(object oArea, int nTickStamp, int nScanBudget)
{
    if (nScanBudget < DL_WORKER_BUDGET_MIN)
    {
        nScanBudget = DL_WORKER_BUDGET_MIN;
    }

    SetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_LAST_TICK, nTickStamp);
    SetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_COUNT, GetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_COUNT) + 1);
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_PASS_FALLBACK_COUNT, GetLocalInt(oModule, DL_L_MODULE_PASS_FALLBACK_COUNT) + 1);

    int nObjCursor = GetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR);
    if (nObjCursor < 0)
    {
        nObjCursor = 0;
    }

    int nObjectHopBudget = nScanBudget * DL_FALLBACK_OBJECT_HOP_MULTIPLIER;
    if (nObjectHopBudget < nScanBudget)
    {
        nObjectHopBudget = nScanBudget;
    }

    object oObj = GetFirstObjectInArea(oArea);
    int nSkipped = 0;
    while (GetIsObjectValid(oObj) && nSkipped < nObjCursor && nSkipped < nObjectHopBudget)
    {
        oObj = GetNextObjectInArea(oArea);
        nSkipped = nSkipped + 1;
    }

    if (nSkipped < nObjCursor && !GetIsObjectValid(oObj))
    {
        nObjCursor = 0;
        oObj = GetFirstObjectInArea(oArea);
    }

    int nVisitedObjects = 0;
    int nScannedActive = 0;
    int bReachedEnd = FALSE;

    while (GetIsObjectValid(oObj) && nScannedActive < nScanBudget && nVisitedObjects < nObjectHopBudget)
    {
        if (GetObjectType(oObj) == OBJECT_TYPE_CREATURE && DL_IsActivePipelineNpc(oObj))
        {
            nScannedActive = nScannedActive + 1;
            DL_EnsureNpcRegisteredInCurrentArea(oObj);
        }

        oObj = GetNextObjectInArea(oArea);
        nVisitedObjects = nVisitedObjects + 1;
    }

    if (!GetIsObjectValid(oObj))
    {
        bReachedEnd = TRUE;
    }

    if (bReachedEnd)
    {
        SetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR, 0);
    }
    else
    {
        SetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_OBJ_CURSOR, nObjCursor + nVisitedObjects);
    }

    return bReachedEnd;
}

int DL_RunAreaRegistryFallbackRecovery(object oArea, int nTickStamp, int nScanBudget)
{
    if (nScanBudget < DL_WORKER_BUDGET_MIN)
    {
        nScanBudget = DL_WORKER_BUDGET_MIN;
    }

    DL_RunAreaRegistryFallbackIntegrityRepair(oArea, nScanBudget);
    int bCatchupDone = DL_RunAreaRegistryFallbackCatchupScan(oArea, nTickStamp, nScanBudget);
    if (bCatchupDone)
    {
        DL_ClearAreaRegistryRebuildPending(oArea);
    }
    else
    {
        DL_MarkAreaRegistryRebuildPending(oArea);
    }

    return GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
}

int DL_ProcessAreaNpcByPassMode(object oArea, object oNpc, int nPassMode, int nTickStamp, int nBudget, int nCursorBefore, int nCursorAfter)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    if (nPassMode != DL_AREA_PASS_MODE_WORKER &&
        nPassMode != DL_AREA_PASS_MODE_WARM &&
        nPassMode != DL_AREA_PASS_MODE_RESYNC)
    {
        DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "skip_pass_mode");
        return FALSE;
    }

    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_LAST_TOUCH_DBG, FALSE);
    SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, FALSE);
    // HOT runtime areas use authoritative round-robin touch; no diagnostic bypass gate.
    int bHotRuntimeArea = nPassMode == DL_AREA_PASS_MODE_WORKER &&
        GetIsObjectValid(oArea) &&
        DL_GetAreaTier(oArea) == DL_TIER_HOT &&
        DL_GetAreaPlayerCount(oArea) > 0;
    int bCritical = FALSE;
    if (!bHotRuntimeArea)
    {
        bCritical = DL_NpcNeedsCriticalWorkerTouch(oNpc);
        if (bCritical && nPassMode == DL_AREA_PASS_MODE_WARM)
        {
            SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, TRUE);
        }
        if ((nPassMode == DL_AREA_PASS_MODE_WORKER || nPassMode == DL_AREA_PASS_MODE_WARM) &&
            GetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK) == nTickStamp)
        {
            if (!bCritical)
            {
                DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "skip_last_touch_gate");
                return FALSE;
            }
            SetLocalInt(oNpc, DL_L_NPC_CRITICAL_BYPASSED_LAST_TOUCH_DBG, TRUE);
        }
    }

    if (nPassMode == DL_AREA_PASS_MODE_RESYNC)
    {
        DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "skip_pass_mode");
        DL_RequestResync(oNpc, DL_RESYNC_AREA_ENTER);
        DL_ProcessResync(oNpc);
        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
        return TRUE;
    }

    if (!DL_IsActivePipelineNpc(oNpc))
    {
        DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "skip_not_active_pipeline_npc");
        return FALSE;
    }

    if (GetArea(oNpc) != oArea || GetLocalObject(oNpc, DL_L_NPC_REG_AREA) != oArea)
    {
        DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oNpc, nCursorBefore);
        return FALSE;
    }

    if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
    {
        DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, nPassMode, nBudget, nCursorBefore, nCursorAfter, TRUE, FALSE, "skip_invalid_slot");
        return FALSE;
    }

    if (DL_TouchNpcFromAreaWorker(oNpc, oArea, nPassMode, nTickStamp, nBudget, nCursorBefore, nCursorAfter))
    {
        SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
        return TRUE;
    }

    return FALSE;
}

int DL_RunAreaNpcRoundRobinPass(object oArea, int nCursor, int nBudget, int nPassMode, int nTickStamp)
{
    if (nCursor < 0)
    {
        nCursor = 0;
    }

    if (nBudget < DL_WORKER_BUDGET_MIN)
    {
        nBudget = DL_WORKER_BUDGET_MIN;
    }

    int nNpcProcessed = 0;
    int nCandidates = 0;
    int nNpcRegistered = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
    if (nNpcRegistered < 0)
    {
        nNpcRegistered = 0;
    }

    DL_SetAreaWorkerPassDebug(oArea, nTickStamp, nPassMode, nBudget, nCursor, nCursor);

    // Recovery path only: bounded scan when registry is empty or has stale slots.
    if (nNpcRegistered == 0)
    {
        DL_MarkAreaRegistryRebuildPending(oArea);
        nNpcRegistered = DL_RunAreaRegistryFallbackRecovery(oArea, nTickStamp, nBudget);
        if (nNpcRegistered == 0)
        {
            SetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN, 0);
            SetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES, 0);
            return 0;
        }
    }

    if (nCursor >= nNpcRegistered)
    {
        nCursor = nCursor % nNpcRegistered;
    }

    int nAttempts = 0;
    int bFallbackNeeded = FALSE;
    while (nAttempts < nNpcRegistered && nNpcProcessed < nBudget)
    {
        int nSlot = (nCursor + nAttempts) % nNpcRegistered;
        object oCandidate = DL_GetAreaRegistryNpcAtSlot(oArea, nSlot);
        nCandidates = nCandidates + 1;

        if (GetIsObjectValid(oCandidate))
        {
            DL_BsmithTraceStage(oCandidate, "WORKER_REGISTRY_SEEN", "round_robin slot=" + IntToString(nSlot));
            if (GetObjectType(oCandidate) == OBJECT_TYPE_CREATURE &&
                GetIsPC(oCandidate) == FALSE &&
                GetIsDM(oCandidate) == FALSE &&
                GetArea(oCandidate) == oArea &&
                GetLocalInt(oCandidate, DL_L_NPC_REG_ON) == TRUE &&
                GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) == oArea &&
                GetLocalInt(oCandidate, DL_L_NPC_REG_SLOT) == nSlot &&
                DL_IsActivePipelineNpc(oCandidate))
            {
                if (DL_ProcessAreaNpcByPassMode(oArea, oCandidate, nPassMode, nTickStamp, nBudget, nCursor, nCursor))
                {
                    nNpcProcessed = nNpcProcessed + 1;
                }
            }
            else if (DL_IsActivePipelineNpc(oCandidate))
            {
                if (GetArea(oCandidate) != oArea || GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) != oArea)
                {
                    DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oCandidate, nSlot);
                    nNpcRegistered = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
                    bFallbackNeeded = TRUE;
                }
                else
                {
                    DL_EnsureNpcRegisteredInCurrentArea(oCandidate);
                    if (GetLocalObject(oCandidate, DL_L_NPC_REG_AREA) == oArea &&
                        DL_ProcessAreaNpcByPassMode(oArea, oCandidate, nPassMode, nTickStamp, nBudget, nCursor, nCursor))
                    {
                        nNpcProcessed = nNpcProcessed + 1;
                    }
                }
            }
            else if (GetLocalInt(oCandidate, DL_L_NPC_REG_ON) == TRUE)
            {
                DL_SetNpcRegularWorkerDebug(oCandidate, oArea, nTickStamp, nPassMode, nBudget, nCursor, nCursor, TRUE, FALSE, "skip_not_active_pipeline_npc");
                DL_UnregisterNpc(oCandidate);
                bFallbackNeeded = TRUE;
            }
            else
            {
                DL_SetNpcRegularWorkerDebug(oCandidate, oArea, nTickStamp, nPassMode, nBudget, nCursor, nCursor, TRUE, FALSE, "skip_not_active_pipeline_npc");
            }
        }
        else
        {
            bFallbackNeeded = TRUE;
        }

        nAttempts = nAttempts + 1;
    }

    if (nNpcProcessed >= nBudget && nAttempts < nNpcRegistered)
    {
        int nNextBudgetSlot = (nCursor + nAttempts) % nNpcRegistered;
        object oBudgetNpc = DL_GetAreaRegistryNpcAtSlot(oArea, nNextBudgetSlot);
        if (GetIsObjectValid(oBudgetNpc) &&
            DL_IsActivePipelineNpc(oBudgetNpc) &&
            !DL_IsNpcRegistryOwnerForArea(oBudgetNpc, oArea))
        {
            DL_RemoveStaleNpcReferenceFromAreaRegistrySlot(oArea, oBudgetNpc, nNextBudgetSlot);
            nNpcRegistered = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
        }
    }

    if (bFallbackNeeded)
    {
        DL_MarkAreaRegistryRebuildPending(oArea);
    }

    if (nPassMode == DL_AREA_PASS_MODE_WORKER || nPassMode == DL_AREA_PASS_MODE_WARM)
    {
        int nLastCatchupTick = GetLocalInt(oArea, DL_L_AREA_PASS_FALLBACK_LAST_TICK);
        int bCatchupDue = GetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING) == TRUE ||
            nLastCatchupTick <= 0 ||
            (nTickStamp >= nLastCatchupTick && (nTickStamp - nLastCatchupTick) >= DL_WARM_MAINTENANCE_INTERVAL_TICKS);
        if (bCatchupDue)
        {
            int nCatchupBudget = nBudget - nNpcProcessed;
            if (nCatchupBudget < DL_WORKER_BUDGET_MIN)
            {
                nCatchupBudget = DL_WORKER_BUDGET_MIN;
            }
            DL_RunAreaRegistryFallbackCatchupScan(oArea, nTickStamp, nCatchupBudget);
            nNpcRegistered = GetLocalInt(oArea, DL_L_AREA_REG_COUNT);
        }
    }

    if (GetLocalInt(oArea, DL_L_AREA_REGISTRY_REBUILD_PENDING) == TRUE)
    {
        nNpcRegistered = DL_RunAreaRegistryFallbackRecovery(oArea, nTickStamp, nBudget);
    }

    SetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN, nNpcRegistered);
    SetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES, nCandidates);
    return nNpcProcessed;
}

int DL_RunTransitionRegistryHandoffTick(object oArea, int nTickStamp)
{
    if (!DL_IsAreaObject(oArea))
    {
        return 0;
    }

    int nTouched = 0;
    int i = 0;
    while (i < DL_TRANSITION_HANDOFF_SLOT_COUNT)
    {
        string sSlotKey = DL_GetAreaTransitionHandoffSlotKey(i);
        object oNpc = GetLocalObject(oArea, sSlotKey);
        if (GetIsObjectValid(oNpc))
        {
            object oNpcArea = GetArea(oNpc);
            object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
            string sRegisteredAreaBefore = "";
            string sNpcArea = "";
            if (GetIsObjectValid(oRegisteredArea))
            {
                sRegisteredAreaBefore = GetTag(oRegisteredArea);
            }
            if (GetIsObjectValid(oNpcArea))
            {
                sNpcArea = GetTag(oNpcArea);
            }

            SetLocalString(oNpc, "dl_transition_registry_worker_tick_area", GetTag(oArea));
            SetLocalInt(oNpc, "dl_transition_registry_handoff_slot", i);
            SetLocalInt(oNpc, "dl_transition_registry_handoff_seen", TRUE);
            SetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called", FALSE);
            SetLocalString(oNpc, "dl_transition_registry_npc_area", sNpcArea);
            SetLocalString(oNpc, "dl_transition_registry_reg_area_before", sRegisteredAreaBefore);
            SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredAreaBefore);
            DL_SetTransitionRegistryHandoffDebug(oNpc, OBJECT_INVALID, oArea);

            if (oNpcArea == oArea)
            {
                SetLocalInt(oNpc, DL_L_NPC_PROCESSED_BY_RR_DBG, FALSE);
                DL_SetNpcRegularWorkerDebug(oNpc, oArea, nTickStamp, DL_AREA_PASS_MODE_WORKER, 0, 0, 0, FALSE, FALSE, "");
                DL_WorkerTouchNpc(oNpc);
                DL_ClearStaleTransitionHandoffProblemIfOwned(oNpc);
                SetLocalInt(oNpc, "dl_transition_registry_handoff_touch_called", TRUE);
                SetLocalInt(oNpc, DL_L_NPC_LAST_TOUCH_TICK, nTickStamp);
                oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
                string sRegisteredAreaAfterTouch = "";
                if (GetIsObjectValid(oRegisteredArea))
                {
                    sRegisteredAreaAfterTouch = GetTag(oRegisteredArea);
                }
                SetLocalString(oNpc, "dl_transition_registry_reg_area_after", sRegisteredAreaAfterTouch);
                DL_SetTransitionRegistryHandoffDebug(oNpc, OBJECT_INVALID, oArea);
                if (oRegisteredArea == oArea)
                {
                    DeleteLocalObject(oArea, sSlotKey);
                    nTouched = nTouched + 1;
                }
                else
                {
                    DL_MarkAreaRegistryRebuildPending(oArea);
                }
            }
            else
            {
                DL_MarkAreaRegistryRebuildPending(oArea);
                DL_SetTransitionRegistryHandoffDebug(oNpc, OBJECT_INVALID, oArea);
            }
        }
        i = i + 1;
    }

    return nTouched;
}

void DL_WorkerTouchNpc(object oNpc)
{
    object oCurrentArea = GetArea(oNpc);
    object oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    string sCurrentArea = "";
    string sRegisteredArea = "";
    if (GetIsObjectValid(oCurrentArea))
    {
        sCurrentArea = GetTag(oCurrentArea);
    }
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredArea = GetTag(oRegisteredArea);
    }
    SetLocalString(oNpc, "dl_registry_current_physical_area", sCurrentArea);
    SetLocalString(oNpc, "dl_registry_area_before_repair", sRegisteredArea);
    SetLocalString(oNpc, "dl_worker_touch_area", sCurrentArea);

    if (!DL_IsActivePipelineNpc(oNpc))
    {
        return;
    }

    if (oRegisteredArea != oCurrentArea)
    {
        if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
        {
            SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "registry_repair_verify_failed");
            DL_MaybeLogNpcDiagnostic(oNpc, "worker_registry_repair", TRUE);
            return;
        }
    }

    if (!DL_EnsureNpcRegisteredInCurrentArea(oNpc))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "registry_repair_verify_failed");
        DL_MaybeLogNpcDiagnostic(oNpc, "worker_registry_repair", TRUE);
        return;
    }

    oRegisteredArea = GetLocalObject(oNpc, DL_L_NPC_REG_AREA);
    sRegisteredArea = "";
    if (GetIsObjectValid(oRegisteredArea))
    {
        sRegisteredArea = GetTag(oRegisteredArea);
    }
    SetLocalString(oNpc, "dl_registry_area_after_repair", sRegisteredArea);
    DL_BsmithTraceStage(oNpc, "REGISTRY_CHECK", "after_repair");
    DL_ClearStaleTransitionHandoffProblemIfOwned(oNpc);
    if (GetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC) == "registry_repair_verify_failed")
    {
        DeleteLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC);
    }

    object oModule = GetModule();
    int nWorkerSeq = GetLocalInt(oModule, DL_L_MODULE_WORKER_SEQ) + 1;
    SetLocalInt(oModule, DL_L_MODULE_WORKER_SEQ, nWorkerSeq);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_SEQ, nWorkerSeq);
    SetLocalInt(oNpc, DL_L_NPC_WORKER_TOUCH_SEQ_DBG, nWorkerSeq);
    SetLocalInt(oNpc, DL_L_NPC_LAST_WORKER_TOUCH_HOUR_DBG, GetTimeHour());
    SetLocalInt(oNpc, DL_L_NPC_LAST_WORKER_TOUCH_MINUTE_DBG, GetTimeMinute());
    SetLocalInt(oNpc, DL_L_NPC_LAST_WORKER_TOUCH_ABS_MIN_DBG, DL_GetAbsoluteMinute());
    DL_BsmithTraceStage(oNpc, "WORKER_TOUCH", "worker_touch");

    int nDirective = DL_ResolveNpcDirective(oNpc);
    DL_BsmithTraceStage(oNpc, "DIRECTIVE_PROCESS", "invoke " + DL_GetDirectiveDebugLabel(nDirective));
    DL_ApplyDirectiveSkeleton(oNpc, nDirective);
    DL_BsmithTraceStage(oNpc, "WORKER_EXIT", "after_directive");

    if (DL_GetNpcProblemSummary(oNpc) != "ok")
    {
        DL_MaybeLogNpcDiagnostic(oNpc, "worker", FALSE);
        DL_BsmithTraceStage(oNpc, "PROBLEM_SUMMARY", DL_GetNpcProblemSummary(oNpc));
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_DIAG_LAST_SIG);
    }
}

void DL_RunAreaEnterResyncTick(object oArea)
{
    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        return;
    }

    if (DL_GetAreaTier(oArea) != DL_TIER_HOT)
    {
        return;
    }

    if (GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING) != TRUE)
    {
        return;
    }

    int nBudget = DL_GetAreaResyncBudget(oArea);
    nBudget = DL_ConsumeModuleNpcBudget(nBudget);
    if (nBudget <= 0)
    {
        SetLocalInt(oArea, DL_L_AREA_RESYNC_LAST_PROCESSED, 0);
        object oModuleNoBudget = GetModule();
        SetLocalInt(oModuleNoBudget, DL_L_MODULE_RESYNC_LAST_PROCESSED, 0);
        return;
    }

    int nCursor = GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_CURSOR);
    int nTickStamp = DL_GetAreaTick(oArea);
    int nNpcProcessed = DL_RunAreaNpcRoundRobinPass(oArea, nCursor, nBudget, DL_AREA_PASS_MODE_RESYNC, nTickStamp);
    int nNpcSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN);

    SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_TOUCHED, nNpcProcessed);
    SetLocalInt(oArea, DL_L_AREA_RESYNC_LAST_PROCESSED, nNpcProcessed);
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_RESYNC_LAST_PROCESSED, nNpcProcessed);

    if (nNpcSeen <= 0)
    {
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_CURSOR, 0);
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING, FALSE);
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE, GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE) + 1);
        return;
    }

    int nCandidatesSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES);
    int nCursorAdvance = DL_GetCursorAdvance(nNpcProcessed, nCandidatesSeen, nNpcSeen);
    int nNextCursor = (nCursor + nCursorAdvance) % nNpcSeen;
    SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_CURSOR, nNextCursor);

    if (nNextCursor == 0)
    {
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING, FALSE);
        SetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE, GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_DONE) + 1);
    }
}

void DL_RunAreaWarmMaintenanceTick(object oArea)
{
    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        DL_MarkAreaCursorNpcSkipped(oArea, DL_GetAreaTick(oArea), DL_AREA_PASS_MODE_WARM, 0, DL_GetAreaWorkerCursor(oArea), "skip_runtime_disabled");
        return;
    }

    int nTickStamp = DL_GetAreaTick(oArea);
    if (DL_ProcessCriticalAreaCursorNpc(oArea, DL_AREA_PASS_MODE_WARM, nTickStamp, "warm"))
    {
        return;
    }

    if (DL_GetAreaTier(oArea) != DL_TIER_WARM)
    {
        DL_MarkAreaCursorNpcSkipped(oArea, nTickStamp, DL_AREA_PASS_MODE_WARM, 0, DL_GetAreaWorkerCursor(oArea), "skip_area_not_hot");
        return;
    }

    object oWarmCandidate = DL_GetAreaWorkerCursorNpc(oArea);
    int bCriticalWarmCandidate = DL_NpcNeedsCriticalWorkerTouch(oWarmCandidate);
    int nLastTick = GetLocalInt(oArea, DL_L_AREA_LAST_WARM_MAINT_TICK);
    if (bCriticalWarmCandidate)
    {
        SetLocalInt(oWarmCandidate, DL_L_NPC_CRITICAL_BYPASSED_WARM_DBG, TRUE);
    }
    if (!bCriticalWarmCandidate &&
        nTickStamp >= nLastTick && (nTickStamp - nLastTick) < DL_WARM_MAINTENANCE_INTERVAL_TICKS)
    {
        DL_MarkAreaCursorNpcSkipped(oArea, nTickStamp, DL_AREA_PASS_MODE_WARM, 0, DL_GetAreaWorkerCursor(oArea), "skip_area_not_hot");
        return;
    }
    SetLocalInt(oArea, DL_L_AREA_LAST_WARM_MAINT_TICK, nTickStamp);

    int nBudget = DL_WORKER_BUDGET_MIN;
    if (!bCriticalWarmCandidate)
    {
        nBudget = DL_ConsumeModuleNpcBudget(nBudget);
    }
    if (nBudget <= 0)
    {
        if (DL_ProcessCriticalAreaCursorNpc(oArea, DL_AREA_PASS_MODE_WARM, nTickStamp, "budget"))
        {
            return;
        }
        int nBudgetCursor = DL_GetAreaWorkerCursor(oArea);
        DL_SetAreaWorkerPassDebug(oArea, nTickStamp, DL_AREA_PASS_MODE_WARM, 0, nBudgetCursor, nBudgetCursor);
        DL_MarkAreaCursorNpcSkipped(oArea, nTickStamp, DL_AREA_PASS_MODE_WARM, 0, nBudgetCursor, "skip_budget_exhausted");
        SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, 0);
        object oModuleNoBudget = GetModule();
        SetLocalInt(oModuleNoBudget, DL_L_MODULE_WORKER_LAST_PROCESSED, 0);
        return;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    int nNpcProcessed = DL_RunAreaNpcRoundRobinPass(oArea, nCursor, nBudget, DL_AREA_PASS_MODE_WARM, nTickStamp);
    int nNpcSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN);

    int nCursorAfter = 0;
    if (nNpcSeen <= 0)
    {
        DL_SetAreaWorkerCursor(oArea, 0);
    }
    else
    {
        int nCandidatesSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES);
        int nCursorAdvance = DL_GetCursorAdvance(nNpcProcessed, nCandidatesSeen, nNpcSeen);
        nCursorAfter = (nCursor + nCursorAdvance) % nNpcSeen;
        DL_SetAreaWorkerCursor(oArea, nCursorAfter);
    }
    DL_SetAreaWorkerPassDebug(oArea, nTickStamp, DL_AREA_PASS_MODE_WARM, nBudget, nCursor, nCursorAfter);

    SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, nNpcProcessed);
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_WORKER_LAST_PROCESSED, nNpcProcessed);
}

void DL_RunAreaWorkerTick(object oArea)
{
    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    if (!DL_IsRuntimeEnabled())
    {
        DL_MarkAreaCursorNpcSkipped(oArea, DL_GetAreaTick(oArea), DL_AREA_PASS_MODE_WORKER, 0, DL_GetAreaWorkerCursor(oArea), "skip_runtime_disabled");
        return;
    }

    int nAreaTickSeq = DL_AdvanceAreaTick(oArea);
    SetLocalString(oArea, DL_L_AREA_WORKER_TICK_AREA_DBG, GetTag(oArea));
    SetLocalInt(oArea, DL_L_AREA_WORKER_TICK_SEQ_DBG, nAreaTickSeq);
    DL_BootstrapAreaTier(oArea);
    DL_MaybeReconcileAreaPlayerCount(oArea);

    int nCachedPlayers = DL_GetAreaPlayerCount(oArea);
    int nActualPlayers = DL_CountPlayersInArea(oArea);
    int nTierBeforeLifecycle = DL_GetAreaTier(oArea);
    int bStaleRepaired = FALSE;
    int bHotnessRepaired = FALSE;
    int bForcedHotDueToPlayer = FALSE;

    if (nActualPlayers > 0)
    {
        if (nCachedPlayers != nActualPlayers)
        {
            SetLocalInt(oArea, DL_L_AREA_PLAYER_COUNT, nActualPlayers);
            SetLocalInt(oArea, DL_L_AREA_PLAYER_COUNT_INIT, TRUE);
            bStaleRepaired = TRUE;
        }
        if (nTierBeforeLifecycle != DL_TIER_HOT)
        {
            DL_TransitionAreaToHot(oArea, TRUE);
            bHotnessRepaired = TRUE;
            bForcedHotDueToPlayer = TRUE;
        }
    }

    DL_SetAreaHotnessDebug(
        oArea,
        nCachedPlayers,
        nActualPlayers,
        nTierBeforeLifecycle,
        DL_GetAreaTier(oArea),
        bHotnessRepaired,
        bForcedHotDueToPlayer,
        bStaleRepaired
    );
    DL_UpdateAreaTierLifecycle(oArea);

    int nTierAfterLifecycle = DL_GetAreaTier(oArea);
    if (nActualPlayers > 0 && nTierAfterLifecycle != DL_TIER_HOT)
    {
        SetLocalInt(oArea, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG, TRUE);
        DL_TransitionAreaToHot(oArea, TRUE);
        bHotnessRepaired = TRUE;
        bForcedHotDueToPlayer = TRUE;
        nTierAfterLifecycle = DL_GetAreaTier(oArea);
    }
    else
    {
        SetLocalInt(oArea, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG, FALSE);
    }
    DL_SetAreaHotnessDebug(
        oArea,
        nCachedPlayers,
        nActualPlayers,
        nTierBeforeLifecycle,
        nTierAfterLifecycle,
        bHotnessRepaired,
        bForcedHotDueToPlayer,
        bStaleRepaired
    );

    int nTier = DL_GetAreaTier(oArea);
    if (nTier == DL_TIER_FROZEN)
    {
        if (nActualPlayers > 0)
        {
            SetLocalInt(oArea, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG, TRUE);
            DL_TransitionAreaToHot(oArea, TRUE);
            nTier = DL_GetAreaTier(oArea);
            DL_SetAreaHotnessDebug(oArea, nCachedPlayers, nActualPlayers, nTierBeforeLifecycle, nTier, TRUE, TRUE, bStaleRepaired);
        }
        else
        {
            if (DL_ProcessCriticalAreaCursorNpc(oArea, DL_AREA_PASS_MODE_WORKER, DL_GetAreaTick(oArea), "warm"))
            {
                return;
            }
            DL_MarkAreaCursorNpcSkipped(oArea, DL_GetAreaTick(oArea), DL_AREA_PASS_MODE_WORKER, 0, DL_GetAreaWorkerCursor(oArea), "skip_area_not_hot");
            return;
        }
    }
    if (nTier == DL_TIER_WARM)
    {
        if (nActualPlayers > 0)
        {
            SetLocalInt(oArea, DL_L_AREA_HOTNESS_BUG_PLAYER_PRESENT_DBG, TRUE);
            DL_TransitionAreaToHot(oArea, TRUE);
            nTier = DL_GetAreaTier(oArea);
            DL_SetAreaHotnessDebug(oArea, nCachedPlayers, nActualPlayers, nTierBeforeLifecycle, nTier, TRUE, TRUE, bStaleRepaired);
        }
        else
        {
            DL_RunAreaWarmMaintenanceTick(oArea);
            return;
        }
    }

    DL_RunAreaEnterResyncTick(oArea);

    // HOT area worker must not depend on shared module budget or critical/emergency bypasses.
    int nBudget = DL_GetAreaWorkerBudget(oArea);
    if (nBudget < DL_WORKER_BUDGET_MIN)
    {
        nBudget = DL_WORKER_BUDGET_MIN;
    }

    int nCursor = DL_GetAreaWorkerCursor(oArea);
    int nTickStamp = DL_GetAreaTick(oArea);
    int nNpcProcessed = DL_RunAreaNpcRoundRobinPass(oArea, nCursor, nBudget, DL_AREA_PASS_MODE_WORKER, nTickStamp);
    int nNpcSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_SEEN);

    int nCursorAfter = 0;
    if (nNpcSeen <= 0)
    {
        DL_SetAreaWorkerCursor(oArea, 0);
    }
    else
    {
        int nCandidatesSeen = GetLocalInt(oArea, DL_L_AREA_PASS_LAST_CANDIDATES);
        int nCursorAdvance = DL_GetCursorAdvance(nNpcProcessed, nCandidatesSeen, nNpcSeen);
        nCursorAfter = (nCursor + nCursorAdvance) % nNpcSeen;
        DL_SetAreaWorkerCursor(oArea, nCursorAfter);
    }
    DL_SetAreaWorkerPassDebug(oArea, nTickStamp, DL_AREA_PASS_MODE_WORKER, nBudget, nCursor, nCursorAfter);

    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_WORKER_TICKS, GetLocalInt(oModule, DL_L_MODULE_WORKER_TICKS) + 1);
    SetLocalInt(oArea, DL_L_AREA_WORKER_LAST_PROCESSED, nNpcProcessed);
    SetLocalInt(oModule, DL_L_MODULE_WORKER_LAST_PROCESSED, nNpcProcessed);
}
