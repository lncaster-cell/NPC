// Daily Life v2 smoke Step 01.
// Verifies DL2_IsRuntimeEnabled() contract in 3 baseline cases.

#include "dl_v2_runtime_inc"

void DL2_LogCaseResult(string sCaseId, int bExpected, int bActual)
{
    string sVerdict = bExpected == bActual ? "PASS" : "FAIL";
    SendMessageToPC(GetFirstPC(), "[DL2][SMOKE][STEP01][" + sVerdict + "] " + sCaseId
        + " expected=" + IntToString(bExpected)
        + " actual=" + IntToString(bActual));
}

void main()
{
    object oModule = GetModule();

    // Case 1: module disabled.
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, FALSE);
    SetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION, DL2_CONTRACT_VERSION_A0);
    DL2_LogCaseResult("disabled", FALSE, DL2_IsRuntimeEnabled());

    // Case 2: enabled with invalid version.
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, TRUE);
    SetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION, "v2.invalid");
    DL2_LogCaseResult("enabled_invalid_version", FALSE, DL2_IsRuntimeEnabled());

    // Case 3: enabled with accepted version.
    SetLocalInt(oModule, DL2_L_MODULE_ENABLED, TRUE);
    SetLocalString(oModule, DL2_L_MODULE_CONTRACT_VERSION, DL2_CONTRACT_VERSION_A0);
    DL2_LogCaseResult("enabled_a0", TRUE, DL2_IsRuntimeEnabled());
}
