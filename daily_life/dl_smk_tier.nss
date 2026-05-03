// Area tier bootstrap smoke for manual diagnostics, not for permanent heartbeat.

#include "dl_core_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();
    string DL_SMK_L_ENABLED = "dl_smk_enabled";
    string DL_SMK_L_ACTOR_TAG = "dl_smk_actor_tag";
    string DL_SMK_NS = "dl_smk_metric_tier_";

    if (GetLocalInt(oModule, DL_SMK_L_ENABLED) != TRUE)
    {
        return;
    }

    object oActor = OBJECT_INVALID;
    string sActorTag = GetLocalString(oModule, DL_SMK_L_ACTOR_TAG);
    if (sActorTag != "")
    {
        oActor = GetObjectByTag(sActorTag);
    }
    if (!GetIsObjectValid(oActor))
    {
        oActor = GetFirstPC();
    }

    if (!DL_IsAreaObject(oArea))
    {
        oArea = GetArea(oActor);
    }

    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    // Reset policy: area tier is explicit state; reset via canonical value, not key deletion.
    SetLocalInt(oArea, DL_L_AREA_TIER, DL_TIER_WARM);
    DL_BootstrapAreaTier(oArea);

    SetLocalInt(oArea, DL_SMK_NS + "value", DL_GetAreaTier(oArea));
}
