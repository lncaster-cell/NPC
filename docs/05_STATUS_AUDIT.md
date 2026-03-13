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

1. **Нет явного трекера задач Stage I.3** (чек-листа статусов по подпунктам).
2. **Нет отдельного операционного smoke-документа** именно для legal/reinforcement цепочки.
3. **В README перечислены документы, которых сейчас нет в репозитории**:
   - `docs/ARCHITECTURE.md`
   - `docs/TECH_PASSPORT.md`
   - `docs/IMPLEMENTATION_ROADMAP.md`
   - `docs/MECHANICS_DESIGN_BRIEFS.md`
   - `docs/TOOLSET_CONTRACT.md`
   - `docs/PERF_RUNBOOK.md`

Это и создаёт эффект «контекст утерян / неполная документация».

## 5) Рекомендованный порядок восстановления документации

1. Создать `docs/06_STAGE_I3_TRACKER.md`:
   - `Planned / In Progress / Done / Blocked` по 4 подпунктам Stage I.3.
2. Создать `docs/07_DECISIONS_LOG.md`:
   - короткие ADR-записи по спорным решениям (legal pipeline, reinforcement limits, escalation boundaries).
3. Вынести в `docs/08_GAP_MAP.md`:
   - «документ заявлен в README, но отсутствует в repo», с владельцем и сроком восстановления.
4. Обновить README так, чтобы он ссылался только на реально существующие документы + этот аудит.

## 6) Итог в одном абзаце

Текущий код отражает зрелую реализацию базового Ambient Life контура до **Stage I.2 включительно**, а ключевой пробел находится в **Stage I.3 (legal/reinforcement)** и в разрыве между README и реально присутствующим набором документов. Для управляемого продолжения разработки нужен короткий трекер Stage I.3 и выравнивание карты документации с фактическим состоянием репозитория.
