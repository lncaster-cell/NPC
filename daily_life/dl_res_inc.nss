#include "dl_activity_archive_anim_inc"
#include "dl_transition_inc"

// Step 05+: resolver/materialization skeleton.
// Scope: EARLY_WORKER sleep window + basic BLACKSMITH/GATE_POST/TRADER WORK/SLEEP window split.

const string DL_L_NPC_DIRECTIVE = "dl_npc_directive";
const string DL_L_NPC_MAT_REQ = "dl_npc_mat_req";
const string DL_L_NPC_MAT_TAG = "dl_npc_mat_tag";
const string DL_L_NPC_DIALOGUE_MODE = "dl_npc_dialogue_mode";
const string DL_L_NPC_SERVICE_MODE = "dl_npc_service_mode";
const string DL_L_NPC_PROFILE_ID = "dl_profile_id";
const string DL_L_NPC_STATE = "dl_state";
const string DL_L_NPC_SLEEP_PHASE = "dl_npc_sleep_phase";
const string DL_L_NPC_SLEEP_STATUS = "dl_npc_sleep_status";
const string DL_L_NPC_SLEEP_TARGET = "dl_npc_sleep_target";
const string DL_L_NPC_SLEEP_DIAGNOSTIC = "dl_npc_sleep_diagnostic";
const string DL_L_NPC_WORK_KIND = "dl_npc_work_kind";
const string DL_L_NPC_WORK_TARGET = "dl_npc_work_target";
const string DL_L_NPC_WORK_STATUS = "dl_npc_work_status";
const string DL_L_NPC_WORK_DIAGNOSTIC = "dl_npc_work_diagnostic";
const string DL_L_NPC_GUARD_SHIFT_START = "dl_guard_shift_start";
const string DL_L_NPC_ACTIVITY_ID = "dl_npc_activity_id";
const string DL_L_NPC_ANIM_SET = "dl_npc_anim_set";
const string DL_L_NPC_CACHE_SLEEP_APPROACH = "dl_cache_sleep_approach";
const string DL_L_NPC_CACHE_SLEEP_BED = "dl_cache_sleep_bed";
const string DL_L_NPC_CACHE_WORK_FORGE = "dl_cache_work_forge";
const string DL_L_NPC_CACHE_WORK_CRAFT = "dl_cache_work_craft";
const string DL_L_NPC_CACHE_WORK_POST = "dl_cache_work_post";
const string DL_L_NPC_CACHE_WORK_TRADE = "dl_cache_work_trade";
const string DL_L_NPC_CACHE_MEAL = "dl_cache_meal";
const string DL_L_NPC_CACHE_SOCIAL_A = "dl_cache_social_a";
const string DL_L_NPC_CACHE_SOCIAL_B = "dl_cache_social_b";
const string DL_L_NPC_CACHE_PUBLIC = "dl_cache_public";
const string DL_L_NPC_CACHE_WORK_PRIMARY = "dl_cache_work_primary";
const string DL_L_NPC_CACHE_WORK_SECONDARY = "dl_cache_work_secondary";
const string DL_L_NPC_CACHE_HOME_AREA = "dl_cache_home_area";
const string DL_L_NPC_CACHE_WORK_AREA = "dl_cache_work_area";
const string DL_L_NPC_CACHE_MEAL_AREA = "dl_cache_meal_area";
const string DL_L_NPC_CACHE_SOCIAL_AREA = "dl_cache_social_area";
const string DL_L_NPC_CACHE_PUBLIC_AREA = "dl_cache_public_area";
const string DL_L_NPC_FOCUS_STATUS = "dl_npc_focus_status";
const string DL_L_NPC_FOCUS_TARGET = "dl_npc_focus_target";
const string DL_L_NPC_FOCUS_DIAGNOSTIC = "dl_npc_focus_diagnostic";
const string DL_L_NPC_SOCIAL_SLOT = "dl_social_slot";
const string DL_L_NPC_SOCIAL_PARTNER_TAG = "dl_social_partner_tag";
const string DL_L_NPC_WEEKEND_MODE = "dl_weekend_mode";
const string DL_L_NPC_WEEKEND_SHIFT_LENGTH = "dl_weekend_shift_length";
const string DL_L_NPC_HOME_AREA_TAG = "dl_home_area_tag";
const string DL_L_NPC_WORK_AREA_TAG = "dl_work_area_tag";
const string DL_L_NPC_MEAL_AREA_TAG = "dl_meal_area_tag";
const string DL_L_NPC_SOCIAL_AREA_TAG = "dl_social_area_tag";
const string DL_L_NPC_PUBLIC_AREA_TAG = "dl_public_area_tag";
const string DL_L_NPC_WAKE_HOUR = "dl_wake_hour";
const string DL_L_NPC_SLEEP_HOURS = "dl_sleep_hours";
const string DL_L_NPC_SHIFT_START = "dl_shift_start";
const string DL_L_NPC_SHIFT_LENGTH = "dl_shift_length";
const string DL_L_NPC_DIAG_LAST_KEY = "dl_diag_last_key";
const string DL_L_NPC_DIAG_LAST_MINUTE = "dl_diag_last_minute";

