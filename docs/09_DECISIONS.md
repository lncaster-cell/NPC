# 09_DECISIONS

## 2026-05 — Area-level dense registry is canonical

Decision:

NPC, waypoint and route lookup in runtime must use area/controller-level dense registries.

Pattern:

```text
al_npc_count + al_npc_0001...
al_route_count + al_route_0001...
al_wp_count + al_wp_0001...
```

Reason:

NWN2 runtime performance is better when objects are resolved once during bootstrap/resync and then reused through local object references.

Consequences:

- tag lookup is allowed only for bootstrap/resync/admin/fallback;
- area scans are allowed only for cold init, dirty resync, audit or maintenance;
- runtime logic must not repeatedly search the world.

---

## 2026-05 — DB is durable storage, not runtime cache

Decision:

Campaign DB / SQLite / external DB must store durable world state, not drive every NPC step.

Reason:

DB access is heavier than locals and should be batched at safe points.

Consequences:

- no DB read/write in route step;
- no DB write for every animation/perception;
- city/clan/role/crime state can be persisted;
- runtime keeps session state in locals/cache.

---

## 2026-05 — Heartbeat is scheduler only

Decision:

Module/area heartbeat may exist only as thin scheduler with early exit.

Reason:

Heartbeat runs repeatedly and becomes expensive when used as AI brain.

Consequences:

- no per-NPC decision tree heartbeat;
- no full area scans in heartbeat;
- scheduler processes bounded jobs only;
- inactive areas should cost almost nothing.

---

## 2026-05 — DelayCommand is not pseudo-heartbeat

Decision:

Do not use recursive `DelayCommand` loops as global simulation mechanism.

Reason:

Delayed commands store script state, can be lost if caller/target becomes invalid, and scale poorly.

Consequences:

- cleanup/resync jobs live on area/module/stable controller;
- NPC-owned delayed cleanup is forbidden unless explicitly safe;
- `AssignCommand` preferred for immediate deferral.

---

## 2026-05 — Daily Life uses action queue, not polling

Decision:

Daily Life must use native action queue and authored anchors where possible.

Reason:

Polling “did NPC reach point” replaces engine behavior with more expensive script behavior.

Consequences:

- use `ActionMoveToObject`/anchors/segments;
- runtime-state is for orchestration/resync/interrupt, not for pathfinding replacement;
- long travel can be simulated off-screen.

---

## 2026-05 — Law system is event-driven

Decision:

Law/crime/witness must be built from engine events and zones, not global witness polling.

Reason:

NWN2 exposes enough signal events: perception, disturbed inventory, damage, death, triggers, equipment.

Consequences:

- OnDisturbed remains inventory/theft layer;
- OnBlocked and OnDisturbed remain separate systems;
- theft/social/noise are separate channels;
- central law router normalizes events;
- law zones define policy.

---

## 2026-05 — External simulator is v1-local and coarse

Decision:

External simulator v1 should be local, simple and coarse-grained.

Preferred stack:

```text
SQLite / local DB
external CLI or desktop process
table dashboard
state tables + event_log
```

Reason:

One developer should not start with distributed service architecture.

Consequences:

- no REST/RPC bridge in v1 unless unavoidable;
- no live dependency in NWN2 hot path;
- simulator runs on world-hour/day/safe-point;
- game uses last known projection if simulator is unavailable.

---

## 2026-05 — Stock NWN2 compiler remains release authority

Decision:

External compilers are helpful, but stock NWN2 toolset compatibility remains the final release criterion.

Reason:

NWN2 toolset compiler is what the module must ultimately survive.

Consequences:

- use conservative NWScript subset;
- avoid compiler-specific extensions;
- maintain include/prototype discipline;
- CI should compile broadly after include changes.
