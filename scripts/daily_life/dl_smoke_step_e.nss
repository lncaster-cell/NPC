#include "dl_const_inc"
#include "dl_log_inc"
#include "dl_types_inc"
#include "dl_resync_inc"

string DL_SmokeDescribeDirective(int nDirective)
{
    if (nDirective == DL_DIR_ABSENT) return "ABSENT";
    if (nDirective == DL_DIR_UNASSIGNED) return "UNASSIGNED";
    return "OTHER";
}

void DL_RunStepEBaseLostProbe()
{
    object oArea = GetFirstArea();
    object oObject;
    object oModule = GetModule();
    int nChecked = 0;
    int nAbsent = 0;
    int nUnassigned = 0;

    while (GetIsObjectValid(oArea))
    {
        oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE
                && !GetIsPC(oObject)
                && DL_IsDailyLifeNpc(oObject)
                && !DL_HasBase(oObject))
            {
                DL_RunForcedResync(oObject, oArea, DL_RESYNC_BASE_LOST);
                nChecked += 1;

                if (GetLocalInt(oObject, DL_L_DIRECTIVE) == DL_DIR_ABSENT)
                {
                    nAbsent += 1;
                }
                else if (GetLocalInt(oObject, DL_L_DIRECTIVE) == DL_DIR_UNASSIGNED)
                {
                    nUnassigned += 1;
                }
            }
            oObject = GetNextObjectInArea(oArea);
        }
        oArea = GetNextArea();
    }

    DL_Log(
        DL_DEBUG_BASIC,
        "StepE smoke probe: checked="
            + IntToString(nChecked)
            + " absent=" + IntToString(nAbsent)
            + " unassigned=" + IntToString(nUnassigned)
            + " last_kind=" + DL_SmokeDescribeDirective(GetLocalInt(oModule, DL_L_LAST_BASE_LOST_KIND))
            + " last_slot=" + GetLocalString(oModule, DL_L_LAST_BASE_LOST_SLOT));
}

void main()
{
    DL_RunStepEBaseLostProbe();
}
