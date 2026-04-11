// Step 05+: resolver/materialization skeleton.
// Scope: EARLY_WORKER sleep window + basic BLACKSMITH A/B window split.

const string DL_L_NPC_DIRECTIVE = "dl_npc_directive";
const string DL_L_NPC_MAT_REQ = "dl_npc_mat_req";
const string DL_L_NPC_MAT_TAG = "dl_npc_mat_tag";
const string DL_L_NPC_DIALOGUE_MODE = "dl_npc_dialogue_mode";
const string DL_L_NPC_SERVICE_MODE = "dl_npc_service_mode";
const string DL_L_NPC_PROFILE_ID = "dl_profile_id";
const string DL_L_NPC_STATE = "dl_state";

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
    }
    else if (nDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_WORK);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_WORK, DL_SERVICE_AVAILABLE);
    }
    else if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SOCIAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SOCIAL, DL_SERVICE_OFF);
    }
    else
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_IDLE);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
    }

    DL_ApplyMaterializationSkeleton(oNpc, nDirective);
}
