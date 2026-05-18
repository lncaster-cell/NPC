#include "dl_social_scene_inc"

const string DL_L_NPC_CACHE_SOCIAL_PARTNER_OBJ = "dl_cache_social_partner_obj";
const string DL_L_NPC_CACHE_CHILL_CHAIR_OBJ = "dl_cache_chill_chair_obj";
const string DL_L_NPC_CACHE_CHILL_CHAIR_MISSING_UNTIL = "dl_cache_chill_chair_missing_until";
const string DL_L_NPC_CACHE_MEAL_CHAIR_OBJ = "dl_cache_meal_chair_obj";
const string DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL = "dl_cache_meal_chair_missing_until";
const string DL_L_NPC_CHILL_SIT_RETRY_UNTIL = "dl_chill_sit_retry_until";
const string DL_L_NPC_MEAL_SIT_RETRY_UNTIL = "dl_meal_sit_retry_until";
const string DL_L_NPC_CHILL_WAYPOINT_MODE = "dl_chill_waypoint_mode";
const string DL_L_NPC_MEAL_LEGACY_ACTION_SIT = "dl_meal_legacy_action_sit";
const string DL_L_NPC_CHILL_LEGACY_ACTION_SIT = "dl_chill_legacy_action_sit";
const string DL_L_NPC_FOCUS_ACTION_STAMP = "dl_focus_anchor_action_stamp";
const string DL_L_NPC_FOCUS_ACTION_TARGET = "dl_focus_anchor_action_target";
const string DL_L_WP_CHILL_CHAIR_TAG = "dl_chill_chair_tag";
const string DL_L_NPC_SOCIAL_PROBE_BEFORE = "dl_social_probe_before";
const string DL_L_NPC_SOCIAL_PROBE_AFTER = "dl_social_probe_after";
const string DL_L_NPC_SOCIAL_PROBE_RESULT = "dl_social_probe_result";
const string DL_L_NPC_SOCIAL_PROBE_REASON = "dl_social_probe_reason";
const string DL_L_NPC_SOCIAL_PROBE_DIST = "dl_social_probe_dist";
const string DL_L_NPC_SOCIAL_PROBE_ACTION = "dl_social_probe_action";
const string DL_L_NPC_SOCIAL_PROBE_SEQ = "dl_social_probe_seq";
const string DL_L_NPC_SOCIAL_PROBE_ABS_MIN = "dl_social_probe_abs_min";
const string DL_L_NPC_SOCIAL_PROBE_NOW_DIST = "dl_social_probe_now_dist";
const string DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE = "dl_social_probe_focus_status_before";
const string DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION = "dl_social_probe_current_action";
// Household seating defaults to waypoint animation: the meal/chill waypoint is
// the NPC body position and facing anchor, and chairs are decoration only.
// Set dl_meal_legacy_action_sit=1 or dl_chill_legacy_action_sit=1 on the NPC
// or waypoint only for hand-verified placeables that should use ActionSit.
const string DL_L_WP_MEAL_CHAIR_TAG = "dl_meal_chair_tag";
const int DL_SOCIAL_PARTNER_TAG_SEARCH_CAP = 32;
const int DL_CHILL_MISSING_CACHE_TTL_MINUTES = 10;
const int DL_MEAL_MISSING_CACHE_TTL_MINUTES = 10;
const int DL_CHILL_SIT_RETRY_MINUTES = 1;
const int DL_MEAL_SIT_RETRY_MINUTES = 1;
const int DL_MEAL_NEAR_CHAIR_SCAN_CAP = 12;
const float DL_MEAL_NEAR_CHAIR_RADIUS = 2.25;
const float DL_MEAL_SIT_VERIFY_DELAY = 4.0;
const float DL_MEAL_LOOP_ANIM_DURATION = 30.0;
const float DL_CHILL_SIT_VERIFY_DELAY = 4.0;
const float DL_CHILL_LOOP_ANIM_DURATION = 30.0;
const string DL_CHILL_ANIM_SIT_IDLE = "sitidle";

