// Ambient Life Stage H activity subsystem baseline (canonical int-based semantics).
// Canonical activity IDs are sourced from PycukSystems activity table (see docs updates).

// Canonical IDs reused in Ambient Life ordinary execution layer.
const int AL_ACTIVITY_HIDDEN = 0;
const int AL_ACTIVITY_ACT_ONE = 1;
const int AL_ACTIVITY_DINNER = 3;
const int AL_ACTIVITY_AGREE = 7;
const int AL_ACTIVITY_ANGRY = 8;
const int AL_ACTIVITY_READ = 20;
const int AL_ACTIVITY_SIT = 21;
const int AL_ACTIVITY_STAND_CHAT = 23;
const int AL_ACTIVITY_CHEER = 28;
const int AL_ACTIVITY_KNEEL_TALK = 39;
const int AL_ACTIVITY_GUARD = 43;

// Sleep-related IDs from canonical list remain outside ordinary activity subsystem.
const int AL_ACTIVITY_MIDNIGHT_BED = 4;
const int AL_ACTIVITY_SLEEP_BED = 5;
const int AL_ACTIVITY_MIDNIGHT_90 = 31;
const int AL_ACTIVITY_SLEEP_90 = 32;

// Backward-compatible aliases used by existing Stage D/E/F code paths.
const int AL_ACTIVITY_IDLE = AL_ACTIVITY_HIDDEN;
const int AL_ACTIVITY_STAND = AL_ACTIVITY_STAND_CHAT;

const int AL_ACTIVITY_BEHAVIOR_IDLE_WAIT = 0;
const int AL_ACTIVITY_BEHAVIOR_SIT_WAIT = 1;
const int AL_ACTIVITY_BEHAVIOR_GUARD_WAIT = 2;
const int AL_ACTIVITY_BEHAVIOR_SOCIAL_WAIT = 3;
const int AL_ACTIVITY_BEHAVIOR_WORK_WAIT = 4;

int AL_ActivityBehaviorForCode(int nActivity)
{
    if (nActivity == AL_ACTIVITY_SIT || nActivity == AL_ACTIVITY_DINNER || nActivity == AL_ACTIVITY_READ)
    {
        return AL_ACTIVITY_BEHAVIOR_SIT_WAIT;
    }

    if (nActivity == AL_ACTIVITY_GUARD)
    {
        return AL_ACTIVITY_BEHAVIOR_GUARD_WAIT;
    }

    if (nActivity == AL_ACTIVITY_AGREE || nActivity == AL_ACTIVITY_ANGRY || nActivity == AL_ACTIVITY_CHEER || nActivity == AL_ACTIVITY_STAND_CHAT)
    {
        return AL_ACTIVITY_BEHAVIOR_SOCIAL_WAIT;
    }

    if (nActivity == AL_ACTIVITY_KNEEL_TALK)
    {
        return AL_ACTIVITY_BEHAVIOR_WORK_WAIT;
    }

    if (nActivity == AL_ACTIVITY_ACT_ONE)
    {
        return AL_ACTIVITY_BEHAVIOR_IDLE_WAIT;
    }

    return AL_ACTIVITY_BEHAVIOR_IDLE_WAIT;
}

string AL_ActivityNameForCode(int nActivity)
{
    if (nActivity == AL_ACTIVITY_HIDDEN) return "Hidden";
    if (nActivity == AL_ACTIVITY_ACT_ONE) return "ActOne";
    if (nActivity == AL_ACTIVITY_DINNER) return "Dinner";
    if (nActivity == AL_ACTIVITY_AGREE) return "Agree";
    if (nActivity == AL_ACTIVITY_ANGRY) return "Angry";
    if (nActivity == AL_ACTIVITY_READ) return "Read";
    if (nActivity == AL_ACTIVITY_SIT) return "Sit";
    if (nActivity == AL_ACTIVITY_STAND_CHAT) return "StandChat";
    if (nActivity == AL_ACTIVITY_CHEER) return "Cheer";
    if (nActivity == AL_ACTIVITY_KNEEL_TALK) return "KneelTalk";
    if (nActivity == AL_ACTIVITY_GUARD) return "Guard";

    return "Activity_" + IntToString(nActivity);
}

int AL_ActivityIsSleepSpecialCode(int nActivity)
{
    return nActivity == AL_ACTIVITY_MIDNIGHT_BED
        || nActivity == AL_ACTIVITY_SLEEP_BED
        || nActivity == AL_ACTIVITY_MIDNIGHT_90
        || nActivity == AL_ACTIVITY_SLEEP_90;
}

int AL_ActivityResolveCode(object oNpc, int nStepActivity)
{
    if (!GetIsObjectValid(oNpc))
    {
        return AL_ACTIVITY_HIDDEN;
    }

    if (nStepActivity > AL_ACTIVITY_HIDDEN)
    {
        return nStepActivity;
    }

    int nDefault = GetLocalInt(oNpc, "al_default_activity");
    if (nDefault > AL_ACTIVITY_HIDDEN)
    {
        return nDefault;
    }

    return AL_ACTIVITY_HIDDEN;
}

void AL_ActivityApplyIdleFallback(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    SetLocalInt(oNpc, "al_activity_current", AL_ACTIVITY_HIDDEN);
    SetLocalString(oNpc, "al_mode", "idle");
    ActionWait(1.0);
}

void AL_ActivityQueueOrdinary(object oNpc, int nActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDurSec <= 0)
    {
        nDurSec = 6;
    }

    int nBehavior = AL_ActivityBehaviorForCode(nActivity);

    if (nBehavior == AL_ACTIVITY_BEHAVIOR_SIT_WAIT)
    {
        ActionSit(OBJECT_INVALID);
        ActionWait(IntToFloat(nDurSec));
    }
    else
    {
        ActionWait(IntToFloat(nDurSec));
    }

    SetLocalInt(oNpc, "al_activity_current", nActivity);
    SetLocalString(oNpc, "al_mode", AL_ActivityNameForCode(nActivity));
}

void AL_ActivityApplyStep(object oNpc, int nStepActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nActivity = AL_ActivityResolveCode(oNpc, nStepActivity);
    if (nActivity <= AL_ACTIVITY_HIDDEN)
    {
        AL_ActivityApplyIdleFallback(oNpc);
        return;
    }

    // Sleep IDs are kept as Stage G special-case and never executed via ordinary activity path.
    if (AL_ActivityIsSleepSpecialCode(nActivity))
    {
        AL_ActivityApplyIdleFallback(oNpc);
        return;
    }

    AL_ActivityQueueOrdinary(oNpc, nActivity, nDurSec);
}

void AL_ActivityApplyBaseline(object oNpc, int nActivity, int nDurSec)
{
    AL_ActivityApplyStep(oNpc, nActivity, nDurSec);
}
