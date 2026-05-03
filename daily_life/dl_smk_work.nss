// Step 04 worker smoke for manual diagnostics, not for permanent heartbeat.

#include "dl_core_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oModule = GetModule();
    string DL_SMK_L_ENABLED = "dl_smk_enabled";
    string DL_SMK_L_ACTOR_TAG = "dl_smk_actor_tag";
    string DL_SMK_NS = "dl_smk_metric_work_";

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

    SetLocalInt(oModule, DL_L_MODULE_ENABLED, TRUE);
    SetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION, DL_CONTRACT_VERSION_A0);

    DeleteLocalInt(oArea, DL_L_AREA_WORKER_CURSOR);
    DeleteLocalInt(oArea, DL_L_AREA_WORKER_BUDGET);

    DL_BootstrapAreaTier(oArea);
    DL_RunAreaWorkerTick(oArea);

    SetLocalInt(oArea, DL_SMK_NS + "cur", DL_GetAreaWorkerCursor(oArea));
    SetLocalInt(oArea, DL_SMK_NS + "tik", GetLocalInt(oArea, DL_L_AREA_WORKER_TICK));
}
