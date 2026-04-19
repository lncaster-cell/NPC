const string DL_CR_EVT_PICKPOCKET = "pickpocket";
const string DL_CR_EVT_CONTAINER_THEFT = "container_theft";
const string DL_CR_EVT_DOOR_LOCKPICK = "door_lockpick";
const string DL_CR_EVT_PLACEABLE_LOCKPICK = "placeable_lockpick";
const string DL_CR_EVT_RESTRICTED_ENTRY = "restricted_entry";

const string DL_L_MODULE_CR_WITNESS_RADIUS = "dl_cr_witness_radius";
const string DL_L_MODULE_CR_GUARD_ALERT_RADIUS = "dl_cr_guard_alert_radius";
const string DL_L_AREA_CR_RESTRICTED = "dl_cr_restricted";
const string DL_L_EVT_CR_KIND = "dl_cr_evt_kind";
const string DL_L_EVT_CR_WITNESSED = "dl_cr_evt_witnessed";
const string DL_L_EVT_CR_AREA_TAG = "dl_cr_evt_area_tag";

const float DL_CR_WITNESS_RADIUS_DEFAULT = 10.0;
const float DL_CR_GUARD_ALERT_RADIUS_DEFAULT = 20.0;

float DL_CR_GetWitnessRadius()
{
    int nRaw = GetLocalInt(GetModule(), DL_L_MODULE_CR_WITNESS_RADIUS);
    if (nRaw <= 0)
    {
        return DL_CR_WITNESS_RADIUS_DEFAULT;
    }
    return IntToFloat(nRaw);
}

float DL_CR_GetGuardAlertRadius()
{
    int nRaw = GetLocalInt(GetModule(), DL_L_MODULE_CR_GUARD_ALERT_RADIUS);
    if (nRaw <= 0)
    {
        return DL_CR_GUARD_ALERT_RADIUS_DEFAULT;
    }
    return IntToFloat(nRaw);
}

int DL_CR_IsWitnessCandidate(object oWitness, object oOffender, object oArea)
{
    if (!GetIsObjectValid(oWitness) || !GetIsObjectValid(oOffender) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    if (oWitness == oOffender)
    {
        return FALSE;
    }

    if (GetObjectType(oWitness) != OBJECT_TYPE_CREATURE)
    {
        return FALSE;
    }

    if (GetIsDead(oWitness) || GetIsDM(oWitness))
    {
        return FALSE;
    }

    if (GetArea(oWitness) != oArea)
    {
        return FALSE;
    }

    return TRUE;
}

int DL_CR_HasWitness(object oOffender, object oArea, float fRadius)
{
    if (!DL_IsRuntimePlayer(oOffender) || !GetIsObjectValid(oArea))
    {
        return FALSE;
    }

    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        if (DL_CR_IsWitnessCandidate(oObj, oOffender, oArea))
        {
            float fDist = GetDistanceBetween(oObj, oOffender);
            if (fDist <= fRadius)
            {
                if (GetObjectSeen(oObj, oOffender) || GetObjectHeard(oObj, oOffender))
                {
                    return TRUE;
                }
            }
        }
        oObj = GetNextObjectInArea(oArea);
    }

    return FALSE;
}

int DL_CR_GetCrimeHeat(string sKind)
{
    if (sKind == DL_CR_EVT_PICKPOCKET)
    {
        return 15;
    }
    if (sKind == DL_CR_EVT_CONTAINER_THEFT)
    {
        return 20;
    }
    if (sKind == DL_CR_EVT_DOOR_LOCKPICK)
    {
        return 25;
    }
    if (sKind == DL_CR_EVT_PLACEABLE_LOCKPICK)
    {
        return 20;
    }
    if (sKind == DL_CR_EVT_RESTRICTED_ENTRY)
    {
        return 15;
    }
    return 10;
}

void DL_CR_AlertNearbyGuards(object oOffender, object oArea)
{
    if (!DL_IsRuntimePlayer(oOffender) || !GetIsObjectValid(oArea))
    {
        return;
    }

    int nLevel = GetLocalInt(GetModule(), DL_L_MODULE_CR_LEVEL);
    if (nLevel <= 0)
    {
        return;
    }

    float fRadius = DL_CR_GetGuardAlertRadius();
    object oObj = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oObj))
    {
        if (DL_IsActivePipelineNpc(oObj) && DL_CR_IsGuardVictim(oObj))
        {
            if (GetDistanceBetween(oObj, oOffender) <= fRadius)
            {
                AssignCommand(oObj, ClearAllActions(TRUE));
                if (nLevel >= 3)
                {
                    AssignCommand(oObj, ActionAttack(oOffender));
                }
                else
                {
                    AssignCommand(oObj, ActionMoveToObject(oOffender, TRUE, 2.0));
                }
            }
        }
        oObj = GetNextObjectInArea(oArea);
    }
}

