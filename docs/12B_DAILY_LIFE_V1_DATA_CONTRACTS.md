# Ambient Life v2 — Daily Life v1 Data Contracts

Дата: 2026-03-20  
Статус: implementation contract draft  
Назначение: инженерная спецификация структур данных, enum-ов и минимальных runtime-контрактов для первой реализации Daily Life v1.

> Обновление статуса (2026-04-01): часть enum-набора в этом документе описывает расширенный целевой дизайн (vNext) и может не совпадать 1:1 с текущими идентификаторами Milestone A runtime в `scripts/daily_life/dl_const_inc.nss`.
> Для фактической проверки текущего runtime-контракта используйте код как source-of-truth и `docs/22_RUNTIME_TRUTH_AND_ACTIVITY_JOURNAL.md`.

### Быстрая сверка с Milestone A runtime (2026-04-02)

Ниже — короткая таблица соответствия наиболее часто используемых идентификаторов этого документа к фактическим runtime-именам в `scripts/daily_life/dl_const_inc.nss`.

| Doc name (vNext/spec) | Runtime name (Milestone A) | Статус |
|---|---|---|
| `DL_SUB_LAW_PATROL` | `DL_SUBTYPE_PATROL` | renamed in runtime |
| `DL_SUB_LAW_GATE_POST` | `DL_SUBTYPE_GATE_POST` | renamed in runtime |
| `DL_SUB_LAW_INSPECTION` | `DL_SUBTYPE_INSPECTION` | renamed in runtime |
| `DL_SUB_CRAFT_BLACKSMITH` | `DL_SUBTYPE_BLACKSMITH` | renamed in runtime |
| `DL_SUB_CRAFT_ARTISAN` | `DL_SUBTYPE_ARTISAN` | renamed in runtime |
| `DL_SUB_TRADE_SHOPKEEPER` | `DL_SUBTYPE_SHOPKEEPER` | renamed in runtime |
| `DL_SUB_TRADE_INNKEEPER` | `DL_SUBTYPE_INNKEEPER` | renamed in runtime |
| `DL_SUB_CIV_RESIDENT` | `DL_SUBTYPE_RESIDENT` | renamed in runtime |
| `DL_SUB_ELITE_OFFICIAL` | `DL_SUBTYPE_OFFICIAL` | renamed in runtime |
| `DL_DAY_NORMAL` | `DL_DAY_WEEKDAY` | semantic rename |
| `DL_WIN_MIDDAY_EAT` | — | not present in Milestone A |
| `DL_WIN_RETURN` | — | not present in Milestone A |
| `DL_WIN_PUBLIC` | `DL_WIN_PUBLIC_IDLE` | narrowed/renamed |
| `DL_DIR_RETURN_BASE` | — | not present in Milestone A |
| `DL_DIR_EAT` | — | not present in Milestone A |
| `DL_DIR_WORSHIP` | — | not present in Milestone A |
| `DL_DLG_NORMAL` | `DL_DLG_NONE` (functional baseline) | runtime uses NONE baseline |
| `DL_ACT_EAT` | — | not present in Milestone A |
| `DL_ACT_WORSHIP` | — | not present in Milestone A |
| `DL_OVR_CITY_ALARM` | — | not present in Milestone A |
| `DL_OVR_FIRE` | `DL_OVR_FIRE` | matches |
| `DL_OVR_QUARANTINE` | `DL_OVR_QUARANTINE` | matches |
| `DL_AREA_FROZEN` | `DL_AREA_FROZEN` | matches |
| `DL_AREA_WARM` | `DL_AREA_WARM` | matches |
| `DL_AREA_HOT` | `DL_AREA_HOT` | matches |

---

> Этот документ дополняет:
> - `docs/12B_DAILY_LIFE_VNEXT_CANON.md`
> - `docs/archive/12B_DAILY_LIFE_V1_RULESET_legacy_2026-03-20.md`
> - `docs/12B_DAILY_LIFE_V1_RULESET_REV1.md`
>
> Его задача — дать агенту и разработчику конкретный набор сущностей, enum-ов и полей, по которым можно писать код без повторного расползания дизайна.

