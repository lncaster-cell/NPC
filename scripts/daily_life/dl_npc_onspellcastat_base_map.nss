#include "dl_all_base_map_inc"

void main()
{
    if (DL_ShouldEmitSpellEvent(OBJECT_SELF))
    {
        DL_SignalNpcUserDefined(OBJECT_SELF, DL_UD_SPELL_CAST_AT);
    }
}
