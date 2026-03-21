#include "dl_area_inc"
#include "dl_resync_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oEntering = GetEnteringObject();
    if (!GetIsPC(oEntering) || GetIsDM(oEntering))
    {
        return;
    }

    DL_OnAreaBecameHot(oArea);

    object oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject))
        {
            DL_RequestResync(oObject, DL_RESYNC_AREA_ENTER);
        }
        oObject = GetNextObjectInArea(oArea);
    }
}
