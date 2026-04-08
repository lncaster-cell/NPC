#ifndef DL_TYPES_INC_NSS
#define DL_TYPES_INC_NSS

#include "dl_const_inc"
#include "dl_util_inc"

// NOTE:
// Historical name kept for backward compatibility in include consumers.
// The runtime gate now uses full canonical Daily Life family coverage.
int DL_IsCanonicalDailyLifeFamily(int nFamily)
{
    return nFamily == DL_FAMILY_LAW
        || nFamily == DL_FAMILY_CRAFT
        || nFamily == DL_FAMILY_TRADE_SERVICE
        || nFamily == DL_FAMILY_CIVILIAN
        || nFamily == DL_FAMILY_ELITE_ADMIN
        || nFamily == DL_FAMILY_CLERGY;
}

int DL_IsFamilyInFirstPlayableSlice(int nFamily)
{
    return DL_IsCanonicalDailyLifeFamily(nFamily);
}

int DL_IsSubtypeAllowedForFamily(int nFamily, int nSubtype)
{
    if (nSubtype == DL_SUBTYPE_NONE)
    {
        return TRUE;
    }

    if (nFamily == DL_FAMILY_LAW)
    {
        return nSubtype == DL_SUBTYPE_PATROL
            || nSubtype == DL_SUBTYPE_GATE_POST
            || nSubtype == DL_SUBTYPE_INSPECTION;
    }
    if (nFamily == DL_FAMILY_CRAFT)
    {
        return nSubtype == DL_SUBTYPE_BLACKSMITH
            || nSubtype == DL_SUBTYPE_ARTISAN
            || nSubtype == DL_SUBTYPE_LABORER;
    }
    if (nFamily == DL_FAMILY_TRADE_SERVICE)
    {
        return nSubtype == DL_SUBTYPE_SHOPKEEPER
            || nSubtype == DL_SUBTYPE_INNKEEPER
            || nSubtype == DL_SUBTYPE_WANDERING_VENDOR;
    }
    if (nFamily == DL_FAMILY_CIVILIAN)
    {
        return nSubtype == DL_SUBTYPE_RESIDENT
            || nSubtype == DL_SUBTYPE_HOMELESS
            || nSubtype == DL_SUBTYPE_SERVANT;
    }
    if (nFamily == DL_FAMILY_ELITE_ADMIN)
    {
        return nSubtype == DL_SUBTYPE_NOBLE
            || nSubtype == DL_SUBTYPE_OFFICIAL
            || nSubtype == DL_SUBTYPE_SCRIBE;
    }
    if (nFamily == DL_FAMILY_CLERGY)
    {
        return nSubtype == DL_SUBTYPE_PRIEST;
    }
    return FALSE;
}

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
    int nFamily = GetLocalInt(oNPC, DL_L_NPC_FAMILY);
    if (DL_IsCanonicalDailyLifeFamily(nFamily))
    {
        return nFamily;
    }
    return DL_FAMILY_NONE;
}

int DL_GetNpcSubtype(object oNPC)
{
    int nFamily = DL_GetNpcFamily(oNPC);
    int nSubtype = GetLocalInt(oNPC, DL_L_NPC_SUBTYPE);

    if (DL_IsSubtypeAllowedForFamily(nFamily, nSubtype))
    {
        return nSubtype;
    }
    return DL_SUBTYPE_NONE;
}

int DL_IsDailyLifeNpc(object oNPC)
{
    return DL_GetNpcFamily(oNPC) != DL_FAMILY_NONE;
}

int DL_GetDefaultScheduleTemplateForProfile(int nFamily, int nSubtype)
{
    if (nFamily == DL_FAMILY_LAW)
    {
        if (nSubtype == DL_SUBTYPE_GATE_POST)
        {
            return DL_SCH_DUTY_ROTATION_DAY;
        }
        return DL_SCH_DUTY_ROTATION_NIGHT;
    }
    if (nFamily == DL_FAMILY_CRAFT)
    {
        return DL_SCH_EARLY_WORKER;
    }
    if (nFamily == DL_FAMILY_TRADE_SERVICE)
    {
        if (nSubtype == DL_SUBTYPE_INNKEEPER)
        {
            return DL_SCH_TAVERN_LATE;
        }
        if (nSubtype == DL_SUBTYPE_WANDERING_VENDOR)
        {
            return DL_SCH_WANDERING_VENDOR_WINDOW;
        }
        return DL_SCH_SHOP_DAY;
    }
    return DL_SCH_CIVILIAN_HOME;
}

int DL_GetDefaultScheduleTemplate(object oNPC)
{
    return DL_GetDefaultScheduleTemplateForProfile(DL_GetNpcFamily(oNPC), DL_GetNpcSubtype(oNPC));
}

int DL_GetScheduleTemplate(object oNPC)
{
    int nTemplate = GetLocalInt(oNPC, DL_L_SCHEDULE_TEMPLATE);
    if (nTemplate != DL_SCH_NONE)
    {
        return nTemplate;
    }
    return DL_GetDefaultScheduleTemplate(oNPC);
}

object DL_GetNpcBase(object oNPC)
{
    return GetLocalObject(oNPC, DL_L_NPC_BASE);
}

string DL_GetFunctionSlotId(object oNPC)
{
    return GetLocalString(oNPC, DL_L_FUNCTION_SLOT_ID);
}

int DL_GetDefaultAllowedDirectivesMaskForFamily(int nFamily)
{
    if (nFamily == DL_FAMILY_LAW)
    {
        return (1 << DL_DIR_SLEEP)
            | (1 << DL_DIR_DUTY)
            | (1 << DL_DIR_HOLD_POST)
            | (1 << DL_DIR_PUBLIC_PRESENCE)
            | (1 << DL_DIR_HIDE_SAFE)
            | (1 << DL_DIR_LOCKDOWN_BASE)
            | (1 << DL_DIR_ABSENT);
    }
    if (nFamily == DL_FAMILY_CRAFT)
    {
        return (1 << DL_DIR_SLEEP)
            | (1 << DL_DIR_WORK)
            | (1 << DL_DIR_SOCIAL)
            | (1 << DL_DIR_PUBLIC_PRESENCE)
            | (1 << DL_DIR_HIDE_SAFE)
            | (1 << DL_DIR_LOCKDOWN_BASE)
            | (1 << DL_DIR_ABSENT);
    }
    if (nFamily == DL_FAMILY_TRADE_SERVICE)
    {
        return (1 << DL_DIR_SLEEP)
            | (1 << DL_DIR_SERVICE)
            | (1 << DL_DIR_SOCIAL)
            | (1 << DL_DIR_PUBLIC_PRESENCE)
            | (1 << DL_DIR_HIDE_SAFE)
            | (1 << DL_DIR_LOCKDOWN_BASE)
            | (1 << DL_DIR_ABSENT);
    }

    return (1 << DL_DIR_SLEEP)
        | (1 << DL_DIR_SOCIAL)
        | (1 << DL_DIR_PUBLIC_PRESENCE)
        | (1 << DL_DIR_HIDE_SAFE)
        | (1 << DL_DIR_ABSENT);
}

int DL_GetDefaultAllowedDirectivesMask(object oNPC)
{
    return DL_GetDefaultAllowedDirectivesMaskForFamily(DL_GetNpcFamily(oNPC));
}

int DL_GetAllowedDirectivesMask(object oNPC)
{
    int nMask = GetLocalInt(oNPC, DL_L_ALLOWED_DIRECTIVES_MASK);
    if (nMask != 0)
    {
        return nMask;
    }
    return DL_GetDefaultAllowedDirectivesMask(oNPC);
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
