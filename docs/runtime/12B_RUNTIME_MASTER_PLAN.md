# Ambient Life v2 — Доменная детализация B: runtime-архитектура и операции

Дата: 2026-03-14
Версия: 3 (роль уточнена: runtime master summary)
Статус: доменная runtime-детализация (не главный вход; главный канон в `17`)
Область: `README.md`, `docs/*`, `scripts/daily_life/*`

---

> Этот документ является доменной детализацией. Общая каноническая карта проекта фиксируется в `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`, а `docs/entry/01_PROJECT_OVERVIEW.md` используется только как навигационный индекс.

## 0) Для кого и зачем этот документ

Этот документ предназначен для агента/разработчика, который открывает репозиторий впервые и должен:
- быстро понять идею и границы системы;
- увидеть, какие механики уже реализованы, а какие планируются;
- понять архитектурные решения и причины этих решений;
- знать, где контент, где runtime, где эксплуатация и QA;
- уметь восстановить runtime-контур и операционные зависимости без чтения деталей по всем профильным документам.

Идея этого файла: **сводка по runtime («что / почему / как / где / что дальше»), которая читается после `01_PROJECT_OVERVIEW` и вместе с профильными источниками**.

---

## 1) Executive summary (за 2 минуты)

1. Ambient Life v2 — это area-centric + event-driven система симуляции жизни NPC в NWN2.
2. Heartbeat используется как лёгкий Gate (wake-up/dirty-check), а отложенные работы идут через Timer Queue + Budgeted Worker (bounded dispatch).
3. Реализованы базовые контуры до Stage I.2: lifecycle, registry/dispatch, route/transition, sleep/activity, blocked/disturbed, local crime/alarm, population respawn.
4. Основной следующий этап — Stage I.3: reinforcement policy + legal pipeline (surrender/arrest/case intake/trial/sentence) + расширение последствий преступлений + отдельный QA smoke.
5. Главные принципы: bounded processing, отсутствие world-wide full scan, разделение контента и runtime, обязательная наблюдаемость через метрики.

---

## 2) Источники, которые были объединены

Этот master plan синтезирует и нормализует информацию из:
- `docs/runtime/02_MECHANICS.md`
- `docs/runtime/03_OPERATIONS.md`
- `docs/runtime/04_CONTENT_CONTRACTS.md`
- `docs/governance/18_REBUILD_RESET_CONTEXT.md`
- `docs/runtime/06_SYSTEM_INVARIANTS.md`
- `docs/runtime/07_SCENARIOS_AND_ALGORITHMS.md`
- `docs/runtime/10_NPC_RESPAWN_MECHANICS.md`
- `docs/governance/10_DECISIONS_LOG.md`

Примечание: этот том является сводным runtime-документом; при изменениях профильных документов (`02/03/04/06/07/10`) синхронизация выполняется в этот файл, чтобы не дублировать нормативную логику в нескольких местах.

Дополнительная профильная детализация redesign Daily Life vNext вынесена в `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`. Этот документ не заменяет `12B`, а фиксирует отдельный нормативный слой новой модели повседневной жизни NPC.

---

## 3) Продуктовая идея и замысел автора

### 3.1 Что симулируется
Система симулирует «фоновую жизнь» NPC:
- суточные рутины;
- перемещение по маршрутам;
- переходы между area;
- сон и активность;
- реакции на помехи/инциденты;
- реакцию города на преступность;
- временные внешние городские состояния через единый incident context;
- восстановление безымянного населения.

### 3.2 Почему архитектура именно такая
Ключевая проблема: per-NPC heartbeat плохо масштабируется и тяжело контролируется при росте числа NPC.

Выбранный ответ:
- area-centric orchestration (управление сверху, а не «каждый NPC сам по себе»);
- heartbeat как лёгкий gate-сигнал, а не постоянный runtime-loop;
- timer-variant для отложенных задач: `due_time` -> центральная очередь -> budgeted worker;
- bounded budgets/caps для всех «дорогих» операций;
- explicit diagnostics, чтобы поведение наблюдалось, а не угадывалось.

### 3.3 Что считается успехом
- живой, но предсказуемый мир;
- отсутствие бесконечных эскалаций;
- управляемая производительность;
- прозрачная эволюция механик по стадиям roadmap.

---

## 4) Архитектура системы (карта подсистем)

