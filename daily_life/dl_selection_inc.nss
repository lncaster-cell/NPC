// Unified deterministic selection/scoring helpers.
// Domain adapters provide score and stable tie keys.

const int DL_SELECTION_SCORE_INF = 1000000;

int DL_GetSelectionScoreInf()
{
    return DL_SELECTION_SCORE_INF;
}

int DL_IsWithinAnchorRadius(object oActor, object oAnchor, float fRadius)
{
    if (!GetIsObjectValid(oActor) || !GetIsObjectValid(oAnchor))
    {
        return FALSE;
    }

    return GetDistanceBetween(oActor, oAnchor) <= fRadius;
}

int DL_SelectionCompare(int nCandidateScore, int nBestScore, string sCandidateTieKey, string sBestTieKey)
{
    if (nCandidateScore < nBestScore)
    {
        return TRUE;
    }

    if (nCandidateScore > nBestScore)
    {
        return FALSE;
    }

    if (sBestTieKey == "")
    {
        return TRUE;
    }

    if (sCandidateTieKey == "")
    {
        return FALSE;
    }

    string sCandidateNorm = GetStringLowerCase(sCandidateTieKey);
    string sBestNorm = GetStringLowerCase(sBestTieKey);
    if (sCandidateNorm == sBestNorm)
    {
        return FALSE;
    }

    return GetStringLength(sCandidateNorm) < GetStringLength(sBestNorm);
}

int DL_SelectNearestObjectCandidate(
    object oCandidate,
    float fCandidateDistance,
    string sCandidateTieKey,
    object oBest,
    float fBestDistance,
    string sBestTieKey
)
{
    if (!GetIsObjectValid(oCandidate))
    {
        return FALSE;
    }

    if (!GetIsObjectValid(oBest))
    {
        return TRUE;
    }

    int nCandidateScore = FloatToInt(fCandidateDistance * 100.0);
    int nBestScore = FloatToInt(fBestDistance * 100.0);
    return DL_SelectionCompare(nCandidateScore, nBestScore, sCandidateTieKey, sBestTieKey);
}

int DL_CompareSidesForBidirectionalPair(
    object oNpc,
    object oTarget,
    object oEntry,
    object oExit,
    float fSideBias,
    int bPreferEntryOnTie
)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oTarget) ||
        !GetIsObjectValid(oEntry) || !GetIsObjectValid(oExit))
    {
        return FALSE;
    }

    float fNpcToEntry = GetDistanceBetween(oNpc, oEntry);
    float fNpcToExit = GetDistanceBetween(oNpc, oExit);
    float fTargetToEntry = GetDistanceBetween(oTarget, oEntry);
    float fTargetToExit = GetDistanceBetween(oTarget, oExit);

    int bNpcOnEntrySide = (fNpcToEntry + fSideBias) < fNpcToExit;
    int bTargetOnExitSide = (fTargetToExit + fSideBias) < fTargetToEntry;

    if (!bNpcOnEntrySide && !bTargetOnExitSide && bPreferEntryOnTie)
    {
        bNpcOnEntrySide = fNpcToEntry <= fNpcToExit;
        bTargetOnExitSide = fTargetToExit <= fTargetToEntry;
    }

    return bNpcOnEntrySide && bTargetOnExitSide;
}

string DL_SelectionBuildTieKey(object oPrimary, object oSecondary, int nOrdinal)
{
    string sPrimary = GetIsObjectValid(oPrimary) ? GetTag(oPrimary) : "~";
    string sSecondary = GetIsObjectValid(oSecondary) ? GetTag(oSecondary) : "~";
    return sPrimary + "|" + sSecondary + "|" + IntToString(nOrdinal);
}

// Transition-routing contract:
// all candidate comparisons for transition routing must go through this helper
// to preserve deterministic score and tie-break behavior.
int DL_SelectionConsiderTransitionCandidate(
    int nCandidateScore,
    object oTiePrimary,
    object oTieSecondary,
    int nOrdinal,
    int nBestScore,
    string sBestTieKey
)
{
    string sCandidateTieKey = DL_SelectionBuildTieKey(oTiePrimary, oTieSecondary, nOrdinal);
    return DL_SelectionCompare(nCandidateScore, nBestScore, sCandidateTieKey, sBestTieKey);
}
