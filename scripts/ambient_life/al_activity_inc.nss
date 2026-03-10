#ifndef AL_ACTIVITY_INC_NSS
#define AL_ACTIVITY_INC_NSS

const string AL_LOCAL_DEFAULT_ACTIVITY = "al_default_activity";

const int AL_ACTIVITY_IDLE = 0;
const int AL_ACTIVITY_WANDER = 1;

int AL_SanitizeActivity(int nActivity)
{
    if (nActivity == AL_ACTIVITY_IDLE) return nActivity;
    if (nActivity == AL_ACTIVITY_WANDER) return nActivity;
    return -1;
}

int AL_GetSafeActivity(object oNpc, int nActivity)
{
    int nSafe = AL_SanitizeActivity(nActivity);
    if (nSafe >= 0) return nSafe;

    nSafe = AL_SanitizeActivity(GetLocalInt(oNpc, AL_LOCAL_DEFAULT_ACTIVITY));
    if (nSafe >= 0) return nSafe;

    return AL_ACTIVITY_IDLE;
}

void AL_QueueActivity(object oNpc, int nActivity, float fDwellSec)
{
    if (!GetIsObjectValid(oNpc)) return;

    int nSafeActivity = AL_GetSafeActivity(oNpc, nActivity);

    // Keep routine sequencing in engine action queue; no per-NPC timers.
    if (nSafeActivity == AL_ACTIVITY_WANDER)
    {
        // Stage 2 keeps activity semantics minimal and queue-safe.
        ActionWait(1.0);
    }

    if (fDwellSec > 0.0)
    {
        ActionWait(fDwellSec);
    }
}

#endif