## 1) Общий принцип

Daily Life v1 строится не как честная симуляция, а как rule-driven система.

Следствие для кода:
- нужны компактные enum-ы;
- нужны предсказуемые контракты данных;
- нужно как можно меньше “свободных текстовых состояний”;
- основной расчёт должен сводиться к последовательности:
  1. собрать входы;
  2. определить директиву;
  3. определить anchor group;
  4. выбрать точку;
  5. выбрать активность/анимацию;
  6. определить режим диалога и доступность сервиса.

---

## 2) Базовые enum-ы

## 2.1 Identity policy

### `DL_IDENTITY_KIND`
- `DL_IDENTITY_NAMED`
- `DL_IDENTITY_UNNAMED`

### `DL_PERSISTENCE_POLICY`
- `DL_PERSISTENT`
- `DL_REPLACEABLE`

---

## 2.2 NPC family

### `DL_NPC_FAMILY`
- `DL_FAMILY_LAW`
- `DL_FAMILY_CRAFT`
- `DL_FAMILY_TRADE_SERVICE`
- `DL_FAMILY_CIVILIAN`
- `DL_FAMILY_ELITE_ADMIN`
- `DL_FAMILY_CLERGY`

### `DL_NPC_SUBTYPE`

#### Для `DL_FAMILY_LAW`
- `DL_SUB_LAW_PATROL`
- `DL_SUB_LAW_GATE_POST`
- `DL_SUB_LAW_INSPECTION`

#### Для `DL_FAMILY_CRAFT`
- `DL_SUB_CRAFT_BLACKSMITH`
- `DL_SUB_CRAFT_ARTISAN`
- `DL_SUB_CRAFT_LABORER`

#### Для `DL_FAMILY_TRADE_SERVICE`
- `DL_SUB_TRADE_SHOPKEEPER`
- `DL_SUB_TRADE_INNKEEPER`
- `DL_SUB_TRADE_WANDERING_VENDOR`

#### Для `DL_FAMILY_CIVILIAN`
- `DL_SUB_CIV_RESIDENT`
- `DL_SUB_CIV_HOMELESS`
- `DL_SUB_CIV_SERVANT`

#### Для `DL_FAMILY_ELITE_ADMIN`
- `DL_SUB_ELITE_NOBLE`
- `DL_SUB_ELITE_OFFICIAL`
- `DL_SUB_ELITE_SCRIBE`

#### Для `DL_FAMILY_CLERGY`
- `DL_SUB_CLERGY_PRIEST`

---

## 2.3 Schedule / day type

### `DL_SCHEDULE_TEMPLATE`
- `DL_SCH_EARLY_WORKER`
- `DL_SCH_SHOP_DAY`
- `DL_SCH_TAVERN_LATE`
- `DL_SCH_DUTY_ROTATION_DAY`
- `DL_SCH_DUTY_ROTATION_NIGHT`
- `DL_SCH_LATE_ELITE`
- `DL_SCH_OFFICE_DAY`
- `DL_SCH_CLERGY_DAY`
- `DL_SCH_STREET_IRREGULAR`
- `DL_SCH_WANDERING_VENDOR_WINDOW`

### `DL_DAY_TYPE`
- `DL_DAY_NORMAL`
- `DL_DAY_REST`
- `DL_DAY_HOLY`
- `DL_DAY_CRISIS`

### `DL_TIME_WINDOW`
- `DL_WIN_SLEEP`
- `DL_WIN_MORNING_PREP`
- `DL_WIN_WORK_CORE`
- `DL_WIN_MIDDAY_EAT`
- `DL_WIN_PUBLIC`
- `DL_WIN_EVENING`
- `DL_WIN_RETURN`
- `DL_WIN_NIGHT_DUTY`
- `DL_WIN_LATE_SOCIAL`

---

## 2.4 Base / context

