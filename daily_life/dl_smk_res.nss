// Step 05 resolver/materialization smoke.
// Includes EARLY_WORKER baseline plus BLACKSMITH A/B probes and PASS flags.

#include "dl_res_inc"

void main()
{
    object oNpc = GetFirstPC();
    object oModule = GetModule();

    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalString(oNpc, DL_L_NPC_PROFILE_ID, DL_PROFILE_EARLY_WORKER);

    SetLocalInt(oModule, "dl_smk_res_05", DL_ResolveNpcDirectiveAtHour(oNpc, 5));
    SetLocalInt(oModule, "dl_smk_res_06", DL_ResolveNpcDirectiveAtHour(oNpc, 6));
    SetLocalInt(oModule, "dl_smk_res_21", DL_ResolveNpcDirectiveAtHour(oNpc, 21));
    SetLocalInt(oModule, "dl_smk_res_22", DL_ResolveNpcDirectiveAtHour(oNpc, 22));
    SetLocalInt(oModule, "dl_smk_res_23", DL_ResolveNpcDirectiveAtHour(oNpc, 23));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 22));
    SetLocalInt(oModule, "dl_smk_res_mat", GetLocalInt(oNpc, DL_L_NPC_MAT_REQ));
    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 6));
    SetLocalString(oModule, "dl_smk_res_06_dlg", GetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE));
    SetLocalString(oModule, "dl_smk_res_06_srv", GetLocalString(oNpc, DL_L_NPC_SERVICE_MODE));
    SetLocalInt(oModule, "dl_smk_res_06_mat", GetLocalInt(oNpc, DL_L_NPC_MAT_REQ));

    SetLocalString(oNpc, DL_L_NPC_PROFILE_ID, DL_PROFILE_BLACKSMITH);
    SetLocalInt(oModule, "dl_smk_bs_10", DL_ResolveNpcDirectiveAtHour(oNpc, 10));
    SetLocalInt(oModule, "dl_smk_bs_21", DL_ResolveNpcDirectiveAtHour(oNpc, 21));
    SetLocalInt(oModule, "dl_smk_bs_23", DL_ResolveNpcDirectiveAtHour(oNpc, 23));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 10));
    SetLocalString(oModule, "dl_smk_bs_10_dlg", GetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE));
    SetLocalString(oModule, "dl_smk_bs_10_srv", GetLocalString(oNpc, DL_L_NPC_SERVICE_MODE));
    SetLocalString(oModule, "dl_smk_bs_10_tag", GetLocalString(oNpc, DL_L_NPC_MAT_TAG));
    SetLocalString(oModule, "dl_smk_bs_10_kind", GetLocalString(oNpc, DL_L_NPC_WORK_KIND));
    SetLocalString(oModule, "dl_smk_bs_10_wst", GetLocalString(oNpc, DL_L_NPC_WORK_STATUS));
    SetLocalString(oModule, "dl_smk_bs_10_wdiag", GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 11));
    SetLocalString(oModule, "dl_smk_bs_11_kind", GetLocalString(oNpc, DL_L_NPC_WORK_KIND));
    SetLocalString(oModule, "dl_smk_bs_11_wst", GetLocalString(oNpc, DL_L_NPC_WORK_STATUS));
    SetLocalString(oModule, "dl_smk_bs_11_wdiag", GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC));

    DL_ApplyDirectiveSkeleton(oNpc, DL_ResolveNpcDirectiveAtHour(oNpc, 21));
    SetLocalString(oModule, "dl_smk_bs_21_dlg", GetLocalString(oNpc, DL_L_NPC_DIALOGUE_MODE));
    SetLocalString(oModule, "dl_smk_bs_21_srv", GetLocalString(oNpc, DL_L_NPC_SERVICE_MODE));
    SetLocalString(oModule, "dl_smk_bs_21_tag", GetLocalString(oNpc, DL_L_NPC_MAT_TAG));
    SetLocalInt(oModule, "dl_smk_bs_21_act", GetLocalInt(oNpc, DL_L_NPC_ACTIVITY_ID));
    SetLocalString(oModule, "dl_smk_bs_21_anim", GetLocalString(oNpc, DL_L_NPC_ANIM_SET));

    int bEarlyWorkerWindowPass =
        GetLocalInt(oModule, "dl_smk_res_05") == DL_DIR_SLEEP &&
        GetLocalInt(oModule, "dl_smk_res_06") == DL_DIR_NONE &&
        GetLocalInt(oModule, "dl_smk_res_22") == DL_DIR_SLEEP &&
        GetLocalInt(oModule, "dl_smk_res_23") == DL_DIR_SLEEP &&
        GetLocalString(oModule, "dl_smk_res_06_dlg") == DL_DIALOGUE_IDLE &&
        GetLocalString(oModule, "dl_smk_res_06_srv") == DL_SERVICE_OFF &&
        GetLocalInt(oModule, "dl_smk_res_06_mat") != TRUE;
    SetLocalInt(oModule, "dl_smk_res_early_pass", bEarlyWorkerWindowPass);

    int bBlacksmithABPass =
        GetLocalInt(oModule, "dl_smk_bs_10") == DL_DIR_WORK &&
        GetLocalString(oModule, "dl_smk_bs_10_dlg") == DL_DIALOGUE_WORK &&
        GetLocalString(oModule, "dl_smk_bs_10_srv") == DL_SERVICE_AVAILABLE &&
        GetLocalString(oModule, "dl_smk_bs_10_tag") == DL_MAT_WORK &&
        GetLocalString(oModule, "dl_smk_bs_10_kind") == DL_WORK_KIND_FORGE &&
        GetLocalString(oModule, "dl_smk_bs_10_wst") == "missing_waypoints" &&
        GetLocalString(oModule, "dl_smk_bs_10_wdiag") == "need_forge_and_craft_waypoints" &&
        GetLocalString(oModule, "dl_smk_bs_11_kind") == DL_WORK_KIND_CRAFT &&
        GetLocalString(oModule, "dl_smk_bs_11_wst") == "missing_waypoints" &&
        GetLocalString(oModule, "dl_smk_bs_11_wdiag") == "need_forge_and_craft_waypoints" &&
        GetLocalInt(oModule, "dl_smk_bs_21") == DL_DIR_SLEEP &&
        GetLocalString(oModule, "dl_smk_bs_21_dlg") == DL_DIALOGUE_SLEEP &&
        GetLocalString(oModule, "dl_smk_bs_21_srv") == DL_SERVICE_OFF &&
        GetLocalString(oModule, "dl_smk_bs_21_tag") == DL_MAT_SLEEP &&
        GetLocalInt(oModule, "dl_smk_bs_21_act") == DL_ARCH_ACT_NPC_SLEEP_BED &&
        GetLocalString(oModule, "dl_smk_bs_21_anim") == DL_ARCH_ANIMS_SLEEP_BED &&
        GetLocalInt(oModule, "dl_smk_bs_23") == DL_DIR_SLEEP;
    SetLocalInt(oModule, "dl_smk_bs_ab_pass", bBlacksmithABPass);

    SetLocalInt(oModule, "dl_smk_res_pass", bEarlyWorkerWindowPass && bBlacksmithABPass);
}
