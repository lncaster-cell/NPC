const string DL_L_MODULE_CR_ENABLED = "dl_city_response_enabled";
const string DL_L_MODULE_CR_HEAT = "dl_cr_heat";
const string DL_L_MODULE_CR_LEVEL = "dl_cr_level";
const string DL_L_MODULE_CR_LAST_ABS_MIN = "dl_cr_last_abs_min";

const string DL_L_NPC_CR_LAST_INCIDENT_ABS_MIN = "dl_cr_last_incident_abs_min";
const string DL_L_AREA_CR_ENABLED = "dl_city_response_enabled";

const int DL_CR_HEAT_MIN = 0;
const int DL_CR_HEAT_MAX = 100;
const int DL_CR_EPISODE_COOLDOWN_MIN = 1; // one heat increment per attacker->victim combat episode
const int DL_CR_GUARD_REACTION_COOLDOWN_MIN = 1; // minimum delay between repeated guard reaction attempts per offender
const int DL_CR_OFFENDER_TTL_MIN = 5;
const int DL_CR_DECAY_INTERVAL_MIN = 5;
const int DL_CR_DECAY_PER_STEP = 10;

const string DL_CR_KEY_PREFIX_EPISODE = "dl_cr_cd_";
const string DL_CR_KEY_PREFIX_GUARD_REACT = "dl_cr_guard_react_";
const string DL_CR_KEY_UNKNOWN_IDENTITY = "unknown";

int DL_CR_IsDetainPending(object oPc);

int DL_CR_IsEnabledForArea(object oArea)
{
    return DL_CanRunCityResponseForArea(oArea);
}

int DL_CR_GetLevelByHeat(int nHeat)
{
    if (nHeat >= 75)
    {
        return 3;
    }
    if (nHeat >= 50)
    {
        return 2;
    }
    if (nHeat >= 25)
    {
        return 1;
    }
    return 0;
}

void DL_CR_SyncHeatLevel(object oModule, int nHeat)
{
    nHeat = DL_ClampInt(nHeat, DL_CR_HEAT_MIN, DL_CR_HEAT_MAX);
    SetLocalInt(oModule, DL_L_MODULE_CR_HEAT, nHeat);
    SetLocalInt(oModule, DL_L_MODULE_CR_LEVEL, DL_CR_GetLevelByHeat(nHeat));
}

void DL_CR_ApplyLazyDecay()
{
    object oModule = GetModule();
    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nLastAbsMin = GetLocalInt(oModule, DL_L_MODULE_CR_LAST_ABS_MIN);

    if (nLastAbsMin <= 0 || nNowAbsMin <= nLastAbsMin)
    {
        SetLocalInt(oModule, DL_L_MODULE_CR_LAST_ABS_MIN, nNowAbsMin);
        return;
    }

    int nElapsed = nNowAbsMin - nLastAbsMin;
    int nSteps = nElapsed / DL_CR_DECAY_INTERVAL_MIN;
    if (nSteps <= 0)
    {
        return;
    }

    int nHeat = GetLocalInt(oModule, DL_L_MODULE_CR_HEAT);
    nHeat = nHeat - (nSteps * DL_CR_DECAY_PER_STEP);
    DL_CR_SyncHeatLevel(oModule, nHeat);
    SetLocalInt(oModule, DL_L_MODULE_CR_LAST_ABS_MIN, nLastAbsMin + (nSteps * DL_CR_DECAY_INTERVAL_MIN));
}

object DL_CR_ResolveResponsibleActor(object oActor)
{
    if (!DL_IsValidNpcObject(oActor))
    {
        return OBJECT_INVALID;
    }

    if (DL_IsRuntimePlayer(oActor))
    {
        return oActor;
    }

    object oMaster = GetMaster(oActor);
    if (DL_IsRuntimePlayer(oMaster))
    {
        return oMaster;
    }

    return OBJECT_INVALID;
}

