# Ambient Life v2 — NPC Respawn (city population layer)

Дата: 2026-03-13  
<<<<<<< codex/add-npc-respawn-mechanism-7zwt28
Назначение: подробная техническая документация по механике респауна населения города.

---

## 1) Цель и границы механики

Механика респауна нужна, чтобы **восполнять дефицит безымянных жителей** без ломания существующего Ambient Life runtime.

Ключевые требования:

- респаун работает в area-centric/event-driven модели;
- не использует per-NPC heartbeat/polling loop;
- не «воскрешает» конкретные трупы;
- не респаунит named NPC;
- не создаёт бесконечный поток NPC;
- не подменяет собой materialization/LOD lifecycle.

---

## 2) Канон терминов

### Respawn
Создание **нового** NPC через `CreateObject` для восполнения городского дефицита безымянных.

### Materialization
Возврат ранее существующего логического NPC в активную зону без создания нового существа.

> Это разные контуры. Materialization не должен трогать population deficit, а respawn обязан работать через population policy.

---

## 3) Архитектурное место в runtime

### 3.1 Файлы

- `scripts/ambient_life/al_city_population_inc.nss` — population-layer (счётчики, дефицит, бюджет, cooldown, валидация spawn-node, respawn create-path).
- `scripts/ambient_life/al_core_inc.nss` — lifecycle hooks:
  - `AL_OnNpcSpawn` -> `AL_CityPopulationOnNpcSpawn`;
  - `AL_OnNpcDeath` -> `AL_CityPopulationOnNpcDeath`.
- `scripts/ambient_life/al_area_inc.nss` — hot-area tick:
  - `AL_AreaTick` -> `AL_CityPopulationTryRespawnTick`.

### 3.2 Почему именно так

- решение о респауне принимает **городской слой**, не отдельный NPC;
- расчёт делается в уже существующем area tick (bounded runtime);
- нет глобальных world-scan и нет отдельного бесконечного цикла.

---

## 4) Population model (city-scoped)

Состояние хранится module-local ключами с city-префиксом (`AL_CityRegistryCityKey(...)`).

### 4.1 Основные поля
=======
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
>>>>>>> main

- `population_target_named`
- `population_target_unnamed`
- `population_alive_named`
- `population_alive_unnamed`
- `population_deficit_unnamed`
- `population_respawn_budget`

<<<<<<< codex/add-npc-respawn-mechanism-7zwt28
### 4.2 Служебные поля респауна
=======
Дополнительно используются служебные ключи бюджета/тайминга:
>>>>>>> main

- `population_respawn_budget_max`
- `population_respawn_budget_initialized`
- `population_last_respawn_tick`
- `population_budget_last_regen_tick`
<<<<<<< codex/add-npc-respawn-mechanism-7zwt28
- `population_respawn_resref` (fallback)

### 4.3 Инварианты

- `alive_* >= 0`
- `deficit_unnamed >= 0`
- `0 <= respawn_budget <= respawn_budget_max`
- named NPC не может быть целью респауна

---

## 5) Классификация NPC

Источник признака named:

- `al_population_named == TRUE` **или**
- `al_is_named == TRUE`.

Результат кэшируется runtime-метками:

- `al_population_is_named`
- `al_population_classified`
- `al_population_alive_registered`
- `al_population_city_id`

### Важное правило
Если NPC классифицирован как named, его смерть только уменьшает `population_alive_named`; дефицит для респауна не создаётся.

---

## 6) Lifecycle-алгоритмы

### 6.1 OnSpawn (`AL_CityPopulationOnNpcSpawn`)

1. Проверка runtime-NPC и защита от повторной регистрации.
2. Определение `city_id`.
3. Классификация named/unnamed.
4. Инкремент соответствующего `population_alive_*`.
5. Актуализация `population_target_*` (peak alive).
6. Для unnamed: если `deficit_unnamed > 0`, уменьшение дефицита на 1.
7. Инициализация/нормализация бюджета города (`AL_CityPopulationEnsureBudget`).

### 6.2 OnDeath (`AL_CityPopulationOnNpcDeath`)

1. Проверка, что NPC действительно зарегистрирован в population-layer.
2. Для named:
   - `population_alive_named--` (с clamping до 0).
3. Для unnamed:
   - `population_alive_unnamed--` (с clamping до 0);
   - `population_deficit_unnamed++`.

---

## 7) Respawn-контур (tick path)

`AL_CityPopulationTryRespawnTick(oArea)` вызывается только для hot-area.

### 7.1 Pre-checks (порядок)

