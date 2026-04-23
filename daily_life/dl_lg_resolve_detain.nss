#include "dl_core_inc"

void main()
{
    object oPc = GetPCSpeaker();
    if (!GetIsObjectValid(oPc))
    {
        oPc = GetLastSpeaker();
    }

    if (!DL_IsRuntimePlayer(oPc))
    {
        return;
    }

    DL_LG_ResolveCaseDetainComplete(oPc);
}
