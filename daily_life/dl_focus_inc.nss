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

const string DL_EVT_FOCUS_FALLBACK_SOCIAL_PUBLIC = "fallback_social_public";
const string DL_EVT_FOCUS_SOCIAL_PARTNER_LOOKUP = "social_partner_lookup";
void DL_ClearFocusExecutionState(object oNpc)
{
    DL_ClearNpcSocialReservation(oNpc);
    DL_ResetNpcDirectiveState(oNpc, DL_NPC_RESET_DOMAIN_FOCUS);
    DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
}
object DL_ResolveSocialPartnerObject(object oNpc, string sPartnerTag)
{
    if (!GetIsObjectValid(oNpc) || sPartnerTag == "")
    {
        DL_InvalidateCachedObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    int nTier = DL_GetAreaTier(oArea);
    int nLifecycleSeq = GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ);
    object oCached = DL_GetCachedObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ, sPartnerTag, OBJECT_TYPE_CREATURE, oArea, nTier, nLifecycleSeq);
    if (GetIsObjectValid(oCached) && oCached != oNpc && DL_IsActivePipelineNpc(oCached))
    {
        return oCached;
    }

    int bTagFound = GetIsObjectValid(GetObjectByTag(sPartnerTag, 0));
    int bTagFoundOutsideArea = FALSE;

    object oSelfCandidate = DL_FindObjectByTagWithChecks(sPartnerTag, DL_SOCIAL_PARTNER_TAG_SEARCH_CAP, OBJECT_TYPE_CREATURE, OBJECT_INVALID, OBJECT_INVALID, FALSE);
    if (GetIsObjectValid(oSelfCandidate) && oSelfCandidate == oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_SOCIAL_PARTNER_SELF);
        DL_LogSocialEvent(oNpc, DL_EVT_FOCUS_FALLBACK_SOCIAL_PUBLIC, "reason=" + DL_DIAG_FOCUS_SOCIAL_PARTNER_SELF);
    }

    object oPartner = DL_FindObjectByTagWithChecks(
        sPartnerTag,
        DL_SOCIAL_PARTNER_TAG_SEARCH_CAP,
        OBJECT_TYPE_CREATURE,
        GetArea(oNpc),
        oNpc,
        TRUE
    );
    if (!GetIsObjectValid(oPartner) && bTagFound)
    {
        object oAnyAreaPartner = DL_FindObjectByTagWithChecks(
            sPartnerTag,
            DL_SOCIAL_PARTNER_TAG_SEARCH_CAP,
            OBJECT_TYPE_CREATURE,
            OBJECT_INVALID,
            oNpc,
            TRUE
        );
        bTagFoundOutsideArea = GetIsObjectValid(oAnyAreaPartner);
    }

    if (!GetIsObjectValid(oPartner))
    {
        DL_InvalidateCachedObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ);
        if (bTagFoundOutsideArea)
        {
            DL_LogSocialEvent(
                oNpc,
                DL_EVT_FOCUS_SOCIAL_PARTNER_LOOKUP,
                "tag=" + sPartnerTag + " result=" + DL_MSG_RESULT_FOUND_OUTSIDE_AREA
            );
        }
        else if (!bTagFound)
        {
            DL_LogSocialEvent(
                oNpc,
                DL_EVT_FOCUS_SOCIAL_PARTNER_LOOKUP,
                "tag=" + sPartnerTag + " result=" + DL_MSG_RESULT_TAG_NOT_FOUND
            );
        }
        return OBJECT_INVALID;
    }

    DL_SetCachedObject(oNpc, DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ, oPartner, sPartnerTag, OBJECT_TYPE_CREATURE, oArea, nTier, nLifecycleSeq);
    return oPartner;
}
object DL_GetNpcCachedPlaceableByTagInArea(object oNpc, string sCacheLocal, string sTag, object oArea)
{
    return DL_GetNpcCachedObjectByTagInArea(
        oNpc,
        sCacheLocal,
        sTag,
        OBJECT_TYPE_PLACEABLE,
        oArea,
        DL_WAYPOINT_TAG_SEARCH_CAP,
        "anchor"
    );
}
// Domain contract: interpret navigation result only; do not mutate transition locals directly.
int DL_ProgressFocusAtTarget(object oNpc, object oTarget, string sOnAnchorStatus, string sAnim)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return FALSE;
    }

    if (DL_TryAdvanceViaTransitionOrRoute(oNpc, oTarget, DL_DIAG_CTX_ROUTED))
    {
        return TRUE;
    }

    float fTargetDistance = GetDistanceBetween(oNpc, oTarget);
    if (fTargetDistance > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldRedispatchMovement(oNpc, DL_L_NPC_FOCUS_STATUS, DL_STATUS_MOVING_TO_ANCHOR, fTargetDistance, DL_WORK_ANCHOR_RADIUS))
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_STATUS_MOVING_TO_ANCHOR);
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
            DL_QueueMoveAction(oNpc, GetLocation(oTarget), TRUE);
        }
        return TRUE;
    }

    DL_OnNpcArrivedAtAnchor(oNpc, oTarget, DL_L_NPC_FOCUS_STATUS, sOnAnchorStatus, DL_L_NPC_FOCUS_DIAGNOSTIC, sAnim, TRUE);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
    DL_CommandSetFacing(oNpc, GetFacing(oTarget));
    if (sAnim != "")
    {
        PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
    DL_LogSocialEvent(oNpc, sOnAnchorStatus, DL_BuildAnchorTelemetry(oNpc, oTarget, "", "focus"));
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
    object oTargetArea = DL_ResolvePreferredAreaWithFallbacks(oNpc, DL_AREA_PURPOSE_MEAL);
    if (sMealKind == DL_MEAL_KIND_LUNCH && GetLocalString(oNpc, DL_L_NPC_MEAL_AREA_TAG) == "")
    {
        string sReason = DL_FB_REASON_FOCUS_MISSING_MEAL_AREA;
        if (!GetIsObjectValid(DL_GetWorkArea(oNpc)))
        {
            sReason = DL_FB_REASON_FOCUS_MISSING_MEAL_AND_WORK_AREA;
        }
        DL_LogSocialEvent(oNpc, "fallback_meal_policy", "reason=" + sReason + " kind=" + sMealKind + " area=" + GetTag(oTargetArea));
    }
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_GetAreaAnchorWaypoint(oNpc, oTargetArea, "dl_anchor_meal", DL_L_NPC_CACHE_MEAL, TRUE));
}
object DL_ResolveSocialWaypoint(object oNpc)
{
    object oArea = DL_ResolvePreferredAreaWithFallbacks(oNpc, DL_AREA_PURPOSE_SOCIAL);

