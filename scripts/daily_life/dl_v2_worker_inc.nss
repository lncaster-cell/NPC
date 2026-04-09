#ifndef DL_V2_WORKER_INC_NSS
#define DL_V2_WORKER_INC_NSS

#include "dl_v2_registry_inc"

int DL2_GetAreaWorkerBudget(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return DL2_DEFAULT_WORKER_BUDGET;
    }

    int nBudget = GetLocalInt(oArea, DL2_L_AREA_WORKER_BUDGET);
    if (nBudget < 1)
    {
        return DL2_DEFAULT_WORKER_BUDGET;
    }

    return nBudget;
}

int DL2_GetAreaWorkerCursor(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    int nCursor = GetLocalInt(oArea, DL2_L_AREA_WORKER_CURSOR);
    if (nCursor < 0)
    {
        return 0;
    }

    return nCursor;
}

void DL2_SetAreaWorkerCursor(object oArea, int nCursor)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (nCursor < 0)
    {
        nCursor = 0;
    }

    SetLocalInt(oArea, DL2_L_AREA_WORKER_CURSOR, nCursor);
}

int DL2_CountRuntimeCandidatesInArea(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    int nCount = 0;
    object oCurrent = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oCurrent))
    {
        if (DL2_IsRuntimeNpcCandidate(oCurrent))
        {
            nCount++;
        }

        oCurrent = GetNextObjectInArea(oArea);
    }

    return nCount;
}

object DL2_GetRuntimeCandidateByIndex(object oArea, int nTargetIndex)
{
    if (!GetIsObjectValid(oArea) || nTargetIndex < 0)
    {
        return OBJECT_INVALID;
    }

    int nIndex = 0;
    object oCurrent = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oCurrent))
    {
        if (DL2_IsRuntimeNpcCandidate(oCurrent))
        {
            if (nIndex == nTargetIndex)
            {
                return oCurrent;
            }
            nIndex++;
        }

        oCurrent = GetNextObjectInArea(oArea);
    }

    return OBJECT_INVALID;
}

object DL2_GetNextRuntimeCandidateForWorker(object oArea)
{
    int nCount = DL2_CountRuntimeCandidatesInArea(oArea);
    if (nCount < 1)
    {
        DL2_SetAreaWorkerCursor(oArea, 0);
        return OBJECT_INVALID;
    }

    int nCursor = DL2_GetAreaWorkerCursor(oArea);
    if (nCursor >= nCount)
    {
        nCursor = 0;
    }

    object oCandidate = DL2_GetRuntimeCandidateByIndex(oArea, nCursor);
    DL2_SetAreaWorkerCursor(oArea, (nCursor + 1) % nCount);

    if (GetIsObjectValid(oCandidate))
    {
        DL2_EnsureNpcRegistered(oCandidate);
    }

    return oCandidate;
}

#endif
