const int DL_SCHED_DEFAULT_WAKE_HOUR = 6;
const int DL_SCHED_DEFAULT_SLEEP_HOURS = 8;
const int DL_SCHED_MIN_SLEEP_HOURS = 7;
const int DL_SCHED_MAX_SLEEP_HOURS = 10;
const int DL_SCHED_DEFAULT_SHIFT_START = 8;
const int DL_SCHED_DEFAULT_SHIFT_LENGTH = 8;
const int DL_SCHED_DEFAULT_WEEKEND_SHIFT_LENGTH = 6;
const int DL_SCHED_DEFAULT_CHILL_DELAY_MINUTES = 90;
const int DL_SCHED_DEFAULT_CHILL_DURATION_MINUTES = 180;

int DL_NormalizeHour(int nHour)
{
    while (nHour < 0)
    {
        nHour = nHour + 24;
    }
    while (nHour > 23)
    {
        nHour = nHour - 24;
    }
    return nHour;
}
int DL_NormalizeMinuteOfDay(int nMinute)
{
    while (nMinute < 0)
    {
        nMinute = nMinute + 1440;
    }
    while (nMinute >= 1440)
    {
        nMinute = nMinute - 1440;
    }
    return nMinute;
}
int DL_GetNowMinuteOfDay()
{
    return (GetTimeHour() * 60) + GetTimeMinute();
}
int DL_GetAbsoluteMinute()
{
    int nDays = (GetCalendarYear() * 12 * 28) + (GetCalendarMonth() * 28) + GetCalendarDay();
    return (nDays * 1440) + DL_GetNowMinuteOfDay();
}

int DL_IsMinuteCooldownActive(object oTarget, string sKey)
{
    return GetLocalInt(oTarget, sKey) > DL_GetAbsoluteMinute();
}

void DL_SetMinuteCooldown(object oTarget, string sKey, int nDurationMinutes)
{
    if (nDurationMinutes < 0)
    {
        nDurationMinutes = 0;
    }

    SetLocalInt(oTarget, sKey, DL_GetAbsoluteMinute() + nDurationMinutes);
}

int DL_ShouldRunByAreaTickInterval(int nNowTick, int nLastTick, int nInterval)
{
    if (nInterval <= 0)
    {
        return TRUE;
    }

    if (nNowTick < nLastTick)
    {
        return TRUE;
    }

    return (nNowTick - nLastTick) >= nInterval;
}

