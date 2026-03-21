#ifndef AL_V1_WORKER_INC_NSS
#define AL_V1_WORKER_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_area_inc"
#include "al_v1_resync_inc"

int DLV1_GetWorkerBudget(object oArea)
{
    return DLV1_GetDefaultAreaTierBudget(DLV1_GetAreaTier(oArea));
}

void DLV1_ProcessNpcBudgeted(object oArea, object oNPC)
{
    int nReason = GetLocalInt(oNPC, DLV1_L_RESYNC_REASON);
    if (nReason == DLV1_RESYNC_NONE)
    {
        nReason = DLV1_RESYNC_WORKER;
    }
    DLV1_RunResync(oNPC, oArea, nReason);
}

void DLV1_DispatchDueJobs(object oArea, int nBudget)
{
    object oObject = GetFirstObjectInArea(oArea);
    int nProcessed = 0;

    while (GetIsObjectValid(oObject) && nProcessed < nBudget)
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            DLV1_ProcessNpcBudgeted(oArea, oObject);
            nProcessed += 1;
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void DLV1_AreaWorkerTick(object oArea)
{
    if (!DLV1_ShouldRunDailyLife(oArea))
    {
        return;
    }
    DLV1_DispatchDueJobs(oArea, DLV1_GetWorkerBudget(oArea));
}

#endif