    string sSlot = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT);
    string sAnchor = sSlot == "b" ? "dl_anchor_social_b" : "dl_anchor_social_a";
    string sCache = sSlot == "b" ? DL_L_NPC_CACHE_SOCIAL_B : DL_L_NPC_CACHE_SOCIAL_A;
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_GetAreaAnchorWaypoint(oNpc, oArea, sAnchor, sCache, FALSE));
}
object DL_ResolvePublicWaypoint(object oNpc)
{
    object oArea = DL_ResolvePreferredAreaWithFallbacks(oNpc, DL_AREA_PURPOSE_PUBLIC);
    if (!GetIsObjectValid(oArea))
    {
        DL_LogMarkupIssueOnce(
            oNpc,
            DL_DIAG_FOCUS_MISSING_PUBLIC_ANCHOR,
            "NPC " + GetTag(oNpc) + " " + DL_MSG_FOCUS_MISSING_PUBLIC_AREA
        );
        return OBJECT_INVALID;
    }
    return DL_ResolveEffectiveWaypointForNpc(oNpc, DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_public", DL_L_NPC_CACHE_PUBLIC, TRUE));
}
object DL_ResolveChillWaypoint(object oNpc)
{
    if (DL_IsMinuteCooldownActive(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL))
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

    oSeat = DL_ResolveEffectiveWaypointForNpc(oNpc, oSeat);
    if (GetIsObjectValid(oSeat))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL);
        return oSeat;
    }

    DL_SetMinuteCooldown(oNpc, DL_L_NPC_CACHE_CHILL_SEAT_MISSING_UNTIL, DL_CHILL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}
object DL_ResolveChillChairObject(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return OBJECT_INVALID;
    }

    if (DL_IsMinuteCooldownActive(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL))
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

    DL_SetMinuteCooldown(oNpc, DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL, DL_CHILL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}
