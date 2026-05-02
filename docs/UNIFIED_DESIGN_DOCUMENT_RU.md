# NPC — Единый дизайн-документ (Unified)

> Статус: **единственный источник документации проекта**.  
> Этот документ заменяет предыдущие разрозненные документы в `docs/**`.

## 1) Цель проекта

Построить для NWN2 модульную, производительную, событийную систему «живого мира», где:
- NPC правдоподобно живут по распорядку;
- город и домены (кланы, право, имущество, торговля, путешествия) реагируют на действия игрока;
- архитектура остается расширяемой без хаотичного роста скриптов.

Базовый технический принцип: **использовать встроенные механики NWN2/NWScript и подтвержденные практики (NWN Lexicon / официальные функции), а не костыли**.

---

## 2) Самый главный блок: мои идеи по системам

Ниже зафиксирован ядровой замысел (сохранен как главный смысл проекта).

### 2.1 Общая продуктовая идея

- Мир не симулируется «честно поминутно» целиком.
- Симулируется **активный контур**: там, где игрок и где важен игровой эффект.
- Поведение NPC строится через формулу:

`engine_time + npc_profile + place_context + incident_context -> directive -> local_execution`

### 2.2 Системы, которые ты хотел и их границы

1. **Daily Life (ядро живого поведения NPC)**  
   - Area-centric, event-driven, bounded execution.
   - Рутина + мягкие отклонения + временные incident-override + обязательный resync.

2. **City Response (городская реакция)**  
   - Сигналы тревоги/эскалации/деэскалации.
   - Не подменяет legal-вердикт, а запускает оперативный режим города.

3. **Legal / Crime / Witness**  
   - Нормативный контур: квалификация событий, свидетели, процессуальные стадии.
   - Отдельный lifecycle, независимый от единичных срабатываний.

4. **Clan System + Succession/Aging**  
   - Социально-политический слой с асимметрией: детальный игроковый клан + фасадные NPC-кланы.
   - Наследование и возраст как долгий мета-контур.

5. **Player Property (собственность)**  
   - Единый реестр долговременного владения.
   - Camp/жилье/имущество — часть одного домена, не отдельные «мини-системы».

6. **Trade + City State**  
   - Макроэкономический/снабженческий контур (не розничный store-only слой).
   - Влияет на доступность, давление на город и контекст Daily Life.

7. **World Travel**  
   - Узловая система путешествий поверх реальных ограничений NWN2.
   - Морские/дальние переходы через маршруты, события и presentation-слой.

### 2.3 Анти-хаос принципы

- Никаких ad-hoc подсистем «под один случай».
- Контракты между доменами важнее точечных скриптов.
- Идемпотентность terminal-переходов.
- Bounded обработка событий, без unbounded fan-out.
- Single source of truth на уровне runtime-правил.

---

## 3) Блок исследований движка (сохранено как обязательная база)

### 3.1 Ключевые ограничения NWN2/NWScript

- Для кастомных событий в `EventUserDefined` нельзя использовать зарезервированные диапазоны движка (в т.ч. `1000..1011`, `1510`, `1511`); для внутренних событий проекта использовать отдельный диапазон (например `3000+`).
- Нельзя строить критичную системную логику на массовом `DelayCommand` как планировщике.
- Для travel-дизайна учитывать, что некоторые идеи «настоящего движущегося корабля» в NWN2 не поддерживаются как полноценная опора.
- Runtime должен быть event-first, а не heartbeat-поминутный опрос всего мира.

### 3.2 Практика, которой придерживаемся

- Сначала проверяем стандартные NWScript функции и паттерны NWN Lexicon.
- Если встроенный механизм есть — используем его.
- Если нет — вводим тонкую обертку, но не ломаем контракт ядра.
- Любой новый контур проходит проверку: bounded / idempotent / observable.

### 3.4 Политика reset локальных ключей (DeleteLocal* vs SetLocal*=zero)

Единое правило для локальных ключей runtime-контракта:

- Используем `DeleteLocalInt/DeleteLocalString/DeleteLocalObject`, когда **отсутствие ключа семантически значимо** (tri-state/absence meaningful):
  - нужно различать `никогда не инициализировалось` vs `явно 0/""/OBJECT_INVALID`;
  - ключ управляет lazy-init, one-shot bootstrap, совместимостью миграций.
