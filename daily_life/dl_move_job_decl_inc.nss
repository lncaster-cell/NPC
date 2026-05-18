// Declaration-only include for the canonical Daily Life movement job helpers.
void DL_BeginMoveJob(object oNpc, string sOwner, string sPhase, string sTargetTag, float fRadius);
void DL_BeginMoveJobToObject(object oNpc, string sOwner, string sPhase, object oTarget, float fRadius);
void DL_ClearMoveJob(object oNpc);
int DL_TickMoveJob(object oNpc);
int DL_ForceReachMoveJobIfAlreadyAtTarget(object oNpc);
int DL_IsMoveJobAtTargetNow(object oNpc);
int DL_IsMoveJobReached(object oNpc);
string DL_GetMoveJobResult(object oNpc);
