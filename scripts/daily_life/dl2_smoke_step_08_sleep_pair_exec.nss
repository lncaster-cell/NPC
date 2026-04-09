// Daily Life v2 smoke Step 08.
// Verifies two-waypoint sleep pair and move->snap execution path.
// Test stand expectation:
// - one interior area
// - one NPC with assigned sleep pair
// - two waypoints: approach near bed, bed on bed surface

#include "dl_v2_sleep_exec_inc"

void DL2_EnableSmokeTraceForSleepExecTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

void main()
{
    object oArea = GetArea(GetFirstPC());
    object oNPC = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oNPC) && !DL2_IsRuntimeNpcCandidate(oNPC))
    {
        oNPC = GetNextObjectInArea(oArea);
    }

    DL2_EnableSmokeTraceForSleepExecTest();

    if (!GetIsObjectValid(oNPC))
    {
        DL2_LogSmoke("STEP08", "runtime_npc_present", TRUE, FALSE);
        return;
    }

    DL2_LogSmoke(
        "STEP08",
        "sleep_pair_valid",
        TRUE,
        DL2_IsNpcSleepAnchorPairValid(oNPC)
    );

    DL2_ExecuteSleepPairTick(oNPC);

    DL2_LogSmoke(
        "STEP08",
        "sleep_mode_started",
        TRUE,
        GetLocalInt(oNPC, DL2_L_NPC_SLEEP_MODE) == DL2_SLEEP_MODE_APPROACH
            || GetLocalInt(oNPC, DL2_L_NPC_SLEEP_MODE) == DL2_SLEEP_MODE_ON_BED
    );
}
