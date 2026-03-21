#include "dl_log_inc"
#include "dl_resync_inc"

void main()
{
    DL_Log(DL_DEBUG_BASIC, "Daily Life load hook initialized");
    DL_RequestModuleResync(DL_RESYNC_SAVE_LOAD);
}
