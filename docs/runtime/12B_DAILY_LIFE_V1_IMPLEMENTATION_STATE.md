# Ambient Life v2 — Daily Life v1: Implementation State (Snapshot)

Дата: 2026-04-06  
Статус: operational implementation snapshot  
Назначение: единый технический обзор **что уже реализовано в коде**, **что не реализовано**, и **как текущая runtime-система работает** для Milestone A.

---

## 1) Короткий итог (для владельца проекта)

- **Сделано:** каркас Milestone A (Steps A–E) реализован в `scripts/daily_life/`: есть контракты, resolver, materialization, area worker/tier lifecycle, base-lost/slot-handoff stub, NPC lifecycle/event hooks, compile-safe entry layer.
- **Runtime edge-case fixed (2026-04-07):** midnight/`00:00:00` больше не трактуется как «пустое» время в cooldown/slot-review дедупликации; теперь используется явная инициализация состояния.
- **Не сделано:** Milestone A acceptance не закрыт фактами прогонов A–G на owner/toolset среде.
- **Граница текущего состояния:** система уже может вести NPC в `HOT`-зонах по расписанию и override-правилам, но это ещё не финальный production verdict.

---

## 2) Что реализовано в коде (по шагам Milestone A)

## 2.1 Step A — Contracts foundation

Реализовано:
- единый набор locals/enum-like constants;
- helper-access к family/subtype/schedule/base;
- базовые utility и логгер;
- compile-safe aggregation file для entry path.

Ключевые файлы:
- `scripts/daily_life/dl_const_inc.nss`
- `scripts/daily_life/dl_types_inc.nss`
- `scripts/daily_life/dl_util_inc.nss`
- `scripts/daily_life/dl_log_inc.nss`
- `scripts/daily_life/dl_all_inc.nss`

## 2.2 Step B — Pure resolver

Реализовано:
- deterministic resolver `schedule -> directive -> anchor/dialogue/service`;
- применение override (`FIRE`, `QUARANTINE`);
- проверка допустимости directive через mask.

Ключевые файлы:
- `scripts/daily_life/dl_schedule_inc.nss`
- `scripts/daily_life/dl_override_inc.nss`
- `scripts/daily_life/dl_resolver_inc.nss`
- `scripts/daily_life/dl_all_inc.nss`

## 2.3 Step C — Materialization and interaction

Реализовано:
- выбор anchor с fallback цепочкой;
- materialize path (instant placement или local walk);
- activity + interaction state (`dialogue_mode`, `service_mode`);
- base-lost обработка и безопасные ветки fallback.

Ключевые файлы:
- `scripts/daily_life/dl_anchor_inc.nss`
- `scripts/daily_life/dl_activity_inc.nss`
- `scripts/daily_life/dl_materialize_inc.nss`
- `scripts/daily_life/dl_interact_inc.nss`
- `scripts/daily_life/dl_dialogue_bridge_inc.nss`
- `scripts/daily_life/dl_all_inc.nss`

## 2.4 Step D — Area worker and lifecycle

Реализовано:
- area tier (`HOT/WARM/FROZEN`);
- bounded worker budget;
- resync path (`area enter`, `worker`, `override end`, NPC lifecycle/event hooks и др.);
- area tick hook для запуска worker;
- thin NPC lifecycle/event layer (`OnSpawn`, `OnUserDefined`, `OnDeath`) и lightweight producer bridges для noisy hooks;
- compile-safe entry layer для основных runtime hooks.

Ключевые файлы:
- `scripts/daily_life/dl_area_inc.nss`
- `scripts/daily_life/dl_worker_inc.nss`
- `scripts/daily_life/dl_resync_inc.nss`
- `scripts/daily_life/dl_area_tick.nss`
- `scripts/daily_life/dl_area_enter.nss`
- `scripts/daily_life/dl_area_exit.nss`
- `scripts/daily_life/dl_on_load.nss`
- `scripts/daily_life/dl_npc_hooks_inc.nss`
- `scripts/daily_life/dl_npc_onspawn.nss`
- `scripts/daily_life/dl_npc_onud.nss`
- `scripts/daily_life/dl_npc_ondeath.nss`
- `scripts/daily_life/dl_npc_onperception.nss`
- `scripts/daily_life/dl_npc_onphysicalattacked.nss`
- `scripts/daily_life/dl_npc_ondamaged.nss`
- `scripts/daily_life/dl_npc_onspellcastat.nss`
- `scripts/daily_life/dl_npc_ondisturbed.nss`
- `scripts/daily_life/dl_all_inc.nss`

## 2.5 Step E — Stub handoff

Реализовано:
- request-review и slot-assigned API;
- staged slot profile для safe handoff;
- base-lost ветки `ABSENT/UNASSIGNED` без full population-respawn реализации.

Ключевые файлы:
- `scripts/daily_life/dl_slot_handoff_inc.nss`
- `scripts/daily_life/dl_materialize_inc.nss`
- `scripts/daily_life/dl_smoke_step_e.nss`
- `scripts/daily_life/dl_all_inc.nss`

