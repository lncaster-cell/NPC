// Minimal compile-body compatibility helpers.
// Keep this file implementation-only and side-effect-light.

void DL_LogChatDebugEvent(object oNpc, string sKind, string sPayload)
{
    // Chat debug output is currently disabled by design.
}

void DL_CommandSetFacing(object oActor, float fFacing)
{
    if (!GetIsObjectValid(oActor))
    {
        return;
    }

    AssignCommand(oActor, SetFacing(fFacing));
}
