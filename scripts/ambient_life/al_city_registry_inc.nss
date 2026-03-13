// Ambient Life city-level registry layer (Phase 1 foundation).
// Additive layer on top of area registries; no per-tick world scans.

const int AL_CITY_DISTRICT_INTERIOR = 1;
const int AL_CITY_DISTRICT_EXTERIOR = 2;

string AL_CityRegistryCityKey(string sCityId, string sSuffix)
{
    return "al_city_" + sCityId + "_" + sSuffix;
}

string AL_CityRegistryResolveCityId(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return "";
    }

    string sCityId = GetLocalString(oArea, "al_city_id");
    if (sCityId == "")
    {
        sCityId = "city_" + GetTag(oArea);
        SetLocalString(oArea, "al_city_id", sCityId);
    }

    return sCityId;
}

int AL_CityRegistryResolveDistrictType(object oArea)
{
    int nType = GetLocalInt(oArea, "al_city_district_type");
    if (nType == AL_CITY_DISTRICT_INTERIOR || nType == AL_CITY_DISTRICT_EXTERIOR)
    {
        return nType;
    }

    if (GetLocalInt(oArea, "al_is_interior") == TRUE)
    {
        nType = AL_CITY_DISTRICT_INTERIOR;
    }
    else
    {
        nType = AL_CITY_DISTRICT_EXTERIOR;
    }

    SetLocalInt(oArea, "al_city_district_type", nType);
    return nType;
}

void AL_CityRegistryEnsureDistrict(object oArea)
{
    if (!GetIsObjectValid(oArea) || GetObjectType(oArea) != OBJECT_TYPE_AREA)
    {
        return;
    }

    object oModule = GetModule();
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    if (GetLocalString(oArea, "al_city_reg_city_id") == sCityId)
    {
        return;
    }

    int nCount = GetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "district_count"));
    int i = 0;
    while (i < nCount)
    {
        object oExisting = GetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "district_" + IntToString(i)));
        if (oExisting == oArea)
        {
            SetLocalString(oArea, "al_city_reg_city_id", sCityId);
            return;
        }

        i = i + 1;
    }

    SetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "district_" + IntToString(nCount)), oArea);
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "district_count"), nCount + 1);

    SetLocalString(oArea, "al_city_reg_city_id", sCityId);
    SetLocalInt(oArea, "al_city_reg_district_idx", nCount);
    SetLocalInt(oArea, "al_city_district_type", AL_CityRegistryResolveDistrictType(oArea));
}

void AL_CityRegistrySetActiveCrimeCase(object oArea, int nCaseId)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "active_crime_case_id"), nCaseId);
    SetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "active_crime_case_area"), oArea);
}

void AL_CityRegistrySetActiveAlarmCase(object oArea, int nCaseId)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "active_alarm_case_id"), nCaseId);
    SetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "active_alarm_case_area"), oArea);
}

int AL_CityRegistryEnemyAdd(object oArea, object oEnemy)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oEnemy) || GetObjectType(oEnemy) != OBJECT_TYPE_CREATURE)
    {
        return FALSE;
    }

    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return FALSE;
    }

    object oModule = GetModule();
    int nCount = GetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"));
    int i = 0;
    while (i < nCount)
    {
        if (GetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(i))) == oEnemy)
        {
            return FALSE;
        }

        i = i + 1;
    }

    SetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(nCount)), oEnemy);
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"), nCount + 1);
    SetLocalInt(oEnemy, "al_city_enemy_active", TRUE);
    SetLocalString(oEnemy, "al_city_enemy_city_id", sCityId);
    return TRUE;
}

void AL_CityRegistryEnemyRemove(object oArea, object oEnemy)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oEnemy))
    {
        return;
    }

    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    int nCount = GetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"));
    int i = 0;
    while (i < nCount)
    {
        string sKey = AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(i));
        if (GetLocalObject(oModule, sKey) == oEnemy)
        {
            int nLast = nCount - 1;
            if (i != nLast)
            {
                SetLocalObject(oModule, sKey, GetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(nLast))));
            }

            DeleteLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(nLast)));
            SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"), nLast);
            break;
        }

        i = i + 1;
    }

    DeleteLocalInt(oEnemy, "al_city_enemy_active");
    DeleteLocalString(oEnemy, "al_city_enemy_city_id");
}

int AL_CityRegistryEnemyCount(object oArea)
{
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return 0;
    }

    return GetLocalInt(GetModule(), AL_CityRegistryCityKey(sCityId, "enemy_count"));
}
