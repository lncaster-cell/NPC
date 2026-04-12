# Ambient Life v2 — System Invariants & Principles

Дата синхронизации: 2026-04-01  
Источник: `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`, `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`, `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`, `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`, `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`.  
Исключения аудита: `third party/*` и внутренний компилятор не анализируются и не изменяются.

## 1. Глобальные архитектурные инварианты

1. **Heartbeat Gate + Timer Queue + Budgeted Worker**  
   Heartbeat допустим как лёгкий wake-up/dirty-check датчик, а не как главный runtime-контур; отложенные работы планируются через централизованную очередь сроков (`due_time`) и исполняются bounded-worker'ом.
2. **Event-driven orchestration**  
   Переходы между шагами рутины и реакции происходят через события (`OnUserDefined` и профильные hooks).
3. **Bounded processing**  
   Все тяжёлые контуры обязаны иметь budget/cap и не уходить в unbounded-циклы; worker выполняет ограниченный объём задач за проход.
4. **Content/runtime separation**  
   Контент задаёт intent (маршруты, links, bed-id, роли), runtime хранит эфемерное состояние и метрики.

## 2. Инварианты жизненного цикла NPC

- NPC должен входить в area registry только в валидных состояниях и удаляться при выходе/смерти.
- Tier-модель (`FROZEN/WARM/HOT`) определяет интенсивность обработки и maintenance.
- Ручное редактирование runtime locals запрещено: очередь, курсоры, индексы, временные state-флаги.

## 3. Инварианты registry/dispatch

- Registry ограничен по ёмкости area-контекстом.
- Dispatch queue обрабатывается batched-режимом и учитывает overflow/задержки.
- Диагностика miss-rate/overflow является обязательной частью операционной проверки.
- Любая логика, расширяющая dispatch, должна сохранять bounded latency.

## 4. Инварианты route/transition/sleep

- Route строится по slot-маршрутам и выполняется bounded-шагами.
- Route cache имеет TTL/инвалидации и не должен зависать при rebuild.
- Transition выполняется через явно размеченные step-поля и проверяемые endpoint-ы.
- Sleep — отдельный контур: определяется `al_bed_id` и должен завершаться возвратом в routine pipeline.

## 5. Инварианты reactive/city layer

- Blocked/disturbed реакции локальны и не должны разрушать route/schedule канон.
- City crime/alarm эскалация реализуется FSM-подходом, без world-wide scan.
- Alarm должен иметь путь деэскалации (active -> recovery -> normal).
- Персональная routine-машина и city alarm FSM не смешиваются напрямую.

## 6. Инварианты linked graph и контента

- `al_link_count` должен соответствовать фактическому количеству `al_link_*`.
- `al_link_i` обязаны указывать на существующие area tags.
- route steps индексируются последовательно, без пропусков.
- Sleep-разметка (`al_bed_id`) допустима только при наличии корректных waypoint-пар в area.

## 7. Инварианты разработки и аудита

- Любые изменения `scripts/ambient_life/al_*` сопровождаются perf-проверкой S80/S100/S120.
- Документация должна фиксировать:
  1) реализовано,
  2) запланировано,
  3) открытые вопросы,
  4) операционные проверки.
- При аудитах/инспекциях `third party/*` и компилятор внутри неё исключаются из анализа и изменений.

## 8. Инварианты heartbeat и отложенных задач

- Heartbeat разрешён как сервисный «будильник», но не как место тяжёлой логики.
- В неактивных областях heartbeat должен гарантированно отключаться (`SetEventHandler(..., "")`).
- Основной механизм отложенного исполнения — timer-variant: `due_time` + центральная timer queue + budgeted worker.
- Массовая сетка независимых `DelayCommand()` не используется как планировщик: ограничения контекста/`OBJECT_SELF`/жизненного цикла объекта делают её ненадёжной для системного runtime.
