// Ambient Life Stage F transition subsystem.
// Separate from Stage D/E area-scoped route cache runtime.

#include "al_area_inc"
#include "al_activity_inc"
#include "al_events_inc"

const int AL_TRANSITION_NONE = 0;
const int AL_TRANSITION_AREA_HELPER = 1;
const int AL_TRANSITION_INTRA_TELEPORT = 2;

string AL_TransitionRtActiveKey() { return "al_trans_rt_active"; }
string AL_TransitionRtTypeKey() { return "al_trans_rt_type"; }
string AL_TransitionRtDstKey() { return "al_trans_rt_dst"; }

void AL_TransitionRuntimeClear(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, AL_TransitionRtActiveKey(), FALSE);
    SetLocalInt(oNpc, AL_TransitionRtTypeKey(), AL_TRANSITION_NONE);
    DeleteLocalObject(oNpc, AL_TransitionRtDstKey());
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

    oSrc = GetObjectByTag(sSrcTag, 0);
    oDst = GetObjectByTag(sDstTag, 0);

    if (!GetIsObjectValid(oSrc) || !GetIsObjectValid(oDst))
    {
        return FALSE;
    }

    if (GetObjectType(oSrc) != OBJECT_TYPE_WAYPOINT || GetObjectType(oDst) != OBJECT_TYPE_WAYPOINT)
    {
        return FALSE;
    }

    // Transition source must belong to current NPC area, destination may be remote.
    if (GetArea(oSrc) != oArea)
    {
        return FALSE;
    }

    return TRUE;
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
    if (nActivity <= AL_ACTIVITY_IDLE)
    {
        nActivity = GetLocalInt(oNpc, "al_default_activity");
    }

    int nDur = GetLocalInt(oStep, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 2;
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oSrc, TRUE, 1.5);
    ActionJumpToLocation(GetLocation(oDst));
    AL_ActivityApplyBaseline(oNpc, nActivity, nDur);
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    SetLocalInt(oNpc, AL_TransitionRtActiveKey(), TRUE);
    SetLocalInt(oNpc, AL_TransitionRtTypeKey(), AL_TRANSITION_AREA_HELPER);
    SetLocalObject(oNpc, AL_TransitionRtDstKey(), oDst);

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
    if (nActivity <= AL_ACTIVITY_IDLE)
    {
        nActivity = GetLocalInt(oNpc, "al_default_activity");
    }

    int nDur = GetLocalInt(oStep, "al_dur_sec");
    if (nDur <= 0)
    {
        nDur = 2;
    }

    ClearAllActions(TRUE);
    ActionMoveToObject(oSrc, TRUE, 1.5);
    ActionJumpToLocation(GetLocation(oDst));
    AL_ActivityApplyBaseline(oNpc, nActivity, nDur);
    ActionDoCommand(SignalEvent(oNpc, EventUserDefined(AL_EVENT_ROUTE_REPEAT)));

    SetLocalInt(oNpc, AL_TransitionRtActiveKey(), TRUE);
    SetLocalInt(oNpc, AL_TransitionRtTypeKey(), AL_TRANSITION_INTRA_TELEPORT);
    SetLocalObject(oNpc, AL_TransitionRtDstKey(), oDst);

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