- Используем `SetLocal*` в каноническое «пустое» значение (`0`, `""`, `OBJECT_INVALID`), когда **само значение является состоянием** (explicit value meaningful):
  - флаги активного runtime-цикла (`pending`, `cursor`, `last_processed`);
  - числовые/строковые метрики, которые читаются как всегда определённые значения.

Правило выбора:
1) Если чтение кода зависит от `наличия` ключа — `DeleteLocal*`.
2) Если чтение кода зависит только от `значения` ключа — `SetLocal*` в канонический reset.

### 3.5 Canonical runtime key taxonomy (worker/resync/transition/social/crime/legal)

- **State:** `*_STATE`.
- **Flag:** `*_PENDING`, `*_ACTIVE`.
- **Counters/sequence:** `*_COUNT`, `*_SEQ`.
- **Timestamps:** `*_ABS_MIN`, `*_TICK`.

Применённые уточнения доменов:
- `worker`: `..._WORKER_TICKS` → `..._WORKER_TICK_COUNT`; `..._LAST_PROCESSED` → `..._LAST_PROCESSED_TICK`.
- `social`: `..._RESERVED_UNTIL` → `..._RESERVED_ABS_MIN`.
- `crime`: `..._LOCKPICK_MARK_UNTIL` → `..._LOCKPICK_MARK_ABS_MIN`.

Совместимость миграции — короткоживущая: на этапе перехода допускается одноразовая перекладка legacy key в canonical key с последующим `DeleteLocal*` legacy-ключа.

Временный переходный режим допускает dual-style только с явным `COMPAT`-комментарием рядом с кодом и с планом удаления legacy-ветки.

### 3.3 Рекомендуемая событийная архитектура

- Центральный dispatcher на модуле + адаптеры событий на уровне area/NPC.
- Тонкие обработчики входных событий, тяжелая логика — в специализированных резолверах.
- Очередь/квоты на тик для контроля burst-нагрузок.

---

## 4) Минимальная целевая архитектура Daily Life vNext

Канонический pipeline Daily Life:

```text
Schedule
→ Directive
→ Activity / Scene
→ Destination Resolver
→ Nav Router
→ Transition Executor
→ Action / Animation
```

Этот pipeline является целевым контрактом. Новые runtime-правки должны приводить текущий код к этому разделению, а не добавлять параллельные частные механизмы.

### 4.1 Schedule

**Ответственность:** определить, что NPC должен делать сейчас по игровому времени.

Schedule возвращает только верхнеуровневую директиву и не знает конкретных waypoint, дверей, переходов, театров, таверн или кроватей.

Разрешённые директивы Daily Life:

```text
SLEEP
WORK
MEAL
SOCIAL
PUBLIC
CHILL
```

### 4.2 Directive

**Ответственность:** выразить намерение NPC.

Директива не должна быть жёсткой связкой `waypoint + animation`. Она только выбирает тип поведения, а конкретика уходит ниже — в activity/scene и destination resolver.

Примеры:

- `SLEEP` — ночной период сна;
- `WORK` — рабочая активность профиля;
- `MEAL` — завтрак/обед/ужин;
- `SOCIAL` — социальный досуг или социальная сцена;
- `PUBLIC` — общественное присутствие без конкретного досуга;
- `CHILL` — личный отдых дома.

Важно: fallback `SOCIAL -> PUBLIC` считается частью **исполнения SOCIAL-сцены** (executor-path), а не отдельной публичной директивной стадией/предикатом верхнего уровня.

### 4.3 Activity / Scene

**Ответственность:** выбрать конкретный небольшой сценарий внутри директивы.

Примеры целевых сцен:

```text
SOCIAL + theater      -> theater_visit
SOCIAL + tavern       -> tavern_visit
SOCIAL + paired_chat  -> paired_chat_scene
MEAL + breakfast      -> breakfast_at_home
CHILL + home          -> sit_at_home
WORK + blacksmith     -> blacksmith_work_cycle
```

Сцена — это управляемый эпизод поведения: найти цель, дойти, занять место, выполнить действие/анимацию, корректно завершить и освободить ресурсы. Это не полноценная психологическая симуляция NPC.

### 4.4 Destination Resolver

**Ответственность:** определить конкретную цель сцены.

Примеры:

