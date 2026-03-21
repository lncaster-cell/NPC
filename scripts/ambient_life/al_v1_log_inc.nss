#ifndef AL_V1_LOG_INC_NSS
#define AL_V1_LOG_INC_NSS

#include "al_v1_const_inc"

void DLV1_Log(int nLevel, string sMessage)
{
    if (nLevel > DLV1_DEBUG_LEVEL)
    {
        return;
    }

    WriteTimestampedLogEntry("[DLV1] " + sMessage);
}

void DLV1_LogNpc(object oNPC, int nLevel, string sMessage)
{
    string sTag = "<invalid>";
    if (GetIsObjectValid(oNPC))
    {
        sTag = GetTag(oNPC);
    }
    DLV1_Log(nLevel, sTag + ": " + sMessage);
}

#endif
