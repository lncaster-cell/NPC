// Ambient Life Stage I.2 disturbed reaction layer.
// Scope: Stage I.1 foundation + bounded local crime/alarm escalation (area-local only).

#include "al_area_inc"
#include "al_activity_inc"
#include "al_events_inc"

const int AL_REACT_TYPE_NONE = 0;
const int AL_REACT_TYPE_ADDED = 1;
const int AL_REACT_TYPE_REMOVED = 2;
const int AL_REACT_TYPE_STOLEN = 3;
const int AL_REACT_TYPE_UNKNOWN = 4;

const int AL_CRIME_KIND_NONE = 0;
const int AL_CRIME_KIND_SUSPICIOUS = 1;
const int AL_CRIME_KIND_THEFT = 2;
const int AL_CRIME_KIND_HOSTILE_LEGAL = 3;

const int AL_NPC_ROLE_CIVILIAN = 0;
const int AL_NPC_ROLE_MILITIA = 1;
const int AL_NPC_ROLE_GUARD = 2;

const int AL_CRIME_DEBOUNCE_TICKS = 2;
const float AL_LOCAL_ALARM_RADIUS = 18.0;
const int AL_LOCAL_ALARM_MAX_RESPONDERS = 8;

// Route runtime hooks consumed by Stage I.1 reaction layer.
string AL_RouteRtActiveKey();
int AL_RouteRoutineResumeCurrent(object oNpc);
void AL_RouteBlockedRuntimeReset(object oNpc);

// Local helper forward declarations used by bounded alarm fan-out path.
int AL_ReactShouldOverrideRoutine(object oActor);
void AL_ReactRuntimeBegin(object oActor, int nReactType, object oSource, object oItem);
void AL_ReactRunBoundedOverride(object oNpc, int bHasCredibleSource, int nCrimeKind);
void AL_ReactResumeOrResetOnSelf();
void AL_ReactFinishCreature(object oNpc);
void AL_ReactApplyActivityStepSelfSafe(object oNpc, int nStepActivity, int nDurSec);

object AL_FindNearestSafeWaypointFromCache(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return OBJECT_INVALID;
    }

    object oCached = GetLocalObject(oNpc, "al_safe_wp_cache");
    if (!GetIsObjectValid(oCached) || GetObjectType(oCached) != OBJECT_TYPE_WAYPOINT || GetArea(oCached) != oArea)
    {
        DeleteLocalObject(oNpc, "al_safe_wp_cache");
        return OBJECT_INVALID;
    }

    return oCached;
}

void AL_ReactApplyActivityStepSelfSafe(object oNpc, int nStepActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    // Ensure queued activity actions are pushed onto oNpc's action queue.
    SetLocalInt(oNpc, "al_react_step_activity", nStepActivity);
    SetLocalInt(oNpc, "al_react_step_dur", nDurSec);
    AssignCommand(oNpc, ActionDoCommand(ExecuteScript("al_react_apply_step", OBJECT_SELF)));
}

const string AL_REACT_SAFE_WP_TAG_KEY = "al_safe_wp_tag";
const string AL_REACT_SAFE_WP_MARKER_KEY = "al_is_safe_wp";
const string AL_REACT_SAFE_WP_LEGACY_KEY = "al_safe_wp";
const string AL_REACT_SAFE_WP_LEGACY_FLAG = "al_ff_legacy_safe_wp_fallback";

int AL_ReactLegacySafeWpFallbackEnabled()
{
    return GetLocalInt(GetModule(), AL_REACT_SAFE_WP_LEGACY_FLAG) == TRUE;
}

void AL_ReactRecordLegacySafeWpFallbackHit(string sMetricKey)
{
    object oModule = GetModule();
    SetLocalInt(oModule, sMetricKey, GetLocalInt(oModule, sMetricKey) + 1);
}