void DL_ExecuteMealDirective(object oNpc)
{
    string sMealKind = DL_ResolveMealKind(oNpc);
    object oMeal = DL_ResolveMealWaypoint(oNpc, sMealKind);
    if (!GetIsObjectValid(oMeal))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_MISSING_MEAL_ANCHOR);
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

    DL_LogSocialEvent(
        oNpc,
        "target_meal",
        DL_BuildAnchorTelemetry(oNpc, oMeal, "target dir=MEAL kind=" + sMealKind, "focus")
    );
    DL_ProgressFocusAtTarget(oNpc, oMeal, "on_meal_anchor_" + sMealKind, sAnim);
}
int DL_ProgressChillAtSeat(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return FALSE;
    }

    if (DL_TryAdvanceViaTransitionOrRoute(oNpc, oSeat, DL_DIAG_CTX_ROUTED))
    {
        return TRUE;
    }

    float fSeatDistance = GetDistanceBetween(oNpc, oSeat);
    if (fSeatDistance > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldRedispatchMovement(oNpc, DL_L_NPC_FOCUS_STATUS, DL_STATUS_MOVING_TO_ANCHOR, fSeatDistance, DL_WORK_ANCHOR_RADIUS))
        {
            SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_STATUS_MOVING_TO_ANCHOR);
            SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
            DL_QueueMoveAction(oNpc, GetLocation(oSeat), TRUE);
        }
        return TRUE;
    }

    DL_ClearTransitionExecutionState(oNpc);
    if (GetLocalInt(oNpc, DL_L_NPC_CHILL_WAYPOINT_MODE) == TRUE)
    {
        return DL_ProgressFocusAtTarget(oNpc, oSeat, DL_STATUS_ON_CHILL_ANCHOR, DL_CHILL_ANIM_SIT_IDLE);
    }

    object oChair = DL_ResolveChillChairObject(oNpc, oSeat);
    if (!GetIsObjectValid(oChair))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_DIAG_FOCUS_MISSING_CHILL_CHAIR);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_MISSING_CHILL_CHAIR);
        return TRUE;
    }

    object oSitter = GetSittingCreature(oChair);
    if (oSitter == oNpc)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
        DL_SetRuntimeState(oNpc, DL_L_NPC_FOCUS_STATUS, DL_STATUS_ON_CHILL_ANCHOR, "", "");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        DL_LogSocialEvent(oNpc, DL_STATUS_ON_CHILL_ANCHOR, "chair=" + GetTag(oChair));
        return TRUE;
    }

    if (GetIsObjectValid(oSitter) && oSitter != oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, DL_DIAG_FOCUS_CHILL_CHAIR_OCCUPIED);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_CHILL_CHAIR_OCCUPIED);
        return TRUE;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == DL_STATUS_SITTING_CHILL_ATTEMPT &&
        DL_IsMinuteCooldownActive(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL))
    {
        return TRUE;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DL_SetRuntimeState(oNpc, DL_L_NPC_FOCUS_STATUS, DL_STATUS_SITTING_CHILL_ATTEMPT, "", "");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
    SetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL, nNowAbs + DL_CHILL_SIT_RETRY_MINUTES);
    DL_OrchestrateRuntimeAction(oNpc, DL_ORCH_ACT_NONE, OBJECT_INVALID, LOCATION_INVALID, "", TRUE, "", "", "", "", "", "", "", "", "dl_social_action", "chill_sit_attempt", nNowAbs);
    AssignCommand(oNpc, ActionSit(oChair));
    DL_LogSocialEvent(oNpc, DL_STATUS_SITTING_CHILL_ATTEMPT, "chair=" + GetTag(oChair));
    return TRUE;
}
void DL_ExecuteChillDirective(object oNpc)
{
    object oSeat = DL_ResolveChillWaypoint(oNpc);
    if (!GetIsObjectValid(oSeat))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_MISSING_CHILL_SEAT);
        return;
    }

    DL_LogSocialEvent(
        oNpc,
        "target_chill",
        DL_BuildAnchorTelemetry(oNpc, oSeat, "target dir=CHILL", "focus")
    );
    DL_ProgressChillAtSeat(oNpc, oSeat);
}
void DL_ExecutePublicDirective(object oNpc)
{
    object oPublic = DL_ResolvePublicWaypoint(oNpc);
    if (!GetIsObjectValid(oPublic))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_MISSING_PUBLIC_ANCHOR);
        return;
    }

    string sAnim = "pause";
    if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 100, 0) % 2) == 0)
    {
        sAnim = "talk01";
    }
    DL_LogSocialEvent(
        oNpc,
        "target_public",
        DL_BuildAnchorTelemetry(oNpc, oPublic, "target dir=PUBLIC", "focus")
    );
    DL_ProgressFocusAtTarget(oNpc, oPublic, "on_public_anchor", sAnim);
}
int DL_ShouldFallbackSocialToPublicLocal(object oNpc)
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
        DL_LogSocialEvent(oNpc, DL_EVT_FOCUS_FALLBACK_SOCIAL_PUBLIC, "reason=" + DL_FB_REASON_SOCIAL_ANCHOR_OR_PARTNER_MISSING);
        return TRUE;
    }

    object oPartner = DL_ResolveSocialPartnerObject(oNpc, sPartnerTag);
    if (!GetIsObjectValid(oPartner) || GetLocalInt(oPartner, DL_L_NPC_DIRECTIVE) != DL_DIR_SOCIAL)
    {
        DL_LogSocialEvent(oNpc, DL_EVT_FOCUS_FALLBACK_SOCIAL_PUBLIC, "reason=" + DL_FB_REASON_SOCIAL_PARTNER_NOT_SOCIAL);
        return TRUE;
    }

    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);
    if (!GetIsObjectValid(oPartnerWp))
    {
        DL_LogSocialEvent(oNpc, DL_EVT_FOCUS_FALLBACK_SOCIAL_PUBLIC, "reason=" + DL_FB_REASON_SOCIAL_PARTNER_ANCHOR_MISSING);
        return TRUE;
    }

    return FALSE;
}
void DL_ExecuteSocialDirective(object oNpc)
{
    // Validate
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    // Resolve
    string sKind = DL_GetNpcSocialKind(oNpc);

    // Prepare
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_FOCUS_STATUS, DL_PIPE_STEP_PREPARE, "", "", "dl_tm_social_dispatch_count");
    if (DL_IsStandaloneSocialKind(sKind))
    {
        object oSocial = DL_ResolveStandaloneSocialWaypoint(oNpc, sKind);
        if (!GetIsObjectValid(oSocial))
        {
            DL_PipelineUpdateDiagnostic(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_MISSING_SOCIAL_POOL_PREFIX + sKind);
            return;
        }

        string sAnim = DL_GetStandaloneSocialAnimation(sKind);
        DL_LogSocialEvent(
            oNpc,
            "target_social_" + sKind,
            DL_BuildAnchorTelemetry(oNpc, oSocial, "target dir=SOCIAL kind=" + sKind, "focus")
        );
        DL_ProgressFocusAtTarget(oNpc, oSocial, "on_social_" + sKind, sAnim);
        return;
    }

    if (DL_ShouldFallbackSocialToPublicLocal(oNpc))
    {
        DL_SetReasonAndDiagnostic(oNpc, DL_FB_DOMAIN_SOCIAL, DL_FB_REASON_SOCIAL_PARTNER_NOT_SOCIAL, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_SOCIAL_FALLBACK_TO_PUBLIC);
        DL_LogSocialEvent(oNpc, "fallback_social_public", "reason=" + DL_FB_REASON_SOCIAL_PARTNER_NOT_SOCIAL);
        DL_ExecutePublicDirective(oNpc);
        return;
    }

    string sPartnerTag = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PARTNER_TAG);
    object oPartner = DL_ResolveSocialPartnerObject(oNpc, sPartnerTag);
    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);
    if (!GetIsObjectValid(oPartnerWp))
    {
        DL_PipelineUpdateDiagnostic(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, DL_DIAG_FOCUS_SOCIAL_FALLBACK_TO_PUBLIC);
        return;
    }

    object oMe = DL_ResolveSocialWaypoint(oNpc);

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

    DL_LogSocialEvent(
        oNpc,
        "target_social",
        DL_BuildAnchorTelemetry(oNpc, oMe, "target dir=SOCIAL slot=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) + " partner=" + sPartnerTag, "focus")
    );
    // Execute
    DL_ProgressFocusAtTarget(oNpc, oMe, sStatus, sAnim);

    // Finalize
    DL_OnNpcActionDispatched(oNpc, DL_L_NPC_FOCUS_STATUS, DL_PIPE_STEP_FINALIZE);
}