const string DL_PROFILE_EARLY_WORKER = "early_worker";
const string DL_PROFILE_BLACKSMITH = "blacksmith";
const string DL_PROFILE_GATE_POST = "gate_post";
const string DL_PROFILE_TRADER = "trader";

const string DL_STATE_IDLE = "idle";
const string DL_STATE_SLEEP = "sleep";
const string DL_STATE_WORK = "work";
const string DL_STATE_SOCIAL = "social";
const string DL_STATE_MEAL = "meal";
const string DL_STATE_PUBLIC = "public";

const string DL_DIALOGUE_IDLE = "idle";
const string DL_DIALOGUE_SLEEP = "sleep";
const string DL_DIALOGUE_WORK = "work";
const string DL_DIALOGUE_SOCIAL = "social";

const string DL_SERVICE_OFF = "off";
const string DL_SERVICE_AVAILABLE = "available";

const string DL_MAT_SLEEP = "sleep";
const string DL_MAT_WORK = "work";
const string DL_MAT_SOCIAL = "social";
const string DL_MAT_MEAL = "meal";
const string DL_MAT_PUBLIC = "public";

const int DL_DIR_NONE = 0;
const int DL_DIR_SLEEP = 1;
const int DL_DIR_WORK = 2;
const int DL_DIR_SOCIAL = 3;
const int DL_DIR_MEAL = 4;
const int DL_DIR_PUBLIC = 5;
const int DL_SLEEP_PHASE_NONE = 0;
const int DL_SLEEP_PHASE_MOVING = 1;
const int DL_SLEEP_PHASE_JUMPING = 2;
const int DL_SLEEP_PHASE_ON_BED = 3;

const float DL_SLEEP_APPROACH_RADIUS = 1.50;
const float DL_SLEEP_BED_RADIUS = 1.10;
const float DL_WORK_ANCHOR_RADIUS = 1.60;

const int DL_GUARD_SHIFT_HOURS = 9;

const string DL_WORK_KIND_FORGE = "forge";
const string DL_WORK_KIND_CRAFT = "craft";
const string DL_WORK_KIND_POST = "post";
const string DL_WORK_KIND_TRADE = "trade";
const string DL_WEEKEND_MODE_OFF_PUBLIC = "off_public";
const string DL_WEEKEND_MODE_REDUCED_WORK = "reduced_work";
const string DL_MEAL_KIND_BREAKFAST = "breakfast";
const string DL_MEAL_KIND_LUNCH = "lunch";
const string DL_MEAL_KIND_DINNER = "dinner";

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

void DL_LogChat(string sMessage)
{
    object oPc = GetFirstPC();
    while (GetIsObjectValid(oPc))
    {
        SendMessageToPC(oPc, "[DL] " + sMessage);
        oPc = GetNextPC();
    }
}

void DL_LogMarkupIssueOnce(object oNpc, string sKey, string sMessage)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    string sLastKey = GetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY);
    int nLastMin = GetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE);
    if (sLastKey == sKey && (nNowAbsMin - nLastMin) < 30)
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_DIAG_LAST_KEY, sKey);
    SetLocalInt(oNpc, DL_L_NPC_DIAG_LAST_MINUTE, nNowAbsMin);
    DL_LogChat(sMessage);
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
    int nAbsoluteDay = (GetCalendarYear() * 12 * 28) + (GetCalendarMonth() * 28) + GetCalendarDay();
    int nDow = nAbsoluteDay % 7; // 0=Sunday, 6=Saturday in runtime convention
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
        nHours = 8;
    }
    return DL_ClampInt(nHours, 7, 10);
}

int DL_GetNpcWakeHour(object oNpc)
{
    int nWake = GetLocalInt(oNpc, DL_L_NPC_WAKE_HOUR);
    if (nWake < 0 || nWake > 23)
    {
        nWake = 6;
    }
    return nWake;
}

int DL_GetNpcShiftStart(object oNpc)
{
    int nStart = GetLocalInt(oNpc, DL_L_NPC_SHIFT_START);
    if (nStart == 0)
    {
        nStart = 8;
    }

    if (GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) == DL_PROFILE_GATE_POST)
    {
        int nLegacyGuardStart = GetLocalInt(oNpc, DL_L_NPC_GUARD_SHIFT_START);
        if (nLegacyGuardStart > 0 && nLegacyGuardStart <= 23)
        {
            nStart = nLegacyGuardStart;
        }
    }
    if (nStart < 0 || nStart > 23)
    {
        nStart = 8;
    }
    return nStart;
}

int DL_GetNpcShiftLength(object oNpc, int bWeekend)
{
    int nLen = GetLocalInt(oNpc, DL_L_NPC_SHIFT_LENGTH);
    if (nLen <= 0)
    {
        nLen = 8;
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
                nLen = 6;
            }
        }
        else if (sMode == DL_WEEKEND_MODE_OFF_PUBLIC)
        {
            nLen = 0;
        }
    }

    return nLen;
}

