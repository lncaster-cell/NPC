#ifndef DL_V2_IDLE_BASE_RESOLVER_INC_NSS
#define DL_V2_IDLE_BASE_RESOLVER_INC_NSS

#include "dl_v2_work_resolver_inc"

// Minimal IDLE_BASE fallback slice.
// Acts as the current neutral fallback after SLEEP and WORK.
// New conditions can later be inserted before this fallback without breaking the layer order.

const int DL2_DIRECTIVE_IDLE_BASE = 3;

int DL2_ResolveDirectiveIdleBaseFallback()
{
    return DL2_DIRECTIVE_IDLE_BASE;
}

int DL2_ResolveDirectiveForEarlyWorkerBasicWithIdleBase(int nHour)
{
    int nDirective = DL2_ResolveDirectiveForEarlyWorkerBasic(nHour);
    if (nDirective != DL2_DIRECTIVE_UNASSIGNED)
    {
        return nDirective;
    }

    return DL2_ResolveDirectiveIdleBaseFallback();
}

string DL2_GetExtendedDirectiveName(int nDirective)
{
    if (nDirective == DL2_DIRECTIVE_IDLE_BASE)
    {
        return "IDLE_BASE";
    }

    return DL2_GetBasicDirectiveName(nDirective);
}

#endif
