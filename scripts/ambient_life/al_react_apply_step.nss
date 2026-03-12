#include "al_activity_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    int nStepActivity = GetLocalInt(oNpc, "al_react_step_activity");
    int nDurSec = GetLocalInt(oNpc, "al_react_step_dur");
    DeleteLocalInt(oNpc, "al_react_step_activity");
    DeleteLocalInt(oNpc, "al_react_step_dur");

    AL_ActivityApplyStep(oNpc, nStepActivity, nDurSec);
}
