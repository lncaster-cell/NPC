> [!NOTE]
> Этот документ закрыт и переведён в архивный контекст. См. `docs/audits/audit_artifacts_closure_2026-05-02.md`

# Dead / legacy code candidates audit

Дата: 2026-05-02  
Scope: поиск «мусорного кода», неиспользуемых функций и остатков старых решений.

## Метод

- Собраны все объявления `DL_*` функций в `daily_life/*.nss`.
- Для каждой функции проверено количество упоминаний по репозиторию (`daily_life`, `docs`, `README.md`).
- Кандидаты с единственным упоминанием (только место объявления) отмечены как потенциально мёртвые.

## Найденные кандидаты (single-reference)

1. `DL_CR_MarkPendingLockpick` (`dl_cr_crime_inc.nss`) — не найдено вызовов из других скриптов.
2. `DL_ResolveEffectiveWaypointForNpc` (`dl_anchor_cache_inc.nss`) — не найдено вызовов.
3. `DL_IsValidTransitionWaypointForTag` (`dl_transition_inc.nss`) — не найдено вызовов.

## Риск и интерпретация

Это **кандидаты**, а не автоматическое удаление:
- часть функций может быть задумана под будущую интеграцию;
- часть могла использоваться до рефакторинга и остаться как остаток legacy-веток;
- если функция не вызывается ни runtime, ни event-scripts, она повышает шум и стоимость поддержки.

## Дополнительный признак legacy-остатков

Даже при наличии canonical router/executor, рабочие call-sites в `work/sleep/focus` продолжают использовать legacy navigation facade. Это усиливает вероятность наличия «полуживых» вспомогательных функций и переходных API.

## Рекомендации

1. Ввести `@deprecated`-комментарии у single-reference кандидатов и telemetry-флаг на случай временного оставления.
2. Провести 1 проход удаления «кандидат -> build/run smoke -> rollback при необходимости».
3. Для функций, оставляемых как planned hooks, добавить явный комментарий `reserved for ...`, чтобы убрать ambiguity.
4. Параллельно продолжить миграцию call-sites на canonical routing facade, чтобы быстрее проявились реально неиспользуемые legacy helper-функции.

## Практический приоритет

- **P1:** `DL_IsValidTransitionWaypointForTag`, `DL_ResolveEffectiveWaypointForNpc` (инфраструктурные helper-остатки).
- **P2:** `DL_CR_MarkPendingLockpick` (доменная функция crime-потока; перед удалением проверить сценарии lockpick event hooks).