## 4.1 Слои
1. **Core lifecycle слой** — area tick, tiers, жизненный цикл.
2. **Registry/dispatch слой** — регистрация NPC, очередь событий, маршрутизация runtime-сигналов.
3. **Route/sleep/activity слой** — повседневное поведение NPC.
4. **Reactive/incident/city слой** — disturbed/blocked, crime/alarm как первый incident-type, единый incident context, role assignments.
5. **Population слой** — восстановление unnamed-дефицита (respawn policy).

## 4.2 Файловая карта runtime
### Entry points / hooks
- `scripts/daily_life/dl_on_load.nss`
- `scripts/daily_life/dl_area_enter.nss`
- `scripts/daily_life/dl_area_exit.nss`
- `scripts/daily_life/dl_area_tick.nss`

### Core runtime includes
- `scripts/daily_life/dl_area_inc.nss`
- `scripts/daily_life/dl_worker_inc.nss`
- `scripts/daily_life/dl_types_inc.nss`
- `scripts/daily_life/dl_const_inc.nss`
- `scripts/daily_life/dl_util_inc.nss`
- `scripts/daily_life/dl_log_inc.nss`

### Behavior / schedule / resolver
- `scripts/daily_life/dl_schedule_inc.nss`
- `scripts/daily_life/dl_activity_inc.nss`
- `scripts/daily_life/dl_resolver_inc.nss`
- `scripts/daily_life/dl_resync_inc.nss`
- `scripts/daily_life/dl_override_inc.nss`
- `scripts/daily_life/dl_slot_handoff_inc.nss`
- `scripts/daily_life/dl_anchor_inc.nss`
- `scripts/daily_life/dl_interact_inc.nss`
- `scripts/daily_life/dl_materialize_inc.nss`

### Smoke / verification scripts
- `scripts/daily_life/dl_smoke_milestone_a.nss`
- `scripts/daily_life/dl_smoke_step_e.nss`


## 4.3 Поток управления (упрощённо)
1. Area tick инициирует обработку.
2. Dispatch доставляет события в bounded режиме.
3. NPC проходят route/sleep/activity шаги.
4. Внешние инциденты через hooks и incident events запускают reactive/incident/city контуры.
5. Incident pipeline регулирует эскалацию, смену стадии, деэскалацию и resume/resync.
6. Population layer закрывает дефицит населения в рамках policy.

---

## 4.4 Архитектурный принцип внешних инцидентов

Daily Life не должен получать отдельный subsystem под пожар, отдельный subsystem под карантин и ещё один subsystem под комендантский час.

Канон runtime-слоя:
- существует единый `incident context` на уровне города/района/набора area;
- `crime/alarm` считается первым реализованным типом инцидента, а не единственным допустимым сценарием;
- роль NPC определяет, какой temporary override применяется при активном инциденте;
- переключение идёт через event-driven pipeline: `incident_start -> interrupt -> temporary behavior -> incident_end -> resync/resume`;
- area/building слой должен поддерживать incident-метаданные: `restricted_area`, `danger_area`, `blocked_routes`, `safe_point`, `panic_point`, `incident_anchor`.

Это позволяет добавлять пожар, карантин, бунт и комендантский час без переписывания ядра Daily Life.

## 5) Ответственности и границы (очень важно)

## 5.1 Контент отвечает за
- маршрутные теги и слоты (`alwp0..alwp5`);
- связность area (`al_link_count`, `al_link_*`);
- sleep markup (`al_bed_id`, sleep пары waypoint);
- city принадлежность (`al_city_id`, district type, city точки);
- respawn nodes и конфиг area-level.

## 5.2 Runtime отвечает за
- очереди, курсоры, индексы;
- state flags и состояние FSM;
- служебные счётчики/диагностику/health;
- bounded бюджеты и cooldown-логики.

## 5.3 Жёсткий запрет
Runtime locals нельзя редактировать вручную как способ «починки» сценариев. Исправление должно быть через код/контент/контракты.

---

## 6) Канонические инварианты системы

## 6.1 Архитектура
1. Heartbeat — только лёгкий Gate (wake-up/dirty-check), а не главный runtime-контур.
2. Отложенные задачи исполняются через timer-variant (`due_time` + центральная очередь + budgeted worker), а не через сетку `DelayCommand()`.
3. Нет world-wide full-scan как базовой стратегии.
4. Любая тяжёлая логика обязана быть bounded и исполняться по бюджету.
5. Любой новый механизм обязан иметь наблюдаемое состояние и критерии завершения.

