// Step 05+: resolver/materialization skeleton.
// Scope: EARLY_WORKER sleep window + basic BLACKSMITH A/B window split.

const string DL_L_NPC_DIRECTIVE = "dl_npc_directive";
const string DL_L_NPC_MAT_REQ = "dl_npc_mat_req";
const string DL_L_NPC_MAT_TAG = "dl_npc_mat_tag";
const string DL_L_NPC_DIALOGUE_MODE = "dl_npc_dialogue_mode";
const string DL_L_NPC_SERVICE_MODE = "dl_npc_service_mode";

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

    if (GetLocalString(oNpc, "dl_profile_id") == "early_worker")
    {
        if (DL_IsEarlyWorkerSleepHour(nHour))
        {
            return DL_DIR_SLEEP;
        }
    }
    else if (GetLocalString(oNpc, "dl_profile_id") == "blacksmith")
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
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, "sleep");
        return;
    }

    if (nDirective == DL_DIR_WORK)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, "work");
        return;
    }

    if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, "social");
        return;
    }

    DeleteLocalInt(oNpc, DL_L_NPC_MAT_REQ);
    DeleteLocalString(oNpc, DL_L_NPC_MAT_TAG);
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
        SetLocalString(oNpc, "dl_state", "sleep");
        SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, "sleep");
        SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, "off");
    }
    else if (nDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, "dl_state", "work");
        SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, "work");
        SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, "available");
    }
    else if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalString(oNpc, "dl_state", "social");
        SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, "social");
        SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, "off");
    }
    else if (GetLocalString(oNpc, "dl_state") == "")
    {
        SetLocalString(oNpc, "dl_state", "idle");
        SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, "idle");
        SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, "off");
    }

    DL_ApplyMaterializationSkeleton(oNpc, nDirective);
}
