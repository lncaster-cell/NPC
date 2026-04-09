#ifndef DL_V2_SLEEP_ANCHOR_INC_NSS
#define DL_V2_SLEEP_ANCHOR_INC_NSS

#include "dl_v2_idle_base_resolver_inc"

// Sleep anchor pair contract.
// Exactly two waypoints are used:
// 1) approach waypoint near the bed, walkmesh-safe
// 2) bed waypoint on the bed, used as snap target

const string DL2_L_NPC_SLEEP_APPROACH_TAG = "dl2_sleep_approach_tag";
const string DL2_L_NPC_SLEEP_BED_TAG = "dl2_sleep_bed_tag";
const string DL2_L_NPC_SLEEP_MODE = "dl2_sleep_mode";

const int DL2_SLEEP_MODE_NONE = 0;
const int DL2_SLEEP_MODE_APPROACH = 1;
const int DL2_SLEEP_MODE_ON_BED = 2;

const int DL2_ACTIVITY_SLEEP_BED = 5;
const int DL2_ACTIVITY_SLEEP_90 = 32;

object DL2_GetWaypointByTagStrict(string sTag)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oWaypoint = GetObjectByTag(sTag, 0);
    if (!GetIsObjectValid(oWaypoint))
    {
        return OBJECT_INVALID;
    }

    return oWaypoint;
}

void DL2_AssignSleepAnchorPair(object oNPC, string sApproachTag, string sBedTag)
{
    if (!GetIsObjectValid(oNPC))
    {
        return;
    }

    SetLocalString(oNPC, DL2_L_NPC_SLEEP_APPROACH_TAG, sApproachTag);
    SetLocalString(oNPC, DL2_L_NPC_SLEEP_BED_TAG, sBedTag);
    SetLocalInt(oNPC, DL2_L_NPC_SLEEP_MODE, DL2_SLEEP_MODE_NONE);
}

object DL2_GetNpcSleepApproachWaypoint(object oNPC)
{
    return DL2_GetWaypointByTagStrict(GetLocalString(oNPC, DL2_L_NPC_SLEEP_APPROACH_TAG));
}

object DL2_GetNpcSleepBedWaypoint(object oNPC)
{
    return DL2_GetWaypointByTagStrict(GetLocalString(oNPC, DL2_L_NPC_SLEEP_BED_TAG));
}

int DL2_IsNpcSleepAnchorPairValid(object oNPC)
{
    object oApproach = DL2_GetNpcSleepApproachWaypoint(oNPC);
    object oBed = DL2_GetNpcSleepBedWaypoint(oNPC);

    if (!GetIsObjectValid(oApproach) || !GetIsObjectValid(oBed))
    {
        return FALSE;
    }

    return GetArea(oApproach) == GetArea(oBed);
}

#endif
