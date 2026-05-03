#include "dl_core_inc"

void main()
{
    object oGuard = OBJECT_SELF;
    object oPc = DL_GetDialogPlayer();
    if (!GetIsObjectValid(oPc))
    {
        return;
    }

    DL_CR_HandleDetainRefused(oPc, oGuard);
}