- `SLEEP`: найти `sleep_approach` и `sleep_bed` по `home_slot`;
- `MEAL`: найти meal anchor в home/meal area;
- `SOCIAL + theater`: найти свободную точку из пула `dl_social_theater_*`;
- `SOCIAL + tavern`: найти свободную точку из пула `dl_social_tavern_*`;
- `CHILL`: найти seat/chair домашнего отдыха.

Если цель является shared-place, resolver может резервировать её:

```text
театр seat
таверна spot
social anchor
chair/seat
```

Резервация должна быть bounded и самоистекающей, чтобы застрявший, умерший или удалённый NPC не блокировал место навсегда.

### 4.5 Nav Router

**Ответственность:** выбрать следующий transition entry на пути к цели.

Nav Router не телепортирует NPC, не открывает двери и не проигрывает анимации. Он только отвечает:

```text
где NPC сейчас?
где находится цель?
какой следующий переход нужно выполнить?
```

Каноническая модель узла маршрута:

```text
area_tag:nav_zone
```

Пример:

```text
blacksmith_house:hall
city_street:street
theater:audience
```

Пример маршрута:

```text
blacksmith_house:hall
→ city_street:street
→ theater:audience
```

Маршрутизация должна быть bounded: ограниченная глубина поиска, ограниченное число transition-кандидатов, без полного поиска мира в hot path.

Жёсткий контракт слоя: функции nav-модуля (`dl_cross_area_nav_inc.nss`, `dl_nav_router_inc.nss`) делают только planning/validation маршрута и возвращают entry waypoint; любые `AssignCommand`/`Action*`/`DoDoorAction` запрещены в nav-слое.

### 4.6 Transition Executor

**Ответственность:** выполнить один выбранный переход.

Это низкоуровневый исполнитель, а не отдельная навигационная система. Его задача:

```text
подойти к transition waypoint
открыть дверь/активировать driver, если задан
переместить NPC к exit waypoint
обновить dl_npc_nav_zone
вернуть управление верхнему pipeline
```

Существующий transition layer сохраняется именно как `Transition Executor`. Новая маршрутизация должна вызывать executor, а не дублировать его механику и не конкурировать с ним.

Жёсткий контракт слоя: фактическое исполнение перехода (подход, door driver, jump/teleport, очистка action queue, sync nav-zone) выполняется только в `dl_transition_engine_inc.nss`.
`dl_transition_exec_inc.nss` — только thin adapter к Engine (routing-context), `dl_transition_inc.nss` — только API/metadata helpers и backward-compatible adapter-вход.

### 4.7 Action / Animation

**Ответственность:** нижний NWScript/NWN2 слой действий.

Базовые допустимые механики:

```text
ActionMoveToLocation
ActionJumpToLocation
ActionSit
DoDoorAction
SetFacing
PlayCustomAnimation
ClearAllActions
```

Приоритет — штатные действия движка. Кастомная логика допускается только как тонкий адаптер над штатным действием.

### 4.8 Builder-friendly разметка

Разметка должна принадлежать location/area, а не конкретному NPC.

Плохо:

```text
blacksmith01_bed
blacksmith01_theater_spot
```

Хорошо:

```text
dl_sleep_bed_1
dl_social_theater_1
dl_social_theater_2
dl_social_tavern_1
```

NPC должен получать профиль/слот/area tags и переиспользовать существующую разметку:

```text
dl_profile_id = blacksmith
dl_home_slot = 1
dl_home_area_tag = blacksmith_house
dl_social_area_tag = theater_area
dl_social_kind = theater
```

### 4.9 Shared location contract

`dl_nav_zone` — это физико-навигационный фрагмент, а не семантическое назначение комнаты.

Одна зона может содержать разные activity anchors. Например боковая комната дома кузнеца может одновременно содержать:

```text
meal anchor для кузнеца
sleep slot дочери
social/chill spot
```

Поэтому запрещено проектировать зоны как `mealroom = только еда` или `bedroom = только сон`. Семантика принадлежит activity anchors, а не nav-zone.

### 4.10 SOCIAL как social destination/activity layer

`SOCIAL` не ограничивается парным разговором. Целевые виды:

```text
paired_chat
theater
tavern
public
```

`paired_chat` остаётся сценой разговора с партнёром. `theater` и `tavern` — это social destination-сцены, где NPC идёт в общественное место и занимает свободную pooled-точку.

### 4.11 Меж-area SOCIAL маршрут

Целевой контракт для похода в театр/таверну:

```text
SOCIAL kind = theater
→ Destination Resolver резервирует свободную dl_social_theater_*
→ Nav Router строит bounded путь area:zone → area:zone
→ Transition Executor выполняет один переход за раз
→ NPC доходит до зарезервированного места
→ сцена удерживает место/анимацию
→ при смене директивы reservation очищается
```

Пример разметки:

```text
// Дом кузнеца
dl_nav_hall_to_street
  dl_nav_to_area_tag = city_street

// Улица у дома
dl_nav_street_to_hall
  dl_nav_to_area_tag = blacksmith_house

// Улица у театра
dl_nav_street_to_audience
  dl_nav_to_area_tag = theater_area

// Театр
dl_nav_audience_to_street
  dl_nav_to_area_tag = city_street

dl_social_theater_1
  dl_nav_zone = audience

dl_social_theater_2
  dl_nav_zone = audience
```

### 4.12 Запреты и разрешённые адаптеры

Запрещено:

- делать отдельный ручной маршрут на каждого NPC;
- заставлять NPC сканировать весь модуль/area каждый тик;
- смешивать route planner и transition executor в одном монолите;
- делать SOCIAL как полноценную психологическую симуляцию отношений на этом этапе;
- строить новые костыли, если NWScript/NWN2 уже даёт штатный механизм.

Разрешено:

- bounded route search;
- area-level cache;
- pooled anchors;
- reservation TTL;
- fallback в `PUBLIC`/`CHILL`/idle при битой разметке;
- advanced overrides для особых переходов.

---

## 5) Runtime Core / Event Bus / Domain Adapters / Ops Layer

1. **Runtime Core**: registry, resolver pipeline, materialization, resync.
2. **Event Bus**: маршрутизация пользовательских и системных событий.
3. **Domain Adapters**: city/legal/clan/property/trade/travel hooks.
4. **Ops Layer**: инварианты, smoke/runbook, диагностика, счетчики.

---

## 6) Правила разработки и документации

- Этот файл — единственный дизайн-док.
- Любые изменения в архитектуре фиксируются только здесь.
- Приоритет: встроенные механики NWN2/NWScript и подтверждение через NWN Lexicon.
- Операционные документы сопровождения допустимы только в минимальном составе:
  - `docs/DEVELOPMENT_STATUS_RU.md` (краткий текущий статус и ближайшие шаги);
  - `docs/DEVELOPMENT_WORKFLOW_RU.md` (процесс и чек-листы сопровождения).
- Новые документы вне этого минимального набора не добавляются без явной необходимости.

---

## 7) Ближайший фокус реализации

1. Привести Daily Life runtime-код к pipeline-контракту из раздела 4.
2. Сохранить Daily Life как главный активный runtime-контур.
3. Стандартизировать входы внешних инцидентов через единый контракт.
4. Довести интеграционные handoff-точки с city/legal/clan/property/trade/travel.
5. Сохранять производительность через bounded execution и наблюдаемость.

---

## 8) Runtime Truth / Activity Journal (Daily Life)

### 2026-05-02 — фиксация Daily Life vNext pipeline-контракта

- Зафиксирован канонический pipeline: `Schedule -> Directive -> Activity / Scene -> Destination Resolver -> Nav Router -> Transition Executor -> Action / Animation`.
- Для runtime-директив обязателен внутренний шаблон шагов: `Validate -> Resolve -> Prepare -> Execute -> Finalize`; новые директивы не должны вводить локальные mini-state-machine вне этого шаблона.
- Старый transition layer переопределён как низкоуровневый `Transition Executor`, а не как конкурирующая навигационная система.
- `SOCIAL` зафиксирован как social destination/activity layer: `paired_chat`, `theater`, `tavern`, `public`.
- Разметка должна принадлежать location/area, а не конкретному NPC; замена NPC не должна требовать перестановки waypoint-разметки.
- `dl_nav_zone` трактуется как физико-навигационный фрагмент, а не назначение комнаты.
- Следующий runtime-фокус: привести include-слой к строгому разделению `Destination Resolver` / `Nav Router` / `Transition Executor`.
- В runtime CR tuning зафиксированы cooldown-параметры в `daily_life/dl_city_response_inc.nss`: `DL_CR_EPISODE_COOLDOWN_MIN` и `DL_CR_GUARD_REACTION_COOLDOWN_MIN` (убран hardcoded `+ 1` для guard perception cooldown).