void DL_ClearFocusMoveIssueState(object oNpc)
{
    DL_ClearAnchorMoveIssueState(oNpc, DL_L_NPC_FOCUS_ACTION_STAMP, DL_L_NPC_FOCUS_ACTION_TARGET);
}
int DL_ShouldIssueFocusMoveAction(object oNpc, object oTarget)
{
    return DL_ShouldIssueAnchorMoveAction(
        oNpc,
        oTarget,
        DL_L_NPC_FOCUS_STATUS,
        "moving_to_anchor",
        DL_L_NPC_FOCUS_ACTION_TARGET,
        DL_L_NPC_FOCUS_ACTION_STAMP
    );
}
string DL_GetFocusMoveOwner(object oNpc)
{
    int nDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);
    if (nDirective == DL_DIR_MEAL) return DL_MOVE_OWNER_MEAL;
    if (nDirective == DL_DIR_SOCIAL) return DL_MOVE_OWNER_SOCIAL;
    if (nDirective == DL_DIR_PUBLIC) return DL_MOVE_OWNER_PUBLIC;
    if (nDirective == DL_DIR_CHILL) return DL_MOVE_OWNER_CHILL;
    return "focus";
}
void DL_IssueFocusMoveAction(object oNpc, object oTarget)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget))
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "moving_to_anchor");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oTarget));
    SetLocalString(oNpc, DL_L_NPC_FOCUS_ACTION_TARGET, GetTag(oTarget));
    DL_BeginMoveJobToObject(oNpc, DL_GetFocusMoveOwner(oNpc), "anchor", oTarget, DL_WORK_ANCHOR_RADIUS);
}
void DL_ClearFocusExecutionState(object oNpc)
{
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
    DL_ClearSocialSceneState(oNpc);
    DL_ClearFocusMoveIssueState(oNpc);
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
            DL_LogChatDebugEvent(
                oNpc,
                "social_partner_lookup",
                "social partner lookup tag=" + sPartnerTag + " result=self_ignored"
            );
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

    DL_NavPrepareTargetZoneFromAnchor(oNpc, oTarget);
    int bFinalizedTransition = DL_NavTryFinalizeCompletedTransition(oNpc, oTarget);
    if (bFinalizedTransition)
    {
        DL_LogChatDebugEvent(
            oNpc,
            "post_transition_complete",
            "post_transition_complete" +
                " npc_area=" + GetLocalString(oNpc, "dl_nav_debug_npc_area") +
                " target_area=" + GetLocalString(oNpc, "dl_nav_debug_target_area") +
                " current_zone=" + GetLocalString(oNpc, "dl_nav_debug_current_zone") +
                " target_zone=" + GetLocalString(oNpc, "dl_nav_debug_target_zone") +
                " old_transition_status=" + GetLocalString(oNpc, "dl_nav_debug_old_transition_status") +
                " focus_target=" + GetLocalString(oNpc, "dl_nav_debug_focus_target") +
                " current_action=" + IntToString(GetLocalInt(oNpc, "dl_nav_debug_current_action"))
        );
    }
    if (!bFinalizedTransition && DL_NavTryAdvanceToZoneForOwner(oNpc, GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET), DL_GetFocusMoveOwner(oNpc)))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oTarget) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldIssueFocusMoveAction(oNpc, oTarget))
        {
            DL_IssueFocusMoveAction(oNpc, oTarget);
        }
        return TRUE;
    }

    DL_ClearFocusMoveIssueState(oNpc);
    DL_ClearMoveJob(oNpc);
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
int DL_ApplyFocusWaypointAnimation(object oNpc, object oAnchor, string sStableStatus, string sAnim, float fLoopDuration)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    string sAnchorTag = GetTag(oAnchor);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == sStableStatus &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sAnchorTag)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        return TRUE;
    }

    DL_ClearFocusMoveIssueState(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, sStableStatus);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, sAnchorTag);

    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, SetFacing(GetFacing(oAnchor)));

    int bPlayedCustom = FALSE;
    if (sAnim != "")
    {
        bPlayedCustom = PlayCustomAnimation(oNpc, sAnim, TRUE);
    }
    if (!bPlayedCustom)
    {
        AssignCommand(oNpc, ActionPlayAnimation(ANIMATION_LOOPING_SIT_CHAIR, 1.0, fLoopDuration));
    }

    DL_LogChatDebugEvent(
        oNpc,
        sStableStatus,
        sStableStatus + " waypoint_animation anchor=" + sAnchorTag + " anim=" + sAnim + " custom=" + IntToString(bPlayedCustom)
    );
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
    int nMealOffset = DL_GetTagDeterministicOffset(sTag, 21, 10);
    int nBreakfastStart = DL_NormalizeMinuteOfDay((nWake * 60) - 15 + nMealOffset);
    int nLunchStart = DL_NormalizeMinuteOfDay(nShiftStart + 240 - 15 + nMealOffset);
    int nDinnerStart = DL_NormalizeMinuteOfDay(nSleepStart - 75 + nMealOffset);

    if (DL_MinuteInWindow(nNow, nBreakfastStart, DL_SCHED_BREAKFAST_DURATION_MINUTES))
    {
        return DL_MEAL_KIND_BREAKFAST;
    }
    if (nShiftLen >= 8 && DL_MinuteInWindow(nNow, nLunchStart, DL_SCHED_LUNCH_DURATION_MINUTES))
    {
        return DL_MEAL_KIND_LUNCH;
    }
    if (DL_MinuteInWindow(nNow, nDinnerStart, DL_SCHED_DINNER_DURATION_MINUTES))
    {
        return DL_MEAL_KIND_DINNER;
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

    object oMeal = DL_GetAreaAnchorWaypoint(oNpc, oTargetArea, "dl_anchor_meal", DL_L_NPC_CACHE_MEAL, FALSE);
    if (GetIsObjectValid(oMeal))
    {
        return oMeal;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    oMeal = DL_ResolveNpcWaypointWithFallbackTagInArea(
        oNpc,
        DL_L_NPC_CACHE_MEAL,
        oTargetArea,
        "dl_meal_",
        "",
        "dl_meal_" + IntToString(nSlot)
    );
    if (GetIsObjectValid(oMeal))
    {
        return oMeal;
    }

    DL_LogMarkupIssueOnce(
        oNpc,
        "missing_meal_anchor_" + GetTag(oTargetArea),
        "Area " + GetTag(oTargetArea) + " needs area local dl_anchor_meal or waypoint dl_meal_" + IntToString(nSlot) + " for NPC " + GetTag(oNpc) + "."
    );
    return OBJECT_INVALID;
}
object DL_ResolveSocialWaypoint(object oNpc)
{
    object oArea = DL_GetSocialArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetWorkArea(oNpc);
    }
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    string sSlot = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT);
    object oWaypoint = OBJECT_INVALID;
    if (sSlot == "a")
    {
        oWaypoint = DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_social_a", DL_L_NPC_CACHE_SOCIAL_A, FALSE);
    }
    else if (sSlot == "b")
    {
        oWaypoint = DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_social_b", DL_L_NPC_CACHE_SOCIAL_B, FALSE);
    }

    if (GetIsObjectValid(oWaypoint))
    {
        return oWaypoint;
    }

    return DL_GetAreaAnchorWaypoint(oNpc, oArea, "dl_anchor_social", DL_L_NPC_CACHE_SOCIAL_A, TRUE);
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
int DL_IsMealChairTagCandidate(string sTag)
{
    if (sTag == "")
    {
        return FALSE;
    }
    if (FindSubString(sTag, "chair") >= 0)
    {
        return TRUE;
    }
    if (FindSubString(sTag, "Chair") >= 0)
    {
        return TRUE;
    }
    if (FindSubString(sTag, "seat") >= 0)
    {
        return TRUE;
    }
    if (FindSubString(sTag, "Seat") >= 0)
    {
        return TRUE;
    }
    return FALSE;
}

