#ifndef AL_V1_AREA_INC_NSS
#define AL_V1_AREA_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_log_inc"
#include "al_v1_util_inc"

int DLV1_GetAreaTier(object oArea)
{
    return GetLocalInt(oArea, DLV1_L_AREA_TIER);
}

void DLV1_SetAreaTier(object oArea, int nTier)
{
    SetLocalInt(oArea, DLV1_L_AREA_TIER, nTier);
}

int DLV1_ShouldRunDailyLife(object oArea)
{
    return DLV1_GetAreaTier(oArea) == DLV1_AREA_HOT;
}

void DLV1_OnAreaBecameHot(object oArea)
{
    DLV1_SetAreaTier(oArea, DLV1_AREA_HOT);
    DLV1_Log(DLV1_DEBUG_BASIC, "Area HOT: " + GetTag(oArea));
}

void DLV1_OnAreaBecameWarm(object oArea)
{
    DLV1_SetAreaTier(oArea, DLV1_AREA_WARM);
    DLV1_Log(DLV1_DEBUG_BASIC, "Area WARM: " + GetTag(oArea));
}

void DLV1_OnAreaBecameFrozen(object oArea)
{
    DLV1_SetAreaTier(oArea, DLV1_AREA_FROZEN);
    DLV1_Log(DLV1_DEBUG_BASIC, "Area FROZEN: " + GetTag(oArea));
}

#endif
