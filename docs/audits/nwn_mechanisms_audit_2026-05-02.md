# NWN Lexicon-oriented audit (built-in mechanisms first)

Дата: 2026-05-02  
Scope: `daily_life/*.nss` (routing + transition execution + call-sites)

## Executive summary

Кодовая база в целом следует правильному курсу: навигация и transition уже опираются на штатные NWN механики (`ActionMoveToLocation`, `ActionJumpToLocation`, `DoDoorAction`, `GetIsDoorActionPossible`) и не изобретает «движок внутри движка».

Однако есть несколько точек, где консистентность и эксплуатационная диагностика пока уступают целевому уровню.

## Ключевые наблюдения

### 1) Canonical pipeline уже сформирован (плюс)

- Router выбирает entry waypoint и делегирует исполнение executor'у: `DL_TryRouteToTarget -> DL_TryExecuteRoutedTransitionEntryWaypoint`.
- Executor использует встроенные действия NWN для movement/transition.

Вывод: архитектурная база соответствует принципу «использовать встроенные механики, не костыли».

### 2) Часть activity-слоёв ещё сидит на legacy facade (риск консистентности)

В коде остаются вызовы `DL_TryUseNavigationRouteToTarget` в activity-модулях (`sleep`, `work`, `focus`). Это увеличивает вероятность расхождения поведения и усложняет сопровождение pipeline.

Рекомендация: унифицировать call-sites на `DL_TryRouteToTarget`.

### 3) Небольшая диагностическая неконсистентность в executor

В универсальном executor передаётся `sDiagPrefix`, но в ветке trigger/none и door финальный diagnostic жёстко задан как `routed_transition_in_progress`.

Следствие: для non-routed сценариев (если будут подключены через тот же executor) telemetry теряет контекст префикса.

Рекомендация: заменить жёсткую строку на динамический вариант через `sDiagPrefix + "_transition_in_progress"` во всех финальных путях.

### 4) Door-driver реализован через штатные API (плюс)

Проверка `GetIsDoorActionPossible` и вызов `DoDoorAction` перед jump — хороший пример корректного использования NWN built-ins без кастомного обхода.

## Приоритетный план

1. Миграция activity call-sites на canonical router facade.
2. Нормализация transition diagnostics (prefix-safe).
3. После стабилизации telemetry — удаление legacy routing wrappers.

## Итог

Проект уже в правильной архитектурной колее; основная незавершённость — не в отсутствии механизмов NWN, а в переходном слое совместимости. Текущий фокус должен быть на консолидации точек входа и стандартизации диагностик.
