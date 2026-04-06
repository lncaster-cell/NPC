#ifndef DL_NPC_HOOKS_INC_NSS
#define DL_NPC_HOOKS_INC_NSS

#include "dl_const_inc"
#include "dl_log_inc"
#include "dl_types_inc"
#include "dl_area_inc"
#include "dl_resync_inc"
#include "dl_slot_handoff_inc"

const int DL_UD_BOOTSTRAP = 12001;
const int DL_UD_RESYNC = 12002;
const int DL_UD_FORCE_RESYNC = 12003;
const int DL_UD_CLEANUP = 12004;
const int DL_UD_PERCEPTION = 12005;
const int DL_UD_PHYSICAL_ATTACKED = 12006;
const int DL_UD_DISTURBED = 12007;

const string DL_L_UD_LAST_PERCEPTION_TICK = "dl_ud_last_perception_tick";
const string DL_L_UD_LAST_ATTACK_TICK = "dl_ud_last_attack_tick";
const string DL_L_UD_LAST_DISTURBED_TICK = "dl_ud_last_disturbed_tick";

const int DL_UD_PERCEPTION_COOLDOWN_SEC = 3;
const int DL_UD_ATTACK_COOLDOWN_SEC = 1;
const int DL_UD_DISTURBED_COOLDOWN_SEC = 2;

int DL_GetHookClockSeconds()
{
    return (GetTimeHour() * 3600) + (GetTimeMinute() * 60) + GetTimeSecond();
}

int DL_HasHookCooldownElapsed(object oNPC, string sKey, int nCooldownSec)
{
    int nNow = DL_GetHookClockSeconds();
    int nLast = GetLocalInt(oNPC, sKey);
    int nElapsed = nNow - nLast;

    if (nLast <= 0)
    {
        return TRUE;
    }
    if (nElapsed < 0)
    {
        nElapsed += 86400;
    }
    return nElapsed >= nCooldownSec;
}

void DL_MarkHookCooldown(object oNPC, string sKey)
{
    SetLocalInt(oNPC, sKey, DL_GetHookClockSeconds());
}

int DL_IsNpcHookCandidate(object oNPC)
{
    if (!GetIsObjectValid(oNPC))
    {
        return FALSE;
    }
    if (GetObjectType(oNPC) != OBJECT_TYPE_CREATURE)
    {
        return FALSE;
    }
    if (GetIsPC(oNPC))
    {
        return FALSE;
    }
    return DL_IsDailyLifeNpc(oNPC);
}

void DL_SignalNpcUserDefined(object oNPC, int nEvent)
{
    if (!GetIsObjectValid(oNPC))
    {
        return;
    }
    SignalEvent(oNPC, EventUserDefined(nEvent));
}

void DL_RequestNpcHookResync(object oNPC, int nReason, int bForceNow)
{
    object oArea;

    if (!DL_IsNpcHookCandidate(oNPC))
    {
        return;
    }

    oArea = GetArea(oNPC);
    if (bForceNow && GetIsObjectValid(oArea) && DL_ShouldRunDailyLife(oArea))
    {
        DL_RunForcedResync(oNPC, oArea, nReason);
        return;
    }

    DL_RequestResync(oNPC, nReason);
}

void DL_OnNpcSpawnHook(object oNPC)
{
    if (!DL_IsNpcHookCandidate(oNPC))
    {
        return;
    }

    DL_RequestNpcHookResync(oNPC, DL_RESYNC_WORKER, FALSE);
    DL_LogNpc(oNPC, DL_DEBUG_VERBOSE, "npc spawn hook -> worker resync requested");
}