int DL_IsEarlyWorkerSleepHour(int nHour)
{
    nHour = DL_NormalizeHour(nHour);
    return nHour >= 22 || nHour < 6;
}

int DL_IsBlacksmithWorkHour(int nHour)
{
    nHour = DL_NormalizeHour(nHour);
    return nHour >= 8 && nHour < 18;
}

int DL_IsTraderWorkHour(int nHour)
{
    nHour = DL_NormalizeHour(nHour);
    return nHour >= 8 && nHour < 18;
}

int DL_IsHourInShiftWindow(int nHour, int nStartHour, int nDuration)
{
    nHour = DL_NormalizeHour(nHour);
    nStartHour = DL_NormalizeHour(nStartHour);

    int nOffset = nHour - nStartHour;
    if (nOffset < 0)
    {
        nOffset = nOffset + 24;
    }

    return nOffset >= 0 && nOffset < nDuration;
}

int DL_IsGatePostWorkHour(object oNpc, int nHour)
{
    return DL_IsHourInShiftWindow(nHour, GetLocalInt(oNpc, DL_L_NPC_GUARD_SHIFT_START), DL_GUARD_SHIFT_HOURS);
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
    int nShiftStart = DL_GetNpcShiftStart(oNpc) * 60;
    int nWeekendType = DL_GetWeekendType();
    int bWeekend = nWeekendType != 0;
    int nShiftLen = DL_GetNpcShiftLength(oNpc, bWeekend);
    int nShiftEnd = DL_NormalizeMinuteOfDay(nShiftStart + (nShiftLen * 60));
    string sTag = GetTag(oNpc);

    int nBreakfastStart = DL_NormalizeMinuteOfDay((nWake * 60) + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nDinnerStart = DL_NormalizeMinuteOfDay(nSleepStart - 75 + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nLunchStart = DL_NormalizeMinuteOfDay(nShiftStart + 240 + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nSocialStart = DL_NormalizeMinuteOfDay(nShiftEnd + 10 + DL_GetTagDeterministicOffset(sTag, 31, 15));
    int nPublicStart = DL_NormalizeMinuteOfDay((nWake * 60) + 180 + DL_GetTagDeterministicOffset(sTag, 41, 20));
    int nPublicLate = DL_NormalizeMinuteOfDay(nDinnerStart - 120 + DL_GetTagDeterministicOffset(sTag, 31, 15));

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

    int bInWorkWindow = nShiftLen > 0 && DL_MinuteInWindow(nNow, nShiftStart, nShiftLen * 60);
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

    if (nShiftLen > 0 && DL_MinuteInWindow(nNow, nShiftStart, nShiftLen * 60))
    {
        return DL_DIR_WORK;
    }

    return DL_DIR_NONE;
}

int DL_ResolveNpcDirective(object oNpc)
{
    return DL_ResolveNpcDirectiveAtMinute(oNpc, DL_GetNowMinuteOfDay());
}

void DL_ApplyMaterializationSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirective == DL_DIR_SLEEP)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SLEEP);
        return;
    }

    if (nDirective == DL_DIR_WORK)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_WORK);
        return;
    }

    if (nDirective == DL_DIR_SOCIAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_SOCIAL);
        return;
    }

    if (nDirective == DL_DIR_MEAL)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_MEAL);
        return;
    }

    if (nDirective == DL_DIR_PUBLIC)
    {
        SetLocalInt(oNpc, DL_L_NPC_MAT_REQ, TRUE);
        SetLocalString(oNpc, DL_L_NPC_MAT_TAG, DL_MAT_PUBLIC);
        return;
    }

    DeleteLocalInt(oNpc, DL_L_NPC_MAT_REQ);
    DeleteLocalString(oNpc, DL_L_NPC_MAT_TAG);
}

object DL_GetNpcCachedWaypointByTag(object oNpc, string sCacheLocal, string sTag)
{
    if (!GetIsObjectValid(oNpc) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sCacheLocal);
    if (GetIsObjectValid(oCached) && GetTag(oCached) == sTag)
    {
        return oCached;
    }

    object oWp = GetWaypointByTag(sTag);
    if (!GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    SetLocalObject(oNpc, sCacheLocal, oWp);
    return oWp;
}

object DL_ResolveEffectiveWaypointForNpc(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    if (GetArea(oWp) == GetArea(oNpc))
    {
        return oWp;
    }

    if (DL_WaypointHasTransition(oWp))
    {
        object oExitWp = DL_ResolveTransitionExitWaypointFromEntry(oWp);
        if (GetIsObjectValid(oExitWp) && GetArea(oExitWp) == GetArea(oNpc))
        {
            return oExitWp;
        }
    }

    return OBJECT_INVALID;
}

object DL_ResolveNpcWaypointWithFallbackTag(
    object oNpc,
    string sCacheLocal,
    string sPersonalPrefix,
    string sPersonalSuffix,
    string sFallbackTag
)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sNpcTag = GetTag(oNpc);
    object oWp = DL_ResolveEffectiveWaypointForNpc(
        oNpc,
        DL_GetNpcCachedWaypointByTag(oNpc, sCacheLocal, sPersonalPrefix + sNpcTag + sPersonalSuffix)
    );
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }

    return DL_ResolveEffectiveWaypointForNpc(
        oNpc,
        DL_GetNpcCachedWaypointByTag(oNpc, sCacheLocal, sFallbackTag)
    );
}

