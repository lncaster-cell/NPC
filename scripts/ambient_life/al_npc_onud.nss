#include "al_events_inc"

void main()
{
    int nEvent = GetUserDefinedEventNumber();

    if (nEvent == AL_EVENT_RESYNC)
    {
        // Core lifecycle hook: reset slot marker so next SLOT event is always accepted.
        SetLocalInt(OBJECT_SELF, "al_last_slot", -1);
        return;
    }

    if (nEvent >= AL_EVENT_SLOT_0 && nEvent <= AL_EVENT_SLOT_5)
    {
        int nSlot = nEvent - AL_EVENT_SLOT_0;
        if (GetLocalInt(OBJECT_SELF, "al_last_slot") != nSlot)
        {
            SetLocalInt(OBJECT_SELF, "al_last_slot", nSlot);
            // Route/activity execution is intentionally deferred to next stages.
        }
        return;
    }

    if (nEvent == AL_EVENT_ROUTE_REPEAT)
    {
        // Reserved hook for route execution loop.
        return;
    }
}
