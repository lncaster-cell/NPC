// Daily Life centralized configuration access layer.

const float DL_CFG_CR_WITNESS_RADIUS_DEFAULT = 10.0;
const float DL_CFG_CR_GUARD_ALERT_RADIUS_DEFAULT = 20.0;
const int DL_CFG_CR_GUARD_RESPONDERS_MAX_DEFAULT = 2;
const string DL_CFG_CR_JAIL_WP_TAG_DEFAULT = "dl_jail_entry_wp";
const string DL_CFG_CR_DETAIN_DIALOG_DEFAULT = "dl_cr_guard_detain";

const int DL_CFG_TRANSITION_DRIVER_LOOKUP_CAP_DEFAULT = 4;
const int DL_CFG_TRANSITION_DRIVER_LOOKUP_CAP_MIN = 1;
const int DL_CFG_TRANSITION_DRIVER_LOOKUP_CAP_MAX = 16;

const string DL_L_MODULE_CFG_FALLBACK_COUNT = "dl_cfg_fallback_count";
const string DL_L_MODULE_CFG_INVALID_COUNT = "dl_cfg_invalid_count";

void DL_RecordConfigFallback(string sKey, string sReason)
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL_L_MODULE_CFG_FALLBACK_COUNT, GetLocalInt(oModule, DL_L_MODULE_CFG_FALLBACK_COUNT) + 1);
    if (sReason != "")
    {
        SetLocalInt(oModule, DL_L_MODULE_CFG_INVALID_COUNT, GetLocalInt(oModule, DL_L_MODULE_CFG_INVALID_COUNT) + 1);
    }

    if (DL_IsRuntimeLogEnabled())
    {
        DL_LogRuntime("[DL][CFG] fallback key=" + sKey + (sReason == "" ? "" : " reason=" + sReason));
    }
}

int DL_GetConfigInt(string sKey, int nDefault, int nMin = -2147483647, int nMax = 2147483647)
{
    int nRaw = GetLocalInt(GetModule(), sKey);
    if (nRaw < nMin || nRaw > nMax)
    {
        DL_RecordConfigFallback(sKey, "out_of_range");
        return nDefault;
    }
    if (nRaw == 0 && nMin > 0)
    {
        DL_RecordConfigFallback(sKey, "empty_or_zero");
        return nDefault;
    }
    return nRaw;
}

float DL_GetConfigFloat(string sKey, float fDefault, float fMinExclusive = 0.0, float fMax = 1000000.0)
{
    float fRaw = GetLocalFloat(GetModule(), sKey);
    if (fRaw > fMinExclusive && fRaw <= fMax)
    {
        return fRaw;
    }

    int nLegacyRaw = GetLocalInt(GetModule(), sKey);
    if (nLegacyRaw > fMinExclusive && IntToFloat(nLegacyRaw) <= fMax)
    {
        return IntToFloat(nLegacyRaw);
    }

    DL_RecordConfigFallback(sKey, "empty_or_invalid_float");
    return fDefault;
}

string DL_GetConfigString(string sKey, string sDefault)
{
    string sRaw = GetLocalString(GetModule(), sKey);
    if (sRaw == "")
    {
        DL_RecordConfigFallback(sKey, "empty_string");
        return sDefault;
    }
    return sRaw;
}
