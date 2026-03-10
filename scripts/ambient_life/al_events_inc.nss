#ifndef AL_EVENTS_INC_NSS
#define AL_EVENTS_INC_NSS

// Ambient Life internal event namespace for OnUserDefined.
// Ambient Life owns canonical range 1100-1299.
// Other internal subsystems must not allocate events in this range unless coordinated.
// Reserved compact range avoids collision with common low-index custom events.
const int AL_EVENT_BASE = 1100;

const int AL_EVENT_RESYNC = AL_EVENT_BASE + 1;
const int AL_EVENT_SLOT_0 = AL_EVENT_BASE + 10;
const int AL_EVENT_SLOT_1 = AL_EVENT_BASE + 11;
const int AL_EVENT_SLOT_2 = AL_EVENT_BASE + 12;
const int AL_EVENT_SLOT_3 = AL_EVENT_BASE + 13;
const int AL_EVENT_SLOT_4 = AL_EVENT_BASE + 14;
const int AL_EVENT_SLOT_5 = AL_EVENT_BASE + 15;

// Future route execution hook.
const int AL_EVENT_ROUTE_REPEAT = AL_EVENT_BASE + 20;

// Reserved reaction window (future): 1200-1299.
// Keep untouched by non-Ambient-Life systems.
const int AL_EVENT_REACT_BASE = 1200;
const int AL_EVENT_REACT_MAX = 1299;

int AL_GetSlotEvent(int nSlot)
{
    if (nSlot == 0) return AL_EVENT_SLOT_0;
    if (nSlot == 1) return AL_EVENT_SLOT_1;
    if (nSlot == 2) return AL_EVENT_SLOT_2;
    if (nSlot == 3) return AL_EVENT_SLOT_3;
    if (nSlot == 4) return AL_EVENT_SLOT_4;
    return AL_EVENT_SLOT_5;
}

#endif
