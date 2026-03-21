#include "al_v1_area_inc"
#include "al_v1_resync_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oEntering = GetEnteringObject();
    if (!GetIsPC(oEntering) || GetIsDM(oEntering))
    {
        return;
    }

    DLV1_OnAreaBecameHot(oArea);

    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            DLV1_RequestResync(oObject, DLV1_RESYNC_AREA_ENTER);
        }
        oObject = GetNextObjectInArea(oArea);
    }
}
