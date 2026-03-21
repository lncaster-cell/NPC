#ifndef AL_V1_OVERRIDE_INC_NSS
#define AL_V1_OVERRIDE_INC_NSS

#include "al_v1_const_inc"
#include "al_v1_types_inc"

int DLV1_GetTopOverride(object oNPC, object oArea)
{
    int nOverride = GetLocalInt(oNPC, DLV1_L_OVERRIDE_KIND);
    if (nOverride != DLV1_OVR_NONE)
    {
        return nOverride;
    }

    nOverride = GetLocalInt(oArea, DLV1_L_OVERRIDE_KIND);
    if (nOverride != DLV1_OVR_NONE)
    {
        return nOverride;
    }

    return GetLocalInt(GetModule(), DLV1_L_OVERRIDE_KIND);
}

int DLV1_HasCriticalOverride(object oNPC, object oArea)
{
    int nOverride = DLV1_GetTopOverride(oNPC, oArea);
    return nOverride == DLV1_OVR_FIRE || nOverride == DLV1_OVR_QUARANTINE;
}

int DLV1_ShouldSuppressMaterialization(object oNPC, int nOverrideKind)
{
    if (nOverrideKind == DLV1_OVR_FIRE)
    {
        return TRUE;
    }

    if (nOverrideKind == DLV1_OVR_QUARANTINE)
    {
        int nFamily = DLV1_GetNpcFamily(oNPC);
        return nFamily != DLV1_FAMILY_LAW;
    }

    return FALSE;
}

int DLV1_ShouldDisableService(object oNPC, int nOverrideKind)
{
    if (nOverrideKind == DLV1_OVR_FIRE)
    {
        return TRUE;
    }

    if (nOverrideKind == DLV1_OVR_QUARANTINE)
    {
        return DLV1_GetNpcFamily(oNPC) != DLV1_FAMILY_LAW;
    }

    return FALSE;
}

#endif
