# Ambient Life v2 — Статус-аудит (восстановление контекста)

Дата: 2026-03-13  
Область аудита: `README.md`, `docs/*`, `scripts/ambient_life/*`.  
Исключения (по правилу проекта): `third party/*` и компилятор внутри неё **не анализировались**.

## 1) Что уже реализовано в коде (подтверждено)

### 1.1 Ядро runtime и orchestration
- Area lifecycle/tick loop присутствует: `al_area_inc.nss`, `al_area_tick.nss`, `al_core_inc.nss`.
- Event bus + dispatch queue присутствуют: `al_events_inc.nss`, `al_dispatch_inc.nss`.
- Есть bounded-метрики и anti-overflow механики в dispatch/area/runtime locals.

Статус: **Сделано**.

### 1.2 Registry и lookup/cache
- Плотный area registry реализован: `al_registry_inc.nss`.
- Lookup cache реализован: `al_lookup_cache_inc.nss`.
- Поддержка transfer между area при переходах: `AL_TransferNPCRegistry` вызывается в transition post-area хуке.

Статус: **Сделано**.

### 1.3 Route/routine/transition/sleep/activity
- Route runtime + cache + API: `al_route_inc.nss`, `al_route_cache_inc.nss`, `al_route_runtime_api_inc.nss`.
- Transition subsystem: `al_transition_inc.nss`, `al_transition_post_area.nss`.
- Sleep subsystem: `al_sleep_inc.nss`.
- Activity subsystem: `al_activity_inc.nss`, `al_acts_inc.nss`.

Статус: **Сделано**.

### 1.4 Реактивный слой и городская эскалация
- Blocked helper: `al_blocked_inc.nss`, обработчик `al_npc_onblocked.nss`.
- Disturbed/react layer: `al_react_inc.nss`, `al_npc_ondisturbed.nss`.
- City registry/alarm/crime: `al_city_registry_inc.nss`, `al_city_alarm_inc.nss`, `al_city_crime_inc.nss`.
- Продюсеры событий подключены через hooks: `OnDamaged`, `OnDeath`, `OnPhysicalAttacked`, `OnSpellCastAt`.

Статус: **Сделано (локальный city/crime/alarm слой)**.

## 2) Что планировалось и ещё не завершено

## Stage I.3 (следующий этап по проектным документам)
Из `README.md` и `docs/01_PROJECT_OVERVIEW.md`:
1. Reinforcement / guard spawn policy (bounded, без world-wide scan).
2. Surrender / arrest / trial pipeline.
3. Расширение последствий crime incidents.
4. QA smoke для legal/reinforcement цепочки.

Подтверждение в коде:
- В `al_react_inc.nss` есть комментарий про future legal hook.
- Ставится флаг `al_legal_followup_pending` с пометкой `Stage I.3+`.

Статус: **Запланировано, частично подготовлены hooks, полноценная реализация отсутствует**.

## 3) Что закрыто по текущей версии документации

По `README.md` и `docs/01_PROJECT_OVERVIEW.md` закрыты этапы:
- **Stages A–H**.
- **Stage I.0–I.2**.

С практической стороны это согласуется с наличием соответствующих подсистем в `scripts/ambient_life/*` (registry/dispatch/lifecycle/route/transition/sleep/activity/blocked/disturbed/city crime-alarm).

Статус: **Закрыто**.

## 4) Какие вопросы остаются открытыми

1. **Stage I.3 остаётся в Planned**: есть трекер `docs/08_STAGE_I3_TRACKER.md`, но статусы подпунктов пока не переходили в `In Progress/Done`.
2. **Нет отдельного smoke-runbook для legal/reinforcement**: в `docs/03_OPERATIONS.md` пока только общий perf/validation контур.
3. **Каталог runtime-файлов в документации был неполным до этой синхронизации**:
   - отдельно вынесены action-скрипты (`al_action_signal_ud.nss`, `al_action_set_mode.nss`),
   - выделены runtime-утилиты (`al_health_inc.nss`, `al_react_apply_step.nss`, `al_react_resume_reset.nss`),
   - добавлена population-подсистема (`al_city_population_inc.nss`) как часть актуального city layer.

Результат: основной разрыв «документация vs код» смещён с отсутствующих файлов к рабочему бэклогу Stage I.3.

## 5) Рекомендованный порядок восстановления документации

1. Перевести минимум один подпункт `docs/08_STAGE_I3_TRACKER.md` в `In Progress` с owner/date.
2. Добавить `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` (операционный smoke-runbook для I.3).
3. После старта I.3 синхронно обновлять `docs/02_MECHANICS.md`, `docs/03_OPERATIONS.md`, `docs/04_CONTENT_CONTRACTS.md` по каждому завершённому подпункту.
4. Поддерживать каталог runtime-файлов в `docs/07_SCENARIOS_AND_ALGORITHMS.md` как актуальную карту подсистем.

## 6) Итог в одном абзаце

Текущий код отражает зрелую реализацию базового Ambient Life контура до **Stage I.2 включительно**, а ключевой пробел находится в **Stage I.3 (legal/reinforcement)** и в разрыве между README и реально присутствующим набором документов. Для управляемого продолжения разработки нужен короткий трекер Stage I.3 и выравнивание карты документации с фактическим состоянием репозитория.
