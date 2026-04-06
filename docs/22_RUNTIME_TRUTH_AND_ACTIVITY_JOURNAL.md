# Daily Life v1 — Runtime Truth & Activity Journal

Дата старта: 2026-03-30  
Статус: active  
Назначение: единая рабочая точка, где в одном месте фиксируется:
1) **что реально делает код сейчас** (Runtime Truth),
2) **что планировалось и что сделано** по шагам (Activity Journal).

> Этот файл не заменяет SoT-канон. Канон правил — в профильных документах. Этот файл отражает фактическую реализацию в `scripts/daily_life/` на текущий день.

---

## 1) Runtime Truth (факт по коду)

### 1.1 Контур исполнения
- NPC `OnSpawn` может завести NPC в bounded runtime-контур через `dl_npc_onspawn`.
- NPC `OnUserDefined` является центральным thin dispatcher для внутренних Daily Life hook-events (`dl_npc_onud`).
- NPC `OnDeath` выполняет cleanup/deregister path через `dl_npc_ondeath`.
- Area `OnHeartbeat` вызывает `dl_area_tick` -> `DL_AreaWorkerTick`.
- Worker обрабатывает NPC только если зона проходит `DL_ShouldRunDailyLife`.
- В текущем коде `DL_ShouldRunDailyLife` возвращает `TRUE` для `HOT` и `WARM`, `FALSE` для `FROZEN` (через `DL_ShouldRunDailyLifeTier`).
- Основной runtime entry path собран через `dl_all_inc`, чтобы ключевые hooks и smoke scripts были compile-safe внутри самого `NPC`.

### 1.2 Tier lifecycle
- `OnEnter` игрока: зона переводится в `HOT`, запускается area resync.
- `OnExit` игрока:
  - если после исключения выходящего игрока в зоне ещё есть игроки -> зона переводится в `WARM`;
  - если игроков нет -> зона переводится в `FROZEN`.
- Практический эффект в текущей реализации: `WARM` даёт ограниченный рабочий цикл, `FROZEN` отключает dispatch.

### 1.3 Какие NPC реально попадают в обработку
- NPC должен быть Daily Life NPC (`dl_npc_family` из first playable slice) **или** пройти bootstrap через NPC hook layer (например, через staged slot profile / `dl_function_slot_id`).
- Для гарантированной обработки в worker: `dl_named=TRUE` или `dl_persistent=TRUE` (либо pending-resync флаг).
- Noisy producer hooks (`OnPerception`, `OnPhysicalAttacked`, `OnDamaged`, `OnSpellCastAt`, `OnDisturbed`) не должны выполнять тяжёлую логику напрямую: их текущая роль — поставить lightweight event/dirty signal в `OnUserDefined` path.

### 1.4 Что считается «мозгами» в v1
- Rule-driven resolver: `schedule/day/override` -> `directive`.
- Затем вычисляются `anchor_group`, `dialogue_mode`, `service_mode`.
- Materialization применяет это состояние (перемещение/скрытие/absent + interaction state).
- Внутренняя санитарная чистка идёт по runtime-first принципу: сначала оптимизируются hot-path schedule/resolver/worker/resync helper-функции, потом менее частый legacy include-layer.

### 1.5 Граница текущей реализации
- Реализован каркас Milestone A (A–E).
- Не закрыт финальный owner verdict Milestone A (нужны подтверждённые smoke run A–G).
- Post-Milestone A интеграции (полная population/respawn/legal/trade) не заявлены как готовые.
- Полная compile-safe синхронизация исходного дерева `scripts/daily_life/` ещё продолжается, но основной runtime entry path уже вынесен на `dl_all_inc`.

---

## 2) Planned vs Done (операционный трек)

