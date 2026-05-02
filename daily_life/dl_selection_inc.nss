// Unified deterministic selection/scoring helpers.
// Domain adapters provide score and stable tie keys.

const int DL_SELECTION_SCORE_INF = 2147483000;

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

    return GetStringLowerCase(sCandidateTieKey) < GetStringLowerCase(sBestTieKey);
}

string DL_SelectionBuildTieKey(object oPrimary, object oSecondary, int nOrdinal)
{
    string sPrimary = GetIsObjectValid(oPrimary) ? GetTag(oPrimary) : "~";
    string sSecondary = GetIsObjectValid(oSecondary) ? GetTag(oSecondary) : "~";
    return sPrimary + "|" + sSecondary + "|" + IntToString(nOrdinal);
}
