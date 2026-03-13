// Ambient Life city-wide alarm controller (Phase 2 runtime integration).

#include "al_city_registry_inc"
#include "al_react_inc"
#include "al_events_inc"

int AL_IsHotArea(object oArea);
int AL_IsRuntimeNpc(object oNpc);

const int AL_CITY_ALARM_IDLE = 0;
const int AL_CITY_ALARM_PENDING_ALARM = 1;
const int AL_CITY_ALARM_ACTIVE_ALARM = 2;
const int AL_CITY_ALARM_CLEARING = 3;
const int AL_CITY_ALARM_RECOVERY = 4;

const int AL_CITY_WAR_POST_CAPACITY = 5;
const int AL_CITY_ALARM_BELL_TIMEOUT_TICKS = 3;
const int AL_CITY_ALARM_RECOVERY_BATCH_LIMIT = 6;
const int AL_CITY_ALARM_RESYNC_BATCH_LIMIT = 12;

int AL_CityAlarmGetState(object oArea)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return AL_CITY_ALARM_IDLE;
    }

    return GetLocalInt(GetModule(), AL_CityRegistryCityKey(sCityId, "alarm_state"));
}

string AL_CityAlarmPointTag(object oArea, string sKey)
{
    return GetLocalString(oArea, sKey);
}

object AL_CityAlarmResolvePoint(object oArea, string sTag)
{
    if (!GetIsObjectValid(oArea) || sTag == "")
    {
        return OBJECT_INVALID;
    }

    int n = 0;
    object oPoint = GetObjectByTag(sTag, n);
    while (GetIsObjectValid(oPoint))
    {
        if (GetArea(oPoint) == oArea)
        {
            return oPoint;
        }

        n = n + 1;
        oPoint = GetObjectByTag(sTag, n);
    }

    return OBJECT_INVALID;
}

int AL_CityAlarmTryClaimWarPost(object oArea, int nPostIdx, object oNpc)
{
    string sCountKey = "al_city_war_post_occ_count_" + IntToString(nPostIdx);
    int nCount = GetLocalInt(oArea, sCountKey);
    if (nCount >= AL_CITY_WAR_POST_CAPACITY)
    {
        return FALSE;
    }

    int i = 0;
    while (i < nCount)
    {
        object oOccupant = GetLocalObject(oArea, "al_city_war_post_occ_" + IntToString(nPostIdx) + "_" + IntToString(i));
        if (oOccupant == oNpc)
        {
            return TRUE;
        }

        i = i + 1;
    }

    SetLocalObject(oArea, "al_city_war_post_occ_" + IntToString(nPostIdx) + "_" + IntToString(nCount), oNpc);
    SetLocalInt(oArea, sCountKey, nCount + 1);
    SetLocalInt(oNpc, "al_city_alarm_post_idx", nPostIdx);
    return TRUE;
}

void AL_CityAlarmReleaseWarPost(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nPostIdx = GetLocalInt(oNpc, "al_city_alarm_post_idx");
    if (nPostIdx < 0)
    {
        return;
    }

    string sCountKey = "al_city_war_post_occ_count_" + IntToString(nPostIdx);
    int nCount = GetLocalInt(oArea, sCountKey);
    if (nCount <= 0)
    {
        DeleteLocalInt(oNpc, "al_city_alarm_post_idx");
        return;
    }

    int i = 0;
    while (i < nCount)
    {
        string sKey = "al_city_war_post_occ_" + IntToString(nPostIdx) + "_" + IntToString(i);
        if (GetLocalObject(oArea, sKey) == oNpc)
        {
            int nLast = nCount - 1;
            if (i != nLast)
            {
                SetLocalObject(oArea, sKey, GetLocalObject(oArea, "al_city_war_post_occ_" + IntToString(nPostIdx) + "_" + IntToString(nLast)));
            }

            DeleteLocalObject(oArea, "al_city_war_post_occ_" + IntToString(nPostIdx) + "_" + IntToString(nLast));
            SetLocalInt(oArea, sCountKey, nLast);
            break;
        }

        i = i + 1;
    }

    DeleteLocalInt(oNpc, "al_city_alarm_post_idx");
}

