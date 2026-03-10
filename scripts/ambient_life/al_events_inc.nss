#ifndef AL_EVENTS_INC_NSS
#define AL_EVENTS_INC_NSS

// Ambient Life internal event namespace for OnUserDefined.
// Namespace ownership rule:
// - 1100..1199 is owned by Ambient Life core/routine events.
// - 1200..1299 is reserved for Ambient Life reaction events.
// Other internal subsystems must not emit arbitrary events in these ranges.
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