## 6.2 Lifecycle / registry / dispatch
- NPC регистрируется и удаляется только в валидных lifecycle-точках.
- Tier модель (`FREEZE/WARM/HOT`) влияет на интенсивность обработки.
- Dispatch обрабатывается пакетно с backpressure и overflow-контролем.

## 6.3 Route / transition / sleep
- Route исполняется bounded шагами.
- Transition всегда валидирует endpoint и destination area.
- Sleep — отдельная ветка исполнения, с возвратом в routine pipeline.

## 6.4 Reactive / city
- Blocked/disturbed — локальные реакции, не ломающие route/schedule канон.
- Alarm — FSM, а не «мгновенная агрессия всего мира».
- Обязателен путь деэскалации (`active -> recovery -> normal`).

## 6.5 Контент
- `al_link_count` == фактическое число `al_link_*`.
- Индексация route-шагов без пропусков.
- `al_bed_id` допустим только при корректной sleep-разметке area.

---

## 7) Контракты данных и событий

## 7.1 NPC locals
### Обязательные
- `alwp0..alwp5`
- `al_default_activity`

### Опциональные / fallback / role hints
- `AL_WP_S0..AL_WP_S5`
- `al_npc_role` (`0` civilian, `1` militia, `2` guard/enforcer)
- `al_safe_wp_tag`

## 7.2 Area locals
- `al_link_count`, `al_link_0..N`
- `al_city_id`, `al_city_district_type`
- city tags: `al_city_bell_tag`, `al_city_arsenal_tag`, `al_city_shelter_tag`, `al_city_war_post_tag_<idx>`

## 7.3 Sleep/route
- `al_step`
- `al_bed_id`
- `al_dur_sec` (опционально)

## 7.4 Population/respawn
### Area конфиг
- `al_city_respawn_tag` ИЛИ `al_city_respawn_tag_<idx>` + `al_city_respawn_node_count`
- `al_city_respawn_resref` (опционально)
- `al_city_respawn_cooldown_ticks` (опционально)
- `al_city_respawn_budget_regen_ticks` (опционально)
- `al_city_respawn_safe_dist` (опционально)

### Module/city runtime keys
- `population_target_named`, `population_target_unnamed`
- `population_alive_named`, `population_alive_unnamed`
- `population_deficit_unnamed`
- `population_respawn_budget`, `population_respawn_budget_max`, `population_respawn_budget_initialized`
- `population_last_respawn_tick`, `population_budget_last_regen_tick`
- `population_respawn_resref`

## 7.5 Внутренние события (bus)
- `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`
- `AL_EVENT_RESYNC`
- `AL_EVENT_ROUTE_REPEAT`
- `AL_EVENT_BLOCKED_RESUME`
- city assignment events:
  - `AL_EVENT_CITY_ASSIGN_GO_SHELTER`
  - `AL_EVENT_CITY_ASSIGN_GO_ARSENAL`
  - `AL_EVENT_CITY_ASSIGN_HOLD_WAR_POST`
  - `AL_EVENT_CITY_ASSIGN_ALARM_RECOVERY`

---

## 8) Сценарии выполнения (операционная картина)

## 8.1 Базовый lifecycle
- `OnSpawn` -> регистрация -> участие в tick/dispatched логике.
- `OnExit/OnDeath` -> очистка runtime-состояний.

## 8.2 Суточный цикл
- slot event выбирает route.
- route исполняется по шагам в bounded режиме.
- fallback/resync не ломает общий бюджет area.

## 8.3 Переходы между area
- transition-step -> валидация endpoint.
- переход -> post-area transfer/sync registry.

## 8.4 Sleep lifecycle
- шаг с `al_bed_id` переключает в sleep pipeline.
- wake-up возвращает в routine.

## 8.5 Blocked/disturbed
- `OnBlocked` -> door-first + bounded resume.
- `OnDisturbed`/producer hooks -> реакция + city/crime pipeline.

## 8.6 Crime/alarm
- инциденты типизируются.
- desired/live alarm state разделены.
- role assignments управляются через события.
- есть controlled recovery.

## 8.7 Population respawn
- `OnSpawn/OnDeath` поддерживают alive/target/deficit.
- при выполнении pre-checks запускается create-path.
- только unnamed дефицит закрывается респауном.

---

## 9) Deep dive: Population Respawn (важная часть)

