// Daily Life v2 smoke Step 06.
// Verifies work-only resolver for EARLY_WORKER schedule.

#include "dl_v2_work_resolver_inc"

void DL2_EnableSmokeTraceForWorkResolverTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

void DL2_LogWorkDirectiveCase(string sCaseId, int nExpectedDirective, int nActualDirective)
{
    DL2_LogSmoke("STEP06", sCaseId, nExpectedDirective, nActualDirective);
}

void main()
{
    DL2_EnableSmokeTraceForWorkResolverTest();

    DL2_LogWorkDirectiveCase(
        "early_worker_07_unassigned",
        DL2_DIRECTIVE_UNASSIGNED,
        DL2_ResolveDirectiveForEarlyWorkerWork(7)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_08_work",
        DL2_DIRECTIVE_WORK,
        DL2_ResolveDirectiveForEarlyWorkerWork(8)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_12_work",
        DL2_DIRECTIVE_WORK,
        DL2_ResolveDirectiveForEarlyWorkerWork(12)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_17_work",
        DL2_DIRECTIVE_WORK,
        DL2_ResolveDirectiveForEarlyWorkerWork(17)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_18_unassigned",
        DL2_DIRECTIVE_UNASSIGNED,
        DL2_ResolveDirectiveForEarlyWorkerWork(18)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_basic_05_sleep",
        DL2_DIRECTIVE_SLEEP,
        DL2_ResolveDirectiveForEarlyWorkerBasic(5)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_basic_09_work",
        DL2_DIRECTIVE_WORK,
        DL2_ResolveDirectiveForEarlyWorkerBasic(9)
    );

    DL2_LogWorkDirectiveCase(
        "early_worker_basic_19_unassigned",
        DL2_DIRECTIVE_UNASSIGNED,
        DL2_ResolveDirectiveForEarlyWorkerBasic(19)
    );
}
