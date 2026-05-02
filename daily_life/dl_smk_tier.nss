// Area tier bootstrap smoke.

#include "dl_core_inc"

void main()
{
    object oArea = OBJECT_SELF;
    if (!DL_IsAreaObject(oArea))
    {
        oArea = GetArea(GetFirstPC());
    }

    if (!DL_IsAreaObject(oArea))
    {
        return;
    }

    // Reset policy: area tier is explicit state; reset via canonical value, not key deletion.
    SetLocalInt(oArea, DL_L_AREA_TIER, DL_TIER_WARM);
    DL_BootstrapAreaTier(oArea);

    SetLocalInt(oArea, "dl_smk_tier_value", DL_GetAreaTier(oArea));
}
