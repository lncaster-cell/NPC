// Daily Life legacy transition adapter.
//
// SINGLE POINT POLICY:
// This include is the only allowed place for backward-compatibility exceptions
// in transition/anchor/router flows.
//
// Deprecation path (removal criteria):
// 1) All transition entries provide explicit `dl_transition_exit_tag` OR valid `dl_nav_*_to_*` tags.
// 2) No content depends on (`dl_transition_kind`, `dl_transition_id`) synthesis.
// 3) No content depends on foreign-entry handoff via exit-in-NPC-area behavior.
// 4) Driver metadata uses explicit `dl_transition_driver` and never relies on empty/legacy kind.

string DL_LegacyAdapterResolveExitTagFromKindId(string sKind, string sTransitionId)
{
    if (sTransitionId == "")
    {
        return "";
    }

    if (sKind == DL_TRANSITION_KIND_AREA_LINK)
    {
        return "dl_xfer_" + sTransitionId + "_to";
    }
    if (sKind == DL_TRANSITION_KIND_LOCAL_JUMP)
    {
        return "dl_jump_" + sTransitionId + "_to";
    }

    return "";
}

object DL_LegacyAdapterResolveForeignAnchorTransitionHandoff(object oNpc, object oWp)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oWp))
    {
        return OBJECT_INVALID;
    }

    // Legacy behavior: allow foreign transition entry if its exit lands in NPC area.
    object oExitWp = DL_TryGetTransitionExitWaypoint(oWp);
    if (GetIsObjectValid(oExitWp) && GetArea(oExitWp) == GetArea(oNpc))
    {
        return oExitWp;
    }

    return OBJECT_INVALID;
}

object DL_LegacyAdapterResolveGlobalTransitionWaypointByTag(string sResolvedTag)
{
    if (sResolvedTag == "")
    {
        return OBJECT_INVALID;
    }

    // Legacy compatibility fallback for old metadata/tag layouts.
    return DL_ResolveObjectByTagWithPolicy(
        sResolvedTag,
        OBJECT_TYPE_WAYPOINT,
        OBJECT_INVALID,
        DL_TRANSITION_TAG_SEARCH_CAP_GLOBAL_FALLBACK,
        DL_TAG_FALLBACK_GLOBAL
    );
}

int DL_LegacyAdapterIsTransitionDriverTypeMatch(string sDriverKind, object oDriver)
{
    if (!GetIsObjectValid(oDriver))
    {
        return FALSE;
    }

    // Legacy/empty kind: allow classic door/trigger drivers.
    if (sDriverKind != DL_TRANSITION_DRIVER_DOOR &&
        sDriverKind != DL_TRANSITION_DRIVER_TRIGGER &&
        sDriverKind != DL_TRANSITION_DRIVER_NONE)
    {
        int nTypeLegacy = GetObjectType(oDriver);
        return nTypeLegacy == OBJECT_TYPE_DOOR || nTypeLegacy == OBJECT_TYPE_TRIGGER;
    }

    return FALSE;
}
