// Daily Life v2 smoke Step 02.
// Verifies module contract/bootstrap initialization.

#include "dl_v2_bootstrap_inc"

void DL2_EnableSmokeTraceForTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

void main()
{
    object oModule = GetModule();

    DL2_EnableSmokeTraceForTest();

    DeleteLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION);
    DeleteLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET);
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, FALSE);
    DL2_InitModuleContract();

    DL2_LogSmoke(
        "STEP02",
        "contract_initialized",
        TRUE,
        DL2_IsModuleContractInitialized()
    );

    DL2_LogSmoke(
        "STEP02",
        "default_budget_applied",
        DL2_DEFAULT_WORKER_BUDGET,
        GetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET)
    );

    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, TRUE);
    DeleteLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION);
    SetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET, 1);
    DL2_InitModuleContract();

    DL2_LogSmoke(
        "STEP02",
        "enabled_preserved",
        TRUE,
        GetLocalInt(oModule, DL2_L_MODULE_ENABLED)
    );

    DL2_LogSmoke(
        "STEP02",
        "budget_repaired",
        DL2_DEFAULT_WORKER_BUDGET,
        GetLocalInt(oModule, DL2_L_AREA_WORKER_BUDGET)
    );
}
