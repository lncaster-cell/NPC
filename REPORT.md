# Ambient Life — Stage C Report (Area Graph + Simulation LOD Policy)

## Реализовано
- Area graph linkage contract:
  - добавлены простые indexed locals для direct links (`al_link_count`, `al_link_<idx>`),
  - policy использует только depth 0 / depth 1 interest (current + direct links).
- 3-tier area simulation model:
  - `FREEZE` — без area tick progression,
  - `WARM` — лёгкая поддержка runtime readiness без rich simulation,
  - `HOT` — полный текущий runtime (в рамках Stage B foundation).
- Runtime-owned tier state:
  - введён `al_sim_tier` на area,
  - area tier пересчитывается по player presence + linked-area interest.
- Grace / hysteresis:
  - введён `al_warm_until_sync` для краткого warm retention,
  - при потере игрока area не падает мгновенно в `FREEZE`.
- Stage B lifecycle backbone расширен под LOD:
  - slot progression и dispatch событий слотов остаются только в `HOT`,
  - `WARM` делает только maintenance (в т.ч. редкий registry compact),
  - downgrade идёт по цепочке `HOT -> WARM -> FREEZE`.

## Зачем этот этап до route runtime
- Без Stage C route runtime в городе с несколькими улицами/районами и множеством интерьеров будет запускаться в слишком большом числе area.
- LOD policy ограничивает полнотактную симуляцию только player area (`HOT`), сохраняя соседние зоны в дешёвом `WARM` состоянии.
- Это создаёт стабильную базу для следующего этапа (route cache + route execution), где route-система может безопасно опираться на уже ограниченный контур активных area.

## Сознательно отложено
- Route cache/runtime.
- Multi-step routines.
- Sleep runtime.
- Reactions (blocked/disturbed/crime/alarm).
- Любые 4-tier или deep graph/pathfinding расширения.

## Соблюдённые инварианты
- Event-driven orchestration.
- Нет NPC heartbeat.
- Нет per-NPC periodic timers.
- Нет route runtime на этапе LOD.
- Нет deep recursive warming.
- Нет сложной graph DSL/config subsystem.
