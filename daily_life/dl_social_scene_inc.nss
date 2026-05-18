// SOCIAL directive owns routing and stable anchor focus only.
// This Social Scene layer owns staged, non-looping presentation gestures.
// It is worker tick-driven and cancellable through focus cleanup; it avoids
// DelayCommand chains, NPC heartbeats, global managers, and area scans.

const string DL_L_NPC_SOCIAL_SCENE_ID = "dl_social_scene_id";
const string DL_L_NPC_SOCIAL_SCENE_STEP = "dl_social_scene_step";
const string DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE = "dl_social_scene_next_minute";
const string DL_L_NPC_SOCIAL_SCENE_ROLE = "dl_social_scene_role";
const string DL_L_NPC_SOCIAL_SCENE_LAST_ANIM = "dl_social_scene_last_anim";
const string DL_L_NPC_SOCIAL_SCENE_ANCHOR = "dl_social_scene_anchor";
const string DL_L_NPC_SOCIAL_SCENE_LAST_POOL = "dl_social_scene_last_pool";
const string DL_L_NPC_SOCIAL_SCENE_ACTIVE = "dl_social_scene_active";
const string DL_L_NPC_SOCIAL_SCENE_PHASE = "dl_social_scene_phase";
const string DL_L_NPC_SOCIAL_SCENE_PLAY_RESULT = "dl_social_scene_play_result";

const string DL_SOCIAL_SCENE_DEFAULT = "social_default";
const int DL_SOCIAL_SCENE_SOLO_WAIT_MINUTES = 3;

int DL_GetSocialSceneStepCount(string sSceneId)
{
    if (sSceneId == DL_SOCIAL_SCENE_DEFAULT) return 8;
    return 8;
}

int DL_GetSocialSceneStepWaitMinutes(string sSceneId, int nStep)
{
    return 1;
}

string DL_GetSocialSceneSpeakerPoolName(int nPhase)
{
    int nMood = nPhase % 8;

    if (nMood == 2 || nMood == 3) return "forceful_speaker";
    if (nMood == 4 || nMood == 5) return "sad_speaker";
    if (nMood == 6 || nMood == 7) return "laugh_speaker";
    return "neutral_speaker";
}

int DL_GetSocialScenePoolCount(string sPool)
{
    if (sPool == "neutral_speaker") return 3;
    if (sPool == "forceful_speaker") return 5;
    if (sPool == "sad_speaker") return 3;
    if (sPool == "laugh_speaker") return 3;
    if (sPool == "listener") return 9;
    return 1;
}

string DL_GetSocialScenePoolAnim(string sPool, int nIndex)
{
    if (sPool == "neutral_speaker")
    {
        if (nIndex == 0) return "talknormal";
        if (nIndex == 1) return "talknormal02";
        return "talkcheer";
    }

    if (sPool == "forceful_speaker")
    {
        if (nIndex == 0) return "talkforce";
        if (nIndex == 1) return "talkforce01";
        if (nIndex == 2) return "talkforce02";
        if (nIndex == 3) return "talkforce03";
        return "talkshout";
    }

    if (sPool == "sad_speaker")
    {
        if (nIndex == 0) return "talksad";
        if (nIndex == 1) return "talkplead";
        return "dejected";
    }

    if (sPool == "laugh_speaker")
    {
        if (nIndex == 0) return "talklaugh";
        if (nIndex == 1) return "chuckle";
        return "laugh";
    }

    if (sPool == "listener")
    {
        if (nIndex == 0) return "listen";
        if (nIndex == 1) return "nodyes";
        if (nIndex == 2) return "nodno";
        if (nIndex == 3) return "scratchhead";
        if (nIndex == 4) return "shrug";
        if (nIndex == 5) return "sigh";
        if (nIndex == 6) return "EMO_thoughtful";
        if (nIndex == 7) return "EMO_annoyed";
        return "bored";
    }

    return "listen";
}

