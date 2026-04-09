// Daily Life v2 smoke Step 01 (clean-room reset).
// Minimal check for module contract initialization.

#include "dl_v2_core_inc"

void main()
{
    object oModule = GetModule();

    DeleteLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION);
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, TRUE);

    DL2_InitModuleContract();

    int bRuntimeEnabled = DL2_IsRuntimeEnabled();
    SetLocalInt(oModule, "dl2_smoke_step_01_runtime_enabled", bRuntimeEnabled);
}
