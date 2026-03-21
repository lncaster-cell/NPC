#ifndef AL_V1_SCHEDULE_INC_NSS
#define AL_V1_SCHEDULE_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_types_inc"

int DLV1_DetermineDayType(object oArea)
{
    int nOverride = GetLocalInt(oArea, DLV1_L_DAY_TYPE_OVERRIDE);
    if (nOverride != 0)
    {
        return nOverride;
    }

    int nDay = GetCalendarDay();
    if ((nDay % 7) == 0)
    {
        return DLV1_DAY_REST;
    }
    return DLV1_DAY_WEEKDAY;
}

int DLV1_GetPersonalTimeOffset(object oNPC)
{
    return GetLocalInt(oNPC, DLV1_L_PERSONAL_OFFSET_MIN);
}

int DLV1_GetCurrentMinuteOfDay()
{
    return (GetTimeHour() * 60) + GetTimeMinute();
}

int DLV1_DetermineScheduleWindow(int nTemplate, int nDayType, int nMinuteOfDay, int nOffset)
{
    int nMinute = nMinuteOfDay + nOffset;
    while (nMinute < 0)
    {
        nMinute += 1440;
    }
    while (nMinute >= 1440)
    {
        nMinute -= 1440;
    }

    if (nTemplate == DLV1_SCH_EARLY_WORKER)
    {
        if (nMinute < 360)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 480)
        {
            return DLV1_WIN_MORNING_PREP;
        }
        if (nMinute < 1020)
        {
            return DLV1_WIN_WORK_CORE;
        }
        if (nMinute < 1260)
        {
            return DLV1_WIN_SOCIAL;
        }
        return DLV1_WIN_SLEEP;
    }

    if (nTemplate == DLV1_SCH_SHOP_DAY)
    {
        if (nMinute < 420)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 540)
        {
            return DLV1_WIN_MORNING_PREP;
        }
        if (nMinute < 1140)
        {
            return DLV1_WIN_SERVICE_CORE;
        }
        if (nMinute < 1260)
        {
            return DLV1_WIN_PUBLIC_IDLE;
        }
        return DLV1_WIN_SLEEP;
    }

    if (nTemplate == DLV1_SCH_TAVERN_LATE)
    {
        if (nMinute < 600)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 900)
        {
            return DLV1_WIN_PUBLIC_IDLE;
        }
        if (nMinute < 1380)
        {
            return DLV1_WIN_LATE_SOCIAL;
        }
        return DLV1_WIN_SLEEP;
    }

    if (nTemplate == DLV1_SCH_DUTY_ROTATION_DAY)
    {
        if (nMinute < 360)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 1080)
        {
            return DLV1_WIN_DAY_DUTY;
        }
        if (nMinute < 1260)
        {
            return DLV1_WIN_PUBLIC_IDLE;
        }
        return DLV1_WIN_SLEEP;
    }

    if (nTemplate == DLV1_SCH_DUTY_ROTATION_NIGHT)
    {
        if (nMinute < 420)
        {
            return DLV1_WIN_NIGHT_DUTY;
        }
        if (nMinute < 960)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 1200)
        {
            return DLV1_WIN_PUBLIC_IDLE;
        }
        return DLV1_WIN_NIGHT_DUTY;
    }

    if (nTemplate == DLV1_SCH_WANDERING_VENDOR_WINDOW)
    {
        if (nMinute < 420)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 1020)
        {
            return DLV1_WIN_SERVICE_CORE;
        }
        if (nMinute < 1200)
        {
            return DLV1_WIN_PUBLIC_IDLE;
        }
        return DLV1_WIN_SLEEP;
    }

    if (nDayType == DLV1_DAY_REST)
    {
        if (nMinute < 480)
        {
            return DLV1_WIN_SLEEP;
        }
        if (nMinute < 1140)
        {
            return DLV1_WIN_PUBLIC_IDLE;
        }
        if (nMinute < 1260)
        {
            return DLV1_WIN_SOCIAL;
        }
        return DLV1_WIN_SLEEP;
    }

    if (nMinute < 360)
    {
        return DLV1_WIN_SLEEP;
    }
    if (nMinute < 1020)
    {
        return DLV1_WIN_PUBLIC_IDLE;
    }
    if (nMinute < 1200)
    {
        return DLV1_WIN_SOCIAL;
    }
    return DLV1_WIN_SLEEP;
}

#endif