object DL_FindNearestMealChairObject(object oNpc, object oMeal)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oMeal);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nNth = 1;
    while (nNth <= DL_MEAL_NEAR_CHAIR_SCAN_CAP)
    {
        object oCandidate = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, GetLocation(oMeal), nNth);
        if (!GetIsObjectValid(oCandidate))
        {
            break;
        }

        if (GetArea(oCandidate) == oArea &&
            GetDistanceBetweenLocations(GetLocation(oCandidate), GetLocation(oMeal)) <= DL_MEAL_NEAR_CHAIR_RADIUS &&
            DL_IsMealChairTagCandidate(GetTag(oCandidate)))
        {
            return oCandidate;
        }

        nNth = nNth + 1;
    }

    return OBJECT_INVALID;
}

object DL_ResolveMealChairObject(object oNpc, object oMeal)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal))
    {
        return OBJECT_INVALID;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nMissingUntil = GetLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
    if (nMissingUntil > nNowAbs)
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oMeal);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ);
    if (GetIsObjectValid(oCached) &&
        GetObjectType(oCached) == OBJECT_TYPE_PLACEABLE &&
        GetArea(oCached) == oArea &&
        DL_IsMealChairTagCandidate(GetTag(oCached)))
    {
        return oCached;
    }

    string sChairTag = GetLocalString(oMeal, DL_L_WP_MEAL_CHAIR_TAG);
    object oChair = OBJECT_INVALID;
    if (sChairTag != "")
    {
        oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, sChairTag, oArea);
        if (GetIsObjectValid(oChair))
        {
            DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
            return oChair;
        }
    }

    string sNpcTag = GetTag(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, "dl_meal_" + sNpcTag + "_chair", oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    oChair = DL_GetNpcCachedPlaceableByTagInArea(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, "dl_meal_chair_" + IntToString(nSlot), oArea);
    if (GetIsObjectValid(oChair))
    {
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    oChair = DL_FindNearestMealChairObject(oNpc, oMeal);
    if (GetIsObjectValid(oChair))
    {
        SetLocalObject(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_OBJ, oChair);
        DeleteLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL);
        return oChair;
    }

    SetLocalInt(oNpc, DL_L_NPC_CACHE_MEAL_CHAIR_MISSING_UNTIL, nNowAbs + DL_MEAL_MISSING_CACHE_TTL_MINUTES);
    return OBJECT_INVALID;
}

