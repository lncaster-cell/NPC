#ifndef AL_REGISTRY_INC_NSS
#define AL_REGISTRY_INC_NSS

const string AL_LOCAL_NPC_COUNT = "al_npc_count";

string AL_GetNpcKey(int nIndex)
{
    return "al_npc_" + IntToString(nIndex);
}

int AL_GetNpcCount(object oArea)
{
    return GetLocalInt(oArea, AL_LOCAL_NPC_COUNT);
}

void AL_SetNpcCount(object oArea, int nCount)
{
    if (nCount < 0) nCount = 0;
    SetLocalInt(oArea, AL_LOCAL_NPC_COUNT, nCount);
}

int AL_FindNpcIndex(object oArea, object oNpc)
{
    int nCount = AL_GetNpcCount(oArea);
    int i = 0;
    while (i < nCount)
    {
        if (GetLocalObject(oArea, AL_GetNpcKey(i)) == oNpc)
        {
            return i;
        }
        i = i + 1;
    }
    return -1;
}

void AL_RegisterNpc(object oArea, object oNpc)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNpc)) return;
    if (AL_FindNpcIndex(oArea, oNpc) >= 0) return;

    int nCount = AL_GetNpcCount(oArea);
    SetLocalObject(oArea, AL_GetNpcKey(nCount), oNpc);
    AL_SetNpcCount(oArea, nCount + 1);
}

void AL_UnregisterNpc(object oArea, object oNpc)
{
    if (!GetIsObjectValid(oArea) || !GetIsObjectValid(oNpc)) return;

    int nCount = AL_GetNpcCount(oArea);
    int nIndex = AL_FindNpcIndex(oArea, oNpc);
    if (nIndex < 0) return;

    int nLast = nCount - 1;
    if (nIndex != nLast)
    {
        object oSwap = GetLocalObject(oArea, AL_GetNpcKey(nLast));
        SetLocalObject(oArea, AL_GetNpcKey(nIndex), oSwap);
    }

    DeleteLocalObject(oArea, AL_GetNpcKey(nLast));
    AL_SetNpcCount(oArea, nLast);
}

// Sparse cleanup for stale or cross-area references.
void AL_SyncCleanupRegistry(object oArea)
{
    int nCount = AL_GetNpcCount(oArea);
    int i = 0;
    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_GetNpcKey(i));
        int bStale = !GetIsObjectValid(oNpc) || GetArea(oNpc) != oArea || GetIsDead(oNpc);

        if (bStale)
        {
            int nLast = nCount - 1;
            if (i != nLast)
            {
                object oSwap = GetLocalObject(oArea, AL_GetNpcKey(nLast));
                SetLocalObject(oArea, AL_GetNpcKey(i), oSwap);
            }
            DeleteLocalObject(oArea, AL_GetNpcKey(nLast));
            nCount = nLast;
            AL_SetNpcCount(oArea, nCount);
            continue;
        }

        i = i + 1;
    }
}

#endif
