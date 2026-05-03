// Canonical runtime-directive pipeline helpers.
// Pipeline steps for runtime directives:
// 1) Validate  2) Resolve  3) Prepare  4) Execute  5) Finalize

string DL_PIPE_STEP_VALIDATE = "validate";
string DL_PIPE_STEP_RESOLVE = "resolve";
string DL_PIPE_STEP_PREPARE = "prepare";
string DL_PIPE_STEP_EXECUTE = "execute";
string DL_PIPE_STEP_FINALIZE = "finalize";

// Forward declarations for helpers defined by downstream include units.
// NWScript requires declarations before first call in the textual include graph.
void DL_ExecuteSleepDirective(object oNpc);
void DL_ExecuteWorkDirective(object oNpc);
void DL_ExecuteMealDirective(object oNpc);
void DL_ExecuteSocialDirective(object oNpc);
void DL_ExecutePublicDirective(object oNpc);
void DL_ExecuteChillDirective(object oNpc);
string DL_SelectionBuildTieKey(object oPrimary, object oSecondary, int nOrdinal);
int DL_SelectionCompare(int nCandidateScore, int nBestScore, string sCandidateTieKey, string sBestTieKey);

void DL_PipelineUpdateStatus(object oActor, string sStatusLocal, string sStatus)
{
    if (!GetIsObjectValid(oActor) || sStatusLocal == "")
    {
        return;
    }

    if (sStatus == "")
    {
        DeleteLocalString(oActor, sStatusLocal);
        return;
    }

    SetLocalString(oActor, sStatusLocal, sStatus);
}

void DL_PipelineUpdateDiagnostic(object oActor, string sDiagLocal, string sDiagnostic)
{
    if (!GetIsObjectValid(oActor) || sDiagLocal == "")
    {
        return;
    }

    if (sDiagnostic == "")
    {
        DeleteLocalString(oActor, sDiagLocal);
        return;
    }

    SetLocalString(oActor, sDiagLocal, sDiagnostic);
}

void DL_PipelineDispatchCommand(object oActor, int nCommandKind, object oTargetA, object oTargetB)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    if (nCommandKind == 1)
    {
        if (GetIsObjectValid(oTargetA))
        {
            DL_CommandAttackResetQueue(oActor, oTargetA);
        }
        return;
    }

    if (nCommandKind == 2)
    {
        if (GetIsObjectValid(oTargetA))
        {
            DL_CommandMoveToObject(oActor, oTargetA, TRUE, 2.0);
        }
        return;
    }

    if (nCommandKind == 3)
    {
        if (GetIsObjectValid(oTargetA))
        {
            DL_CommandJumpToLocationResetQueue(oActor, GetLocation(oTargetA));
        }
        return;
    }

    if (nCommandKind == 4)
    {
        DL_TryResetActionQueue(oActor, TRUE, DL_RESET_REASON_BLOCKED);
    }
}
