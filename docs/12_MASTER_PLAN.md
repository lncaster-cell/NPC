# Ambient Life v2 — Master Plan (единый мастер-документ)

Дата: 2026-03-14  
Статус: единый источник контекста для разработки, эксплуатации, QA и восстановления системы «с нуля».  
Область: `scripts/ambient_life/*`, `docs/*`, `README.md`.

---

## 0. Как читать этот документ

Этот мастер-план рассчитан на агента/разработчика, который **не знает ничего** о проекте и хочет:
1. понять идею системы;
2. восстановить архитектуру и границы;
3. понять контракты контента и runtime;
4. воспроизвести механики и сценарии;
5. продолжить разработку (включая планируемые Stage I.3+ механизмы).

Документ объединяет и нормализует материалы из:
- `docs/01_PROJECT_OVERVIEW.md`
- `docs/02_MECHANICS.md`
- `docs/03_OPERATIONS.md`
- `docs/04_CONTENT_CONTRACTS.md`
- `docs/05_STATUS_AUDIT.md`
- `docs/06_SYSTEM_INVARIANTS.md`
- `docs/07_SCENARIOS_AND_ALGORITHMS.md`
- `docs/08_STAGE_I3_TRACKER.md`
- `docs/10_NPC_RESPAWN_MECHANICS.md`
- `docs/11_GENERAL_DESIGN_DOCUMENT.md`

---

## 1. Продуктовая идея и замысел автора

### 1.1 Что это за система
Ambient Life v2 — это runtime-слой для NWN2, который симулирует «живую» повседневную жизнь NPC:
- рутины по времени суток;
- маршруты и переходы между area;
- сон и активность;
- локальные реакции на инциденты;
- городскую тревогу/преступность;
- восстановление населения города.

### 1.2 Какую проблему решает
Классический подход с per-NPC heartbeat плохо масштабируется. Здесь применён другой замысел:
- координация сверху вниз (area-centric),
- события вместо постоянного polling,
- bounded-обработка вместо «бесконечных» контуров,
- чёткое разделение контента и runtime-состояния.

### 1.3 Основные ценности дизайна
1. **Предсказуемость:** поведение объяснимо через контракты и state-машины.
2. **Масштабируемость:** нет world-wide full-scan как основы механики.
3. **Диагностируемость:** ключевые контуры имеют метрики, overflow и health counters.
4. **Управляемая эволюция:** новые функции встраиваются через существующий event/runtime каркас.

---

## 2. Архитектура системы (верхний уровень)

## 2.1 Core-парадигма
- **Area-centric execution:** «сердце» симуляции — area tick.
- **Event-driven orchestration:** NPC переходят между шагами через события и hooks.
- **Bounded processing:** каждый тяжёлый контур ограничен бюджетами/лимитами.
- **Content-configured behavior:** контент задаёт intent; runtime реализует логику.

## 2.2 Карта подсистем
1. **Core + Area lifecycle**
   - `al_core_inc.nss`, `al_area_inc.nss`, `al_area_tick.nss`, `al_area_onenter.nss`, `al_area_onexit.nss`, `al_mod_onleave.nss`
2. **Registry + Dispatch + Lookup/Cache**
   - `al_registry_inc.nss`, `al_dispatch_inc.nss`, `al_events_inc.nss`, `al_lookup_cache_inc.nss`
3. **Route/Transition/Sleep/Activity**
   - `al_route_inc.nss`, `al_route_cache_inc.nss`, `al_route_runtime_api_inc.nss`, `al_transition_inc.nss`, `al_transition_post_area.nss`, `al_sleep_inc.nss`, `al_activity_inc.nss`, `al_acts_inc.nss`
4. **Reactive + City layer**
   - `al_blocked_inc.nss`, `al_react_inc.nss`, `al_react_apply_step.nss`, `al_react_resume_reset.nss`, `al_city_registry_inc.nss`, `al_city_crime_inc.nss`, `al_city_alarm_inc.nss`, `al_city_population_inc.nss`, `al_health_inc.nss`
