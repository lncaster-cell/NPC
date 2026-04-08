// Daily Life v2 bootstrap stub.
// Runtime logic is introduced incrementally, one verified function at a time.

#include "dl_v2_runtime_inc"

void main()
{
    int bRuntimeEnabled = DL2_IsRuntimeEnabled();

    // Step 01 diagnostic signal: verifies bootstrap can access runtime gate.
    SendMessageToPC(GetFirstPC(), "[DL2][BOOTSTRAP] runtime_enabled=" + IntToString(bRuntimeEnabled));
}
