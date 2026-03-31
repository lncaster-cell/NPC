#include "dl_const_inc"
#include "dl_log_inc"
#include "dl_types_inc"
#include "dl_override_inc"
#include "dl_resync_inc"
#include "dl_worker_inc"

string DL_SmokePassLabel(int bPass)
{
    if (bPass)
    {
        return "PASS";
    }
    return "FAIL";
}

void DL_LogScenarioResult(string sScenario, int bFound, int bPass, string sDetail)
{
    string sStatus;

    if (!bFound)
    {
        sStatus = "NOT_FOUND";
    }
    else
    {
        sStatus = DL_SmokePassLabel(bPass);
    }

    DL_Log(
        DL_DEBUG_BASIC,
        "MilestoneA smoke " + sScenario + " status=" + sStatus + " detail=" + sDetail);
}

int DL_IsScenarioAExpected(object oNPC)
{
    int nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);
    int nDialogue = GetLocalInt(oNPC, DL_L_DIALOGUE_MODE);
    int nService = GetLocalInt(oNPC, DL_L_SERVICE_MODE);

    return nDirective == DL_DIR_WORK
        && nDialogue == DL_DLG_WORK
        && (nService == DL_SERVICE_LIMITED || nService == DL_SERVICE_AVAILABLE);
}

int DL_IsScenarioBExpected(object oNPC)
{
    int nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);
    int nDialogue = GetLocalInt(oNPC, DL_L_DIALOGUE_MODE);
    int nService = GetLocalInt(oNPC, DL_L_SERVICE_MODE);

    return nDirective != DL_DIR_WORK
        && nDialogue != DL_DLG_WORK
        && nService != DL_SERVICE_AVAILABLE;
}

int DL_IsScenarioCExpected(object oNPC)
{
    int nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);
    int nDialogue = GetLocalInt(oNPC, DL_L_DIALOGUE_MODE);

    return (nDirective == DL_DIR_DUTY || nDirective == DL_DIR_HOLD_POST)
        && (nDialogue == DL_DLG_INSPECTION || nDialogue == DL_DLG_OFF_DUTY || nDialogue == DL_DLG_WORK);
}

int DL_IsScenarioDExpected(object oNPC)
{
    int nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);
    int nDialogue = GetLocalInt(oNPC, DL_L_DIALOGUE_MODE);
    int nService = GetLocalInt(oNPC, DL_L_SERVICE_MODE);

    return (nDirective == DL_DIR_SERVICE || nDirective == DL_DIR_SOCIAL)
        && (nDialogue == DL_DLG_WORK || nDialogue == DL_DLG_OFF_DUTY)
        && (nService == DL_SERVICE_AVAILABLE || nService == DL_SERVICE_DISABLED);
}

int DL_IsScenarioEExpected(object oNPC, object oArea)
{
    int nOverride = DL_GetTopOverride(oNPC, oArea);
    int nFamily = DL_GetNpcFamily(oNPC);
    int nDirective = GetLocalInt(oNPC, DL_L_DIRECTIVE);

    if (nOverride != DL_OVR_QUARANTINE)
    {
        return FALSE;
    }

    if (nFamily == DL_FAMILY_LAW)
    {
        return nDirective == DL_DIR_DUTY || nDirective == DL_DIR_HOLD_POST;
    }
    return nDirective == DL_DIR_LOCKDOWN_BASE;
}