int DL_ShouldAttemptMealActionSit(object oNpc, object oMeal, object oChair)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal) || !GetIsObjectValid(oChair))
    {
        return FALSE;
    }

    string sChairTag = GetTag(oChair);
    if (sChairTag == "")
    {
        return FALSE;
    }

    if (GetLocalString(oMeal, DL_L_WP_MEAL_CHAIR_TAG) == sChairTag)
    {
        return TRUE;
    }

    string sNpcTag = GetTag(oNpc);
    if (sChairTag == "dl_meal_" + sNpcTag + "_chair")
    {
        return TRUE;
    }

    int nSlot = DL_GetNpcHomeSlot(oNpc);
    if (sChairTag == "dl_meal_chair_" + IntToString(nSlot))
    {
        return TRUE;
    }

    return FALSE;
}

void DL_ApplyMealAnimationFallback(object oNpc, object oMeal, string sMealKind, string sAnim, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oMeal))
    {
        return;
    }

    string sStableStatus = "on_meal_anchor_" + sMealKind;
    string sMealTag = GetTag(oMeal);
    int bAlreadyStable = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == sStableStatus &&
                         GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sMealTag;
    if (DL_ApplyFocusWaypointAnimation(oNpc, oMeal, sStableStatus, sAnim, DL_MEAL_LOOP_ANIM_DURATION) &&
        !bAlreadyStable && sDiagnostic != "")
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, sDiagnostic);
    }
}

int DL_ShouldUseMealLegacyActionSit(object oNpc, object oMeal)
{
    if (GetIsObjectValid(oNpc) && GetLocalInt(oNpc, DL_L_NPC_MEAL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    if (GetIsObjectValid(oMeal) && GetLocalInt(oMeal, DL_L_NPC_MEAL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    return FALSE;
}

string DL_GetMealWaypointAnimation(object oNpc, string sMealKind)
{
    if (sMealKind == DL_MEAL_KIND_BREAKFAST)
    {
        return "sitdrink";
    }
    if ((DL_GetTagDeterministicOffset(GetTag(oNpc), 6, 0) % 6) == 0)
    {
        return "sitdrink";
    }
    return "siteat";
}

int DL_ExecuteMealWaypointAnimation(object oNpc, object oMeal, string sMealKind, string sAnim)
{
    DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
    return DL_ApplyFocusWaypointAnimation(oNpc, oMeal, "on_meal_anchor_" + sMealKind, sAnim, DL_MEAL_LOOP_ANIM_DURATION);
}

void DL_VerifyMealSitOrFallback(object oNpc, object oChair, object oMeal, string sMealKind, string sAnim)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oChair) || !GetIsObjectValid(oMeal))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_MEAL)
    {
        return;
    }

    if (GetSittingCreature(oChair) == oNpc)
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_meal_anchor_sitting");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oMeal));
        DL_LogChatDebugEvent(oNpc, "on_meal_anchor_sitting", "on_meal_anchor_sitting chair=" + GetTag(oChair));
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));
    SetLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL, DL_GetAbsoluteMinute() + DL_MEAL_SIT_RETRY_MINUTES);
    DL_ApplyMealAnimationFallback(oNpc, oMeal, sMealKind, sAnim, "");
}

