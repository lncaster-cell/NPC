# 01_NWN2_ENGINE_CONSTRAINTS

## Цель

Зафиксировать ограничения старого движка NWN2, которые должны влиять на все архитектурные решения.

## Heartbeat

Heartbeat — дорогой и грубый инструмент.

Правила:

- module heartbeat — только тонкий диспетчер;
- area heartbeat — только с ранним выходом;
- creature heartbeat — использовать минимально;
- placeable/door heartbeat не использовать как основу критичной Daily Life логики;
- heartbeat не должен сканировать мир постоянно;
- heartbeat не должен быть “мозгом мира”.

Правильный стиль:

```c
void main()
{
    if (!ShouldRunScheduler()) return;
    if (!HasActiveAreas()) return;

    RunOneSmallBudgetedJob();
}
```

## DelayCommand

`DelayCommand` не задерживает текущий скрипт. Он сохраняет script situation и создаёт отложенную работу.

Ограничения:

- не строить self-loop через `DelayCommand`;
- не создавать тысячи delayed calls;
- не назначать cleanup на NPC, который может умереть/despawn;
- не использовать `DelayCommand(0.0)` вместо нормального `AssignCommand`, если не нужна именно временная семантика;
- delayed cleanup/resync должен жить на area/module/stable controller.

Допустимые случаи:

- короткий timed reset;
- retry/backoff;
- staged VFX;
- ограниченное окно respawn;
- небольшая временная задержка, где реально важно время.

## Action queue

Использовать штатную очередь действий движка, а не самодельный polling достижения каждой точки.

Предпочтительно:

- `AssignCommand`;
- `ActionMoveToObject`;
- `ActionPlayAnimation`;
- `ActionDoCommand`;
- короткие action queue;
- route segment через якоря/двери/переходы.

Опасно:

- постоянный опрос “дошёл ли NPC”;
- длинная очередь из десятков действий без контроля состояния;
- частый `ClearAllActions` из разных подсистем;
- `PlayAnimation` там, где нужна queued animation.

## Движение

Для Daily Life предпочтительно движение к объектам-якорям, а не к “голым” location.

Правило:

```text
Anchor object > door object > transition object > waypoint object > raw location
```

`ActionMoveToLocation` допустим, но не должен быть основой дальних переходов и сложной навигации.

## Area lifecycle

Рекомендуемый жизненный цикл области:

```text
Area On Client Enter
  -> lazy init / resync
  -> build area cache
  -> mark area active
  -> runtime reads only cache/local refs

Area empty
  -> no heavy AI
  -> keep coarse state
  -> optional despawn/LOD
```

## Persistence

Object refs и runtime locations не являются долговременной истиной.

Для persistence хранить:

- `NPC_ID`;
- `AreaTag`;
- `RouteID`;
- `AnchorID`;
- `State`;
- `DueTime`;
- `AreaTag + vector + facing`;
- schema/version.

Не хранить как истину:

- object reference;
- raw campaign location без version/area tag;
- current action queue;
- transient controller object;
- delayed command state.

## Toolset / build pipeline

После изменения include-файлов и архитектурных библиотек надо компилировать весь релевантный набор скриптов.

Правила:

- не полагаться только на “один скрипт скомпилировался”;
- после изменений в include запускать полный compile check;
- фиксировать toolset/compiler build;
- не использовать compiler-specific extensions без отдельного решения;
- не делать большие umbrella include без необходимости.
