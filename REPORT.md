# Ambient Life — Stage E Report (Bounded Multi-step Routines on Stage D Foundation)

## Реализовано
- Stage D route cache сохранён как основа (`scripts/ambient_life/al_route_inc.nss`):
  - slot -> route tag resolve через `alwp0..alwp5`,
  - controlled invalidation/rebuild,
  - area-scoped ordered chain по `al_step`.
- Добавлен Stage E routine runtime поверх cache:
  - bounded multi-step progression внутри одного slot,
  - исполнение шагов в порядке cached индексов,
  - поддержка route с 1+ шагами,
  - broken/non-contiguous/invalid цепочка уходит в clean fallback.
- Step advance сделан event-driven:
  - `AL_EVENT_ROUTE_REPEAT` используется как controlled post-step hook,
  - событие ставится в конец action queue шага,
  - heartbeat/polling loop не используется.
- Реальная поддержка `al_dur_sec`:
  - на каждом шаге queue строится как `move -> activity(dwell) -> repeat-event`,
  - `al_dur_sec` определяет dwell длительность,
  - при невалидном/нулевом значении применяется bounded fallback duration.

## Новые runtime locals (минимальный набор)
- `al_route_rt_active` — флаг активного routine цикла.
- `al_route_rt_idx` — индекс текущего шага в cached chain.
- `al_route_rt_left` — оставшееся число шагов в текущем bounded cycle.
- `al_route_rt_cycle` — служебный маркер числа запусков routine cycle.

Набор ограничен Stage E потребностями; sleep/reaction/inter-area state не добавлялся.

## Интеграция с Stage B/C/D backbone
- Event-driven модель сохранена.
- NPC для runtime по-прежнему берутся только через area dense registry dispatch.
- Routine progression остаётся строго HOT-only.
- Stage D area-scoped cache foundation не переписан и не размыт.

## Границы Stage E (сознательно не реализовано)
- Межзоновые переходы и linked-area traversal.
- Sleep runtime (`al_bed_id` pipeline).
- Blocked/disturbed/crime/alarm reactions.
- Любая polling/timer-per-NPC архитектура.

Следующий логичный этап: ограниченные межзоновые переходы внутри города поверх текущего bounded routine foundation.
