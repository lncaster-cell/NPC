# 48 — Daily Life v2 Step 05: Sleep-Only Resolver (RU)

> Дата: 2026-04-09  
> Статус: implementation slice in progress

## 1) Цель шага

Ввести первый resolver helper без materialization, без activity layer и без full schedule system.

Текущий scope шага намеренно узкий:
- только directive layer;
- только `SLEEP`;
- только типовой профиль `EARLY_WORKER`;
- без других директив.

## 2) Owner decision, зафиксированный для v2

Для `EARLY_WORKER` окно сна в v2 фиксируется как:
- начало сна: `22:00`
- окончание сна: `06:00`

Это решение принято как owner choice для первого sleep-only resolver slice.

## 3) Что добавлено

### 3.1 Resolver include
Добавлен `daily_life/dl_res_inc.nss`.

Назначение:
- ввести минимальный enum директив для первого шага;
- ввести helper проверки часов и окна времени;
- ввести sleep-only resolver;
- ввести специализированный helper для `EARLY_WORKER`.

### 3.2 Smoke check
Добавлен `daily_life/dl_smk_res.nss`.

Проверяет кейсы:
- `05:00` -> `SLEEP`
- `06:00` -> `UNASSIGNED`
- `21:00` -> `UNASSIGNED`
- `22:00` -> `SLEEP`
- `23:00` -> `SLEEP`

## 4) Почему шаг сделан именно так

Шаг не пытается сразу реализовать полный resolver,
потому что для остальных директив ещё не закрыт owner-level набор точных правил.

Поэтому текущая реализация:
- расширяет контур минимально;
- не навязывает дополнительные продуктовые решения;
- делает owner choice по `EARLY_WORKER` явной и тестируемой.

## 5) Что дальше

Следующие варианты роста после этого шага:
1. добавить вторую типовую sleep-policy для другого schedule template;
2. расширить directive layer следующей директивой;
3. ввести schedule-template id как вход resolver helper;
4. после этого переходить к anchor policy helper.
---

**Текущий canonical runtime path: `daily_life/`.**