int DL_TryProgressMealLegacyChair(object oNpc, object oMeal, string sMealKind, string sAnim)
{
    object oChair = DL_ResolveMealChairObject(oNpc, oMeal);
    if (!GetIsObjectValid(oChair))
    {
        return FALSE;
    }

    object oSitter = GetSittingCreature(oChair);
    if (oSitter == oNpc)
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_meal_anchor_sitting");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oMeal));
        DL_LogChatDebugEvent(oNpc, "on_meal_anchor_sitting", "on_meal_anchor_sitting chair=" + GetTag(oChair));
        return TRUE;
    }

    if (GetIsObjectValid(oSitter) && oSitter != oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "meal_chair_occupied");
        return FALSE;
    }

    if (!DL_ShouldAttemptMealActionSit(oNpc, oMeal, oChair))
    {
        return FALSE;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nRetryUntil = GetLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL);
    string sStatus = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS);
    if (nRetryUntil > nNowAbs)
    {
        if (sStatus == "sitting_meal_attempt")
        {
            return TRUE;
        }
        return FALSE;
    }

    DL_ClearFocusMoveIssueState(oNpc);
    DL_ClearMoveJob(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "sitting_meal_attempt");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oMeal));
    SetLocalInt(oNpc, DL_L_NPC_MEAL_SIT_RETRY_UNTIL, nNowAbs + DL_MEAL_SIT_RETRY_MINUTES);
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionSit(oChair));
    DelayCommand(DL_MEAL_SIT_VERIFY_DELAY, DL_VerifyMealSitOrFallback(oNpc, oChair, oMeal, sMealKind, sAnim));
    DL_LogChatDebugEvent(oNpc, "sitting_meal_attempt", "sitting_meal_attempt chair=" + GetTag(oChair));
    return TRUE;
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

    string sAnim = DL_GetMealWaypointAnimation(oNpc, sMealKind);

    DL_LogChatDebugEvent(
        oNpc,
        "target_meal",
        "target dir=MEAL area=" + GetTag(GetArea(oMeal)) + " anchor=" + GetTag(oMeal) + " kind=" + sMealKind
    );

    DL_NavPrepareTargetZoneFromAnchor(oNpc, oMeal);
    if (DL_NavTryAdvanceToZoneForOwner(oNpc, GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET), DL_GetFocusMoveOwner(oNpc)))
    {
        return;
    }

    if (GetDistanceBetween(oNpc, oMeal) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldIssueFocusMoveAction(oNpc, oMeal))
        {
            DL_IssueFocusMoveAction(oNpc, oMeal);
        }
        return;
    }

    if (DL_ShouldUseMealLegacyActionSit(oNpc, oMeal))
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        if (DL_TryProgressMealLegacyChair(oNpc, oMeal, sMealKind, sAnim))
        {
            return;
        }

        DL_ExecuteMealWaypointAnimation(oNpc, oMeal, sMealKind, sAnim);
        return;
    }

    DL_ExecuteMealWaypointAnimation(oNpc, oMeal, sMealKind, sAnim);
}
void DL_ApplyChillAnimationFallback(object oNpc, object oSeat, string sDiagnostic)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return;
    }

    string sSeatTag = GetTag(oSeat);
    int bAlreadyStable = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_chill_anchor" &&
                         GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sSeatTag;
    if (DL_ApplyFocusWaypointAnimation(oNpc, oSeat, "on_chill_anchor", DL_CHILL_ANIM_SIT_IDLE, DL_CHILL_LOOP_ANIM_DURATION) &&
        !bAlreadyStable && sDiagnostic != "")
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, sDiagnostic);
    }
}

