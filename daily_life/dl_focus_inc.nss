const string DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ = "dl_cache_social_partner_obj";
const string DL_L_NPC_CACHE_CHILL_CHAIR_OBJ = "dl_cache_chill_chair_obj";
const string DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL = "dl_cache_chill_chair_missing_until";
const string DL_L_NPC_CHILL_SIT_RETRY_UNTIL = "dl_chill_sit_retry_until";
const string DL_L_NPC_CHILL_WAYPOINT_MODE = "dl_chill_waypoint_mode";
const string DL_L_WP_CHILL_CHAIR_TAG = "dl_chill_chair_tag";
const int DL_SOCIAL_PARTNER_TAG_SEARCH_CAP = 32;
const int DL_CHILL_MISSING_CACHE_TTL_MINUTES = 10;
const int DL_CHILL_SIT_RETRY_MINUTES = 1;
const string DL_CHILL_ANIM_SIT_IDLE = "sitidle";

void DL_ClearFocusExecutionState(object oNpc)
{
    DL_ClearNpcSocialReservation(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    DL_ClearTransitionExecutionState(oNpc);
}
object DL_ResolveSocialPartnerObject(object oNpc, string sPartnerTag)
{
    if (!GetIsObjectValid(oNpc) || sPartnerTag == "")
    {
        DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
    if (GetIsObjectValid(oCached) &&
        oCached != oNpc &&
        GetTag(oCached) == sPartnerTag &&
        DL_IsActivePipelineNpc(oCached) &&
        GetArea(oCached) == GetArea(oNpc))
    {
        return oCached;
    }

    int bTagFound = FALSE;
    int bTagFoundOutsideArea = FALSE;
    object oPartner = OBJECT_INVALID;
    int nTagIndex = 0;
    object oCandidate = GetObjectByTag(sPartnerTag, nTagIndex);
    while (GetIsObjectValid(oCandidate) && nTagIndex < DL_SOCIAL_PARTNER_TAG_SEARCH_CAP)
    {
        bTagFound = TRUE;

        if (oCandidate == oNpc)
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "social_partner_self");
            DL_LogChatDebugEvent(oNpc, "fallback_social_public", "fallback social->public reason=social_partner_self");
        }
        else if (!DL_IsActivePipelineNpc(oCandidate))
        {
            // Keep scanning for a suitable active pipeline NPC.
        }
        else if (GetArea(oCandidate) == GetArea(oNpc))
        {
            oPartner = oCandidate;
            break;
        }
        else
        {
            bTagFoundOutsideArea = TRUE;
        }

        nTagIndex = nTagIndex + 1;
        oCandidate = GetObjectByTag(sPartnerTag, nTagIndex);
    }

    if (!GetIsObjectValid(oPartner))
    {
        DeleteLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
        if (bTagFoundOutsideArea)
        {
            DL_LogChatDebugEvent(
                oNpc,
                "social_partner_lookup",
                "social partner lookup tag=" + sPartnerTag + " result=found_outside_area"
            );
        }
        else if (!bTagFound)
        {
            DL_LogChatDebugEvent(
                oNpc,
                "social_partner_lookup",
                "social partner lookup tag=" + sPartnerTag + " result=tag_not_found"
            );
        }
        return OBJECT_INVALID;
    }

    SetLocalObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ, oPartner);
    return oPartner;
}
object DL_GetNpcCachedPlaceableByTagInArea(object oNpc, string sCacheLocal, string sTag, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, sCacheLocal);
    if (GetIsObjectValid(oCached) &&
        GetTag(oCached) == sTag &&
        GetObjectType(oCached) == OBJECT_TYPE_PLACEABLE &&
        GetArea(oCached) == oArea)
    {
        return oCached;
    }
    DeleteLocalObject(oNpc, sCacheLocal);

    int nNth = 0;
    while (nNth < DL_WAYPOINT_TAG_SEARCH_CAP)
    {
        object oCandidate = GetObjectByTag(sTag, nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetObjectType(oCandidate) == OBJECT_TYPE_PLACEABLE && GetArea(oCandidate) == oArea)
        {
            SetLocalObject(oNpc, sCacheLocal, oCandidate);
            return oCandidate;
        }

        nNth = nNth + 1;
    }

    return OBJECT_INVALID;
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

    if (DL_TryUseNavigationRouteToTarget(oNpc, oTarget))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "moving_to_anchor")
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "moving_to_anchor");
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
            DL_QueueMoveAction(oNpc, GetLocation(oTarget), TRUE);
        }
        return TRUE;
    }

    DL_ClearTransitionExecutionState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, sOnAnchorStatus);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
    AssignCommand(oNpc, SetFacing(GetFacing(oTarget)));
    if (sAnim != "")
    {
        PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
    DL_LogChatDebugEvent(oNpc, sOnAnchorStatus, sOnAnchorStatus + " anchor=" + GetTag(oTarget));
    return TRUE;
}
string DL_ResolveMealKind(object oNpc)
{
    int nNow = DL_GetNowMinuteOfDay();
    int nWake = DL_GetNpcWakeHour(oNpc);
    int nSleepHours = DL_GetNpcSleepHours(oNpc);
    int nSleepStart = DL_NormalizeMinuteOfDay((nWake * 60) - (nSleepHours * 60));
    int bWeekend = DL_GetWeekendType() != 0;
    int bHasWorkWindow = DL_NpcHasWorkDirectiveWindow(oNpc, bWeekend);
    int nShiftLen = bHasWorkWindow ? DL_GetNpcShiftLength(oNpc, bWeekend) : 0;
    int nShiftStartHour = DL_GetNpcShiftStart(oNpc);
    if (nShiftStartHour == 0 && GetLocalInt(oNpc, DL_L_NPC_SHIFT_LENGTH) <= 0 && bHasWorkWindow)
    {
        nShiftStartHour = 8;
    }
    int nShiftStart = nShiftStartHour * 60;
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
            if (GetIsObjectValid(oTargetArea))
            {
                DL_LogChatDebugEvent(
                    oNpc,
                    "fallback_meal_work",
                    "fallback meal->work reason=missing_meal_area kind=" + sMealKind + " area=" + GetTag(oTargetArea)
                );
            }
        }
    }

    if (!GetIsObjectValid(oTargetArea))
    {
        oTargetArea = DL_GetHomeArea(oNpc);
        if (GetIsObjectValid(oTargetArea) && sMealKind == DL_MEAL_KIND_LUNCH)
        {
            DL_LogChatDebugEvent(
                oNpc,
                "fallback_meal_home",
                "fallback meal->home reason=missing_meal_and_work_area kind=" + sMealKind + " area=" + GetTag(oTargetArea)
            );
        }
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
object DL_ResolveChillWaypoint(object oNpc)
{
    int nNowAbs = DL_GetAbsoluteMinute();
    int nMissingUntil = GetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
    if (nMissingUntil > nNowAbs)
    {
        return OBJECT_INVALID;
    }

    object oArea = DL_GetHomeArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    object oSeat = DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_CHILL_SEAT,
        oArea,
        "dl_chill_",
        "_seat",
        "dl_chill_seat_" + IntToString(nSlot)
    );

    if (GetIsObjectValid(oSeat))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
        return oSeat;
    }

    SetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL, nNowAbs + DL_CHILL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}