string AL_ReactNpcSafeWaypointTag(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return "";
    }

    string sSafeTag = GetLocalString(oNpc, AL_REACT_SAFE_WP_TAG_KEY);
    if (sSafeTag != "")
    {
        return sSafeTag;
    }

    if (AL_ReactLegacySafeWpFallbackEnabled())
    {
        string sLegacySafeTag = GetLocalString(oNpc, AL_REACT_SAFE_WP_LEGACY_KEY);
        if (sLegacySafeTag != "")
        {
            AL_ReactRecordLegacySafeWpFallbackHit("al_safe_wp_legacy_tag_fallback_hits");
            return sLegacySafeTag;
        }
    }

    return "";
}

int AL_ReactIsSafeWaypoint(object oWaypoint)
{
    if (!GetIsObjectValid(oWaypoint) || GetObjectType(oWaypoint) != OBJECT_TYPE_WAYPOINT)
    {
        return FALSE;
    }

    if (GetLocalInt(oWaypoint, AL_REACT_SAFE_WP_MARKER_KEY) == TRUE)
    {
        return TRUE;
    }

    // Temporary migration fallback: legacy marker support is controlled by feature-flag.
    if (AL_ReactLegacySafeWpFallbackEnabled() && GetLocalInt(oWaypoint, AL_REACT_SAFE_WP_LEGACY_KEY) == TRUE)
    {
        AL_ReactRecordLegacySafeWpFallbackHit("al_safe_wp_legacy_marker_fallback_hits");
        return TRUE;
    }

    return FALSE;
}

object AL_FindNearestSafeWaypointFromCache(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    object oCachedArea = GetLocalObject(oNpc, "al_safe_lookup_area");
    if (oCachedArea == oArea && GetLocalInt(oNpc, "al_safe_lookup_tick") == nSyncTick)
    {
        object oCachedWp = GetLocalObject(oNpc, "al_safe_lookup_wp");
        if (GetIsObjectValid(oCachedWp) && GetObjectType(oCachedWp) == OBJECT_TYPE_WAYPOINT && GetArea(oCachedWp) == oArea)
        {
            SetLocalInt(oNpc, "al_safe_lookup_hit", GetLocalInt(oNpc, "al_safe_lookup_hit") + 1);
            return oCachedWp;
        }

        SetLocalInt(oNpc, "al_safe_lookup_miss", GetLocalInt(oNpc, "al_safe_lookup_miss") + 1);
        return OBJECT_INVALID;
    }

    return OBJECT_INVALID;
}

object AL_ReactFindNearestSafeWaypoint(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oCached = AL_FindNearestSafeWaypointFromCache(oNpc);
    if (GetIsObjectValid(oCached))
    {
        return oCached;
    }

    int nIndex = 1;
    object oWaypoint = GetNearestObject(OBJECT_TYPE_WAYPOINT, oNpc, nIndex);
    while (GetIsObjectValid(oWaypoint) && nIndex <= 24)
    {
        if (GetArea(oWaypoint) == oArea)
        {
            if (AL_ReactIsSafeWaypoint(oWaypoint))
            {
                SetLocalObject(oNpc, "al_safe_lookup_area", oArea);
                SetLocalInt(oNpc, "al_safe_lookup_tick", GetLocalInt(oArea, "al_sync_tick"));
                SetLocalObject(oNpc, "al_safe_lookup_wp", oWaypoint);
                SetLocalInt(oNpc, "al_safe_lookup_miss", GetLocalInt(oNpc, "al_safe_lookup_miss") + 1);
                return oWaypoint;
            }

            // Temporary compatibility fallback for scenes without explicit safe marker keys.
            // Remove after migration to AL_REACT_SAFE_WP_MARKER_KEY is complete.
            string sTag = GetTag(oWaypoint);
            if (FindSubString(sTag, "safe") >= 0 || FindSubString(sTag, "SAFE") >= 0)
            {
                SetLocalObject(oNpc, "al_safe_lookup_area", oArea);
                SetLocalInt(oNpc, "al_safe_lookup_tick", GetLocalInt(oArea, "al_sync_tick"));
                SetLocalObject(oNpc, "al_safe_lookup_wp", oWaypoint);
                SetLocalInt(oNpc, "al_safe_lookup_miss", GetLocalInt(oNpc, "al_safe_lookup_miss") + 1);
                return oWaypoint;
            }

            string sName = GetName(oWaypoint);
            if (FindSubString(sName, "safe") >= 0 || FindSubString(sName, "SAFE") >= 0)
            {
                SetLocalObject(oNpc, "al_safe_lookup_area", oArea);
                SetLocalInt(oNpc, "al_safe_lookup_tick", GetLocalInt(oArea, "al_sync_tick"));
                SetLocalObject(oNpc, "al_safe_lookup_wp", oWaypoint);
                SetLocalInt(oNpc, "al_safe_lookup_miss", GetLocalInt(oNpc, "al_safe_lookup_miss") + 1);
                return oWaypoint;
            }
        }

        nIndex = nIndex + 1;
        oWaypoint = GetNearestObject(OBJECT_TYPE_WAYPOINT, oNpc, nIndex);
    }

    SetLocalObject(oNpc, "al_safe_lookup_area", oArea);
    SetLocalInt(oNpc, "al_safe_lookup_tick", GetLocalInt(oArea, "al_sync_tick"));
    DeleteLocalObject(oNpc, "al_safe_lookup_wp");
    SetLocalInt(oNpc, "al_safe_lookup_miss", GetLocalInt(oNpc, "al_safe_lookup_miss") + 1);

    return OBJECT_INVALID;
}

