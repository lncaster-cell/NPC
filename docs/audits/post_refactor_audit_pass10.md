# Post-refactor runtime audit (pass 10) — Daily Life

## Контекст

- Дата аудита: 2026-04-21.
- Область: `daily_life/dl_worker_inc.nss` (`DL_RunAreaWarmMaintenanceTick`, `DL_RunAreaWorkerTick`).
- Фокус: progression курсора после pass 8/9 при нулевом `nNpcProcessed`.
- Подход: только штатные NWScript-механики и существующий round-robin контракт.

## Найденный риск

### R10-1 (Medium): same-window stall при `nNpcProcessed == 0`

Симптом:
- В worker/warm тике курсор сдвигался на `nNpcProcessed`.
- Если текущие кандидаты были пропущены dedupe-гейтами (`DL_L_NPC_LAST_TOUCH_TICK`) или другими безопасными skip-условиями, `nNpcProcessed` мог быть `0` при `nNpcSeen > 0`.
- В результате курсор не двигался и следующий тик снова стартовал с того же окна.

Риск:
- ухудшение fairness и медленное покрытие area-population в режимах с частыми skip в текущем окне.

## Исправление

Минимальная правка:
- В `DL_RunAreaWarmMaintenanceTick` и `DL_RunAreaWorkerTick` добавлен clamp cursor advance:
  - если `nNpcSeen > 0` и `nNpcProcessed <= 0`, сдвиг курсора принудительно `1`.
  - иначе используется штатный сдвиг на `nNpcProcessed`.

Почему безопасно:
- Не меняется budget/обработка NPC в проходе.
- Изменяется только advance cursor state между тиками.
- Используется уже существующая модель modulo по `nNpcSeen`, без новых механизмов и ad-hoc хранения.

## Итог

Pass 10 закрывает R10-1: worker/warm курсор больше не «залипает» на одном окне при нулевом фактическом `processed`, что повышает стабильность round-robin покрытия без изменения контрактов обработки NPC.
