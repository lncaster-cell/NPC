#ifndef DL_V2_BOOTSTRAP_INC_NSS
#define DL_V2_BOOTSTRAP_INC_NSS

#include "dl_v2_log_inc"

int DL2_IsModuleContractInitialized()
{
    object oModule = GetModule();
    if (GetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION) != DL2_CONTRACT_VERSION_A0)
    {
        return FALSE;
    }

    return GetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET) >= DL2_DEFAULT_WORKER_BUDGET;
}

void DL2_InitModuleContract()
{
    object oModule = GetModule();
    int nEnabled = GetLocalInt(oModule, DL2_L_MODULE_ENABLED) == TRUE ? TRUE : FALSE;
    int nLogEnabled = GetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED) == TRUE ? TRUE : FALSE;
    int nSmokeTrace = GetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE) == TRUE ? TRUE : FALSE;
    int nLogLevel = DL2_GetLogLevel();
    int nWorkerBudget = GetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET);

    SetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION, DL2_CONTRACT_VERSION_A0);
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, nEnabled);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, nLogEnabled);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, nSmokeTrace);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, nLogLevel);

    if (nWorkerBudget < DL2_DEFAULT_WORKER_BUDGET)
    {
        nWorkerBudget = DL2_DEFAULT_WORKER_BUDGET;
    }
    SetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET, nWorkerBudget);

    DL2_LogInfo(
        "BOOTSTRAP",
        "contract_version=" + GetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION)
            + " enabled=" + IntToString(GetLocalInt(oModule, DL2_L_MODULE_ENABLED))
            + " budget=" + IntToString(GetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET))
    );
}

#endif