### 2026-04-21 — фиксация канонического статуса Legal (City Response)

- Устранён конфликт формулировок между документами по стадии Legal.
- Канонический факт: `legal witness lifecycle v1 scaffold` уже реализован (witnessed handoff + переходы `active -> detained/resolved`).
- Полный судебный/расследовательский legal-контур зафиксирован как следующий этап, не входящий в текущий v1 runtime.

### 2026-05-02 — canonical API для `detain pending` (crime/legal handoff)

- Для флага `DL_L_PC_CR_DETAIN_PENDING` канонизирован единый helper-набор:
  - `DL_CR_SetDetainPending(oPc, nUntilAbsMin, sReason)`;
  - `DL_CR_ClearDetainPending(oPc, sResolution)`;
  - `DL_CR_IsDetainPending(oPc)`.
- Прямые записи/очистки `SetLocalInt/DeleteLocalInt` этого флага в crime flow заменяются на helper API.
- Helper API синхронизирует legal-handoff поля:
  - обновляет `DL_L_PC_LG_CASE_LAST_UPDATE_ABS_MIN`;
  - ведёт диагностические метки причины/резолюции (`DL_L_PC_CR_DETAIN_PENDING_REASON`, `DL_L_PC_CR_DETAIN_PENDING_RESOLUTION`);
  - очищает/ведёт `DL_L_NPC_CR_OFFENDER_UNTIL` как TTL pending-состояния.
- Закреплено требование идемпотентности:
  - повторный `set` с тем же/менее строгим TTL и той же причиной не даёт дублирующего эффекта;
  - повторный `clear` при уже очищенном состоянии — no-op.

### 2026-04-21 — процессная синхронизация документации (README + docs)

- Зафиксирован обязательный процесс синхронизации документации в каждом runtime-коммите: `README` + `DEVELOPMENT_STATUS` + (при архитектурных изменениях) `UNIFIED`.
- Явно закреплена маркировка `⏳ validation pending` для сценариев без подтверждения owner-run.
- Подтверждён неизменный baseline: сначала встроенные функции/механики NWScript/NWN2 (с опорой на NWN Lexicon), затем минимальные адаптеры только при отсутствии штатного решения.

### 2026-04-15 — фиксация текущего прогресса после post-refactor audit (pass 4)

- Зафиксировано, что после include-decomposition Daily Life остаётся runtime-safe по базовым инвариантам (budget-bound worker, стабильный lifecycle порядок, сохранён cache-layer).
- Подтверждён главный риск производительности: в HOT-area при `area-enter resync pending` возможна двойная обработка одного NPC в рамках одного heartbeat (resync pass + worker pass).
- Приоритет на следующий runtime-шаг: минимальная mitigation-правка через same-heartbeat dedupe marker (без смены архитектуры и без отказа от event-first модели).
- Второй приоритет: снизить lookup churn в SOCIAL через валидацию/переиспользование partner object cache.
- В документационном контуре закреплено: для изменений используем штатные механики NWN2/NWScript и подтверждённые функции/паттерны NWN Lexicon, не вводя ad-hoc обходы.

### 2026-04-15 — закладка anti-degradation архитектурного контура (budget pressure guard)

- В module budget-контуре введён **pressure detector** на штатных locals NWScript: при систематическом дефиците minute-budget (`requested > granted`) модуль помечается как `budget pressure active`.
- При активном pressure автоматически включается **мягкое load-shedding ограничение**:
  - cap для area worker budget (hot path),
  - отдельный cap для area resync budget,
  что снижает риск лавинообразной деградации при длительных burst-нагрузках.
- Выход из pressure выполняется только после серии стабильных «полных» grant-ов бюджета (relief streak), чтобы избежать дрожания режима (thrashing).
- Решение реализовано без кастомного планировщика и без новых обходных костылей: используется существующий minute-window budget-контракт и стандартные local-переменные объекта `module`.

### 2026-04-14 — синхронизация документационного контура

- README приведён к единому doc-маршруту: активным источником считается только `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`.
- Зафиксировано правило документации: при разработке использовать штатные механики NWN2/NWScript и проверенные паттерны из NWN Lexicon, без ad-hoc обходов.

### 2026-04-14 — фиксация текущего runtime-состояния Daily Life (по `main`)

