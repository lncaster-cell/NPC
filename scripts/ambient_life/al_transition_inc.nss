// Ambient Life Stage F transition subsystem.
// Separate from Stage D/E area-scoped route cache runtime.
//
// NOTE: Transition runtime state is NOT persisted in locals.
// We execute transition actions immediately and do not keep
// al_trans_rt_* technical keys on NPCs.

#include "al_area_inc"
#include "al_activity_inc"
#include "al_events_inc"
#include "al_registry_inc"

const int AL_TRANSITION_NONE = 0;
const int AL_TRANSITION_AREA_HELPER = 1;
const int AL_TRANSITION_INTRA_TELEPORT = 2;

void AL_TransitionRuntimeClear(object oNpc)
{
    // Transition runtime state is not stored; keep function for API stability.
}

int AL_TransitionTypeFromStep(object oStep)
{
    if (!GetIsObjectValid(oStep))
    {
        return AL_TRANSITION_NONE;
    }

    int nType = GetLocalInt(oStep, "al_trans_type");
    if (nType != AL_TRANSITION_AREA_HELPER && nType != AL_TRANSITION_INTRA_TELEPORT)
    {
        return AL_TRANSITION_NONE;
    }

    return nType;
}

int AL_TransitionResolveEndpoints(object oStep, object oNpc, object oArea, object &oSrc, object &oDst)
{
    if (!GetIsObjectValid(oStep) || !GetIsObjectValid(oNpc) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    string sSrcTag = GetLocalString(oStep, "al_trans_src_wp");
    string sDstTag = GetLocalString(oStep, "al_trans_dst_wp");

    if (sSrcTag == "" || sDstTag == "")
    {
        return FALSE;
    }

    int nDebug = GetLocalInt(oArea, "al_debug");

    // Resolve source waypoint by tag, explicitly restricted to NPC current area.
    int iSrc = 0;
    int nSrcMatches = 0;
    object oSrcCandidate = GetObjectByTag(sSrcTag, iSrc);
    while (GetIsObjectValid(oSrcCandidate))
    {
        if (GetObjectType(oSrcCandidate) == OBJECT_TYPE_WAYPOINT && GetArea(oSrcCandidate) == oArea)
        {
            nSrcMatches = nSrcMatches + 1;
            if (nSrcMatches == 1)
            {
                oSrc = oSrcCandidate;
            }
        }

        iSrc = iSrc + 1;
        oSrcCandidate = GetObjectByTag(sSrcTag, iSrc);
    }

    if (nSrcMatches != 1)
    {
        if (nDebug > 0)
        {
            WriteTimestampedLogEntry(
                "[AL][TransitionResolve] ambiguous-or-missing src waypoint: area=" + GetTag(oArea)
                + " src_tag=" + sSrcTag
                + " matches_in_area=" + IntToString(nSrcMatches)
            );
        }
        return FALSE;
    }

    // Optional explicit destination-area policy.
    object oDstTargetArea = GetLocalObject(oStep, "al_trans_dst_area_obj");
    if (!GetIsObjectValid(oDstTargetArea))
    {
        oDstTargetArea = GetLocalObject(oStep, "al_trans_target_area");
    }

    string sDstTargetAreaTag = GetLocalString(oStep, "al_trans_dst_area");
    if (sDstTargetAreaTag == "")
    {
        sDstTargetAreaTag = GetLocalString(oStep, "al_trans_target_area");
    }

    if (!GetIsObjectValid(oDstTargetArea) && sDstTargetAreaTag != "")
    {
        int iArea = 0;
        int nAreaMatches = 0;
        object oAreaCandidate = GetObjectByTag(sDstTargetAreaTag, iArea);
        while (GetIsObjectValid(oAreaCandidate))
        {
            if (GetObjectType(oAreaCandidate) == OBJECT_TYPE_AREA)
            {
                nAreaMatches = nAreaMatches + 1;
                if (nAreaMatches == 1)
                {
                    oDstTargetArea = oAreaCandidate;
                }
            }

            iArea = iArea + 1;
            oAreaCandidate = GetObjectByTag(sDstTargetAreaTag, iArea);
        }

        if (nAreaMatches != 1)
        {
            if (nDebug > 0)
            {
                WriteTimestampedLogEntry(
                    "[AL][TransitionResolve] ambiguous-or-missing dst area: area=" + GetTag(oArea)
                    + " dst_area_tag=" + sDstTargetAreaTag
                    + " area_matches=" + IntToString(nAreaMatches)
                );
            }
            return FALSE;
        }
    }

    // Resolve destination waypoint by tag using explicit target-area policy if configured.
    int iDst = 0;
    int nDstMatches = 0;
    object oDstCandidate = GetObjectByTag(sDstTag, iDst);
    while (GetIsObjectValid(oDstCandidate))
    {
        if (GetObjectType(oDstCandidate) == OBJECT_TYPE_WAYPOINT)
        {
            int bAreaMatch = TRUE;
            if (GetIsObjectValid(oDstTargetArea))
            {
                bAreaMatch = (GetArea(oDstCandidate) == oDstTargetArea);
            }

            if (bAreaMatch)
            {
                nDstMatches = nDstMatches + 1;
                if (nDstMatches == 1)
                {
                    oDst = oDstCandidate;
                }
            }
        }

        iDst = iDst + 1;
        oDstCandidate = GetObjectByTag(sDstTag, iDst);
    }

    if (nDstMatches != 1)
    {
        if (nDebug > 0)
        {
            string sScope = "global";
            if (GetIsObjectValid(oDstTargetArea))
            {
                sScope = GetTag(oDstTargetArea);
            }

            WriteTimestampedLogEntry(
                "[AL][TransitionResolve] ambiguous-or-missing dst waypoint: area=" + GetTag(oArea)
                + " dst_tag=" + sDstTag
                + " scope=" + sScope
                + " matches=" + IntToString(nDstMatches)
            );
        }
        return FALSE;
    }

    return TRUE;
}


void AL_TransitionPostAreaHelper(object oNpc, object oFromArea)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oToArea = GetArea(oNpc);
    if (!GetIsObjectValid(oToArea))
    {
        return;
    }

    AL_TransferNPCRegistry(oNpc, oFromArea, oToArea);
    SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
}