int DL_ShouldUseChillLegacyActionSit(object oNpc, object oSeat)
{
    if (GetIsObjectValid(oNpc) && GetLocalInt(oNpc, DL_L_NPC_CHILL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    if (GetIsObjectValid(oSeat) && GetLocalInt(oSeat, DL_L_NPC_CHILL_LEGACY_ACTION_SIT) == TRUE)
    {
        return TRUE;
    }
    return FALSE;
}

int DL_ExecuteChillWaypointAnimation(object oNpc, object oSeat)
{
    DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    return DL_ApplyFocusWaypointAnimation(oNpc, oSeat, "on_chill_anchor", DL_CHILL_ANIM_SIT_IDLE, DL_CHILL_LOOP_ANIM_DURATION);
}

void DL_VerifyChillSitOrFallback(object oNpc, object oChair, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oChair) || !GetIsObjectValid(oSeat))
    {
        return;
    }

    if (GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) != DL_DIR_CHILL)
    {
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != GetTag(oSeat))
    {
        return;
    }

    if (GetSittingCreature(oChair) == oNpc)
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_chill_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        DL_LogChatDebugEvent(oNpc, "on_chill_anchor", "on_chill_anchor chair=" + GetTag(oChair));
        return;
    }

    SetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL, DL_GetAbsoluteMinute() + DL_CHILL_SIT_RETRY_MINUTES);
    DL_ApplyChillAnimationFallback(oNpc, oSeat, "chill_action_sit_failed");
}

int DL_TryProgressChillLegacyChair(object oNpc, object oSeat)
{
    object oChair = DL_ResolveChillChairObject(oNpc, oSeat);
    if (!GetIsObjectValid(oChair))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "missing_chill_chair");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_chill_chair");
        return FALSE;
    }

    object oSitter = GetSittingCreature(oChair);
    if (oSitter == oNpc)
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DeleteLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_chill_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        DL_LogChatDebugEvent(oNpc, "on_chill_anchor", "on_chill_anchor legacy_chair=" + GetTag(oChair));
        return TRUE;
    }

    if (GetIsObjectValid(oSitter) && oSitter != oNpc)
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "chill_chair_occupied");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "chill_chair_occupied");
        return FALSE;
    }

    int nNowAbs = DL_GetAbsoluteMinute();
    int nRetryUntil = GetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "sitting_chill_attempt" && nRetryUntil > nNowAbs)
    {
        return TRUE;
    }

    DL_ClearFocusMoveIssueState(oNpc);
    DL_ClearMoveJob(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "sitting_chill_attempt");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oSeat));
    SetLocalInt(oNpc, DL_L_NPC_CHILL_SIT_RETRY_UNTIL, nNowAbs + DL_CHILL_SIT_RETRY_MINUTES);
    AssignCommand(oNpc, ClearAllActions(TRUE));
    AssignCommand(oNpc, ActionSit(oChair));
    DelayCommand(DL_CHILL_SIT_VERIFY_DELAY, DL_VerifyChillSitOrFallback(oNpc, oChair, oSeat));
    DL_LogChatDebugEvent(oNpc, "sitting_chill_attempt", "sitting_chill_attempt legacy_chair=" + GetTag(oChair));
    return TRUE;
}

int DL_ProgressChillAtSeat(object oNpc, object oSeat)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSeat))
    {
        return FALSE;
    }

    DL_NavPrepareTargetZoneFromAnchor(oNpc, oSeat);
    if (DL_NavTryAdvanceToZoneForOwner(oNpc, GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET), DL_GetFocusMoveOwner(oNpc)))
    {
        return TRUE;
    }

    if (GetDistanceBetween(oNpc, oSeat) > DL_WORK_ANCHOR_RADIUS)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        if (DL_ShouldIssueFocusMoveAction(oNpc, oSeat))
        {
            DL_IssueFocusMoveAction(oNpc, oSeat);
        }
        return TRUE;
    }

    if (DL_ShouldUseChillLegacyActionSit(oNpc, oSeat))
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        if (DL_TryProgressChillLegacyChair(oNpc, oSeat))
        {
            return TRUE;
        }
    }

    return DL_ExecuteChillWaypointAnimation(oNpc, oSeat);
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
    object oMe = DL_ResolveSocialWaypoint(oNpc);
    if (!GetIsObjectValid(oMe))
    {
        DL_LogChatDebugEvent(oNpc, "fallback_social_public", "fallback social->public reason=missing_social_area_or_anchor");
        return TRUE;
    }

    return FALSE;
}
void DL_SetSocialArrivalProbeFailure(object oNpc, object oAnchor, string sReason, float fDist)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, sReason);
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST, fDist);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, FALSE);
    SetLocalString(
        oNpc,
        DL_L_NPC_SOCIAL_PROBE_AFTER,
        "social_arrival_probe " + sReason +
            " anchor_tag=" + GetTag(oAnchor) +
            " npc_area=" + GetTag(GetArea(oNpc)) +
            " anchor_area=" + GetTag(GetArea(oAnchor)) +
            " dist=" + FloatToString(fDist, 1, 2)
    );
}

