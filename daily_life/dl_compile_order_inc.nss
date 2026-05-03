// Minimal compile-order declarations only.
// Keep this include small: no constants, no default args, no function bodies.

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

string DL_LegacyAdapterResolveExitTagFromKindId(string sKind, string sTransitionId);
object DL_LegacyAdapterResolveGlobalTransitionWaypointByTag(string sResolvedTag);
int DL_LegacyAdapterIsTransitionDriverTypeMatch(string sDriverKind, object oDriver);
int DL_ParseAutoNavTag(string sTag, string sFromLocal, string sToLocal);
int DL_IsTransitionNavigableTarget(object oNpc, object oTarget);
