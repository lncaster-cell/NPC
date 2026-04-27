# Post-refactor runtime audit (pass 9) — Daily Life

## Контекст

- Дата аудита: 2026-04-21.
- Область: `daily_life/dl_worker_inc.nss` (`DL_RunAreaNpcRoundRobinPass`).
- Метод: проверка корректности источника `DL_L_AREA_PASS_LAST_SEEN` для cursor modulo после изменений pass 8.
- Политика: только встроенные механики NWScript/NWN2 и каноничные Lexicon-паттерны (итерация area через `GetFirstObjectInArea`/`GetNextObjectInArea`).

## Найденная проблема

### R9-1 (Medium): fallback на registry count маскировал реальное нулевое наблюдение

Симптом:
- При `nNpcSeenTotal <= 0` код подставлял `nNpcRegistered`.
- Если registry становился stale (например, после ухода/деактивации NPC без своевременного deregistration), `DL_L_AREA_PASS_LAST_SEEN` оставался > 0 даже при фактическом `0` active NPC в area.

Риск:
- cursor progression опирался на устаревшее окно population.
- восстановление fairness после опустевшей area затягивалось.

## Исправление

Минимальная правка:
- Удалён fallback на `nNpcRegistered`.
- `DL_L_AREA_PASS_LAST_SEEN` теперь записывается строго из наблюдаемого `nNpcSeenTotal` (с защитным clamp только от теоретически невозможного отрицательного значения).

Почему это соответствует NWN Lexicon-подходу:
- Источник истины — фактическая итерация объектов в area стандартными built-in функциями.
- Не вводятся новые ad-hoc локалы/таймеры/обходы; только корректировка семантики существующей метрики.

## Итог

Pass 9 закрывает R9-1: `DL_L_AREA_PASS_LAST_SEEN` больше не удерживает stale registry population и отражает фактически наблюдаемый active set, что улучшает стабильность cursor modulo после динамических изменений состава NPC.