object AL_ReactResolveSafeWaypointInArea(object oNpc, string sTag)
{
    if (!GetIsObjectValid(oNpc) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    return AL_ResolveWaypointInAreaCached(oArea, sTag);
}

int AL_ReactGetAreaSyncTick(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    return GetLocalInt(oArea, "al_sync_tick");
}

void AL_ReactAreaAlarmClear(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalInt(oArea, "al_alarm_state", AL_CRIME_KIND_NONE);
    SetLocalInt(oArea, "al_alarm_until", 0);
    DeleteLocalObject(oArea, "al_alarm_source");
}

void AL_ReactAreaAlarmRefresh(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nUntil = GetLocalInt(oArea, "al_alarm_until");
    int nTick = AL_ReactGetAreaSyncTick(oArea);

    if (nUntil <= 0 || nTick <= nUntil)
    {
        return;
    }

    AL_ReactAreaAlarmClear(oArea);
}

int AL_ReactGetNpcRole(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE)
    {
        return AL_NPC_ROLE_CIVILIAN;
    }

    int nRole = GetLocalInt(oNpc, "al_npc_role");
    if (nRole < AL_NPC_ROLE_CIVILIAN || nRole > AL_NPC_ROLE_GUARD)
    {
        return AL_NPC_ROLE_CIVILIAN;
    }

    return nRole;
}

int AL_ReactIsSourceAllowed(object oDisturbed, object oSource)
{
    if (!GetIsObjectValid(oDisturbed) || !GetIsObjectValid(oSource))
    {
        return FALSE;
    }

    if (GetLocalInt(oDisturbed, "al_allow_all") == TRUE)
    {
        return TRUE;
    }

    string sSourceTag = GetTag(oSource);
    string sOwnerTag = GetLocalString(oDisturbed, "al_owner_tag");
    if (sOwnerTag != "" && sOwnerTag == sSourceTag)
    {
        return TRUE;
    }

    string sAllowedTag = GetLocalString(oDisturbed, "al_allowed_tag");
    if (sAllowedTag != "" && sAllowedTag == sSourceTag)
    {
        return TRUE;
    }

    return FALSE;
}

int AL_ReactHasWitness(object oDisturbed, object oSource)
{
    if (!GetIsObjectValid(oDisturbed))
    {
        return FALSE;
    }

    // Content rule: forced witness flag on disturbed actor always enables witness path.
    if (GetLocalInt(oDisturbed, "al_force_witness") == TRUE)
    {
        return TRUE;
    }

    object oArea = GetArea(oDisturbed);
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    // Optional area-level override for staged scenes/scripts that need guaranteed witnesses.
    if (GetLocalInt(oArea, "al_force_witness") == TRUE)
    {
        return TRUE;
    }

    // Witnesses require a valid creature source physically in the same area.
    if (!GetIsObjectValid(oSource) || GetObjectType(oSource) != OBJECT_TYPE_CREATURE || GetArea(oSource) != oArea)
    {
        return FALSE;
    }

    // Baseline witness signal: at least one player/observer tracked in area state.
    return (GetLocalInt(oArea, "al_player_count") > 0);

}

