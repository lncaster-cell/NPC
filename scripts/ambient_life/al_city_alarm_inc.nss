// Ambient Life city-wide alarm controller (Phase 1 foundation).

#include "al_city_registry_inc"

int AL_IsHotArea(object oArea);

const int AL_CITY_ALARM_IDLE = 0;
const int AL_CITY_ALARM_PENDING_ALARM = 1;
const int AL_CITY_ALARM_ACTIVE_ALARM = 2;
const int AL_CITY_ALARM_CLEARING = 3;
const int AL_CITY_ALARM_RECOVERY = 4;

const int AL_CITY_WAR_POST_CAPACITY = 5;

int AL_CityAlarmGetState(object oArea)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return AL_CITY_ALARM_IDLE;
    }

    return GetLocalInt(GetModule(), AL_CityRegistryCityKey(sCityId, "alarm_state"));
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

    if (AL_CityRegistryEnemyCount(oArea) > 0)
    {
        AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_ACTIVE_ALARM);
        return;
    }

    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_CLEARING);
    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_RECOVERY);
    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_IDLE);
}
