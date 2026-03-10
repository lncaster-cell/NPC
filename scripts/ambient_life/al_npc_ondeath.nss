#include "al_registry_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea)) return;

    AL_UnregisterNpc(oArea, oNpc);
}