object DL_GetNpcAreaByTagCached(object oNpc, string sAreaTagLocal, string sAreaCacheLocal)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    string sAreaTag = GetLocalString(oNpc, sAreaTagLocal);
    if (sAreaTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sAreaCacheLocal);
    if (GetIsObjectValid(oCached) && GetTag(oCached) == sAreaTag)
    {
        return oCached;
    }

    object oArea = GetObjectByTag(sAreaTag);
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "invalid_area_" + sAreaTagLocal + "_" + sAreaTag,
            "NPC " + GetTag(oNpc) + ": area tag '" + sAreaTag + "' is invalid for local '" + sAreaTagLocal + "'."
        );
        return OBJECT_INVALID;
    }

    SetLocalObject(oNpc, sAreaCacheLocal, oArea);
    return oArea;
}

object DL_GetAreaAnchorWaypoint(object oNpc, object oArea, string sAnchorLocal, string sCacheLocal, int bRequired)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sWpTag = GetLocalString(oArea, sAnchorLocal);
    if (sWpTag == "")
    {
        if (bRequired)
        {
            DL_LogMarkupIssueOnce(
                oNpc,
                "missing_anchor_" + GetTag(oArea) + "_" + sAnchorLocal,
                "Area " + GetTag(oArea) + " misses required anchor '" + sAnchorLocal + "' for NPC " + GetTag(oNpc) + "."
            );
        }
        return OBJECT_INVALID;
    }

    object oWp = DL_GetNpcCachedWaypointByTag(oNpc, sCacheLocal, sWpTag);
    if (!GetIsObjectValid(oWp))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "missing_wp_" + GetTag(oArea) + "_" + sAnchorLocal + "_" + sWpTag,
            "Area " + GetTag(oArea) + " anchor '" + sAnchorLocal + "' points to missing waypoint '" + sWpTag + "'."
        );
        return OBJECT_INVALID;
    }
    return oWp;
}

object DL_GetHomeArea(object oNpc)
{
    object oHome = DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_HOME_AREA_TAG, DL_L_NPC_CACHE_HOME_AREA);
    if (!GetIsObjectValid(oHome))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "missing_home_area",
            "NPC " + GetTag(oNpc) + " has no valid home area (dl_home_area_tag)."
        );
    }
    return oHome;
}

object DL_GetWorkArea(object oNpc)
{
    return DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_WORK_AREA_TAG, DL_L_NPC_CACHE_WORK_AREA);
}

object DL_GetMealArea(object oNpc)
{
    return DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_MEAL_AREA_TAG, DL_L_NPC_CACHE_MEAL_AREA);
}

object DL_GetSocialArea(object oNpc)
{
    return DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_SOCIAL_AREA_TAG, DL_L_NPC_CACHE_SOCIAL_AREA);
}

object DL_GetPublicArea(object oNpc)
{
    return DL_GetNpcAreaByTagCached(oNpc, DL_L_NPC_PUBLIC_AREA_TAG, DL_L_NPC_CACHE_PUBLIC_AREA);
}

object DL_ResolveSleepApproachWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    return DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_sleep_approach", DL_L_NPC_CACHE_SLEEP_APPROACH, TRUE);
}

object DL_ResolveSleepBedWaypoint(object oNpc)
{
    object oHome = DL_GetHomeArea(oNpc);
    return DL_GetAreaAnchorWaypoint(oNpc, oHome, "dl_anchor_sleep_bed", DL_L_NPC_CACHE_SLEEP_BED, TRUE);
}

object DL_ResolveBlacksmithForgeWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_FORGE,
        "dl_work_",
        "_forge",
        "dl_work_forge"
    );
}

object DL_ResolveBlacksmithCraftWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_secondary", DL_L_NPC_CACHE_WORK_SECONDARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_CRAFT,
        "dl_work_",
        "_craft",
        "dl_work_craft"
    );
}

object DL_ResolveGatePostWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_POST,
        "dl_work_",
        "_post",
        "dl_work_post"
    );
}

object DL_ResolveTraderWaypoint(object oNpc)
{
    object oWork = DL_GetWorkArea(oNpc);
    object oWp = DL_GetAreaAnchorWaypoint(oNpc, oWork, "dl_anchor_work_primary", DL_L_NPC_CACHE_WORK_PRIMARY, FALSE);
    if (GetIsObjectValid(oWp))
    {
        return oWp;
    }
    return DL_ResolveNpcWaypointWithFallbackTag(
        oNpc,
        DL_L_NPC_CACHE_WORK_TRADE,
        "dl_work_",
        "_trade",
        "dl_work_trade"
    );
}

