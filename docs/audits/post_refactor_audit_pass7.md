# Post-refactor runtime audit (pass 7) — Daily Life

## Контекст

- Дата аудита: 2026-04-17.
- Область: `daily_life/dl_worker_inc.nss` (round-robin pass / cursor progression).
- Метод: path-audit горячего цикла с проверкой bounded execution и корректности cursor modulo.
- Базовая политика: только штатные NWScript/NWN2 механики и паттерны NWN Lexicon, без ad-hoc обходов.

## Найденный риск

### R7-1 (Medium): потенциальный same-window reset курсора при раннем fast-break

Симптом:
- В `DL_RunAreaNpcRoundRobinPass` локальная метрика `DL_L_AREA_PASS_LAST_SEEN` выставлялась из `DL_L_AREA_REG_COUNT`, а при fast-break фактически наблюдалось только окно `cursor..cursor+budget`.
- При дрейфе registry count (например, edge-case пропуска регистрации части NPC) курсор мог часто возвращаться в один и тот же диапазон и дольше восстанавливать покрытие.

Риск:
- ухудшение fairness round-robin и delayed touch/register для части активных NPC.

## Принятое решение

Минимальная штатная правка в `DL_RunAreaNpcRoundRobinPass`:
1. Добавлен учёт **фактически наблюдаемого** количества active NPC (`nNpcSeenTotal`) в текущем проходе.
2. Если сработал fast-break, выполняется лёгкий **tail-count** остатка area-итерации (без дополнительной обработки директив) через стандартные `GetFirstObjectInArea/GetNextObjectInArea`.
3. `DL_L_AREA_PASS_LAST_SEEN` теперь ставится из наблюдаемого total, с fallback на registry count только если total не получен.

Почему это безопасно:
- Не меняется контракт директив/ресинка.
- Бюджет обработки NPC (`nBudget`) не увеличивается.
- Добавляется только корректный учёт размера active-population для стабильного cursor modulo.

## Сверка с NWN Lexicon

Использованы и сохранены каноничные паттерны:
- area iteration: `GetFirstObjectInArea` + `GetNextObjectInArea`;
- фильтрация существ: `GetObjectType(...) == OBJECT_TYPE_CREATURE`;
- action-free counting path (без лишних side effects).

## Итог

Pass 7 закрывает риск R7-1: курсор round-robin теперь опирается на наблюдаемую active-population, что снижает вероятность repeated same-window обработки при расхождении registry и фактического состава NPC.
