#include "dl_core_inc"

void main()
{
    object oGuard = OBJECT_SELF;
    object oPc = GetPCSpeaker();
    if (!GetIsObjectValid(oPc))
    {
        oPc = GetLastSpeaker();
    }

    DL_CR_HandleDetainRefused(oPc, oGuard);
}