// Crime classification is intentionally deterministic:
// - witness = AL_ReactHasWitness(...), see witness criteria above;
// - THEFT requires source + item + witness + not allowed;
// - SUSPICIOUS covers non-allowed partial evidence (source and/or witness).
// Debounce/alarm pipeline consumes nCrimeKind as-is, so witness changes only alter
// classification inputs and remain stable through AL_ReactIncidentDebounced ->
// AL_ReactRaiseAreaAlarm -> AL_ReactNotifyNearbyResponders.
int AL_ReactClassifyCrime(object oActor, int nReactType, object oSource, object oItem)
{
    if (nReactType == AL_REACT_TYPE_ADDED || nReactType == AL_REACT_TYPE_NONE)
    {
        return AL_CRIME_KIND_NONE;
    }

    int bHasSource = GetIsObjectValid(oSource) && oSource != oActor;
    int bHasItem = GetIsObjectValid(oItem);
    int bAllowed = AL_ReactIsSourceAllowed(oActor, oSource);
    int bWitness = AL_ReactHasWitness(oActor, oSource);

    if (nReactType == AL_REACT_TYPE_STOLEN)
    {
        if (bHasSource && bHasItem && bWitness && !bAllowed)
        {
            return AL_CRIME_KIND_THEFT;
        }

        if (!bAllowed && (bHasSource || bWitness))
        {
            return AL_CRIME_KIND_SUSPICIOUS;
        }
    }

    if ((nReactType == AL_REACT_TYPE_REMOVED || nReactType == AL_REACT_TYPE_UNKNOWN) && !bAllowed && (bHasSource || bWitness))
    {
        return AL_CRIME_KIND_SUSPICIOUS;
    }

    return AL_CRIME_KIND_NONE;
}

int AL_ReactPromoteByRole(int nCrimeKind, int nNpcRole)
{
    if (nCrimeKind == AL_CRIME_KIND_NONE)
    {
        return AL_CRIME_KIND_NONE;
    }

    if (nNpcRole == AL_NPC_ROLE_GUARD && nCrimeKind >= AL_CRIME_KIND_THEFT)
    {
        return AL_CRIME_KIND_HOSTILE_LEGAL;
    }

    return nCrimeKind;
}

int AL_ReactAlarmDebounced(object oArea, object oSource, int nCrimeKind)
{
    if (!GetIsObjectValid(oArea) || nCrimeKind <= AL_CRIME_KIND_NONE)
    {
        return TRUE;
    }

    int nTick = AL_ReactGetAreaSyncTick(oArea);
    int nLastTick = GetLocalInt(oArea, "al_alarm_last_tick");
    object oLastSource = GetLocalObject(oArea, "al_alarm_last_source");
    int nLastKind = GetLocalInt(oArea, "al_alarm_last_kind");

    if (nTick > 0 && nLastTick > 0 && nTick <= (nLastTick + AL_CRIME_DEBOUNCE_TICKS) && oLastSource == oSource && nCrimeKind <= nLastKind)
    {
        return TRUE;
    }

    SetLocalInt(oArea, "al_alarm_last_tick", nTick);
    SetLocalObject(oArea, "al_alarm_last_source", oSource);
    SetLocalInt(oArea, "al_alarm_last_kind", nCrimeKind);
    return FALSE;
}

int AL_ReactIncidentDebounced(object oActor, object oSource, int nCrimeKind)
{
    if (!GetIsObjectValid(oActor) || nCrimeKind <= AL_CRIME_KIND_NONE)
    {
        return TRUE;
    }

    object oArea = GetArea(oActor);
    int nTick = AL_ReactGetAreaSyncTick(oArea);

    int nLastTick = GetLocalInt(oActor, "al_react_last_crime_tick");
    object oLastSource = GetLocalObject(oActor, "al_react_last_crime_source");
    int nLastKind = GetLocalInt(oActor, "al_react_last_crime_kind");

    if (nTick > 0 && nLastTick > 0 && nTick <= (nLastTick + AL_CRIME_DEBOUNCE_TICKS) && oLastSource == oSource && nCrimeKind <= nLastKind)
    {
        return TRUE;
    }

    SetLocalInt(oActor, "al_react_last_crime_tick", nTick);
    SetLocalObject(oActor, "al_react_last_crime_source", oSource);
    SetLocalInt(oActor, "al_react_last_crime_kind", nCrimeKind);
    return FALSE;
}

