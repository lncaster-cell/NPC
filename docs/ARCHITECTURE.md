# Ambient Life — Architecture Canon (Stage A contracts, Stage B core runtime, Stage C LOD, Stage D route baseline, Stage E multi-step routines)

## 1) Scope (Stage A + Stage B + Stage C + Stage D + Stage E status)

Stage A зафиксировал архитектуру и contracts.
Stage B реализовал минимальный core lifecycle runtime поверх этого канона.
Stage C добавил area graph linkage contract и area simulation LOD policy.
Stage D добавил минимальный route layer (cache + baseline execution) строго в рамках `HOT` tier.
Stage E развил его в bounded multi-step routine progression внутри одного slot и одной area.

Обязательные принципы:
- Event-driven оркестрация.
- Один area-level tick loop на area с активным simulation tier (`WARM`/`HOT`), без NPC heartbeat.
- Никаких NPC heartbeat.
- Dense registry на уровне area (`al_npc_count`, `al_npc_<idx>`).
- `OnUserDefined` используется как внутренняя шина событий.
- Слотная модель времени (базовые слоты через `alwp0..alwp5`).
- Персональный временной offset (`al_slot_offset_min`) остаётся canonical field; full per-NPC offset-dispatch остаётся следующими стадиями.
- Агрессивное кэширование и отсутствие repeated area full-scan в hot path.
- Stage E routine runtime исполняется только в `HOT` areas.

---

## 2) Architectural layers (minimal)

### 2.1 Entry scripts
Внешние входы от движка:
- `al_area_onenter`
- `al_area_onexit`
- `al_area_tick`
- `al_mod_onleave`
- `al_npc_onspawn`
- `al_npc_ondeath`
- `al_npc_onud`

### 2.2 Core layer
Core принимает entry-события и управляет lifecycle:
- area lifecycle;
- npc lifecycle;
- slot events/resync dispatch;
- route baseline запуском только для `HOT` area;
- переходами mode/state через runtime-owned locals (`al_last_slot`, `al_last_area`, `al_mode`).

### 2.3 Area Graph + Simulation LOD layer (Stage C)
Минимальный слой интереса зоны:
- area linkage contract через `al_link_count` + `al_link_<idx>`;
- `FREEZE`/`WARM`/`HOT` policy с hysteresis;
- route runtime разрешён только в `HOT`.

### 2.4 Registry/Cache layer
Отвечает за плотный registry area и кэши, чтобы hot path не сканировал зону повторно.

### 2.5 Route cache + bounded routine layer (Stage D/E)
Минимальный route foundation:
- slot -> route tag resolve через `alwp0..alwp5`;
- controlled cache build/rebuild;
- deterministic ordering только по `al_step`;
- bounded multi-step execution через action queue без polling arrival tracking;
- минимальные activity semantics (`al_activity` int code + fallback в `al_default_activity` int code).

### 2.6 Future layers (Stage F+)
- Sleep runtime (`<bed_id>_approach -> <bed_id>_pose`).
- Reactions (blocked/disturbed/crime/alarm).

---

## 3) Event model

Транспорт: `OnUserDefined`.

Внутренний namespace Ambient Life в диапазоне `3100..3107`:
- `3100..3105` — `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`.
- `3106` — `AL_EVENT_RESYNC`.
- `3107` — `AL_EVENT_ROUTE_REPEAT` (Stage E bounded step-advance hook, не heartbeat).

Требования:
1. Все внутренние сигналы Ambient Life передаются event-driven способом.
2. Entry scripts не содержат feature runtime.
3. Route/routine runtime не исполняется в `WARM`/`FREEZE`.

---

## 4) Area simulation tiers (mandatory)

1. `FREEZE`
   - area спит;
   - нет area tick runtime progression;
   - нет route/runtime progression.
2. `WARM`
   - area прогрета как соседняя/быстро достижимая;
   - без route execution;
   - разрешена только лёгкая поддержка cache/state readiness.
3. `HOT`
   - area, где реально находится игрок;
   - route/routine runtime Stage D/E разрешён.

---

## 5) Slot model + route/routine progression

1. Глобальный slot хранится на area в `al_slot`.
2. Для NPC базовые slot-якоря заданы через `alwp0..alwp5`.
3. Runtime отслеживает последний обработанный слот в `al_last_slot`.
4. Stage D/E route cache хранит:
   - активный route tag,
   - cached slot,
   - шаги (`al_route_step_<idx>`),
   - valid marker (`al_route_cache_valid`).
5. Rebuild кэша допускается только контролируемо: `RESYNC`, slot change, route tag change, area mismatch (NPC moved), force rebuild/invalidate.

5. Stage E runtime locals для bounded progression:
   - `al_route_rt_active` — флаг активного routine-цикла текущего slot;
   - `al_route_rt_idx` — текущий индекс шага в cached цепочке;
   - `al_route_rt_left` — сколько шагов осталось в bounded cycle;
   - `al_route_rt_cycle` — служебный marker количества запусков cycle.
6. `AL_EVENT_ROUTE_REPEAT` используется только как controlled step-advance после завершения очереди действий шага.

---

## 6) Caching policy (mandatory)

### 6.1 Hot path rules
- Никаких repeated area full-scan в каждом тике.
- Никаких repeated nearest/tag search как baseline стратегии исполнения route.
- Работа только через registry/cache структуры.

### 6.2 Area dense registry
- `al_npc_count` хранит размер плотного пула.
- `al_npc_<idx>` хранит индексные ссылки на NPC.
- Dispatch событий выполняется через area registry.

### 6.3 Route cache strategy (Stage D/E)
- Cache build использует route tag из текущего slot.
- Stage D cache area-scoped: waypoint считается валидным только если находится в текущей area NPC.
- Waypoints собираются и сортируются только по `al_step`.
- Неконсистентный route (missing/duplicate/non-contiguous step chain) сбрасывается в fallback.
- В normal hot path используется уже cached route descriptor.

### 6.4 Stage E step semantics (`al_dur_sec`)
- Каждый шаг берётся из cached waypoint chain внутри текущей area.
- `al_dur_sec` применяется как dwell-фаза шага через action queue (`move -> activity wait`).
- Продвижение делается bounded repeat-событием в конце очереди действий шага, без polling/heartbeat.

### 6.5 Fallback-first safety
Если маршрут/шаг/активность невалидны:
1. Без краша и без repeated search loop.
2. Fallback к `al_default_activity` (int).
3. Если fallback невалиден — safe idle (`AL_ACTIVITY_IDLE`).



### 6.6 Stage D/E temporary activity codes (int-based)
- Stage D использует минимальный временный набор int кодов без новой activity-системы:
  - `0` = `AL_ACTIVITY_IDLE` (safe fallback),
  - `1` = `AL_ACTIVITY_STAND`,
  - `2` = `AL_ACTIVITY_SIT`,
  - `3` = `AL_ACTIVITY_GUARD`.
- Это baseline для Stage D; richer activity semantics остаются на следующих стадиях.

---

## 7) Stage E boundary (explicit)

Stage E **не** включает:
- cross-area routing / linked-area route traversal;
- sleep runtime;
- reactions/crime/alarm;
- polling-based arrival tracking;
- превращение route runtime в монолитный AI.

Stage E специально сохраняет activity semantics минимальными и area-scoped cache-first foundation для следующего этапа межзоновых переходов и sleep/reactions.
