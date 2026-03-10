// Ambient Life Stage D minimal activity baseline.

void AL_ActivityApplyIdleFallback(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    ActionWait(1.0);
    SetLocalString(oNpc, "al_mode", "idle");
}

void AL_ActivityApplyBaseline(object oNpc, string sActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDurSec <= 0)
    {
        nDurSec = 6;
    }

    if (sActivity == "")
    {
        AL_ActivityApplyIdleFallback(oNpc);
        return;
    }

    if (sActivity == "stand")
    {
        ActionWait(IntToFloat(nDurSec));
        SetLocalString(oNpc, "al_mode", "stand");
        return;
    }

    if (sActivity == "sit")
    {
        ActionSit(OBJECT_INVALID);
        ActionWait(IntToFloat(nDurSec));
        SetLocalString(oNpc, "al_mode", "sit");
        return;
    }

    if (sActivity == "guard")
    {
        ActionWait(IntToFloat(nDurSec));
        SetLocalString(oNpc, "al_mode", "guard");
        return;
    }

    AL_ActivityApplyIdleFallback(oNpc);
}
