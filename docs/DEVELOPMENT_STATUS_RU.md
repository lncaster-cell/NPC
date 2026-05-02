# Development Status (RU)

> Обновлено: **2026-05-02**

## 1) Runtime-срез проекта (полный инвентарь реализованного)

### 1.1 Daily Life Core (в production-контуре)

- Event-first ingress подключён через module/area/NPC entrypoints:
  - module: `dl_load`;
  - area: `dl_a_enter`, `dl_a_exit`, `dl_a_hb`;
  - NPC: `dl_spawn`, `dl_death`, `dl_blocked`, `dl_userdef`.
- Runtime-contract и lifecycle-контур активны:
  - контракт включения `dl_enabled` + `dl_contract_version`;
  - событийный пайплайн user-defined через `3001` (`EventUserDefined`) для lifecycle/blocked;
  - инвариантный death-cleanup сохранён.
- Include-decomposition завершён и используется как каноническая структура:
  - `dl_runtime_contract_inc`, `dl_registry_inc`, `dl_resync_inc`,
  - `dl_worker_inc`, `dl_lifecycle_inc`, `dl_diag_inc`,
  - domain-слой резолвера/materialization через `dl_res_inc` + тематические include.

### 1.2 Directive/Resolver/Materialization (реализовано)

- Рабочая директивная модель:
  - `SLEEP`, `WORK`, `MEAL`, `SOCIAL`, `PUBLIC`;
  - minute-based резолвер расписания с weekend-ветвлением;
  - skeleton materialization и transition driver.
- Поддерживаемые профили NPC:
  - `blacksmith`, `gate_post`, `trader`, `domestic_worker`.
- Area-based модель локаций и anchor-контракт:
  - home/work/meal/social/public area tags на NPC;
  - `dl_anchor_*` локалки на area;
  - cache-слой anchor/object ссылок для снижения lookup churn.
- Transition driver lookup hardening:
  - резолвер драйвера перехода использует bounded `GetNearestObjectByTag(..., nNth)` по waypoint-контексту вместо глобального `GetObjectByTag`;
  - добавлена единая проверка типа драйвера (`door`/`trigger`) + same-area как для cache-hit, так и для lookup-кандидатов; `driver=none` теперь явно short-circuit в `OBJECT_INVALID`;
  - cap lookup-попыток параметризован module-local ключом `dl_transition_driver_lookup_cap` (bounded clamp), чтобы owner мог калибровать поведение без правки кода;
  - module-local symbol централизован в `dl_runtime_contract_inc` как канонический runtime-контракт (без дублирования объявления в transition include);
  - miss-cache на tick-уровне (`dl_transition_driver_miss_tick`) снижает повторные lookup-miss в одном area-tick при отсутствующем/битом driver tag, включая ранний `GetNearestObjectByTag` miss-path.

### 1.3 Worker/Resync/Budget control (реализовано)

- Area worker работает в bounded budget режиме:
  - round-robin cursor;
  - budget consumption через module minute-budget;
  - last_processed метрики на area/module.
- Area-enter resync выделен в отдельную фазу и бюджет.
- Warm-tier maintenance работает отдельным минимальным проходом.
- Внедрён anti-degradation контур:
  - budget pressure detector;
  - adaptive cap для worker/resync при хроническом дефиците бюджета.
- Area worker hot-path переведён на per-area slot registry с bounded fallback recovery.
- Registry учитывает активных NPC через slot-based структуру и не полагается на полный area scan в обычном worker-проходе.
- Tick-source consistency hardening: `area-enter resync` теперь берёт tick stamp через `DL_GetAreaTick` (с каноническим guard от отрицательных значений), а не прямым `GetLocalInt`.

### 1.4 Diagnostics/Ops (реализовано)

- Runtime/log/diag контур:
  - сигнатурный дедуп диагностик;
  - чат-debug фильтрация (`dl_chat_debug`, `dl_chat_debug_npc_tag`);
  - problem summary и markup/stuck сигнализация без log spam.
- Smoke-скрипты и вспомогательные проверки присутствуют (`dl_smk_tier`, `dl_smk_sync`, `dl_smk_work`, `dl_smoke_ev`).

### 1.5 City Response + Legal v1 (текущий реализованный объём)

- Реализован **базовый ingress атака/убийство** как продолжение Daily Life:
  - `dl_city_response_inc` (heat/level, lazy decay, offender TTL);
  - `dl_damaged` (OnDamaged ingress);
  - `dl_perception` (guard reaction ingress);
  - интеграция kill-эскалации в `dl_death`.
- Реализованы theft/burglary/restricted ingress:
  - `dl_disturbed` (`OnDisturbed`);
  - `dl_open` (`OnOpen`);
  - `dl_cr_restricted_trg` (`Trigger OnEnter`).