5. **Action wrappers + NPC hooks**
   - `al_action_signal_ud.nss`, `al_action_set_mode.nss`, `al_npc_onspawn.nss`, `al_npc_onud.nss`, `al_npc_onblocked.nss`, `al_npc_ondisturbed.nss`, `al_npc_ondamaged.nss`, `al_npc_onphysicalattacked.nss`, `al_npc_onspellcastat.nss`, `al_npc_ondeath.nss`

## 2.3 Границы ответственности
- **Контент** задаёт: маршруты, связи area, sleep markup, роли/теги.
- **Runtime** хранит: очереди, курсоры, state flags, счётчики, diagnostics.
- **Запрет:** ручное редактирование runtime locals как «лечения» проблем.

---

## 3. Ключевые инварианты (нельзя нарушать)

## 3.1 Архитектурные инварианты
1. Никаких per-NPC heartbeat-loop как основы системы.
2. Никаких global full-scan как базовой стратегии.
3. Любой тяжёлый контур имеет budget/cap и путь завершения.
4. Любое расширение обязано быть наблюдаемым через состояния и метрики.

## 3.2 Lifecycle / Registry / Dispatch
- NPC добавляется/удаляется из registry строго при валидных lifecycle событиях.
- Tier-модель (`FREEZE/WARM/HOT`) определяет глубину обслуживания.
- Dispatch queue обрабатывается пакетно с контролем overflow и latency.

## 3.3 Route / Transition / Sleep
- Route выполняется bounded-шагами.
- Transition требует валидных endpoint и target area.
- Sleep выделен в отдельный контур и обязан возвращать NPC в routine pipeline.

## 3.4 Reactive / City
- Blocked/disturbed локальны и не разрушают базовые route/schedule инварианты.
- City alarm работает как FSM (а не хаотичная глобальная агрессия).
- Есть явная деэскалация (active -> recovery -> normal).

## 3.5 Content-инварианты
- `al_link_count` соответствует `al_link_*`.
- Route шаги индексируются без пропусков.
- `al_bed_id` допустим только при наличии корректной sleep-пары waypoint.

---

## 4. Контракты контента (для создания мира)

## 4.1 NPC locals
### Обязательные
- `alwp0..alwp5` — route tags по слотам суток.
- `al_default_activity` — fallback/дефолтная активность.

### Опциональные/fallback
- `AL_WP_S0..AL_WP_S5` — legacy fallback route tags.
- `al_npc_role` — роль (`0` civilian, `1` militia, `2` guard/enforcer).
- `al_safe_wp_tag` — точка fallback-отхода при тревоге.

## 4.2 Area locals
- `al_link_count`, `al_link_0..N` — граф переходов.
- `al_city_id`, `al_city_district_type` — принадлежность к city layer.
- city points: `al_city_bell_tag`, `al_city_arsenal_tag`, `al_city_shelter_tag`, `al_city_war_post_tag_<idx>`.

## 4.3 Sleep и route contracts
- Sleep-step: `al_step`, `al_bed_id`, опционально `al_dur_sec`.
- Все reference-теги должны существовать в своей area.

## 4.4 Respawn population contracts
### Area/local
- `al_city_respawn_tag` или `al_city_respawn_tag_<idx>` + `al_city_respawn_node_count`
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

---

## 5. Runtime-сценарии (как система реально работает)

## 5.1 Базовый lifecycle
1. NPC входит в area -> регистрируется.
2. Получает сигналы/события через dispatch.
3. При выходе/смерти корректно удаляется из runtime-структур.

## 5.2 Routine по слотам суток
1. Слот-событие выбирает маршрут (`AL_EVENT_SLOT_0..5`).
2. Route исполняется bounded-проходом.
3. При проблемах — fallback/resync без развала общего tick-budget.

## 5.3 Transition между area
1. Route-step требует перехода.
2. Проверяются source/destination endpoint + целевая area.
3. После перехода выполняется post-area синхронизация registry.

## 5.4 Sleep lifecycle
1. Route-step с `al_bed_id` переводит в sleep-контур.
2. Sleep исполняется как специальный pipeline.
3. Wake-up возвращает в routine.

## 5.5 Blocked recovery
1. `OnBlocked`.
2. Локальные unblock-попытки.
3. При неуспехе — bounded resync/resume.

