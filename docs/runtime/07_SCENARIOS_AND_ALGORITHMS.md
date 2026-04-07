# Ambient Life v2 — Сценарии, алгоритмы, системы и механики (каталог)

Дата обновления: 2026-04-03  
Цель: синхронизировать карту сценариев с фактическим runtime-контуром `scripts/daily_life/*`.

> Для обратной совместимости со старыми design-упоминаниями `al_*` см. `docs/runtime/12B_DAILY_LIFE_V1_LEGACY_TO_RUNTIME_MAPPING.md`.

## 1. Системы (верхний уровень)

1. **Core + area lifecycle**
   - Файлы: `dl_on_load.nss`, `dl_area_enter.nss`, `dl_area_exit.nss`, `dl_area_tick.nss`, `dl_area_inc.nss`.
2. **Worker / orchestration / service includes**
   - Файлы: `dl_worker_inc.nss`, `dl_types_inc.nss`, `dl_const_inc.nss`, `dl_util_inc.nss`, `dl_log_inc.nss`.
3. **Routine pipeline (schedule/activity/anchor/materialize)**
   - Файлы: `dl_schedule_inc.nss`, `dl_activity_inc.nss`, `dl_anchor_inc.nss`, `dl_materialize_inc.nss`.
4. **Resolver / resync / override / slot handoff**
   - Файлы: `dl_resolver_inc.nss`, `dl_resync_inc.nss`, `dl_override_inc.nss`, `dl_slot_handoff_inc.nss`.
5. **Interaction слой**
   - Файлы: `dl_interact_inc.nss`.
6. **Smoke / диагностика**
   - Файлы: `dl_smoke_milestone_a.nss`, `dl_smoke_step_e.nss`.

## 2. Разработанные сценарии (runtime)

### 2.1 Базовый lifecycle сценарий
- Module load поднимает runtime-контекст.
- Area enter/exit обновляет участие NPC в area-орchestration.
- Area heartbeat/tick двигает bounded-обработку.

### 2.2 Сценарий routine по слотам суток
- Slot-hand-off выбирает активный интервал расписания.
- Schedule + activity формируют поведение NPC в текущем слоте.

### 2.3 Сценарий маршрута/перепривязки
- Resolver проверяет возможность шага.
- Anchor/materialize используют безопасную перепривязку, если требуется.
- Resync восстанавливает рутину после локального рассинхрона.

### 2.4 Сценарий blocked/disturbed/interact
- Взаимодействия проходят через `dl_interact_inc.nss`.
- Resolver и override применяют временные ограничения/замены поведения.

### 2.5 Сценарий population/runtime recovery
- Worker-контур обрабатывает сервисные задачи bounded-пачками.
- Восстановление состояния после локальных ошибок идёт через resync-пайплайн.

### 2.6 Smoke validation
- `dl_smoke_milestone_a.nss`: базовая проверка Milestone A.
- `dl_smoke_step_e.nss`: шаг E / branch-проверки для base-lost/resync веток.

## 3. Алгоритмы и стратегии (что реально используется)

1. **Bounded worker processing** — пакетная обработка без unbounded-циклов.
2. **Area-centric orchestration** — координация на уровне area, а не per-NPC loop.
3. **Resolver-first transitions** — сначала проверка/разрешение шага, затем применение.
4. **Resync contract** — явный путь возврата к валидной рутине.
5. **Override as temporary policy** — временные отклонения без переписывания ядра рутины.

## 4. Событийные контракты (внутренний bus)

- Slot events и handoff-события: через `dl_slot_handoff_inc.nss`.
- Service/resync события: через `dl_resync_inc.nss` и `dl_worker_inc.nss`.
- Interaction-triggered события: через `dl_interact_inc.nss` и resolver-пайплайн.

## 5. Механики: статус синхронизации

- **Реализованы:** lifecycle hooks, bounded worker, schedule/activity, resolver/resync, override, interaction слой, smoke-пакет Milestone A.
- **В процессе roadmap (Stage I.3+):** расширение legal/reinforcement-связок и дальнейший incident-пакет.

## 6. Источники правды

1. Runtime поведение: `scripts/daily_life/*`.
2. Канон механик и операционных требований: `docs/runtime/02_MECHANICS.md`, `docs/runtime/03_OPERATIONS.md`, `docs/runtime/04_CONTENT_CONTRACTS.md`.
3. Legacy-обратная совместимость по названиям: `docs/runtime/12B_DAILY_LIFE_V1_LEGACY_TO_RUNTIME_MAPPING.md`.