## 9.1 Цель
Поддерживать демографическую устойчивость города без:
- респауна named NPC,
- burst-спавнов,
- смешения с materialization.

## 9.2 Термины
- **Respawn**: создание нового NPC через `CreateObject`.
- **Materialization**: возврат уже существующего логического NPC.

## 9.3 Hooks
- `AL_OnNpcSpawn -> AL_CityPopulationOnNpcSpawn`
- `AL_OnNpcDeath -> AL_CityPopulationOnNpcDeath`
- `AL_AreaTick -> AL_CityPopulationTryRespawnTick`

## 9.4 Алгоритм OnSpawn
1. validate + no-double-register;
2. определить city;
3. классифицировать named/unnamed;
4. обновить alive counters;
5. поднять target при необходимости;
6. для unnamed уменьшить deficit (если > 0);
7. ensure/normalize budget.

## 9.5 Алгоритм OnDeath
- named: `alive_named--`;
- unnamed: `alive_unnamed--`, `deficit_unnamed++`;
- все операции с clamping.

## 9.6 RespawnTick pre-checks
1. area HOT;
2. alarm desired/live == peace;
3. `deficit_unnamed > 0`;
4. cooldown OK;
5. budget > 0;
6. regen budget при необходимости;
7. валидный respawn node;
8. безопасная node (нет врагов, игрок не слишком близко);
9. валидный resref (area/local fallback на city).

## 9.7 Create-path
На успешном создании:
- budget--;
- deficit--;
- last_respawn_tick обновляется;
- новый NPC маркируется unnamed;
- дальше стандартный `OnSpawn` lifecycle.

## 9.8 Что запрещено
- респаун named NPC;
- решение о респауне в heartbeat конкретного NPC;
- спавн перед игроком;
- отключение cooldown/budget/safety;
- объединение materialization и respawn в один «серый» контур.

---

## 10) Operations / perf / QA

## 10.1 Perf-gate
Для изменений в `scripts/daily_life/dl_*` обязательно:
- S80
- S100
- S120

Режим:
- warm-up: 2 area tick
- measurement: 20 tick
- baseline и after в одинаковых условиях

## 10.2 Обязательные метрики
- `al_dispatch_q_len`, `al_dispatch_q_overflow`
- `al_reg_overflow_count`, `al_route_overflow_count`
- `route_cache_hits`, `route_cache_rebuilds`, `route_cache_invalidations`
- `al_h_recent_resync`
- `al_h_reg_index_miss_delta`, `al_h_reg_index_miss_window_delta`
- `al_reg_lookup_window_total`, `al_reg_lookup_window_miss`, `al_reg_reverse_hit`
- `al_dispatch_ticks_to_drain`, `al_dispatch_budget_current`
- `al_dispatch_processed_tick`, `al_dispatch_backlog_before`, `al_dispatch_backlog_after`

## 10.3 Operator checklist
Перед PR:
1. baseline-vs-after по обязательным метрикам;
2. operator-readable + machine-readable отчёт;
3. perf-проверка не пропущена для core-файлов;
4. обновление baseline имеет обоснование;
5. preflight summary приложен.

## 10.4 Preflight для контента
Проверять до релиза:
- linked graph (`al_link_*`);
- route/step/sleep markup;
- отсутствие битых тегов/дубликатов/невалидных ссылок.

---

## 11) Статус проекта и roadmap

## 11.1 Реализовано (подтверждённый baseline)
- Stage A–H;
- Stage I.0–I.2;
- зрелый базовый контур: lifecycle + routine + city crime/alarm + population recovery.

## 11.2 Planned (Stage I.3)
1. Reinforcement / guard spawn policy.
2. Surrender -> arrest -> case intake -> trial -> sentence pipeline.
3. Court mechanics: evidence model, hearing modes, verdict classes, sentence execution hooks.
4. Consequences expansion for crime incidents.
5. Специализированные QA-критерии для legal/reinforcement (без временных отдельных трекеров).

## 11.3 Definition of Done для Stage I.3
- реализована bounded policy подкреплений;
- legal pipeline проходит end-to-end (от задержания до исполнения/отмены санкции);
- smoke сценарии воспроизводимы;
- docs синхронно обновлены (`02`, `03`, `04`, `12B`, `18`, `10`).

---

## 12) План восстановления системы с нуля (практический)

