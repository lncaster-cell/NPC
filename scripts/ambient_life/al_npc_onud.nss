#include "al_events_inc"
#include "al_route_inc"

void main()
{
    int nEvent = GetUserDefinedEventNumber();

    if (nEvent == AL_EVENT_RESYNC)
    {
        object oArea = GetArea(OBJECT_SELF);
        int nSlot = GetLocalInt(oArea, "al_slot");
        SetLocalInt(OBJECT_SELF, "al_last_slot", nSlot);
        AL_StartSlotRoute(OBJECT_SELF, nSlot);
        return;
    }

    if (nEvent >= AL_EVENT_SLOT_0 && nEvent <= AL_EVENT_SLOT_5)
    {
        int nSlot = nEvent - AL_EVENT_SLOT_0;
        if (GetLocalInt(OBJECT_SELF, "al_last_slot") != nSlot)
        {
            SetLocalInt(OBJECT_SELF, "al_last_slot", nSlot);
            AL_StartSlotRoute(OBJECT_SELF, nSlot);
        }
        return;
    }

    if (nEvent == AL_EVENT_ROUTE_REPEAT)
    {
        AL_HandleRouteRepeat(OBJECT_SELF);
        return;
    }
}
