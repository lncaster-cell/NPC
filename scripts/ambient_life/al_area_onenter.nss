#include "al_area_inc"

void main()
{
    object oEnter = GetEnteringObject();
    if (!GetIsPC(oEnter) || GetIsDM(oEnter)) return;

    AL_HandleAreaPlayerEnter(OBJECT_SELF);
}
