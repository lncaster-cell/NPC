#ifndef DL_V2_AREA_INC_NSS
#define DL_V2_AREA_INC_NSS

#include "dl_v2_bootstrap_inc"

int DL2_GetAreaTier(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return DL2_AREA_TIER_FROZEN;
    }

    int nTier = GetLocalInt(oArea, DL2_L_AREA_TIER);
    if (!DL2_IsValidAreaTier(nTier))
    {
        return DL2_AREA_TIER_FROZEN;
    }

    return nTier;
}

void DL2_SetAreaTier(object oArea, int nTier)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (!DL2_IsValidAreaTier(nTier))
    {
        nTier = DL2_AREA_TIER_FROZEN;
    }

    SetLocalInt(oArea, DL2_L_AREA_TIER, nTier);
}

void DL2_InitAreaRuntimeState(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (!DL2_IsValidAreaTier(GetLocalInt(oArea, DL2_L_AREA_TIER)))
    {
        SetLocalInt(oArea, DL2_L_AREA_TIER, DL2_AREA_TIER_FROZEN);
    }

    if (GetLocalInt(oArea, DL2_L_AREA_WORKER_BUDGET) < DL2_DEFAULT_WORKER_BUDGET)
    {
        SetLocalInt(oArea, DL2_L_AREA_WORKER_BUDGET, DL2_DEFAULT_WORKER_BUDGET);
    }

    if (GetLocalInt(oArea, DL2_L_AREA_WORKER_CURSOR) < 0)
    {
        SetLocalInt(oArea, DL2_L_AREA_WORKER_CURSOR, 0);
    }
}

void DL2_ActivateAreaOnPlayerEnter(object oArea)
{
    DL2_InitAreaRuntimeState(oArea);
    DL2_SetAreaTier(oArea, DL2_AREA_TIER_HOT);

    DL2_LogInfo(
        "AREA",
        "activate_on_enter tier=" + IntToString(DL2_GetAreaTier(oArea))
            + " budget=" + IntToString(GetLocalInt(oArea, DL2_L_AREA_WORKER_BUDGET))
    );
}

#endif
