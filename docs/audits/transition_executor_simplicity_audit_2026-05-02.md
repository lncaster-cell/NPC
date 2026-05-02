# Audit: Transition Executor и риск переусложнения

Дата: 2026-05-02  
Область: `daily_life/` (router/executor/transition helper) + контракт в unified doc.

## Короткий ответ на главный вопрос

**Да, дублирование есть и в execution, и в routing-API.**  
Это не «две независимые большие системы», но есть несколько параллельных входов с пересекающейся логикой, что увеличивает стоимость поддержки.

## Что уже хорошо (контракт целевой архитектуры)

- Контракт в unified doc фиксирует pipeline `Nav Router -> Transition Executor`.
- Новый путь `DL_TryRouteToTarget -> DL_TryExecuteRoutedTransitionEntryWaypoint` уже реализован и соответствует контракту.

## Карта дублирования (продолжение поиска)

### A. Дублирование execution-path (выполнение одного перехода)

1. **Canonical executor**: `DL_TryExecuteRoutedTransitionEntryWaypoint` (`dl_transition_exec_inc.nss`).
2. **Legacy executor**: `DL_TryExecuteTransitionEntryWaypoint` (`dl_transition_inc.nss`).
3. **Cross-area executor**: `DL_TryExecuteCrossAreaTransitionEntryWaypoint` (`dl_cross_area_nav_inc.nss`).

У всех трёх пересекается одна и та же базовая схема:
- distance-gate до entry;
- resolve exit waypoint;
- set transition status/diag;
- door handling (`DoDoorAction`) + jump (`ActionJumpToLocation`).

### B. Дублирование routing entry points (выбор и запуск маршрута)

Сейчас одновременно существуют несколько публичных «попробовать маршрут» функций:
1. `DL_TryRouteToTarget` (новый canonical router).
2. `DL_TryUseNavZoneRouteToTarget` (legacy nav-zone route).
3. `DL_TryUseCrossAreaNavigationRouteToTarget` (legacy cross-area route).
4. `DL_TryUseNavigationRouteToTarget` (комбинированный legacy wrapper).

Функционально это пересекающиеся API одного назначения (довести NPC к target через transitions), что создаёт риск разных call-sites и разного поведения в edge-case.

### C. Дублирование диагностических состояний

Статусы схожие, но с разными строками:
- `moving_to_transition_entry` vs `moving_to_cross_area_transition_entry` vs `moving_to_routed_transition_entry`;
- `transition_in_progress` vs `cross_area_transition_in_progress` vs `routed_transition_in_progress`;
- разные формулировки для exit-missing.

Это усложняет агрегированную telemetry/алерты и делает сравнение профилей менее надёжным.

## Вывод

Ваше ощущение корректное: **дублирование действительно есть**, и оно уже выходит за рамки «временной совместимости», потому что касается не только legacy-metadata, но и публичных routing/execution точек входа.

## Рекомендованный план с минимальным риском

1. **Single execution core**
   - Оставить единственным исполняющим ядром `DL_TryExecuteRoutedTransitionEntryWaypoint`.
   - Legacy/cross-area executor-функции превратить в тонкие adapters, которые только нормализуют вход и вызывают canonical executor.

2. **Single routing facade**
   - Зафиксировать `DL_TryRouteToTarget` как единственный публичный entry point для нового pipeline.
   - Legacy routing API оставить как deprecated wrappers с явной телеметрией использования.

3. **Unify diagnostics contract**
   - Вынести status/diag коды в константы и helper-setter (единый словарь), чтобы избежать строковых вариаций.

4. **Migration by metrics, not by guess**
   - Добавить счётчики вызовов legacy routing/execution adapters.
   - Удалять legacy ветки только после стабильного низкого usage.

## Практический verdict

- Дублирование локализовано и управляемо.
- Следующий правильный шаг: не расширять новые ветки, пока не завершена консолидация к **одному router API + одному executor core**.
