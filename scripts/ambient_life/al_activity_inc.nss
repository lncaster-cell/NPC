// Ambient Life Stage H activity subsystem baseline (canonical int-based semantics).
// Canonical activity IDs and metadata are sourced from PycukSystems activity table.

#include "al_acts_inc"

// Backward-compatible aliases used by existing Stage D/E/F code paths.
const int AL_ACTIVITY_HIDDEN = AL_ACT_NPC_HIDDEN;
const int AL_ACTIVITY_ACT_ONE = AL_ACT_NPC_ACT_ONE;
const int AL_ACTIVITY_DINNER = AL_ACT_NPC_DINNER;
const int AL_ACTIVITY_AGREE = AL_ACT_NPC_AGREE;
const int AL_ACTIVITY_ANGRY = AL_ACT_NPC_ANGRY;
const int AL_ACTIVITY_READ = AL_ACT_NPC_READ;
const int AL_ACTIVITY_SIT = AL_ACT_NPC_SIT;
const int AL_ACTIVITY_STAND_CHAT = AL_ACT_NPC_STAND_CHAT;
const int AL_ACTIVITY_CHEER = AL_ACT_NPC_CHEER;
const int AL_ACTIVITY_KNEEL_TALK = AL_ACT_NPC_KNEEL_TALK;
const int AL_ACTIVITY_GUARD = AL_ACT_NPC_GUARD;

// Sleep-related IDs remain outside ordinary activity subsystem execution.
const int AL_ACTIVITY_MIDNIGHT_BED = AL_ACT_NPC_MIDNIGHT_BED;
const int AL_ACTIVITY_SLEEP_BED = AL_ACT_NPC_SLEEP_BED;
const int AL_ACTIVITY_MIDNIGHT_90 = AL_ACT_NPC_MIDNIGHT_90;
const int AL_ACTIVITY_SLEEP_90 = AL_ACT_NPC_SLEEP_90;

const int AL_ACTIVITY_IDLE = AL_ACT_NPC_HIDDEN;
const int AL_ACTIVITY_STAND = AL_ACT_NPC_STAND_CHAT;

const int AL_ACTIVITY_BEHAVIOR_IDLE_WAIT = 0;
const int AL_ACTIVITY_BEHAVIOR_SIT_WAIT = 1;
const int AL_ACTIVITY_BEHAVIOR_GUARD_WAIT = 2;
const int AL_ACTIVITY_BEHAVIOR_SOCIAL_WAIT = 3;
const int AL_ACTIVITY_BEHAVIOR_WORK_WAIT = 4;

string AL_TrimToken(string sToken)
{
    int nStart = 0;
    int nLen = GetStringLength(sToken);

    while (nStart < nLen && (GetSubString(sToken, nStart, 1) == " " || GetSubString(sToken, nStart, 1) == "\t"))
    {
        nStart = nStart + 1;
    }

    int nEnd = nLen - 1;
    while (nEnd >= nStart && (GetSubString(sToken, nEnd, 1) == " " || GetSubString(sToken, nEnd, 1) == "\t"))
    {
        nEnd = nEnd - 1;
    }

    if (nEnd < nStart)
    {
        return "";
    }

    return GetSubString(sToken, nStart, nEnd - nStart + 1);
}

string AL_SelectRandomToken(string sCsv)
{
    string sList = sCsv;
    int nCount = 0;

    while (sList != "")
    {
        int nComma = FindSubString(sList, ",");
        string sToken = sList;
        if (nComma >= 0)
        {
            sToken = GetSubString(sList, 0, nComma);
        }
        sToken = AL_TrimToken(sToken);
        if (sToken != "")
        {
            nCount = nCount + 1;
        }

        if (nComma < 0)
        {
            break;
        }

        sList = GetSubString(sList, nComma + 1, GetStringLength(sList) - nComma - 1);
    }

    if (nCount <= 0)
    {
        return "";
    }

    int nPick = Random(nCount);
    sList = sCsv;
    int nIdx = 0;

    while (sList != "")
    {
        int nComma = FindSubString(sList, ",");
        string sToken = sList;
        if (nComma >= 0)
        {
            sToken = GetSubString(sList, 0, nComma);
        }
        sToken = AL_TrimToken(sToken);
        if (sToken != "")
        {
            if (nIdx == nPick)
            {
                return sToken;
            }

            nIdx = nIdx + 1;
        }

        if (nComma < 0)
        {
            break;
        }

        sList = GetSubString(sList, nComma + 1, GetStringLength(sList) - nComma - 1);
    }

    return "";
}

