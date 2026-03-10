// Ambient Life internal event bus (Stage B).

const int AL_EVENT_SLOT_0 = 3100;
const int AL_EVENT_SLOT_1 = 3101;
const int AL_EVENT_SLOT_2 = 3102;
const int AL_EVENT_SLOT_3 = 3103;
const int AL_EVENT_SLOT_4 = 3104;
const int AL_EVENT_SLOT_5 = 3105;
const int AL_EVENT_RESYNC = 3106;
const int AL_EVENT_ROUTE_REPEAT = 3107; // reserved hook for Stage C+

int AL_IsSlotEvent(int nEvent)
{
    return (nEvent >= AL_EVENT_SLOT_0 && nEvent <= AL_EVENT_SLOT_5);
}

int AL_SlotFromEvent(int nEvent)
{
    if (!AL_IsSlotEvent(nEvent))
    {
        return -1;
    }

    return nEvent - AL_EVENT_SLOT_0;
}

int AL_EventFromSlot(int nSlot)
{
    if (nSlot < 0 || nSlot > 5)
    {
        return -1;
    }

    return AL_EVENT_SLOT_0 + nSlot;
}
