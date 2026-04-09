#ifndef DL_V2_RESOLVER_INC_NSS
#define DL_V2_RESOLVER_INC_NSS

#include "dl_v2_worker_inc"

// Minimal directive layer for the first resolver slice.
// Current scope: sleep-only directive resolution.

const int DL2_DIRECTIVE_UNASSIGNED = 0;
const int DL2_DIRECTIVE_SLEEP = 1;

const int DL2_SCHEDULE_EARLY_WORKER_SLEEP_START_HOUR = 22;
const int DL2_SCHEDULE_EARLY_WORKER_SLEEP_END_HOUR = 6;

int DL2_IsValidHour(int nHour)
{
    return nHour >= 0 && nHour <= 23;
}

string DL2_GetDirectiveName(int nDirective)
{
    switch (nDirective)
    {
        case DL2_DIRECTIVE_SLEEP:
            return "SLEEP";
    }

    return "UNASSIGNED";
}

int DL2_IsHourInWindow(int nHour, int nStartHour, int nEndHour)
{
    if (!DL2_IsValidHour(nHour) || !DL2_IsValidHour(nStartHour) || !DL2_IsValidHour(nEndHour))
    {
        return FALSE;
    }

    if (nStartHour == nEndHour)
    {
        return nHour == nStartHour;
    }

    if (nStartHour < nEndHour)
    {
        return nHour >= nStartHour && nHour < nEndHour;
    }

    return nHour >= nStartHour || nHour < nEndHour;
}

int DL2_ResolveDirectiveSleepOnly(int nHour, int nSleepStartHour, int nSleepEndHour)
{
    if (DL2_IsHourInWindow(nHour, nSleepStartHour, nSleepEndHour))
    {
        return DL2_DIRECTIVE_SLEEP;
    }

    return DL2_DIRECTIVE_UNASSIGNED;
}

int DL2_ResolveDirectiveForEarlyWorkerSleep(int nHour)
{
    return DL2_ResolveDirectiveSleepOnly(
        nHour,
        DL2_SCHEDULE_EARLY_WORKER_SLEEP_START_HOUR,
        DL2_SCHEDULE_EARLY_WORKER_SLEEP_END_HOUR
    );
}

#endif