void AL_ReactRaiseAreaAlarm(object oActor, object oSource, int nCrimeKind)
{
    object oArea = GetArea(oActor);
    if (!GetIsObjectValid(oArea) || nCrimeKind <= AL_CRIME_KIND_NONE)
    {
        return;
    }

    AL_ReactAreaAlarmRefresh(oArea);
    if (AL_ReactAlarmDebounced(oArea, oSource, nCrimeKind))
    {
        return;
    }

    int nTick = AL_ReactGetAreaSyncTick(oArea);
    int nDuration = 2;
    if (nCrimeKind == AL_CRIME_KIND_THEFT)
    {
        nDuration = 4;
    }
    else if (nCrimeKind == AL_CRIME_KIND_HOSTILE_LEGAL)
    {
        nDuration = 6;
    }

    int nState = GetLocalInt(oArea, "al_alarm_state");
    if (nCrimeKind > nState)
    {
        SetLocalInt(oArea, "al_alarm_state", nCrimeKind);
    }

    int nUntil = nTick + nDuration;
    if (GetLocalInt(oArea, "al_alarm_until") < nUntil)
    {
        SetLocalInt(oArea, "al_alarm_until", nUntil);
    }

    if (GetIsObjectValid(oSource))
    {
        SetLocalObject(oArea, "al_alarm_source", oSource);
    }
}

void AL_ReactCivilianResponse(object oNpc, object oSource)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AssignCommand(oNpc, ActionSpeakString("Thief! Help!", TALKVOLUME_SHOUT));

    object oSafe = AL_ReactResolveSafeWaypointInArea(oNpc, AL_ReactNpcSafeWaypointTag(oNpc));
    if (GetIsObjectValid(oSafe))
    {
        AssignCommand(oNpc, ActionMoveToObject(oSafe, TRUE, 1.5));
        return;
    }

    // Fallback intent: increase distance from threat (safe waypoint -> retreat vector),
    // and if no retreat target can be built, keep the civilian in-place in panic state.
    object oFallbackSafe = AL_ReactFindNearestSafeWaypoint(oNpc);
    if (GetIsObjectValid(oFallbackSafe))
    {
        AssignCommand(oNpc, ActionMoveToObject(oFallbackSafe, TRUE, 1.5));
        return;
    }

    if (GetIsObjectValid(oSource) && GetArea(oSource) == GetArea(oNpc))
    {
        vector vNpcPos = GetPosition(oNpc);
        vector vSrcPos = GetPosition(oSource);
        vector vAwayDir = vNpcPos - vSrcPos;
        float fAwayLen = VectorMagnitude(vAwayDir);

        if (fAwayLen > 0.1)
        {
            vector vRetreatPos = vNpcPos + ((vAwayDir / fAwayLen) * 10.0);
            location lRetreat = Location(GetArea(oNpc), vRetreatPos, GetFacing(oNpc));
            AssignCommand(oNpc, ActionMoveToLocation(lRetreat, TRUE));
            return;
        }
    }

    AL_ReactApplyActivityStepSelfSafe(oNpc, AL_ACTIVITY_ANGRY, 4);
}

void AL_ReactMilitiaResponse(object oNpc, object oSource)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSource))
    {
        return;
    }

    AssignCommand(oNpc, ActionAttack(oSource));
}

void AL_ReactGuardResponse(object oNpc, object oSource, int nCrimeKind)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oSource))
    {
        return;
    }

    // Built-in hostility/faction alignment remains primary; legal chain is future stage hook.
    int bFactionMismatch = !GetFactionEqual(oNpc, oSource);
    int bBuiltInHostile = GetIsReactionTypeHostile(oNpc, oSource);
    if (nCrimeKind >= AL_CRIME_KIND_HOSTILE_LEGAL || bBuiltInHostile || bFactionMismatch)
    {
        AssignCommand(oNpc, ActionAttack(oSource));
        return;
    }

    AssignCommand(oNpc, ActionSpeakString("Stop!", TALKVOLUME_SHOUT));
    AssignCommand(oNpc, ActionMoveToObject(oSource, TRUE, 2.0));
}