#### Что внедрено (уже влито в `main`)

- **Minute-based directive resolution**: директива рассчитывается поминутно (`DL_ResolveNpcDirectiveAtMinute`) с оконной логикой сна/еды/работы/social/public.
- В runtime-контуре директив уже используются **`MEAL`**, **`SOCIAL`**, **`PUBLIC`** (помимо `SLEEP`/`WORK`) как materialization и execution-состояния.
- На NPC используются area-теги: **`home/work/meal/social/public`** (`dl_home_area_tag`, `dl_work_area_tag`, `dl_meal_area_tag`, `dl_social_area_tag`, `dl_public_area_tag`).
- Для area-based навигации применяются **`dl_anchor_*` area-local anchors** (sleep/work/meal/social/public) как первичные точки назначения.
- Внедрена **weekend-логика** (в т.ч. `off_public` и `reduced_work`, с weekend-ветвлением в директивном резолвере).
- Влиты runtime-диагностика и анти-спам логирования: сигнатурный дедуп диагностик NPC (повторяющиеся состояния не спамят лог каждый тик).
- Внедрён **двухконтурный quota-control**: отдельный area-resync budget + module-level NPC budget per minute (burst-ограничение между несколькими hot-area).
- В runtime добавлены **операционные метрики последнего тика** (`worker_last_processed`/`resync_last_processed` на area и module уровне).

#### Что подтверждено как текущая runtime truth

- Текущая Daily Life модель считается **schedule-driven/area-driven runtime-моделью**; старая legacy-разметка больше не трактуется как канонический baseline.
- **NPC location model = area-based** (через area tag locals на NPC и area anchor locals на area).
- **Area anchors — source of truth** для целевых точек Daily Life в area-контексте.
- **Legacy waypoint fallback** существует как совместимость/страховка для части профилей, но **не является целевой моделью развития**.

#### Что ещё не подтверждено owner-run тестом (open runtime validation)

- Кузнец в будни (полный цикл WORK/MEAL/SOCIAL/PUBLIC/SLEEP).
- Кузнец в выходные (влияние weekend mode на поведение).
- NPC без `work` area-тега (ожидаемый graceful fallback/idle-public-path, без деградации контура).
- Торговец с `reduced_work` (корректное сокращение смены в weekend-режиме).
- Успешный social pair сценарий (оба NPC доходят/держат social anchor).
- Fallback из SOCIAL в PUBLIC при несостоявшейся паре.
- Поведение при missing anchor (диагностика + безопасное поведение без «залипания»).
- Практическая полезность chat debug в реальном owner-run (достаточность сигналов, отсутствие лишнего шума).

#### Known risks (текущее честное состояние)

- Часть weekend/public поведения всё ещё требует owner validation в живом прогоне.
- SOCIAL/PUBLIC сцены пока уровня **v1 richness** (функционально есть, но глубина сценариев ограничена).
- Корректность area-driven модели критически зависит от полноты и правильности area markup.
- Финальная уверенность по качеству Daily Life требует **in-game owner run**, а не только code inspection.

#### Что тестировать следующим (owner run next steps)

1. Прогон «кузнец будни» и «кузнец выходные» в одном и том же area-наборе, с включённым chat-log и фиксацией директив по времени.
2. Проверка trader `reduced_work` на субботе/воскресенье (факт сокращения смены + корректный выход в public/social окна).
3. Негативные кейсы markup: NPC без `work`, area без `dl_anchor_public`, area с битым anchor waypoint tag.
4. SOCIAL pair matrix: валидный партнёр, невалидный партнёр, партнёр вне area — с проверкой, что fallback в PUBLIC стабилен.

---

## 9) Архитектурная оптимизация (best practices + справка NWN Lexicon)

Ниже — зафиксированный набор практик, который используем как baseline для оптимизации runtime-кода.

### 9.1 Проверенные практики из NWN Lexicon

1. **Минимизировать частые полные обходы area-объектов**<br>
   `GetFirstObjectInArea`/`GetNextObjectInArea` полезны, но их не рекомендуют гонять слишком часто в крупных/населённых локациях. Следствие: worker-контур должен оставаться quota-based, а тяжёлые массовые обходы — только по событию/по необходимости.