int AL_TransitionQueueAreaHelper(object oNpc, object oStep, object oSrc, object oDst)
{
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    if (GetArea(oSrc) != oArea)
    {
        return FALSE;
    }

    if (GetArea(oDst) == oArea)
    {
        return FALSE;
    }

    int nActivity = GetLocalInt(oStep, "al_activity");

    int nDur = GetLocalInt(oStep, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 2;
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oSrc, TRUE, 1.5);
    ActionJumpToLocation(GetLocation(oDst));
    ActionDoCommand(AL_TransitionPostAreaHelper(oNpc, oArea));
    AL_ActivityApplyStep(oNpc, nActivity, nDur);

    return TRUE;
}

int AL_TransitionQueueIntraTeleport(object oNpc, object oStep, object oSrc, object oDst)
{
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    if (GetArea(oSrc) != oArea || GetArea(oDst) != oArea)
    {
        return FALSE;
    }

    int nActivity = GetLocalInt(oStep, "al_activity");

    int nDur = GetLocalInt(oStep, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 2;
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oSrc, TRUE, 1.5);
    ActionJumpToLocation(GetLocation(oDst));
    AL_ActivityApplyStep(oNpc, nActivity, nDur);
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    return TRUE;
}

int AL_TransitionQueueFromStep(object oNpc, object oStep)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oStep))
    {
        return FALSE;
    }

    int nType = AL_TransitionTypeFromStep(oStep);
    if (nType == AL_TRANSITION_NONE)
    {
        return FALSE;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetLocalInt(oArea, "al_sim_tier") != AL_SIM_TIER_HOT)
    {
        return FALSE;
    }

    object oSrc = OBJECT_INVALID;
    object oDst = OBJECT_INVALID;
    if (!AL_TransitionResolveEndpoints(oStep, oNpc, oArea, oSrc, oDst))
    {
        return FALSE;
    }

    if (nType == AL_TRANSITION_AREA_HELPER)
    {
        return AL_TransitionQueueAreaHelper(oNpc, oStep, oSrc, oDst);
    }

    if (nType == AL_TRANSITION_INTRA_TELEPORT)
    {
        return AL_TransitionQueueIntraTeleport(oNpc, oStep, oSrc, oDst);
    }

    return FALSE;
}