string DL_CR_GetOffenderIdentityKey(object oOffender)
{
    if (!DL_IsValidNpcObject(oOffender))
    {
        return DL_CR_KEY_UNKNOWN_IDENTITY;
    }

    if (DL_IsRuntimePlayer(oOffender))
    {
        string sPublicCdKey = GetPCPublicCDKey(oOffender);
        if (sPublicCdKey != "")
        {
            return sPublicCdKey;
        }
    }

    string sIdentity = ObjectToString(oOffender);
    if (sIdentity == "")
    {
        sIdentity = GetTag(oOffender);
    }
    if (sIdentity == "")
    {
        sIdentity = DL_CR_KEY_UNKNOWN_IDENTITY;
    }

    return GetStringLowerCase(sIdentity);
}

string DL_CR_GetEpisodeCooldownKey(object oOffender)
{
    return DL_CR_KEY_PREFIX_EPISODE + DL_CR_GetOffenderIdentityKey(oOffender);
}

string DL_CR_GetGuardReactionCooldownKey(object oOffender)
{
    return DL_CR_KEY_PREFIX_GUARD_REACT + DL_CR_GetOffenderIdentityKey(oOffender);
}

string DL_CR_GetDetainDialogResRef()
{
    return DL_GetConfigString(DL_L_MODULE_CR_DETAIN_DIALOG, DL_CFG_CR_DETAIN_DIALOG_DEFAULT);
}


int DL_CR_StartDetainInteraction(object oGuard, object oOffender, string sDialogResRef, int bForceApproach)
{
    if (!DL_IsValidNpcObject(oGuard) || !DL_IsValidNpcObject(oOffender))
    {
        return FALSE;
    }

    if (!DL_IsActivePipelineNpc(oGuard) || !DL_IsRuntimePlayer(oOffender))
    {
        return FALSE;
    }

    if (GetIsInConversation(oGuard) || GetIsInConversation(oOffender) ||
        GetIsInCombat(oGuard) || GetIsInCombat(oOffender))
    {
        return FALSE;
    }

    if (sDialogResRef == "")
    {
        sDialogResRef = DL_CR_GetDetainDialogResRef();
    }

    if (bForceApproach)
    {
        DL_OrchestrateRuntimeAction(
            oGuard,
            DL_ORCH_ACT_MOVE_OBJECT,
            oOffender,
            LOCATION_INVALID,
            "",
            TRUE,
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "",
            "dl_cr_action",
            "guard_approach_offender",
            DL_GetAbsoluteMinute(),
            TRUE,
            2.0
        );
        DL_OrchestrateRuntimeAction(oGuard, DL_ORCH_ACT_START_CONVERSATION, oOffender, LOCATION_INVALID, sDialogResRef, FALSE);
    }
    else
    {
        DL_OrchestrateRuntimeAction(oGuard, DL_ORCH_ACT_START_CONVERSATION, oOffender, LOCATION_INVALID, sDialogResRef, TRUE);
    }
    return TRUE;
}

int DL_CR_IsGuardVictim(object oVictim)
{
    return GetLocalString(oVictim, DL_L_NPC_PROFILE_ID) == DL_PROFILE_GATE_POST;
}

void DL_CR_RegisterIncident(object oOffender, int nHeatDelta)
{
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    object oModule = GetModule();
    DL_CR_ApplyLazyDecay();

    int nNowAbsMin = DL_GetAbsoluteMinute();
    int nHeat = GetLocalInt(oModule, DL_L_MODULE_CR_HEAT) + nHeatDelta;
    DL_CR_SyncHeatLevel(oModule, nHeat);
    SetLocalInt(oModule, DL_L_MODULE_CR_LAST_ABS_MIN, nNowAbsMin);

    SetLocalInt(oOffender, DL_L_NPC_CR_LAST_INCIDENT_ABS_MIN, nNowAbsMin);
    SetLocalInt(oOffender, DL_L_NPC_CR_OFFENDER_UNTIL, nNowAbsMin + DL_CR_OFFENDER_TTL_MIN);
}

