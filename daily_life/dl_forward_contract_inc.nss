// Compile-order forward declarations for Daily Life include graph.
// Declarations here must not conflict with concrete domain prototypes.

void DL_ExecuteSleepDirective(object oNpc);
void DL_ExecuteWorkDirective(object oNpc);
void DL_ExecuteMealDirective(object oNpc);
void DL_ExecuteSocialDirective(object oNpc);
void DL_ExecutePublicDirective(object oNpc);
void DL_ExecuteChillDirective(object oNpc);

void DL_ApplyDirectiveSkeleton(object oNpc, int nDirective);
void DL_ClearTransitionExecutionState(object oNpc);
void DL_RegisterNpc(object oNpc);
void DL_UnregisterNpc(object oNpc);
void DL_ReconcileNpcAreaRegistration(object oNpc);
void DL_RequestResync(object oNpc, int nReason);
void DL_ProcessResync(object oNpc);

object DL_FindObjectByTagInAreaDeterministic(string sTag, int nObjectType, object oArea, int nSearchCap);
