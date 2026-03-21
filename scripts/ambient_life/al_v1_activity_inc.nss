#ifndef AL_V1_ACTIVITY_INC_NSS
#define AL_V1_ACTIVITY_INC_NSS

#include "al_v1_const_inc"

int DLV1_ResolveActivityKind(object oNPC, int nDirective, int nAnchorGroup)
{
    if (nDirective == DLV1_DIR_SLEEP)
    {
        return DLV1_ACT_SLEEP;
    }
    if (nDirective == DLV1_DIR_WORK)
    {
        return DLV1_ACT_WORK;
    }
    if (nDirective == DLV1_DIR_SERVICE)
    {
        return DLV1_ACT_SERVICE_IDLE;
    }
    if (nDirective == DLV1_DIR_SOCIAL || nAnchorGroup == DLV1_AG_SOCIAL)
    {
        return DLV1_ACT_SOCIAL;
    }
    if (nDirective == DLV1_DIR_DUTY || nDirective == DLV1_DIR_HOLD_POST)
    {
        return DLV1_ACT_DUTY_IDLE;
    }
    if (nDirective == DLV1_DIR_HIDE_SAFE || nDirective == DLV1_DIR_LOCKDOWN_BASE)
    {
        return DLV1_ACT_HIDE;
    }
    return DLV1_ACT_NONE;
}

void DLV1_ApplyActivity(object oNPC, int nActivityKind, object oPoint)
{
    SetLocalInt(oNPC, DLV1_L_ACTIVITY_KIND, nActivityKind);
    if (!GetIsObjectValid(oNPC))
    {
        return;
    }

    AssignCommand(oNPC, ClearAllActions());
    if (GetIsObjectValid(oPoint))
    {
        AssignCommand(oNPC, ActionMoveToObject(oPoint, TRUE));
    }
}

#endif
