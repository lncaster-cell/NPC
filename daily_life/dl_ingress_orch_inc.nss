// Canonical ingress orchestration helper.
// Base pipeline for each ingress:
// 1) validate,
// 2) normalize actor/context,
// 3) lifecycle sync,
// 4) state transition,
// 5) telemetry/diagnostic.

const int DL_INGRESS_STAGE_VALIDATE       = 1;
const int DL_INGRESS_STAGE_NORMALIZE      = 2;
const int DL_INGRESS_STAGE_LIFECYCLE_SYNC = 3;
const int DL_INGRESS_STAGE_STATE_TRANS    = 4;
const int DL_INGRESS_STAGE_TELEMETRY      = 5;

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

void DL_IngressOrchestrateLifecycleSignal(object oNpc, int nEventKind, string sTelemetryTag)
{
    // validate
    if (!DL_IngressValidateNpc(oNpc, FALSE, FALSE))
    {
        return;
    }

    // normalize actor/context
    object oArea = GetArea(oNpc);

    // lifecycle sync
    if (nEventKind == DL_NPC_EVENT_DEATH)
    {
        DL_CR_HandleNpcKilled(oNpc);
    }

    // state transition
    DL_RequestNpcLifecycleSignal(oNpc, nEventKind);

    // telemetry/diagnostic
    if (DL_IsRuntimeLogEnabled())
    {
        string sLog = "[DL][" + sTelemetryTag + "] npc=" + GetName(oNpc) +
                      " area=" + GetName(oArea) +
                      " kind=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_EVENT_KIND)) +
                      " seq=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ));

        DL_LogRuntime(sLog);
    }
}

void DL_IngressOrchestrateBlockedSignal(object oNpc, object oBlocker)
{
    // validate
    if (!DL_IngressValidateNpc(oNpc, TRUE, TRUE))
    {
        return;
    }

    // normalize actor/context
    if (!GetIsObjectValid(oBlocker))
    {
        SetLocalString(oNpc, DL_L_NPC_BLOCKED_DIAGNOSTIC, "blocked_invalid_object");
        return;
    }

    // lifecycle sync (no-op: blocked does not require external lifecycle callback)

    // state transition
    DL_RequestNpcBlockedSignal(oNpc, oBlocker);

    // telemetry/diagnostic
    if (DL_IsRuntimeLogEnabled())
    {
        string sLog = "[DL][BLOCKED_SIGNAL] npc=" + GetName(oNpc) +
                      " blocker=" + GetTag(oBlocker) +
                      " type=" + IntToString(GetObjectType(oBlocker)) +
                      " kind=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_EVENT_KIND)) +
                      " seq=" + IntToString(GetLocalInt(oNpc, DL_L_NPC_EVENT_SEQ));

        DL_LogRuntime(sLog);
    }
}

void DL_IngressOrchestrateAreaEnter(object oArea, object oEnter)
{
    // validate
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    // normalize actor/context
    object oActor = oEnter;

    // lifecycle sync
    DL_OnAreaEnterBootstrap(oArea, oActor);

    // state transition (no explicit state signal for area enter)

    // telemetry/diagnostic
    if (DL_IsRuntimeLogEnabled())
    {
        string sActor = GetIsObjectValid(oActor) ? GetName(oActor) : "<invalid>";
        string sLog = "[DL][AREA_ENTER] area=" + GetName(oArea) +
                      " actor=" + sActor +
                      " players=" + IntToString(DL_GetAreaPlayerCount(oArea)) +
                      " tier=" + IntToString(DL_GetAreaTier(oArea)) +
                      " reg=" + IntToString(GetLocalInt(oArea, DL_L_AREA_REG_COUNT)) +
                      " resync_req=" + IntToString(GetLocalInt(oArea, DL_L_AREA_ENTER_RESYNC_PENDING));

        DL_LogRuntime(sLog);
    }
}
