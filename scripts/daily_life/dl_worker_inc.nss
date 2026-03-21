#ifndef DL_WORKER_INC_NSS
#define DL_WORKER_INC_NSS

#include "dl_const_inc"
#include "dl_area_inc"
#include "dl_resync_inc"

int DL_GetWorkerBudget(object oArea)
{
    return DL_GetDefaultAreaTierBudget(DL_GetAreaTier(oArea));
}

void DL_ProcessNpcBudgeted(object oArea, object oNPC)
{
    int nReason = GetLocalInt(oNPC, DL_L_RESYNC_REASON);
    if (nReason == DL_RESYNC_NONE)
    {
        nReason = DL_RESYNC_WORKER;
    }
    DL_RunResync(oNPC, oArea, nReason);
}

void DL_DispatchDueJobs(object oArea, int nBudget)
{
    object oObject = GetFirstObjectInArea(oArea);
    int nProcessed = 0;

    while (GetIsObjectValid(oObject) && nProcessed < nBudget)
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            DL_ProcessNpcBudgeted(oArea, oObject);
            nProcessed += 1;
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void DL_AreaWorkerTick(object oArea)
{
    if (!DL_ShouldRunDailyLife(oArea))
    {
        return;
    }
    DL_DispatchDueJobs(oArea, DL_GetWorkerBudget(oArea));
}

#endif
