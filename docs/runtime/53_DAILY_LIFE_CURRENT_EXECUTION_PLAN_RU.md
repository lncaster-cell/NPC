# 53 — Daily Life Current Execution Plan (RU)

> Статус: **ACTIVE**  
> Дата: **2026-04-11**  
> Назначение: короткий рабочий план дальнейшей разработки Daily Life **от текущего фактического состояния**, без смешения с legacy-планами и без двусмысленности вокруг owner-run.

---

## 1. Зафиксированная текущая точка

Подтверждено фактом:
- clean-room runtime slice Steps 01–05 реализован;
- owner-run текущего clean-room lifecycle/registry slice уже выполнен владельцем;
- подтверждены `AREA_ENTER`, `HB`, death lifecycle и cleanup регистрации в isolated area (`reg: 1 -> 0`);
- временное debug/logging остаётся в игровом чате;
- active runtime workspace: `daily_life/`.

Не подтверждено как acceptance целиком:
- Scenario F как полный bounded resync/materialization run;
- Scenario G как отдельный `HOT/WARM/FROZEN` acceptance run;
- вертикальные сценарии A–E (`BLACKSMITH`, `GATE_POST`, `INNKEEPER`, `QUARANTINE`).

---

## 2. Что означает owner-run на текущем этапе

Использовать только две формулировки:

1. `owner-run текущего clean-room slice`
   - уже выполнен;
   - относится к lifecycle/registry/worker smoke.

2. `полный owner-run Milestone A`
   - ещё не выполнен;
   - требует закрытия acceptance-сценариев A–G.

Термин `owner-run` без уточнения не использовать.

---

## 3. Следующий реальный план работ

### Шаг 1 — Закрыть Scenario F
Цель:
- подтвердить bounded resync/materialization на входе игрока в area как целостный сценарий.

Что должно быть подтверждено:
- вход игрока поднимает area в `HOT`;
- выполняется bounded resync;
- NPC materialize-ятся в правдоподобное текущее состояние;
- не проигрывается hidden full simulation;
- нет хаотичного телепорта перед глазами игрока.

Результат:
- отдельная запись PASS/FAIL в acceptance journal.

### Шаг 2 — Закрыть Scenario G
Цель:
- подтвердить, что tier-поведение area соответствует baseline.

Что должно быть подтверждено:
- `HOT` обрабатывается bounded worker;
- `WARM` не живёт как полноценная active-area;
- `FROZEN` молчит;
- нет полного исполнения рутины без игрока.

Результат:
- отдельная запись PASS/FAIL в acceptance journal.

### Шаг 3 — После PASS по F/G выбрать первый vertical slice
Первый vertical slice по умолчанию:
- `BLACKSMITH`
- два состояния:
  - `WORK`
  - non-`WORK` / social-rest window

Почему именно он:
- уже есть базовый resolver/materialization skeleton;
- сценарий хорошо наблюдаем в toolset;
- он даёт проверку `directive -> dialogue/service -> point/materialization` на одном NPC.

Результат:
- первый end-to-end сценарий A/B.

### Шаг 4 — Только после этого расширять дальше
Следующие кандидаты после blacksmith:
1. `LAW / GATE_POST`
2. `TRADE_SERVICE / INNKEEPER`
3. `QUARANTINE` override

---

## 4. Что запрещено до закрытия F/G

- не переходить к Step 07+;
- не расползаться в новые подсистемы;
- не делать массовый foundation-refactor;
- не убирать чат-логирование;
- не смешивать текущий clean-room план с legacy/V1 broad plan.

---

## 5. Рабочее правило на ближайшую итерацию

Формула ближайшей итерации простая:

`F -> G -> BLACKSMITH A/B`

Всё остальное считается преждевременным расширением.
