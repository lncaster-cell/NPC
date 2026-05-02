void DL_CR_ClearPursuitState(object oPc);

const string DL_L_PC_LG_CASE_STATE = "dl_lg_case_state";
const string DL_L_PC_LG_CASE_KIND = "dl_lg_case_kind";
const string DL_L_PC_LG_CASE_SEVERITY = "dl_lg_case_severity";
const string DL_L_PC_LG_CASE_OPEN_ABS_MIN = "dl_lg_case_open_abs_min";
const string DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN = "dl_lg_case_last_update_abs_min";
const string DL_L_PC_LG_CASE_RESOLUTION = "dl_lg_case_resolution";
const string DL_L_PC_LG_CASE_FINE = "dl_lg_case_fine";

const string DL_L_PC_LG_LAST_WITNESS_TAG = "dl_lg_last_witness_tag";
const string DL_L_PC_LG_LAST_WITNESSED_KIND = "dl_lg_last_witnessed_kind";
const string DL_L_PC_LG_LAST_WITNESSED_AREA = "dl_lg_last_witnessed_area";
const string DL_L_PC_LG_LAST_WITNESSED_ABS_MIN = "dl_lg_last_witnessed_abs_min";

const int DL_LG_CASE_STATE_NONE = 0;
const int DL_LG_CASE_STATE_ACTIVE = 1;
const int DL_LG_CASE_STATE_DETAINED = 2;
const int DL_LG_CASE_STATE_RESOLVED = 3;
const string DL_L_MODULE_LG_DEFAULT_FINE = "dl_lg_default_fine";

int DL_LG_GetDefaultFine()
{
    int nFine = GetLocalInt(GetModule(), DL_L_MODULE_LG_DEFAULT_FINE);
    if (nFine <= 0)
    {
        return 100;
    }
    return nFine;
}

int DL_LG_GetSeverityByKind(string sKind)
{
    if (sKind == DL_LG_CASE_KIND_KILL)
    {
        return 5;
    }
    if (sKind == DL_LG_CASE_KIND_ATTACK)
    {
        return 3;
    }
    if (sKind == DL_LG_CASE_KIND_DOOR_LOCKPICK || sKind == DL_LG_CASE_KIND_RESTRICTED_ENTRY)
    {
        return 3;
    }
    if (sKind == DL_LG_CASE_KIND_CONTAINER_THEFT || sKind == DL_LG_CASE_KIND_PICKPOCKET || sKind == DL_LG_CASE_KIND_PLACEABLE_LOCKPICK)
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
        DeleteLocalString(oOffender, DL_L_PC_LG_CASE_RESOLUTION);
        DeleteLocalInt(oOffender, DL_L_PC_LG_CASE_FINE);
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
        SetLocalInt(oOffender, DL_L_PC_LG_CASE_SEVERITY, 0);
        DeleteLocalString(oOffender, DL_L_PC_LG_CASE_RESOLUTION);
        DeleteLocalInt(oOffender, DL_L_PC_LG_CASE_FINE);
    }

    SetLocalString(oOffender, DL_L_PC_LG_CASE_KIND, DL_LG_CASE_KIND_DETAIN_REFUSAL);
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

    if (nFine <= 0)
    {
        nFine = DL_LG_GetDefaultFine();
    }

    DL_CR_ClearPursuitState(oOffender);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_RESOLVED);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, DL_GetAbsoluteMinute());
    SetLocalString(oOffender, DL_L_PC_LG_CASE_RESOLUTION, DL_LG_CASE_RESOLUTION_FINE);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_FINE, nFine);

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

    DL_CR_ClearPursuitState(oOffender);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_STATE, DL_LG_CASE_STATE_RESOLVED);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN, DL_GetAbsoluteMinute());
    SetLocalString(oOffender, DL_L_PC_LG_CASE_RESOLUTION, DL_LG_CASE_RESOLUTION_DETAIN_COMPLETE);
    SetLocalInt(oOffender, DL_L_PC_LG_CASE_FINE, 0);
}
