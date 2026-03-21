#ifndef AL_V1_CONST_INC_NSS
#define AL_V1_CONST_INC_NSS

const string DLV1_L_NPC_FAMILY = "dlv1_npc_family";
const string DLV1_L_NPC_SUBTYPE = "dlv1_npc_subtype";
const string DLV1_L_SCHEDULE_TEMPLATE = "dlv1_schedule_template";
const string DLV1_L_NPC_BASE = "dlv1_npc_base";
const string DLV1_L_NAMED = "dlv1_named";
const string DLV1_L_PERSISTENT = "dlv1_persistent";
const string DLV1_L_PERSONAL_OFFSET_MIN = "dlv1_personal_offset_min";
const string DLV1_L_ALLOWED_DIRECTIVES_MASK = "dlv1_allowed_directives_mask";
const string DLV1_L_OVERRIDE_KIND = "dlv1_override_kind";
const string DLV1_L_DIRECTIVE = "dlv1_current_directive";
const string DLV1_L_ANCHOR_GROUP = "dlv1_current_anchor_group";
const string DLV1_L_DIALOGUE_MODE = "dlv1_dialogue_mode";
const string DLV1_L_SERVICE_MODE = "dlv1_service_mode";
const string DLV1_L_ACTIVITY_KIND = "dlv1_activity_kind";
const string DLV1_L_AREA_TIER = "dlv1_area_tier";
const string DLV1_L_RESYNC_PENDING = "dlv1_resync_pending";
const string DLV1_L_RESYNC_REASON = "dlv1_resync_reason";
const string DLV1_L_DAY_TYPE_OVERRIDE = "dlv1_day_type_override";
const string DLV1_L_LAST_SLOT_REVIEW = "dlv1_last_slot_review";
const string DLV1_L_LAST_SLOT_ASSIGNED = "dlv1_last_slot_assigned";
const string DLV1_L_SLOT_ASSIGNED_NPC = "dlv1_slot_assigned_npc";

const int DLV1_DEBUG_NONE = 0;
const int DLV1_DEBUG_BASIC = 1;
const int DLV1_DEBUG_VERBOSE = 2;
const int DLV1_DEBUG_LEVEL = DLV1_DEBUG_BASIC;

const int DLV1_FAMILY_NONE = 0;
const int DLV1_FAMILY_LAW = 1;
const int DLV1_FAMILY_CRAFT = 2;
const int DLV1_FAMILY_TRADE_SERVICE = 3;
const int DLV1_FAMILY_CIVILIAN = 4;
const int DLV1_FAMILY_ELITE_ADMIN = 5;
const int DLV1_FAMILY_CLERGY = 6;

const int DLV1_SUBTYPE_NONE = 0;
const int DLV1_SUBTYPE_PATROL = 1;
const int DLV1_SUBTYPE_GATE_POST = 2;
const int DLV1_SUBTYPE_INSPECTION = 3;
const int DLV1_SUBTYPE_BLACKSMITH = 4;
const int DLV1_SUBTYPE_ARTISAN = 5;
const int DLV1_SUBTYPE_LABORER = 6;
const int DLV1_SUBTYPE_SHOPKEEPER = 7;
const int DLV1_SUBTYPE_INNKEEPER = 8;
const int DLV1_SUBTYPE_WANDERING_VENDOR = 9;
const int DLV1_SUBTYPE_RESIDENT = 10;
const int DLV1_SUBTYPE_HOMELESS = 11;
const int DLV1_SUBTYPE_SERVANT = 12;
const int DLV1_SUBTYPE_NOBLE = 13;
const int DLV1_SUBTYPE_OFFICIAL = 14;
const int DLV1_SUBTYPE_SCRIBE = 15;
const int DLV1_SUBTYPE_PRIEST = 16;

const int DLV1_SCH_NONE = 0;
const int DLV1_SCH_EARLY_WORKER = 1;
const int DLV1_SCH_SHOP_DAY = 2;
const int DLV1_SCH_TAVERN_LATE = 3;
const int DLV1_SCH_DUTY_ROTATION_DAY = 4;
const int DLV1_SCH_DUTY_ROTATION_NIGHT = 5;
const int DLV1_SCH_WANDERING_VENDOR_WINDOW = 6;
const int DLV1_SCH_CIVILIAN_HOME = 7;

const int DLV1_DAY_WEEKDAY = 1;
const int DLV1_DAY_REST = 2;
const int DLV1_DAY_CRISIS = 3;

