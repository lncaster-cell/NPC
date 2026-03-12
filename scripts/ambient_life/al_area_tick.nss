#include "al_core_inc"

void main()
{
    // Safety bootstrap hook only (legacy OnHeartbeat wiring).
    // Does not run periodic simulation tick directly.
    AL_OnAreaTickBootstrap(OBJECT_SELF);
}