### `DL_BASE_KIND`
- `DL_BASE_HOME`
- `DL_BASE_SHOP`
- `DL_BASE_FORGE`
- `DL_BASE_TAVERN`
- `DL_BASE_BARRACKS`
- `DL_BASE_OFFICE`
- `DL_BASE_TEMPLE`
- `DL_BASE_SHELTER`
- `DL_BASE_STREET_ZONE`
- `DL_BASE_WORKSHOP`

### `DL_BASE_STATE`
- `DL_BASE_VALID`
- `DL_BASE_LOST`
- `DL_BASE_FORBIDDEN`
- `DL_BASE_DESTROYED`
- `DL_BASE_PLAYER_OWNED_EXCLUSION`

---

## 2.5 Anchor groups

### `DL_ANCHOR_GROUP`
- `DL_AG_SLEEP`
- `DL_AG_WORK`
- `DL_AG_SERVICE`
- `DL_AG_EAT`
- `DL_AG_SOCIAL`
- `DL_AG_WORSHIP`
- `DL_AG_DUTY`
- `DL_AG_IDLE_BASE`
- `DL_AG_ENTRY`
- `DL_AG_STREET_NEAR_BASE`
- `DL_AG_SAFE`
- `DL_AG_GATE`
- `DL_AG_PATROL_POINT`
- `DL_AG_OFFICE`
- `DL_AG_WAIT`

### `DL_ANCHOR_SELECT_RESULT`
- `DL_ANCHOR_OK`
- `DL_ANCHOR_FALLBACK_USED`
- `DL_ANCHOR_NONE_FOUND`
- `DL_ANCHOR_CONTEXT_FORBIDDEN`

---

## 2.6 Directive

### `DL_DIRECTIVE`

#### Базовые
- `DL_DIR_SLEEP`
- `DL_DIR_WORK`
- `DL_DIR_SERVICE`
- `DL_DIR_EAT`
- `DL_DIR_SOCIAL`
- `DL_DIR_WORSHIP`
- `DL_DIR_DUTY`
- `DL_DIR_RETURN_BASE`
- `DL_DIR_IDLE_BASE`
- `DL_DIR_PUBLIC_PRESENCE`

#### Override
- `DL_DIR_HIDE_SAFE`
- `DL_DIR_LOCKDOWN_BASE`
- `DL_DIR_ASSIST_RESPONSE`
- `DL_DIR_HOLD_POST`
- `DL_DIR_LEAVE_CITY`
- `DL_DIR_BASE_LOST`
- `DL_DIR_UNASSIGNED`
- `DL_DIR_ABSENT`

### `DL_DIRECTIVE_SOURCE`
- `DL_DIRSRC_SCHEDULE`
- `DL_DIRSRC_DAY_TYPE`
- `DL_DIRSRC_CITY_OVERRIDE`
- `DL_DIRSRC_BASE_STATE`
- `DL_DIRSRC_FALLBACK`

---

## 2.7 Dialogue / service

### `DL_DIALOGUE_MODE`
- `DL_DLG_NORMAL`
- `DL_DLG_WORK`
- `DL_DLG_OFF_DUTY`
- `DL_DLG_LOCKDOWN`
- `DL_DLG_HIDE`
- `DL_DLG_INSPECTION`
- `DL_DLG_UNAVAILABLE`

### `DL_SERVICE_MODE`
- `DL_SERVICE_NONE`
- `DL_SERVICE_AVAILABLE`
- `DL_SERVICE_LIMITED`
- `DL_SERVICE_DISABLED`

---

## 2.8 Activities / animation families

### `DL_ACTIVITY_KIND`
- `DL_ACT_SLEEP`
- `DL_ACT_WORK`
- `DL_ACT_SERVICE_IDLE`
- `DL_ACT_EAT`
- `DL_ACT_SOCIAL`
- `DL_ACT_WORSHIP`
- `DL_ACT_GUARD`
- `DL_ACT_IDLE`
- `DL_ACT_WAIT`

Примечание: конкретная анимация движка может выбираться вторым слоем из `DL_ACTIVITY_KIND + npc_subtype + anchor_group`.

---

## 2.9 Overrides

