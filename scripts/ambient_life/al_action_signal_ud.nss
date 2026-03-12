#include "al_events_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nEvent = GetLocalInt(oNpc, "al_action_signal_event");
    DeleteLocalInt(oNpc, "al_action_signal_event");
    if (nEvent <= 0)
    {
        return;
    }

    SignalEvent(oNpc, EventUserDefined(nEvent));
}
