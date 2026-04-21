# Post-refactor runtime audit (pass 9) — Daily Life

## Контекст

- Дата аудита: 2026-04-21.
- Область: `daily_life/dl_worker_inc.nss` (`DL_RunAreaNpcRoundRobinPass`).
- Цель: закрепить устойчивость cursor/population инварианта после фикса R8-1.

## Уточнение риска

После удаления двойного инкремента в wrap-фазе остаётся класс регрессий, где будущие правки могут случайно повторно увеличить `nNpcSeenTotal` при полном проходе area.

Симптом такого дрейфа:
- `DL_L_AREA_PASS_LAST_SEEN` перестаёт точно совпадать с фактически увиденным числом active NPC при отсутствии fast-break.
- Cursor modulo начинает опираться на «зашумлённый» знаменатель.

## Принятое усиление

Добавлен лёгкий инвариант после wrap-фазы:
- если fast-break **не** срабатывал (`!bBrokeEarly`) и основной проход уже видел активных NPC (`nNpcSeen > 0`), то `nNpcSeenTotal` принудительно выравнивается к `nNpcSeen`.

Это не меняет поведение fast-break пути, где total корректно добирается tail-count-ом.

## Почему это безопасно

- Нулевой рост стоимости hot-path: только O(1) проверка/присваивание.
- Не меняются budget, порядок обработки и контракты resync/worker.
- Используются штатные NWScript-паттерны area iteration без новых обходных механизмов.

## Сверка с NWN Lexicon

Архитектура и цикл обхода остаются каноничными:
- `GetFirstObjectInArea` / `GetNextObjectInArea`
- фильтрация через `GetObjectType(...)=OBJECT_TYPE_CREATURE`

Ссылки:
- https://nwnlexicon.com/GetFirstObjectInArea
- https://nwnlexicon.com/GetNextObjectInArea
- https://nwnlexicon.com/OBJECT_TYPE

## Итог

Pass 9 закрепляет инвариант population-count для non-fast-break ветки и снижает шанс повторной деградации fairness в cursor round-robin.
