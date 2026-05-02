# Project-wide duplication audit (codebase-wide)

Дата: 2026-05-02  
Scope: весь код репозитория (`daily_life/*.nss`, docs для контрактов).

## Executive summary

Да, дублирование есть в нескольких слоях, но крупнейший кластер — в навигации/transition.  
Второй заметный кластер — дублирование routing-вызовов в activity-модулях (`sleep/work/focus`) через legacy facade.

## 1) Transition execution duplication (критично)

Найдены **три** исполняющих функции с пересечением логики:
- `DL_TryExecuteRoutedTransitionEntryWaypoint` (canonical).
- `DL_TryExecuteTransitionEntryWaypoint` (legacy).
- `DL_TryExecuteCrossAreaTransitionEntryWaypoint` (cross-area).

Общая повторяющаяся механика:
- move to entry;
- resolve exit;
- transition status/diagnostic;
- optional `DoDoorAction`;
- `ActionJumpToLocation`.

Риск: рассинхрон поведения/диагностики, рост regression surface.

## 2) Routing API duplication (критично)

Найдены параллельные routing entry points:
- `DL_TryRouteToTarget` (canonical facade);
- `DL_TryUseNavZoneRouteToTarget` (legacy);
- `DL_TryUseCrossAreaNavigationRouteToTarget` (legacy);
- `DL_TryUseNavigationRouteToTarget` (legacy wrapper).

Риск: разные call-sites могут идти разными путями в edge-case и давать разный runtime result.

## 3) Activity-level duplicated routing calls (средний риск)

`work`, `sleep`, `focus` всё ещё вызывают legacy routing facade `DL_TryUseNavigationRouteToTarget`, а не canonical `DL_TryRouteToTarget`.

Это не дублирование функции «строка-в-строку», но это **дублирование точки интеграции**, которое тормозит консолидацию pipeline.

## 4) Diagnostic vocabulary duplication (средний риск)

Для transition веток используются разные, но близкие по смыслу diagnostic/status строки:
- `moving_to_transition_entry` / `moving_to_cross_area_transition_entry` / `moving_to_routed_transition_entry`;
- `transition_in_progress` / `cross_area_transition_in_progress` / `routed_transition_in_progress`;
- несколько вариантов exit-missing.

Риск: усложнённая telemetry/алертинг и более дорогой анализ инцидентов.

## 5) Что не считаю «плохим дублированием»

- `DL_SetWorkMissingState` и `DL_SetSleepMissingState` похожи концептуально, но обслуживают разные state-машины (work vs sleep), поэтому это допустимое доменное разделение.
- Единичные `ActionJumpToLocation` в crime/detain flow — отдельный домен (не navigation pipeline), здесь дублирование архитектурно ожидаемо.

## Recommendation (порядок работ)

1. **Закрыть критичное дублирование first**: один executor core + один router facade.
2. **Перевести activity call-sites** (`sleep/work/focus`) на canonical routing facade.
3. **Унифицировать transition diagnostics** через константы/enum-style коды.
4. После стабилизации telemetry — удалить legacy wrappers.

## Contract alignment

Предлагаемая консолидация полностью соответствует unified pipeline-контракту:  
`Destination Resolver -> Nav Router -> Transition Executor`.