int AL_CityAlarmFindNearestFreeWarPost(object oNpc)
{
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return -1;
    }

    int nPostCount = GetLocalInt(oArea, "al_city_war_post_count");
    float fBest = 10000000.0;
    int nBestIdx = -1;
    location lSelf = GetLocation(oNpc);

    int i = 0;
    while (i < nPostCount)
    {
        if (GetLocalInt(oArea, "al_city_war_post_occ_count_" + IntToString(i)) < AL_CITY_WAR_POST_CAPACITY)
        {
            string sTag = GetLocalString(oArea, "al_city_war_post_tag_" + IntToString(i));
            object oPost = AL_CityAlarmResolvePoint(oArea, sTag);
            if (GetIsObjectValid(oPost))
            {
                float fDist = GetDistanceBetweenLocations(lSelf, GetLocation(oPost));
                if (nBestIdx < 0 || fDist < fBest)
                {
                    nBestIdx = i;
                    fBest = fDist;
                }
            }
        }

        i = i + 1;
    }

    return nBestIdx;
}

void AL_CityAlarmSetMilitiaAlarmLoadout(object oNpc, int bAlarm)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (bAlarm)
    {
        SetLocalInt(oNpc, "al_city_alarm_loadout_active", TRUE);
    }
    else
    {
        DeleteLocalInt(oNpc, "al_city_alarm_loadout_active");
    }
}

void AL_CityAlarmAssignShelter(object oNpc)
{
    object oArea = GetArea(oNpc);
    object oShelter = AL_CityAlarmResolvePoint(oArea, AL_CityAlarmPointTag(oArea, "al_city_shelter_tag"));

    SetLocalString(oNpc, "al_city_alarm_assignment", "go_shelter");
    if (GetIsObjectValid(oShelter))
    {
        SetLocalObject(oNpc, "al_city_alarm_assignment_target", oShelter);
    }

    SignalEvent(oNpc, EventUserDefined(AL_EVENT_CITY_ASSIGN_GO_SHELTER));
}

void AL_CityAlarmAssignArsenal(object oNpc)
{
    object oArea = GetArea(oNpc);
    object oArsenal = AL_CityAlarmResolvePoint(oArea, AL_CityAlarmPointTag(oArea, "al_city_arsenal_tag"));

    SetLocalString(oNpc, "al_city_alarm_assignment", "go_arsenal");
    if (GetIsObjectValid(oArsenal))
    {
        SetLocalObject(oNpc, "al_city_alarm_assignment_target", oArsenal);
    }

    SignalEvent(oNpc, EventUserDefined(AL_EVENT_CITY_ASSIGN_GO_ARSENAL));
}

void AL_CityAlarmAssignWarPost(object oNpc, int nPostIdx)
{
    object oArea = GetArea(oNpc);
    object oPost = OBJECT_INVALID;
    if (nPostIdx >= 0)
    {
        oPost = AL_CityAlarmResolvePoint(oArea, GetLocalString(oArea, "al_city_war_post_tag_" + IntToString(nPostIdx)));
    }

    SetLocalString(oNpc, "al_city_alarm_assignment", "hold_war_post");
    if (GetIsObjectValid(oPost))
    {
        SetLocalObject(oNpc, "al_city_alarm_assignment_target", oPost);
    }

    SignalEvent(oNpc, EventUserDefined(AL_EVENT_CITY_ASSIGN_HOLD_WAR_POST));
}

void AL_CityAlarmAssignRecovery(object oNpc)
{
    SetLocalString(oNpc, "al_city_alarm_assignment", "alarm_recovery");
    SignalEvent(oNpc, EventUserDefined(AL_EVENT_CITY_ASSIGN_ALARM_RECOVERY));
}

