# Ambient Life — Stage F Report (Separate Transition Subsystem after Stage E)

## Реализовано
- Сохранена Stage D/E основа:
  - area-scoped route cache по `alwp0..alwp5`,
  - bounded multi-step progression через `AL_EVENT_ROUTE_REPEAT`.
- Добавлен отдельный runtime-слой `al_transition_inc.nss`, который вызывается только для transition steps.
- Реализованы два канонических механизма переходов:
  1. **Area-to-area helper transition**
     - transition step указывает source/destination helper waypoint tags;
     - runtime делает `move-to-source -> jump-to-destination -> dwell -> repeat`;
     - source обязан быть в текущей area NPC, destination — в другой area.
  2. **Intra-area teleport transition**
     - transition step также указывает пару helper waypoint;
     - runtime делает `move-to-source -> jump-to-destination -> dwell -> repeat`;
     - source и destination обязаны быть в одной area.

## Authoring contract (Stage F)
- Transition step остаётся waypoint в route chain (`al_step`), но объявляется как special action:
  - `al_trans_type` (`1` area helper, `2` intra teleport),
  - `al_trans_src_wp` (tag source helper waypoint),
  - `al_trans_dst_wp` (tag destination helper waypoint).
- Если `al_trans_type` отсутствует/невалиден, шаг обрабатывается как обычный Stage E route step.
- Helper-пары заранее ставятся в toolset и могут переиспользоваться многими NPC.

## Новый runtime state (минимальный)
- `al_trans_rt_active` — маркер активного transition шага.
- `al_trans_rt_type` — тип transition механизма.
- `al_trans_rt_dst` — destination helper waypoint текущего transition.

## Интеграция и границы
- Transition subsystem отделён от обычного route runtime path.
- Stage D area-scoped cache не переписан и не превращён в transition graph.
- HOT/WARM/FREEZE semantics сохранены: route/transition runtime работает только в HOT.
- Heartbeat/polling/per-NPC timer архитектуры не добавлялись.

## Сознательно отложено
- Sleep runtime.
- Blocked/disturbed/crime/alarm reactions.
- Любой новый сложный graph/path subsystem.
