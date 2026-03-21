#ifndef AL_V1_INTERACT_INC_NSS
#define AL_V1_INTERACT_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_override_inc"
#include "al_v1_resolver_inc"

void DLV1_SetDialogueMode(object oNPC, int nDialogueMode)
{
    SetLocalInt(oNPC, DLV1_L_DIALOGUE_MODE, nDialogueMode);
}

void DLV1_SetServiceMode(object oNPC, int nServiceMode)
{
    SetLocalInt(oNPC, DLV1_L_SERVICE_MODE, nServiceMode);
}

void DLV1_RefreshInteractionState(object oNPC, object oArea)
{
    int nDirective = DLV1_ResolveDirective(oNPC, oArea);
    int nOverride = DLV1_GetTopOverride(oNPC, oArea);

    DLV1_SetDialogueMode(oNPC, DLV1_ResolveDialogueMode(oNPC, nDirective, nOverride));
    DLV1_SetServiceMode(oNPC, DLV1_ResolveServiceMode(oNPC, nDirective, nOverride));
    SetLocalInt(oNPC, DLV1_L_DIRECTIVE, nDirective);
    SetLocalInt(oNPC, DLV1_L_ANCHOR_GROUP, DLV1_ResolveAnchorGroup(oNPC, nDirective));
}

#endif
