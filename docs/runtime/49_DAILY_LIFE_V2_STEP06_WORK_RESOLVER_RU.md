# 49 — Daily Life v2 Step 06: Work Resolver for EARLY_WORKER (RU)

> Дата: 2026-04-09  
> Статус: implemented (clean-room runtime)

## 1) Цель шага

Добавить следующую owner-approved директиву после sleep-only slice:
- `WORK`
- только для `EARLY_WORKER`
- без materialization
- без anchor policy
- без full schedule matrix

## 2) Owner decision, зафиксированный для v2

Для `EARLY_WORKER` рабочее окно в v2 фиксируется как:
- начало работы: `08:00`
- окончание работы: `18:00`

## 3) Что добавлено

### 3.1 Work resolver update
Обновлён `daily_life/dl_res_inc.nss`.

Назначение:
- ввести минимальный `WORK` directive slice;
- ввести helper `WORK`-окна;
- ввести basic composition helper для `EARLY_WORKER`:
  - сначала `SLEEP`
  - потом `WORK`
  - иначе `UNASSIGNED`

### 3.2 Smoke check
Обновлён `daily_life/dl_smk_res.nss`.

Проверяет кейсы:
- `07:00` -> `UNASSIGNED`
- `08:00` -> `WORK`
- `12:00` -> `WORK`
- `17:00` -> `WORK`
- `18:00` -> `UNASSIGNED`
- basic path `05:00` -> `SLEEP`
- basic path `09:00` -> `WORK`
- basic path `19:00` -> `UNASSIGNED`

## 4) Почему шаг сделан отдельно

Полный unified resolver пока не собирается намеренно.

Причина:
- owner-решения по другим директивам ещё не зафиксированы;
- отдельный шаг позволяет проверить `WORK` без скрытых побочных зависимостей;
- layered growth остаётся управляемым.

## 5) Что дальше

Следующие варианты:
1. добавить `IDLE_BASE` как следующую owner-approved директиву;
2. добавить template-aware resolver shell;
3. перейти к anchor policy только после минимального набора директив.
