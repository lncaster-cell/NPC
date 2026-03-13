// Ambient Life city population respawn layer.
// Respawn replenishes unnamed deficit from city-owned spawn nodes.

#include "al_city_registry_inc"

const int AL_CITY_RESPAWN_BUDGET_MAX_DEFAULT = 3;
const int AL_CITY_RESPAWN_BUDGET_REGEN_TICKS_DEFAULT = 4;
const int AL_CITY_RESPAWN_COOLDOWN_TICKS_DEFAULT = 2;
const float AL_CITY_RESPAWN_SAFE_DIST_DEFAULT = 20.0;

int AL_CityPopulationIsNamedNpc(object oNpc)
{
    if (GetLocalInt(oNpc, "al_population_named") == TRUE)
    {
        return TRUE;
    }

    if (GetLocalInt(oNpc, "al_is_named") == TRUE)
    {
        return TRUE;
    }

    return FALSE;
}

void AL_CityPopulationEnsureSpawnClassification(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE)
    {
        return;
    }

    if (GetLocalInt(oNpc, "al_population_classified") == TRUE)
    {
        return;
    }

    int nNamed = AL_CityPopulationIsNamedNpc(oNpc);
    SetLocalInt(oNpc, "al_population_is_named", nNamed);
    SetLocalInt(oNpc, "al_population_classified", TRUE);
}

void AL_CityPopulationEnsureBudget(string sCityId)
{
    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    string sBudgetMaxKey = AL_CityRegistryCityKey(sCityId, "population_respawn_budget_max");
    string sBudgetKey = AL_CityRegistryCityKey(sCityId, "population_respawn_budget");

    int nBudgetMax = GetLocalInt(oModule, sBudgetMaxKey);
    if (nBudgetMax <= 0)
    {
        nBudgetMax = AL_CITY_RESPAWN_BUDGET_MAX_DEFAULT;
        SetLocalInt(oModule, sBudgetMaxKey, nBudgetMax);
    }

    int nBudget = GetLocalInt(oModule, sBudgetKey);
    if (nBudget <= 0)
    {
        SetLocalInt(oModule, sBudgetKey, nBudgetMax);
    }
}

void AL_CityPopulationOnNpcSpawn(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || !AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, "al_population_alive_registered") == TRUE)
    {
        return;
    }

    object oArea = GetArea(oNpc);
    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    AL_CityPopulationEnsureSpawnClassification(oNpc);

    object oModule = GetModule();
    int nNamed = GetLocalInt(oNpc, "al_population_is_named") == TRUE;

    if (nNamed)
    {
        string sAliveNamedKey = AL_CityRegistryCityKey(sCityId, "population_alive_named");
        string sTargetNamedKey = AL_CityRegistryCityKey(sCityId, "population_target_named");
        int nAliveNamed = GetLocalInt(oModule, sAliveNamedKey) + 1;
        SetLocalInt(oModule, sAliveNamedKey, nAliveNamed);
        if (nAliveNamed > GetLocalInt(oModule, sTargetNamedKey))
        {
            SetLocalInt(oModule, sTargetNamedKey, nAliveNamed);
        }
    }
    else
    {
        string sAliveUnnamedKey = AL_CityRegistryCityKey(sCityId, "population_alive_unnamed");
        string sTargetUnnamedKey = AL_CityRegistryCityKey(sCityId, "population_target_unnamed");
        int nAliveUnnamed = GetLocalInt(oModule, sAliveUnnamedKey) + 1;
        SetLocalInt(oModule, sAliveUnnamedKey, nAliveUnnamed);
        if (nAliveUnnamed > GetLocalInt(oModule, sTargetUnnamedKey))
        {
            SetLocalInt(oModule, sTargetUnnamedKey, nAliveUnnamed);
        }
    }

    SetLocalString(oNpc, "al_population_city_id", sCityId);
    SetLocalInt(oNpc, "al_population_alive_registered", TRUE);

    AL_CityPopulationEnsureBudget(sCityId);
}

void AL_CityPopulationOnNpcDeath(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || !AL_IsRuntimeNpc(oNpc))
    {
        return;
    }

    if (GetLocalInt(oNpc, "al_population_alive_registered") != TRUE)
    {
        return;
    }

    string sCityId = GetLocalString(oNpc, "al_population_city_id");
    if (sCityId == "")
    {
        sCityId = AL_CityRegistryResolveCityId(GetArea(oNpc));
    }

    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    int nNamed = GetLocalInt(oNpc, "al_population_is_named") == TRUE;
    if (nNamed)
    {
        string sAliveNamedKey = AL_CityRegistryCityKey(sCityId, "population_alive_named");
        int nAliveNamed = GetLocalInt(oModule, sAliveNamedKey) - 1;
        if (nAliveNamed < 0)
        {
            nAliveNamed = 0;
        }

        SetLocalInt(oModule, sAliveNamedKey, nAliveNamed);
    }
    else
    {
        string sAliveUnnamedKey = AL_CityRegistryCityKey(sCityId, "population_alive_unnamed");
        string sDeficitKey = AL_CityRegistryCityKey(sCityId, "population_deficit_unnamed");

        int nAliveUnnamed = GetLocalInt(oModule, sAliveUnnamedKey) - 1;
        if (nAliveUnnamed < 0)
        {
            nAliveUnnamed = 0;
        }

        SetLocalInt(oModule, sAliveUnnamedKey, nAliveUnnamed);
        SetLocalInt(oModule, sDeficitKey, GetLocalInt(oModule, sDeficitKey) + 1);
    }

    DeleteLocalInt(oNpc, "al_population_alive_registered");
}

