#ifndef AL_V1_RESYNC_INC_NSS
#define AL_V1_RESYNC_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_types_inc"
#include "al_v1_materialize_inc"
#include "al_v1_interact_inc"

int DLV1_ShouldResync(object oNPC, int nReason)
{
    if (!DLV1_IsPersistent(oNPC) && !DLV1_IsNamed(oNPC))
    {
        return FALSE;
    }
    return nReason != DLV1_RESYNC_NONE;
}

void DLV1_RequestResync(object oNPC, int nReason)
{
    SetLocalInt(oNPC, DLV1_L_RESYNC_PENDING, TRUE);
    SetLocalInt(oNPC, DLV1_L_RESYNC_REASON, nReason);
}

void DLV1_RunResync(object oNPC, object oArea, int nReason)
{
    if (!DLV1_ShouldResync(oNPC, nReason))
    {
        return;
    }

    DLV1_MaterializeNpc(oNPC, oArea);
    DLV1_RefreshInteractionState(oNPC, oArea);
    DeleteLocalInt(oNPC, DLV1_L_RESYNC_PENDING);
    SetLocalInt(oNPC, DLV1_L_RESYNC_REASON, DLV1_RESYNC_NONE);
}

#endif
