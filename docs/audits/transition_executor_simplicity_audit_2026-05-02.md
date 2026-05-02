# Audit: Transition Executor и риск переусложнения

Дата: 2026-05-02  
Область: `daily_life/` (router/executor/transition helper) + контракт в unified doc.

## Короткий ответ на главный вопрос

**Да, дублирование сейчас есть.** Не «полные две системы навигации», но есть **параллельные исполнители переходов** (executor-логика в нескольких местах), из-за чего растут риски рассинхронизации поведения и диагностики.

## Что уже хорошо (контракт соблюдён на уровне новой ветки)

- Контракт в design doc фиксирует `Nav Router -> Transition Executor` и запрещает конкурирующую навигацию внутри executor.
- `DL_TryRouteToTarget` выбирает entry и делегирует выполнение в `DL_TryExecuteRoutedTransitionEntryWaypoint`.
- Новый executor выполняет ровно один переход: подойти к entry → разрешить exit/driver → jump → обновить `dl_npc_nav_zone`.

## Где именно дублирование

### 1) Legacy transition executor в `dl_transition_inc.nss`

В `dl_transition_inc.nss` остаётся «старый» исполняющий путь перехода с теми же шагами (подход, проверка exit, driver, door open, jump, статусы/diag), что функционально пересекается с новым canonical executor.

### 2) Отдельная cross-area execution ветка в `dl_cross_area_nav_inc.nss`

В `dl_cross_area_nav_inc.nss` есть ещё один самостоятельный путь исполнения перехода (moving_to_cross_area_transition_entry, cross_area_transition_in_progress, door/jump), что снова дублирует executor-механику.

### 3) Диагностика и статусы размножены по слоям

Разные ветки пишут похожие, но не полностью одинаковые статусы/diagnostic строки. Это усложняет наблюдаемость и отладку.

## Вывод по «переусложнению»

- Ваше ощущение **обосновано**: сложность возникает не от самого разделения `Nav Router`/`Transition Executor`, а от того, что рядом ещё живут legacy/cross-area исполняющие ветки.
- То есть проблема не в концепции разделения, а в **неполной миграции к единому executor**.

## Рекомендованный план упрощения (без ломки текущих профилей)

1. **Single execution path:** оставить один канонический исполнитель `DL_TryExecuteRoutedTransitionEntryWaypoint`.
2. **Adapter-only для legacy/cross-area:** старые входы не исполняют переход сами, а нормализуют вход и вызывают canonical executor.
3. **Единый словарь transition diagnostics/status:** константы + helper-setter вместо строковых вариаций.
4. **Telemetry migration gate:** считать долю legacy-вызовов, и только после падения до целевого порога удалять старые исполняющие ветки.

## Практический verdict

- **Дублирование есть, но оно локализовано** и решается без тотальной переписи.
- Текущий этап разработки логично завершить так: «один executor, остальные слои — только маршрутизация/адаптация».
