# Post-refactor runtime audit (pass 8) — Daily Life

## Контекст

- Дата аудита: 2026-04-21.
- Область: `daily_life/dl_worker_inc.nss` (`DL_RunAreaNpcRoundRobinPass`).
- Запрос: поиск мусорного кода/конфликтующей логики и симптомов «нейросетевого абсурда» в hot-path.
- Базовый принцип: использовать штатные механики NWScript/NWN2 с опорой на NWN Lexicon.

## Найденный риск

### R8-1 (Medium): двойной учёт active NPC в wrap-фазе курсора

Симптом:
- После pass 7 метрика `nNpcSeenTotal` стала опорой для `DL_L_AREA_PASS_LAST_SEEN` (и далее для modulo cursor).
- В `wrap`-ветке (`nNpcProcessed < nBudget && nCursor > 0`) код повторно увеличивал `nNpcSeenTotal` при втором проходе по префиксу списка.
- Это давало завышенный `nNpcSeenTotal` относительно фактического числа active NPC.

Риск:
- Некорректный знаменатель для modulo cursor.
- Drift/fairness деградация round-robin: часть NPC может получать более редкие touch-окна при длинных сериях тиков.

## Исправление

Минимальная правка без изменения архитектуры:
- Удалён инкремент `nNpcSeenTotal` в wrap-цикле.
- Подсчёт `nNpcSeenTotal` теперь выполняется только в основном проходе (+ tail-count при fast-break), т.е. один раз на объект.

Почему это корректно:
- Не меняет контракт budget (`nBudget`) и не расширяет обработку NPC.
- Не добавляет новых локалок/фаз.
- Сохраняет модель event-first и существующие точки ingress/resync.

## Сверка с NWN Lexicon

Подход остаётся в пределах каноничного iteration-паттерна:
- `GetFirstObjectInArea` / `GetNextObjectInArea` для bounded проходов по area.
- `GetObjectType(...) == OBJECT_TYPE_CREATURE` для фильтрации существ.

Проверено по справочным страницам NWN Lexicon:
- https://nwnlexicon.com/GetFirstObjectInArea
- https://nwnlexicon.com/GetNextObjectInArea
- https://nwnlexicon.com/OBJECT_TYPE

## Итог

Pass 8 закрывает конфликт логики учёта population в cursor-алгоритме: исключён двойной подсчёт в wrap-фазе, что стабилизирует fairness round-robin без ad-hoc костылей.