## 12.1 Порядок реализации
1. Area tick + event bus + bounded dispatch.
2. Registry + lookup/cache + diagnostics.
3. Slot routines + route runtime.
4. Transition subsystem + post-transfer sync.
5. Sleep pipeline.
6. Activity pipeline.
7. Blocked/disturbed.
8. City registry + crime + alarm FSM.
9. Population layer + respawn policy.
10. Perf + operations gates.
11. Только после этого Stage I.3 legal/reinforcement.

## 12.2 Критерии приёмки каждого шага
Шаг не считается завершённым без:
- явных инвариантов;
- наблюдаемого runtime-состояния;
- smoke-сценариев;
- bounded гарантии (нет бесконечных контуров);
- базового perf контроля.

---

## 13) Анти-паттерны (чего делать нельзя)

1. World-wide scan как «универсальное решение».
2. Бесконечные циклы без budget/cap.
3. Смешение city FSM и per-NPC routine FSM в неявную общую машину.
4. Ручное правление runtime locals вместо исправления первопричины.
5. «Магические» спавны/эскалации без диагностируемых причин.
6. Смешение respawn и materialization.

---

## 14) Диагностика и отладка: где смотреть в первую очередь

Если «NPC не живут нормальной жизнью»:
1. Проверить route tags (`alwp*`) и existence waypoint.
2. Проверить registry overflow/lookup miss метрики.
3. Проверить dispatch backlog/overflow.
4. Проверить linked graph (`al_link_count`, `al_link_*`).

Если «не работают переходы между area»:
1. Проверить endpoint tags и target area.
2. Проверить post-transition transfer hooks.
3. Проверить дубли/битые links в контенте.

Если «город не реагирует/не успокаивается»:
1. Проверить producer hooks (damage/attack/spell/death/disturbed).
2. Проверить desired/live alarm state.
3. Проверить assignment event flow.
4. Проверить, что recovery-path выполняется.

Если «не работает respawn населения»:
1. Проверить `deficit_unnamed` > 0.
2. Проверить cooldown/budget.
3. Проверить peace-state города.
4. Проверить respawn node и safe distance.
5. Проверить resref (area/local или city fallback).

---

## 15) FAQ — ответы на типовые вопросы нового агента

### Q1. Как правильно использовать heartbeat в этой архитектуре?
Как лёгкий будильник: проверить, что есть pending-state/просроченные сроки, и разбудить worker. Тяжёлая логика должна жить в budgeted worker, а в неактивных областях heartbeat отключается.

### Q1.1 Можно ли использовать heartbeat точечно?
Да, но только как управляемый вспомогательный канал, а не постоянный фон. Нужен отдельный Heartbeat Gate/Supervisor: включение по явным условиям, лёгкая работа в обработчике, гарантированное отключение, когда условия исчезают.

### Q2. Где «истина»: в контенте или runtime?
Intent в контенте, динамика и служебное состояние в runtime. Нельзя подменять одно другим.

### Q3. Что самое критичное в стабильности?
Dispatch/registry bounded-инварианты + валидный контент route/links + корректная деэскалация city FSM.

### Q4. Что уже готово и что нет?
Готова база до Stage I.2. Основной незакрытый пакет — Stage I.3 (legal/reinforcement).

### Q5. Можно ли быстро «подкрутить локал» в рантайме и закрыть баг?
Нет. Это нарушает воспроизводимость и скрывает причину.

### Q6. Какая минимальная проверка перед слиянием?
Perf S80/S100/S120 + обязательные метрики + smoke/контент preflight.

### Q7. Как понять, что система не ушла в unbounded-поведение?
Смотреть queue/backlog/overflow, ticks-to-drain, cache rebuild/invalidations, и подтверждать bounded сценариями.

---

## 16) Глоссарий

- **Area-centric execution** — управление симуляцией на уровне area tick.
- **Event-driven orchestration** — переходы между состояниями через события.
- **Bounded processing** — ограниченные бюджеты/ёмкости/время выполнения.
- **Routine pipeline** — повседневный цикл маршрутов/активностей NPC.
- **City FSM** — state-машина тревоги и реакции города.
- **Respawn** — создание нового NPC для закрытия дефицита.
- **Materialization** — возврат уже существующего NPC в активную зону.
- **Preflight** — предварительная валидация контента и связей до релиза.

---

## 17) Документационные долги и план поддержания master-документа

