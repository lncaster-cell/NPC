#ifndef DL_RESYNC_INC_NSS
#define DL_RESYNC_INC_NSS

#include "dl_const_inc"
#include "dl_types_inc"
#include "dl_materialize_inc"
#include "dl_interact_inc"

int DL_ShouldResync(object oNPC, int nReason)
{
    if (!DL_IsDailyLifeNpc(oNPC))
    {
        return FALSE;
    }
    if (!DL_IsPersistent(oNPC) && !DL_IsNamed(oNPC))
    {
        return GetLocalInt(oNPC, DL_L_RESYNC_PENDING) == TRUE;
    }
    return nReason != DL_RESYNC_NONE;
}

void DL_RequestResync(object oNPC, int nReason)
{
    if (!DL_IsDailyLifeNpc(oNPC))
    {
        return;
    }
    SetLocalInt(oNPC, DL_L_RESYNC_PENDING, TRUE);
    SetLocalInt(oNPC, DL_L_RESYNC_REASON, nReason);
}

void DL_RequestAreaResync(object oArea, int nReason)
{
    object oObject = GetFirstObjectInArea(oArea);

    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            DL_RequestResync(oObject, nReason);
        }
        oObject = GetNextObjectInArea(oArea);
    }
}

void DL_RequestModuleResync(int nReason)
{
    object oArea = GetFirstArea();

    while (GetIsObjectValid(oArea))
    {
        DL_RequestAreaResync(oArea, nReason);
        oArea = GetNextArea();
    }
}

void DL_RunResync(object oNPC, object oArea, int nReason)
{
    if (!DL_ShouldResync(oNPC, nReason))
    {
        return;
    }

    DL_MaterializeNpc(oNPC, oArea);
    DeleteLocalInt(oNPC, DL_L_RESYNC_PENDING);
    SetLocalInt(oNPC, DL_L_RESYNC_REASON, DL_RESYNC_NONE);
}

#endif
