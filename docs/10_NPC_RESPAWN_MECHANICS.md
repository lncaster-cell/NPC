# Ambient Life v2 — NPC Respawn (city population layer)

Дата: 2026-03-13  
Назначение: короткий техдок по механике респауна населения города.

## 1) Канон

- Респаун разрешён только для **безымянных** NPC.
- Именные NPC не респаунятся никогда (смерть постоянная).
- Респаун — это **восполнение дефицита города**, а не воскрешение конкретного трупа.
- `materialization` и `respawn` — разные механики:
  - materialization возвращает уже существующего логически NPC;
  - respawn создаёт нового NPC через `CreateObject`.

## 2) Где живёт логика

- `scripts/ambient_life/al_city_population_inc.nss` — population-layer и respawn-policy.
- Вход в lifecycle:
  - `AL_OnNpcSpawn` -> `AL_CityPopulationOnNpcSpawn`;
  - `AL_OnNpcDeath` -> `AL_CityPopulationOnNpcDeath`.
- Периодический запуск: `AL_AreaTick` (только hot-area) -> `AL_CityPopulationTryRespawnTick`.

Важно: per-NPC heartbeat не используется. Механика встроена в area-centric/event-driven runtime.

## 3) Модель населения (city-scoped)

На модуле (через city-key) поддерживаются:

- `population_target_named`
- `population_target_unnamed`
- `population_alive_named`
- `population_alive_unnamed`
- `population_deficit_unnamed`
- `population_respawn_budget`

Дополнительно используются служебные ключи бюджета/тайминга:

- `population_respawn_budget_max`
- `population_respawn_budget_initialized`
- `population_last_respawn_tick`
- `population_budget_last_regen_tick`

## 4) Правила обновления счётчиков

### Spawn

- При спавне NPC классифицируется как named/unnamed (`al_population_is_named`).
- Увеличивается соответствующий `population_alive_*`.
- `population_target_*` поднимается до нового пика alive, если нужно.
- Для безымянного spawn при наличии дефицита дефицит уменьшается на 1.

### Death

- Для named: уменьшается `population_alive_named` (не ниже 0).
- Для unnamed: уменьшается `population_alive_unnamed` (не ниже 0) и увеличивается `population_deficit_unnamed`.

## 5) Контракт респауна

Респаун возможен только при выполнении всех условий:

1. area в hot-tier;
2. город в мирном состоянии (`alarm desired/live == peace`);
3. `population_deficit_unnamed > 0`;
4. `population_respawn_budget > 0`;
5. выдержан cooldown (`al_city_respawn_cooldown_ticks`);
6. найдена валидная respawn node;
7. node безопасна:
   - в городе нет активных врагов;
   - игрок не слишком близко (`al_city_respawn_safe_dist`).

Если всё прошло:

- вызывается `CreateObject(OBJECT_TYPE_CREATURE, resref, node_location, ...)`;
- после успешного создания уменьшаются budget/deficit (с защитой от ухода в минус);
- новый NPC помечается как unnamed (`al_population_named = FALSE`) и затем входит в стандартный `OnSpawn` lifecycle.

## 6) Контентные параметры

### На area

- `al_city_respawn_tag` или набор `al_city_respawn_tag_<idx>` + `al_city_respawn_node_count`.
- `al_city_respawn_resref` (опционально; при отсутствии берётся city-level fallback).
- `al_city_respawn_cooldown_ticks` (опционально).
- `al_city_respawn_budget_regen_ticks` (опционально).
- `al_city_respawn_safe_dist` (float/int, опционально).

### На module (city-key)

- `population_respawn_resref` — fallback resref для города.
- `population_respawn_budget_max` — максимум бюджета.

## 7) Что НЕ делает этот слой

- Не респаунит named NPC.
- Не materialize-ит скрытых NPC (это другой контур).
- Не инициирует респаун из трупа/персонального heartbeat.
- Не делает world-wide scan.

## 8) Мини-сценарии проверки

1. Убит named NPC -> alive_named уменьшается, респаун не идёт.
2. Убит один unnamed NPC -> deficit +1, позже при выполнении условий создаётся 1 новый unnamed NPC.
3. Массовая гибель unnamed -> восстановление по cooldown+budget, без мгновенного всплеска.
4. Тревога/враги в городе -> респаун отложен.
5. Игрок рядом со spawn node -> респаун отложен.
