#ifndef AL_V1_RESOLVER_INC_NSS
#define AL_V1_RESOLVER_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_types_inc"
#include "al_v1_schedule_inc"
#include "al_v1_override_inc"

int DLV1_ResolveDirectiveFromSchedule(object oNPC, int nScheduleWindow, int nDayType)
{
    int nFamily = DLV1_GetNpcFamily(oNPC);

    if (!DLV1_HasBase(oNPC))
    {
        return DLV1_DIR_ABSENT;
    }

    if (nScheduleWindow == DLV1_WIN_SLEEP)
    {
        return DLV1_DIR_SLEEP;
    }

    if (nFamily == DLV1_FAMILY_LAW)
    {
        if (nScheduleWindow == DLV1_WIN_DAY_DUTY || nScheduleWindow == DLV1_WIN_NIGHT_DUTY)
        {
            return DLV1_DIR_DUTY;
        }
        if (nScheduleWindow == DLV1_WIN_PUBLIC_IDLE)
        {
            return DLV1_DIR_PUBLIC_PRESENCE;
        }
        return DLV1_DIR_SLEEP;
    }

    if (nFamily == DLV1_FAMILY_CRAFT)
    {
        if (nScheduleWindow == DLV1_WIN_WORK_CORE)
        {
            return DLV1_DIR_WORK;
        }
        if (nScheduleWindow == DLV1_WIN_SOCIAL || nDayType == DLV1_DAY_REST)
        {
            return DLV1_DIR_SOCIAL;
        }
        return DLV1_DIR_PUBLIC_PRESENCE;
    }

    if (nFamily == DLV1_FAMILY_TRADE_SERVICE)
    {
        if (nScheduleWindow == DLV1_WIN_SERVICE_CORE || nScheduleWindow == DLV1_WIN_LATE_SOCIAL)
        {
            return DLV1_DIR_SERVICE;
        }
        if (nScheduleWindow == DLV1_WIN_SOCIAL)
        {
            return DLV1_DIR_SOCIAL;
        }
        return DLV1_DIR_PUBLIC_PRESENCE;
    }

    if (nScheduleWindow == DLV1_WIN_SOCIAL || nScheduleWindow == DLV1_WIN_LATE_SOCIAL)
    {
        return DLV1_DIR_SOCIAL;
    }
    return DLV1_DIR_PUBLIC_PRESENCE;
}

int DLV1_ApplyOverrideToDirective(object oNPC, int nDirective, int nOverrideKind)
{
    if (nOverrideKind == DLV1_OVR_FIRE)
    {
        if (DLV1_GetNpcFamily(oNPC) == DLV1_FAMILY_LAW)
        {
            return DLV1_DIR_HOLD_POST;
        }
        return DLV1_DIR_HIDE_SAFE;
    }

    if (nOverrideKind == DLV1_OVR_QUARANTINE)
    {
        if (DLV1_GetNpcFamily(oNPC) == DLV1_FAMILY_LAW)
        {
            return DLV1_DIR_DUTY;
        }
        return DLV1_DIR_LOCKDOWN_BASE;
    }

    return nDirective;
}

int DLV1_ResolveDirective(object oNPC, object oArea)
{
    int nDayType = DLV1_DetermineDayType(oArea);
    int nMinute = DLV1_GetCurrentMinuteOfDay();
    int nOffset = DLV1_GetPersonalTimeOffset(oNPC);
    int nWindow = DLV1_DetermineScheduleWindow(DLV1_GetScheduleTemplate(oNPC), nDayType, nMinute, nOffset);
    int nDirective = DLV1_ResolveDirectiveFromSchedule(oNPC, nWindow, nDayType);
    nDirective = DLV1_ApplyOverrideToDirective(oNPC, nDirective, DLV1_GetTopOverride(oNPC, oArea));

    if (!DLV1_SupportsDirective(oNPC, nDirective))
    {
        return DLV1_DIR_PUBLIC_PRESENCE;
    }

    return nDirective;
}

int DLV1_ResolveAnchorGroup(object oNPC, int nDirective)
{
    if (nDirective == DLV1_DIR_SLEEP)
    {
        return DLV1_AG_SLEEP;
    }
    if (nDirective == DLV1_DIR_WORK)
    {
        return DLV1_AG_WORK;
    }
    if (nDirective == DLV1_DIR_SERVICE)
    {
        return DLV1_AG_SERVICE;
    }
    if (nDirective == DLV1_DIR_SOCIAL)
    {
        return DLV1_AG_SOCIAL;
    }
    if (nDirective == DLV1_DIR_DUTY)
    {
        if (DLV1_GetNpcSubtype(oNPC) == DLV1_SUBTYPE_GATE_POST)
        {
            return DLV1_AG_GATE;
        }
        return DLV1_AG_DUTY;
    }
    if (nDirective == DLV1_DIR_HOLD_POST)
    {
        return DLV1_AG_GATE;
    }
    if (nDirective == DLV1_DIR_LOCKDOWN_BASE)
    {
        return DLV1_AG_HIDE;
    }
    if (nDirective == DLV1_DIR_HIDE_SAFE)
    {
        return DLV1_AG_HIDE;
    }
    if (nDirective == DLV1_DIR_PUBLIC_PRESENCE)
    {
        return DLV1_AG_STREET_NEAR_BASE;
    }
    return DLV1_AG_NONE;
}

int DLV1_ResolveDialogueMode(object oNPC, int nDirective, int nOverrideKind)
{
    if (nOverrideKind == DLV1_OVR_FIRE)
    {
        return DLV1_DLG_HIDE;
    }
    if (nDirective == DLV1_DIR_WORK || nDirective == DLV1_DIR_SERVICE)
    {
        return DLV1_DLG_WORK;
    }
    if (nDirective == DLV1_DIR_DUTY || nDirective == DLV1_DIR_HOLD_POST)
    {
        if (DLV1_GetNpcSubtype(oNPC) == DLV1_SUBTYPE_INSPECTION || DLV1_GetNpcSubtype(oNPC) == DLV1_SUBTYPE_GATE_POST)
        {
            return DLV1_DLG_INSPECTION;
        }
        return DLV1_DLG_OFF_DUTY;
    }
    if (nDirective == DLV1_DIR_LOCKDOWN_BASE)
    {
        return DLV1_DLG_LOCKDOWN;
    }
    if (nDirective == DLV1_DIR_HIDE_SAFE)
    {
        return DLV1_DLG_HIDE;
    }
    if (nDirective == DLV1_DIR_ABSENT)
    {
        return DLV1_DLG_UNAVAILABLE;
    }
    return DLV1_DLG_OFF_DUTY;
}

int DLV1_ResolveServiceMode(object oNPC, int nDirective, int nOverrideKind)
{
    if (DLV1_ShouldDisableService(oNPC, nOverrideKind))
    {
        return DLV1_SERVICE_DISABLED;
    }
    if (nDirective == DLV1_DIR_WORK)
    {
        return DLV1_SERVICE_LIMITED;
    }
    if (nDirective == DLV1_DIR_SERVICE)
    {
        return DLV1_SERVICE_AVAILABLE;
    }
    if (nDirective == DLV1_DIR_ABSENT)
    {
        return DLV1_SERVICE_NONE;
    }
    return DLV1_SERVICE_DISABLED;
}

#endif
