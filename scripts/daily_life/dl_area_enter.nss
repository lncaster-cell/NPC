#include "dl_area_inc"
#include "dl_resync_inc"
#include "dl_types_inc"

void main()
{
    object oArea = OBJECT_SELF;
    object oEntering = GetEnteringObject();
    object oObject;

    if (!GetIsPC(oEntering) || GetIsDM(oEntering))
    {
        return;
    }

    DL_OnAreaBecameHot(oArea);

    oObject = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObject))
    {
        if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject) && DL_IsDailyLifeNpc(oObject))
        {
            DL_RequestResync(oObject, DL_RESYNC_AREA_ENTER);
        }
        oObject = GetNextObjectInArea(oArea);
    }
}
