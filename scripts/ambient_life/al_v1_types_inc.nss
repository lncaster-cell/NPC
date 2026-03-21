#ifndef AL_V1_TYPES_INC_NSS
#define AL_V1_TYPES_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_util_inc"

int DLV1_IsNamed(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_NAMED) == TRUE;
}

int DLV1_IsPersistent(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_PERSISTENT) == TRUE;
}

int DLV1_GetNpcFamily(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_NPC_FAMILY);
}

int DLV1_GetNpcSubtype(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_NPC_SUBTYPE);
}

int DLV1_GetScheduleTemplate(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_SCHEDULE_TEMPLATE);
}

object DLV1_GetNpcBase(object oNPC)
{
    return GetLocalObject(oNPC, DLV1_L_NPC_BASE);
}

int DLV1_GetAllowedDirectivesMask(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_ALLOWED_DIRECTIVES_MASK);
}

int DLV1_HasBase(object oNPC)
{
    return GetIsObjectValid(DLV1_GetNpcBase(oNPC));
}

int DLV1_SupportsDirective(object oNPC, int nDirective)
{
    int nMask = DLV1_GetAllowedDirectivesMask(oNPC);
    if (nMask == 0)
    {
        return TRUE;
    }
    return (nMask & (1 << nDirective)) != 0;
}

#endif
