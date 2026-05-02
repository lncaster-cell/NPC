const string DL_L_NPC_SOCIAL_KIND = "dl_social_kind";
const string DL_L_NPC_SOCIAL_RESERVED_WP = "dl_social_reserved_wp";
const string DL_L_WP_SOCIAL_RESERVED_BY = "dl_social_reserved_by";
const string DL_L_WP_SOCIAL_RESERVED_ABS_MIN = "dl_social_reserved_abs_min";

const string DL_SOCIAL_KIND_PAIRED_CHAT = "paired_chat";
const string DL_SOCIAL_KIND_THEATER = "theater";
const string DL_SOCIAL_KIND_TAVERN = "tavern";
const string DL_SOCIAL_KIND_PUBLIC = "public";

const int DL_SOCIAL_POOL_SEARCH_CAP = 32;
const int DL_SOCIAL_RESERVATION_TTL_MINUTES = 90;

int DL_GetSocialReservationAbsMin(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return 0;
    }

    int nAbsMin = GetLocalInt(oWp, DL_L_WP_SOCIAL_RESERVED_ABS_MIN);
    if (nAbsMin > 0)
    {
        return nAbsMin;
    }

    // COMPAT(temporary): migrate legacy key and immediately delete alias.
    nAbsMin = GetLocalInt(oWp, "dl_social_reserved_until");
    if (nAbsMin > 0)
    {
        SetLocalInt(oWp, DL_L_WP_SOCIAL_RESERVED_ABS_MIN, nAbsMin);
    }
    DeleteLocalInt(oWp, "dl_social_reserved_until");
    return nAbsMin;
}

string DL_GetNpcSocialKind(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return "";
    }

    return GetLocalString(oNpc, DL_L_NPC_SOCIAL_KIND);
}

int DL_IsStandaloneSocialKind(string sKind)
{
    if (sKind == "")
    {
        return FALSE;
    }

    return sKind != DL_SOCIAL_KIND_PAIRED_CHAT;
}

string DL_GetSocialPoolTagPrefix(string sKind)
{
    if (sKind == "")
    {
        return "";
    }

    return "dl_social_" + sKind + "_";
}

string DL_GetSocialAnchorLocalForKind(string sKind)
{
    if (sKind == "")
    {
        return "";
    }

    return "dl_anchor_social_" + sKind;
}

string DL_GetStandaloneSocialAnimation(string sKind)
{
    if (sKind == DL_SOCIAL_KIND_TAVERN)
    {
        return "talk01";
    }

    if (sKind == DL_SOCIAL_KIND_PUBLIC)
    {
        return "talk02";
    }

    // Theater and unknown standalone social destinations should stay visually quiet.
    return "pause";
}

int DL_StringStartsWithSimple(string sValue, string sPrefix)
{
    int nPrefixLength = GetStringLength(sPrefix);
    if (nPrefixLength <= 0)
    {
        return FALSE;
    }

    if (GetStringLength(sValue) < nPrefixLength)
    {
        return FALSE;
    }

    return GetSubString(sValue, 0, nPrefixLength) == sPrefix;
}

object DL_FindSocialPoolWaypointByTagInArea(string sTag, object oArea)
{
    if (sTag == "" || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oResolved = DL_FindObjectByTagInAreaDeterministic(sTag, OBJECT_TYPE_WAYPOINT, oArea, DL_WAYPOINT_TAG_SEARCH_CAP);
    DL_RecordCacheMetric(oArea, "social", GetIsObjectValid(oResolved));
    return oResolved;
}

void DL_ClearSocialWaypointReservation(object oWp)
{
    if (!GetIsObjectValid(oWp))
    {
        return;
    }

    DeleteLocalObject(oWp, DL_L_WP_SOCIAL_RESERVED_BY);
    DeleteLocalInt(oWp, DL_L_WP_SOCIAL_RESERVED_ABS_MIN);
}

int DL_IsSocialWaypointReservedByOther(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oWp))
    {
        return TRUE;
    }

    int nUntil = DL_GetSocialReservationAbsMin(oWp);
    object oReservedBy = GetLocalObject(oWp, DL_L_WP_SOCIAL_RESERVED_BY);
    if (nUntil <= DL_GetAbsoluteMinute())
    {
        DL_ClearSocialWaypointReservation(oWp);
        return FALSE;
    }

    if (!GetIsObjectValid(oReservedBy))
    {
        DL_ClearSocialWaypointReservation(oWp);
        return FALSE;
    }

    if (oReservedBy == oNpc)
    {
        return FALSE;
    }

    return TRUE;
}