object DL_ResolveChillChairObject(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return OBJECT_INVALID;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nMissingUntil = GetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
    if (nMissingUntil > nNowAbs)
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oSeat);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sChairTag = GetLocalString(oSeat, DL_L_WP_CHILL_CHAIR_TAG);
    object oChair = OBJECT_INVALID;
    if (sChairTag != "")
    {
        oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_OBJ, sChairTag, oArea);
        if (GetIsObjectValid(oChair))
        {
            DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
            return oChair;
        }
    }

    string sNpcTag = GetTag(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_OBJ, "dl_chill_" + sNpcTag + "_chair", oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_OBJ, "dl_chill_chair_" + IntToString(nSlot), oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    SetLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL, nNowAbs + DL_CHILL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
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
    else if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 6, 0) % 6) == 0)
    {
        sAnim = "sitdrink";
    }

    DL_LogChatDebugEvent(
        oNpc,
        "target_meal",
        "target dir=MEAL area=" + GetTag(GetArea(oMeal)) + " anchor=" + GetTag(oMeal) + " kind=" + sMealKind
    );
    DL_ProgressFocusAtTarget(oNpc, oMeal, "on_meal_anchor_" + sMealKind, sAnim);
}
int DL_ProgressChillAtSeat(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return FALSE;
    }

    if (DL_WaypointHasTransition(oSeat))
    {
        if (DL_TryExecuteTransitionAtWaypoint(oNpc, oSeat))
        {
            return TRUE;
        }
    }

    if (DL_TryUseNavigationRouteToTarget(oNpc, oSeat))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oSeat) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "moving_to_anchor")
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "moving_to_anchor");
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
            DL_QueueMoveAction(oNpc, GetLocation(oSeat), TRUE);
        }
        return TRUE;
    }

    DL_ClearTransitionExecutionState(oNpc);
    if (GetLocalInt(oNpc, DL_L_NPC_CHILL_WAYPOINT_MODE) == TRUE)
    {
        return DL_ProgressFocusAtTarget(oNpc, oSeat, "on_chill_anchor", DL_CHILL_ANIM_SIT_IDLE);
    }

    object oChair = DL_ResolveChillChairObject(oNpc, oSeat);
    if (!GetIsObjectValid(oChair))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "missing_chill_chair");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_chill_chair");
        return TRUE;
    }

    object oSitter = GetSittingCreature(oChair);
    if (oSitter == oNpc)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_chill_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        DL_LogChatDebugEvent(oNpc, "on_chill_anchor", "on_chill_anchor chair=" + GetTag(oChair));
        return TRUE;
    }

    if (GetIsObjectValid(oSitter) && oSitter != oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "chill_chair_occupied");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "chill_chair_occupied");
        return TRUE;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nRetryUntil = GetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "sitting_chill_attempt" && nRetryUntil > nNowAbs)
    {
        return TRUE;
    }

    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "sitting_chill_attempt");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
    SetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL, nNowAbs + DL_CHILL_SIT_RETRY_MINUTES);
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionSit(oChair));
    DL_LogChatDebugEvent(oNpc, "sitting_chill_attempt", "sitting_chill_attempt chair=" + GetTag(oChair));
    return TRUE;
}
void DL_ExecuteChillDirective(object oNpc)
{
    object oSeat = DL_ResolveChillWaypoint(oNpc);
    if (!GetIsObjectValid(oSeat))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_chill_seat");
        return;
    }

    DL_LogChatDebugEvent(
        oNpc,
        "target_chill",
        "target dir=CHILL area=" + GetTag(GetArea(oSeat)) + " anchor=" + GetTag(oSeat)
    );
    DL_ProgressChillAtSeat(oNpc, oSeat);
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
    DL_LogChatDebugEvent(
        oNpc,
        "target_public",
        "target dir=PUBLIC area=" + GetTag(GetArea(oPublic)) + " anchor=" + GetTag(oPublic)
    );
    DL_ProgressFocusAtTarget(oNpc, oPublic, "on_public_anchor", sAnim);
}
int DL_ShouldFallbackSocialToPublic(object oNpc)
{
    string sKind = DL_GetNpcSocialKind(oNpc);
    if (DL_IsStandaloneSocialKind(sKind))
    {
        return FALSE;
    }

    object oMe = DL_ResolveSocialWaypoint(oNpc);
    string sPartnerTag = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PARTNER_TAG);
    if (!GetIsObjectValid(oMe) || sPartnerTag == "")
    {
        DL_LogChatDebugEvent(oNpc, "fallback_social_public", "fallback social->public reason=missing_social_anchor_or_partner");
        return TRUE;
    }

    object oPartner = DL_ResolveSocialPartnerObject(oNpc, sPartnerTag);
    if (!GetIsObjectValid(oPartner) || GetLocalInt(oPartner, DL_L_NPC_DIRECTIVE) != DL_DIR_SOCIAL)
    {
        DL_LogChatDebugEvent(oNpc, "fallback_social_public", "fallback social->public reason=partner_not_social");
        return TRUE;
    }

    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);
    if (!GetIsObjectValid(oPartnerWp))
    {
        DL_LogChatDebugEvent(oNpc, "fallback_social_public", "fallback social->public reason=partner_missing_social_anchor");
        return TRUE;
    }

    return FALSE;
}
void DL_ExecuteSocialDirective(object oNpc)
{
    string sKind = DL_GetNpcSocialKind(oNpc);
    if (DL_IsStandaloneSocialKind(sKind))
    {
        object oSocial = DL_ResolveStandaloneSocialWaypoint(oNpc, sKind);
        if (!GetIsObjectValid(oSocial))
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_social_pool_" + sKind);
            return;
        }

        string sAnim = DL_GetStandaloneSocialAnimation(sKind);
        DL_LogChatDebugEvent(
            oNpc,
            "target_social_" + sKind,
            "target dir=SOCIAL kind=" + sKind + " area=" + GetTag(GetArea(oSocial)) + " anchor=" + GetTag(oSocial)
        );
        DL_ProgressFocusAtTarget(oNpc, oSocial, "on_social_" + sKind, sAnim);
        return;
    }

    object oMe = DL_ResolveSocialWaypoint(oNpc);
    string sPartnerTag = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PARTNER_TAG);
    object oPartner = DL_ResolveSocialPartnerObject(oNpc, sPartnerTag);
    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);

    if (!GetIsObjectValid(oMe) || !GetIsObjectValid(oPartner) || !GetIsObjectValid(oPartnerWp))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "social_fallback_to_public");
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

    DL_LogChatDebugEvent(
        oNpc,
        "target_social",
        "target dir=SOCIAL area=" + GetTag(GetArea(oMe)) + " anchor=" + GetTag(oMe) +
            " slot=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) +
            " partner=" + sPartnerTag
    );
    DL_ProgressFocusAtTarget(oNpc, oMe, sStatus, sAnim);
}