int DL_TryStartSocialSceneAtReachedAnchor(object oNpc, object oAnchor, object oPartner, int bPartnerOnAnchor)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor))
    {
        DL_SetSocialArrivalProbeFailure(oNpc, oAnchor, "invalid_object", -1.0);
        return FALSE;
    }

    if (GetArea(oNpc) != GetArea(oAnchor))
    {
        DL_SetSocialArrivalProbeFailure(oNpc, oAnchor, "area_mismatch", GetDistanceBetween(oNpc, oAnchor));
        return FALSE;
    }

    if (GetDistanceBetween(oNpc, oAnchor) > DL_WORK_ANCHOR_RADIUS)
    {
        DL_SetSocialArrivalProbeFailure(oNpc, oAnchor, "too_far", GetDistanceBetween(oNpc, oAnchor));
        return FALSE;
    }

    DL_ClearFocusMoveIssueState(oNpc);
    DL_ClearTransitionExecutionState(oNpc);
    DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_social_anchor");
    SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oAnchor));
    AssignCommand(oNpc, SetFacing(GetFacing(oAnchor)));
    DL_LogChatDebugEvent(oNpc, "on_social_anchor", "on_social_anchor anchor=" + GetTag(oAnchor));
    DL_TickSocialScene(oNpc, oAnchor, oPartner, bPartnerOnAnchor);
    return TRUE;
}
void DL_ExecuteSocialDirective(object oNpc)
{
    object oMe = DL_ResolveSocialWaypoint(oNpc);
    int nProbeSeq = GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_SEQ) + 1;
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_SEQ, nProbeSeq);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN, DL_GetAbsoluteMinute());
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE, GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION, GetCurrentAction(oNpc));
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST, -1.0);
    string sPartnerTag = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PARTNER_TAG);
    object oPartner = DL_ResolveSocialPartnerObject(oNpc, sPartnerTag);
    object oPartnerWp = DL_ResolveSocialWaypoint(oPartner);

    int bPartnerReady = GetIsObjectValid(oPartner) &&
        GetLocalInt(oPartner, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL &&
        GetIsObjectValid(oPartnerWp);
    int bPartnerOnAnchor = FALSE;
    if (bPartnerReady)
    {
        bPartnerOnAnchor =
            GetLocalString(oPartner, DL_L_NPC_FOCUS_STATUS) == "on_social_anchor" &&
            GetLocalString(oPartner, DL_L_NPC_FOCUS_TARGET) == GetTag(oPartnerWp) &&
            GetDistanceBetween(oPartner, oPartnerWp) <= DL_WORK_ANCHOR_RADIUS;
    }

    object oReachedFocus = DL_ResolveFocusTargetInCurrentArea(oNpc);
    string sFocusTargetTag = GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET);
    int bReachedSocialAnchor = GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "moving_to_anchor" &&
        GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE) == DL_DIR_SOCIAL &&
        GetIsObjectValid(oReachedFocus) &&
        GetDistanceBetween(oNpc, oReachedFocus) <= DL_WORK_ANCHOR_RADIUS &&
        sFocusTargetTag == GetTag(oReachedFocus) &&
        (FindSubString(sFocusTargetTag, "social") >= 0 ||
            (GetIsObjectValid(oMe) && GetTag(oMe) == sFocusTargetTag));
    if (bReachedSocialAnchor)
    {
        DL_ClearFocusMoveIssueState(oNpc);
        DL_ClearMoveJob(oNpc);
        DL_ClearTransitionExecutionState(oNpc);
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        SetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS, "on_social_anchor");
        SetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET, GetTag(oReachedFocus));
        AssignCommand(oNpc, SetFacing(GetFacing(oReachedFocus)));
        SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST, GetDistanceBetween(oNpc, oReachedFocus));
        SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST, GetDistanceBetween(oNpc, oReachedFocus));
        SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, TRUE);
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "reached_focus_recovered");
        SetLocalString(
            oNpc,
            DL_L_NPC_SOCIAL_PROBE_BEFORE,
            "seq=" + IntToString(nProbeSeq) +
                " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
                " focus_status=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_FOCUS_STATUS_BEFORE) +
                " focus_target=" + sFocusTargetTag +
                " reached_tag=" + GetTag(oReachedFocus) +
                " reached_dist=" + FloatToString(GetDistanceBetween(oNpc, oReachedFocus), 1, 2) +
                " current_action=" + IntToString(GetCurrentAction(oNpc))
        );
        SetLocalString(
            oNpc,
            DL_L_NPC_SOCIAL_PROBE_AFTER,
            "seq=" + IntToString(nProbeSeq) +
                " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
                " recovered_reached_focus=1 focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
                " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET)
        );
        DL_TickSocialScene(oNpc, oReachedFocus, oPartner, bPartnerOnAnchor);
        return;
    }

    if (!GetIsObjectValid(oMe))
    {
        SetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC, "missing_social_anchor");
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "missing_social_anchor");
        SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, FALSE);
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER, "missing_social_anchor");
        return;
    }

    string sAnchorTag = GetTag(oMe);
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_DIST, GetDistanceBetween(oNpc, oMe));
    SetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST, GetDistanceBetween(oNpc, oMe));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ACTION, GetCurrentAction(oNpc));
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_CURRENT_ACTION, GetCurrentAction(oNpc));
    SetLocalString(
        oNpc,
        DL_L_NPC_SOCIAL_PROBE_BEFORE,
        "seq=" + IntToString(nProbeSeq) +
            " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
            " npc_tag=" + GetTag(oNpc) +
            " focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
            " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
            " oMe_tag=" + GetTag(oMe) +
            " npc_area=" + GetTag(GetArea(oNpc)) +
            " oMe_area=" + GetTag(GetArea(oMe)) +
            " dist=" + FloatToString(GetDistanceBetween(oNpc, oMe), 1, 2) +
            " now_dist=" + FloatToString(GetLocalFloat(oNpc, DL_L_NPC_SOCIAL_PROBE_NOW_DIST), 1, 2) +
            " current_action=" + IntToString(GetCurrentAction(oNpc)) +
            " bPartnerOnAnchor=" + IntToString(bPartnerOnAnchor)
    );
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "calling_helper");
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER, "calling_helper");
    int bStartedSocialScene = DL_TryStartSocialSceneAtReachedAnchor(oNpc, oMe, oPartner, bPartnerOnAnchor);
    string sProbeFailure = GetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_AFTER);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_RESULT, bStartedSocialScene);
    SetLocalString(
        oNpc,
        DL_L_NPC_SOCIAL_PROBE_AFTER,
        "seq=" + IntToString(nProbeSeq) +
            " abs_min=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_SOCIAL_PROBE_ABS_MIN)) +
            " helper_result=" + IntToString(bStartedSocialScene) +
            " focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
            " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
            " detail=" + sProbeFailure
    );
    if (bStartedSocialScene)
    {
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_PROBE_REASON, "started");
        return;
    }

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_social_anchor" &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sAnchorTag)
    {
        DeleteLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
        DL_TickSocialScene(oNpc, oMe, oPartner, bPartnerOnAnchor);
        return;
    }

    DL_LogChatDebugEvent(
        oNpc,
        "target_social",
        "target dir=SOCIAL area=" + GetTag(GetArea(oMe)) + " anchor=" + GetTag(oMe) +
            " social_anchor=" + GetTag(oMe) +
            " social_slot=" + GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) +
            " social_partner_tag=" + sPartnerTag +
            " social_partner_valid=" + IntToString(GetIsObjectValid(oPartner))
    );

    DL_ProgressFocusAtTarget(oNpc, oMe, "on_social_anchor", "");

    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) == "on_social_anchor" &&
        GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) == sAnchorTag)
    {
        DL_TickSocialScene(oNpc, oMe, oPartner, bPartnerOnAnchor);
    }
}