int AL_ReactShouldNpcJoinLocalAlarm(object oNpc, object oSource)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return FALSE;
    }

    if (GetIsObjectValid(oSource) && oNpc == oSource)
    {
        return FALSE;
    }

    return AL_ReactShouldOverrideRoutine(oNpc);
}

void AL_ReactNotifyNearbyResponders(object oActor, object oSource, int nCrimeKind)
{
    if (!GetIsObjectValid(oActor) || nCrimeKind <= AL_CRIME_KIND_NONE)
    {
        return;
    }

    object oArea = GetArea(oActor);
    if (!AL_IsHotArea(oArea))
    {
        return;
    }

    location lCenter = GetLocation(oActor);
    object oCandidate = GetFirstObjectInShape(SHAPE_SPHERE, AL_LOCAL_ALARM_RADIUS, lCenter, FALSE, OBJECT_TYPE_CREATURE);
    int nJoined = 0;

    while (GetIsObjectValid(oCandidate) && nJoined < AL_LOCAL_ALARM_MAX_RESPONDERS)
    {
        object oNext = GetNextObjectInShape(SHAPE_SPHERE, AL_LOCAL_ALARM_RADIUS, lCenter, FALSE, OBJECT_TYPE_CREATURE);

        if (oCandidate != oActor && AL_ReactShouldNpcJoinLocalAlarm(oCandidate, oSource))
        {
            // Fan-out responders are non-OBJECT_SELF targets: all behavior must be enqueued via AssignCommand.
            AL_ReactRuntimeBegin(oCandidate, AL_REACT_TYPE_STOLEN, oSource, OBJECT_INVALID);
            SetLocalInt(oCandidate, "al_react_resume_flag", TRUE);
            AL_ReactRunBoundedOverride(oCandidate, GetIsObjectValid(oSource), nCrimeKind);
            AL_ReactFinishCreature(oCandidate);
            nJoined = nJoined + 1;
        }

        oCandidate = oNext;
    }
}

int AL_ReactTypeFromDisturb(int nDisturbType)
{
    if (nDisturbType == INVENTORY_DISTURB_TYPE_ADDED)
    {
        return AL_REACT_TYPE_ADDED;
    }

    if (nDisturbType == INVENTORY_DISTURB_TYPE_REMOVED)
    {
        return AL_REACT_TYPE_REMOVED;
    }

    if (nDisturbType == INVENTORY_DISTURB_TYPE_STOLEN)
    {
        return AL_REACT_TYPE_STOLEN;
    }

    return AL_REACT_TYPE_UNKNOWN;
}

int AL_ReactShouldOverrideRoutine(object oActor)
{
    if (!GetIsObjectValid(oActor) || GetObjectType(oActor) != OBJECT_TYPE_CREATURE || GetIsPC(oActor))
    {
        return FALSE;
    }

    object oArea = GetArea(oActor);
    if (!AL_IsHotArea(oArea))
    {
        return FALSE;
    }

    return GetLocalInt(oActor, AL_RouteRtActiveKey());
}

void AL_ReactRuntimeClear(object oActor)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    SetLocalInt(oActor, "al_react_active", FALSE);
    SetLocalInt(oActor, "al_react_resume_flag", FALSE);
}

void AL_ReactRuntimeBegin(object oActor, int nReactType, object oSource, object oItem)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    SetLocalInt(oActor, "al_react_active", TRUE);
    SetLocalInt(oActor, "al_react_type", nReactType);

    if (GetIsObjectValid(oSource))
    {
        SetLocalObject(oActor, "al_react_last_source", oSource);
    }
    else
    {
        DeleteLocalObject(oActor, "al_react_last_source");
    }

    if (GetIsObjectValid(oItem))
    {
        SetLocalObject(oActor, "al_react_last_item", oItem);
    }
    else
    {
        DeleteLocalObject(oActor, "al_react_last_item");
    }
}

