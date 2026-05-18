# 05_COMPILER_AND_CI_RULES

## Главный принцип

Для NWN2 релизный источник истины — стандартный компилятор NWN2 Toolset.

Внешние компиляторы полезны, но они не должны быть единственным gate.

## Compiler gates

Рекомендуемая матрица:

```text
1. NWN2 Toolset compiler — canonical release gate
2. Skywing / Advanced Script Compiler — NWN2-oriented second gate
3. nwnsc — useful CLI/CI gate, but treat as NWN:EE-oriented unless verified
```

## Safe NWScript subset

Писать в консервативном NWScript.

Правила:

- не использовать `nwnsc`-specific extensions;
- не использовать `#pragma`, если stock compiler это не принимает;
- не полагаться на нестандартное поведение include search;
- не полагаться на новые EE-only language features;
- `const` держать в stock-compatible форме;
- не вводить локальный `const`, если stock compiler ломается;
- избегать shadowing параметров локальными переменными.

## Include rules

- точный регистр `#include`;
- не создавать include-файлы с одинаковым basename в разных местах;
- минимальный include graph;
- однонаправленные зависимости;
- не делать огромный umbrella include без необходимости;
- прототипы для функций, вызываемых ниже по файлу;
- имена параметров в prototype указывать явно;
- взаимную рекурсию избегать или оформлять прототипами;
- после изменения include запускать полный compile check.

## Declaration order

NWScript компилируется сверху вниз.

Правило:

```text
constants/globals
prototypes
small helpers
domain functions
public entry points
main
```

Если функция вызывается до определения — нужен prototype.

## Known risky areas

- include order;
- case-sensitivity на Linux runner;
- stock compiler identifier pressure;
- большие include-библиотеки;
- shadowing parameter names;
- duplicate symbols;
- compiler-specific extensions;
- разница между toolset resource search order и CLI input paths.

## CI rules

CI должен:

- компилировать все затронутые `.nss`;
- по возможности компилировать весь `scripts/` или `src/`;
- сохранять logs/artifacts;
- падать на compile error;
- показывать file/line error;
- не скрывать warnings, если они указывают на compatibility risk.

## Codex rules for compiler compatibility

Codex не должен:

- менять include graph без объяснения;
- добавлять новый include ради одной функции, если можно переиспользовать существующий;
- переименовывать ключи/locals без миграции;
- добавлять новые globals без проверки конфликтов;
- менять const/string declarations массово без compile reason;
- исправлять compile error через архитектурный refactor.

## Минимальный отчёт после правки

После изменения кода агент должен вернуть:

```text
Changed files:
Compile command:
Compile result:
Warnings:
Behavioral impact:
Unrelated changes: none
```

## Если компиляция расходится

Если внешний CLI компилятор проходит, а toolset compiler падает:

```text
toolset wins
```

Если toolset проходит, а внешний compiler падает:

```text
investigate, but do not block release unless CI requires it
```

Если оба падают:

```text
fix syntax/include/order first, no gameplay refactor
```