int AL_ShouldLoopCustomAnimation(int nActivity, string sAnimToken)
{
    if (nActivity == AL_ACT_NPC_MIDNIGHT_BED || nActivity == AL_ACT_NPC_SLEEP_BED || nActivity == AL_ACT_NPC_MIDNIGHT_90 || nActivity == AL_ACT_NPC_SLEEP_90)
    {
        return TRUE;
    }

    string sToken = AL_TrimToken(sAnimToken);
    if (sToken == "" || FindSubString(sToken, "dance") >= 0)
    {
        return TRUE;
    }

    return FALSE;
}

int AL_PlayCustomAnimation(object oNpc, int nActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sToken = AL_SelectRandomToken(AL_GetActivityCustomAnims(nActivity));
    if (sToken == "")
    {
        return FALSE;
    }

    int bLoop = AL_ShouldLoopCustomAnimation(nActivity, sToken);

    // Real engine custom-token playback.
    string sChunk = "PlayCustomAnimation(OBJECT_SELF, \"" + sToken + "\", " + IntToString(bLoop) + ");";
    AssignCommand(oNpc, ExecuteScriptChunk(sChunk));
    AssignCommand(oNpc, ActionWait(IntToFloat(nDurSec)));

    // Preserve the selected token for metadata/debug and higher-level behavior tracking.
    SetLocalString(oNpc, "al_activity_custom_anim", sToken);
    SetLocalInt(oNpc, "al_activity_custom_loop", bLoop);
    SetLocalString(oNpc, "al_mode", "custom:" + sToken);

    return TRUE;
}

int AL_PlayNumericAnimation(object oNpc, int nActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    string sToken = AL_SelectRandomToken(AL_GetActivityNumericAnims(nActivity));
    if (sToken == "")
    {
        return FALSE;
    }

    int nAnim = StringToInt(sToken);
    if (nAnim <= 0)
    {
        return FALSE;
    }

    AssignCommand(oNpc, ActionPlayAnimation(nAnim, FALSE, 1.0));
    AssignCommand(oNpc, ActionWait(IntToFloat(nDurSec)));

    SetLocalInt(oNpc, "al_activity_numeric_anim", nAnim);
    SetLocalString(oNpc, "al_mode", "numeric:" + IntToString(nAnim));
    return TRUE;
}

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

    int nSlotLocal = GetLocalInt(oNpc, "al_slot_activity");
    if (nSlotLocal > AL_ACTIVITY_HIDDEN)
    {
        return nSlotLocal;
    }

    int nDefault = GetLocalInt(oNpc, "al_default_activity");
    if (nDefault > AL_ACTIVITY_HIDDEN)
    {
        return nDefault;
    }

    object oArea = GetArea(oNpc);
    int nAreaDefault = AL_ACTIVITY_HIDDEN;
    if (GetIsObjectValid(oArea))
    {
        nAreaDefault = GetLocalInt(oArea, "al_default_activity");
    }
    if (nAreaDefault > AL_ACTIVITY_HIDDEN)
    {
        return nAreaDefault;
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

int AL_ActivityQueueOrdinary(object oNpc, int nActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
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
    return TRUE;
}

void AL_ActivityApplyStep(object oNpc, int nStepActivity, int nDurSec)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    if (nDurSec <= 0)
    {
        nDurSec = 6;
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

    // 1) Prefer custom animation tokens when available.
    if (AL_PlayCustomAnimation(oNpc, nActivity, nDurSec))
    {
        SetLocalInt(oNpc, "al_activity_current", nActivity);
        return;
    }

    // 2) Fallback to numeric animation table.
    if (AL_PlayNumericAnimation(oNpc, nActivity, nDurSec))
    {
        SetLocalInt(oNpc, "al_activity_current", nActivity);
        return;
    }

    // 3) Run ordinary queued behavior for the resolved activity.
    if (AL_ActivityQueueOrdinary(oNpc, nActivity, nDurSec))
    {
        return;
    }

    // 4) Last resort: mark idle.
    AL_ActivityApplyIdleFallback(oNpc);
}

void AL_ActivityApplyBaseline(object oNpc, int nActivity, int nDurSec)
{
    AL_ActivityApplyStep(oNpc, nActivity, nDurSec);
}
