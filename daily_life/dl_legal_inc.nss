const string DL_L_PC_LG_CASE_STATE = "dl_lg_case_state";
const string DL_L_PC_LG_CASE_KIND = "dl_lg_case_kind";
const string DL_L_PC_LG_CASE_SEVERITY = "dl_lg_case_severity";
const string DL_L_PC_LG_CASE_OPEN_ABS_MIN = "dl_lg_case_open_abs_min";
const string DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN = "dl_lg_case_last_update_abs_min";

const string DL_L_PC_LG_LAST_WITNESS_TAG = "dl_lg_last_witness_tag";
const string DL_L_PC_LG_LAST_WITNESSED_KIND = "dl_lg_last_witnessed_kind";
const string DL_L_PC_LG_LAST_WITNESSED_AREA = "dl_lg_last_witnessed_area";
const string DL_L_PC_LG_LAST_WITNESSED_ABS_MIN = "dl_lg_last_witnessed_abs_min";

const int DL_LG_CASE_STATE_NONE = 0;
const int DL_LG_CASE_STATE_ACTIVE = 1;
const int DL_LG_CASE_STATE_DETAINED = 2;
const int DL_LG_CASE_STATE_RESOLVED = 3;

int DL_LG_GetSeverityByKind(string sKind)
{
    if (sKind == "kill")
    {
        return 5;
    }
    if (sKind == "attack")
    {
        return 3;
    }
    if (sKind == "door_lockpick" || sKind == "restricted_entry")
    {
        return 3;
    }
    if (sKind == "container_theft" || sKind == "pickpocket" || sKind == "placeable_lockpick")
    {
        return 2;
    }
    return 1;
}

void DL_LG_OnWitnessedIncident(object oOffender, string sKind, object oArea, object oWitness)
{
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nState = GetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE);

    if (nState == DL_LG_CASE_STATE_NONE || nState == DL_LG_CASE_STATE_RESOLVED)
    {
        SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_ACTIVE);
        SetLocalInt(oOffender, DL_L_PC_LG_CASE_OPEN_ABS_MIN, nNowAbsMin);
        SetLocalInt(oOffender, DL_L_PC_LG_CASE_SEVERITY, 0);
    }

    SetLocalString(oOffender, DL_L_PC_LG_CASE_KIND, sKind);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_SEVERITY,
        GetLocalInt(oOffender, DL_L_PC_LG_CASE_SEVERITY) + DL_LG_GetSeverityByKind(sKind));
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, nNowAbsMin);

    SetLocalString(oOffender, DL_L_PC_LG_LAST_WITNESSED_KIND, sKind);
    SetLocalInt(oOffender, DL_L_PC_LG_LAST_WITNESSED_ABS_MIN, nNowAbsMin);
    if (GetIsObjectValid(oArea))
    {
        SetLocalString(oOffender, DL_L_PC_LG_LAST_WITNESSED_AREA, GetTag(oArea));
    }
    if (GetIsObjectValid(oWitness))
    {
        SetLocalString(oOffender, DL_L_PC_LG_LAST_WITNESS_TAG, GetTag(oWitness));
    }
}

void DL_LG_OnDetained(object oOffender, object oGuard)
{
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_DETAINED);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, DL_GetAbsoluteMinute());

    if (GetIsObjectValid(oGuard))
    {
        SetLocalString(oOffender, DL_L_PC_LG_LAST_WITNESS_TAG, GetTag(oGuard));
    }
}

void DL_LG_OnRefusedDetain(object oOffender, object oGuard)
{
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nState = GetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE);
    if (nState == DL_LG_CASE_STATE_NONE || nState == DL_LG_CASE_STATE_RESOLVED)
    {
        SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_ACTIVE);
        SetLocalInt(oOffender, DL_L_PC_LG_CASE_OPEN_ABS_MIN, nNowAbsMin);
    }

    SetLocalInt(oOffender, DL_L_PC_LG_CASE_SEVERITY,
        GetLocalInt(oOffender, DL_L_PC_LG_CASE_SEVERITY) + 1);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, nNowAbsMin);

    if (GetIsObjectValid(oGuard))
    {
        SetLocalString(oOffender, DL_L_PC_LG_LAST_WITNESS_TAG, GetTag(oGuard));
    }
}

void DL_LG_ResolveCaseFine(object oOffender, int nFine)
{
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_RESOLVED);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, DL_GetAbsoluteMinute());

    if (nFine > 0)
    {
        SendMessageToPC(oOffender, "[DL][LEGAL] Штраф назначен: " + IntToString(nFine));
    }
}

void DL_LG_ResolveCaseDetainComplete(object oOffender)
{
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_RESOLVED);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, DL_GetAbsoluteMinute());
}
