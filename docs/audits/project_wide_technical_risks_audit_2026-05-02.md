> [!NOTE]
> Этот документ закрыт и переведён в архивный контекст. См. `docs/audits/audit_artifacts_closure_2026-05-02.md`

# Project-wide technical risks audit

Дата: 2026-05-02  
Scope: весь runtime-код `daily_life/*.nss`.

## Executive summary

По коду выявлены 4 приоритетные технические зоны риска:
1. Незавершённая консолидация routing/executor (архитектурный риск).
2. Legacy routing facade всё ещё в hot-path activity-контуров (поведенческий drift риск).
3. Разнородная transition telemetry vocabulary (операционный риск наблюдаемости).
4. Локальный `DelayCommand` в blocked-flow (контролируемый, но требующий лимитов и мониторинга).

## 1) Архитектурный риск: параллельные execution paths

Одновременно присутствуют:
- canonical executor `DL_TryExecuteRoutedTransitionEntryWaypoint`;
- legacy executor `DL_TryExecuteTransitionEntryWaypoint`;
- cross-area executor `DL_TryExecuteCrossAreaTransitionEntryWaypoint`.

Риск: трудно гарантировать одинаковые edge-case semantics после будущих изменений.

## 2) Поведенческий риск: mixed routing facades в рабочих сценариях

`work`, `sleep`, `focus` продолжают использовать `DL_TryUseNavigationRouteToTarget` вместо единого `DL_TryRouteToTarget`.

Риск: разные маршрутизационные ветки в разных директивах, что повышает вероятность «плавающих» багов и усложняет regression triage.

## 3) Наблюдаемость: фрагментация диагностических кодов

Похожие по смыслу состояния пишутся разными строками (`moving_to_*`, `*_in_progress`, варианты `*_exit_missing`).

Риск: трудно строить стабильные дешборды/алерты без нормализации (увеличение операционной стоимости поддержки).

## 4) DelayCommand в blocked-flow

В `dl_blocked_inc.nss` есть `DelayCommand` для reissue/cooldown после попытки открыть дверь.

Это допустимо как тонкий deferred-механизм, но важно контролировать:
- частоту срабатываний;
- fan-out при большом числе NPC;
- отсутствие каскадного requeue.

## Рекомендации (практичные, без «переписать всё»)

1. Зафиксировать **single routing facade** (`DL_TryRouteToTarget`) и перевести на него `work/sleep/focus`.
2. Оставить **single executor core** и превратить legacy/cross-area execution в adapters.
3. Ввести централизованный словарь transition status/diag (константы + helper API).
4. Для blocked DelayCommand добавить telemetry counters (events per minute, repeated-by-npc rate).

## Почему это соответствует проектным принципам

- Используются штатные механики NWScript (`ActionMoveToLocation`, `ActionJumpToLocation`, `DoDoorAction`) без избыточных костылей.
- Рекомендации направлены на bounded/observable/idempotent контуры и соответствуют unified pipeline-контракту.
