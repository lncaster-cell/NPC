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
const string DL_L_MODULE_CR_GUARD_RESPONDERS_MAX = "dl_cr_guard_responders_max";
const string DL_L_MODULE_CR_JAIL_WP_TAG = "dl_cr_jail_wp_tag";
const string DL_L_OBJ_CR_LOCKPICK_MARK_UNTIL = "dl_cr_lockpick_mark_until";
const string DL_L_OBJ_CR_LOCKPICK_MARK_BY = "dl_cr_lockpick_mark_by";

const float DL_CR_WITNESS_RADIUS_DEFAULT = 10.0;
const float DL_CR_GUARD_ALERT_RADIUS_DEFAULT = 20.0;
const int DL_CR_GUARD_RESPONDERS_MAX_DEFAULT = 2;
const int DL_CR_GUARD_RESPONDERS_MAX_CAP = 2;
const int DL_CR_INVESTIGATE_TTL_MIN = 3;
const int DL_CR_SHOUT_COOLDOWN_MIN = 1;
const int DL_CR_WITNESS_SCAN_CAP = 24;
const int DL_CR_GUARD_SCAN_CAP = 24;
const string DL_CR_KEY_PREFIX_SHOUT_CD = "dl_cr_shout_cd_";
const string DL_CR_JAIL_WP_TAG_DEFAULT = "dl_jail_entry_wp";
const float DL_CR_DISTANCE_INF = 1000000.0;
const int DL_CR_LOCKPICK_MARK_TTL_MIN = 1;

float DL_CR_GetWitnessRadius()
{
    float fRaw = GetLocalFloat(GetModule(), DL_L_MODULE_CR_WITNESS_RADIUS);
    if (fRaw > 0.0)
    {
        return fRaw;
    }

    int nLegacyRaw = GetLocalInt(GetModule(), DL_L_MODULE_CR_WITNESS_RADIUS);
    if (nLegacyRaw <= 0)
    {
        return DL_CR_WITNESS_RADIUS_DEFAULT;
    }
    return IntToFloat(nLegacyRaw);
}

float DL_CR_GetGuardAlertRadius()
{
    float fRaw = GetLocalFloat(GetModule(), DL_L_MODULE_CR_GUARD_ALERT_RADIUS);
    if (fRaw > 0.0)
    {
        return fRaw;
    }

    int nLegacyRaw = GetLocalInt(GetModule(), DL_L_MODULE_CR_GUARD_ALERT_RADIUS);
    if (nLegacyRaw <= 0)
    {
        return DL_CR_GUARD_ALERT_RADIUS_DEFAULT;
    }
    return IntToFloat(nLegacyRaw);
}

int DL_CR_GetGuardRespondersMax()
{
    int nRaw = GetLocalInt(GetModule(), DL_L_MODULE_CR_GUARD_RESPONDERS_MAX);
    if (nRaw <= 0)
    {
        return DL_CR_GUARD_RESPONDERS_MAX_DEFAULT;
    }
    if (nRaw > DL_CR_GUARD_RESPONDERS_MAX_CAP)
    {
        return DL_CR_GUARD_RESPONDERS_MAX_CAP;
    }
    return nRaw;
}

string DL_CR_GetJailWaypointTag()
{
    string sTag = GetLocalString(GetModule(), DL_L_MODULE_CR_JAIL_WP_TAG);
    if (sTag == "")
    {
        return DL_CR_JAIL_WP_TAG_DEFAULT;
    }
    return sTag;
}

void DL_CR_ClearPursuitState(object oPc)
{
    if (!DL_IsRuntimePlayer(oPc))
    {
        return;
    }

    DeleteLocalInt(oPc, DL_L_PC_CR_DETAIN_PENDING);
    DeleteLocalObject(oPc, DL_L_PC_CR_LAST_GUARD);
    DeleteLocalInt(oPc, DL_L_NPC_CR_OFFENDER_UNTIL);
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

    if (!DL_IsActivePipelineNpc(oWitness))
    {
        return FALSE;
    }

    if (GetArea(oWitness) != oArea)
    {
        return FALSE;
    }

    return TRUE;
}

object DL_CR_FindWitness(object oOffender, object oArea, float fRadius)
{
    if (!DL_IsRuntimePlayer(oOffender) || !GetIsObjectValid(oArea))
    {
        return OBJECT_INVALID;
    }

    object oBest = OBJECT_INVALID;
    float fBestDist = DL_CR_DISTANCE_INF;
    location lCenter = GetLocation(oOffender);

    object oObj = GetFirstObjectInShape(
        SHAPE_SPHERE,
        fRadius,
        lCenter,
        FALSE,
        OBJECT_TYPE_CREATURE
    );
    int nChecked = 0;
    while (GetIsObjectValid(oObj))
    {
        if (nChecked >= DL_CR_WITNESS_SCAN_CAP)
        {
            break;
        }
        nChecked = nChecked + 1;

        if (DL_CR_IsWitnessCandidate(oObj, oOffender, oArea))
        {
            if (GetObjectSeen(oObj, oOffender) || GetObjectHeard(oObj, oOffender))
            {
                float fDist = GetDistanceBetween(oObj, oOffender);
                if (fDist <= fRadius && fDist < fBestDist)
                {
                    oBest = oObj;
                    fBestDist = fDist;
                }
            }
        }
        oObj = GetNextObjectInShape(
            SHAPE_SPHERE,
            fRadius,
            lCenter,
            FALSE,
            OBJECT_TYPE_CREATURE
        );
    }