void DL_RunScenarioProfileChecks()
{
    object oArea = GetFirstArea();
    object oObject;
    int bFoundA = FALSE;
    int bFoundB = FALSE;
    int bFoundC = FALSE;
    int bFoundD = FALSE;
    int bFoundE = FALSE;
    int bPassA = FALSE;
    int bPassB = FALSE;
    int bPassC = FALSE;
    int bPassD = FALSE;
    int bPassE = FALSE;

    while (GetIsObjectValid(oArea))
    {
        oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject) && DL_IsDailyLifeNpc(oObject))
            {
                DL_RunForcedResync(oObject, oArea, DL_RESYNC_WORKER);

                if (DL_GetNpcFamily(oObject) == DL_FAMILY_CRAFT && DL_GetNpcSubtype(oObject) == DL_SUBTYPE_BLACKSMITH)
                {
                    bFoundA = TRUE;
                    bFoundB = TRUE;

                    if (DL_IsScenarioAExpected(oObject))
                    {
                        bPassA = TRUE;
                    }

                    if (DL_IsScenarioBExpected(oObject))
                    {
                        bPassB = TRUE;
                    }
                }

                if (DL_GetNpcFamily(oObject) == DL_FAMILY_LAW && DL_GetNpcSubtype(oObject) == DL_SUBTYPE_GATE_POST)
                {
                    bFoundC = TRUE;
                    if (DL_IsScenarioCExpected(oObject))
                    {
                        bPassC = TRUE;
                    }
                }

                if (DL_GetNpcFamily(oObject) == DL_FAMILY_TRADE_SERVICE && DL_GetNpcSubtype(oObject) == DL_SUBTYPE_INNKEEPER)
                {
                    bFoundD = TRUE;
                    if (DL_IsScenarioDExpected(oObject))
                    {
                        bPassD = TRUE;
                    }
                }

                if (DL_GetTopOverride(oObject, oArea) == DL_OVR_QUARANTINE)
                {
                    bFoundE = TRUE;
                    if (DL_IsScenarioEExpected(oObject, oArea))
                    {
                        bPassE = TRUE;
                    }
                }
            }
            oObject = GetNextObjectInArea(oArea);
        }
        oArea = GetNextArea();
    }

    DL_LogScenarioResult("A", bFoundA, bPassA, "blacksmith work profile");
    DL_LogScenarioResult("B", bFoundB, bPassB, "blacksmith non-work profile");
    DL_LogScenarioResult("C", bFoundC, bPassC, "gate duty profile");
    DL_LogScenarioResult("D", bFoundD, bPassD, "innkeeper late profile");
    DL_LogScenarioResult("E", bFoundE, bPassE, "quarantine override profile");
}

void DL_RunScenarioFGChecks()
{
    object oArea = GetFirstArea();
    object oProbeNpc = OBJECT_INVALID;
    object oProbeArea = OBJECT_INVALID;
    int bFoundHot = FALSE;
    int bFoundWarm = FALSE;
    int bFoundFrozen = FALSE;
    int bBudgetShape = FALSE;
    int bGateShape = FALSE;

    if (DL_GetDefaultAreaTierBudget(DL_AREA_HOT) > DL_GetDefaultAreaTierBudget(DL_AREA_WARM)
        && DL_GetDefaultAreaTierBudget(DL_AREA_WARM) > DL_GetDefaultAreaTierBudget(DL_AREA_FROZEN))
    {
        bBudgetShape = TRUE;
    }

    while (GetIsObjectValid(oArea))
    {
        int nTier = DL_GetAreaTier(oArea);
        object oObject = GetFirstObjectInArea(oArea);

        if (nTier == DL_AREA_HOT)
        {
            bFoundHot = TRUE;
        }
        else if (nTier == DL_AREA_WARM)
        {
            bFoundWarm = TRUE;
        }
        else if (nTier == DL_AREA_FROZEN)
        {
            bFoundFrozen = TRUE;
        }

        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject) && DL_IsDailyLifeNpc(oObject))
            {
                oProbeNpc = oObject;
                oProbeArea = oArea;
                break;
            }
            oObject = GetNextObjectInArea(oArea);
        }

        if (GetIsObjectValid(oProbeNpc))
        {
            break;
        }
        oArea = GetNextArea();
    }

    if (GetIsObjectValid(oProbeNpc))
    {
        DL_RunForcedResync(oProbeNpc, oProbeArea, DL_RESYNC_AREA_ENTER);
        DL_LogScenarioResult(
            "F",
            TRUE,
            GetLocalInt(oProbeNpc, DL_L_DIRECTIVE) != DL_DIR_NONE,
            "area enter forced resync on first available DL NPC");
    }
    else
    {
        DL_LogScenarioResult("F", FALSE, FALSE, "no DL NPC found for area-enter probe");
    }

    {
        int bHotRuns = DL_ShouldRunDailyLifeTier(DL_AREA_HOT);
        int bWarmRuns = DL_ShouldRunDailyLifeTier(DL_AREA_WARM);
        int bFrozenRuns = DL_ShouldRunDailyLifeTier(DL_AREA_FROZEN);
        bGateShape = bHotRuns && bWarmRuns && !bFrozenRuns;
    }

    DL_LogScenarioResult(
        "G",
        bFoundHot || bFoundWarm || bFoundFrozen,
        bFoundHot && bFoundWarm && bFoundFrozen && bBudgetShape && bGateShape,
        "tier presence + budget ordering + gate hot/warm run, frozen stop");
}

void main()
{
    DL_RunScenarioProfileChecks();
    DL_RunScenarioFGChecks();
}
