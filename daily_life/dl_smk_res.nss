// Step 05 resolver/materialization smoke.
// Includes EARLY_WORKER baseline plus BLACKSMITH A/B probes.

#include "dl_res_inc"

void main()
{
    object oNpc = GetFirstPC();
    object oModule = GetModule();

    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalString(oNpc, "dl_profile_id", "early_worker");

    SetLocalInt(oModule, "dl_smk_res_05", DL_ResolveNpcDirectiveAtHour(oNpc, 5));
    SetLocalInt(oModule, "dl_smk_res_06", DL_ResolveNpcDirectiveAtHour(oNpc, 6));
    SetLocalInt(oModule, "dl_smk_res_21", DL_ResolveNpcDirectiveAtHour(oNpc, 21));
    SetLocalInt(oModule, "dl_smk_res_22", DL_ResolveNpcDirectiveAtHour(oNpc, 22));
    SetLocalInt(oModule, "dl_smk_res_23", DL_ResolveNpcDirectiveAtHour(oNpc, 23));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 22));
    SetLocalInt(oModule, "dl_smk_res_mat", GetLocalInt(oNpc, DL_L_NPC_MAT_REQ));

    SetLocalString(oNpc, "dl_profile_id", "blacksmith");
    SetLocalInt(oModule, "dl_smk_bs_10", DL_ResolveNpcDirectiveAtHour(oNpc, 10));
    SetLocalInt(oModule, "dl_smk_bs_21", DL_ResolveNpcDirectiveAtHour(oNpc, 21));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 10));
    SetLocalString(oModule, "dl_smk_bs_10_dlg", GetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE));
    SetLocalString(oModule, "dl_smk_bs_10_srv", GetLocalString(oNpc, DL_L_NPC_SERVICE_MODE));
    SetLocalString(oModule, "dl_smk_bs_10_tag", GetLocalString(oNpc, DL_L_NPC_MAT_TAG));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 21));
    SetLocalString(oModule, "dl_smk_bs_21_dlg", GetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE));
    SetLocalString(oModule, "dl_smk_bs_21_srv", GetLocalString(oNpc, DL_L_NPC_SERVICE_MODE));
    SetLocalString(oModule, "dl_smk_bs_21_tag", GetLocalString(oNpc, DL_L_NPC_MAT_TAG));
}
