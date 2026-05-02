#include "dl_core_inc"
#include "dl_ingress_orch_inc"

void main()
{
    DL_IngressOrchestrateLifecycleSignal(OBJECT_SELF, DL_NPC_EVENT_DEATH, "DEATH_SIGNAL");
}