void DL_ClearSleepExecutionState(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);
}

void DL_ClearWorkExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_WORK_KIND);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);
}

void DL_ClearFocusExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DL_ClearTransitionExecutionState(oNpc);
}

void DL_ClearActivityPresentation(object oNpc)
{
    DeleteLocalInt(oNpc, DL_L_NPC_ACTIVITY_ID);
    DeleteLocalString(oNpc, DL_L_NPC_ANIM_SET);
}

void DL_SetActivityPresentation(object oNpc, int nActivityId, string sAnimSet)
{
    SetLocalInt(oNpc, DL_L_NPC_ACTIVITY_ID, nActivityId);
    SetLocalString(oNpc, DL_L_NPC_ANIM_SET, sAnimSet);
}

int DL_TryApplyWorkActivityPresentation(object oNpc, string sProfile, string sWorkKind)
{
    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        if (sWorkKind == DL_WORK_KIND_CRAFT)
        {
            DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_FORGE_MULTI, DL_ARCH_ANIMS_CRAFT);
            return TRUE;
        }

        DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_FORGE, DL_ARCH_ANIMS_FORGE);
        return TRUE;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_GUARD, DL_ARCH_ANIMS_GUARD);
        return TRUE;
    }

    if (sProfile == DL_PROFILE_TRADER)
    {
        DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_MERCHANT_MULTI, DL_ARCH_ANIMS_TRADE);
        return TRUE;
    }

    return FALSE;
}

void DL_ApplyArchiveActivityPresentation(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDirective == DL_DIR_SLEEP)
    {
        DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_SLEEP_BED, DL_ARCH_ANIMS_SLEEP_BED);
        return;
    }

    if (nDirective != DL_DIR_WORK)
    {
        DL_ClearActivityPresentation(oNpc);
        return;
    }

    string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
    string sWorkKind = GetLocalString(oNpc, DL_L_NPC_WORK_KIND);
    if (DL_TryApplyWorkActivityPresentation(oNpc, sProfile, sWorkKind))
    {
        return;
    }

    DL_ClearActivityPresentation(oNpc);
}

string DL_ResolveBlacksmithWorkKindAtHour(int nHour)
{
    nHour = DL_NormalizeHour(nHour);
    if ((nHour % 2) == 0)
    {
        return DL_WORK_KIND_FORGE;
    }

    return DL_WORK_KIND_CRAFT;
}

string DL_TrimAnimToken(string sToken)
{
    int nStart = 0;
    int nEnd = GetStringLength(sToken);

    while (nStart < nEnd && GetSubString(sToken, nStart, 1) == " ")
    {
        nStart = nStart + 1;
    }

    while (nEnd > nStart && GetSubString(sToken, nEnd - 1, 1) == " ")
    {
        nEnd = nEnd - 1;
    }

    return GetSubString(sToken, nStart, nEnd - nStart);
}

string DL_GetFirstAnimToken(string sAnimSet)
{
    int nComma = FindSubString(sAnimSet, ",");
    if (nComma < 0)
    {
        return DL_TrimAnimToken(sAnimSet);
    }

    return DL_TrimAnimToken(GetSubString(sAnimSet, 0, nComma));
}

string DL_GetSecondAnimToken(string sAnimSet)
{
    int nComma = FindSubString(sAnimSet, ",");
    if (nComma < 0)
    {
        return "";
    }

    string sTail = GetSubString(sAnimSet, nComma + 1, GetStringLength(sAnimSet) - (nComma + 1));
    int nSecondComma = FindSubString(sTail, ",");
    if (nSecondComma < 0)
    {
        return DL_TrimAnimToken(sTail);
    }

    return DL_TrimAnimToken(GetSubString(sTail, 0, nSecondComma));
}

void DL_PlaySleepAnimation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sAnimSet = GetLocalString(oNpc, DL_L_NPC_ANIM_SET);
    if (sAnimSet == "")
    {
        sAnimSet = DL_ARCH_ANIMS_SLEEP_BED;
    }

    string sLoopAnim = DL_GetSecondAnimToken(sAnimSet);
    if (sLoopAnim == "")
    {
        sLoopAnim = DL_GetFirstAnimToken(sAnimSet);
    }

    if (sLoopAnim == "")
    {
        return;
    }

    PlayCustomAnimation(oNpc, sLoopAnim, TRUE);
}

void DL_PlayWorkAnimation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sAnim = DL_GetFirstAnimToken(GetLocalString(oNpc, DL_L_NPC_ANIM_SET));
    if (sAnim == "")
    {
        return;
    }

    PlayCustomAnimation(oNpc, sAnim, TRUE);
}

void DL_SetWorkMissingState(object oNpc, string sKind, string sDiagnostic)
{
    SetLocalString(oNpc, DL_L_NPC_WORK_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, "missing_waypoints");
    SetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC, sDiagnostic);
    DeleteLocalString(oNpc, DL_L_NPC_WORK_TARGET);
    DL_ClearActivityPresentation(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
}

