// Ambient Life city-level registry layer (Phase 1 foundation).
// Additive layer on top of area registries; no per-tick world scans.

const int AL_CITY_DISTRICT_INTERIOR = 1;
const int AL_CITY_DISTRICT_EXTERIOR = 2;
const int AL_CITY_ENEMY_INACTIVE_TICK_WINDOW = 24;

void AL_CityRegistryEnemyClearState(object oEnemy)
{
    if (!GetIsObjectValid(oEnemy))
    {
        return;
    }

    DeleteLocalInt(oEnemy, "al_city_enemy_active");
    DeleteLocalString(oEnemy, "al_city_enemy_city_id");
    DeleteLocalInt(oEnemy, "al_city_enemy_last_active_tick");
}

int AL_CityRegistryEnemyCurrentTick(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    return GetLocalInt(oArea, "al_sync_tick");
}

void AL_CityRegistryEnemyTouch(object oEnemy, string sCityId, int nTick)
{
    if (!GetIsObjectValid(oEnemy))
    {
        return;
    }

    SetLocalInt(oEnemy, "al_city_enemy_active", TRUE);
    SetLocalString(oEnemy, "al_city_enemy_city_id", sCityId);
    SetLocalInt(oEnemy, "al_city_enemy_last_active_tick", nTick);
}

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
    int nTick = AL_CityRegistryEnemyCurrentTick(oArea);
    int i = 0;
    while (i < nCount)
    {
        if (GetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(i))) == oEnemy)
        {
            AL_CityRegistryEnemyTouch(oEnemy, sCityId, nTick);
            return FALSE;
        }

        i = i + 1;
    }

    SetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(nCount)), oEnemy);
    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"), nCount + 1);
    AL_CityRegistryEnemyTouch(oEnemy, sCityId, nTick);
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

    AL_CityRegistryEnemyClearState(oEnemy);
}

int AL_CityRegistryPruneEnemies(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return 0;
    }

    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return 0;
    }

    object oModule = GetModule();
    int nCount = GetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"));
    int nNowTick = AL_CityRegistryEnemyCurrentTick(oArea);
    int nRemoved = 0;
    int i = 0;

    while (i < nCount)
    {
        string sEnemyKey = AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(i));
        object oEnemy = GetLocalObject(oModule, sEnemyKey);
        int bRemove = FALSE;

        if (!GetIsObjectValid(oEnemy) || GetObjectType(oEnemy) != OBJECT_TYPE_CREATURE)
        {
            bRemove = TRUE;
        }
        else
        {
            object oEnemyArea = GetArea(oEnemy);
            if (!GetIsObjectValid(oEnemyArea) || AL_CityRegistryResolveCityId(oEnemyArea) != sCityId)
            {
                bRemove = TRUE;
            }
            else if (nNowTick > 0)
            {
                int nLastActive = GetLocalInt(oEnemy, "al_city_enemy_last_active_tick");
                if (nLastActive <= 0)
                {
                    nLastActive = nNowTick;
                    SetLocalInt(oEnemy, "al_city_enemy_last_active_tick", nNowTick);
                }

                if ((nNowTick - nLastActive) > AL_CITY_ENEMY_INACTIVE_TICK_WINDOW)
                {
                    bRemove = TRUE;
                }
            }
        }

        if (!bRemove)
        {
            i = i + 1;
            continue;
        }

        int nLast = nCount - 1;
        if (i != nLast)
        {
            SetLocalObject(oModule, sEnemyKey, GetLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(nLast))));
        }

        DeleteLocalObject(oModule, AL_CityRegistryCityKey(sCityId, "enemy_" + IntToString(nLast)));
        nCount = nLast;
        nRemoved = nRemoved + 1;

        AL_CityRegistryEnemyClearState(oEnemy);
    }

    SetLocalInt(oModule, AL_CityRegistryCityKey(sCityId, "enemy_count"), nCount);
    return nRemoved;
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