void DL_CR_HandleNpcDamaged(object oVictim)
{
    if (!DL_IsActivePipelineNpc(oVictim))
    {
        return;
    }

    object oArea = GetArea(oVictim);
    if (!DL_CR_IsEnabledForArea(oArea))
    {
        return;
    }

    object oDamager = GetLastDamager(oVictim);
    object oOffender = DL_CR_ResolveResponsibleActor(oDamager);
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    string sCooldownKey = DL_CR_GetEpisodeCooldownKey(oOffender);
    int nNowAbsMin = DL_GetAbsoluteMinute();
    if (DL_IsMinuteCooldownActive(oVictim, sCooldownKey))
    {
        return;
    }

    DL_SetMinuteCooldown(oVictim, sCooldownKey, DL_CR_EPISODE_COOLDOWN_MIN);

    int nHeatDelta = DL_CR_IsGuardVictim(oVictim) ? 25 : 15;
    DL_CR_RegisterIncident(oOffender, nHeatDelta);
}

void DL_CR_HandleNpcKilled(object oVictim)
{
    if (!DL_IsPipelineNpc(oVictim))
    {
        return;
    }

    object oArea = GetArea(oVictim);
    if (!DL_CR_IsEnabledForArea(oArea))
    {
        return;
    }

    object oKiller = GetLastKiller();
    object oOffender = DL_CR_ResolveResponsibleActor(oKiller);
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    int nHeatDelta = DL_CR_IsGuardVictim(oVictim) ? 40 : 25;
    DL_CR_RegisterIncident(oOffender, nHeatDelta);
}

int DL_CR_IsOffenderActive(object oCreature)
{
    if (!DL_IsRuntimePlayer(oCreature))
    {
        return FALSE;
    }

    return DL_IsMinuteCooldownActive(oCreature, DL_L_NPC_CR_OFFENDER_UNTIL);
}

void DL_CR_HandleGuardPerception(object oGuard)
{
    if (!DL_IsValidNpcObject(oGuard))
    {
        return;
    }

    if (!DL_IsActivePipelineNpc(oGuard) || !DL_CR_IsGuardVictim(oGuard))
    {
        return;
    }

    object oSeen = GetLastPerceived();
    if (!DL_IsRuntimePlayer(oSeen))
    {
        return;
    }

    if (!GetLastPerceptionSeen() && !GetLastPerceptionHeard())
    {
        return;
    }

    object oArea = GetArea(oGuard);
    if (!DL_CR_IsEnabledForArea(oArea) || !DL_CR_IsOffenderActive(oSeen))
    {
        return;
    }

    int nLevel = GetLocalInt(GetModule(), DL_L_MODULE_CR_LEVEL);
    if (nLevel <= 0)
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    if (nLevel < 3)
    {
        if (!DL_CR_IsDetainPending(oSeen))
        {
            return;
        }

        if (GetLocalObject(oGuard, DL_L_NPC_CR_INVESTIGATE_TARGET) != oSeen ||
            GetLocalInt(oGuard, DL_L_NPC_CR_INVESTIGATE_UNTIL) < nNowAbsMin)
        {
            return;
        }
    }

    string sCooldownKey = DL_CR_GetGuardReactionCooldownKey(oSeen);
    if (DL_IsMinuteCooldownActive(oGuard, sCooldownKey))
    {
        return;
    }
    DL_SetMinuteCooldown(oGuard, sCooldownKey, DL_CR_GUARD_REACTION_COOLDOWN_MIN);

    if (nLevel >= 3)
    {
        DL_OrchestrateRuntimeAction(oGuard, DL_ORCH_ACT_ATTACK, oSeen, LOCATION_INVALID, "", TRUE, "", "", "", "", "", "", "", "", "dl_cr_action", "guard_attack_seen", DL_GetAbsoluteMinute());
        return;
    }

    DL_CR_StartDetainInteraction(oGuard, oSeen, "", TRUE);
}