- Производительный профиль:
  - без тяжёлых heartbeat-проходов;
  - антиспам через attacker/offender cooldown;
  - witness/guard поиск через bounded shape-итераторы с cap-ограничениями;
  - guard reaction по perception + throttling;
  - cooldown-ключи runtime players нормализуются через `GetPCPublicCDKey` с fallback на tag.
- Текущая стадия City Response:
  - ✅ attack/kill ingress готов;
  - ✅ theft/burglary ingress v1 добавлен с witness-gated реакцией;
  - ✅ detain flow v1 добавлен: witness shout, ограниченный отклик ближайших guard-постов, диалог сдачи и телепорт в jail waypoint при согласии;
  - ✅ perf-tuning v1: witness/guard поиск переведён на bounded shape-итераторы с cap-ограничениями и perception seen/heard фильтрацией;
  - ✅ legal witness lifecycle v1 scaffold добавлен: witnessed handoff в legal-case state, переходы `active -> detained/resolved`.
  - ✅ legal v1.1 simple finalizer добавлен: `fine`/`detain_complete` резолв кейса без ввода полного суда.
  - ✅ cooldown key normalization v1: anti-spam ключи инцидентов/реакции guard переведены на `GetPCPublicCDKey` (с fallback на tag), устранены multiplayer-коллизии при одинаковом PC tag.
  - ✅ cooldown key contract hardening: введены единые prefix-константы и специализированные helper-функции для incident/guard reaction ключей, чтобы исключить дрейф форматов.
  - ✅ identity normalization hardening: fallback-chain уточнён (`GetPCPublicCDKey(..., TRUE)` -> `ObjectToString` -> tag/unknown), при этом built-in public key остаётся каноническим без модификации.
  - ✅ audit pass12 alignment: runtime-вызов `GetPCPublicCDKey` синхронизирован с документированным контрактом через явный параметр `TRUE`, устранён drift между статус-документацией и кодом.
  - ✅ city-response constants cleanup: магические строки legal/detain local keys вынесены в именованные константы для безопасного сопровождения без изменения runtime-поведения.
  - ✅ witness shout anti-spam hardening: cooldown ключ witness-shout переведён с `GetTag` на нормализованный offender identity chain (public cd key/object id/tag fallback), устранён риск коллизий в multiplayer.
  - ✅ include-scope dedupe cleanup: `dl_cr_crime_inc` переиспользует `DL_CR_GetOffenderIdentityKey` из `dl_city_response_inc`, устранено дублирование identity-helper/констант в общем include-графе `dl_core_inc`.
  - ✅ detain default dedupe: `DL_CR_DETAIN_DIALOG_DEFAULT` централизован в city-response include и переиспользуется crime-flow, убран риск дрейфа fallback dialog resref.
  - ✅ pending-key contract unification: `dl_cr_detain_pending` закреплён за единым символом `DL_L_PC_CR_DETAIN_PENDING` в city-response слое, crime-flow переиспользует этот контракт без дублирования объявления.
  - ✅ stale contract symbol cleanup: удалены неиспользуемые legacy-константы `dl_cr_case_state`/`DL_CR_CASE_STATE_*` из `dl_cr_crime_inc`, чтобы исключить возврат неактуального legal state-контракта в сопровождении.
  - ✅ shared-local contract dedupe: `dl_cr_last_guard`, `dl_cr_detain_dialog`, `dl_cr_offender_until` и `dl_cr_investigate_*` централизованы в `dl_runtime_contract_inc` как cross-include канон (без дублирования в city-response/legal/crime include), что снижает риск дрейфа ключей между слоями.
  - ✅ detain-resolver dedupe: helper `DL_CR_GetDetainDialogResRef` централизован в `dl_city_response_inc` и переиспользуется crime/guard flow, чтобы убрать дубли fallback-логики и сохранить единый источник чтения module-local `dl_cr_detain_dialog`.
  - ✅ witness-candidate hardening: `DL_CR_IsWitnessCandidate` ограничен `DL_IsActivePipelineNpc`, чтобы witness-gated crime ingress не использовал runtime-players/DM/невалидные сущности как «свидетелей» и оставался в каноническом NPC-пайплайне.
  - ✅ hot-path micro-opt: в witness scan центр shape-итерации кэшируется (`location lCenter`) вместо повторных `GetLocation(oOffender)` вызовов внутри bounded-loop.
  - ✅ witness scan micro-opt v2: perception-gate (`seen/heard`) вынесен перед `GetDistanceBetween`, что снижает число distance-вычислений для нерелевантных кандидатов.
  - ✅ guard alert consistency fix: в `DL_CR_AlertNearbyGuards` добавлен perception-gate (`seen/heard`) перед distance ranking, что синхронизирует поведение с declared perf-policy и отсекает «слепые» guard-кандидаты.
  - ✅ distance-ranking cleanup: магическое `1000000.0` в witness/guard ranking заменено на именованную константу `DL_CR_DISTANCE_INF` для единообразия и безопасного сопровождения.
  - ✅ radius/responders contract hardening: `dl_cr_witness_radius` и `dl_cr_guard_alert_radius` теперь читаются через `GetLocalFloat` (с legacy-fallback на int), а `dl_cr_guard_responders_max` ограничен capability-лимитом алгоритма (до 2), чтобы runtime-конфиг отражал реальное поведение без скрытого дрейфа.
  - ✅ cursor advancement hardening v3: `DL_GetCursorAdvance` оставляет схему `processed -> candidates -> safety floor`, а границы шага теперь фиксируются через `DL_ClampInt(1..nNpcSeen)` (вместо modulo-ветки), что делает контракт проще, дешевле и полностью согласованным с bounded round-robin проходом.
  - ⏳ legal процессуальные расширения (полный суд/расследование post-factum) остаются следующими этапами.

