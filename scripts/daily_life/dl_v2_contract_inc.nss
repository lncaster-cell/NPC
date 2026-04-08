#ifndef DL_V2_CONTRACT_INC_NSS
#define DL_V2_CONTRACT_INC_NSS

#include "dl_v2_runtime_inc"

// Daily Life v2 shared contract constants.
// Extends Step 01 runtime gate with NPC/area/runtime contract values.

const string DL2_L_NPC_PROFILE_ID = "dl2_profile_id";
const string DL2_L_NPC_STATE = "dl2_state";
const string DL2_L_NPC_ANCHOR_ID = "dl2_anchor_id";
const string DL2_L_NPC_LAST_TICK = "dl2_last_tick";
const string DL2_L_NPC_DEBUG_TRACE = "dl2_debug_trace";

const string DL2_L_AREA_TIER = "dl2_area_tier";
const string DL2_L_AREA_WORKER_CURSOR = "dl2_worker_cursor";
const string DL2_L_AREA_WORKER_BUDGET = "dl2_worker_budget";

const int DL2_STATE_IDLE = 0;
const int DL2_STATE_TRANSIT = 1;
const int DL2_STATE_ACTIVE = 2;
const int DL2_STATE_BLOCKED = 3;

const int DL2_AREA_TIER_FROZEN = 0;
const int DL2_AREA_TIER_WARM = 1;
const int DL2_AREA_TIER_HOT = 2;

const int DL2_DEFAULT_WORKER_BUDGET = 4;

int DL2_IsValidNpcState(int nState)
{
    return nState >= DL2_STATE_IDLE && nState <= DL2_STATE_BLOCKED;
}

int DL2_IsValidAreaTier(int nTier)
{
    return nTier >= DL2_AREA_TIER_FROZEN && nTier <= DL2_AREA_TIER_HOT;
}

#endif
