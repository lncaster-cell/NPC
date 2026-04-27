const string DL_L_MODULE_CR_ENABLED = "dl_city_response_enabled";
const string DL_L_MODULE_CR_HEAT = "dl_cr_heat";
const string DL_L_MODULE_CR_LEVEL = "dl_cr_level";
const string DL_L_MODULE_CR_LAST_ABS_MIN = "dl_cr_last_abs_min";

const string DL_L_NPC_CR_LAST_INCIDENT_ABS_MIN = "dl_cr_last_incident_abs_min";
const string DL_L_AREA_CR_ENABLED = "dl_city_response_enabled";

const int DL_CR_HEAT_MIN = 0;
const int DL_CR_HEAT_MAX = 100;
const int DL_CR_EPISODE_COOLDOWN_MIN = 1; // one heat increment per attacker->victim combat episode
const int DL_CR_OFFENDER_TTL_MIN = 5;
const int DL_CR_DECAY_INTERVAL_MIN = 5;
const int DL_CR_DECAY_PER_STEP = 10;

const string DL_CR_KEY_PREFIX_EPISODE = "dl_cr_cd_";
const string DL_CR_KEY_PREFIX_GUARD_REACT = "dl_cr_guard_react_";
const string DL_CR_KEY_UNKNOWN_IDENTITY = "unknown";
const string DL_CR_DETAIN_DIALOG_DEFAULT = "dl_cr_guard_detain";

int DL_CR_IsEnabledForArea(object oArea)
{
    if (!DL_IsRuntimeEnabled())
    {
        return FALSE;
    }

    object oModule = GetModule();
    if (GetLocalInt(oModule, DL_L_MODULE_CR_ENABLED) != TRUE)
    {
        return FALSE;
    }

    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    return GetLocalInt(oArea, DL_L_AREA_CR_ENABLED) == TRUE;
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
    if (!GetIsObjectValid(oActor))
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
    if (!GetIsObjectValid(oOffender))
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
    string sDialogResRef = GetLocalString(GetModule(), DL_L_MODULE_CR_DETAIN_DIALOG);
    if (sDialogResRef == "")
    {
        return DL_CR_DETAIN_DIALOG_DEFAULT;
    }
    return sDialogResRef;
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
    int nCooldownUntil = GetLocalInt(oVictim, sCooldownKey);
    if (nCooldownUntil > nNowAbsMin)
    {
        return;
    }

    SetLocalInt(oVictim, sCooldownKey, nNowAbsMin + DL_CR_EPISODE_COOLDOWN_MIN);

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

    return GetLocalInt(oCreature, DL_L_NPC_CR_OFFENDER_UNTIL) > DL_GetAbsoluteMinute();
}

void DL_CR_HandleGuardPerception(object oGuard)
{
    if (!GetIsObjectValid(oGuard))
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
        if (GetLocalInt(oSeen, DL_L_PC_CR_DETAIN_PENDING) != TRUE)
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
    if (GetLocalInt(oGuard, sCooldownKey) > nNowAbsMin)
    {
        return;
    }
    SetLocalInt(oGuard, sCooldownKey, nNowAbsMin + 1);

    if (nLevel >= 3)
    {
        AssignCommand(oGuard, ClearAllActions(TRUE));
        AssignCommand(oGuard, ActionAttack(oSeen));
        return;
    }

    string sDialogResRef = DL_CR_GetDetainDialogResRef();
    AssignCommand(oGuard, ClearAllActions(TRUE));
    AssignCommand(oGuard, ActionMoveToObject(oSeen, TRUE, 2.0));
    AssignCommand(oGuard, ActionStartConversation(oSeen, sDialogResRef, TRUE, TRUE));
}
