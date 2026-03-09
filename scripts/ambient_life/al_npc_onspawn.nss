#include "al_registry_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea)) return;

    object oLastArea = GetLocalObject(oNpc, "al_last_area");
    if (GetIsObjectValid(oLastArea) && oLastArea != oArea)
    {
        AL_UnregisterNpc(oLastArea, oNpc);
    }

    AL_RegisterNpc(oArea, oNpc);
    SetLocalObject(oNpc, "al_last_area", oArea);
}