2. **Осторожно использовать `DelayCommand` как инфраструктуру планирования**<br>
   По справке, множественные `DelayCommand` (особенно рекурсивные/долгие цепочки) могут приводить к проблемам производительности и к сложному поведению контекста. Следствие: для ядра Daily Life сохраняем event-first runtime, без «таймерной паутины».

3. **Сигнализация событий вместо прямого fan-out в одном скрипте**<br>
   `SignalEvent` исполняется как отдельная от вызывающего скрипта единица и подходит для развязки ingress/dispatch логики. Следствие: держим тонкие ingress-скрипты и передаём тяжёлую работу в резолверы/воркеры.

4. **Фильтровать типы объектов при area-итерациях**<br>
   Вызовы обхода area должны всегда использовать object-filter (например, `OBJECT_TYPE_CREATURE`) для снижения стоимости перебора.

### 9.2 Практические рекомендации для vNext

1. **Area worker: переход к registry-driven итерации (приоритет P1)**<br>
   Цель: уйти от регулярного полного area-scan в тиках hot-tier.<br>
   Подход: хранить компактный реестр активных NPC на area-уровне (через стабильные ключи/индексы) и обрабатывать только его.

2. **Burst-контроль ingress (P1)**<br>
   Ввести единый module-level лимит «максимум обработок NPC за тик» поверх area budget, чтобы входящий burst из нескольких горячих area не приводил к frame-spike.

3. **Resync как отдельная фазовая квота (P1)**<br>
   Разделить обычный worker budget и resync budget, чтобы массовый resync не вытеснял runtime-обновление уже активных NPC.

4. **Диагностический профиль производительности (P2)**<br>
   Добавить метрики в module/area locals:
   - `processed_per_tick`
   - `resync_processed_per_tick`
   - `ingress_queue_depth`
   - `max_tick_cost_marker`

5. **Контракт на idempotent transitions (P2)**<br>
   Формализовать таблицу разрешённых переходов directive/state и запретить повторную «дорогую» materialization, если effective state не изменился.

6. **Adaptive backpressure (P1, внедрено v1)**<br>
   На уровне module budget поддерживать флаг pressure-режима, который автоматически снижает cap worker/resync budgets в hot-контуре до безопасного минимума, пока не восстановится устойчивый запас minute-budget.

### 9.3 Decision policy (обязательная)

- Если есть встроенный механизм NWScript/NWN2 и он покрывает задачу — используем его.
- Если встроенный механизм частично покрывает задачу — применяем тонкую адаптацию, не ломая runtime-контракты.
- Если механизма нет — расширяем через явный контракт + диагностику + bounded execution.

### 9.4 Sources of truth (внешние ссылки)

- NWN Lexicon: `GetFirstObjectInArea` — рекомендации по частоте обходов и фильтрам.<br>
  https://nwnlexicon.com/GetFirstObjectInArea
- NWN Lexicon: `DelayCommand` — ограничения/подводные камни и влияние на производительность.<br>
  https://www.nwnlexicon.com/DelayCommand
- NWN Lexicon: `SignalEvent` — модель исполнения событийного сигнала.<br>
  https://nwnlexicon.com/SignalEvent

### 9.5 Применено в runtime (2026-04-14)

- В `dl_worker_inc.nss` оптимизирован `DL_RunAreaNpcRoundRobinPass`:
  - добавлен fast-path раннего выхода из area-обхода после выполнения бюджета в логическом окне `cursor + budget`;
  - `DL_L_AREA_REG_COUNT` используется как registry-backed источник размера активного набора NPC для вычисления `pass_last_seen`, чтобы не требовать полного досканирования area каждый тик.
- Дополнительно усилен registry-first подход:
  - если `DL_L_AREA_REG_COUNT == 0`, включается throttled bounded registry-reconcile (редкий и лимитированный scan), чтобы восстановиться после пропущенных lifecycle/register событий;
  - при успешном reconcile worker возвращается к registry-driven pass без полного area-scan;
  - `pass_last_seen` фиксируется из реестра (`DL_L_AREA_REG_COUNT`) как стабильный размер логического окна round-robin, без перехода к scan-derived значению;
  - меж-area миграция уже зарегистрированного активного NPC теперь корректирует `DL_L_AREA_REG_COUNT` и `DL_L_AREA_REG_SEQ` в обеих area (old/new) через reconcile-path, с защитой от двойного декремента ниже нуля.
