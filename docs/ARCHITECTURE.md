# Архитектура Ambient Life v2

## 1. Цель

Симулировать «живое» расписание NPC в NWN2 через события и area-centric runtime без per-NPC heartbeat loops.

## 2. Архитектурные принципы

- **Area-centric execution**: активность координируется из area tick scheduler (`AL_ScheduleAreaTick`).
- **Event-driven orchestration**: NPC получают сигналы через `OnUserDefined`.
- **Bounded processing**: маршруты, реакции и спец-шаги выполняются ограниченно и предсказуемо.
- **Content-configured behavior**: поведение задаётся locals на NPC/waypoints/areas.

## 3. Подсистемы

### 3.1 Lifecycle и tiers (Stage C)
- Константы tiers: `FREEZE=0`, `WARM=1`, `HOT=2`.
- HOT используется для активной симуляции; WARM — облегчённый режим удержания контекста.
- При уходе в FREEZE тик инвалидируется через token-механику.

### 3.2 Registry (Stage B)
- Плотный реестр `al_npc_0..N`, счётчик `al_npc_count`.
- Удаление — через swap-remove для сохранения плотности.
- Ограничение: `AL_MAX_NPCS = 100` на area.

### 3.3 Route engine (Stages D/E)
- Маршрут выбирается по слоту времени (6 слотов в сутки).
- Route cache ограничен `AL_ROUTE_MAX_STEPS = 16`.
- Выполнение routine bounded; при ошибках — безопасный fallback.

### 3.4 Transition subsystem (Stage F)
- Поддержка transition-step:
  - area helper;
  - intra-area teleport.
- После transition выполняется controlled route repeat.

### 3.5 Sleep subsystem (Stage G)
- Sleep-step активируется через `al_bed_id`.
- Используются точки `{bed}_approach` и `{bed}_pose`.
- При неполной разметке — fallback-поведение.

### 3.6 Activity subsystem (Stage H)
- Единый слой применения activity для route-шагов.
- Дефолтная активность задаётся на NPC.

### 3.7 Reactive subsystem (Stages I.0/I.1/I.2)
- I.0: `OnBlocked` → локальный bounded recovery.
- I.1: `OnDisturbed` → bounded override для inventory/theft, затем возврат к routine.
- I.2: локальный слой crime/alarm поверх I.1:
  - bounded классификация инцидента (`none/suspicious/theft/hostile-legal`);
  - area-local alarm state (`al_alarm_state`, `al_alarm_until`, `al_alarm_source`) с деэскалацией по `al_sync_tick`;
  - role split (`civilian/militia/guard`) без giant role framework;
  - guard-path опирается на built-in hostility/faction (`GetIsReactionTypeHostile`, `GetFactionEqual`) перед future legal-цепочкой;
  - debounce anti-spam для повторных `OnDisturbed` инцидентов (actor-local + area-local);
  - bounded локальный fan-out на nearby NPC текущей area (без world scan/spawn).

## 4. Event bus

- Slot events: `3100..3105`
- `3106`: RESYNC
- `3107`: ROUTE_REPEAT
- `3108`: BLOCKED_RESUME

Crime/alarm на Stage I.2 намеренно **не** добавляет новые события шины: эскалация выполняется внутри bounded `OnDisturbed` пути.

## 5. Инварианты

- Нет heartbeat/polling loop на NPC.
- Центральный runtime loop — только area tick scheduler (`AL_ScheduleAreaTick` → `DelayCommand` → `AL_AreaTick`).
- Toolset `OnHeartbeat` не является штатным периодическим путём и не должен дублировать scheduler-цикл.
- Dispatch событий работает по текущему area registry.
- Stage I.2 не включает guard spawn/reinforcements и не включает surrender/arrest/trial (оставлены только future hooks `al_legal_followup_pending`).