void AL_CityAlarmNpcLiveApply(object oNpc, int nState)
{
    if (!GetIsObjectValid(oNpc) || !AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    int nRole = AL_ReactGetNpcRole(oNpc);

    if (nState == AL_CITY_ALARM_ACTIVE_ALARM)
    {
        if (nRole == AL_NPC_ROLE_CIVILIAN)
        {
            AL_CityAlarmAssignShelter(oNpc);
            return;
        }

        if (nRole == AL_NPC_ROLE_MILITIA)
        {
            AL_CityAlarmAssignArsenal(oNpc);
            int nPost = AL_CityAlarmFindNearestFreeWarPost(oNpc);
            if (nPost >= 0 && AL_CityAlarmTryClaimWarPost(GetArea(oNpc), nPost, oNpc))
            {
                AL_CityAlarmAssignWarPost(oNpc, nPost);
            }
            return;
        }

        if (nRole == AL_NPC_ROLE_GUARD)
        {
            int nGuardPost = AL_CityAlarmFindNearestFreeWarPost(oNpc);
            if (nGuardPost >= 0 && AL_CityAlarmTryClaimWarPost(GetArea(oNpc), nGuardPost, oNpc))
            {
                AL_CityAlarmAssignWarPost(oNpc, nGuardPost);
            }
        }

        return;
    }

    if (nState == AL_CITY_ALARM_RECOVERY)
    {
        AL_CityAlarmAssignRecovery(oNpc);
        AL_CityAlarmReleaseWarPost(oNpc);
        return;
    }

    if (nState == AL_CITY_ALARM_IDLE)
    {
        AL_CityAlarmReleaseWarPost(oNpc);
        DeleteLocalString(oNpc, "al_city_alarm_assignment");
        DeleteLocalObject(oNpc, "al_city_alarm_assignment_target");
    }
}

void AL_CityAlarmSetDistrictDesiredState(object oDistrict, int nState)
{
    if (!GetIsObjectValid(oDistrict))
    {
        return;
    }

    SetLocalInt(oDistrict, "al_city_alarm_desired_state", nState);

    if (AL_IsHotArea(oDistrict))
    {
        SetLocalInt(oDistrict, "al_city_alarm_live_state", nState);
    }
}

void AL_CityAlarmApplyCityState(object oArea, int nState)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "alarm_state"), nState);

    int nCount = GetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "district_count"));
    int i = 0;
    while (i < nCount)
    {
        object oDistrict = GetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "district_" + IntToString(i)));
        AL_CityAlarmSetDistrictDesiredState(oDistrict, nState);
        i = i + 1;
    }
}

void AL_CityAlarmRaisePending(object oArea, int nCaseId, object oSource)
{
    AL_CityRegistryEnsureDistrict(oArea);
    AL_CityRegistrySetActiveAlarmCase(oArea, nCaseId);
    SetLocalObject(oArea, "al_city_alarm_source", oSource);

    SetLocalInt(oArea, "al_city_alarm_pending_started_tick", GetLocalInt(oArea, "al_sync_tick"));
    SetLocalInt(oArea, "al_city_alarm_bell_on_running", TRUE);

    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_PENDING_ALARM);
}

void AL_CityAlarmActivate(object oArea, int nCaseId, object oSource)
{
    AL_CityRegistryEnsureDistrict(oArea);
    AL_CityRegistrySetActiveAlarmCase(oArea, nCaseId);
    SetLocalObject(oArea, "al_city_alarm_source", oSource);
    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_ACTIVE_ALARM);
}

void AL_CityAlarmTryClear(object oArea)
{
    AL_CityRegistryEnsureDistrict(oArea);
    AL_CityRegistryPruneEnemies(oArea);

    if (AL_CityRegistryEnemyCount(oArea) > 0)
    {
        AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_ACTIVE_ALARM);
        return;
    }

    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_CLEARING);
    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_RECOVERY);
}

