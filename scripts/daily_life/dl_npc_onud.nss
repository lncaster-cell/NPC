#include "dl_npc_hooks_inc"

void main()
{
    DL_OnNpcUserDefinedHook(OBJECT_SELF, GetUserDefinedEventNumber());
}
