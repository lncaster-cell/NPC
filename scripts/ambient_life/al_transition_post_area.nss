#include "al_events_inc"
#include "al_transition_inc"

void main()
{
    object oNpc = OBJECT_SELF;
    if (!GetIsObjectValid(oNpc))
    {
        return;
    }

    object oFromArea = GetLocalObject(oNpc, "al_transition_post_from_area");
    DeleteLocalObject(oNpc, "al_transition_post_from_area");
    AL_TransitionPostAreaHelper(oNpc, oFromArea);
}
