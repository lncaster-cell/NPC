// Ambient Life canonical activity metadata imported from PycukSystems.

const int AL_ACT_NPC_HIDDEN = 0;
const int AL_ACT_NPC_ACT_ONE = 1;
const int AL_ACT_NPC_ACT_TWO = 2;
const int AL_ACT_NPC_DINNER = 3;
const int AL_ACT_NPC_MIDNIGHT_BED = 4;
const int AL_ACT_NPC_SLEEP_BED = 5;
const int AL_ACT_NPC_WAKE = 6;
const int AL_ACT_NPC_AGREE = 7;
const int AL_ACT_NPC_ANGRY = 8;
const int AL_ACT_NPC_SAD = 9;
const int AL_ACT_NPC_COOK = 10;
const int AL_ACT_NPC_DANCE_FEMALE = 11;
const int AL_ACT_NPC_DANCE_MALE = 12;
const int AL_ACT_NPC_DRUM = 13;
const int AL_ACT_NPC_FLUTE = 14;
const int AL_ACT_NPC_FORGE = 15;
const int AL_ACT_NPC_GUITAR = 16;
const int AL_ACT_NPC_WOODSMAN = 17;
const int AL_ACT_NPC_MEDITATE = 18;
const int AL_ACT_NPC_POST = 19;
const int AL_ACT_NPC_READ = 20;
const int AL_ACT_NPC_SIT = 21;
const int AL_ACT_NPC_SIT_DINNER = 22;
const int AL_ACT_NPC_STAND_CHAT = 23;
const int AL_ACT_NPC_TRAINING_ONE = 24;
const int AL_ACT_NPC_TRAINING_TWO = 25;
const int AL_ACT_NPC_TRAINER_PACE = 26;
const int AL_ACT_NPC_WWP = 27;
const int AL_ACT_NPC_CHEER = 28;
const int AL_ACT_NPC_COOK_MULTI = 29;
const int AL_ACT_NPC_FORGE_MULTI = 30;
const int AL_ACT_NPC_MIDNIGHT_90 = 31;
const int AL_ACT_NPC_SLEEP_90 = 32;
const int AL_ACT_NPC_THIEF = 33;
const int AL_ACT_NPC_THIEF2 = 36;
const int AL_ACT_NPC_ASSASSIN = 37;
const int AL_ACT_NPC_MERCHANT_MULTI = 38;
const int AL_ACT_NPC_KNEEL_TALK = 39;
const int AL_ACT_NPC_BARMAID = 41;
const int AL_ACT_NPC_BARTENDER = 42;
const int AL_ACT_NPC_GUARD = 43;

const string AL_WP_PACE = "AL_WP_PACE";
const string AL_WP_WWP = "AL_WP_WWP";

// Activity animation rule table (predicate group -> result string).
const string AL_ANIMS_LOOK_AROUND = "lookleft, lookright";
const string AL_ANIMS_DINNER_SEATED = "sitdrink, siteat, sitidle";
const string AL_ANIMS_SLEEP_BED = "laydownB, proneB";
const string AL_ANIMS_KNEEL_TALK = "kneelidle, kneeltalk";
const string AL_ANIMS_BAR_SERVICE = "gettable, lookright, openlock, yawn";
const string AL_ANIMS_MEDITATE = "meditate";
const string AL_ANIMS_SIT_CHAT = "sitfidget, sitidle, sittalk, sittalk01, sittalk02";
const string AL_ANIMS_STEALTH_GROUND = "disableground, sleightofhand, sneak";

int AL_IsLocateWrapperActivity(int nActivity)
{
    return nActivity >= 91 && nActivity <= 98;
}

int AL_IsActivityInGroupLookAround(int nActivity)
{
    return nActivity == AL_ACT_NPC_ACT_ONE ||
           nActivity == AL_ACT_NPC_ACT_TWO ||
           nActivity == AL_ACT_NPC_TRAINING_ONE ||
           nActivity == AL_ACT_NPC_TRAINING_TWO ||
           nActivity == AL_ACT_NPC_TRAINER_PACE ||
           nActivity == AL_ACT_NPC_POST;
}

int AL_IsActivityInGroupDinnerSeated(int nActivity)
{
    return nActivity == AL_ACT_NPC_DINNER || nActivity == AL_ACT_NPC_WAKE;
}

int AL_IsActivityInGroupSleepBed(int nActivity)
{
    return nActivity == AL_ACT_NPC_MIDNIGHT_BED ||
           nActivity == AL_ACT_NPC_SLEEP_BED ||
           nActivity == AL_ACT_NPC_MIDNIGHT_90 ||
           nActivity == AL_ACT_NPC_SLEEP_90;
}

int AL_IsActivityInGroupBarService(int nActivity)
{
    return nActivity == AL_ACT_NPC_BARMAID || nActivity == AL_ACT_NPC_BARTENDER;
}