void DL_SetWorkTargetState(object oNpc, string sKind, object oTarget)
{
    SetLocalString(oNpc, DL_L_NPC_WORK_KIND, sKind);
    SetLocalString(oNpc, DL_L_NPC_WORK_TARGET, GetTag(oTarget));
    DeleteLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
}

void DL_SetSleepMissingState(object oNpc, int bInvalidArea)
{
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_NONE);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "missing_waypoints");
    if (bInvalidArea)
    {
        SetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC, "sleep_target_invalid_area");
    }
    else
    {
        DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    }
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_TARGET);
    DL_ClearTransitionExecutionState(oNpc);
}

void DL_SetSleepTargetState(object oNpc, object oBed)
{
    SetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET, GetTag(oBed));
    DeleteLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
}

void DL_QueueMoveAction(object oNpc, location lTarget, int bRun)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionMoveToLocation(lTarget, bRun));
}

void DL_QueueJumpAction(object oNpc, location lTarget)
{
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionJumpToLocation(lTarget));
}

int DL_ProgressWorkAtTarget(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (DL_WaypointHasTransition(oTarget))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oTarget))
        {
            return TRUE;
        }
    }

    location lTarget = GetLocation(oTarget);
    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) != "moving_to_anchor")
        {
            SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, "moving_to_anchor");
            DL_QueueMoveAction(oNpc, lTarget, TRUE);
        }
        return TRUE;
    }

    DL_ClearTransitionExecutionState(oNpc);
    SetLocalString(oNpc, DL_L_NPC_WORK_STATUS, "on_anchor");
    DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);
    DL_PlayWorkAnimation(oNpc);
    return TRUE;
}

int DL_ProgressFocusAtTarget(object oNpc, object oTarget, string sOnAnchorStatus, string sAnim)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (DL_WaypointHasTransition(oTarget))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oTarget))
        {
            return TRUE;
        }
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "moving_to_anchor")
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "moving_to_anchor");
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
            DL_QueueMoveAction(oNpc, GetLocation(oTarget), TRUE);
        }
        return TRUE;
    }

    DL_ClearTransitionExecutionState(oNpc);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, sOnAnchorStatus);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
    if (sAnim != "")
    {
        PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
    return TRUE;
}

string DL_ResolveMealKind(object oNpc)
{
    int nNow = DL_GetNowMinuteOfDay();
    int nWake = DL_GetNpcWakeHour(oNpc);
    int nSleepHours = DL_GetNpcSleepHours(oNpc);
    int nSleepStart = DL_NormalizeMinuteOfDay((nWake * 60) - (nSleepHours * 60));
    int nShiftStart = DL_GetNpcShiftStart(oNpc) * 60;
    int nShiftLen = DL_GetNpcShiftLength(oNpc, DL_GetWeekendType() != 0);
    string sTag = GetTag(oNpc);
    int nBreakfastStart = DL_NormalizeMinuteOfDay((nWake * 60) + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nLunchStart = DL_NormalizeMinuteOfDay(nShiftStart + 240 + DL_GetTagDeterministicOffset(sTag, 21, 10));
    int nDinnerStart = DL_NormalizeMinuteOfDay(nSleepStart - 75 + DL_GetTagDeterministicOffset(sTag, 21, 10));

    if (DL_MinuteInWindow(nNow, nBreakfastStart, 60))
    {
        return DL_MEAL_KIND_BREAKFAST;
    }
    if (nShiftLen >= 8 && DL_MinuteInWindow(nNow, nLunchStart, 30))
    {
        return DL_MEAL_KIND_LUNCH;
    }
    return DL_MEAL_KIND_DINNER;
}

object DL_ResolveMealWaypoint(object oNpc, string sMealKind)
{
    object oTargetArea = OBJECT_INVALID;
    if (sMealKind == DL_MEAL_KIND_LUNCH)
    {
        oTargetArea = DL_GetMealArea(oNpc);
        if (!GetIsObjectValid(oTargetArea))
        {
            oTargetArea = DL_GetWorkArea(oNpc);
        }
    }

    if (!GetIsObjectValid(oTargetArea))
    {
        oTargetArea = DL_GetHomeArea(oNpc);
    }

    return DL_GetAreaAnchorWaypoint(oNpc, oTargetArea, "dl_anchor_meal", DL_L_NPC_CACHE_MEAL, TRUE);
}

object DL_ResolveSocialWaypoint(object oNpc)
{
    object oArea = DL_GetSocialArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetWorkArea(oNpc);
    }

    string sSlot = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT);
    string sAnchor = sSlot == "b" ? "dl_anchor_social_b" : "dl_anchor_social_a";
    string sCache = sSlot == "b" ? DL_L_NPC_CACHE_SOCIAL_B : DL_L_NPC_CACHE_SOCIAL_A;
    return DL_GetAreaAnchorWaypoint(oNpc, oArea, sAnchor, sCache, FALSE);
}

