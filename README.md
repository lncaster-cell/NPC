# NPC (PysukSystems)

> Обновлено: **2026-04-20**

## Что это

Проект runtime-системы «живого мира» для NWN2, где ядром является контур **Daily Life** в `daily_life/`.

Базовый принцип разработки: сначала использовать встроенные механики NWN2/NWScript и проверенные функции/паттерны из **NWN Lexicon**, и только при реальной необходимости добавлять тонкие адаптеры без ad-hoc костылей.

## Текущий прогресс (кратко)

- Daily Life работает как event-first/area-driven runtime-контур.
- Post-refactor audit (pass 4) завершён и зафиксирован: `daily_life/post_refactor_audit_pass4.md`.
- Главный технический приоритет: убрать same-heartbeat двойную обработку NPC при area-enter resync (R1) минимальной безопасной правкой.

## Цели текущего этапа

1. Снизить hot-path churn без архитектурного переписывания.
2. Довести owner-run валидацию сценариев будни/выходные и негативных markup-кейсов.
3. Поддерживать документацию синхронной с фактическим состоянием `main`.

## Минимальный набор документации

- `docs/UNIFIED_DESIGN_DOCUMENT_RU.md` — канонический дизайн и архитектурные решения.
- `docs/DEVELOPMENT_STATUS_RU.md` — краткий оперативный статус и ближайшие шаги.
- `docs/DEVELOPMENT_WORKFLOW_RU.md` — правила сопровождения, чек-листы изменений и синхронизации docs/code.

## Где вносить runtime-изменения

- Активный workspace: `daily_life/`.
- Новые runtime-правки (`.nss`) вносятся в `daily_life/`.
- В активной документации не использовать legacy-путь `scripts/daily_life/`.

## Установка Daily Life в модуль NWN2

Ниже — практическая «карта подключения»: какие скрипты назначать, какие теги/локации задавать и какие local variables выставлять в Toolset.

### 1) Подготовка скриптов

1. Скопируйте/подключите все файлы из `daily_life/*.nss` в модуль.
2. Скомпилируйте скрипты в Toolset (получите `.ncs`).
3. Убедитесь, что entrypoint-скрипты компилируются без ошибок:
   - `dl_load`
   - `dl_a_enter`
   - `dl_a_exit`
   - `dl_a_hb`
   - `dl_spawn`
   - `dl_damaged`
   - `dl_death`
   - `dl_blocked`
   - `dl_perception`
   - `dl_disturbed`
   - `dl_open`
   - `dl_cr_restricted_trg`
   - `dl_cr_detain_accept`
   - `dl_cr_detain_refuse`
   - `dl_lg_resolve_fine`
   - `dl_lg_resolve_detain`
   - `dl_userdef`

### 2) Какие скрипты куда назначать

#### Module

- **OnModuleLoad** → `dl_load`

#### Area (для каждой area, где должен работать Daily Life)

- **OnEnter** → `dl_a_enter`
- **OnExit** → `dl_a_exit`
- **OnHeartbeat** → `dl_a_hb`

#### Creature/NPC (для всех NPC, которые участвуют в Daily Life)

- **OnSpawn** → `dl_spawn`
- **OnDamaged** → `dl_damaged`
- **OnDeath** → `dl_death`
- **OnBlocked** → `dl_blocked`
- **OnPerception** → `dl_perception` (для guard NPC, если включён City Response)
- **OnDisturbed** → `dl_disturbed` (container theft / pickpocket ingress)
- **OnOpen** → `dl_open` (door/placeable burglary ingress)
- **OnUserDefined** → `dl_userdef`

#### Trigger (restricted-зоны)

- **OnEnter** → `dl_cr_restricted_trg` (restricted entry ingress)

> Важно: `OnUserDefined` обязателен, потому что lifecycle и blocked-сигналы идут через `EventUserDefined(3001)` внутри runtime-контура.

### 3) Что прописывать в local variables (локалки)

### 3.1 Module locals

Минимум:

- `dl_enabled = 1` — включает runtime (при загрузке также ставится контракт `dl_contract_version=a0`).
- `dl_city_response_enabled = 1` — включает City Response контур на уровне модуля (ветка атаки/убийства).
- `dl_cr_witness_radius = 10` — радиус поиска свидетелей для crime ingress.
- `dl_cr_guard_alert_radius = 20` — радиус немедленного оповещения guard после witnessed crime.
- `dl_cr_guard_responders_max = 2` — сколько ближайших guard-постов реагируют на witnessed crime.
- `dl_cr_detain_dialog = dl_cr_guard_detain` — resref диалога задержания (guard → offender).
- `dl_cr_jail_wp_tag = dl_jail_entry_wp` — waypoint-tag для телепорта при сдаче.
- `dl_lg_default_fine = 100` — дефолтный штраф для Legal v1.1 resolve-fine (если явно не передан).

Опционально для отладки:

- `dl_chat_debug = 1`
- `dl_chat_debug_npc_tag = <tag_npc>` (пусто = для всех NPC)

### 3.2 NPC locals (базовая разметка профиля и локаций)

Обязательная базовая разметка:

- `dl_profile_id` = один из профилей:
  - `blacksmith`
  - `gate_post`
  - `trader`
  - `domestic_worker`
- `dl_home_area_tag` = тег домашней area

Рекомендуемая area-разметка поведения:

- `dl_work_area_tag`
- `dl_meal_area_tag`
- `dl_social_area_tag`
- `dl_public_area_tag`

Для shared-home модели (канон):

- `dl_home_slot` = номер слота проживания (`1`, `2`, `3`, ...)

