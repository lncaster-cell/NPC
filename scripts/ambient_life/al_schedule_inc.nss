#ifndef AL_SCHEDULE_INC_NSS
#define AL_SCHEDULE_INC_NSS

// 6 slots x 4h each.
int AL_GetCurrentSlot(object oArea, object oNpc)
{
    int nHour = GetTimeHour();
    int nSlot = nHour / 4;

    // Optional per-NPC minute offset for slot boundary staggering.
    int nOffsetMin = 0;
    if (GetIsObjectValid(oNpc))
    {
        nOffsetMin = GetLocalInt(oNpc, "al_slot_offset_min");
    }

    if (nOffsetMin != 0)
    {
        int nMinute = GetTimeMinute();
        int nTotal = (nHour * 60 + nMinute + nOffsetMin) % 1440;
        if (nTotal < 0) nTotal = nTotal + 1440;
        nSlot = (nTotal / 240);
    }

    if (nSlot < 0) nSlot = 0;
    if (nSlot > 5) nSlot = 5;
    return nSlot;
}

#endif
