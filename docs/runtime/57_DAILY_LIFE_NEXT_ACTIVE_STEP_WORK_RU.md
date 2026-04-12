# 57 — Daily Life Next Active Step: BLACKSMITH WORK (RU)

> Дата: 2026-04-12  
> Статус: **active next-step note**

## 1. Что зафиксировано

После временной фиксации готовности sleep-сценария текущим следующим активным шагом считается:

- `BLACKSMITH WORK`

## 2. Что это означает practically

На текущей итерации не открываются новые vertical scenarios и не запускается broad expansion.

Следующий фокус ограничен первым vertical slice:
- проверить и довести `WORK`-поведение у `blacksmith`;
- подтвердить, что в рабочее окно применяется `WORK` directive;
- подтвердить, что ставятся ожидаемые work-state / dialogue / service / activity / animation markers;
- при необходимости зафиксировать статус `WORK` как текущий owner-confirmed результат.

## 3. Что не входит в этот шаг

Пока не считается обязательным для закрытия текущего micro-step:
- отдельный полноценный path к рабочей точке уровня sleep execution;
- новые NPC-сценарии (`GATE_POST`, `INNKEEPER`, `QUARANTINE`);
- broad `Step 07+` expansion;
- массовый refactor foundation/runtime.

## 4. Рабочая формула

Текущий порядок:
- `SLEEP = temporarily ready`
- `следующий активный шаг = WORK`
- после фиксации результата по `WORK` можно считать вопрос о закрытии первого `BLACKSMITH` slice