void AL_ReactRunBoundedOverride(object oNpc, int bHasCredibleSource, int nCrimeKind)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AssignCommand(oNpc, ClearAllActions(TRUE));

    if (nCrimeKind > AL_CRIME_KIND_NONE)
    {
        int nRole = AL_ReactGetNpcRole(oNpc);
        object oSource = GetLocalObject(oNpc, "al_react_last_source");

        if (nRole == AL_NPC_ROLE_CIVILIAN)
        {
            AL_ReactCivilianResponse(oNpc, oSource);
        }
        else if (nRole == AL_NPC_ROLE_MILITIA)
        {
            AL_ReactMilitiaResponse(oNpc, oSource);
        }
        else
        {
            AL_ReactGuardResponse(oNpc, oSource, nCrimeKind);
            SetLocalInt(oNpc, "al_legal_followup_pending", TRUE); // Stage I.3+: surrender/arrest/trial hook.
        }
    }
    else if (bHasCredibleSource)
    {
        object oSource = GetLocalObject(oNpc, "al_react_last_source");
        AssignCommand(oNpc, ActionMoveToObject(oSource, TRUE, 2.0));
    }

    // Keep ActionWait as the queue tail so AL_ReactFinishCreature can append
    // ActionDoCommand(resume/reset) and restore routine only after react actions.
    AssignCommand(oNpc, ActionWait(0.8));
}

void AL_ReactResumeOrResetOnSelf()
{
    if (!AL_RouteRoutineResumeCurrent(OBJECT_SELF))
    {
        AL_RouteBlockedRuntimeReset(OBJECT_SELF);
        SignalEvent(OBJECT_SELF, EventUserDefined(AL_EVENT_RESYNC));
    }
}

void AL_ReactFinishCreature(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int bResume = GetLocalInt(oNpc, "al_react_resume_flag");

    AL_ReactRuntimeClear(oNpc);

    if (!bResume)
    {
        return;
    }

    AssignCommand(oNpc, ActionDoCommand(ExecuteScript("al_react_resume_reset", OBJECT_SELF)));
}

void AL_OnDisturbed(object oActor)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    if (GetLocalInt(oActor, "al_react_active"))
    {
        return;
    }

    AL_ReactAreaAlarmRefresh(GetArea(oActor));

    object oSource = GetLastDisturbed();
    int nDisturbType = GetInventoryDisturbType();
    object oItem = GetInventoryDisturbItem();

    int nReactType = AL_ReactTypeFromDisturb(nDisturbType);
    AL_ReactRuntimeBegin(oActor, nReactType, oSource, oItem);

    if (nReactType == AL_REACT_TYPE_ADDED)
    {
        AL_ReactRuntimeClear(oActor);
        return;
    }

    int bCanOverride = AL_ReactShouldOverrideRoutine(oActor);
    SetLocalInt(oActor, "al_react_resume_flag", bCanOverride);

    // Creature theft context can be partial in toolset/runtime edge cases.
    // Treat missing source/item on stolen as suspicious but bounded.
    int bHasCredibleSource = GetIsObjectValid(oSource) && oSource != oActor;

    int nCrimeKind = AL_ReactClassifyCrime(oActor, nReactType, oSource, oItem);
    int nRole = AL_ReactGetNpcRole(oActor);
    nCrimeKind = AL_ReactPromoteByRole(nCrimeKind, nRole);

    // Debounce/alarm fan-out uses the already-classified crime kind and does not
    // re-evaluate witness criteria; this keeps THEFT/SUSPICIOUS transitions predictable.
    if (!AL_ReactIncidentDebounced(oActor, oSource, nCrimeKind))
    {
        AL_ReactRaiseAreaAlarm(oActor, oSource, nCrimeKind);
        AL_ReactNotifyNearbyResponders(oActor, oSource, nCrimeKind);
    }

    if (bCanOverride)
    {
        AL_ReactRunBoundedOverride(oActor, bHasCredibleSource, nCrimeKind);
    }

    AL_ReactFinishCreature(oActor);
}
