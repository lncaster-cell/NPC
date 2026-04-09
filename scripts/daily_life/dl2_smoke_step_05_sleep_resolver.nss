// Daily Life v2 smoke Step 05.
// Verifies sleep-only resolver for EARLY_WORKER schedule.

#include "dl_v2_resolver_inc"

void DL2_EnableSmokeTraceForResolverTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

void DL2_LogDirectiveCase(string sCaseId, int nExpectedDirective, int nActualDirective)
{
    DL2_LogSmoke("STEP05", sCaseId, nExpectedDirective, nActualDirective);
}

void main()
{
    DL2_EnableSmokeTraceForResolverTest();

    DL2_LogDirectiveCase(
        "early_worker_05_sleep",
        DL2_DIRECTIVE_SLEEP,
        DL2_ResolveDirectiveForEarlyWorkerSleep(5)
    );

    DL2_LogDirectiveCase(
        "early_worker_06_wake",
        DL2_DIRECTIVE_UNASSIGNED,
        DL2_ResolveDirectiveForEarlyWorkerSleep(6)
    );

    DL2_LogDirectiveCase(
        "early_worker_21_awake",
        DL2_DIRECTIVE_UNASSIGNED,
        DL2_ResolveDirectiveForEarlyWorkerSleep(21)
    );

    DL2_LogDirectiveCase(
        "early_worker_22_sleep",
        DL2_DIRECTIVE_SLEEP,
        DL2_ResolveDirectiveForEarlyWorkerSleep(22)
    );

    DL2_LogDirectiveCase(
        "early_worker_23_sleep",
        DL2_DIRECTIVE_SLEEP,
        DL2_ResolveDirectiveForEarlyWorkerSleep(23)
    );
}