1. В репозитории встречаются ссылки на документы, которых может не быть в текущем tree (например некоторые `docs/09_*`).
2. Документ `docs/runtime/10_NPC_RESPAWN_MECHANICS.md` содержит следы несинхрона/merge-остатков и требует отдельной очистки.
3. При изменениях в архитектуре сначала обновлять профильный документ-источник, затем синхронизировать этот master summary.

Рекомендуемый процесс поддержки:
- изменили механику -> обновили профильный doc -> обновили этот master summary (разделы 8/10/11/15).
- закрыли этап -> обновили status/roadmap/FAQ.

---

## 18) Короткая памятка «что делать прямо сейчас новому агенту»

1. Прочитать разделы 1, 4, 6, 8, 10, 11, 12, 15.
2. Зафиксировать: система уже зрелая до I.2; I.3 — главный фронт.
3. Любое изменение проектировать через bounded и observability.
4. Не ломать границу content/runtime.
5. Перед PR пройти perf-gate и smoke-валидацию.

Если ты понимаешь этот документ — ты понимаешь архитектурный замысел проекта и можешь продолжать разработку осмысленно.

---

## 19) Формальная проверка полноты покрытия («описывает всё»)

Этот раздел нужен, чтобы проверить, что мастер-план действительно покрывает все основные элементы системы, а не только «ядро по памяти».

### 19.1 Покрытие документации
Покрыты и нормализованы материалы:
- `17_UNIFIED_GAME_DESIGN_BRIEF_RU` (единая high-level карта и инварианты);
- `02_MECHANICS` (канон механик);
- `03_OPERATIONS` (perf-регламент и метрики);
- `04_CONTENT_CONTRACTS` (контент и runtime ключи);
- `18_REBUILD_RESET_CONTEXT` (режим reset/rebuild и статус этапа);
- `06_SYSTEM_INVARIANTS` (инварианты);
- `07_SCENARIOS_AND_ALGORITHMS` (сценарии и алгоритмы);
- `10_DECISIONS_LOG` (архитектурные решения и компромиссы);
- `10_NPC_RESPAWN_MECHANICS` (детализация respawn, с учётом несинхронов исходника);
- `13_AGING_AND_CLAN_SUCCESSION` (старение персонажей и клановое наследование v1).

### 19.2 Покрытие runtime-файлов (`scripts/daily_life/*.nss`)
В master-плане отражены все файлы текущей директории `scripts/daily_life`:
- Core/lifecycle: `dl_on_load`, `dl_area_enter`, `dl_area_exit`, `dl_area_tick`, `dl_area_inc`;
- Worker/types/utils: `dl_worker_inc`, `dl_types_inc`, `dl_const_inc`, `dl_util_inc`, `dl_log_inc`;
- Routine/schedule/activity: `dl_schedule_inc`, `dl_activity_inc`, `dl_anchor_inc`, `dl_materialize_inc`;
- Resolver/resync/override: `dl_resolver_inc`, `dl_resync_inc`, `dl_override_inc`, `dl_slot_handoff_inc`;
- Interaction: `dl_interact_inc`;
- Smoke/tests: `dl_smoke_milestone_a`, `dl_smoke_step_e`.

Для legacy-обратной совместимости со старыми именами `al_*` используется централизованный mapping-док: `docs/runtime/12B_DAILY_LIFE_V1_LEGACY_TO_RUNTIME_MAPPING.md`.

### 19.3 Покрытие сущностей и контрактов
Покрыты:
- NPC locals (route/activity/role/safe wp);
- Area locals (links/city metadata/city points);
- Sleep markup и route-step правила;
- Population/respawn area + module/city ключи;
- Runtime-only locals и запрет ручного редактирования.

### 19.4 Покрытие сценариев
Покрыты end-to-end сценарии:
- lifecycle spawn/exit/death;
- routine slot execution;
- transition между area;
- sleep/wakeup;
- blocked recovery;
- disturbed/crime escalation;
- alarm recovery;
- population respawn.

### 19.5 Покрытие «планируемого»
Покрыт весь запланированный блок Stage I.3:
- reinforcement policy;
- surrender/arrest/case intake/trial/sentence pipeline;
- consequences expansion;
- dedicated legal/reinforcement QA smoke.

### 19.6 Что сознательно не включено в область
- `third party/*` и компилятор внутри неё (по правилам проекта не анализируются и не изменяются).

Итог проверки полноты: master-план описывает текущую систему целиком (архитектура, контракты, сценарии, операционный контур, roadmap) и отдельно маркирует зоны документального долга.

---