| Дата | Задача | Планировалось | Сделано | Статус |
|---|---|---|---|---|
| 2026-03-30 | Audit текущей реализации Daily Life v1 | Зафиксировать сильные стороны и расхождения docs/runtime | Создан отдельный аудит-отчёт `docs/23_DAILY_LIFE_V1_CODE_AUDIT_2026-03-30.md` | done |
| 2026-03-30 | Проверка README на актуальную инструкцию настройки | Если нет явной runtime-инструкции — добавить минимальный быстрый старт | В README добавлен раздел «Быстрый старт настройки Daily Life v1 (актуально)» | done |
| 2026-03-30 | Централизованный рабочий журнал | Вести единый файл «факт кода + активность» | Создан этот документ | done |
| 2026-03-30 | Audit Phase 2 (edge-cases) | Углубить аудит после первичного отчёта и выделить дополнительные риски | Дополнен `docs/23_DAILY_LIFE_V1_CODE_AUDIT_2026-03-30.md` секциями A-04..A-06 и новым приоритетом | done |
| 2026-03-31 | Синхронизация Runtime Truth с кодом после warm-tier/gate обновлений | Убрать расхождения между журналом и текущим поведением worker gate | Обновлены разделы `1.1` и `1.2`: зафиксировано `HOT/WARM=run`, `FROZEN=stop`; отмечен tier helper `DL_ShouldRunDailyLifeTier` | done |
| 2026-04-02 | Фикс edge-case `OnExit` для последнего игрока | Убрать ложный переход в `WARM`, если в area не остаётся игроков | В `dl_area_exit` проверка заменена на `DL_HasAnyPlayersExcept(oArea, oExiting)`; в `dl_util_inc` добавлен helper `DL_HasAnyPlayersExcept` | done |
| 2026-04-05 | Синхронизация `OnExit` tier-перехода с runtime lifecycle | Убрать рассинхрон: при remaining players зона должна уходить в `WARM`, при пустой зоне — в `FROZEN` | В `dl_area_exit` ветка `DL_HasAnyPlayersExcept(oArea, oExiting)` переводит зону в `DL_OnAreaBecameWarm`; fallback без игроков оставлен на `DL_OnAreaBecameFrozen` | done |
| 2026-04-06 | Восстановление NPC lifecycle/event hook layer | Вернуть явные NPC entrypoints и producer bridges без тяжёлой логики в noisy hooks | Добавлены `dl_npc_onspawn`, `dl_npc_onud`, `dl_npc_ondeath`, producer-bridges (`onperception`, `onphysicalattacked`, `ondamaged`, `onspellcastat`, `ondisturbed`) и bootstrap path через slot handoff | done |
| 2026-04-06 | Compile-safe runtime entry path | Убрать зависимость ключевых hook/smoke scripts от guarded include-графа | Добавлен `dl_all_inc`; на него переведены area hooks, dialogue/store hooks, NPC lifecycle hooks и smoke scripts | done |
| 2026-04-06 | Внутренняя санитарная чистка include-layer | Начать поэтапную оптимизацию legacy guarded includes без смены runtime-контракта | Оптимизированы hot-path schedule helpers до constant-time math; упрощён `dl_resolver_inc` (меньше повторных family/subtype lookups и мёртвых веток) | done |
| 2026-04-06 | Worker/resync perf cleanup | Снять лишние full-pass/duplicate gate затраты в area worker и resync dispatch | В `dl_worker_inc` убран лишний cleanup-pass для `candidateCount=0`, budget-zero path вынесен в ранний cleanup; в `dl_resync_inc` добавлен `DL_RequestResyncKnownNpc` для area/module dispatch без двойного daily-life gate | done |

---

## 3) Правила ведения этого журнала

1. Любая заметная правка `scripts/daily_life/` должна сопровождаться обновлением раздела **Runtime Truth** (если меняется фактическое поведение).
2. Любая завершённая задача спринта должна появиться в таблице **Planned vs Done** в тот же день.
3. Для проверок smoke/acceptance использовать связку:
   - `docs/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md`,
   - `docs/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`,
   - и краткую сводку в этом файле (без дублирования всего журнала).
4. Если найдено расхождение «документ говорит X, код делает Y» — сначала фиксировать в аудите/журнале, потом вносить правку в код или документ с явной пометкой даты.

---

## 4) Быстрый weekly snapshot (шаблон)

- Период: `YYYY-MM-DD .. YYYY-MM-DD`
- Что изменилось в коде:
- Что подтверждено smoke/acceptance:
- Что остаётся риском:
- Следующий приоритетный шаг:
