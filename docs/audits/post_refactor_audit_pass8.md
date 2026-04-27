# Post-refactor runtime audit (pass 8) — Daily Life

## Контекст

- Дата аудита: 2026-04-21.
- Область: `daily_life/dl_worker_inc.nss` (`DL_RunAreaNpcRoundRobinPass`).
- Метод: path-audit логики `cursor/budget` с фокусом на корректность `DL_L_AREA_PASS_LAST_SEEN`.
- Базовая политика: только штатные NWScript/NWN2 механики по паттернам NWN Lexicon (итерация area через `GetFirstObjectInArea`/`GetNextObjectInArea`), без ad-hoc обходов.

## Найденная проблема

### R8-1 (Medium): двойной учёт active NPC в wrap-ветке

Симптом:
- После основного прохода (и опционального tail-count при fast-break) `nNpcSeenTotal` уже отражал наблюдаемую active-population area.
- В wrap-ветке (`nNpcProcessed < nBudget && nCursor > 0`) счётчик `nNpcSeenTotal` повторно инкрементировался для первых `nCursor` NPC.

Риск:
- `DL_L_AREA_PASS_LAST_SEEN` завышался.
- Cursor modulo мог вычисляться по inflated population, что ухудшало fairness round-robin и приводило к неритмичному покрытию части NPC.

## Исправление

Минимальная правка:
- Убран повторный инкремент `nNpcSeenTotal` в wrap-ветке.

Почему безопасно:
- Контракт обработки NPC не изменён: меняется только метрика наблюдаемого total.
- Бюджет и порядок вызовов `DL_ProcessAreaNpcByPassMode` не затронуты.
- Используются те же стандартные механики NWScript, без новых side effects.

## Итог

Pass 8 закрывает R8-1: `DL_L_AREA_PASS_LAST_SEEN` снова отражает фактически наблюдаемую active-population без двойного счёта, что стабилизирует cursor progression в round-robin.
