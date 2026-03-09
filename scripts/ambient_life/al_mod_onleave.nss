#include "al_area_inc"

void main()
{
    object oPc = GetExitingObject();
    if (!GetIsPC(oPc) || GetIsDM(oPc)) return;

    object oArea = GetArea(oPc);
    if (GetIsObjectValid(oArea))
    {
        AL_HandleAreaPlayerExit(oArea);
    }
}
