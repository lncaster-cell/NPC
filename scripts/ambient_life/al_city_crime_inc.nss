// Ambient Life city crime layer (Phase 1 foundation).

#include "al_city_registry_inc"
#include "al_city_alarm_inc"

int AL_IsRuntimeNpc(object oNpc);

const int AL_CITY_CRIME_NONE = 0;
const int AL_CITY_CRIME_THEFT = 1;
const int AL_CITY_CRIME_ASSAULT = 2;
const int AL_CITY_CRIME_MURDER = 3;
const int AL_CITY_CRIME_HIDDEN_MURDER = 4;
const int AL_CITY_CRIME_DISCOVERED_MURDER = 5;

const int AL_CITY_CASE_STATUS_OPEN = 1;
const int AL_CITY_CASE_STATUS_LATENT = 2;

int AL_CityCrimeIsInteriorSingleNpcCase(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    int nType = AL_CityRegistryResolveDistrictType(oArea);
    if (nType != AL_CITY_DISTRICT_INTERIOR)
    {
        return FALSE;
    }

    return GetLocalInt(oArea, "al_npc_count") <= 1;
}

int AL_CityCrimeNextCaseId(object oArea)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return 0;
    }

    object oModule = GetModule();
    int nSeq = GetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "case_seq")) + 1;
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "case_seq"), nSeq);
    return nSeq;
}

int AL_CityCrimeOpenCase(object oArea, object oSource, int nKind, int nStatus)
{
    AL_CityRegistryEnsureDistrict(oArea);

    int nCaseId = AL_CityCrimeNextCaseId(oArea);
    if (nCaseId <= 0)
    {
        return 0;
    }

    object oModule = GetModule();
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    string sCaseRoot = AL_CityRegistryCityKey(sCityId, "case_" + IntToString(nCaseId));

    SetLocalInt(oModule, sCaseRoot + "_kind", nKind);
    SetLocalInt(oModule, sCaseRoot + "_status", nStatus);
    SetLocalObject(oModule, sCaseRoot + "_area", oArea);
    SetLocalObject(oModule, sCaseRoot + "_source", oSource);

    SetLocalInt(oArea, "al_city_last_case_id", nCaseId);
    SetLocalInt(oArea, "al_city_last_case_kind", nKind);

    AL_CityRegistrySetActiveCrimeCase(oArea, nCaseId);
    return nCaseId;
}

void AL_CityCrimeOpenTheft(object oArea, object oSource)
{
    AL_CityCrimeOpenCase(oArea, oSource, AL_CITY_CRIME_THEFT, AL_CITY_CASE_STATUS_OPEN);
}


void AL_CityCrimeEscalateAlarm(object oArea, int nCaseId, object oSource)
{
    int nAlarmState = AL_CityAlarmGetState(oArea);
    if (nAlarmState == AL_CITY_ALARM_IDLE || nAlarmState == AL_CITY_ALARM_RECOVERY)
    {
        AL_CityAlarmRaisePending(oArea, nCaseId, oSource);
        return;
    }

    AL_CityAlarmApplyCityState(oArea, AL_CITY_ALARM_ACTIVE_ALARM);
}

void AL_CityCrimeOpenAssault(object oArea, object oSource)
{
    int nCaseId = AL_CityCrimeOpenCase(oArea, oSource, AL_CITY_CRIME_ASSAULT, AL_CITY_CASE_STATUS_OPEN);
    if (nCaseId <= 0)
    {
        return;
    }

    if (GetIsObjectValid(oSource) && GetObjectType(oSource) == OBJECT_TYPE_CREATURE)
    {
        AL_CityRegistryEnemyAdd(oArea, oSource);
    }
    AL_CityCrimeEscalateAlarm(oArea, nCaseId, oSource);
}

void AL_CityCrimeOpenDeathCase(object oArea, object oSource)
{
    if (AL_CityCrimeIsInteriorSingleNpcCase(oArea))
    {
        AL_CityCrimeOpenCase(oArea, oSource, AL_CITY_CRIME_HIDDEN_MURDER, AL_CITY_CASE_STATUS_LATENT);
        SetLocalInt(oArea, "al_city_hidden_case_pending", TRUE);
        return;
    }

    int nCaseId = AL_CityCrimeOpenCase(oArea, oSource, AL_CITY_CRIME_DISCOVERED_MURDER, AL_CITY_CASE_STATUS_OPEN);
    if (nCaseId <= 0)
    {
        return;
    }

    if (GetIsObjectValid(oSource) && GetObjectType(oSource) == OBJECT_TYPE_CREATURE)
    {
        AL_CityRegistryEnemyAdd(oArea, oSource);
    }
    AL_CityCrimeEscalateAlarm(oArea, nCaseId, oSource);
}

void AL_CityCrimeOnDisturbed(object oActor, object oSource, int nReactType, int nCrimeKind)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    object oArea = GetArea(oActor);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    if (nCrimeKind == 2)
    {
        AL_CityCrimeOpenTheft(oArea, oSource);
    }
}

void AL_CityCrimeOnPhysicalAttacked(object oNpc)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    object oSource = GetLastAttacker(oNpc);
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    AL_CityCrimeOpenAssault(oArea, oSource);
}

void AL_CityCrimeOnDamaged(object oNpc)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    object oSource = GetLastDamager(oNpc);
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    AL_CityCrimeOpenAssault(oArea, oSource);
}

void AL_CityCrimeOnSpellCastAt(object oNpc)
{
    if (!AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    object oSource = GetLastSpellCaster();
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    AL_CityCrimeOpenAssault(oArea, oSource);
}

void AL_CityCrimeOnDeath(object oNpc)
{
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    object oSource = GetLastKiller();
    AL_CityCrimeOpenDeathCase(oArea, oSource);

    if (GetLocalInt(oNpc, "al_city_enemy_active") == TRUE)
    {
        AL_CityRegistryEnemyRemove(oArea, oNpc);
        AL_CityAlarmTryClear(oArea);
    }
}
