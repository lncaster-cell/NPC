# 20 — NPC Behavior System Design (RU, Canon)

Дата: 2026-04-13
Статус: **канонический** (основной документ Daily Life / NPC Behavior)
Заменяет/поглощает: `12B_DAILY_LIFE_VNEXT_CANON.md` как отдельный канон.

---

## 1) Назначение

Этот документ является **единым каноном** по поведенческой системе NPC (Daily Life vNext) для Ambient Life v2.

Цель системы:
- поддерживать правдоподобную повседневную жизнь NPC;
- давать корректную materialization в активных зонах;
- обеспечивать bounded runtime без глобальной фоновой симуляции мира;
- интегрироваться с Population/Trade/Legal/Travel без подмены их ответственности.

---

## 2) Архитектурная формула

Базовая модель:

`engine_time + npc_profile + place_context + external_incident_context -> directive -> local_execution`

Где:
- `engine_time` — источник истины по времени;
- `npc_profile` — поведенческий тип и policy NPC;
- `place_context` — база/здание/anchors/доступность;
- `external_incident_context` — внешний городской контекст (пожар/карантин/тревога и т.п.);
- `directive` — текущая директива NPC;
- `local_execution` — локальное исполнение в area-tier модели.

---

## 3) Границы системы

### 3.1 Что система делает

- интерпретирует текущее время движка как вход в resolver;
- выбирает директиву NPC по профилю, расписанию и контексту места;
- materialize-ит NPC сразу в корректном состоянии в активной зоне;
- исполняет поведение только там, где это разрешено tier-политикой;
- выполняет bounded resync после unload/load, паузы, смены tier и инцидентных override;
- отделяет routine-поведение от population creation/respawn.

### 3.2 Что система **не** делает

- не является правовой системой (crime/witness/legal verdict);
- не является источником макроэкономической истины;
- не заменяет travel/aging/clan systems;
- не держит постоянную full-world симуляцию всех NPC;
- не опирается на старую схему `alwp0..alwp5` как на канон vNext.

---

## 4) Ключевые сущности

Минимальный состав:
- `Engine Time`
- `NPC Profile`
- `Schedule Profile`
- `Directive`
- `Base/Building Context`
- `Anchors`
- `Area Tier` (`HOT`, `WARM`, `FROZEN`)
- `Materialization State`
- `Resync Request`
- `Population Slot / Function`
- `Replaceable / Persistent Policy`

### 4.1 NPC Profile

Профиль должен включать минимум:
- `npc_role`
- `schedule_profile`
- `base_id`
- `work_id`/`duty_id` (если применимо)
- identity policy: `named/unnamed`, `persistent/replaceable`
- допустимые directive-маски и fallback-политики.

Профиль описывает **намерение и контекст**, а не waypoint-маршрут.

### 4.2 Schedule Profile

Расписание описывается окнами поведения, а не фиксированными waypoint-слотами.

Пример класса окон:
- `SLEEP`
- `HOME_IDLE`
- `WORK`
- `SOCIAL_LOCAL`
- `DUTY/HOLD_POST`
- `RETURN_TO_BASE`

### 4.3 Base/Building Context и Anchors

`base_id` — это контекст принадлежности NPC (дом, мастерская, казарма, mixed-use объект и т.д.).

Минимальные anchor-типы:
- `sleep_anchor`
- `home_anchor`
- `work_anchor`
- `service_anchor`
- `duty_anchor`
- `entry_anchor`
- `exit_anchor`

---

## 5) Директивная модель

Минимальный канонический набор directive для vNext:
- `SLEEP`
- `HOME_IDLE`
- `GO_HOME`
- `GO_WORK`
- `WORK`
- `SOCIAL_LOCAL`
- `DUTY`
- `HOLD_POST`
- `GO_SHELTER`
- `RETURN_TO_BASE`
- `UNAVAILABLE`

Расширенные incident-директивы (например, `ESCORT`, `DETENTION`) допустимы через policy-слой, но не должны ломать базовый routine-конвейер.

---

## 6) Area-tier / LOD канон

### HOT

Разрешено:
- полное локальное исполнение Daily Life;
- materialization обычных NPC;
- bounded resync;
- локальные переходы и service/runtime-активность.

### WARM

Разрешено:
- bootstrap/prefetch;
- подготовка данных materialization;
- лёгкий scheduler state.

Запрещено:
- полноценная «живая» симуляция;
- массовая materialization;
- тяжёлый worker execution.

### FROZEN

- нет живого Daily Life runtime;
- нет area worker/poulation execution;
- только логическое состояние и статические данные.

Коротко: **HOT = жизнь, WARM = подготовка, FROZEN = тишина**.

---

## 7) Materialization и Resync

### 7.1 Materialization

При активации зоны система не «проигрывает историю», а делает:
1. чтение текущего `engine_time`;
2. resolver текущей директивы;
3. выбор корректного `base/building/anchor`;
4. materialization NPC сразу в валидное состояние.

### 7.2 Bounded Resync

Resync обязан быть ограниченным по бюджету и запускаться по причинам:
- area enter/activation;
- tier change;
- lifecycle re-entry;
- завершение временного incident override.

---

## 8) Внешний incident context (единый контракт)

Daily Life принимает внешний контекст, а не отдельные hardcoded подсистемы «под каждый случай».

Минимальные поля:
- `incident_type`
- `incident_stage`
- `incident_severity`
- `incident_scope` (`city` / `district` / `area-set` / `anchor-local`)
- `affected_roles`
- `affected_areas`
- `blocked_routes`
- `safe_points` / `panic_points`

### 8.1 Базовый паттерн override

- базовый профиль: `*_normal`;
- временный override: `*_incident`;
- после завершения инцидента: обязательный `resync/resume` к routine.

### 8.2 Общий interrupt/resume контракт

1. `interrupt` — корректно прервать текущий routine без поломки identity/profile;
2. `temporary behavior` — применить временную реакцию по scope/role;
3. `resume` — пересчитать актуальную routine-директиву и вернуть в базовый цикл.

---

## 9) Интеграционные границы с соседними системами

### 9.1 Сильная связность

- **Trade / City State**: Daily Life читает макроконтекст и отдаёт операционную проекцию заселённости/дефицитов.
- **Respawn / Population**: Daily Life сигнализирует дефицит функций, но не подменяет creation policy.
- **Homes / Buildings**: Daily Life использует place-context и anchors как основание materialization.

### 9.2 Средняя связность

- **Legal / Witness / Crime**: только read-only ограничения и фактологические runtime-сигналы.
- **Property**: проверка допустимости доступа/использования без изменения ownership.

### 9.3 Слабая связность

- **Clans**: только уже материализованный social context, без клановой полной симуляции.
- **World Travel**: факт локального входа/выхода, без замены travel-движка.
- **Aging / Succession**: только готовые внешние identity/status изменения.

---

## 10) Legacy-позиция (`alwp0..alwp5`)

Слотная waypoint-схема признаётся историческим прототипом и может использоваться только:
- как источник миграционных данных;
- как вспомогательный материал для контентной конверсии.

Она **не** является текущим каноном Daily Life vNext.

---

## 11) Нормативные правила расширения

Любое расширение Daily Life должно:
1. сохранять area-centric + event-driven + bounded execution;
2. не переносить heavy logic в noisy hooks;
3. не смешивать routine и legal/economy/travel истины;
4. реализовываться через profile/policy/incident data, а не через ad-hoc hardcode ветки.
