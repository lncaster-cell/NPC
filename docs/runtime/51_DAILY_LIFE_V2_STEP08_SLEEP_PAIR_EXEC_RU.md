# 51 — Daily Life v2 Step 08: Sleep Pair Execution (RU)

> Дата: 2026-04-09  
> Статус: implementation slice in progress

## 1) Цель шага

Ввести первую практическую sleep execution механику для тестового стенда NWN2.

## 2) Owner constraints, зафиксированные для этого шага

1. Механика должна быть максимально быстрой и чистой.
2. Используются ровно два waypoint:
   - `approach` — у кровати, walkmesh-safe
   - `bed` — на самой кровати
3. Допустим snap/teleport с `approach` на `bed`.
4. Sleep execution сначала отрабатывается на одной interior area с одной кроватью.

## 3) Что добавлено

### 3.1 Sleep pair contract
Добавлен `scripts/daily_life/dl_v2_sleep_anchor_inc.nss`.

Назначение:
- закрепить двухточечный sleep pair contract;
- хранить tags для `approach` и `bed` waypoint;
- валидировать пару waypoint в одной area.

### 3.2 Sleep execution helper
Добавлен `scripts/daily_life/dl_v2_sleep_exec_inc.nss`.

Назначение:
- вести NPC к `approach` waypoint;
- при достаточной близости делать snap на `bed` waypoint;
- фиксировать sleep mode и sleep activity id.

## 4) Текущая execution логика

Fast path:
1. resolver даёт `SLEEP`;
2. execution path вызывает move к `approach`;
3. когда NPC возле `approach`, выполняется snap на `bed`;
4. activity/presentation hook вынесен в следующий слой интеграции.

## 5) Почему animation hook вынесен отдельно

На этом шаге цель — доказать стабильный move->snap path на тестовом стенде,
не смешивая его с возможными проблемами animation API / custom animation binding.

Такой разрез даёт:
- быструю отладку пути;
- чистую локализацию ошибок;
- возможность отдельно доработать sleep presentation после проверки snap-механики.

## 6) Smoke

Добавлен `scripts/daily_life/dl2_smoke_step_08_sleep_pair_exec.nss`.

Он проверяет:
- найден ли runtime NPC на стенде;
- валидна ли sleep pair разметка;
- запускается ли execution path.

## 7) Что дальше

Следующий шаг после проверки на стенде:
1. либо подтвердить, что move->snap работает стабильно;
2. либо скорректировать snap distance / pair placement;
3. затем отдельно подключить sleep presentation/animation hook.
