# Development Status (RU)

> Обновлено: **2026-04-24**

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

### 1.4 Diagnostics/Ops (реализовано)

- Runtime/log/diag контур:
  - сигнатурный дедуп диагностик;
  - чат-debug фильтрация (`dl_chat_debug`, `dl_chat_debug_npc_tag`);
  - problem summary и markup/stuck сигнализация без log spam.
- Smoke-скрипты и вспомогательные проверки присутствуют (`dl_smk_*`, `dl_smoke_ev`).

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
  - ✅ first witnessed theft/restricted incidents теперь должны будить guard даже при свежем `dl_cr_level=0`;
  - ✅ legal witness lifecycle v1 scaffold добавлен: witnessed handoff в `dl_lg_case_state`;
  - ✅ `dl_lg_case_state` является единственным runtime case-state legal flow; `dl_cr_case_state` не используется;
  - ✅ legal v1.1 simple finalizer добавлен: `fine`/`detain_complete` закрывают кейс и очищают City Response pursuit/detain state;
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

- `daily_life/post_refactor_audit_pass4.md`
- `daily_life/post_refactor_audit_pass5.md`
- `daily_life/post_refactor_audit_pass6_deep.md`
- `daily_life/post_refactor_audit_pass7.md`
- `daily_life/post_refactor_audit_pass8.md`
- `daily_life/post_refactor_audit_pass9.md`
- `daily_life/post_refactor_audit_pass11.md`
