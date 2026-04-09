#ifndef DL_V2_ACTIVITY_ANIMATION_CONSTANTS_INC_NSS
#define DL_V2_ACTIVITY_ANIMATION_CONSTANTS_INC_NSS

// Daily Life v2 preserved reference from Daily Life v1 legacy.
// Purpose: keep canonical activity IDs and animation token constants
// from the validated v1 source before deleting broken v1 runtime code.

// Activity IDs (legacy AL reference).
const int DL2_ACT_NPC_HIDDEN = 0;
const int DL2_ACT_NPC_ACT_ONE = 1;
const int DL2_ACT_NPC_ACT_TWO = 2;
const int DL2_ACT_NPC_DINNER = 3;
const int DL2_ACT_NPC_MIDNIGHT_BED = 4;
const int DL2_ACT_NPC_SLEEP_BED = 5;
const int DL2_ACT_NPC_WAKE = 6;
const int DL2_ACT_NPC_AGREE = 7;
const int DL2_ACT_NPC_ANGRY = 8;
const int DL2_ACT_NPC_SAD = 9;
const int DL2_ACT_NPC_COOK = 10;
const int DL2_ACT_NPC_DANCE_FEMALE = 11;
const int DL2_ACT_NPC_DANCE_MALE = 12;
const int DL2_ACT_NPC_DRUM = 13;
const int DL2_ACT_NPC_FLUTE = 14;
const int DL2_ACT_NPC_FORGE = 15;
const int DL2_ACT_NPC_GUITAR = 16;
const int DL2_ACT_NPC_WOODSMAN = 17;
const int DL2_ACT_NPC_MEDITATE = 18;
const int DL2_ACT_NPC_POST = 19;
const int DL2_ACT_NPC_READ = 20;
const int DL2_ACT_NPC_SIT = 21;
const int DL2_ACT_NPC_SIT_DINNER = 22;
const int DL2_ACT_NPC_STAND_CHAT = 23;
const int DL2_ACT_NPC_TRAINING_ONE = 24;
const int DL2_ACT_NPC_TRAINING_TWO = 25;
const int DL2_ACT_NPC_TRAINER_PACE = 26;
const int DL2_ACT_NPC_WWP = 27;
const int DL2_ACT_NPC_CHEER = 28;
const int DL2_ACT_NPC_COOK_MULTI = 29;
const int DL2_ACT_NPC_FORGE_MULTI = 30;
const int DL2_ACT_NPC_MIDNIGHT_90 = 31;
const int DL2_ACT_NPC_SLEEP_90 = 32;
const int DL2_ACT_NPC_THIEF = 33;
const int DL2_ACT_NPC_THIEF2 = 36;
const int DL2_ACT_NPC_ASSASSIN = 37;
const int DL2_ACT_NPC_MERCHANT_MULTI = 38;
const int DL2_ACT_NPC_KNEEL_TALK = 39;
const int DL2_ACT_NPC_BARMAID = 41;
const int DL2_ACT_NPC_BARTENDER = 42;
const int DL2_ACT_NPC_GUARD = 43;

const int DL2_ACT_LOCATE_WRAPPER_MIN = 91;
const int DL2_ACT_LOCATE_WRAPPER_MAX = 98;

// Animation tokens used by legacy activity mappings.
const string DL2_ANIM_1ATTACK01 = "*1attack01";
const string DL2_ANIM_BORED = "bored";
const string DL2_ANIM_BOW = "bow";
const string DL2_ANIM_CHUCKLE = "chuckle";
const string DL2_ANIM_CLAPPING = "clapping";
const string DL2_ANIM_COOKING01 = "cooking01";
const string DL2_ANIM_COOKING02 = "cooking02";
const string DL2_ANIM_CRAFT01 = "craft01";
const string DL2_ANIM_CURTSEY = "curtsey";
const string DL2_ANIM_DANCE01 = "dance01";
const string DL2_ANIM_DANCE02 = "dance02";
const string DL2_ANIM_DISABLEFRONT = "disablefront";
const string DL2_ANIM_DISABLEGROUND = "disableground";
const string DL2_ANIM_DUSTOFF = "dustoff";
const string DL2_ANIM_FLIRT = "flirt";
const string DL2_ANIM_FORGE01 = "forge01";
const string DL2_ANIM_FORGE02 = "forge02";
const string DL2_ANIM_GETGROUND = "getground";
const string DL2_ANIM_GETTABLE = "gettable";
const string DL2_ANIM_INTIMIDATE = "intimidate";
const string DL2_ANIM_KNEELDOWN = "kneeldown";
const string DL2_ANIM_KNEELIDLE = "kneelidle";
const string DL2_ANIM_KNEELTALK = "kneeltalk";
const string DL2_ANIM_KNEELUP = "kneelup";
const string DL2_ANIM_LAYDOWN_B = "laydownB";
const string DL2_ANIM_LOOKLEFT = "lookleft";
const string DL2_ANIM_LOOKRIGHT = "lookright";
const string DL2_ANIM_MEDITATE = "meditate";
const string DL2_ANIM_NODNO = "nodno";
const string DL2_ANIM_NODYES = "nodyes";
const string DL2_ANIM_OPENLOCK = "openlock";
const string DL2_ANIM_PLAYDRUM = "playdrum";
const string DL2_ANIM_PLAYFLUTE = "playflute";
const string DL2_ANIM_PLAYGUITAR = "playguitar";
const string DL2_ANIM_PRONE_B = "proneB";
const string DL2_ANIM_SCRATCHHEAD = "scratchhead";
const string DL2_ANIM_SHRUG = "shrug";
const string DL2_ANIM_SIGH = "sigh";
const string DL2_ANIM_SITEAT = "siteat";
const string DL2_ANIM_SITDRINK = "sitdrink";
const string DL2_ANIM_SITFIDGET = "sitfidget";
const string DL2_ANIM_SITIDLE = "sitidle";
const string DL2_ANIM_SITREAD = "sitread";
const string DL2_ANIM_SITTALK = "sittalk";
const string DL2_ANIM_SITTALK01 = "sittalk01";
const string DL2_ANIM_SITTALK02 = "sittalk02";
const string DL2_ANIM_SITTEAT = "sitteat";
const string DL2_ANIM_SLEIGHTOFHAND = "sleightofhand";
const string DL2_ANIM_SNEAK = "sneak";
const string DL2_ANIM_TALK01 = "talk01";
const string DL2_ANIM_TALK02 = "talk02";
const string DL2_ANIM_TALKLAUGH = "talklaugh";
const string DL2_ANIM_TALKSAD = "talksad";
const string DL2_ANIM_TALKSHOUT = "talkshout";
const string DL2_ANIM_TIRED = "tired";
const string DL2_ANIM_VICTORY = "victory";
const string DL2_ANIM_YAWN = "yawn";

#endif