const int DLV1_WIN_NONE = 0;
const int DLV1_WIN_SLEEP = 1;
const int DLV1_WIN_MORNING_PREP = 2;
const int DLV1_WIN_WORK_CORE = 3;
const int DLV1_WIN_SERVICE_CORE = 4;
const int DLV1_WIN_PUBLIC_IDLE = 5;
const int DLV1_WIN_SOCIAL = 6;
const int DLV1_WIN_LATE_SOCIAL = 7;
const int DLV1_WIN_DAY_DUTY = 8;
const int DLV1_WIN_NIGHT_DUTY = 9;

const int DLV1_BASE_NONE = 0;
const int DLV1_BASE_HOME = 1;
const int DLV1_BASE_WORKSHOP = 2;
const int DLV1_BASE_SHOP = 3;
const int DLV1_BASE_TAVERN = 4;
const int DLV1_BASE_BARRACKS = 5;
const int DLV1_BASE_TEMPLE = 6;
const int DLV1_BASE_OFFICE = 7;

const int DLV1_AG_NONE = 0;
const int DLV1_AG_SLEEP = 1;
const int DLV1_AG_WORK = 2;
const int DLV1_AG_SERVICE = 3;
const int DLV1_AG_SOCIAL = 4;
const int DLV1_AG_DUTY = 5;
const int DLV1_AG_GATE = 6;
const int DLV1_AG_PATROL_POINT = 7;
const int DLV1_AG_STREET_NEAR_BASE = 8;
const int DLV1_AG_WAIT = 9;
const int DLV1_AG_HIDE = 10;

const int DLV1_DIR_NONE = 0;
const int DLV1_DIR_SLEEP = 1;
const int DLV1_DIR_WORK = 2;
const int DLV1_DIR_SERVICE = 3;
const int DLV1_DIR_SOCIAL = 4;
const int DLV1_DIR_DUTY = 5;
const int DLV1_DIR_PUBLIC_PRESENCE = 6;
const int DLV1_DIR_HOLD_POST = 7;
const int DLV1_DIR_LOCKDOWN_BASE = 8;
const int DLV1_DIR_HIDE_SAFE = 9;
const int DLV1_DIR_ABSENT = 10;
const int DLV1_DIR_UNASSIGNED = 11;

const int DLV1_DLG_NONE = 0;
const int DLV1_DLG_WORK = 1;
const int DLV1_DLG_OFF_DUTY = 2;
const int DLV1_DLG_INSPECTION = 3;
const int DLV1_DLG_LOCKDOWN = 4;
const int DLV1_DLG_HIDE = 5;
const int DLV1_DLG_UNAVAILABLE = 6;

const int DLV1_SERVICE_NONE = 0;
const int DLV1_SERVICE_AVAILABLE = 1;
const int DLV1_SERVICE_LIMITED = 2;
const int DLV1_SERVICE_DISABLED = 3;

const int DLV1_ACT_NONE = 0;
const int DLV1_ACT_SLEEP = 1;
const int DLV1_ACT_WORK = 2;
const int DLV1_ACT_SERVICE_IDLE = 3;
const int DLV1_ACT_SOCIAL = 4;
const int DLV1_ACT_DUTY_IDLE = 5;
const int DLV1_ACT_HIDE = 6;

const int DLV1_OVR_NONE = 0;
const int DLV1_OVR_FIRE = 1;
const int DLV1_OVR_QUARANTINE = 2;

const int DLV1_AREA_FROZEN = 0;
const int DLV1_AREA_WARM = 1;
const int DLV1_AREA_HOT = 2;

const int DLV1_RESYNC_NONE = 0;
const int DLV1_RESYNC_AREA_ENTER = 1;
const int DLV1_RESYNC_TIER_UP = 2;
const int DLV1_RESYNC_SAVE_LOAD = 3;
const int DLV1_RESYNC_TIME_JUMP = 4;
const int DLV1_RESYNC_OVERRIDE_END = 5;
const int DLV1_RESYNC_WORKER = 6;

const int DLV1_BUDGET_HOT = 6;
const int DLV1_BUDGET_WARM = 2;
const int DLV1_BUDGET_FROZEN = 0;

int DLV1_GetDefaultWorkerBudget()
{
    return DLV1_BUDGET_HOT;
}

int DLV1_GetDefaultAreaTierBudget(int nTier)
{
    if (nTier == DLV1_AREA_HOT)
    {
        return DLV1_BUDGET_HOT;
    }
    if (nTier == DLV1_AREA_WARM)
    {
        return DLV1_BUDGET_WARM;
    }
    return DLV1_BUDGET_FROZEN;
}

#endif
