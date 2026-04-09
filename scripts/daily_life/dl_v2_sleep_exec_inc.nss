#ifndef DL_V2_SLEEP_EXEC_INC_NSS
#define DL_V2_SLEEP_EXEC_INC_NSS

#include "dl_v2_sleep_anchor_inc"

// Minimal sleep execution slice.
// Fast path:
// - move to walkmesh-safe approach point
// - when near enough, snap to bed waypoint
// Animation/presentation hook is intentionally separated for later test-bed iteration.

const string DL2_L_NPC_SLEEP_ACTIVITY_ID = "dl2_sleep_activity_id";

float DL2_GetSleepApproachSnapDistance()
{
    return 1.25;
}

void DL2_BeginSleepApproach(object oNPC)
{
    object oApproach = DL2_GetNpcSleepApproachWaypoint(oNPC);
    if (!GetIsObjectValid(oNPC) || !GetIsObjectValid(oApproach))
    {
        return;
    }

    AssignCommand(oNPC, ClearAllActions());
    AssignCommand(oNPC, ActionMoveToObject(oApproach, TRUE));
    SetLocalInt(oNPC, DL2_L_NPC_SLEEP_MODE, DL2_SLEEP_MODE_APPROACH);

    DL2_LogInfo("SLEEP", "approach_started");
}

int DL2_IsNpcReadyToSnapToSleepBed(object oNPC)
{
    object oApproach = DL2_GetNpcSleepApproachWaypoint(oNPC);
    if (!GetIsObjectValid(oNPC) || !GetIsObjectValid(oApproach))
    {
        return FALSE;
    }

    return GetDistanceBetween(oNPC, oApproach) <= DL2_GetSleepApproachSnapDistance();
}

void DL2_SnapNpcToSleepBed(object oNPC)
{
    object oBed = DL2_GetNpcSleepBedWaypoint(oNPC);
    if (!GetIsObjectValid(oNPC) || !GetIsObjectValid(oBed))
    {
        return;
    }

    AssignCommand(oNPC, ClearAllActions());
    AssignCommand(oNPC, ActionJumpToLocation(GetLocation(oBed)));

    SetLocalInt(oNPC, DL2_L_NPC_SLEEP_MODE, DL2_SLEEP_MODE_ON_BED);
    SetLocalInt(oNPC, DL2_L_NPC_SLEEP_ACTIVITY_ID, DL2_ACTIVITY_SLEEP_BED);

    DL2_LogInfo("SLEEP", "snap_to_bed_complete");
}

int DL2_ExecuteSleepPairTick(object oNPC)
{
    if (!DL2_IsNpcSleepAnchorPairValid(oNPC))
    {
        DL2_LogWarn("SLEEP", "invalid_sleep_pair");
        return FALSE;
    }

    int nMode = GetLocalInt(oNPC, DL2_L_NPC_SLEEP_MODE);
    if (nMode == DL2_SLEEP_MODE_ON_BED)
    {
        return TRUE;
    }

    if (nMode != DL2_SLEEP_MODE_APPROACH)
    {
        DL2_BeginSleepApproach(oNPC);
        return TRUE;
    }

    if (DL2_IsNpcReadyToSnapToSleepBed(oNPC))
    {
        DL2_SnapNpcToSleepBed(oNPC);
    }

    return TRUE;
}

#endif
