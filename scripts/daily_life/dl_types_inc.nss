#ifndef DL_TYPES_INC_NSS
#define DL_TYPES_INC_NSS

#include "dl_const_inc"
#include "dl_util_inc"

int DL_IsNamed(object oNPC)
{
    return GetLocalInt(oNPC, DL_L_NAMED) == TRUE;
}

int DL_IsPersistent(object oNPC)
{
    return GetLocalInt(oNPC, DL_L_PERSISTENT) == TRUE;
}

int DL_GetNpcFamily(object oNPC)
{
    return GetLocalInt(oNPC, DL_L_NPC_FAMILY);
}

int DL_GetNpcSubtype(object oNPC)
{
    return GetLocalInt(oNPC, DL_L_NPC_SUBTYPE);
}

int DL_GetScheduleTemplate(object oNPC)
{
    return GetLocalInt(oNPC, DL_L_SCHEDULE_TEMPLATE);
}

object DL_GetNpcBase(object oNPC)
{
    return GetLocalObject(oNPC, DL_L_NPC_BASE);
}

int DL_GetAllowedDirectivesMask(object oNPC)
{
    return GetLocalInt(oNPC, DL_L_ALLOWED_DIRECTIVES_MASK);
}

int DL_HasBase(object oNPC)
{
    return GetIsObjectValid(DL_GetNpcBase(oNPC));
}

int DL_SupportsDirective(object oNPC, int nDirective)
{
    int nMask = DL_GetAllowedDirectivesMask(oNPC);
    if (nMask == 0)
    {
        return TRUE;
    }
    return (nMask & (1 << nDirective)) != 0;
}

#endif