## 2) Что подтверждено ревизией кода

- Runtime-контур Daily Life активен и согласован с unified-дизайном (event-first, bounded execution).
- Lifecycle ingress (spawn/death/blocked/userdef) не потерял базовые инварианты после рефакторинга include-слоя.
- Worker/resync/budget pipeline сохраняет ограниченность обработки и метрики наблюдаемости.
- City Response добавлен без архитектурного разрыва: через существующий Daily Life ingress и object-local/module-local контракты.
- Legal v1 держит единый case-state в `dl_lg_case_state`, без дублирования через `dl_cr_case_state`.

## 3) Что ещё в owner-run validation (не закрыто)

1. Weekend/public поведение на реальном модуле (включая reduced_work/off_public кейсы).
2. Негативные markup-кейсы (missing/broken anchors, частично заполненные area tags).
3. SOCIAL pair сценарии на живой карте (валидный/невалидный partner, fallback в PUBLIC).
4. City Response + Legal v1 smoke:
   - witnessed theft на свежем `dl_cr_level=0`;
   - restricted entry;
   - detain dialog: «Сдаться» / «Отказаться»;
   - jail waypoint teleport;
   - `dl_lg_resolve_fine`;
   - `dl_lg_resolve_detain`;
   - проверка, что после legal resolve guard больше не считает PC active offender.
5. City Response калибровка:
   - heat thresholds;
   - offender TTL;
   - guard reaction stage policy;
   - влияние на gameplay в crowded/hot-area.

## 4) Текущие приоритеты

1. `P1`: owner-run smoke City Response + Legal v1 на живом модуле.
2. `P1`: owner-run валидация Daily Life matrix (weekday/weekend + негативные markup).
3. `P1`: tuning budget pressure trigger/relief порогов по фактическим нагрузкам.
4. `P2`: точечная оптимизация transition/lookup churn в hot-tier area.
5. `P2`: подготовка следующего этапа Legal — только после smoke-подтверждения v1.

## 4.1 Что синхронизировано в документации на 2026-04-24

- README приведён к актуальному City Response + Legal v1.1 контракту:
  - first witnessed crime должен оповещать guard даже при `dl_cr_level=0`;
  - `dl_lg_case_state` — единственный legal case-state;
  - `dl_cr_case_state` удалён из runtime-контракта;
  - legal finalizers очищают pursuit/detain state.
- Статус City Response согласован с фактическим кодом:
  - witness shout;
  - ограниченный отклик ближайших guard-постов;
  - detain dialog handoff и jail teleport;
  - cleanup после legal resolve.

## 5) Ограничения и политика (не менялись)

- Все решения проверять через встроенные механики NWN2/NWScript и NWN Lexicon.
- Не вводить ad-hoc обходы, если есть штатная функция/паттерн.
- Любая правка runtime должна сопровождаться синхронизацией этого файла.
- Не добавлять heartbeat polling и полные area scan в hot path.

## 6) Артефакты аудита

- `docs/audits/post_refactor_audit_pass4.md`
- `docs/audits/post_refactor_audit_pass5.md`
- `docs/audits/post_refactor_audit_pass6_deep.md`
- `docs/audits/post_refactor_audit_pass7.md`
- `docs/audits/post_refactor_audit_pass8.md`
- `docs/audits/post_refactor_audit_pass9.md`
- `docs/audits/post_refactor_audit_pass10.md`
- `docs/audits/post_refactor_audit_pass11.md`
- `docs/audits/post_refactor_audit_pass12.md`