void DL_CR_RecordCrimeEvent(object oOffender, object oArea, string sKind, int bWitnessed)
{
    if (!DL_IsRuntimePlayer(oOffender) || !GetIsObjectValid(oArea))
    {
        return;
    }

    SetLocalString(oOffender, DL_L_EVT_CR_KIND, sKind);
    SetLocalInt(oOffender, DL_L_EVT_CR_WITNESSED, bWitnessed);
    SetLocalString(oOffender, DL_L_EVT_CR_AREA_TAG, GetTag(oArea));
}

void DL_CR_RegisterCrimeIncident(object oOffender, object oArea, string sKind, int bWitnessed)
{
    if (!DL_IsRuntimePlayer(oOffender) || !GetIsObjectValid(oArea))
    {
        return;
    }

    DL_CR_RecordCrimeEvent(oOffender, oArea, sKind, bWitnessed);
    if (!bWitnessed)
    {
        return;
    }

    int nHeat = DL_CR_GetCrimeHeat(sKind);
    DL_CR_RegisterIncident(oOffender, nHeat);
    DL_CR_AlertNearbyGuards(oOffender, oArea);
}

void DL_CR_HandleDisturbed(object oDisturbed)
{
    if (!GetIsObjectValid(oDisturbed))
    {
        return;
    }

    object oArea = GetArea(oDisturbed);
    if (!DL_CR_IsEnabledForArea(oArea))
    {
        return;
    }

    object oDisturber = DL_CR_ResolveResponsibleActor(GetLastDisturbed());
    if (!DL_IsRuntimePlayer(oDisturber))
    {
        return;
    }

    float fRadius = DL_CR_GetWitnessRadius();
    int bWitnessed = DL_CR_HasWitness(oDisturber, oArea, fRadius);
    string sKind = GetObjectType(oDisturbed) == OBJECT_TYPE_CREATURE ? DL_CR_EVT_PICKPOCKET : DL_CR_EVT_CONTAINER_THEFT;

    DL_CR_RegisterCrimeIncident(oDisturber, oArea, sKind, bWitnessed);
}

void DL_CR_HandleOpenObject(object oOpened)
{
    if (!GetIsObjectValid(oOpened))
    {
        return;
    }

    object oArea = GetArea(oOpened);
    if (!DL_CR_IsEnabledForArea(oArea))
    {
        return;
    }

    object oOpener = DL_CR_ResolveResponsibleActor(GetLastOpenedBy());
    if (!DL_IsRuntimePlayer(oOpener))
    {
        return;
    }

    if (GetLocalInt(oOpened, DL_L_AREA_CR_RESTRICTED) != TRUE && GetLocked(oOpened) != TRUE)
    {
        return;
    }

    float fRadius = DL_CR_GetWitnessRadius();
    int bWitnessed = DL_CR_HasWitness(oOpener, oArea, fRadius);
    string sKind = GetObjectType(oOpened) == OBJECT_TYPE_DOOR ? DL_CR_EVT_DOOR_LOCKPICK : DL_CR_EVT_PLACEABLE_LOCKPICK;

    DL_CR_RegisterCrimeIncident(oOpener, oArea, sKind, bWitnessed);
}

void DL_CR_HandleRestrictedEntry(object oActor, object oSource)
{
    object oOffender = DL_CR_ResolveResponsibleActor(oActor);
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    object oArea = GetArea(oSource);
    if (!DL_CR_IsEnabledForArea(oArea))
    {
        return;
    }

    int bRestrictedByTrigger = GetLocalInt(oSource, DL_L_AREA_CR_RESTRICTED) == TRUE;
    int bRestrictedByArea = GetLocalInt(oArea, DL_L_AREA_CR_RESTRICTED) == TRUE;
    if (!bRestrictedByTrigger && !bRestrictedByArea)
    {
        return;
    }

    float fRadius = DL_CR_GetWitnessRadius();
    int bWitnessed = DL_CR_HasWitness(oOffender, oArea, fRadius);
    DL_CR_RegisterCrimeIncident(oOffender, oArea, DL_CR_EVT_RESTRICTED_ENTRY, bWitnessed);
}
