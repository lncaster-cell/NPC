#include "dl_core_inc"
#include "dl_blocked_inc"
#include "dl_ingress_orch_inc"

void main()
{
    DL_IngressOrchestrateBlockedSignal(OBJECT_SELF, GetBlockingDoor());
}
