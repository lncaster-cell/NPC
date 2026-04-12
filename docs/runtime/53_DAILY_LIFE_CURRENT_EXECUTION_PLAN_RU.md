# 53 — Daily Life Current Execution Plan (RU)

> Статус: **ACTIVE**  
> Дата: **2026-04-12**  
> Назначение: короткий рабочий план дальнейшей разработки Daily Life **от текущего фактического состояния**, без смешения с legacy-планами и без двусмысленности вокруг owner-run.

---

## 1. Зафиксированная текущая точка

Подтверждено фактом:
- clean-room runtime slice Steps 01–05 реализован;
- owner-run текущего clean-room lifecycle/registry slice уже выполнен владельцем;
- подтверждены `AREA_ENTER`, `HB`, death lifecycle и cleanup регистрации в isolated area (`reg: 1 -> 0`);
- временное debug/logging остаётся в игровом чате;
- active runtime workspace: `daily_life/`.

Подтверждено как acceptance:
- Scenario F = PASS (bounded area-enter resync закрыт);
- Scenario G = PASS (`HOT/WARM` tier-переходы подтверждены на `Gotha Kuznica`/`Gotha`).

Не подтверждено как acceptance целиком:
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

## 3. Текущая рабочая итерация

### 3.1 Acceptance gate F/G закрыт
Зафиксировано:
- Scenario F = PASS;
- Scenario G = PASS;
- по F подтверждены bounded enter-resync и отсутствие hidden full simulation/визуальной дёрготни;
- по G подтверждён lifecycle `HOT=2 -> WARM=1 -> HOT=2` для `Gotha Kuznica`/`Gotha`.

Результат:
- обязательный acceptance gate по F/G закрыт; возврат к этим шагам нужен только при регрессии.

### 3.2 Активный первый vertical slice: BLACKSMITH A/B
Текущий vertical slice:
- `BLACKSMITH`
- два состояния:
  - `WORK`
  - `SLEEP`

Зафиксировано в коде:
- у `blacksmith` есть split `WORK/SLEEP`;
- добавлены минимальные presentation/activity markers;
- sleep execution/waypoint path уже существует в `daily_life/`;
- sleep animation refs уже добавлены в текущий runtime slice.

Практический смысл:
- текущая итерация — не запуск нового broad step, а доведение первого end-to-end сценария `directive -> dialogue/service -> point/materialization` на одном NPC.

### 3.3 Текущий стоп-поинт внутри BLACKSMITH A/B
Текущий зафиксированный фокус:
- не расширять slice дальше в новые vertical scenarios;
- **закрыть именно `SLEEP` directive scenario**;
- довести sleep execution / sleep presentation / sleep animations до устойчивого поведения в живой сцене;
- убрать ситуацию, когда локалы показывают sleep-state раньше фактического достижения bed/target поведения;
- подтвердить owner-run’ом, что sleep path не даёт визуальной дёрготни и не разваливается на heartbeat/reissue path.

Иными словами:
- sleep animations уже добавлены;
- текущая незавершённая часть — сделать sleep scenario надёжным, а не просто «размеченным локалами».

### 3.4 Что идёт после BLACKSMITH A/B
Следующие кандидаты после завершения BLACKSMITH A/B:
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

`закрыть sleep scenario внутри BLACKSMITH A/B -> затем доделать slice -> потом C/D/E по согласованному порядку`

Всё остальное считается преждевременным расширением.