## 5.6 Disturbed/crime/alarm
1. Producer hooks (`OnDisturbed`, `OnDamaged`, `OnPhysicalAttacked`, `OnSpellCastAt`, `OnDeath`) формируют инциденты.
2. Crime типизируется (theft/assault/murder/spell-related).
3. City alarm FSM изменяет desired/live состояния.
4. Выполняются role assignments и controlled materialization.

## 5.7 Alarm recovery
- После peak-тревоги система уходит в controlled recovery и возвращает роли к норме пакетно.

## 5.8 Population respawn
- На `OnSpawn/OnDeath` поддерживаются alive/target/deficit счётчики.
- Респаун — только для unnamed-дефицита, при budget+cooldown+safety.
- Materialization и respawn разделены концептуально и алгоритмически.

---

## 6. Алгоритмы и техники реализации

1. **Bounded dispatch queue** с backpressure и overflow метриками.
2. **Dense registry** с индексами, maintenance и miss-rate диагностикой.
3. **Route cache** с rebuild/invalidation стратегией.
4. **Transition endpoint resolution** с валидацией неоднозначностей.
5. **Sleep special-case execution** как отдельная ветка исполнения.
6. **City alarm FSM** (`idle/pending/active/clearing/recovery`).
7. **Population deficit recovery** через ограниченный create-path.

---

## 7. Deep dive: механизм респауна населения

## 7.1 Назначение
Восстанавливать **дефицит безымянного населения** города без:
- воскрешения конкретных NPC,
- спайков массового спавна,
- нарушения bounded-характера runtime.

## 7.2 Канон
- Named NPC не респаунятся.
- Respawn != Materialization.
- Решение принимает city layer в area tick, а не отдельный NPC.

## 7.3 Lifecycle hooks
- `AL_OnNpcSpawn -> AL_CityPopulationOnNpcSpawn`
- `AL_OnNpcDeath -> AL_CityPopulationOnNpcDeath`
- `AL_AreaTick -> AL_CityPopulationTryRespawnTick`

## 7.4 Алгоритм OnSpawn
1. Проверить валидность и анти-дубль регистрации.
2. Определить city-id.
3. Классифицировать named/unnamed.
4. Обновить `population_alive_*`.
5. Обновить `population_target_*` (peak-aware).
6. Если spawn unnamed и есть deficit — уменьшить deficit.
7. Нормализовать бюджет.

## 7.5 Алгоритм OnDeath
- Named: `alive_named--`.
- Unnamed: `alive_unnamed--`, `deficit_unnamed++`.
- Всё с clamping от ухода в отрицательные значения.

## 7.6 Алгоритм RespawnTick pre-checks
Порядок проверок:
1. area валидна и HOT;
2. город в peace (desired/live);
3. `deficit_unnamed > 0`;
4. cooldown выдержан;
5. бюджет положительный;
6. при необходимости регенерировать бюджет;
7. есть валидная respawn node;
8. node безопасна (нет врагов, игрок не рядом);
9. есть resref (area-level либо city fallback).

## 7.7 Create-path
При успехе `CreateObject`:
- `budget--`,
- `deficit--`,
- `population_last_respawn_tick = now`,
- новый NPC маркируется unnamed,
- дальнейшая регистрация идёт штатным `OnSpawn`.

## 7.8 Anti-patterns
Нельзя:
- респаунить named NPC,
- запускать респаун из трупа/heartbeat,
- спавнить «перед игроком»,
- отключать budget/cooldown/safety,
- смешивать respawn с materialization.

---

## 8. Operations, perf и QA

## 8.1 Perf gate для изменений в `scripts/ambient_life/al_*`
Обязательные прогоны:
- S80
- S100
- S120

Рекомендованный режим:
- warm-up: 2 area-tick
- измерение: 20 tick
- одинаковые условия для baseline/after

