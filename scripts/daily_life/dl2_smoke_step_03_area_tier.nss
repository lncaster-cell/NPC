// Daily Life v2 smoke Step 03.
// Verifies area tier helpers and area runtime activation.

#include "dl_v2_area_inc"

void DL2_EnableSmokeTraceForAreaTest()
{
    object oModule = GetModule();
    SetLocalInt(oModule, DL2_L_MODULE_LOG_ENABLED, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_SMOKE_TRACE, TRUE);
    SetLocalInt(oModule, DL2_L_MODULE_LOG_LEVEL, DL2_LOG_LEVEL_DEBUG);
}

void main()
{
    object oArea = GetArea(GetFirstPC());
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    DL2_EnableSmokeTraceForAreaTest();

    DeleteLocalInt(oArea, DL2_L_AREA_TIER);
    DeleteLocalInt(oArea, DL2_L_AREA_WORKER_BUDGET);
    DeleteLocalInt(oArea, DL2_L_AREA_WORKER_CURSOR);

    DL2_LogSmoke(
        "STEP03",
        "default_tier_frozen",
        DL2_AREA_TIER_FROZEN,
        DL2_GetAreaTier(oArea)
    );

    DL2_ActivateAreaOnPlayerEnter(oArea);

    DL2_LogSmoke(
        "STEP03",
        "activation_sets_hot",
        DL2_AREA_TIER_HOT,
        DL2_GetAreaTier(oArea)
    );

    DL2_LogSmoke(
        "STEP03",
        "area_budget_defaulted",
        DL2_DEFAULT_WORKER_BUDGET,
        GetLocalInt(oArea, DL2_L_AREA_WORKER_BUDGET)
    );

    SetLocalInt(oArea, DL2_L_AREA_TIER, 99);
    DL2_LogSmoke(
        "STEP03",
        "invalid_tier_coerced_on_read",
        DL2_AREA_TIER_FROZEN,
        DL2_GetAreaTier(oArea)
    );
}