### `DL_OVERRIDE_KIND`
- `DL_OVR_NONE`
- `DL_OVR_LOCAL_DISTURBANCE`
- `DL_OVR_FIRE`
- `DL_OVR_QUARANTINE`
- `DL_OVR_RIOT`
- `DL_OVR_CITY_ALARM`
- `DL_OVR_ORDER_COLLAPSE`
- `DL_OVR_RACE_BAN`
- `DL_OVR_CLAN_OUTLAW`
- `DL_OVR_CITY_DECLINE`
- `DL_OVR_BASE_INVALID`

### `DL_OVERRIDE_SEVERITY`
- `DL_OVR_SEV_LOW`
- `DL_OVR_SEV_MEDIUM`
- `DL_OVR_SEV_HIGH`
- `DL_OVR_SEV_CRITICAL`

---

## 2.10 Area tiers

### `DL_AREA_TIER`
- `DL_AREA_HOT`
- `DL_AREA_WARM`
- `DL_AREA_FROZEN`

---

## 3) Структуры данных

## 3.1 NPC profile record

`DL_NpcProfile`
- `profile_id`
- `npc_family`
- `npc_subtype`
- `identity_kind`
- `persistence_policy`
- `schedule_template_id`
- `base_id`
- `home_settlement_id`
- `service_role_id`
- `personal_time_offset_min`
- `allowed_directives_mask`
- `anchor_policy_id`
- `fallback_policy_id`
- `clan_id` (optional)
- `race_group` (optional)
- `special_override_flags` (optional)

Назначение: стабильное описание того, кто такой NPC и какие режимы для него вообще допустимы.

---

## 3.2 Schedule template record

`DL_ScheduleTemplate`
- `schedule_template_id`
- `schedule_enum`
- `default_day_type_policy`
- `window_count`
- `window_0 .. window_n`

`DL_ScheduleWindow`
- `time_window_kind`
- `start_minute`
- `end_minute`
- `preferred_directive`
- `preferred_anchor_group`
- `secondary_anchor_group`
- `allow_public_presence`
- `allow_service`
- `allow_social`
- `allow_worship`

Примечание: `start_minute` и `end_minute` задаются в минутах суток до применения `personal_time_offset_min`.

---

## 3.3 Base record

`DL_BaseRecord`
- `base_id`
- `base_kind`
- `settlement_id`
- `area_tag`
- `base_state`
- `default_safe_anchor_group`
- `default_entry_anchor_group`
- `ownership_flags`
- `access_policy_flags`

Назначение: логический опорный контекст NPC.

---

## 3.4 Anchor policy record

`DL_AnchorPolicy`
- `anchor_policy_id`
- `supported_group_count`
- `group_rule_0 .. group_rule_n`

`DL_AnchorGroupRule`
- `anchor_group`
- `required`
- `fallback_group`
- `point_selection_policy`
- `allow_shared_use`

`DL_AnchorPointRecord`
- `point_tag`
- `anchor_group`
- `priority`
- `activity_mask`
- `is_fallback`

Назначение: набор допустимых групп якорей и конкретных точек для NPC или базы.

---

## 3.5 Function slot record

`DL_FunctionSlot`
- `function_slot_id`
- `settlement_id`
- `base_id`
- `expected_family`
- `expected_subtype`
- `required_service_role`
- `fill_policy`
- `assigned_npc_id` (optional)
- `slot_state`

### `DL_FUNCTION_SLOT_STATE`
- `DL_SLOT_FILLED`
- `DL_SLOT_EMPTY`
- `DL_SLOT_DISABLED`
- `DL_SLOT_SUPPRESSED`

Назначение: описать функцию города отдельно от конкретной личности.

---

## 3.6 Override input record

`DL_OverrideState`
- `override_kind`
- `override_severity`
- `settlement_scope`
- `area_scope`
- `race_filter` (optional)
- `clan_filter` (optional)
- `family_filter` (optional)
- `directive_override` (optional)
- `suppress_materialization`
- `disable_service`
- `disable_public_presence`

Назначение: read-only вход из внешних систем.

---

## 3.7 Resolver input

