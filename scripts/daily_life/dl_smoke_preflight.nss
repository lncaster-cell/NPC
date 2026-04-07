#include "dl_all_inc"

int DL_IsInRange(int nValue, int nMin, int nMax)
{
    return nValue >= nMin && nValue <= nMax;
}

void DL_LogContractIssue(object oNpc, string sField, int nValue, string sExpectation)
{
    string sTag = GetTag(oNpc);
    DL_Log(
        DL_DEBUG_BASIC,
        "Preflight contract issue npc=" + sTag +
        " field=" + sField +
        " value=" + IntToString(nValue) +
        " expected=" + sExpectation
    );
}

void main()
{
    object oModule = GetModule();
    object oArea = GetFirstArea();
    int nAreaCount = 0;
    int nHotAreas = 0;
    int nDlNpcCount = 0;
    int nErrorCount = 0;
    int nWarningCount = 0;

    while (GetIsObjectValid(oArea))
    {
        int nTier = DL_GetAreaTier(oArea);
        nAreaCount += 1;
        if (nTier == DL_AREA_HOT) nHotAreas += 1;

        if (!DL_IsInRange(nTier, DL_AREA_FROZEN, DL_AREA_HOT))
        {
            DL_Log(
                DL_DEBUG_BASIC,
                "Preflight area tier issue area=" + GetTag(oArea) +
                " tier=" + IntToString(nTier) +
                " expected=0..2"
            );
            nErrorCount += 1;
        }

        object oNpc = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oNpc))
        {
            if (GetObjectType(oNpc) == OBJECT_TYPE_CREATURE && !GetIsPC(oNpc) && DL_IsDailyLifeNpc(oNpc))
            {
                int nFamily = DL_GetNpcFamily(oNpc);
                int nSubtype = DL_GetNpcSubtype(oNpc);
                int nSchedule = DL_GetScheduleTemplate(oNpc);
                int nBase = DL_GetNpcBaseKind(oNpc);
                int bNamed = GetLocalInt(oNpc, DL_L_NAMED);
                int bPersistent = GetLocalInt(oNpc, DL_L_PERSISTENT);

                nDlNpcCount += 1;

                if (!DL_IsInRange(nFamily, DL_FAMILY_LAW, DL_FAMILY_CLERGY))
                {
                    DL_LogContractIssue(oNpc, DL_L_NPC_FAMILY, nFamily, "1..6");
                    nErrorCount += 1;
                }
                if (!DL_IsInRange(nSubtype, DL_SUBTYPE_PATROL, DL_SUBTYPE_PRIEST))
                {
                    DL_LogContractIssue(oNpc, DL_L_NPC_SUBTYPE, nSubtype, "1..16");
                    nErrorCount += 1;
                }
                if (!DL_IsInRange(nSchedule, DL_SCH_EARLY_WORKER, DL_SCH_CIVILIAN_HOME))
                {
                    DL_LogContractIssue(oNpc, DL_L_SCHEDULE_TEMPLATE, nSchedule, "1..7");
                    nErrorCount += 1;
                }
                if (!DL_IsInRange(nBase, DL_BASE_HOME, DL_BASE_OFFICE))
                {
                    DL_LogContractIssue(oNpc, DL_L_NPC_BASE, nBase, "1..7");
                    nErrorCount += 1;
                }

                if (!bNamed && !bPersistent)
                {
                    DL_Log(
                        DL_DEBUG_BASIC,
                        "Preflight warning npc=" + GetTag(oNpc) +
                        " lacks worker guarantee flags (dl_named or dl_persistent)"
                    );
                    nWarningCount += 1;
                }
            }
            oNpc = GetNextObjectInArea(oArea);
        }

        oArea = GetNextArea();
    }

    if (GetLocalInt(oModule, DL_L_SMOKE_TRACE) == FALSE)
    {
        DL_Log(DL_DEBUG_BASIC, "Preflight warning module local dl_smoke_trace is FALSE; smoke logs will be reduced.");
        nWarningCount += 1;
    }

    if (nAreaCount == 0)
    {
        DL_Log(DL_DEBUG_BASIC, "Preflight error no areas found in module.");
        nErrorCount += 1;
    }

    if (nDlNpcCount == 0)
    {
        DL_Log(DL_DEBUG_BASIC, "Preflight error no Daily Life NPC found in any area.");
        nErrorCount += 1;
    }

    if (nHotAreas == 0)
    {
        DL_Log(DL_DEBUG_BASIC, "Preflight error no HOT area found (dl_area_tier=2 required for full smoke).");
        nErrorCount += 1;
    }

    DL_Log(
        DL_DEBUG_BASIC,
        "Preflight summary areas=" + IntToString(nAreaCount) +
        " hot_areas=" + IntToString(nHotAreas) +
        " dl_npc=" + IntToString(nDlNpcCount) +
        " warnings=" + IntToString(nWarningCount) +
        " errors=" + IntToString(nErrorCount)
    );

    if (nErrorCount == 0)
    {
        DL_Log(DL_DEBUG_BASIC, "Preflight status=PASS (runtime contour ready for smoke/compile cycle)");
    }
    else
    {
        DL_Log(DL_DEBUG_BASIC, "Preflight status=FAIL (fix contract issues before smoke/compile cycle)");
    }
}