int AL_CityPopulationNodeIsSafe(object oArea, object oNode)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNode))
    {
        return FALSE;
    }

    if (AL_CityRegistryEnemyCount(oArea) > 0)
    {
        return FALSE;
    }

    float fSafeDist = IntToFloat(GetLocalInt(oArea, "al_city_respawn_safe_dist"));
    if (fSafeDist <= 0.0)
    {
        fSafeDist = AL_CITY_RESPAWN_SAFE_DIST_DEFAULT;
    }

    location lNode = GetLocation(oNode);
    object oPc = GetFirstPC();
    while (GetIsObjectValid(oPc))
    {
        if (GetArea(oPc) == oArea)
        {
            if (GetDistanceBetweenLocations(GetLocation(oPc), lNode) < fSafeDist)
            {
                return FALSE;
            }
        }

        oPc = GetNextPC();
    }

    return TRUE;
}

object AL_CityPopulationResolveRespawnNode(object oArea)
{
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    int nCount = GetLocalInt(oArea, "al_city_respawn_node_count");
    if (nCount <= 0)
    {
        nCount = 1;
        if (GetLocalString(oArea, "al_city_respawn_tag") == "")
        {
            return OBJECT_INVALID;
        }
    }

    int i = 0;
    while (i < nCount)
    {
        string sTag = GetLocalString(oArea, "al_city_respawn_tag_" + IntToString(i));
        if (sTag == "" && i == 0)
        {
            sTag = GetLocalString(oArea, "al_city_respawn_tag");
        }

        if (sTag != "")
        {
            object oNode = GetObjectByTag(sTag, 0);
            if (GetIsObjectValid(oNode) && GetArea(oNode) == oArea && AL_CityPopulationNodeIsSafe(oArea, oNode))
            {
                return oNode;
            }
        }

        i = i + 1;
    }

    return OBJECT_INVALID;
}

void AL_CityPopulationTryRespawnTick(object oArea)
{
    if (!GetIsObjectValid(oArea) || AL_IsHotArea(oArea) != TRUE)
    {
        return;
    }

    string sCityId = AL_CityRegistryResolveCityId(oArea);
    if (sCityId == "")
    {
        return;
    }

    object oModule = GetModule();
    AL_CityPopulationEnsureBudget(sCityId);

    string sDeficitKey = AL_CityRegistryCityKey(sCityId, "population_deficit_unnamed");
    int nDeficit = GetLocalInt(oModule, sDeficitKey);
    if (nDeficit <= 0)
    {
        return;
    }

    int nSyncTick = GetLocalInt(oArea, "al_sync_tick");
    string sLastRespawnTickKey = AL_CityRegistryCityKey(sCityId, "population_last_respawn_tick");
    int nCooldownTicks = GetLocalInt(oArea, "al_city_respawn_cooldown_ticks");
    if (nCooldownTicks <= 0)
    {
        nCooldownTicks = AL_CITY_RESPAWN_COOLDOWN_TICKS_DEFAULT;
    }

    int nLastRespawnTick = GetLocalInt(oModule, sLastRespawnTickKey);
    if (nLastRespawnTick > 0 && (nSyncTick - nLastRespawnTick) < nCooldownTicks)
    {
        return;
    }

    string sBudgetMaxKey = AL_CityRegistryCityKey(sCityId, "population_respawn_budget_max");
    string sBudgetKey = AL_CityRegistryCityKey(sCityId, "population_respawn_budget");
    int nBudgetMax = GetLocalInt(oModule, sBudgetMaxKey);
    int nBudget = GetLocalInt(oModule, sBudgetKey);

    int nRegenTicks = GetLocalInt(oArea, "al_city_respawn_budget_regen_ticks");
    if (nRegenTicks <= 0)
    {
        nRegenTicks = AL_CITY_RESPAWN_BUDGET_REGEN_TICKS_DEFAULT;
    }

    string sLastRegenTickKey = AL_CityRegistryCityKey(sCityId, "population_budget_last_regen_tick");
    int nLastRegenTick = GetLocalInt(oModule, sLastRegenTickKey);
    if (nSyncTick > 0 && (nLastRegenTick <= 0 || (nSyncTick - nLastRegenTick) >= nRegenTicks))
    {
        if (nBudget < nBudgetMax)
        {
            nBudget = nBudget + 1;
            if (nBudget > nBudgetMax)
            {
                nBudget = nBudgetMax;
            }

            SetLocalInt(oModule, sBudgetKey, nBudget);
        }

        SetLocalInt(oModule, sLastRegenTickKey, nSyncTick);
    }

    if (nBudget <= 0)
    {
        return;
    }

    object oNode = AL_CityPopulationResolveRespawnNode(oArea);
    if (!GetIsObjectValid(oNode))
    {
        return;
    }

    string sResRef = GetLocalString(oArea, "al_city_respawn_resref");
    if (sResRef == "")
    {
        sResRef = GetLocalString(oModule, AL_CityRegistryCityKey(sCityId, "population_respawn_resref"));
    }

    if (sResRef == "")
    {
        return;
    }

    object oSpawned = CreateObject(OBJECT_TYPE_CREATURE, sResRef, GetLocation(oNode), FALSE, "");
    if (!GetIsObjectValid(oSpawned))
    {
        return;
    }

    SetLocalInt(oModule, sBudgetKey, nBudget - 1);
    SetLocalInt(oModule, sDeficitKey, nDeficit - 1);
    SetLocalInt(oModule, sLastRespawnTickKey, nSyncTick);
    SetLocalInt(oSpawned, "al_population_named", FALSE);
}
