#include "dl_runtime_contract_inc"

// Manual BSMITH_TRACE_OFF debug command/script.
// Assign/run this when bounded blacksmith tracing must be stopped immediately.
void main()
{
    object oNpc = GetObjectByTag("blacksmith01", 0);
    DL_BsmithTraceDisable(oNpc);

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, "BSMITH_TRACE_OFF status=cleared npc=blacksmith01");
        oPC = GetNextPC();
    }
}