int DL_IsSocialWaypointAvailableForNpc(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oWp))
    {
        return FALSE;
    }

    return !DL_IsSocialWaypointReservedByOther(oNpc, oWp);
}

void DL_ReserveSocialWaypointForNpc(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oWp))
    {
        return;
    }

    SetLocalObject(oWp, DL_L_WP_SOCIAL_RESERVED_BY, oNpc);
    SetLocalInt(oWp, DL_L_WP_SOCIAL_RESERVED_ABS_MIN, DL_GetAbsoluteMinute() + DL_SOCIAL_RESERVATION_TTL_MINUTES);
    SetLocalObject(oNpc, DL_L_NPC_SOCIAL_RESERVED_WP, oWp);
}

void DL_ClearNpcSocialReservation(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oWp = GetLocalObject(oNpc, DL_L_NPC_SOCIAL_RESERVED_WP);
    if (GetIsObjectValid(oWp))
    {
        object oReservedBy = GetLocalObject(oWp, DL_L_WP_SOCIAL_RESERVED_BY);
        if (oReservedBy == oNpc)
        {
            DL_ClearSocialWaypointReservation(oWp);
        }
    }

    DeleteLocalObject(oNpc, DL_L_NPC_SOCIAL_RESERVED_WP);
}

object DL_GetNpcReservedStandaloneSocialWaypoint(object oNpc, string sKind, object oArea)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea) || sKind == "")
    {
        return OBJECT_INVALID;
    }

    object oWp = GetLocalObject(oNpc, DL_L_NPC_SOCIAL_RESERVED_WP);
    if (!GetIsObjectValid(oWp) || GetArea(oWp) != oArea)
    {
        return OBJECT_INVALID;
    }

    string sPrefix = DL_GetSocialPoolTagPrefix(sKind);
    string sAnchorLocal = DL_GetSocialAnchorLocalForKind(sKind);
    string sAnchorTag = GetLocalString(oArea, sAnchorLocal);
    if (!DL_StringStartsWithSimple(GetTag(oWp), sPrefix) && GetTag(oWp) != sAnchorTag)
    {
        return OBJECT_INVALID;
    }

    if (!DL_IsSocialWaypointAvailableForNpc(oNpc, oWp))
    {
        return OBJECT_INVALID;
    }

    DL_ReserveSocialWaypointForNpc(oNpc, oWp);
    return oWp;
}

object DL_ResolveStandaloneSocialWaypoint(object oNpc, string sKind)
{
    if (!GetIsObjectValid(oNpc) || !DL_IsStandaloneSocialKind(sKind))
    {
        return OBJECT_INVALID;
    }

    object oArea = DL_GetSocialArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetPublicArea(oNpc);
    }
    if (!GetIsObjectValid(oArea))
    {
        oArea = DL_GetNpcCurrentAreaFallback(oNpc);
    }
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oReserved = DL_GetNpcReservedStandaloneSocialWaypoint(oNpc, sKind, oArea);
    if (GetIsObjectValid(oReserved))
    {
        return oReserved;
    }

    string sPrefix = DL_GetSocialPoolTagPrefix(sKind);
    int nStart = DL_GetTagDeterministicOffset(GetTag(oNpc), DL_SOCIAL_POOL_SEARCH_CAP, 0);
    int i = 0;
    while (i < DL_SOCIAL_POOL_SEARCH_CAP)
    {
        int nIndex = ((nStart + i) % DL_SOCIAL_POOL_SEARCH_CAP) + 1;
        object oCandidate = DL_FindSocialPoolWaypointByTagInArea(sPrefix + IntToString(nIndex), oArea);
        if (GetIsObjectValid(oCandidate) && DL_IsSocialWaypointAvailableForNpc(oNpc, oCandidate))
        {
            DL_ReserveSocialWaypointForNpc(oNpc, oCandidate);
            return oCandidate;
        }
        i = i + 1;
    }

    string sAnchorTag = GetLocalString(oArea, DL_GetSocialAnchorLocalForKind(sKind));
    object oAnchor = DL_FindSocialPoolWaypointByTagInArea(sAnchorTag, oArea);
    if (GetIsObjectValid(oAnchor) && DL_IsSocialWaypointAvailableForNpc(oNpc, oAnchor))
    {
        DL_ReserveSocialWaypointForNpc(oNpc, oAnchor);
        return oAnchor;
    }

    return OBJECT_INVALID;
}
