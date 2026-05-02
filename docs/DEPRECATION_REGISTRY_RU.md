# Deprecation Registry (RU)

Канонический реестр временно поддерживаемых legacy API/ключей.

## Формат записи

Для каждой замены обязательны поля:
- `old` — deprecated API/identifier/local key;
- `replacement` — canonical replacement;
- `remove_by` — крайний срок удаления (дата `YYYY-MM-DD` или релиз).

## Активные записи

| old | replacement | remove_by |
|---|---|---|
| `DL_TryUseNavZoneRouteToTarget` | `DL_TryRouteToTarget` | `2026-06-30` |
| `DL_TryUseCrossAreaNavigationRouteToTarget` | `DL_TryRouteToTarget` | `2026-06-30` |
| `DL_TryUseNavigationRouteToTarget` | `DL_TryRouteToTarget` | `2026-06-30` |
| `DL_TryExecuteTransitionEntryWaypoint` | `DL_TryExecuteTransitionViaEngine` | `2026-06-30` |

## Правила сопровождения

1. После каждого merge с заменой API/ключа реестр обновляется в том же коммите.
2. Transitional legacy-path допускается только как thin compatibility adapter без расширения функциональности.
3. Удаление adapters планируется не позднее одного релизного цикла после появления replacement.
