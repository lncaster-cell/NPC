#ifndef DL_WORKER_INC_NSS
#define DL_WORKER_INC_NSS

#include "dl_const_inc"
#include "dl_area_inc"
#include "dl_resync_inc"
#include "dl_override_inc"
#include "dl_types_inc"

void DL_LogSmokeSnapshot(object oNPC, object oArea, int nReason)
{
    string sMessage;

    sMessage =
        "smoke snapshot"
        + " reason=" + IntToString(nReason)
        + " family=" + IntToString(DL_GetNpcFamily(oNPC))
        + " subtype=" + IntToString(DL_GetNpcSubtype(oNPC))
        + " directive=" + IntToString(GetLocalInt(oNPC, DL_L_DIRECTIVE))
        + " dialogue=" + IntToString(GetLocalInt(oNPC, DL_L_DIALOGUE_MODE))
        + " service=" + IntToString(GetLocalInt(oNPC, DL_L_SERVICE_MODE))
        + " override=" + IntToString(DL_GetTopOverride(oNPC, oArea));

    DL_LogNpc(oNPC, DL_DEBUG_BASIC, sMessage);
}

int DL_GetWorkerBudget(object oArea)
{
    return DL_GetDefaultAreaTierBudget(DL_GetAreaTier(oArea));
}

int DL_ShouldProcessNpcInWorker(object oNPC)
{
    if (!DL_IsDailyLifeNpc(oNPC))
    {
        return FALSE;
    }
    if (GetLocalInt(oNPC, DL_L_RESYNC_PENDING) == TRUE)
    {
        return TRUE;
    }
    return DL_IsPersistent(oNPC) || DL_IsNamed(oNPC);
}

void DL_ProcessNpcBudgeted(object oArea, object oNPC)
{
    int nReason = GetLocalInt(oNPC, DL_L_RESYNC_REASON);
    if (nReason == DL_RESYNC_NONE)
    {
        nReason = DL_RESYNC_WORKER;
    }
    DL_RunResync(oNPC, oArea, nReason);
    if (GetLocalInt(GetModule(), DL_L_SMOKE_TRACE) == TRUE)
    {
        DL_LogSmokeSnapshot(oNPC, oArea, nReason);
    }
}

void DL_DispatchDueJobs(object oArea, int nBudget)
{
    object oObject = GetFirstObjectInArea(oArea);
    int nProcessed = 0;

    while (GetIsObjectValid(oObject) && nProcessed < nBudget)
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject) && DL_ShouldProcessNpcInWorker(oObject))
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
