#include "al_v1_area_inc"
#include "al_v1_util_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oExiting = GetExitingObject();
    if (!GetIsPC(oExiting) || GetIsDM(oExiting))
    {
        return;
    }

    if (DLV1_HasAnyPlayers(oArea))
    {
        DLV1_OnAreaBecameWarm(oArea);
        return;
    }

    DLV1_OnAreaBecameFrozen(oArea);
}
