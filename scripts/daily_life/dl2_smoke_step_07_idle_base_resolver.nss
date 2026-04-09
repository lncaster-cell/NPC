// Daily Life v2 smoke Step 07.
// Verifies IDLE_BASE fallback after SLEEP and WORK.

#include "dl_v2_idle_base_resolver_inc"

void DL2_EnableSmokeTraceForIdleBaseTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

void DL2_LogIdleCase(string sCaseId, int nExpectedDirective, int nActualDirective)
{
    DL2_LogSmoke("STEP07", sCaseId, nExpectedDirective, nActualDirective);
}

void main()
{
    DL2_EnableSmokeTraceForIdleBaseTest();

    DL2_LogIdleCase(
        "early_worker_05_sleep",
        DL2_DIRECTIVE_SLEEP,
        DL2_ResolveDirectiveForEarlyWorkerBasicWithIdleBase(5)
    );

    DL2_LogIdleCase(
        "early_worker_09_work",
        DL2_DIRECTIVE_WORK,
        DL2_ResolveDirectiveForEarlyWorkerBasicWithIdleBase(9)
    );

    DL2_LogIdleCase(
        "early_worker_19_idle",
        DL2_DIRECTIVE_IDLE_BASE,
        DL2_ResolveDirectiveForEarlyWorkerBasicWithIdleBase(19)
    );

    DL2_LogIdleCase(
        "early_worker_21_idle",
        DL2_DIRECTIVE_IDLE_BASE,
        DL2_ResolveDirectiveForEarlyWorkerBasicWithIdleBase(21)
    );
}
