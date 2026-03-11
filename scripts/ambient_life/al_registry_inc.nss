// Ambient Life dense registry (Stage B).

const int AL_MAX_NPCS = 100;

string AL_RegKey(int nIdx)
{
    return "al_npc_" + IntToString(nIdx);
}

int AL_FindNPCInRegistry(object oArea, object oNpc)
{
    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;

    while (i < nCount)
    {
        if (GetLocalObject(oArea, AL_RegKey(i)) == oNpc)
        {
            return i;
        }
        i = i + 1;
    }

    return -1;
}

void AL_RegisterNPC(object oNpc)
{
    if (!GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc))
    {
        return;
    }

    object oArea = GetArea(oNpc);
    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalObject(oNpc, "al_last_area", oArea);

    if (AL_FindNPCInRegistry(oArea, oNpc) >= 0)
    {
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    if (nCount >= AL_MAX_NPCS)
    {
        return;
    }

    SetLocalObject(oArea, AL_RegKey(nCount), oNpc);
    SetLocalInt(oArea, "al_npc_count", nCount + 1);
}

void AL_UnregisterNPC(object oNpc)
{
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oArea = GetLocalObject(oNpc, "al_last_area");
    if (!GetIsObjectValid(oArea))
    {
        oArea = GetArea(oNpc);
    }

    if (!GetIsObjectValid(oArea))
    {
        return;
    }

    int nCount = GetLocalInt(oArea, "al_npc_count");
    int nIdx = AL_FindNPCInRegistry(oArea, oNpc);
    if (nIdx < 0 || nCount <= 0)
    {
        return;
    }

    int nLastIdx = nCount - 1;
    object oLast = GetLocalObject(oArea, AL_RegKey(nLastIdx));

    if (nIdx != nLastIdx)
    {
        SetLocalObject(oArea, AL_RegKey(nIdx), oLast);
    }

    DeleteLocalObject(oArea, AL_RegKey(nLastIdx));
    SetLocalInt(oArea, "al_npc_count", nLastIdx);
}

void AL_RegistryCompact(object oArea)
{
    int nCount = GetLocalInt(oArea, "al_npc_count");
    int i = 0;

    while (i < nCount)
    {
        object oNpc = GetLocalObject(oArea, AL_RegKey(i));
        int bInvalid = !GetIsObjectValid(oNpc) || GetObjectType(oNpc) != OBJECT_TYPE_CREATURE || GetIsPC(oNpc) || (GetArea(oNpc) != oArea);

        if (bInvalid)
        {
            int nLastIdx = nCount - 1;
            object oLast = GetLocalObject(oArea, AL_RegKey(nLastIdx));

            if (i != nLastIdx)
            {
                SetLocalObject(oArea, AL_RegKey(i), oLast);
            }

            DeleteLocalObject(oArea, AL_RegKey(nLastIdx));
            nCount = nLastIdx;
            SetLocalInt(oArea, "al_npc_count", nCount);
            continue;
        }

        SetLocalObject(oNpc, "al_last_area", oArea);
        i = i + 1;
    }
}
