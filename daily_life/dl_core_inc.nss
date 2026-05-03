#include "dl_compile_order_inc"
#include "dl_res_inc"
#include "dl_compile_body_inc"
#include "dl_transition_engine_inc"
#include "dl_config_inc"
#include "dl_registry_inc"
#include "dl_resync_inc"
#include "dl_worker_inc"
#include "dl_city_response_inc"
#include "dl_legal_inc"
#include "dl_cr_crime_inc"

object DL_GetDialogPlayer(int bRequireRuntimePlayer = TRUE)
{
    object oPc = GetPCSpeaker();
    if (!GetIsObjectValid(oPc))
    {
        oPc = GetLastSpeaker();
    }

    if (bRequireRuntimePlayer && !DL_IsRuntimePlayer(oPc))
    {
        return OBJECT_INVALID;
    }

    return oPc;
}

