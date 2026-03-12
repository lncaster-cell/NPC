#include "al_events_inc"
#include "al_route_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (!AL_RouteRoutineResumeCurrent(oNpc))
    {
        AL_RouteBlockedRuntimeReset(oNpc);
        SignalEvent(oNpc, EventUserDefined(AL_EVENT_RESYNC));
    }
}
