#include "dl_npc_hooks_inc"

void main()
{
    if (DL_ShouldEmitDisturbedEvent(OBJECT_SELF))
    {
        DL_SignalNpcUserDefined(OBJECT_SELF, DL_UD_DISTURBED);
    }
}
