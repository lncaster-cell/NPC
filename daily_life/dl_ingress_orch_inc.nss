// Canonical ingress orchestration helper.
// Base pipeline for each ingress:
// 1) validate,
// 2) normalize actor/context,
// 3) lifecycle sync,
// 4) state transition,
// 5) telemetry/diagnostic.
//
// Contract: every new ingress scenario must plug into DL_RunIngressPipeline(...)
// via stage hooks instead of duplicating the 5-stage flow by hand.

void DL_RequestNpcBlockedSignal(object oNpc, object oBlocker);

const int DL_INGRESS_STAGE_VALIDATE       = 1;
const int DL_INGRESS_STAGE_NORMALIZE      = 2;
const int DL_INGRESS_STAGE_LIFECYCLE_SYNC = 3;
const int DL_INGRESS_STAGE_STATE_TRANS    = 4;
const int DL_INGRESS_STAGE_TELEMETRY      = 5;

const int DL_INGRESS_KIND_LIFECYCLE = 1;
const int DL_INGRESS_KIND_BLOCKED   = 2;
const int DL_INGRESS_KIND_AREA      = 3;

int DL_IngressChecklistCanonicalStageCount()
{
    return 5;
}

int DL_IngressChecklistHasCanonicalPipeline()
{
    return DL_IngressChecklistCanonicalStageCount() == 5;
}

int DL_IngressValidateNpc(object oNpc, int bRequireActive, int bRequireRuntime)
{
    if (!DL_IsPipelineNpc(oNpc))
    {
        return FALSE;
    }

    if (bRequireActive && !DL_IsActivePipelineNpc(oNpc))
    {
        return FALSE;
    }

    if (bRequireRuntime && !DL_IsRuntimeEnabled())
    {
        return FALSE;
    }

    return TRUE;
}

int DL_RunIngressPipeline(
    int nIngressKind,
    object oPrimary,
    object oSecondary,
    int nEventKind,
    string sTelemetryTag,
    int bRequireNpc,
    int bRequireActiveNpc,
    int bRequireRuntime,
    int bRequireSecondaryValid,
    string sSecondaryInvalidDiagnostic,
    int bHandleDeathBeforeLifecycle,
    int bEmitTelemetry)
{
    if (bRequireNpc && !DL_IngressValidateNpc(oPrimary, bRequireActiveNpc, bRequireRuntime))
    {
        return FALSE;
    }

    if (!bRequireNpc && !GetIsObjectValid(oPrimary))
    {
        return FALSE;
    }

    if (bRequireSecondaryValid && !GetIsObjectValid(oSecondary))
    {
        if (GetIsObjectValid(oPrimary) && sSecondaryInvalidDiagnostic != "")
        {
            SetLocalString(oPrimary, DL_L_NPC_BLOCKED_DIAGNOSTIC, sSecondaryInvalidDiagnostic);
        }
        return FALSE;
    }

    object oActor = oPrimary;
    object oArea = OBJECT_INVALID;
    if (nIngressKind == DL_INGRESS_KIND_AREA)
    {
        oArea = oPrimary;
        oActor = oSecondary;
    }
    else
    {
        oArea = GetArea(oPrimary);
    }

    if (nIngressKind == DL_INGRESS_KIND_LIFECYCLE)
    {
        if (bHandleDeathBeforeLifecycle && nEventKind == DL_NPC_EVENT_DEATH)
        {
            DL_CR_HandleNpcKilled(oPrimary);
        }

        DL_RequestNpcLifecycleSignal(oPrimary, nEventKind);
    }

    if (nIngressKind == DL_INGRESS_KIND_BLOCKED)
    {
        DL_RequestNpcBlockedSignal(oPrimary, oSecondary);
    }
    else if (nIngressKind == DL_INGRESS_KIND_AREA)
    {
        DL_OnAreaEnterBootstrap(oArea, oActor);
    }

    if (bEmitTelemetry && DL_IsRuntimeLogEnabled())
    {
        if (nIngressKind == DL_INGRESS_KIND_LIFECYCLE)
        {
            string sLogLifecycle = "[DL][" + sTelemetryTag + "] npc=" + GetName(oPrimary) +
                                   " area=" + GetName(oArea) +
                                   " kind=" + IntToString(GetLocalInt(oPrimary, DL_L_NPC_EVENT_KIND)) +
                                   " seq=" + IntToString(GetLocalInt(oPrimary, DL_L_NPC_EVENT_SEQ));

            DL_LogRuntime(sLogLifecycle);
        }
        else if (nIngressKind == DL_INGRESS_KIND_BLOCKED)
        {
            string sLogBlocked = "[DL][BLOCKED_SIGNAL] npc=" + GetName(oPrimary) +
                                 " blocker=" + GetTag(oSecondary) +
                                 " type=" + IntToString(GetObjectType(oSecondary)) +
                                 " kind=" + IntToString(GetLocalInt(oPrimary, DL_L_NPC_EVENT_KIND)) +
                                 " seq=" + IntToString(GetLocalInt(oPrimary, DL_L_NPC_EVENT_SEQ));

            DL_LogRuntime(sLogBlocked);
        }
        else if (nIngressKind == DL_INGRESS_KIND_AREA)
        {
            string sActor = GetIsObjectValid(oActor) ? GetName(oActor) : "<invalid>";
            string sLogArea = "[DL][AREA_ENTER] area=" + GetName(oArea) +
                              " actor=" + sActor +
                              " players=" + IntToString(DL_GetAreaPlayerCount(oArea)) +
                              " tier=" + IntToString(DL_GetAreaTier(oArea)) +
                              " reg=" + IntToString(GetLocalInt(oArea, DL_L_AREA_REG_COUNT)) +
                              " resync_req=" + IntToString(GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING));

            DL_LogRuntime(sLogArea);
        }
    }

    return TRUE;
}

void DL_IngressOrchestrateLifecycleSignal(object oNpc, int nEventKind, string sTelemetryTag)
{
    DL_RunIngressPipeline(
        DL_INGRESS_KIND_LIFECYCLE,
        oNpc,
        OBJECT_INVALID,
        nEventKind,
        sTelemetryTag,
        TRUE,
        FALSE,
        FALSE,
        FALSE,
        "",
        TRUE,
        TRUE);
}

void DL_IngressOrchestrateBlockedSignal(object oNpc, object oBlocker)
{
    DL_RunIngressPipeline(
        DL_INGRESS_KIND_BLOCKED,
        oNpc,
        oBlocker,
        0,
        "",
        TRUE,
        TRUE,
        TRUE,
        TRUE,
        "blocked_invalid_object",
        FALSE,
        TRUE);
}

void DL_IngressOrchestrateAreaEnter(object oArea, object oEnter)
{
    DL_RunIngressPipeline(
        DL_INGRESS_KIND_AREA,
        oArea,
        oEnter,
        0,
        "",
        FALSE,
        FALSE,
        FALSE,
        FALSE,
        "",
        FALSE,
        TRUE);
}
