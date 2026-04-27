# Post-refactor runtime audit (pass 6, deep) — Daily Life

## Контекст

- Дата аудита: 2026-04-15.
- Область: `daily_life/` (worker/resync, directive pipeline, transition/focus, lifecycle ingress, cache/registry).
- Подход: статический path-audit с проверкой инвариантов по входным точкам и горячим путям.
- Базовая политика: использовать штатные NWScript/NWN2 механики и паттерны из NWN Lexicon; не добавлять ad-hoc обходы.

## 1) Проверенный runtime-контур (deep coverage)

1. **Ingress и lifecycle:** `dl_spawn.nss`, `dl_death.nss`, `dl_userdef.nss`, `dl_lifecycle_inc.nss`, `dl_resync_inc.nss`.
2. **Area loop и budgets:** `dl_a_hb.nss`, `dl_worker_inc.nss`, `dl_registry_inc.nss`.
3. **Directive orchestration:** `dl_res_inc.nss` + `dl_sleep_inc.nss`, `dl_work_inc.nss`, `dl_focus_inc.nss`, `dl_transition_inc.nss`.
4. **Blocked flow:** `dl_blocked.nss`, `dl_blocked_inc.nss`.
5. **Cache layer:** `dl_anchor_cache_inc.nss`, social/transition caches в `dl_focus_inc.nss` и `dl_transition_inc.nss`.

## 2) Результаты deep-аудита

### A. Подтверждено как корректное/стабильное

1. **Same-tick dedupe в worker/resync** сохранён и корректно ограничивает двойную обработку.
2. **Budget/cursor модель** остаётся bounded, без unbounded-циклов в hot path.
3. **Blocked recovery** остаётся каноническим: через `DoDoorAction`, delayed reissue и busy-gate.
4. **Cache-first lookup** используется в social-партнёре и transition driver/exit resolution.

### B. Найденные замечания (pass 6)

#### R6-1 (Medium): cross-area social partner reuse

- Симптом: social partner cache/lookup допускал валидного партнёра не из текущей area NPC.
- Риск: ложные SOCIAL-пары при миграции/рассинхроне зон, лишний churn fallback/анимаций.
- Решение (минимальное, штатное): добавлена проверка `GetArea(oPartner) == GetArea(oNpc)` и для cached, и для fallback lookup.
- Почему безопасно: не меняет контракт директивы, только усиливает валидность пары.

#### R6-2 (Low/Medium): door-transition jump via ActionDoCommand(JumpToLocation)

- Симптом: в door-driver ветке перехода использовалась обёртка `ActionDoCommand(JumpToLocation(...))`.
- Риск: менее предсказуемая queue-семантика и избыточный слой по сравнению с прямым action-вызовом.
- Решение: заменено на `ActionJumpToLocation(lExit)` под `AssignCommand`, после `ClearAllActions` и опционального `DoDoorAction`.
- Почему безопасно: соответствует стандартной модели action-очереди NWScript и уменьшает неоднозначность выполнения.

## 3) Внесённые правки по итогам deep-аудита

1. `daily_life/dl_focus_inc.nss`
   - Усилена валидация social partner (same-area для cache hit и cache miss).
2. `daily_life/dl_transition_inc.nss`
   - Упрощён jump в door-driver ветке: прямой `ActionJumpToLocation` вместо `ActionDoCommand(JumpToLocation)`.

## 4) Сверка с NWN Lexicon (ключевые функции)

Проверены справочные паттерны по функциям:

1. `JumpToLocation` / `AssignCommand` / `ClearAllActions` (рекомендуемая последовательность для немедленного телепорта объекта).
2. `ActionDoCommand` (ограничения/известные особенности при вставке void-команд в action queue).

Применённый вывод для кода: в данном runtime-контексте прямой `AssignCommand(..., ActionJumpToLocation(...))` предпочтительнее дополнительной обёртки через `ActionDoCommand`.

## 5) Актуальные приоритеты после pass 6

1. `P1`: owner-run сценарии weekend/public + negative markup с замером переходов между зонами.
2. `P1`: telemetry по `GetObjectByTag` miss-rate для transition driver/area anchor.
3. `P2`: оценка стоимости repeated clear/set в skeleton на high-density area.

## Заключение

Deep-аудит pass 6 подтверждает общую устойчивость post-refactor контура и закрывает два дополнительных runtime-риска без архитектурного переписывания и без ad-hoc решений. Изменения выполнены через встроенные NWScript-механизмы и согласованы с Lexicon-паттернами.