void AL_CityAlarmRuntimeTickHot(object oArea)
{
    int nDesired = GetLocalInt(oArea, "al_city_alarm_desired_state");
    int nLive = GetLocalInt(oArea, "al_city_alarm_live_state");

    if (nDesired == AL_CITY_ALARM_PENDING_ALARM)
    {
        int nStart = GetLocalInt(oArea, "al_city_alarm_pending_started_tick");
        int nTick = GetLocalInt(oArea, "al_sync_tick");

        if (nStart <= 0)
        {
            SetLocalInt(oArea, "al_city_alarm_pending_started_tick", nTick);
        }
        else if ((nTick - nStart) >= AL_CITY_ALARM_BELL_TIMEOUT_TICKS)
        {
            SetLocalInt(oArea, "al_city_alarm_bell_on_running", FALSE);
            AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_ACTIVE_ALARM);
            nDesired = AL_CITY_ALARM_ACTIVE_ALARM;
        }
    }

    if (nLive == nDesired)
    {
        if (nDesired == AL_CITY_ALARM_RECOVERY)
        {
            AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_IDLE);
        }
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int nCursor = GetLocalInt(oArea, "al_city_alarm_rt_cursor");
    if (nCursor < 0 || nCursor >= nCount)
    {
        nCursor = 0;
    }

    int nLimit = AL_CITY_ALARM_RECOVERY_BATCH_LIMIT;
    if (nDesired == AL_CITY_ALARM_ACTIVE_ALARM)
    {
        nLimit = AL_CITY_ALARM_RESYNC_BATCH_LIMIT;
    }

    int nProcessed = 0;
    while (nCursor < nCount && nProcessed < nLimit)
    {
        object oNpc = GetLocalObject(oArea, "al_npc_" + IntToString(nCursor));
        nCursor = nCursor + 1;
        if (!GetIsObjectValid(oNpc))
        {
            continue;
        }

        AL_CityAlarmNpcLiveApply(oNpc, nDesired);
        nProcessed = nProcessed + 1;
    }

    SetLocalInt(oArea, "al_city_alarm_rt_cursor", nCursor);

    if (nCursor >= nCount)
    {
        SetLocalInt(oArea, "al_city_alarm_rt_cursor", 0);
        SetLocalInt(oArea, "al_city_alarm_live_state", nDesired);

        if (nDesired == AL_CITY_ALARM_RECOVERY)
        {
            AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_IDLE);
        }
    }
}

void AL_CityAlarmMaterializeNpc(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nDesired = GetLocalInt(oArea, "al_city_alarm_desired_state");
    if (nDesired <= AL_CITY_ALARM_IDLE)
    {
        AL_CityAlarmSetMilitiaAlarmLoadout(oNpc, FALSE);
        AL_CityAlarmReleaseWarPost(oNpc);
        return;
    }

    int nRole = AL_ReactGetNpcRole(oNpc);
    if (nRole == AL_NPC_ROLE_CIVILIAN)
    {
        SetLocalInt(oNpc, "al_city_alarm_materialized_sheltered", TRUE);
        return;
    }

    if (nRole == AL_NPC_ROLE_MILITIA)
    {
        AL_CityAlarmSetMilitiaAlarmLoadout(oNpc, TRUE);
    }

    if (nRole == AL_NPC_ROLE_MILITIA || nRole == AL_NPC_ROLE_GUARD)
    {
        int nPost = AL_CityAlarmFindNearestFreeWarPost(oNpc);
        if (nPost >= 0)
        {
            AL_CityAlarmTryClaimWarPost(oArea, nPost, oNpc);
        }
    }
}

void AL_CityAlarmOnAreaActivated(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nDesired = GetLocalInt(oArea, "al_city_alarm_desired_state");
    if (nDesired <= 0)
    {
        nDesired = AL_CityAlarmGetState(oArea);
        SetLocalInt(oArea, "al_city_alarm_desired_state", nDesired);
    }

    SetLocalInt(oArea, "al_city_alarm_live_state", nDesired);

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;
    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, "al_npc_" + IntToString(i));
        if (GetIsObjectValid(oNpc))
        {
            AL_CityAlarmMaterializeNpc(oNpc);
        }
        i = i + 1;
    }
}