`DL_ResolverInput`
- `engine_time_minutes`
- `day_type`
- `area_tier`
- `npc_profile_ref`
- `base_record_ref`
- `active_override_count`
- `active_override_0 .. active_override_n`
- `last_materialized_state` (optional)

---

## 3.8 Resolver result

`DL_ResolverResult`
- `directive`
- `directive_source`
- `target_anchor_group`
- `secondary_anchor_group`
- `selected_activity_kind`
- `dialogue_mode`
- `service_mode`
- `should_materialize`
- `should_hide`
- `should_disable_service`
- `resolver_flags`

Назначение: главный результат логики Daily Life на текущем шаге.

---

## 3.9 Materialization plan

`DL_MaterializationPlan`
- `directive`
- `anchor_group`
- `point_tag`
- `activity_kind`
- `dialogue_mode`
- `service_mode`
- `selection_result`
- `requires_local_walk`
- `allow_instant_place`

Правило:
- если игрока в area нет, допустима мгновенная постановка;
- если area только стала `HOT`, допустима быстрая materialization до устойчивого визуального контакта;
- заметные телепорты перед глазами игрока запрещены.

---

## 3.10 Runtime state

`DL_RuntimeState`
- `current_directive`
- `current_anchor_group`
- `current_point_tag`
- `current_activity_kind`
- `current_dialogue_mode`
- `current_service_mode`
- `current_area_tier`
- `last_resync_time`
- `runtime_flags`

Это runtime-проекция, а не источник истины мира.

---

## 3.11 Resync request

`DL_ResyncRequest`
- `reason`
- `priority`
- `npc_id`
- `requested_time`
- `budget_class`

### `DL_RESYNC_REASON`
- `DL_RESYNC_AREA_ENTER`
- `DL_RESYNC_TIER_UP`
- `DL_RESYNC_SAVE_LOAD`
- `DL_RESYNC_TIME_JUMP`
- `DL_RESYNC_OVERRIDE_END`

### `DL_RESYNC_PRIORITY`
- `DL_RESYNC_LOW`
- `DL_RESYNC_NORMAL`
- `DL_RESYNC_HIGH`

---

## 4) Нормативные правила вычисления

## 4.1 Порядок вычисления директивы

Resolver обязан идти в таком порядке:
1. проверить критические override;
2. проверить валидность базы;
3. определить текущий `day_type`;
4. определить текущее окно расписания;
5. применить personal time offset;
6. применить family/subtype rule;
7. применить fallback;
8. выдать итоговую директиву.

Запрещено перепрыгивать сразу к activity или waypoint без вычисления директивы.

---

## 4.2 Порядок вычисления якоря

После директивы:
1. выбрать `target_anchor_group`;
2. проверить доступность группы в политике якорей;
3. выбрать конкретную точку по приоритету;
4. если точка не найдена — перейти к fallback;
5. если fallback исчерпан — вывести `UNASSIGNED` или `ABSENT`.

---

## 4.3 Порядок вычисления диалога и сервиса

После выбора директивы и anchor group:
1. определить `dialogue_mode`;
2. определить `service_mode`;
3. если сервис запрещён override-ом — принудительно `DL_SERVICE_DISABLED`;
4. если NPC отсутствует — `DL_DLG_UNAVAILABLE`.

---

## 5) Таблицы соответствий

## 5.1 Family -> типичные schedule templates

- `LAW` -> `DL_SCH_DUTY_ROTATION_DAY`, `DL_SCH_DUTY_ROTATION_NIGHT`
- `CRAFT` -> `DL_SCH_EARLY_WORKER`
- `TRADE_SERVICE` -> `DL_SCH_SHOP_DAY`, `DL_SCH_TAVERN_LATE`, `DL_SCH_WANDERING_VENDOR_WINDOW`
- `CIVILIAN` -> `DL_SCH_STREET_IRREGULAR`, `DL_SCH_SHOP_DAY` (для части слуг/домовых рутин не как сервиса, а как городского ритма)
- `ELITE_ADMIN` -> `DL_SCH_LATE_ELITE`, `DL_SCH_OFFICE_DAY`
- `CLERGY` -> `DL_SCH_CLERGY_DAY`