1. area валидна и HOT.
2. город в мирном состоянии:
   - `al_city_alarm_desired_state == peace`
   - `al_city_alarm_live_state == peace`
3. `population_deficit_unnamed > 0`.
4. cooldown выдержан (`al_city_respawn_cooldown_ticks`, иначе default).
5. бюджет положительный (`population_respawn_budget > 0`).
6. при необходимости выполнен budget regen (`al_city_respawn_budget_regen_ticks`).
7. найдена валидная respawn node.
8. node безопасна:
   - `AL_CityRegistryEnemyCount(oArea) == 0`;
   - игроки дальше безопасной дистанции (`al_city_respawn_safe_dist`).
9. определён resref:
   - сначала area-local `al_city_respawn_resref`;
   - затем city fallback `population_respawn_resref`.

### 7.2 Create-path

При успешном `CreateObject`:

- уменьшается budget (не ниже 0);
- уменьшается deficit (не ниже 0);
- фиксируется `population_last_respawn_tick`;
- новому NPC ставится `al_population_named = FALSE`;
- дальше он проходит обычный `OnSpawn` и регистрируется в Ambient Life штатно.

---

## 8) Контракт respawn nodes

Поддерживаются два режима:

1. Один узел:
   - `al_city_respawn_tag`
2. Несколько узлов:
   - `al_city_respawn_node_count`
   - `al_city_respawn_tag_0..N-1`

Ограничения:

- узел должен существовать;
- узел должен быть в той же area;
- узел должен пройти safety-check;
- спавн в произвольной точке мира не допускается.

---

## 9) Бюджет и скорость восстановления

### 9.1 Budget init

`population_respawn_budget` инициализируется один раз на город через `population_respawn_budget_initialized`.

### 9.2 Budget max

`population_respawn_budget_max` задаёт верхний предел (если не задан, используется дефолт).

### 9.3 Regen

Каждые `al_city_respawn_budget_regen_ticks` бюджет может восстановиться на +1 (до max).

### 9.4 Cooldown

`al_city_respawn_cooldown_ticks` ограничивает частоту попыток фактического респауна.

Эта комбинация обеспечивает постепенное восстановление после массовых потерь и исключает «моментальную печать» населения.

---

## 10) Конфигурация для контента

### 10.1 Area locals

Обязательный минимум для фактического респауна:

- respawn node (`al_city_respawn_tag` или индексированный набор)
- resref (`al_city_respawn_resref` или city fallback)

Опциональные настройки:

- `al_city_respawn_cooldown_ticks`
- `al_city_respawn_budget_regen_ticks`
- `al_city_respawn_safe_dist` (float/int)

### 10.2 Module/city locals

- `population_respawn_resref`
- `population_respawn_budget_max`

---

## 11) Поведение по сценарию

### A. Смерть named NPC

- `alive_named` уменьшается;
- `deficit_unnamed` не меняется;
- респаун не запускается этим событием.

### B. Смерть одного unnamed NPC

- `alive_unnamed--`, `deficit_unnamed++`;
- позже, при валидных условиях и бюджете, создаётся 1 unnamed NPC.

### C. Массовые потери unnamed

- дефицит растёт быстро;
- восстановление идёт постепенно через cooldown + budget + regen.

### D. Неактивная area (LOD/materialization)

- materialization работает отдельно;
- respawn-контур не заменяет materialization.

### E. Тревога/угроза

- при alarm state > peace или активных врагах respawn откладывается.

---

## 12) Ограничения и анти-паттерны

Нельзя:

- респаунить named NPC;
- принимать решение о респауне в трупе/NPC heartbeat;
- спавнить NPC перед игроком;
- убирать budget/cooldown/safety ограничения;
- смешивать respawn и materialization в один контур.

---

## 13) Debug/операторская проверка (минимум)

Проверить в рантайме:

1. После смерти unnamed растёт `population_deficit_unnamed`.
2. При активной тревоге respawn не происходит.
3. При нулевом бюджете spawn не происходит до regen.
4. При появлении нового unnamed через respawn дефицит снижается.
5. Восстановление после «вайпа» идёт ступенчато, не burst-спайком.

Рекомендуется отдельно добавить smoke-runbook для perf/операторского QA (S80/S100/S120).

---

## 14) Связанные документы

- `docs/02_MECHANICS.md`
- `docs/03_OPERATIONS.md`
- `docs/04_CONTENT_CONTRACTS.md`
- `docs/09_PLANNED_MECHANISMS_RESTORED.md`
- `scripts/ambient_life/al_city_population_inc.nss`
=======

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
>>>>>>> main