Для City Response (атака/убийство):

- `gate_post` считается guard-профилем и получает усиленную реакцию/вес инцидента.

Опционально для расписания/режима:

- `dl_wake_hour`
- `dl_sleep_hours`
- `dl_shift_start`
- `dl_shift_length`
- `dl_weekend_mode` = `off_public` или `reduced_work`
- `dl_weekend_shift_length`
- `dl_social_slot` = `a` или `b`
- `dl_social_partner_tag` = tag NPC-партнёра

### 3.2.1 Player legal locals (Legal v1)

Заполняются runtime автоматически (вручную не проставлять):

- `dl_lg_case_state` (`0 none / 1 active / 2 detained / 3 resolved`)
- `dl_lg_case_kind`
- `dl_lg_case_severity`
- `dl_lg_case_open_abs_min`
- `dl_lg_case_last_update_abs_min`
- `dl_lg_last_witness_tag`
- `dl_lg_last_witnessed_kind`
- `dl_lg_last_witnessed_area`
- `dl_lg_last_witnessed_abs_min`
- `dl_lg_case_resolution` (`fine` / `detain_complete`)
- `dl_lg_case_fine`

### 3.3 Area locals с anchor-точками (что вы назвали «локализации»)

Daily Life использует area-local ссылки на waypoint/object через имена anchor-локалок.

Общие anchors для area:

- `dl_anchor_meal`
- `dl_anchor_public`

Area-флаг для City Response:

- `dl_city_response_enabled = 1` — включает реакцию города в конкретной area (по умолчанию контур выключен, даже если включён на модуле).
- `dl_cr_restricted = 1` — помечает restricted area для инцидента проникновения.

### 3.4 Диалог задержания (Detain Flow v1)

При witnessed crime ближайшие guard реагируют точечно (по умолчанию 1–2 поста), пытаются подойти к offender и запустить диалог `dl_cr_guard_detain`.

В диалоге рекомендуется две action-ноды:

- «Сдаться» → `dl_cr_detain_accept` (телепорт в jail waypoint).
- «Отказаться» → `dl_cr_detain_refuse` (эскалация и силовое задержание).

Минимальный runtime-контракт для detain flow:

- у guard/NPC с реакцией должен быть корректный профиль `gate_post`;
- в модуле должен существовать `.dlg` ресурс с resref из `dl_cr_detain_dialog` (по умолчанию `dl_cr_guard_detain`);
- в модуле должен существовать waypoint для тюрьмы с tag из `dl_cr_jail_wp_tag` (по умолчанию `dl_jail_entry_wp`);
- если `dl_cr_guard_responders_max` не задан, по умолчанию реагируют 2 ближайших поста.

Сон по слотам проживания:

- `dl_anchor_sleep_approach_<slot>`
- `dl_anchor_sleep_bed_<slot>`

Рабочие anchors (в зависимости от профиля/сцены):

- `dl_anchor_work_primary`
- `dl_anchor_work_secondary`
- `dl_anchor_work_fetch`

Social anchors:

- `dl_anchor_social_a`
- `dl_anchor_social_b`

### 4) Минимальный чек-лист после установки

1. Перезагрузите модуль (чтобы отработал `OnModuleLoad=dl_load`).
2. Зайдите игроком в area с назначенным `dl_a_enter` и `dl_a_hb`.
3. Проверьте, что у тестового NPC выставлены минимум `dl_profile_id` и `dl_home_area_tag`.
4. Проверьте, что в area реально есть anchors, на которые ссылаются локалки.
5. Для smoke-проверок можно запускать вспомогательные скрипты `dl_smk_*` вручную в test-area.
6. Для City Response smoke:
   - witnessed кража должна вызвать shout свидетеля и реакцию только ближайших guard;
   - в диалоге guard ветка «Сдаться» должна телепортировать в jail waypoint;
   - ветка «Отказаться» должна эскалировать задержание в силовую фазу.

## NWN Lexicon reference points (для реализации без костылей)

Ключевые встроенные механики, на которые опирается текущий City Response/Detain контур:

- `OnDisturbed`, `GetLastDisturbed`, `GetInventoryDisturbType` — ingress краж из инвентаря/контейнеров.
- `OnOpen`, `GetLastOpenedBy`, `GetLocked` — ingress взлома дверей/placeable.
- `OnPerception`, `GetLastPerceived`, `GetObjectSeen`, `GetObjectHeard` — witness/perception логика.
- `AssignCommand`, `ActionMoveToObject`, `ActionStartConversation` — событийная реакция guard без heavy heartbeat.
- `ActionJumpToLocation` + waypoint — доставка задержанного в jail-point.

## Perf notes (City Response / Witness)

- Witness/guard выборка ограничена **локальным радиусом** вокруг offender через shape-итераторы, а не полным обходом area.
- Введены защитные cap-лимиты на число проверяемых объектов за событие, чтобы не раздувать стоимость в crowded-зонах.
- `OnPerception` фильтруется по факту `seen/heard`, чтобы не обрабатывать шумные переходные события.

## Legal v1 notes

- Witnessed crime теперь делает handoff в legal-case runtime-состояние (`dl_lg_case_state=active`).
- При сдаче (`dl_cr_detain_accept`) legal-case переходит в `detained`.
- При отказе (`dl_cr_detain_refuse`) legal severity повышается.
- Для простого финализатора без “полного суда”:
  - `dl_lg_resolve_fine` закрывает кейс как `fine`;
  - `dl_lg_resolve_detain` закрывает кейс как `detain_complete`.