---

## 5.2 Directive -> типичная anchor group

- `DL_DIR_SLEEP` -> `DL_AG_SLEEP`
- `DL_DIR_WORK` -> `DL_AG_WORK`
- `DL_DIR_SERVICE` -> `DL_AG_SERVICE`
- `DL_DIR_EAT` -> `DL_AG_EAT`
- `DL_DIR_SOCIAL` -> `DL_AG_SOCIAL`
- `DL_DIR_WORSHIP` -> `DL_AG_WORSHIP`
- `DL_DIR_DUTY` -> `DL_AG_DUTY` / `DL_AG_PATROL_POINT` / `DL_AG_GATE`
- `DL_DIR_RETURN_BASE` -> `DL_AG_ENTRY`
- `DL_DIR_IDLE_BASE` -> `DL_AG_IDLE_BASE`
- `DL_DIR_PUBLIC_PRESENCE` -> `DL_AG_STREET_NEAR_BASE` / `DL_AG_WAIT`
- `DL_DIR_HIDE_SAFE` -> `DL_AG_SAFE`
- `DL_DIR_HOLD_POST` -> `DL_AG_GATE` / `DL_AG_DUTY`

---

## 5.3 Directive -> dialogue / service

- `DL_DIR_WORK` -> `DL_DLG_WORK`, `DL_SERVICE_AVAILABLE` или `DL_SERVICE_LIMITED`
- `DL_DIR_SERVICE` -> `DL_DLG_WORK`, `DL_SERVICE_AVAILABLE`
- `DL_DIR_SOCIAL` -> `DL_DLG_OFF_DUTY`, `DL_SERVICE_DISABLED`
- `DL_DIR_DUTY` + inspection subtype -> `DL_DLG_INSPECTION`
- `DL_DIR_LOCKDOWN_BASE` -> `DL_DLG_LOCKDOWN`, `DL_SERVICE_DISABLED`
- `DL_DIR_HIDE_SAFE` -> `DL_DLG_HIDE`, `DL_SERVICE_DISABLED`
- `DL_DIR_ABSENT` -> `DL_DLG_UNAVAILABLE`, `DL_SERVICE_NONE`

---

## 6) Anti-patterns для реализации

Запрещено:
- делать одну гигантскую структуру “NPC super state”, которая смешивает профиль, расписание, директиву и runtime;
- привязывать поведение сразу к waypoint без явного `anchor_group`;
- кодировать диалог напрямую из профессии, игнорируя текущую директиву;
- респаунить named NPC как продолжение той же личности;
- строить wandering vendor как настоящую travel-симуляцию;
- рассчитывать политику, закон и клановые санкции внутри Daily Life runtime;
- использовать строковые магические значения вместо enum-контрактов.

---

## 7) Минимальный объём для первой кодовой реализации

Для старта кода достаточно реализовать:
- enum-ы из раздела 2;
- `DL_NpcProfile`;
- `DL_ScheduleTemplate` + `DL_ScheduleWindow`;
- `DL_BaseRecord`;
- `DL_AnchorPolicy` + `DL_AnchorPointRecord`;
- `DL_ResolverInput`;
- `DL_ResolverResult`;
- `DL_MaterializationPlan`;
- `DL_RuntimeState`;
- `DL_ResyncRequest`.

Не требуется на первом шаге:
- полная схема всех city override-таблиц;
- богатая клановая/расовая логика;
- сложные cross-module migration rules;
- численный баланс population pressure.

---

## 8) Нормативное резюме

Daily Life v1 должен реализовываться как компактный набор rule-driven контрактов.

В коде должны быть жёстко разведены:
- личность NPC;
- функция города;
- профиль NPC;
- шаблон расписания;
- текущая директива;
- группа якорей;
- активность/анимация;
- режим диалога;
- доступность сервиса;
- внешний override.

Если реализация снова начинает смешивать эти слои в одну неявную runtime-кашу, значит Daily Life v1 уходит от канона и создаёт риск архитектурного дрейфа.