object DL_ResolvePublicWaypoint(object oNpc)
{
    object oArea = DL_GetPublicArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetSocialArea(oNpc);
    }
    if (!GetIsObjectValid(oArea))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            "missing_public_area",
            "NPC " + GetTag(oNpc) + " has no public/social area for PUBLIC directive."
        );
        return OBJECT_INVALID;
    }
    return DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_public", DL_L_NPC_CACHE_PUBLIC, TRUE);
}

void DL_ExecuteSleepDirective(object oNpc)
{
    object oApproach = DL_ResolveSleepApproachWaypoint(oNpc);
    object oBed = DL_ResolveSleepBedWaypoint(oNpc);

    if (!GetIsObjectValid(oApproach) || !GetIsObjectValid(oBed))
    {
        DL_SetSleepMissingState(oNpc, FALSE);
        return;
    }

    DL_SetSleepTargetState(oNpc, oBed);

    if (DL_WaypointHasTransition(oApproach))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oApproach))
        {
            return;
        }
    }

    location lApproach = GetLocation(oApproach);
    location lBed = GetLocation(oBed);
    int nPhase = GetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS);
    int bCommittedToBed = nPhase == DL_SLEEP_PHASE_JUMPING || nPhase == DL_SLEEP_PHASE_ON_BED;

    if (!bCommittedToBed && GetDistanceBetween(oNpc, oApproach) > DL_SLEEP_APPROACH_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_MOVING || sStatus != "moving_to_approach")
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_MOVING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "moving_to_approach");
            DL_QueueMoveAction(oNpc, lApproach, TRUE);
        }
        return;
    }

    if (!bCommittedToBed)
    {
        SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
        SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "approach_reached");
        nPhase = DL_SLEEP_PHASE_JUMPING;
        sStatus = "approach_reached";
    }

    if (DL_WaypointHasTransition(oBed))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oBed))
        {
            return;
        }
    }

    if (GetDistanceBetween(oNpc, oBed) > DL_SLEEP_BED_RADIUS)
    {
        if (nPhase != DL_SLEEP_PHASE_JUMPING || sStatus != "jumping_to_bed")
        {
            SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_JUMPING);
            SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "jumping_to_bed");
            DL_QueueJumpAction(oNpc, lBed);
        }
        return;
    }

    if (nPhase != DL_SLEEP_PHASE_ON_BED || sStatus != "on_bed")
    {
        DL_PlaySleepAnimation(oNpc);
    }

    DL_ClearTransitionExecutionState(oNpc);
    SetLocalInt(oNpc, DL_L_NPC_SLEEP_PHASE, DL_SLEEP_PHASE_ON_BED);
    SetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS, "on_bed");
}

void DL_ExecuteWorkDirective(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);

    if (sProfile != DL_PROFILE_BLACKSMITH && sProfile != DL_PROFILE_GATE_POST && sProfile != DL_PROFILE_TRADER)
    {
        DL_ClearWorkExecutionState(oNpc);
        return;
    }

    if (sProfile == DL_PROFILE_BLACKSMITH)
    {
        string sKind = DL_ResolveBlacksmithWorkKindAtHour(GetTimeHour());
        object oForge = DL_ResolveBlacksmithForgeWaypoint(oNpc);
        object oCraft = DL_ResolveBlacksmithCraftWaypoint(oNpc);

        if (!GetIsObjectValid(oForge) || !GetIsObjectValid(oCraft))
        {
            DL_SetWorkMissingState(oNpc, sKind, "need_forge_and_craft_waypoints");
            return;
        }

        object oTarget = sKind == DL_WORK_KIND_CRAFT ? oCraft : oForge;
        DL_SetWorkTargetState(oNpc, sKind, oTarget);
        DL_ProgressWorkAtTarget(oNpc, oTarget);
        return;
    }

    if (sProfile == DL_PROFILE_GATE_POST)
    {
        object oPost = DL_ResolveGatePostWaypoint(oNpc);

        if (!GetIsObjectValid(oPost))
        {
            DL_SetWorkMissingState(oNpc, DL_WORK_KIND_POST, "need_post_waypoint");
            return;
        }

        DL_SetWorkTargetState(oNpc, DL_WORK_KIND_POST, oPost);
        DL_ProgressWorkAtTarget(oNpc, oPost);
        return;
    }

    object oTrade = DL_ResolveTraderWaypoint(oNpc);

    if (!GetIsObjectValid(oTrade))
    {
        DL_SetWorkMissingState(oNpc, DL_WORK_KIND_TRADE, "need_trade_waypoint");
        return;
    }

    DL_SetWorkTargetState(oNpc, DL_WORK_KIND_TRADE, oTrade);
    DL_ProgressWorkAtTarget(oNpc, oTrade);
}

