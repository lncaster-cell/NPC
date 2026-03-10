# Ambient Life — Architecture Canon (Stage A contracts, Stage B core runtime)

## 1) Scope (Stage A + Stage B status)

Stage A зафиксировал архитектуру и contracts.
Stage B реализовал минимальный core lifecycle runtime поверх этого канона (без route/sleep/reaction runtime).

Обязательные принципы:
- Event-driven оркестрация.
- Один area-level tick только при наличии игроков (`al_player_count > 0`).
- Никаких NPC heartbeat.
- Dense registry на уровне area (`al_npc_count`, `al_npc_<idx>`).
- `OnUserDefined` используется как внутренняя шина событий.
- Слотная модель времени (базовые слоты через `alwp0..alwp5`).
- Персональный временной offset (`al_slot_offset_min`) на NPC.
- Агрессивное кэширование и отсутствие повторных area full-scan в hot path.
- Sleep через `approach/pose` waypoints (`<bed_id>_approach`, `<bed_id>_pose`).
- Никакого `rest`/`OnRested` в core.

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

На Stage B эти entry scripts подключены к core dispatcher для lifecycle/tick/OnUD baseline.

### 2.2 Core layer
Core принимает entry-события и управляет lifecycle:
- area lifecycle;
- npc lifecycle;
- запуск slot processing;
- переходы mode/state через runtime-owned locals (`al_last_slot`, `al_last_area`, `al_mode`).

### 2.3 Registry/Cache layer
Отвечает за плотный registry area и кэши, чтобы hot path не сканировал зону повторно.

### 2.4 Feature routes/routines/sleep/reactions
- Routes: выбор и исполнение route steps.
- Routines: multi-step поведение внутри активного slot.
- Sleep: отдельный pipeline через `approach -> pose`.
- Reactions: blocked/disturbed/crime/alarm события на следующих этапах.

---

## 3) Event model

Транспорт: `OnUserDefined`.

Минимальные namespace-группы:
- `AL_EVT_AREA_*` — события area lifecycle/tick.
- `AL_EVT_NPC_*` — события NPC lifecycle.
- `AL_EVT_SLOT_*` — переходы и обработка slot.
- `AL_EVT_ROUTE_*` — route/cache/invalidation.
- `AL_EVT_SLEEP_*` — sleep pipeline.
- `AL_EVT_REACT_*` — реакции (blocked/disturbed/crime/alarm).
- `AL_EVT_DEBUG_*` — диагностика.

### 3.1 Canonical internal IDs (implemented in Stage B)

Внутренний OnUserDefined namespace Ambient Life Stage B закреплён в диапазоне `3100..3107`:
- `3100..3105` — `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5` (заняты).
- `3106` — `AL_EVENT_RESYNC` (занят).
- `3107` — `AL_EVENT_ROUTE_REPEAT` (зарезервирован под Stage C+ route runtime, без реализации в Stage B).

Правило namespace discipline:
- Другие внутренние подсистемы модуля не должны произвольно использовать `3100..3107`.
- Расширения Ambient Life вне Stage B должны использовать отдельные выделенные диапазоны/резервы с явной фиксацией в docs перед использованием.

Требования:
1. Все внутренние сигналы Ambient Life передаются event-driven способом.
2. Entry scripts не содержат feature runtime.
3. Stage B реализует только lifecycle/slot orchestration backbone; feature runtime остаётся на следующих стадиях.

---

## 4) Slot model + routines

1. Глобальный slot хранится на area в `al_slot`.
2. Для NPC базовые slot-якоря заданы через `alwp0..alwp5`.
3. Индивидуальное смещение NPC задаётся `al_slot_offset_min`.
4. Внутри одного slot допускаются multi-step routines (через `al_step`, `al_activity`, `al_dur_sec`).
5. Runtime должен отслеживать последний обработанный слот через `al_last_slot`.

---

## 5) Caching policy (mandatory)

### 5.1 Hot path rules
- Никаких повторных area full-scan в каждом тике.
- Работа только через registry/cache структуры.
- Invalidation выполняется событиями lifecycle, а не периодическим пересканом.

### 5.2 Area dense registry
- `al_npc_count` хранит размер плотного пула.
- `al_npc_<idx>` хранит индексные ссылки на NPC.
- Обновление registry только на событиях enter/leave/spawn/death.

### 5.3 NPC runtime cache
- `al_last_slot`, `al_last_area`, `al_mode` считаются runtime-owned кэшем состояния.
- На Stage B `al_mode` используется как строковое поле; baseline-значение при spawn — `"idle"`.
- Полноценная canonical mode-модель не вводится на Stage B и откладывается на следующие стадии.
- Эти поля используются для дешёвых проверок перехода, без повторного вычисления/поиска.

### 5.4 Route/sleep cache
- Разрешён кэш route/sleep lookup результатов.
- При невалидности кэша сначала invalidation/rebuild, затем fallback.

### 5.5 Fallback-first safety
Если маршрут/шаг/точка сна не найдены:
1. Не падать и не запускать дорогое сканирование в loop.
2. Перейти в безопасный fallback (`al_default_activity` как int activity ID или sleep on place).
3. Проставить debug-сигнал для диагностики.

---

## 6) Sleep policy

- Канон сна: `<bed_id>_approach -> <bed_id>_pose`.
- При отсутствии валидной пары — sleep on place.
- `ActionInteractObject` не используется как базовый механизм сна.

---

## 7) Non-goals (Stage B boundary)

- Нет runtime route execution.
- Нет runtime routine execution.
- Нет runtime sleep execution.
- Нет runtime реакций.
- Нет возврата к legacy монолитной runtime-модели; Stage B остаётся минимальным orchestration фундаментом.
