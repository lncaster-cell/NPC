// Ambient Life public runtime hooks for route state interactions.
// Provides a minimal API surface for external layers (react/blocked) without exposing route local-key internals.

// Internal route runtime hooks.
string AL_RouteRtActiveKey();
int AL_RouteRoutineResumeCurrent(object oNpc);
void AL_RouteBlockedRuntimeReset(object oNpc);

int AL_RouteRuntimeIsActive(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return GetLocalInt(oNpc, AL_RouteRtActiveKey());
}

int AL_RouteRuntimeResumeSafe(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return FALSE;
    }

    return AL_RouteRoutineResumeCurrent(oNpc);
}

void AL_RouteRuntimeResetSafe(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    AL_RouteBlockedRuntimeReset(oNpc);
}