- Это следует практикам NWN Lexicon:
  - избегать частых полных area-обходов (`GetFirstObjectInArea` / `GetNextObjectInArea`);
  - оставлять event/registry-driven модель как приоритет над «сканировать всё каждый тик».

---

## 10) Daily Life canonical extension: shared home + residence slots + domestic profile

### 10.1 Короткий канонический дизайн-блок

- `home` в Daily Life трактуется как **общая area проживания** для нескольких NPC, а не «личный дом на одного NPC».
- Привязка NPC к проживанию канонически задаётся парой:
  - `dl_home_area_tag` — тег общего дома (`home area`);
  - `dl_home_slot` — безличный слот проживания (`1`, `2`, `3`, ...).
- `dl_home_slot` — технический идентификатор спального места в общем доме. Он **не кодирует родство** и не несёт семантики семейной роли.
- В общем доме:
  - sleep anchors — **slot-specific**;
  - meal/public anchors — **общие** для жильцов.
- Для бытовой дневной занятости вводится профиль `domestic_worker`: cooking/craft/fetch и прочие домашние задачи без привязки к семейной роли.

### 10.2 Словарь local variables и anchor names

#### NPC locals

- `dl_home_area_tag` — area-тег общего дома.
- `dl_home_slot` — номер безличного слота проживания внутри `home area`.
- `dl_profile_id=domestic_worker` — профиль бытовой дневной деятельности (дневной труд по дому).

#### Home area anchors (канон)

- Общие:
  - `dl_anchor_meal`
  - `dl_anchor_public`
- Послотные:
  - `dl_anchor_sleep_approach_<slot>`
  - `dl_anchor_sleep_bed_<slot>`

Пример для слота `2`:
- `dl_anchor_sleep_approach_2`
- `dl_anchor_sleep_bed_2`

### 10.3 Почему семейные роли не используются как profile id

- Явно запрещено вводить profile id вида:
  - `wife_of_blacksmith`
  - `brother_of_blacksmith`
  - `child_of_blacksmith`
- Семейные роли смешивают **социальную связь** и **runtime-поведение**, что приводит к взрывному росту профилей.
- Daily Life резолверу нужен профиль поведения (что NPC делает днём), а не генеалогическая метка.
- Родство — это не тип runtime-поведения; оно живёт в отдельном слое социальных/семейных данных.
- `domestic_worker` переиспользуется для жены/брата/сестры/взрослого ребёнка/домашней прислуги без дублирования кода и без жёсткой привязки к одному «главному» NPC.

### 10.4 Новый канонический профиль: `domestic_worker`

- Назначение: основной дневной труд по дому.
- Типичные задачи: cooking / craft / fetch (через существующие Daily Life окна и anchors).
- Не привязывается к роли «жена/брат/ребёнок»; это именно профиль runtime-поведения.
- Может использоваться в любом составе жильцов, где нужен бытовой цикл внутри общего дома.

### 10.5 Короткие канонические примеры

1. **Кузнец + жена в одной кузнице/доме**
   - Оба NPC имеют `dl_home_area_tag=smithy_home`.
   - Кузнец: `dl_profile_id=blacksmith`, `dl_home_slot=1`.
   - Жена: `dl_profile_id=domestic_worker`, `dl_home_slot=2`.
   - Sleep anchors: `..._1` для кузнеца, `..._2` для жены; `dl_anchor_meal` и `dl_anchor_public` общие.

2. **Кузнец + брат в одной кузнице/доме**
   - Оба NPC используют один `dl_home_area_tag`.
   - Брат не получает профиль `brother_of_blacksmith`; он получает поведенческий профиль (`domestic_worker` или другой по занятости) и собственный `dl_home_slot`.
   - Домовая разметка не меняется, меняется только набор NPC/профилей.

3. **Замена кузнеца на другого NPC без переделки дома**
   - `home area` и anchor-структура сохраняются прежними.
   - Убывший NPC удаляется из состава жильцов, новый NPC получает тот же `dl_home_area_tag` и нужный `dl_home_slot`.
   - Переиспользуются существующие `dl_anchor_sleep_approach_<slot>` / `dl_anchor_sleep_bed_<slot>` и общие meal/public anchors без рефакторинга структуры дома.

- Transition execution primitives централизованы в модуле `daily_life/dl_transition_engine_inc.nss` (single source of truth); `daily_life/dl_cross_area_nav_inc.nss` содержит только route-discovery логику для межзональной навигации.
