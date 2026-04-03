# Ambient Life v2 — NPC Respawn (city population layer)

Дата: 2026-03-14  
Назначение: техническая документация по механике респауна населения города.

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

- `scripts/daily_life/dl_area_inc.nss` — population-layer (счётчики, дефицит, бюджет, cooldown, валидация spawn-node, respawn create-path).
- `scripts/daily_life/dl_worker_inc.nss` — lifecycle hooks:
  - `AL_OnNpcSpawn` -> `AL_CityPopulationOnNpcSpawn`;
  - `AL_OnNpcDeath` -> `AL_CityPopulationOnNpcDeath`.
- `scripts/daily_life/dl_area_inc.nss` — hot-area tick:
  - `AL_AreaTick` -> `AL_CityPopulationTryRespawnTick`.

### 3.2 Почему именно так

- решение о респауне принимает **городской слой**, не отдельный NPC;
- расчёт делается в уже существующем area tick (bounded runtime);
- нет глобальных world-scan и нет отдельного бесконечного цикла.

---

## 4) Population model (city-scoped)

Состояние хранится module-local ключами с city-префиксом (`AL_CityRegistryCityKey(...)`).

### 4.1 Основные поля

- `population_target_named`
- `population_target_unnamed`
- `population_alive_named`
- `population_alive_unnamed`
- `population_deficit_unnamed`
- `population_respawn_budget`

### 4.2 Служебные поля респауна

- `population_respawn_budget_max`
- `population_respawn_budget_initialized`
- `population_last_respawn_tick`
- `population_budget_last_regen_tick`
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

Результат классификации влияет только на population counters и eligibility респауна.

---

## 6) Правила обновления счётчиков

### Spawn

- При спавне NPC классифицируется как named/unnamed.
- Увеличивается соответствующий `population_alive_*`.
- `population_target_*` поднимается до нового пика alive, если нужно.
- Для безымянного spawn при наличии дефицита дефицит уменьшается на 1.

### Death

- Для named: уменьшается `population_alive_named` (не ниже 0).
- Для unnamed: уменьшается `population_alive_unnamed` (не ниже 0) и увеличивается `population_deficit_unnamed`.

---

## 7) Контракт респауна

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

---

## 8) Budget / cooldown / regen

- `population_respawn_budget` расходуется на каждый успешный respawn.
- `population_respawn_budget_max` задаёт верхнюю границу бюджета.
- Каждые `al_city_respawn_budget_regen_ticks` бюджет может восстановиться на +1 (до max).
- `al_city_respawn_cooldown_ticks` ограничивает частоту попыток фактического респауна.

Эта комбинация обеспечивает постепенное восстановление после массовых потерь и исключает «моментальную печать» населения.

---

## 9) Контентные параметры

### 9.1 На area

- `al_city_respawn_tag` или набор `al_city_respawn_tag_<idx>` + `al_city_respawn_node_count`.
- `al_city_respawn_resref` (опционально; при отсутствии берётся city-level fallback).
- `al_city_respawn_cooldown_ticks` (опционально).
- `al_city_respawn_budget_regen_ticks` (опционально).
- `al_city_respawn_safe_dist` (float/int, опционально).

### 9.2 На module (city-key)

- `population_respawn_resref` — fallback resref для города.
- `population_respawn_budget_max` — максимум бюджета.

---

## 10) Что НЕ делает этот слой

- Не респаунит named NPC.
- Не materialize-ит скрытых NPC (это другой контур).
- Не инициирует респаун из трупа/персонального heartbeat.
- Не делает world-wide scan.

---

## 11) Мини-сценарии проверки

1. Убит named NPC -> `alive_named` уменьшается, респаун не идёт.
2. Убит один unnamed NPC -> `deficit_unnamed` +1, позже при выполнении условий создаётся 1 новый unnamed NPC.
3. Массовая гибель unnamed -> восстановление по cooldown+budget, без мгновенного всплеска.
4. Тревога/враги в городе -> респаун отложен.
5. Игрок рядом со spawn node -> респаун отложен.

---

## 12) Связанные документы

- `docs/02_MECHANICS.md`
- `docs/03_OPERATIONS.md`
- `docs/04_CONTENT_CONTRACTS.md`
- `scripts/daily_life/dl_area_inc.nss`
