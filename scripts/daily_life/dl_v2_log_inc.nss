#ifndef DL_V2_LOG_INC_NSS
#define DL_V2_LOG_INC_NSS

#include "dl_v2_contract_inc"

const string DL2_L_MODULE_LOG_ENABLED = "dl2_log_enabled";
const string DL2_L_MODULE_SMOKE_TRACE = "dl2_smoke_trace";
const string DL2_L_MODULE_LOG_LEVEL = "dl2_log_level";

const int DL2_LOG_LEVEL_OFF = 0;
const int DL2_LOG_LEVEL_ERROR = 1;
const int DL2_LOG_LEVEL_WARN = 2;
const int DL2_LOG_LEVEL_INFO = 3;
const int DL2_LOG_LEVEL_DEBUG = 4;

int DL2_GetLogLevel()
{
    int nLevel = GetLocalInt(GetModule(), DL2_L_MODULE_LOG_LEVEL);
    if (nLevel < DL2_LOG_LEVEL_OFF || nLevel > DL2_LOG_LEVEL_DEBUG)
    {
        return DL2_LOG_LEVEL_OFF;
    }

    return nLevel;
}

int DL2_IsLogEnabled()
{
    object oModule = GetModule();
    return GetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED) == TRUE
        && DL2_GetLogLevel() > DL2_LOG_LEVEL_OFF;
}

int DL2_IsSmokeTraceEnabled()
{
    object oModule = GetModule();
    return DL2_IsLogEnabled() && GetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE) == TRUE;
}

void DL2_EmitChatLog(string sChannel, string sScope, string sMessage)
{
    object oPC = GetFirstPC();
    if (!GetIsObjectValid(oPC))
    {
        return;
    }

    SendMessageToPC(oPC, "[DL2][" + sChannel + "][" + sScope + "] " + sMessage);
}

void DL2_LogError(string sScope, string sMessage)
{
    if (!DL2_IsLogEnabled() || DL2_GetLogLevel() < DL2_LOG_LEVEL_ERROR)
    {
        return;
    }

    DL2_EmitChatLog("ERROR", sScope, sMessage);
}

void DL2_LogWarn(string sScope, string sMessage)
{
    if (!DL2_IsLogEnabled() || DL2_GetLogLevel() < DL2_LOG_LEVEL_WARN)
    {
        return;
    }

    DL2_EmitChatLog("WARN", sScope, sMessage);
}

void DL2_LogInfo(string sScope, string sMessage)
{
    if (!DL2_IsLogEnabled() || DL2_GetLogLevel() < DL2_LOG_LEVEL_INFO)
    {
        return;
    }

    DL2_EmitChatLog("INFO", sScope, sMessage);
}

void DL2_LogSmoke(string sScope, string sCaseId, int bExpected, int bActual)
{
    if (!DL2_IsSmokeTraceEnabled())
    {
        return;
    }

    string sVerdict = bExpected == bActual ? "PASS" : "FAIL";
    DL2_EmitChatLog(
        "SMOKE",
        sScope,
        "[" + sVerdict + "] " + sCaseId
            + " expected=" + IntToString(bExpected)
            + " actual=" + IntToString(bActual)
    );
}

#endif