## 8.2 Обязательные метрики
Минимальный набор:
- `al_dispatch_q_len`, `al_dispatch_q_overflow`
- `al_reg_overflow_count`, `al_route_overflow_count`
- `route_cache_hits`, `route_cache_rebuilds`, `route_cache_invalidations`
- `al_h_recent_resync`
- `al_h_reg_index_miss_delta`, `al_h_reg_index_miss_window_delta`
- `al_reg_lookup_window_total`, `al_reg_lookup_window_miss`, `al_reg_reverse_hit`
- `al_dispatch_ticks_to_drain`, `al_dispatch_budget_current`
- `al_dispatch_processed_tick`, `al_dispatch_backlog_before`, `al_dispatch_backlog_after`

## 8.3 Operator checklist
Перед PR:
1. baseline-vs-after для обязательных метрик;
2. операторские таблицы + machine-readable отчёт;
3. perf не пропущен для core-файлов;
4. baseline обновлён только с обоснованием;
5. preflight summary приложен.

## 8.4 Linked graph preflight
Перед релизом проверять:
- связность `al_link_*`,
- корректность route/locals,
- WARN/ERROR до поставки.

---

## 9. Статус реализации и roadmap

## 9.1 Что уже сделано (до Stage I.2 включительно)
- architecture/lifecycle/registry/dispatch;
- route/cache/transition;
- sleep/activity;
- blocked/disturbed;
- local city crime/alarm;
- population respawn;
- diagnostics/health/perf базовый контур.

## 9.2 Что запланировано (Stage I.3)
1. **Reinforcement / guard spawn policy**
   - bounded policy без world-wide scan.
2. **Legal pipeline: surrender -> arrest -> trial**
   - end-to-end правовая развязка инцидентов.
3. **Consequences expansion**
   - более градуированные исходы преступлений.
4. **QA smoke для legal/reinforcement**
   - отдельный runbook и pass/fail критерии.

## 9.3 Критерии Done для Stage I.3
- policy подкреплений реализована и документирована;
- legal pipeline работает end-to-end;
- есть воспроизводимый smoke-набор;
- синхронно обновлены mechanics/operations/contracts/status docs.

---

## 10. План восстановления системы «с нуля» (для нового агента)

## 10.1 Последовательность внедрения
1. Реализовать core area tick + event bus + dispatch с bounded-лимитами.
2. Реализовать registry и lookup/cache с диагностикой miss/overflow.
3. Подключить routine-слоты и route pipeline.
4. Добавить transition между area + post-transfer синхронизацию.
5. Добавить sleep отдельным pipeline.
6. Добавить activity слой.
7. Добавить blocked/disturbed реактивный слой.
8. Добавить city registry + crime + alarm FSM.
9. Добавить population layer + respawn policy.
10. Ввести perf/операционный контур и только затем расширять legal/reinforcement.

## 10.2 Проверка корректности на каждом шаге
- Шаг проходит только если:
  - соблюдены инварианты;
  - есть метрики и наблюдаемость;
  - сценарии воспроизводимы;
  - отсутствуют unbounded-контуры.

## 10.3 Дизайн-границы, которые запрещено размывать
- Не превращать систему в giant diplomacy simulator.
- Не смешивать personal routine FSM и city FSM в одну неявную машину.
- Не решать архитектурные проблемы ручным редактированием runtime locals.

---

## 11. Известные проблемы документации и нормализация

1. В части документации встречаются ссылки на ещё не существующие документы (напр. `docs/09_*`).
2. Файл `docs/10_NPC_RESPAWN_MECHANICS.md` содержит следы merge-конфликта и дублирования текста.
3. Этот мастер-план является нормализованной «чистой» версией знаний и должен использоваться как основной onboarding-источник.

Рекомендация: в последующих PR либо очистить `docs/10_NPC_RESPAWN_MECHANICS.md`, либо заменить его на версию, синхронизированную с разделом 7 этого мастер-плана.

---

## 12. Короткая памятка для агента, который стартует с нуля

Если у тебя только этот файл, то ориентируйся так:
1. Система событийная и area-centric.
2. Всё тяжёлое — bounded.
3. Контент задаёт intent, runtime хранит динамику.
4. База (до I.2) считается зрелой.
5. Главная зона разработки: Stage I.3 (reinforcement + legal pipeline + последствия + QA smoke).
6. Любое изменение доказывается не словами, а сценариями, метриками и стабильным perf.

