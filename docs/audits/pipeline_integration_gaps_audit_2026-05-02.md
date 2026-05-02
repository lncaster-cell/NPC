> [!NOTE]
> Этот документ закрыт и переведён в архивный контекст. См. `docs/audits/audit_artifacts_closure_2026-05-02.md`

# Pipeline integration gaps audit

Дата: 2026-05-02  
Scope: runtime includes и фактические call-sites.

## Executive summary

Найден критичный интеграционный гэп: канонический путь `DL_TryRouteToTarget -> DL_TryExecuteRoutedTransitionEntryWaypoint` определён, но фактически почти не используется рабочими activity-flow.

Это означает, что проект формально имеет новый pipeline-контракт, но runtime всё ещё выполняется в legacy-пути.

## Findings

### 1) Canonical router есть, но call-sites на него не переведены

- `DL_TryRouteToTarget` объявлен в `dl_nav_router_inc.nss`.
- `work/sleep/focus` продолжают вызывать `DL_TryUseNavigationRouteToTarget`.

Риск: contract drift между design-документом и исполняемой логикой.

### 2) Canonical executor есть, но routing facade ведёт в legacy execution

- `DL_TryExecuteRoutedTransitionEntryWaypoint` существует как целевой executor.
- `DL_TryUseNavigationRouteToTarget` вызывает `DL_TryExecuteTransitionEntryWaypoint` (legacy executor), а cross-area путь — `DL_TryExecuteCrossAreaTransitionEntryWaypoint`.

Риск: новые правки в canonical executor могут не влиять на основной runtime-path.

### 3) Include-композиция указывает на сохранение legacy-first runtime

`dl_res_inc.nss` подключает `dl_transition_inc` (legacy transition layer), что подтверждает текущую активную зависимость от старого фасада.

## Impact

- Повышенная вероятность «ложного чувства миграции»: код нового pipeline присутствует, но не доминирует в прод-исполнении.
- Рост стоимости тестирования: нужно проверять параллельно canonical и legacy ветки.
- Увеличение риска регрессий при selective-фисках (фикс сделан в одном executor, но баг остаётся в фактически используемом).

## Recommended next step (минимальный, но стратегический)

1. Ввести временный adapter `DL_TryUseNavigationRouteToTarget -> DL_TryRouteToTarget` (при совместимых preconditions).
2. Поэтапно перевести call-sites `work/sleep/focus` на `DL_TryRouteToTarget`.
3. Добавить telemetry-флаг, какой фасад реально сработал (canonical vs legacy).
4. После стабилизации usage — деактивировать прямые legacy execution entry points.

## Why this matches project principles

- Сокращает лишние ветки без отказа от штатных NWScript-механик.
- Делает runtime более предсказуемым, bounded и наблюдаемым.
