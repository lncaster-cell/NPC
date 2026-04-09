#ifndef DL_V2_REGISTRY_INC_NSS
#define DL_V2_REGISTRY_INC_NSS

#include "dl_v2_area_inc"

const string DL2_L_NPC_REGISTERED = "dl2_registered";
const string DL2_L_NPC_REGISTRATION_VERSION = "dl2_registration_version";
const string DL2_REGISTRATION_VERSION_A0 = "v2.reg.a0";

int DL2_IsRuntimeNpcCandidate(object oNPC)
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

    return TRUE;
}

int DL2_IsNpcRegistered(object oNPC)
{
    if (!DL2_IsRuntimeNpcCandidate(oNPC))
    {
        return FALSE;
    }

    return GetLocalInt(oNPC, DL2_L_NPC_REGISTERED) == TRUE
        && GetLocalString(oNPC, DL2_L_NPC_REGISTRATION_VERSION) == DL2_REGISTRATION_VERSION_A0;
}

void DL2_RegisterNpc(object oNPC)
{
    if (!DL2_IsRuntimeNpcCandidate(oNPC))
    {
        return;
    }

    if (!DL2_IsValidNpcState(GetLocalInt(oNPC, DL2_L_NPC_STATE)))
    {
        SetLocalInt(oNPC, DL2_L_NPC_STATE, DL2_STATE_IDLE);
    }

    if (GetLocalString(oNPC, DL2_L_NPC_PROFILE_ID) == "")
    {
        SetLocalString(oNPC, DL2_L_NPC_PROFILE_ID, "unassigned");
    }

    SetLocalInt(oNPC, DL2_L_NPC_REGISTERED, TRUE);
    SetLocalString(oNPC, DL2_L_NPC_REGISTRATION_VERSION, DL2_REGISTRATION_VERSION_A0);

    DL2_LogInfo(
        "REGISTRY",
        "npc_registered profile=" + GetLocalString(oNPC, DL2_L_NPC_PROFILE_ID)
            + " state=" + IntToString(GetLocalInt(oNPC, DL2_L_NPC_STATE))
    );
}

void DL2_EnsureNpcRegistered(object oNPC)
{
    if (DL2_IsNpcRegistered(oNPC))
    {
        return;
    }

    DL2_RegisterNpc(oNPC);
}

#endif
