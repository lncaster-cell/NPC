#include "dl_core_inc"

void main()
{
    object oPc = DL_GetDialogPlayer();
    if (!GetIsObjectValid(oPc))
    {
        return;
    }

    DL_LG_ResolveCaseDetainComplete(oPc);
}
