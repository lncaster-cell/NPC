#ifndef AL_SLEEP_INC_NSS
#define AL_SLEEP_INC_NSS

// Canonical sleep contract (stage 4 runtime):
// - Uses two waypoint tags per bed_id:
//   <bed_id>_approach and <bed_id>_pose
// - No ActionInteractObject-based sleep architecture.
// - If approach or pose waypoint is missing => fallback "sleep on place".

#endif
