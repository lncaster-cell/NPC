// Ambient Life Stage D minimal activity baseline (int-based contract).

const int AL_ACTIVITY_IDLE = 0;
const int AL_ACTIVITY_STAND = 1;
const int AL_ACTIVITY_SIT = 2;
const int AL_ACTIVITY_GUARD = 3;

void AL_ActivityApplyIdleFallback(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    ActionWait(1.0);
    SetLocalString(oNpc, "al_mode", "idle");
}

void AL_ActivityApplyBaseline(object oNpc, int nActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDurSec <= 0)
    {
        nDurSec = 6;
    }

    if (nActivity == AL_ACTIVITY_STAND)
    {
        ActionWait(IntToFloat(nDurSec));
        SetLocalString(oNpc, "al_mode", "stand");
        return;
    }

    if (nActivity == AL_ACTIVITY_SIT)
    {
        ActionSit(OBJECT_INVALID);
        ActionWait(IntToFloat(nDurSec));
        SetLocalString(oNpc, "al_mode", "sit");
        return;
    }

    if (nActivity == AL_ACTIVITY_GUARD)
    {
        ActionWait(IntToFloat(nDurSec));
        SetLocalString(oNpc, "al_mode", "guard");
        return;
    }

    AL_ActivityApplyIdleFallback(oNpc);
}
