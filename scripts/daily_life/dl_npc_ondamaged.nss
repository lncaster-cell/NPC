#include "dl_npc_hooks_inc"

void main()
{
    if (DL_ShouldEmitDamagedEvent(OBJECT_SELF))
    {
        DL_SignalNpcUserDefined(OBJECT_SELF, DL_UD_DAMAGED);
    }
}
