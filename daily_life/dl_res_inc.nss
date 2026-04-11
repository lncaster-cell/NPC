// Step 05+: resolver/materialization skeleton.
// Scope: EARLY_WORKER sleep window + basic BLACKSMITH A/B window split.

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

const string DL_PROFILE_EARLY_WORKER = "early_worker";
const string DL_PROFILE_BLACKSMITH = "blacksmith";

const string DL_STATE_IDLE = "idle";
const string DL_STATE_SLEEP = "sleep";
const string DL_STATE_WORK = "work";
const string DL_STATE_SOCIAL = "social";

const string DL_DIALOGUE_IDLE = "idle";
const string DL_DIALOGUE_SLEEP = "sleep";
const string DL_DIALOGUE_WORK = "work";
const string DL_DIALOGUE_SOCIAL = "social";

const string DL_SERVICE_OFF = "off";
const string DL_SERVICE_AVAILABLE = "available";

const string DL_MAT_SLEEP = "sleep";
const string DL_MAT_WORK = "work";
const string DL_MAT_SOCIAL = "social";

const int DL_DIR_NONE = 0;
const int DL_DIR_SLEEP = 1;
const int DL_DIR_WORK = 2;
const int DL_DIR_SOCIAL = 3;
const int DL_SLEEP_PHASE_NONE = 0;
const int DL_SLEEP_PHASE_MOVING = 1;
const int DL_SLEEP_PHASE_ON_BED = 2;

const float DL_SLEEP_APPROACH_RADIUS = 1.50;
const float DL_SLEEP_BED_RADIUS = 1.10;

int DL_NormalizeHour(int nHour)
{
    while (nHour < 0)
    {
        nHour = nHour + 24;
    }
    while (nHour > 23)
    {
        nHour = nHour - 24;
    }
    return nHour;
}

int DL_IsEarlyWorkerSleepHour(int nHour)
{
    nHour = DL_NormalizeHour(nHour);
    return nHour >= 22 || nHour < 6;
}

int DL_IsBlacksmithWorkHour(int nHour)
{
    nHour = DL_NormalizeHour(nHour);
    return nHour >= 8 && nHour < 18;
}

int DL_ResolveNpcDirectiveAtHour(object oNpc, int nHour)
{
    if (!GetIsObjectValid(oNpc))
    {
        return DL_DIR_NONE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) == DL_PROFILE_EARLY_WORKER)
    {
        if (DL_IsEarlyWorkerSleepHour(nHour))
        {
            return DL_DIR_SLEEP;
        }
    }
    else if (GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) == DL_PROFILE_BLACKSMITH)
    {
        if (DL_IsEarlyWorkerSleepHour(nHour))
        {
            return DL_DIR_SLEEP;
        }

        if (DL_IsBlacksmithWorkHour(nHour))
        {
            return DL_DIR_WORK;
        }
        return DL_DIR_SOCIAL;
    }

    return DL_DIR_NONE;
}

int DL_ResolveNpcDirective(object oNpc)
{
    return DL_ResolveNpcDirectiveAtHour(oNpc, GetTimeHour());
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

    DeleteLocalInt(oNpc, DL_L_NPC_MAT_REQ);
    DeleteLocalString(oNpc, DL_L_NPC_MAT_TAG);
}

object DL_GetSleepWaypointByTag(string sTag)
{
    if (sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oWp = GetWaypointByTag(sTag);
    if (!GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    return oWp;
}

object DL_ResolveSleepApproachWaypoint(object oNpc)
{
    string sNpcTag = GetTag(oNpc);
    object oWp = DL_GetSleepWaypointByTag("dl_sleep_" + sNpcTag + "_approach");
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_GetSleepWaypointByTag("dl_sleep_approach");
}

object DL_ResolveSleepBedWaypoint(object oNpc)
{
    string sNpcTag = GetTag(oNpc);
    object oWp = DL_GetSleepWaypointByTag("dl_sleep_" + sNpcTag + "_bed");
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_GetSleepWaypointByTag("dl_sleep_bed");
}

void DL_ClearSleepExecutionState(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
}

void DL_ExecuteSleepDirective(object oNpc)
{
    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    object oBed = DL_ResolveSleepBedWaypoint(oNpc);

    if (!GetIsObjectValid(oApproach) || !GetIsObjectValid(oBed))
    {
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "missing_waypoints");
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, GetTag(oBed));

    location lApproach = GetLocation(oApproach);
    location lBed = GetLocation(oBed);

    if (GetDistanceBetweenLocations(GetLocation(oNpc), lApproach) > DL_SLEEP_APPROACH_RADIUS)
    {
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "moving_to_approach");
        AssignCommand(oNpc, ClearAllActions(TRUE));
        AssignCommand(oNpc, ActionMoveToLocation(lApproach, TRUE));
        return;
    }

    if (GetDistanceBetweenLocations(GetLocation(oNpc), lBed) > DL_SLEEP_BED_RADIUS)
    {
        AssignCommand(oNpc, ClearAllActions(TRUE));
        AssignCommand(oNpc, ActionJumpToLocation(lBed));
    }

    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "on_bed");
}

void DL_SetInteractionModes(object oNpc, string sDialogue, string sService)
{
    SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, sDialogue);
    SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, sService);
}

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DIRECTIVE, nDirective);

    if (nDirective == DL_DIR_SLEEP)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SLEEP);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SLEEP, DL_SERVICE_OFF);
        DL_ExecuteSleepDirective(oNpc);
    }
    else if (nDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_WORK);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_WORK, DL_SERVICE_AVAILABLE);
        DL_ClearSleepExecutionState(oNpc);
    }
    else if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SOCIAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SOCIAL, DL_SERVICE_OFF);
        DL_ClearSleepExecutionState(oNpc);
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_IDLE);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ClearSleepExecutionState(oNpc);
    }

    DL_ApplyMaterializationSkeleton(oNpc, nDirective);
}
