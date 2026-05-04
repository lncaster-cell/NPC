// Debug helper: attach to a placeable OnUsed event.
// Shows current module time and nearest Daily Life NPC runtime state.
// Intended for builder/runtime smoke tests only.

#include "dl_runtime_contract_inc"

const float DL_DBG_NPC_SCAN_RADIUS = 30.0;

string DL_DbgPad2(int nValue)
{
    if (nValue < 0)
    {
        nValue = 0;
    }
    if (nValue < 10)
    {
        return "0" + IntToString(nValue);
    }
    return IntToString(nValue);
}

string DL_DbgDirectiveLabel(int nDirective)
{
    if (nDirective == DL_DIR_SLEEP)
    {
        return "SLEEP";
    }
    if (nDirective == DL_DIR_WORK)
    {
        return "WORK";
    }
    if (nDirective == DL_DIR_SOCIAL)
    {
        return "SOCIAL";
    }
    if (nDirective == DL_DIR_MEAL)
    {
        return "MEAL";
    }
    if (nDirective == DL_DIR_PUBLIC)
    {
        return "PUBLIC";
    }
    if (nDirective == DL_DIR_CHILL)
    {
        return "CHILL";
    }
    return "NONE";
}

object DL_DbgFindNearestDailyLifeNpc(object oUser)
{
    if (!GetIsObjectValid(oUser))
    {
        return OBJECT_INVALID;
    }

    object oArea = GetArea(oUser);
    if (!GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oBest = OBJECT_INVALID;
    float fBestDistance = DL_DBG_NPC_SCAN_RADIUS + 1.0;
    object oCandidate = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oCandidate))
    {
        if (DL_IsPipelineNpc(oCandidate) && GetLocalString(oCandidate, DL_L_NPC_PROFILE_ID) != "")
        {
            float fDistance = GetDistanceBetween(oUser, oCandidate);
            if (fDistance <= DL_DBG_NPC_SCAN_RADIUS && fDistance < fBestDistance)
            {
                oBest = oCandidate;
                fBestDistance = fDistance;
            }
        }

        oCandidate = GetNextObjectInArea(oArea);
    }

    return oBest;
}

void DL_DbgSay(object oPC, string sText)
{
    SendMessageToPC(oPC, sText);
    FloatingTextStringOnCreature(sText, oPC, FALSE);
}

void main()
{
    object oPC = GetLastUsedBy();
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC))
    {
        oPC = GetFirstPC();
    }

    if (!GetIsObjectValid(oPC))
    {
        return;
    }

    string sTime = "[DL DEBUG] time=" + DL_DbgPad2(GetTimeHour()) + ":" + DL_DbgPad2(GetTimeMinute()) + ":" + DL_DbgPad2(GetTimeSecond()) +
                   " date=" + IntToString(GetCalendarYear()) + "/" + IntToString(GetCalendarMonth()) + "/" + IntToString(GetCalendarDay());
    DL_DbgSay(oPC, sTime);

    object oNpc = DL_DbgFindNearestDailyLifeNpc(oPC);
    if (!GetIsObjectValid(oNpc))
    {
        DL_DbgSay(oPC, "[DL DEBUG] nearest_npc=NONE within " + FloatToString(DL_DBG_NPC_SCAN_RADIUS, 1, 1) + "m");
        return;
    }

    int nNowDirective = DL_ResolveNpcDirective(oNpc);
    int nStoredDirective = GetLocalInt(oNpc, DL_L_NPC_DIRECTIVE);

    string sNpc = "[DL DEBUG] npc=" + GetName(oNpc) +
                  " tag=" + GetTag(oNpc) +
                  " profile=" + GetLocalString(oNpc, DL_L_NPC_PROFILE_ID) +
                  " dist=" + FloatToString(GetDistanceBetween(oPC, oNpc), 1, 1);
    DL_DbgSay(oPC, sNpc);

    string sDirective = "[DL DEBUG] now_dir=" + DL_DbgDirectiveLabel(nNowDirective) +
                        " stored_dir=" + DL_DbgDirectiveLabel(nStoredDirective) +
                        " state=" + GetLocalString(oNpc, DL_L_NPC_STATE) +
                        " problem=" + DL_GetNpcProblemSummary(oNpc);
    DL_DbgSay(oPC, sDirective);

    string sSleep = "[DL DEBUG] sleep_status=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_STATUS) +
                    " sleep_target=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_TARGET) +
                    " sleep_diag=" + GetLocalString(oNpc, DL_L_NPC_SLEEP_DIAGNOSTIC);
    DL_DbgSay(oPC, sSleep);

    string sWork = "[DL DEBUG] work_status=" + GetLocalString(oNpc, DL_L_NPC_WORK_STATUS) +
                   " work_target=" + GetLocalString(oNpc, DL_L_NPC_WORK_TARGET) +
                   " work_diag=" + GetLocalString(oNpc, DL_L_NPC_WORK_DIAGNOSTIC);
    DL_DbgSay(oPC, sWork);

    string sFocus = "[DL DEBUG] focus_status=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) +
                    " focus_target=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) +
                    " focus_diag=" + GetLocalString(oNpc, DL_L_NPC_FOCUS_DIAGNOSTIC);
    DL_DbgSay(oPC, sFocus);

    string sTransition = "[DL DEBUG] transition_status=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_STATUS) +
                         " transition_target=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_TARGET) +
                         " transition_diag=" + GetLocalString(oNpc, DL_L_NPC_TRANSITION_DIAGNOSTIC);
    DL_DbgSay(oPC, sTransition);
}
