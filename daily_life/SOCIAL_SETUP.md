# SOCIAL Builder Setup

SOCIAL supports a simple one-anchor setup and the legacy paired A/B slot setup.

## Simple shared anchor

Use this when an NPC only needs one SOCIAL spot. Set the area local to the waypoint tag:

- Area local `dl_anchor_social = <waypoint tag>`
- Waypoint tag `<waypoint tag>`
- Waypoint local `dl_nav_zone_id = <zone>`
- Optional NPC local `dl_social_partner_tag = <partner npc tag>`

When the optional partner is missing or not yet in the same area, the NPC still walks to the shared SOCIAL waypoint and idles/talks lightly there. Partner absence alone does not force PUBLIC fallback.

## Advanced paired anchors

Use this for two NPCs with fixed A/B spots:

- Area local `dl_anchor_social_a = <slot a waypoint tag>`
- Area local `dl_anchor_social_b = <slot b waypoint tag>`
- NPC A local `dl_social_slot = a`
- NPC B local `dl_social_slot = b`
- Optional NPC local `dl_social_partner_tag = <partner npc tag>`

An NPC with `dl_social_slot = a` tries `dl_anchor_social_a` first. An NPC with `dl_social_slot = b` tries `dl_anchor_social_b` first. If the slot anchor is absent or invalid, the NPC falls back to the simple shared `dl_anchor_social` anchor.

## PUBLIC fallback

SOCIAL falls back to PUBLIC only when SOCIAL markup is broken enough that no SOCIAL target can be resolved:

- no valid social area, including work-area fallback
- no valid slot or shared SOCIAL anchor waypoint