int DL_ClampInt(int nValue, int nMin, int nMax)
{
    if (nValue < nMin)
    {
        return nMin;
    }
    if (nValue > nMax)
    {
        return nMax;
    }
    return nValue;
}
int DL_GetAlphaNumCharValue(string sChar)
{
    string sAlphabet = "abcdefghijklmnopqrstuvwxyz0123456789_";
    int nIndex = FindSubString(sAlphabet, GetStringLowerCase(sChar));
    if (nIndex < 0)
    {
        return 0;
    }
    return nIndex + 1;
}
int DL_GetTagDeterministicOffset(string sTag, int nRange, int nCenterShift)
{
    if (nRange <= 0 || sTag == "")
    {
        return 0;
    }

    int nLen = GetStringLength(sTag);
    int nHash = 0;
    int i = 0;
    while (i < nLen)
    {
        nHash = nHash + (DL_GetAlphaNumCharValue(GetSubString(sTag, i, 1)) * (i + 3));
        i = i + 1;
    }

    int nOffset = nHash % nRange;
    return nOffset - nCenterShift;
}
int DL_MinuteInWindow(int nMinute, int nStart, int nDuration)
{
    nMinute = DL_NormalizeMinuteOfDay(nMinute);
    nStart = DL_NormalizeMinuteOfDay(nStart);
    if (nDuration <= 0)
    {
        return FALSE;
    }

    int nOffset = nMinute - nStart;
    if (nOffset < 0)
    {
        nOffset = nOffset + 1440;
    }
    return nOffset >= 0 && nOffset < nDuration;
}
int DL_GetWeekendType()
{
    // NWN2 toolchain used in CI does not expose GetCalendarDayOfWeek().
    // Derive a stable weekday index from campaign date components.
    // Index convention here is 0=Sunday ... 6=Saturday.
    int nAbsoluteDays = (GetCalendarYear() * 12 * 28) + (GetCalendarMonth() * 28) + GetCalendarDay();
    int nDow = nAbsoluteDays % 7;
    if (nDow == 0)
    {
        return 2;
    }
    if (nDow == 6)
    {
        return 1;
    }
    return 0;
}
int DL_GetNpcSleepHours(object oNpc)
{
    int nHours = GetLocalInt(oNpc, DL_L_NPC_SLEEP_HOURS);
    if (nHours <= 0)
    {
        nHours = DL_SCHED_DEFAULT_SLEEP_HOURS;
    }
    return DL_ClampInt(nHours, DL_SCHED_MIN_SLEEP_HOURS, DL_SCHED_MAX_SLEEP_HOURS);
}
int DL_GetNpcWakeHour(object oNpc)
{
    int nWake = GetLocalInt(oNpc, DL_L_NPC_WAKE_HOUR);
    if (nWake <= 0 || nWake > 23)
    {
        nWake = DL_SCHED_DEFAULT_WAKE_HOUR;
    }
    return nWake;
}
int DL_GetNpcShiftStart(object oNpc)
{
    int nStart = GetLocalInt(oNpc, DL_L_NPC_SHIFT_START);
    if (GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) == DL_PROFILE_GATE_POST)
    {
        int nLegacyGuardStart = GetLocalInt(oNpc, DL_L_NPC_GUARD_SHIFT_START);
        if (nLegacyGuardStart > 0 && nLegacyGuardStart <= 23)
        {
            nStart = nLegacyGuardStart;
        }
    }

    if (nStart <= 0 || nStart > 23)
    {
        nStart = DL_SCHED_DEFAULT_SHIFT_START;
    }
    return nStart;
}
int DL_GetNpcShiftLength(object oNpc, int bWeekend)
{
    int nLen = GetLocalInt(oNpc, DL_L_NPC_SHIFT_LENGTH);
    if (nLen <= 0)
    {
        nLen = DL_SCHED_DEFAULT_SHIFT_LENGTH;
    }

    if (bWeekend)
    {
        string sMode = GetLocalString(oNpc, DL_L_NPC_WEEKEND_MODE);
        if (sMode == DL_WEEKEND_MODE_REDUCED_WORK)
        {
            int nWeekendLen = GetLocalInt(oNpc, DL_L_NPC_WEEKEND_SHIFT_LENGTH);
            if (nWeekendLen > 0)
            {
                nLen = nWeekendLen;
            }
            else
            {
                nLen = DL_SCHED_DEFAULT_WEEKEND_SHIFT_LENGTH;
            }
        }
        else if (sMode == DL_WEEKEND_MODE_OFF_PUBLIC)
        {
            nLen = 0;
        }
    }

    return nLen;
}
int DL_NpcHasWorkDirectiveWindow(object oNpc, int bWeekend)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
    if (sProfile == DL_PROFILE_DOMESTIC_WORKER)
    {
        return GetIsObjectValid(DL_GetHomeArea(oNpc));
    }

    if (!GetIsObjectValid(DL_GetWorkArea(oNpc)))
    {
        return FALSE;
    }

    if (sProfile != DL_PROFILE_BLACKSMITH && sProfile != DL_PROFILE_GATE_POST && sProfile != DL_PROFILE_TRADER)
    {
        return FALSE;
    }

    string sWeekendMode = GetLocalString(oNpc, DL_L_NPC_WEEKEND_MODE);
    if (bWeekend && sWeekendMode == DL_WEEKEND_MODE_OFF_PUBLIC)
    {
        return FALSE;
    }

    return DL_GetNpcShiftLength(oNpc, bWeekend) > 0;
}
int DL_ResolveNpcDirectiveAtMinute(object oNpc, int nNow)
{
    if (!GetIsObjectValid(oNpc))
    {
        return DL_DIR_NONE;
    }

    nNow = DL_NormalizeMinuteOfDay(nNow);
    int nWake = DL_GetNpcWakeHour(oNpc);
    int nSleepHours = DL_GetNpcSleepHours(oNpc);
    int nSleepStart = DL_NormalizeMinuteOfDay((nWake * 60) - (nSleepHours * 60));
    int nWeekendType = DL_GetWeekendType();
    int bWeekend = nWeekendType != 0;
    int bHasWorkWindow = DL_NpcHasWorkDirectiveWindow(oNpc, bWeekend);
    int nShiftLen = bHasWorkWindow ? DL_GetNpcShiftLength(oNpc, bWeekend) : 0;
    int nShiftStartHour = DL_GetNpcShiftStart(oNpc);
    int nShiftStart = nShiftStartHour * 60;
    int nShiftEnd = DL_NormalizeMinuteOfDay(nShiftStart + (nShiftLen * 60));
    int nChillStart = DL_NormalizeMinuteOfDay(nShiftEnd + DL_SCHED_DEFAULT_CHILL_DELAY_MINUTES);
    string sTag = GetTag(oNpc);

    int nBreakfastStart = DL_NormalizeMinuteOfDay((nWake * 60) + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nDinnerStart = DL_NormalizeMinuteOfDay(nSleepStart - 75 + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nLunchStart = DL_NormalizeMinuteOfDay(nShiftStart + 240 + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nSocialStart = DL_NormalizeMinuteOfDay(nShiftEnd + 10 + DL_GetTagDeterministicOffset(sTag, 31, 15));
    int nPublicStart = DL_NormalizeMinuteOfDay((nWake * 60) + 180 + DL_GetTagDeterministicOffset(sTag, 41, 20));
    int nPublicLate = DL_NormalizeMinuteOfDay(nDinnerStart - 120 + DL_GetTagDeterministicOffset(sTag, 31, 15));
    int bInWorkWindow = bHasWorkWindow && DL_MinuteInWindow(nNow, nShiftStart, nShiftLen * 60);

    if (DL_MinuteInWindow(nNow, nSleepStart, nSleepHours * 60))
    {
        return DL_DIR_SLEEP;
    }

    if (DL_MinuteInWindow(nNow, nBreakfastStart, 60))
    {
        return DL_DIR_MEAL;
    }

    if (nShiftLen >= 8 && DL_MinuteInWindow(nNow, nLunchStart, 30))
    {
        return DL_DIR_MEAL;
    }

    if (DL_MinuteInWindow(nNow, nDinnerStart, 60))
    {
        return DL_DIR_MEAL;
    }

    if (bHasWorkWindow && !bInWorkWindow &&
        DL_MinuteInWindow(nNow, nChillStart, DL_SCHED_DEFAULT_CHILL_DURATION_MINUTES) &&
        GetIsObjectValid(DL_ResolveChillWaypoint(oNpc)))
    {
        return DL_DIR_CHILL;
    }

    if (bWeekend && GetLocalString(oNpc, DL_L_NPC_WEEKEND_MODE) == DL_WEEKEND_MODE_OFF_PUBLIC)
    {
        if (DL_MinuteInWindow(nNow, nSocialStart, 75))
        {
            return DL_DIR_SOCIAL;
        }
        if (DL_MinuteInWindow(nNow, nPublicStart, 90) || DL_MinuteInWindow(nNow, nPublicLate, 75))
        {
            return DL_DIR_PUBLIC;
        }
        return DL_DIR_NONE;
    }

    if (!bInWorkWindow && DL_MinuteInWindow(nNow, nSocialStart, 75))
    {
        return DL_DIR_SOCIAL;
    }

    if (!bInWorkWindow && (DL_MinuteInWindow(nNow, nPublicStart, 90) || DL_MinuteInWindow(nNow, nPublicLate, 75)))
    {
        return DL_DIR_PUBLIC;
    }

    if (bHasWorkWindow && DL_MinuteInWindow(nNow, nShiftStart, nShiftLen * 60))
    {
        return DL_DIR_WORK;
    }

    return DL_DIR_NONE;
}
int DL_ResolveNpcDirective(object oNpc)
{
    return DL_ResolveNpcDirectiveAtMinute(oNpc, DL_GetNowMinuteOfDay());
}
