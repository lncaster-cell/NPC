#include "dl_core_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    object oArea = GetArea(oNpc);

    DL_CR_HandleNpcKilled(oNpc);
    DL_RequestNpcLifecycleSignal(oNpc, DL_NPC_EVENT_DEATH);

    if (DL_IsRuntimeLogEnabled())
    {
        string sLog = "[DL][DEATH_SIGNAL] npc=" + GetName(oNpc) +
                      " area=" + GetName(oArea) +
                      " kind=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_EVENT_KIND)) +
                      " seq=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ));

        DL_LogRuntime(sLog);
    }
}
