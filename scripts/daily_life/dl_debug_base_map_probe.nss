#include "dl_all_base_map_inc"

void DL_LogBaseMapProbeForNpc(object oNPC)
{
    object oBase = DL_GetNpcBase(oNPC);
    object oArea = GetArea(oNPC);
    int nDirective;
    int nAnchorGroup;
    object oTargetArea;
    string sConfiguredAnchorTag;
    object oConfiguredAnchor;
    object oResolvedAnchor;

    if (!GetIsObjectValid(oNPC) || !DL_IsDailyLifeNpc(oNPC))
    {
        return;
    }

    nDirective = DL_ResolveDirective(oNPC, oArea);
    nAnchorGroup = DL_ResolveAnchorGroup(oNPC, nDirective);
    oTargetArea = DL_ResolveBaseContextArea(oNPC, oArea, nDirective, nAnchorGroup);
    sConfiguredAnchorTag = DL_ResolveBaseContextAnchorTag(oNPC, nDirective, nAnchorGroup);
    oConfiguredAnchor = DL_FindConfiguredAnchorPoint(oNPC, oTargetArea, nDirective, nAnchorGroup);
    oResolvedAnchor = DL_FindConfiguredOrDerivedAnchorPoint(oNPC, oTargetArea, nDirective, nAnchorGroup);

    DL_Log(
        DL_DEBUG_BASIC,
        "BaseMap probe npc=" + GetTag(oNPC)
        + " base=" + GetTag(oBase)
        + " current_area=" + GetTag(oArea)
        + " directive=" + IntToString(nDirective)
        + " anchor_group=" + IntToString(nAnchorGroup)
        + " target_area=" + GetTag(oTargetArea)
        + " configured_anchor_tag=" + sConfiguredAnchorTag
        + " configured_anchor=" + GetTag(oConfiguredAnchor)
        + " resolved_anchor=" + GetTag(oResolvedAnchor)
    );
}

void main()
{
    object oArea = GetFirstArea();

    while (GetIsObjectValid(oArea))
    {
        object oObject = GetFirstObjectInArea(oArea);
        while (GetIsObjectValid(oObject))
        {
            if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && !GetIsPC(oObject) && DL_IsDailyLifeNpc(oObject))
            {
                DL_LogBaseMapProbeForNpc(oObject);
                return;
            }
            oObject = GetNextObjectInArea(oArea);
        }
        oArea = GetNextArea();
    }

    DL_Log(DL_DEBUG_BASIC, "BaseMap probe found no Daily Life NPC");
}
