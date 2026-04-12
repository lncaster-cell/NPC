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
- вертикальные сценарии A–E (`BLACKSMITH`, `GATE_POST`, `INNKEEPER`, `QUARANTINE`).

Подтверждено как acceptance:
- Scenario F = PASS (bounded area-enter resync закрыт);
- Scenario G = PASS (`HOT/WARM` tier-переходы подтверждены на `Gotha Kuznica`/`Gotha`).

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

### Шаг 1 — Acceptance gate F/G закрыт
Зафиксировано:
- Scenario F = PASS;
- Scenario G = PASS;
- по F подтверждены bounded enter-resync и отсутствие hidden full simulation/визуальной дёрготни;
- по G подтверждён lifecycle `HOT=2 -> WARM=1 -> HOT=2` для `Gotha Kuznica`/`Gotha`.

Результат:
- обязательный acceptance gate по F/G закрыт; возврат к этим шагам нужен только при регрессии.

### Шаг 2 — Первый vertical slice: BLACKSMITH A/B (без Step 07+)
Первый vertical slice по умолчанию:
- `BLACKSMITH`
- два состояния:
  - `WORK`
  - `SLEEP`

Почему именно он:
- уже есть базовый resolver/materialization skeleton;
- сценарий хорошо наблюдаем в toolset;
- он даёт проверку `directive -> dialogue/service -> point/materialization` на одном NPC.

Результат:
- первый end-to-end сценарий A/B.

### Шаг 3 — Только после этого расширять дальше
Следующие кандидаты после blacksmith:
1. `LAW / GATE_POST`
2. `TRADE_SERVICE / INNKEEPER`
3. `QUARANTINE` override

---

## 4. Что запрещено на текущей итерации

- не переходить к Step 07+;
- не расползаться в новые подсистемы;
- не делать массовый foundation-refactor;
- не убирать чат-логирование;
- не смешивать текущий clean-room план с legacy/V1 broad plan.

---

## 5. Рабочее правило на ближайшую итерацию

Формула ближайшей итерации простая:

`BLACKSMITH A/B -> затем C/D/E по согласованному порядку`

Всё остальное считается преждевременным расширением.
