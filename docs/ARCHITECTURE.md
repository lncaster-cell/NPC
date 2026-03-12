# Архитектура Ambient Life v2

## 1. Цель

Симулировать «живое» расписание NPC в NWN2 через события и area-centric runtime без per-NPC heartbeat loops.

## 2. Архитектурные принципы

- **Area-centric execution**: активность координируется из area tick.
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

### 3.7 Reactive subsystem (Stages I.0/I.1)
- I.0: `OnBlocked` → локальный bounded recovery.
- I.1: `OnDisturbed` → bounded override для inventory/theft, затем возврат к routine.

## 4. Event bus

- Slot events: `3100..3105`
- `3106`: RESYNC
- `3107`: ROUTE_REPEAT
- `3108`: BLOCKED_RESUME

## 5. Инварианты

- Нет heartbeat/polling loop на NPC.
- Центральный runtime loop — только area tick (`DelayCommand`).
- Dispatch событий работает по текущему area registry.
