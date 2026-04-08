#ifndef DL_V2_RUNTIME_INC_NSS
#define DL_V2_RUNTIME_INC_NSS

// Daily Life v2 runtime locals and helpers.
// Step 01 scope: runtime enablement gate only.

const string DL2_L_MODULE_ENABLED = "dl2_enabled";
const string DL2_L_MODULE_CONTRACT_VERSION = "dl2_contract_version";
const string DL2_CONTRACT_VERSION_A0 = "v2.a0";

int DL2_IsRuntimeEnabled()
{
    object oModule = GetModule();
    if (GetLocalInt(oModule, DL2_L_MODULE_ENABLED) != TRUE)
    {
        return FALSE;
    }

    return GetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION) == DL2_CONTRACT_VERSION_A0;
}

#endif
