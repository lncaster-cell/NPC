# Ambient Life — Stage D Report (Route Cache + Route Execution Baseline)

## Реализовано
- Route cache subsystem (`scripts/ambient_life/al_route_inc.nss`):
  - slot -> route tag resolve через `alwp0..alwp5`,
  - controlled invalidation/rebuild,
  - cached ordered step references (`al_route_step_<idx>`),
  - minimal descriptor (`tag`, `slot`, `step_count`, `valid`).
- Deterministic route ordering:
  - шаги сортируются только по `al_step`,
  - nearest-based route construction не используется,
  - broken chain (дырки/дубли) уходит в clean fallback.
- Baseline route execution:
  - исполняется только в `HOT` area,
  - запускается на `AL_EVENT_RESYNC` и slot-change событиях,
  - использует action queue sequence (`move -> baseline activity`) без polling arrival tracking.
- Minimal activity baseline:
  - источник активности — waypoint `al_activity`,
  - fallback на `al_default_activity`,
  - при невалидной активности — safe idle.

## Интеграция с Stage B/C backbone
- Event-driven модель сохранена.
- NPC для runtime берутся только через area dense registry dispatch (`al_npc_count` + `al_npc_<idx>`).
- `WARM`/`FREEZE` не исполняют normal route runtime.
- Stage B lifecycle и Stage C LOD поведение не меняются по контракту.

## Политика refresh/invalidation route cache
Rebuild/refresh выполняется только контролируемо:
- `RESYNC` (force rebuild),
- slot change,
- route tag change,
- explicit invalidation (при detected broken cache/reference).

Normal hot path использует уже построенный cache и не пересобирает route на каждом проходе.

## Сознательно отложено (граница Stage D)
- Полноценный multi-step routine engine (Stage E).
- Sleep runtime (`al_bed_id`, bed pipeline) (Stage F).
- Reactions / crime / alarm runtime.
- Богатая activity/социальная/анимационная система.

## Почему foundation готов для Stage E/F
- Route layer маленький и cache-first.
- Route execution ограничен `HOT` tier и не размывает LOD.
- Контракты Stage A/B/C соблюдены, а Stage D даёт стабильную базу для richer routines без переписывания основы.
