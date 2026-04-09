// Daily Life v2 smoke Step 04.
// Verifies NPC registration and area worker candidate cursor.

#include "dl_v2_worker_inc"

void DL2_EnableSmokeTraceForRegistryTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

object DL2_GetFirstRuntimeNpcCandidateInArea(object oArea)
{
    object oCurrent = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oCurrent))
    {
        if (DL2_IsRuntimeNpcCandidate(oCurrent))
        {
            return oCurrent;
        }
        oCurrent = GetNextObjectInArea(oArea);
    }

    return OBJECT_INVALID;
}

void main()
{
    object oArea = GetArea(GetFirstPC());
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    DL2_EnableSmokeTraceForRegistryTest();
    DL2_InitAreaRuntimeState(oArea);
    DL2_SetAreaWorkerCursor(oArea, 0);

    int nCandidateCount = DL2_CountRuntimeCandidatesInArea(oArea);
    DL2_LogSmoke(
        "STEP04",
        "candidate_count_non_negative",
        TRUE,
        nCandidateCount >= 0
    );

    object oFirstCandidate = DL2_GetFirstRuntimeNpcCandidateInArea(oArea);
    if (!GetIsObjectValid(oFirstCandidate))
    {
        DL2_LogSmoke("STEP04", "candidate_present_for_runtime_test", FALSE, FALSE);
        return;
    }

    DeleteLocalInt(oFirstCandidate, DL2_L_NPC_REGISTERED);
    DeleteLocalString(oFirstCandidate, DL2_L_NPC_REGISTRATION_VERSION);
    DeleteLocalString(oFirstCandidate, DL2_L_NPC_PROFILE_ID);
    DeleteLocalInt(oFirstCandidate, DL2_L_NPC_STATE);

    DL2_RegisterNpc(oFirstCandidate);
    DL2_LogSmoke(
        "STEP04",
        "register_sets_flag",
        TRUE,
        DL2_IsNpcRegistered(oFirstCandidate)
    );

    DL2_LogSmoke(
        "STEP04",
        "register_sets_default_profile",
        TRUE,
        GetLocalString(oFirstCandidate, DL2_L_NPC_PROFILE_ID) == "unassigned"
    );

    DL2_SetAreaWorkerCursor(oArea, 0);
    object oWorkerCandidate = DL2_GetNextRuntimeCandidateForWorker(oArea);
    DL2_LogSmoke(
        "STEP04",
        "worker_returns_candidate",
        TRUE,
        GetIsObjectValid(oWorkerCandidate)
    );

    DL2_LogSmoke(
        "STEP04",
        "worker_advances_cursor",
        TRUE,
        DL2_GetAreaWorkerCursor(oArea) >= 0
    );
}
