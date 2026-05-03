// Dispatcher/resync smoke for manual diagnostics, not for permanent heartbeat.

#include "dl_core_inc"

void main()
{
    object oModule = GetModule();
    string DL_SMK_L_ENABLED = "dl_smk_enabled";
    string DL_SMK_L_ACTOR_TAG = "dl_smk_actor_tag";
    string DL_SMK_NS = "dl_smk_metric_sync_";

    if (GetLocalInt(oModule, DL_SMK_L_ENABLED) != TRUE)
    {
        return;
    }

    object oNpc = OBJECT_INVALID;
    string sActorTag = GetLocalString(oModule, DL_SMK_L_ACTOR_TAG);
    if (sActorTag != "")
    {
        oNpc = GetObjectByTag(sActorTag);
    }
    if (!GetIsObjectValid(oNpc))
    {
        oNpc = GetFirstPC();
    }

    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oModule, DL_L_MODULE_ENABLED, TRUE);
    SetLocalString(oModule, DL_L_MODULE_CONTRACT_VERSION, DL_CONTRACT_VERSION_A0);

    DL_RequestResync(oNpc, DL_RESYNC_USER);
    int bPendingBefore = GetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING);

    DL_ProcessResync(oNpc);
    int bPendingAfter = GetLocalInt(oNpc, DL_L_NPC_RESYNC_PENDING);

    SetLocalInt(oModule, DL_SMK_NS + "before", bPendingBefore);
    SetLocalInt(oModule, DL_SMK_NS + "after", bPendingAfter);
}
