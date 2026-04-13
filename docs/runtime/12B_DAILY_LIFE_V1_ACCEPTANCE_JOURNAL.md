# 12B — Daily Life v1 Acceptance Journal

> Last update: 2026-04-13
> Scope: фиксация фактически пройденных owner/toolset acceptance прогонов.

---

## 1) Правила ведения

- Для каждого прогона указывать `run_id`, дату, окружение и итоговый verdict.
- Статусы сценариев: `PASS`, `PARTIAL`, `FAIL`, `NOT_RUN`.
- При `PARTIAL/FAIL` обязательно фиксировать причину и план добивки.

---

## 2) Журнал прогонов

### 2.1 Run summary

| run_id | date | env | owner_note | verdict |
|---|---|---|---|---|
| dlv1-accept-20260413-owner-01 | 2026-04-13 | owner/toolset | Подтвержден успешный прогон Sleep + Work + межзоновых переходов | PASS |

### 2.2 Scenario matrix (latest run)

Текущий run: `dlv1-accept-20260413-owner-01`.

| Scenario | Status | Фактическая фиксация |
|---|---|---|
| SLEEP directive + movement + animation | PASS | NPC получают директиву `SLEEP`, корректно двигаются к месту сна и проигрывают анимацию сна. |
| WORK directive (blacksmith trader) | PASS | Кузнец-трейдер отрабатывает рабочую директиву в ожидаемом рабочем контуре. |
| WORK directive (gate guard / post guard) | PASS | Постовой стражник отрабатывает рабочую/дежурную директиву на посту. |
| Inter-zone transitions | PASS | Межзоновые переходы NPC отрабатываются без расхождений в поведении. |

### 2.3 Open issues

На момент run `dlv1-accept-20260413-owner-01` открытых блокеров не зафиксировано.
