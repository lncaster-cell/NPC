#ifndef DL_WORKER_V2_INC_NSS
#define DL_WORKER_V2_INC_NSS

#include "dl_const_inc"
#include "dl_area_inc"
#include "dl_resync_v2_inc"
#include "dl_override_inc"
#include "dl_slot_handoff_inc"
#include "dl_types_inc"

const string DL_L_WORKER_CURSOR = "dl_worker_cursor";
const string DL_L_WORKER_CANDIDATE_IDX = "dl_worker_candidate_idx";
const string DL_L_WORKER_IS_CANDIDATE = "dl_worker_is_candidate";

int DL_IsWorkerCreatureObject(object oObject)
{
    return GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject);
}

void DL_ClearWorkerCandidateMarker(object oNPC)
{
    DeleteLocalInt(oNPC, DL_L_WORKER_CANDIDATE_IDX);
    DeleteLocalInt(oNPC, DL_L_WORKER_IS_CANDIDATE);
}

void DL_ClearAreaWorkerMarkers(object oArea)
{
    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (DL_IsWorkerCreatureObject(oObject))
        {
            DL_ClearWorkerCandidateMarker(oObject);
        }
        oObject = GetNextObjectInArea(oArea);
    }
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
}

void DL_DispatchDueJobs(object oArea, int nBudget)
{
    object oObject;
    int nCandidateCount = 0;
    int nCursor = 0;
    int nPlanned = 0;
    int nProcessed = 0;

    if (nBudget <= 0)
    {
        DL_ClearAreaWorkerMarkers(oArea);
        SetLocalInt(oArea, DL_L_WORKER_CURSOR, 0);
        return;
    }

    oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (DL_IsWorkerCreatureObject(oObject))
        {
            if (DL_ShouldProcessNpcInWorker(oObject))
            {
                SetLocalInt(oObject, DL_L_WORKER_CANDIDATE_IDX, nCandidateCount);
                SetLocalInt(oObject, DL_L_WORKER_IS_CANDIDATE, TRUE);
                nCandidateCount += 1;
            }
            else
            {
                DL_ClearWorkerCandidateMarker(oObject);
            }
        }
        oObject = GetNextObjectInArea(oArea);
    }

    if (nCandidateCount <= 0)
    {
        SetLocalInt(oArea, DL_L_WORKER_CURSOR, 0);
        return;
    }

    nCursor = GetLocalInt(oArea, DL_L_WORKER_CURSOR) % nCandidateCount;
    if (nCursor < 0)
    {
        nCursor += nCandidateCount;
    }

    nPlanned = nBudget;
    if (nPlanned > nCandidateCount)
    {
        nPlanned = nCandidateCount;
    }

    DL_Log(DL_DEBUG_VERBOSE, "worker fairness area=" + GetTag(oArea) + " cursor=" + IntToString(nCursor) + " candidates=" + IntToString(nCandidateCount) + " budget=" + IntToString(nBudget));

    oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (DL_IsWorkerCreatureObject(oObject))
        {
            if (GetLocalInt(oObject, DL_L_WORKER_IS_CANDIDATE) == TRUE)
            {
                int nCandidateIndex = GetLocalInt(oObject, DL_L_WORKER_CANDIDATE_IDX);
                if (nProcessed < nPlanned)
                {
                    int nDistance = (nCandidateIndex - nCursor) % nCandidateCount;
                    if (nDistance < 0)
                    {
                        nDistance += nCandidateCount;
                    }
                    if (nDistance < nPlanned)
                    {
                        DL_ProcessNpcBudgeted(oArea, oObject);
                        nProcessed += 1;
                    }
                }
            }
            DL_ClearWorkerCandidateMarker(oObject);
        }
        oObject = GetNextObjectInArea(oArea);
    }

    SetLocalInt(oArea, DL_L_WORKER_CURSOR, (nCursor + nProcessed) % nCandidateCount);
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
