// Canonical runtime-directive pipeline helpers.
// Pipeline steps for runtime directives:
// 1) Validate  2) Resolve  3) Prepare  4) Execute  5) Finalize

const string DL_PIPE_STEP_VALIDATE = "validate";
const string DL_PIPE_STEP_RESOLVE = "resolve";
const string DL_PIPE_STEP_PREPARE = "prepare";
const string DL_PIPE_STEP_EXECUTE = "execute";
const string DL_PIPE_STEP_FINALIZE = "finalize";

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
            DL_CommandMoveToObjectResetQueue(oActor, oTargetA, TRUE, 2.0);
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
        AssignCommand(oActor, ClearAllActions(TRUE));
    }
}
