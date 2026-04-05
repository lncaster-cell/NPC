#ifndef DL_DIALOGUE_BRIDGE_INC_NSS
#define DL_DIALOGUE_BRIDGE_INC_NSS

#include "dl_const_inc"
#include "dl_util_inc"
#include "dl_types_inc"
#include "dl_interact_inc"
#include "dl_log_inc"

const string DL_L_CONV_STORE_OBJECT = "dl_conv_store_object";
const string DL_L_CONV_STORE_TAG = "dl_conv_store_tag";
const string DL_L_CONV_STORE_MARKUP = "dl_conv_store_markup";
const string DL_L_CONV_STORE_MARKDOWN = "dl_conv_store_markdown";

int DL_ShouldSkipConversationPrepare(object oNPC)
{
    int nDirective;

    if (!DL_IsValidCreature(oNPC) || !DL_IsDailyLifeNpc(oNPC))
    {
        return TRUE;
    }

    nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);
    return nDirective == DL_DIR_ABSENT || nDirective == DL_DIR_UNASSIGNED;
}

int DL_PrepareConversationState(object oNPC)
{
    object oArea;

    if (DL_ShouldSkipConversationPrepare(oNPC))
    {
        return FALSE;
    }

    oArea = GetArea(oNPC);
    if (!GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    DL_RefreshInteractionState(oNPC, oArea);
    return TRUE;
}

void DL_FinalizeConversationState(object oNPC)
{
    if (DL_ShouldSkipConversationPrepare(oNPC))
    {
        return;
    }

    if (GetIsObjectValid(GetArea(oNPC)))
    {
        DL_RefreshInteractionState(oNPC, GetArea(oNPC));
    }
}

int DL_IsConversationAvailable(object oNPC)
{
    int nDirective;

    if (!DL_IsValidCreature(oNPC))
    {
        return FALSE;
    }
    if (!DL_IsDailyLifeNpc(oNPC))
    {
        return TRUE;
    }

    nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);
    return nDirective != DL_DIR_ABSENT && nDirective != DL_DIR_UNASSIGNED;
}

int DL_HasDialogueMode(object oNPC, int nDialogueMode)
{
    if (!DL_IsValidCreature(oNPC) || !DL_IsDailyLifeNpc(oNPC))
    {
        return FALSE;
    }
    return GetLocalInt(oNPC, DL_L_DIALOGUE_MODE) == nDialogueMode;
}

int DL_HasServiceMode(object oNPC, int nServiceMode)
{
    if (!DL_IsValidCreature(oNPC) || !DL_IsDailyLifeNpc(oNPC))
    {
        return FALSE;
    }
    return GetLocalInt(oNPC, DL_L_SERVICE_MODE) == nServiceMode;
}

int DL_CanOpenConversationStore(object oNPC)
{
    int nServiceMode;

    if (!DL_IsValidCreature(oNPC) || !DL_IsDailyLifeNpc(oNPC))
    {
        return FALSE;
    }

    nServiceMode = GetLocalInt(oNPC, DL_L_SERVICE_MODE);
    return nServiceMode == DL_SERVICE_AVAILABLE || nServiceMode == DL_SERVICE_LIMITED;
}

object DL_GetConversationStore(object oNPC)
{
    object oStore = GetLocalObject(oNPC, DL_L_CONV_STORE_OBJECT);
    string sStoreTag;

    if (GetIsObjectValid(oStore))
    {
        return oStore;
    }

    sStoreTag = GetLocalString(oNPC, DL_L_CONV_STORE_TAG);
    if (sStoreTag == "")
    {
        return OBJECT_INVALID;
    }

    return GetObjectByTag(sStoreTag);
}

int DL_OpenConversationStore(object oNPC, object oPC)
{
    object oStore;
    int nMarkup;
    int nMarkdown;

    if (!GetIsObjectValid(oPC) || !DL_CanOpenConversationStore(oNPC))
    {
        return FALSE;
    }

    oStore = DL_GetConversationStore(oNPC);
    if (!GetIsObjectValid(oStore))
    {
        DL_LogNpc(oNPC, DL_DEBUG_BASIC, "conversation store missing or invalid");
        return FALSE;
    }

    nMarkup = GetLocalInt(oNPC, DL_L_CONV_STORE_MARKUP);
    nMarkdown = GetLocalInt(oNPC, DL_L_CONV_STORE_MARKDOWN);
    OpenStore(oStore, oPC, nMarkup, nMarkdown);
    return TRUE;
}

#endif
