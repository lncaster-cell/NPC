# 08_CODEX_TASK_RULES

## Обязательные правила для Codex/Agent

Перед любым изменением кода:

1. Проверить актуальное состояние branch/repo/PR.
2. Прочитать релевантные документы из `docs/`.
3. Не делать unrelated refactor.
4. Не переименовывать keys/locals без явного задания.
5. Не менять архитектуру без явного задания.
6. Переиспользовать существующие функции и паттерны.
7. Держать runtime overhead минимальным.
8. Компилировать после правки, если доступен compiler/CI.
9. Вернуть список файлов и результат компиляции.

## Performance constraints

Нельзя добавлять в hot path:

- `GetObjectByTag`;
- `GetWaypointByTag`;
- `GetFirstObjectInArea`;
- `GetNextObjectInArea`;
- частый `GetNearestObject`;
- Campaign DB read/write;
- recursive `DelayCommand`;
- per-NPC heartbeat как основу поведения.

Если cache может быть stale:

```text
mark dirty -> scheduler/controller resync -> continue
```

## Daily Life constraints

Не трогать без задания:

- sleep behavior;
- route transition behavior;
- area transition behavior;
- registry lifecycle;
- existing DB keys;
- existing local key names;
- compile workflow.

## Law system constraints

Если задача касается law/crime:

- использовать event-driven stubs;
- не делать global witness heartbeat;
- OnDisturbed = inventory/theft layer;
- не смешивать theft и noise/social;
- использовать law zones/dispatchers;
- DB write только для значимых событий или batch.

## Compiler constraints

- stock NWN2-compatible NWScript;
- prototypes before use;
- careful include order;
- exact include casing;
- no compiler-specific extensions;
- avoid shadowing parameters;
- no giant umbrella include unless required.

## Формат задачи

Использовать шаблон:

```text
Repository:
Task:
Context:
Expected behavior:
Relevant files:
Constraints:
Definition of done:
Compile command:
```

## Формат отчёта после выполнения

```text
Summary:
Changed files:
Behavior changed:
Compiler result:
Tests/manual checks:
Risks:
Unrelated changes:
```

## Хорошая задача

```text
Fix only NPC animation spam at work waypoint.
Do not refactor Daily Life.
Do not change sleep.
Do not change route selection.
Reuse existing animation locals/helpers.
Add bounded cooldown/state guard only if needed.
Run compile check.
```

## Плохая задача

```text
Improve Daily Life system.
```

Слишком широко. Нужно разбить.

## Audit-only prompt

```text
Task:
Audit Daily Life scripts for hot-path performance violations.

Do not edit code.

Find:
- GetObjectByTag/GetWaypointByTag
- GetFirstObjectInArea/GetNextObjectInArea
- GetNearestObject
- Campaign DB reads/writes
- DelayCommand
- heartbeat logic

Classify:
- hot path
- cold path
- fallback
- admin
- maintenance

Output table:
file / function / operation / path type / risk / recommendation
```