---

## 3) Как текущая система работает (runtime-поток)

0. **NPC lifecycle/event hooks** могут ввести NPC в bounded runtime-контур: `OnSpawn` и `OnUserDefined` подают resync-запрос, `OnDeath` делает cleanup, noisy producer hooks только сигналят в `OnUserDefined`.
1. **Area lifecycle** задаёт tier зоны (`HOT/WARM/FROZEN`).
2. На `OnHeartbeat` area вызывается `dl_area_tick`, который запускает `DL_AreaWorkerTick`.
3. Worker в `HOT`-зоне выбирает ограниченное число NPC по budget.
4. Для каждого NPC вызывается resync/materialization.
5. Resolver вычисляет directive от schedule + override.
6. Выбирается anchor, применяются перемещение/активность.
7. Обновляются interaction-поля (`dialogue_mode`, `service_mode`).
8. Основной entry path для runtime hooks и smoke scripts идёт через `dl_all_inc`, чтобы рабочий путь был compile-safe внутри самого `NPC`.
9. Для smoke-диагностики может писаться `smoke snapshot` (если `dl_smoke_trace=TRUE`).

---

## 4) Что уже можно считать рабочим

- Сквозной путь для first playable slice (`LAW`, `CRAFT`, `TRADE_SERVICE`) в рамках текущего runtime-каркаса.
- Реакция на `QUARANTINE/FIRE` в resolver/materialization слое.
- Базовый контроль area-tier и budget-bound обработки.
- NPC-side lifecycle/event hooks без heavy runtime-логики в noisy producer slots.
- Stub-safe обработка base-lost без автогенерации полноценной population системы.
- Compile-safe entry layer внутри `NPC` для основного runtime-path.

---

## 5) Что ещё не закрыто (обязательно для Milestone A close)

1. **Нет фактически подтверждённого run, где A–G = PASS** в acceptance journal.
2. **Нет финального owner-run** на реальном ПК, который закрывает final gate.
3. Часть зон остаётся специально **stub-level** (handoff/base-lost), и это надо подтверждать фактическими smoke-прогонами, а не только inspection.
4. Compile-safe выравнивание исходного runtime-дерева ещё не завершено полностью: сейчас закрыт основной entry path, но не всё include-дерево переведено в единый bare-safe вид.

---

## 6) Соответствие документации и кода (на текущий момент)

Сильная согласованность:
- структура шагов A–E соответствует implementation checklist;
- operational status и ограничения совпадают с control panel;
- runbook и acceptance journal отражают, что есть инструменты проверки, но нет финального PASS-цикла;
- README/runtime-обзор уже должны прямо фиксировать обязательный NPC hook layer и compile-safe entry path.

Точечные runtime-фиксы (2026-04-07):
- В `DL_HasHookCooldownElapsed` убрана неявная трактовка `0` как «неинициализировано»: теперь используется отдельный флаг `<key>_set`, поэтому `00:00:00` участвует в cooldown как валидный timestamp.
- В `DL_RequestFunctionSlotReview` дедупликация переведена с проверки `nLastTick > 0` на явное состояние `last_tick_set`, поэтому значение `nLastTick == 0` (полночь) корректно учитывается в TTL-окне.
- В cleanup ветках синхронно очищаются и значения времени, и флаги `*_set`, чтобы после смерти NPC/clear-review не оставалось «висячего» состояния.
- `DL_IsDailyLifeNpc` снова принимает все канонические семейства (`LAW..CLERGY`), а не только first playable slice: это устраняет silent-ignore NPC в owner-run, где профили уже используют `CIVILIAN`/`ELITE_ADMIN`/`CLERGY`.
- Начат поэтапный refactor-протокол «по одной функции»: сначала выделен явный gate `DL_IsCanonicalDailyLifeFamily`, а legacy-обёртка `DL_IsFamilyInFirstPlayableSlice` оставлена только для обратной совместимости include-потребителей.

Риски расхождения, которые нужно проверять owner-run’ом:
- фактическая постановка NPC по anchor в реальных toolset area-data;
- ожидаемые различия A/B/D по временным окнам в конкретной тестовой сборке;
- стабильность F/G сценариев при реальных нагрузках и сердцебиениях area;
- полная compile/runtime согласованность исходного дерева после окончательной санации include-слоя.

---

## 7) Практический план до «понятного готово/не готово»

1. Прогнать scripted/manual smoke A–G в toolset по runbook.
2. Заполнить acceptance journal фактическими статусами (`PASS/PARTIAL/FAIL`) и расхождениями.
3. Закрыть найденные точечные расхождения в коде (без расширения scope).
4. Довести include-дерево `scripts/daily_life/` до полного compile-safe состояния.
5. Сделать owner-run и зафиксировать окончательный verdict Milestone A.

---

## 8) Что этот документ НЕ делает

- Не заменяет canonical ruleset/SoT-документы.
- Не объявляет Milestone A закрытым.
- Не расширяет scope в legal/trade/travel/clan.