string AL_GetLocateWrapperCustomAnims(int nActivity)
{
    if (nActivity == 91) return "lookleft, lookright, shrug";
    if (nActivity == 92) return "bored, scratchhead, yawn";
    if (nActivity == 93) return AL_ANIMS_SIT_CHAT;
    if (nActivity == 94) return AL_ANIMS_KNEEL_TALK;
    if (nActivity == 95) return "chuckle, nodno, nodyes, talk01, talk02, talklaugh";
    if (nActivity == 96) return "craft01, dustoff, forge01, openlock";
    if (nActivity == 97) return AL_ANIMS_MEDITATE;
    if (nActivity == 98) return AL_ANIMS_STEALTH_GROUND;
    return "";
}

string AL_GetActivityCustomAnims(int nActivity)
{
    if (AL_IsLocateWrapperActivity(nActivity))
    {
        return AL_GetLocateWrapperCustomAnims(nActivity);
    }

    if (AL_IsActivityInGroupLookAround(nActivity)) return AL_ANIMS_LOOK_AROUND;
    if (AL_IsActivityInGroupDinnerSeated(nActivity)) return AL_ANIMS_DINNER_SEATED;
    if (AL_IsActivityInGroupSleepBed(nActivity)) return AL_ANIMS_SLEEP_BED;

    if (nActivity == AL_ACT_NPC_AGREE) return "chuckle, flirt, nodyes";
    if (nActivity == AL_ACT_NPC_ANGRY) return "intimidate, nodno, talkshout";
    if (nActivity == AL_ACT_NPC_SAD) return "talksad, tired";
    if (nActivity == AL_ACT_NPC_COOK) return "cooking02, disablefront";
    if (nActivity == AL_ACT_NPC_DANCE_FEMALE) return "curtsey, dance01";
    if (nActivity == AL_ACT_NPC_DANCE_MALE) return "bow, dance01, dance02";
    if (nActivity == AL_ACT_NPC_DRUM) return "bow, playdrum";
    if (nActivity == AL_ACT_NPC_FLUTE) return "curtsey, playflute";
    if (nActivity == AL_ACT_NPC_FORGE) return "craft01, dustoff, forge01";
    if (nActivity == AL_ACT_NPC_GUITAR) return "bow, playguitar";
    if (nActivity == AL_ACT_NPC_WOODSMAN) return "*1attack01, kneelidle";
    if (nActivity == AL_ACT_NPC_MEDITATE) return AL_ANIMS_MEDITATE;
    if (nActivity == AL_ACT_NPC_READ) return "sitidle, sitread, sitteat";
    if (nActivity == AL_ACT_NPC_SIT) return AL_ANIMS_SIT_CHAT;
    if (nActivity == AL_ACT_NPC_SIT_DINNER) return "sitdrink, siteat, sitidle, sittalk, sittalk01, sittalk02";
    if (nActivity == AL_ACT_NPC_STAND_CHAT) return "chuckle, lookleft, lookright, shrug, talk01, talk02, talklaugh";
    if (nActivity == AL_ACT_NPC_WWP) return "kneelidle, lookleft, lookright";
    if (nActivity == AL_ACT_NPC_CHEER) return "chuckle, clapping, talklaugh, victory";
    if (nActivity == AL_ACT_NPC_COOK_MULTI) return "cooking01, cooking02, craft01, disablefront, dustoff, forge01, gettable, kneelidle, kneelup, openlock, scratchhead";
    if (nActivity == AL_ACT_NPC_FORGE_MULTI) return "craft01, dustoff, forge01, forge02, gettable, kneeldown, kneelidle, kneelup, openlock";
    if (nActivity == AL_ACT_NPC_THIEF) return "chuckle, getground, gettable, openlock";
    if (nActivity == AL_ACT_NPC_THIEF2) return AL_ANIMS_STEALTH_GROUND;
    if (nActivity == AL_ACT_NPC_ASSASSIN) return "sneak";
    if (nActivity == AL_ACT_NPC_MERCHANT_MULTI) return "bored, getground, gettable, openlock, sleightofhand, yawn";
    if (nActivity == AL_ACT_NPC_KNEEL_TALK) return AL_ANIMS_KNEEL_TALK;
    if (AL_IsActivityInGroupBarService(nActivity)) return AL_ANIMS_BAR_SERVICE;
    if (nActivity == AL_ACT_NPC_GUARD) return "bored, lookleft, lookright, sigh";

    return "";
}

string AL_GetActivityNumericAnims(int nActivity)
{
    if (nActivity == AL_ACT_NPC_ANGRY) return "10";
    if (nActivity == AL_ACT_NPC_SAD) return "9";
    if (nActivity == AL_ACT_NPC_COOK) return "35, 36";
    if (nActivity == AL_ACT_NPC_DANCE_FEMALE) return "27";
    return "";
}

string AL_GetActivityWaypointTag(int nActivity)
{
    if (nActivity == AL_ACT_NPC_TRAINER_PACE)
    {
        return AL_WP_PACE;
    }

    if (nActivity == AL_ACT_NPC_WWP)
    {
        return AL_WP_WWP;
    }

    return "";
}

int AL_ActivityRequiresTrainingPartner(int nActivity)
{
    return nActivity == AL_ACT_NPC_TRAINING_ONE || nActivity == AL_ACT_NPC_TRAINING_TWO;
}

int AL_ActivityRequiresBarPair(int nActivity)
{
    return nActivity == AL_ACT_NPC_BARMAID;
}