void DL_OnNpcDeathHook(object oNPC)
{
    string sFunctionSlotId;

    if (!GetIsObjectValid(oNPC))
    {
        return;
    }

    sFunctionSlotId = DL_GetFunctionSlotId(oNPC);
    if (sFunctionSlotId != "")
    {
        DL_RecordBaseLostEvent(oNPC, sFunctionSlotId, DL_DIR_ABSENT);
        DL_RequestFunctionSlotReview(sFunctionSlotId, DL_RESYNC_BASE_LOST);
    }

    DeleteLocalInt(oNPC, DL_L_RESYNC_PENDING);
    DeleteLocalInt(oNPC, DL_L_RESYNC_REASON);
    DeleteLocalInt(oNPC, DL_L_ACTIVITY_KIND);
    DeleteLocalInt(oNPC, DL_L_DIALOGUE_MODE);
    DeleteLocalInt(oNPC, DL_L_SERVICE_MODE);
    DeleteLocalInt(oNPC, DL_L_ANCHOR_GROUP);
    DeleteLocalInt(oNPC, DL_L_UD_LAST_PERCEPTION_TICK);
    DeleteLocalInt(oNPC, DL_L_UD_LAST_ATTACK_TICK);
    DeleteLocalInt(oNPC, DL_L_UD_LAST_DISTURBED_TICK);

    DL_LogNpc(oNPC, DL_DEBUG_BASIC, "npc death hook -> runtime cleanup complete");
}

void DL_OnNpcUserDefinedHook(object oNPC, int nEvent)
{
    object oArea;

    if (!DL_IsNpcHookCandidate(oNPC) && nEvent != DL_UD_CLEANUP)
    {
        return;
    }

    if (nEvent == DL_UD_BOOTSTRAP)
    {
        DL_OnNpcSpawnHook(oNPC);
        return;
    }

    if (nEvent == DL_UD_RESYNC)
    {
        DL_RequestNpcHookResync(oNPC, DL_RESYNC_WORKER, FALSE);
        return;
    }

    if (nEvent == DL_UD_FORCE_RESYNC)
    {
        DL_RequestNpcHookResync(oNPC, DL_RESYNC_WORKER, TRUE);
        return;
    }

    if (nEvent == DL_UD_CLEANUP)
    {
        DL_OnNpcDeathHook(oNPC);
        return;
    }

    if (nEvent == DL_UD_PERCEPTION
        || nEvent == DL_UD_PHYSICAL_ATTACKED
        || nEvent == DL_UD_DISTURBED)
    {
        oArea = GetArea(oNPC);
        if (GetIsObjectValid(oArea) && DL_ShouldRunDailyLife(oArea))
        {
            DL_RequestNpcHookResync(oNPC, DL_RESYNC_WORKER, TRUE);
        }
        else
        {
            DL_RequestNpcHookResync(oNPC, DL_RESYNC_WORKER, FALSE);
        }
        return;
    }
}

int DL_ShouldEmitPerceptionEvent(object oNPC, object oSeen)
{
    if (!DL_IsNpcHookCandidate(oNPC))
    {
        return FALSE;
    }
    if (!GetIsObjectValid(oSeen))
    {
        return FALSE;
    }
    if (!GetIsPC(oSeen) || GetIsDM(oSeen))
    {
        return FALSE;
    }
    if (!DL_HasHookCooldownElapsed(oNPC, DL_L_UD_LAST_PERCEPTION_TICK, DL_UD_PERCEPTION_COOLDOWN_SEC))
    {
        return FALSE;
    }

    DL_MarkHookCooldown(oNPC, DL_L_UD_LAST_PERCEPTION_TICK);
    return TRUE;
}

int DL_ShouldEmitAttackEvent(object oNPC)
{
    if (!DL_IsNpcHookCandidate(oNPC))
    {
        return FALSE;
    }
    if (!DL_HasHookCooldownElapsed(oNPC, DL_L_UD_LAST_ATTACK_TICK, DL_UD_ATTACK_COOLDOWN_SEC))
    {
        return FALSE;
    }

    DL_MarkHookCooldown(oNPC, DL_L_UD_LAST_ATTACK_TICK);
    return TRUE;
}

int DL_ShouldEmitDisturbedEvent(object oNPC)
{
    if (!DL_IsNpcHookCandidate(oNPC))
    {
        return FALSE;
    }
    if (!DL_HasHookCooldownElapsed(oNPC, DL_L_UD_LAST_DISTURBED_TICK, DL_UD_DISTURBED_COOLDOWN_SEC))
    {
        return FALSE;
    }

    DL_MarkHookCooldown(oNPC, DL_L_UD_LAST_DISTURBED_TICK);
    return TRUE;
}

#endif