string DL_SelectSocialSceneAnim(string sPool, string sLastAnim)
{
    int nCount = DL_GetSocialScenePoolCount(sPool);
    if (nCount <= 0) nCount = 1;

    int nIndex = Random(nCount);
    string sAnim = DL_GetSocialScenePoolAnim(sPool, nIndex);
    if (sAnim == sLastAnim && nCount > 1)
    {
        nIndex = (nIndex + 1) % nCount;
        sAnim = DL_GetSocialScenePoolAnim(sPool, nIndex);
    }

    return sAnim;
}

string DL_GetSocialSceneSoloAnim(int nStep)
{
    if (nStep == 0) return "bored";
    if (nStep == 1) return "sigh";
    return "shrug";
}

void DL_ClearSocialSceneState(object oNpc)
{
    if (!GetIsObjectValid(oNpc)) return;

    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_STEP);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ROLE);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR);
    DeleteLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_POOL);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_ACTIVE);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_PHASE);
    DeleteLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_PLAY_RESULT);
}

int DL_SocialSceneIsRealAnim(string sAnim)
{
    if (sAnim == "") return FALSE;
    if (sAnim == "pause") return FALSE;
    return TRUE;
}

void DL_TickSocialScene(object oNpc, object oAnchor, object oPartner, int bPartnerOnAnchor)
{
    if (!GetIsObjectValid(oNpc) || !GetIsObjectValid(oAnchor)) return;

    string sAnchorTag = GetTag(oAnchor);
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_STATUS) != "on_social_anchor") return;
    if (GetLocalString(oNpc, DL_L_NPC_FOCUS_TARGET) != sAnchorTag) return;

    if (GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR) != sAnchorTag)
    {
        DL_ClearSocialSceneState(oNpc);
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ANCHOR, sAnchorTag);
    }

    string sSceneId = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID);
    if (sSceneId == "")
    {
        sSceneId = DL_SOCIAL_SCENE_DEFAULT;
        SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ID, sSceneId);
    }

    string sRole = "a";
    if (GetLocalString(oNpc, DL_L_NPC_SOCIAL_SLOT) == "b") sRole = "b";
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_ROLE, sRole);

    int nNow = DL_GetAbsoluteMinute();
    if (nNow < GetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE)) return;

    int nStepCount = DL_GetSocialSceneStepCount(sSceneId);
    if (nStepCount <= 0) nStepCount = 1;

    int nStep = nNow % nStepCount;
    int bSolo = !GetIsObjectValid(oPartner) || !bPartnerOnAnchor;
    string sLastAnim = GetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM);
    string sPool = "listener";
    string sAnim = "";
    int nWait = DL_GetSocialSceneStepWaitMinutes(sSceneId, nStep);
    int bActiveSpeaker = FALSE;
    int bPlayResult = FALSE;

    if (bSolo)
    {
        int nSoloStep = nStep % 3;
        if (nSoloStep == 0) sPool = "listener";
        if (nSoloStep == 1) sPool = "sad_speaker";
        if (nSoloStep == 2) sPool = "neutral_speaker";
        sAnim = DL_SelectSocialSceneAnim(sPool, sLastAnim);
        nWait = DL_SOCIAL_SCENE_SOLO_WAIT_MINUTES;
        if (nSoloStep == 0) nWait = 2;
    }
    else
    {
        if ((nStep % 2) == 0 && sRole == "a") bActiveSpeaker = TRUE;
        if ((nStep % 2) == 1 && sRole == "b") bActiveSpeaker = TRUE;

        if (bActiveSpeaker) sPool = DL_GetSocialSceneSpeakerPoolName(nStep);
        else sPool = "listener";

        sAnim = DL_SelectSocialSceneAnim(sPool, sLastAnim);
    }

    if (nWait < 1) nWait = 1;

    if (DL_SocialSceneIsRealAnim(sAnim))
    {
        bPlayResult = PlayCustomAnimation(oNpc, sAnim, FALSE);
    }

    SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_ANIM, sAnim);
    SetLocalString(oNpc, DL_L_NPC_SOCIAL_SCENE_LAST_POOL, sPool);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_ACTIVE, bActiveSpeaker);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_PHASE, nStep);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_PLAY_RESULT, bPlayResult);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_STEP, (nStep + 1) % nStepCount);
    SetLocalInt(oNpc, DL_L_NPC_SOCIAL_SCENE_NEXT_MINUTE, nNow + nWait);
}