void DL_ExecuteMealDirective(object oNpc)
{
    string sMealKind = DL_ResolveMealKind(oNpc);
    object oMeal = DL_ResolveMealWaypoint(oNpc, sMealKind);
    if (!GetIsObjectValid(oMeal))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_meal_anchor");
        return;
    }

    string sAnim = "siteat";
    if (sMealKind == DL_MEAL_KIND_BREAKFAST)
    {
        sAnim = "sitdrink";
    }
    else if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
    {
        sAnim = "sitdrink";
    }

    DL_ProgressFocusAtTarget(oNpc, oMeal, "on_meal_anchor_" + sMealKind, sAnim);
}

void DL_ExecutePublicDirective(object oNpc)
{
    object oPublic = DL_ResolvePublicWaypoint(oNpc);
    if (!GetIsObjectValid(oPublic))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_public_anchor");
        return;
    }

    string sAnim = "pause";
    if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
    {
        sAnim = "talk01";
    }
    DL_ProgressFocusAtTarget(oNpc, oPublic, "on_public_anchor", sAnim);
}

void DL_ExecuteSocialDirective(object oNpc)
{
    object oMe = DL_ResolveSocialWaypoint(oNpc);
    string sPartnerTag = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PARTNER_TAG);
    if (!GetIsObjectValid(oMe) || sPartnerTag == "")
    {
        DL_ExecutePublicDirective(oNpc);
        return;
    }

    object oPartner = GetObjectByTag(sPartnerTag);
    if (!GetIsObjectValid(oPartner) || GetLocalInt(oPartner, DL_L_NPC_DIRECTIVE) != DL_DIR_SOCIAL)
    {
        DL_ExecutePublicDirective(oNpc);
        return;
    }

    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);
    if (!GetIsObjectValid(oPartnerWp))
    {
        DL_ExecutePublicDirective(oNpc);
        return;
    }

    int bMeOnAnchor = GetDistanceBetween(oNpc, oMe) <= DL_WORK_ANCHOR_RADIUS;
    int bPartnerOnAnchor = GetDistanceBetween(oPartner, oPartnerWp) <= DL_WORK_ANCHOR_RADIUS;
    string sAnim = "";
    string sStatus = "moving_social_pair";
    if (bMeOnAnchor && bPartnerOnAnchor)
    {
        sStatus = "on_social_anchor";
        sAnim = "talk01";
        if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
        {
            sAnim = "talk02";
        }
    }

    DL_ProgressFocusAtTarget(oNpc, oMe, sStatus, sAnim);
}

void DL_SetInteractionModes(object oNpc, string sDialogue, string sService)
{
    SetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE, sDialogue);
    SetLocalString(oNpc, DL_L_NPC_SERVICE_MODE, sService);
}

int DL_IsProfileServiceAvailable(string sProfile)
{
    return sProfile != DL_PROFILE_GATE_POST;
}

void DL_ApplyIdleLikeDirectiveState(object oNpc, int bSocial)
{
    SetLocalString(oNpc, DL_L_NPC_STATE, bSocial ? DL_STATE_SOCIAL : DL_STATE_IDLE);
    DL_SetInteractionModes(
        oNpc,
        bSocial ? DL_DIALOGUE_SOCIAL : DL_DIALOGUE_IDLE,
        DL_SERVICE_OFF
    );
    DL_ClearSleepExecutionState(oNpc);
    DL_ClearWorkExecutionState(oNpc);
    DL_ClearFocusExecutionState(oNpc);
    DL_ClearActivityPresentation(oNpc);
}

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_DIRECTIVE, nDirective);

    if (nDirective == DL_DIR_SLEEP)
    {
        DL_ClearWorkExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SLEEP);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SLEEP, DL_SERVICE_OFF);
        DL_ApplyArchiveActivityPresentation(oNpc, nDirective);
        DL_ExecuteSleepDirective(oNpc);
    }
    else if (nDirective == DL_DIR_WORK)
    {
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_WORK);
        string sProfile = GetLocalString(oNpc, DL_L_NPC_PROFILE_ID);
        DL_SetInteractionModes(
            oNpc,
            DL_DIALOGUE_WORK,
            DL_IsProfileServiceAvailable(sProfile) ? DL_SERVICE_AVAILABLE : DL_SERVICE_OFF
        );

        DL_ClearSleepExecutionState(oNpc);
        DL_ClearFocusExecutionState(oNpc);
        DL_ExecuteWorkDirective(oNpc);
    }
    else if (nDirective == DL_DIR_MEAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_MEAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecuteMealDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nDirective == DL_DIR_SOCIAL)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_SOCIAL);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_SOCIAL, DL_SERVICE_OFF);
        DL_ExecuteSocialDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else if (nDirective == DL_DIR_PUBLIC)
    {
        DL_ClearSleepExecutionState(oNpc);
        DL_ClearWorkExecutionState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_STATE, DL_STATE_PUBLIC);
        DL_SetInteractionModes(oNpc, DL_DIALOGUE_IDLE, DL_SERVICE_OFF);
        DL_ExecutePublicDirective(oNpc);
        DL_ClearActivityPresentation(oNpc);
    }
    else
    {
        DL_ApplyIdleLikeDirectiveState(oNpc, FALSE);
    }

    DL_ApplyMaterializationSkeleton(oNpc, nDirective);
}
