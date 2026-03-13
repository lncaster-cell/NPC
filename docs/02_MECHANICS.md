# Ambient Life v2 — Mechanics

## 1. Рутины и расписание NPC
**Цель:** воспроизводимый суточный цикл без тяжёлых глобальных сканов.

Канон:
- слот времени выбирает маршрут;
- прогресс по route-step bounded;
- fallback-поведение не ломает общий tick budget.

## 2. Маршруты и переходы между area
**Цель:** безопасные переходы через linked graph.

Канон:
- `al_link_count` соответствует количеству `al_link_*`;
- `al_link_i` указывает на существующие area tags;
- исключаются дубликаты и битые связи;
- приветствуется симметрия links (`A->B` и `B->A`).

## 3. Sleep lifecycle
**Цель:** ночной цикл сна на контентной разметке.

Канон:
- sleep-step определяется по `al_bed_id` на route-step;
- в area существует корректная bed-пара waypoint’ов;
- wake-up возвращает NPC в нормальный routine pipeline.

## 4. Реакции blocked/disturbed
**Цель:** локально обрабатывать помехи и инциденты без unbounded fan-out.

Канон:
- recovery локальный и ограниченный;
- theft/disturbed не должен напрямую ломать route/schedule инварианты;
- диагностика причин обязательна (счётчики/статусы).

## 5. Респаун населения
**Цель:** контролируемое восстановление population и ролей после выбытия.

Канон:
- policy респауна отделена от active routine loop;
- ограничения по плотности и месту появления обязательны;
- исключаются «взрывные» массовые спавны.

## 6. City crime/alarm слой
**Цель:** городская реакция на преступления через state-machine, а не хаотичный global aggro.

Канон:
- producer-события обновляют city runtime (theft/assault/murder/spell);
- alarm имеет desired/live state и bounded materialization ролей;
- есть обязательная деэскалация обратно в норму.

## 7. Registry/dispatch производительность
**Цель:** bounded latency под нагрузкой.

Канон:
- area-scoped registry с капами;
- события идут через queue + batched dispatch;
- overflow/miss-rate диагностируются и контролируются.

## 8. Границы между механиками
- Городской alarm FSM не смешивается с персональной routine-машиной NPC.
- Sleep/transition/react остаются отдельными контурами, связанными только через явные события и bounded handoff.
