#ifndef AL_DEBUG_INC_NSS
#define AL_DEBUG_INC_NSS

void AL_Debug(object oArea, string sMessage)
{
    if (!GetIsObjectValid(oArea)) return;
    if (GetLocalInt(oArea, "al_debug") <= 0) return;
    SendMessageToAllDMs("[AL] " + sMessage);
}

#endif
