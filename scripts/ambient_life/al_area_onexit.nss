#include "al_area_inc"

void main()
{
    object oExit = GetExitingObject();
    if (!GetIsPC(oExit) || GetIsDM(oExit)) return;

    AL_HandleAreaPlayerExit(OBJECT_SELF);
}
