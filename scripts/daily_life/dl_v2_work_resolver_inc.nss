#ifndef DL_V2_WORK_RESOLVER_INC_NSS
#define DL_V2_WORK_RESOLVER_INC_NSS

#include "dl_v2_resolver_inc"

// Minimal WORK directive slice for EARLY_WORKER.
// Current owner-approved window: 08:00 -> 18:00.

const int DL2_DIRECTIVE_WORK = 2;

const int DL2_SCHEDULE_EARLY_WORKER_WORK_START_HOUR = 8;
const int DL2_SCHEDULE_EARLY_WORKER_WORK_END_HOUR = 18;

int DL2_ResolveDirectiveWorkOnly(int nHour, int nWorkStartHour, int nWorkEndHour)
{
    if (DL2_IsHourInWindow(nHour, nWorkStartHour, nWorkEndHour))
    {
        return DL2_DIRECTIVE_WORK;
    }

    return DL2_DIRECTIVE_UNASSIGNED;
}

int DL2_ResolveDirectiveForEarlyWorkerWork(int nHour)
{
    return DL2_ResolveDirectiveWorkOnly(
        nHour,
        DL2_SCHEDULE_EARLY_WORKER_WORK_START_HOUR,
        DL2_SCHEDULE_EARLY_WORKER_WORK_END_HOUR
    );
}

int DL2_ResolveDirectiveForEarlyWorkerBasic(int nHour)
{
    int nSleepDirective = DL2_ResolveDirectiveForEarlyWorkerSleep(nHour);
    if (nSleepDirective == DL2_DIRECTIVE_SLEEP)
    {
        return nSleepDirective;
    }

    return DL2_ResolveDirectiveForEarlyWorkerWork(nHour);
}

string DL2_GetBasicDirectiveName(int nDirective)
{
    if (nDirective == DL2_DIRECTIVE_WORK)
    {
        return "WORK";
    }

    return DL2_GetDirectiveName(nDirective);
}

#endif