    return oBest;
}

void DL_CR_WitnessShout(object oWitness, object oOffender)
{
    if (!GetIsObjectValid(oWitness) || !DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    string sKey = DL_CR_KEY_PREFIX_SHOUT_CD + DL_CR_GetOffenderIdentityKey(oOffender);
    int nNowAbsMin = DL_GetAbsoluteMinute();
    if (GetLocalInt(oWitness, sKey) > nNowAbsMin)
    {
        return;
    }
    SetLocalInt(oWitness, sKey, nNowAbsMin + DL_CR_SHOUT_COOLDOWN_MIN);

    AssignCommand(oWitness, SpeakString("Помогите! Меня обокрали!", TALKVOLUME_SHOUT));
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
    if (nLevel < 1)
    {
        nLevel = 1;
    }

    float fRadius = DL_CR_GetGuardAlertRadius();
    int nMaxResponders = DL_CR_GetGuardRespondersMax();
    object oBestA = OBJECT_INVALID;
    object oBestB = OBJECT_INVALID;
    float fBestA = DL_CR_DISTANCE_INF;
    float fBestB = DL_CR_DISTANCE_INF;

    location lCenter = GetLocation(oOffender);
    object oObj = GetFirstObjectInShape(
        SHAPE_SPHERE,
        fRadius,
        lCenter,
        FALSE,
        OBJECT_TYPE_CREATURE
    );
    int nChecked = 0;
    while (GetIsObjectValid(oObj))
    {
        if (nChecked >= DL_CR_GUARD_SCAN_CAP)
        {
            break;
        }
        nChecked = nChecked + 1;

        if (DL_IsActivePipelineNpc(oObj) && DL_CR_IsGuardVictim(oObj))
        {
            if (GetObjectSeen(oObj, oOffender) || GetObjectHeard(oObj, oOffender))
            {
                float fDist = GetDistanceBetween(oObj, oOffender);
                if (fDist <= fRadius)
                {
                    if (fDist < fBestA)
                    {
                        oBestB = oBestA;
                        fBestB = fBestA;
                        oBestA = oObj;
                        fBestA = fDist;
                    }
                    else if (fDist < fBestB)
                    {
                        oBestB = oObj;
                        fBestB = fDist;
                    }
                }
            }
        }
        oObj = GetNextObjectInShape(
            SHAPE_SPHERE,
            fRadius,
            lCenter,
            FALSE,
            OBJECT_TYPE_CREATURE
        );
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    string sDialogResRef = DL_CR_GetDetainDialogResRef();

    if (GetIsObjectValid(oBestA))
    {
        SetLocalObject(oBestA, DL_L_NPC_CR_INVESTIGATE_TARGET, oOffender);
        SetLocalInt(oBestA, DL_L_NPC_CR_INVESTIGATE_UNTIL, nNowAbsMin + DL_CR_INVESTIGATE_TTL_MIN);
        SetLocalObject(oOffender, DL_L_PC_CR_LAST_GUARD, oBestA);
        AssignCommand(oBestA, ClearAllActions(TRUE));
        if (nLevel >= 3)
        {
            AssignCommand(oBestA, ActionAttack(oOffender));
        }
        else
        {
            AssignCommand(oBestA, ActionMoveToObject(oOffender, TRUE, 2.0));
            AssignCommand(oBestA, ActionStartConversation(oOffender, sDialogResRef, TRUE, TRUE));
        }
    }

    if (nMaxResponders >= 2 && GetIsObjectValid(oBestB))
    {
        SetLocalObject(oBestB, DL_L_NPC_CR_INVESTIGATE_TARGET, oOffender);
        SetLocalInt(oBestB, DL_L_NPC_CR_INVESTIGATE_UNTIL, nNowAbsMin + DL_CR_INVESTIGATE_TTL_MIN);
        AssignCommand(oBestB, ClearAllActions(TRUE));
        if (nLevel >= 3)
        {
            AssignCommand(oBestB, ActionAttack(oOffender));
        }
        else
        {
            AssignCommand(oBestB, ActionMoveToObject(oOffender, TRUE, 2.0));
        }
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

void DL_CR_RegisterCrimeIncident(object oOffender, object oArea, string sKind, int bWitnessed, object oWitness)
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

    DL_LG_OnWitnessedIncident(oOffender, sKind, oArea, oWitness);
    SetLocalInt(oOffender, DL_L_PC_CR_DETAIN_PENDING, TRUE);

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
    object oWitness = DL_CR_FindWitness(oDisturber, oArea, fRadius);
    int bWitnessed = GetIsObjectValid(oWitness);
    if (bWitnessed)
    {
        DL_CR_WitnessShout(oWitness, oDisturber);
    }
    string sKind = GetObjectType(oDisturbed) == OBJECT_TYPE_CREATURE ? DL_CR_EVT_PICKPOCKET : DL_CR_EVT_CONTAINER_THEFT;

    DL_CR_RegisterCrimeIncident(oDisturber, oArea, sKind, bWitnessed, oWitness);
}

void DL_CR_MarkPendingLockpick(object oTarget, object oActor)
{
    if (!GetIsObjectValid(oTarget))
    {
        return;
    }

    object oOffender = DL_CR_ResolveResponsibleActor(oActor);
    if (!DL_IsRuntimePlayer(oOffender))
    {
        return;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    SetLocalInt(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_UNTIL, nNowAbsMin + DL_CR_LOCKPICK_MARK_TTL_MIN);
    SetLocalString(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_BY, DL_CR_GetOffenderIdentityKey(oOffender));
}

int DL_CR_ConsumePendingLockpick(object oTarget, object oOffender)
{
    if (!GetIsObjectValid(oTarget) || !DL_IsRuntimePlayer(oOffender))
    {
        return FALSE;
    }

    int nUntilAbsMin = GetLocalInt(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_UNTIL);
    if (nUntilAbsMin <= 0)
    {
        return FALSE;
    }

    int nNowAbsMin = DL_GetAbsoluteMinute();
    if (nUntilAbsMin < nNowAbsMin)
    {
        DeleteLocalInt(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_UNTIL);
        DeleteLocalString(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_BY);
        return FALSE;
    }

    string sMarkedBy = GetLocalString(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_BY);
    if (sMarkedBy == "" || sMarkedBy != DL_CR_GetOffenderIdentityKey(oOffender))
    {
        return FALSE;
    }

    DeleteLocalInt(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_UNTIL);
    DeleteLocalString(oTarget, DL_L_OBJ_CR_LOCKPICK_MARK_BY);
    return TRUE;
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

    int bRestricted = GetLocalInt(oOpened, DL_L_AREA_CR_RESTRICTED) == TRUE;
    int bLockpick = DL_CR_ConsumePendingLockpick(oOpened, oOpener);
    if (!bRestricted && !bLockpick)
    {
        return;
    }

    float fRadius = DL_CR_GetWitnessRadius();
    object oWitness = DL_CR_FindWitness(oOpener, oArea, fRadius);
    int bWitnessed = GetIsObjectValid(oWitness);
    if (bWitnessed)
    {
        DL_CR_WitnessShout(oWitness, oOpener);
    }
    string sKind = DL_CR_EVT_RESTRICTED_ENTRY;
    if (!bRestricted)
    {
        sKind = GetObjectType(oOpened) == OBJECT_TYPE_DOOR ? DL_CR_EVT_DOOR_LOCKPICK : DL_CR_EVT_PLACEABLE_LOCKPICK;
    }

    DL_CR_RegisterCrimeIncident(oOpener, oArea, sKind, bWitnessed, oWitness);
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
    object oWitness = DL_CR_FindWitness(oOffender, oArea, fRadius);
    int bWitnessed = GetIsObjectValid(oWitness);
    if (bWitnessed)
    {
        DL_CR_WitnessShout(oWitness, oOffender);
    }
    DL_CR_RegisterCrimeIncident(oOffender, oArea, DL_CR_EVT_RESTRICTED_ENTRY, bWitnessed, oWitness);
}

int DL_CR_TeleportToJail(object oPc)
{
    if (!DL_IsRuntimePlayer(oPc))
    {
        return FALSE;
    }

    object oWp = GetWaypointByTag(DL_CR_GetJailWaypointTag());
    if (!GetIsObjectValid(oWp))
    {
        return FALSE;
    }

    AssignCommand(oPc, ClearAllActions(TRUE));
    AssignCommand(oPc, ActionJumpToLocation(GetLocation(oWp)));
    return TRUE;
}

void DL_CR_HandleDetainAccepted(object oPc, object oGuard)
{
    if (!DL_IsRuntimePlayer(oPc))
    {
        return;
    }

    DL_CR_ClearPursuitState(oPc);
    DL_LG_OnDetained(oPc, oGuard);

    if (!DL_CR_TeleportToJail(oPc))
    {
        SendMessageToPC(oPc, "[DL] Не найден jail waypoint. Проверьте local dl_cr_jail_wp_tag.");
    }

    if (GetIsObjectValid(oGuard))
    {
        AssignCommand(oGuard, ClearAllActions(TRUE));
    }
}

void DL_CR_HandleDetainRefused(object oPc, object oGuard)
{
    if (!DL_IsRuntimePlayer(oPc))
    {
        return;
    }

    SetLocalInt(oPc, DL_L_PC_CR_DETAIN_PENDING, TRUE);
    DL_CR_RegisterIncident(oPc, 10);
    DL_LG_OnRefusedDetain(oPc, oGuard);

    if (GetIsObjectValid(oGuard))
    {
        AssignCommand(oGuard, ClearAllActions(TRUE));
        AssignCommand(oGuard, ActionAttack(oPc));
    }
}
