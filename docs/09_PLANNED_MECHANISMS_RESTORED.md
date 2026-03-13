# Ambient Life v2 — Восстановленные планируемые механизмы

Дата: 2026-03-13  
Назначение: собрать в одном месте механики, которые были запланированы, но ещё не доведены до production-ready стадии.

> Ограничение аудита: `third party/*` и компилятор внутри неё не анализируются и не изменяются.

## 1) Базовая рамка планирования

Планируемые механики развиваются поверх уже реализованного Stage I.2:
- area-centric lifecycle;
- registry/dispatch/route/sleep/activity;
- blocked/disturbed;
- city crime/alarm FSM.

Ключевое правило: **никаких world-wide full scans** и никаких unbounded-цепочек.

## 2) Каталог планируемых механик

## M-01 Reinforcement policy (guard spawn / backup)
**Статус:** Planned  
**Опора в текущем runtime:** city alarm состояния и assignment события.

**Планируемое поведение**
1. При росте `desired_alarm_state` система оценивает необходимость подкрепления.
2. Подкрепление materialize-ится только в area/city-локальном контексте.
3. Применяются лимиты: max одновременно активных unit-ов, cooldown и приоритет war post.
4. При recovery подкрепления снимаются по bounded batch-policy.

**Критерии готовности**
- Есть параметризуемые лимиты в контенте/конфиге.
- Нет взрывного спавна и нет full-scan по миру.
- Есть smoke-сценарий «тревога -> подкрепление -> recovery».

## M-02 Legal pipeline: surrender -> arrest -> trial followup
**Статус:** Planned (hook-ready)  
**Опора в текущем runtime:** `al_legal_followup_pending` в disturbed-react слое.

**Планируемое поведение**
1. Disturbed/crime инцидент помечает юридический followup.
2. NPC может войти в ветку surrender при выполнении условий (роль, опасность, контекст area).
3. При отказе — arrest path с bounded преследованием/фиксацией.
4. Финальная стадия: trial/legal outcome (штраф, detention, cleanup state).

**Критерии готовности**
- End-to-end цепочка работает без ручного вмешательства в locals.
- Нет конфликтов с routine/sleep/transition инвариантами.
- Результат legal цепочки отражается в city/crime runtime состоянии.

## M-03 Crime consequences expansion
**Статус:** Planned  
**Опора в текущем runtime:** crime типы и alarm FSM уже реализованы.

**Планируемое поведение**
1. Развести последствия по типам: theft / assault / murder / discovered murder / spell abuse.
2. Добавить градацию тяжести и длительности эффектов на district-level.
3. Реализовать controlled decay последствий (не вечные санкции).
4. Не превращать слой в «global diplomacy simulator».

**Критерии готовности**
- Каждому crime type соответствует предсказуемый outcome.
- Есть явная деэскалация и отсутствие sticky-состояний.
- Поведение воспроизводимо в smoke-тестах.

## M-04 Population respawn policy (после выбытия)
**Статус:** Planned / частично описано в механиках  
**Опора в текущем runtime:** требования к bounded-поведениям и city-role контекст.

**Планируемое поведение**
1. Респаун отделён от обычного route loop.
2. Учитываются role quotas, district тип и безопасные spawn-точки.
3. Вводятся cooldown и per-area cap на восстановление населения.
4. Респаун не ломает текущие alarm/legal контуры.

**Критерии готовности**
- Нет массовых всплесков при множественных выбываниях.
- Новые NPC корректно входят в registry и routine slot flow.
- Есть preflight-проверка валидности точек респауна.

## M-05 Legal/Reinforcement QA smoke pack
**Статус:** Planned  
**Опора в текущем runtime:** общие operations/perf регламенты и существующие preflight практики.

**Планируемое поведение**
1. Набор smoke-сценариев:
   - theft -> alarm pending -> reinforcement;
   - surrender happy-path;
   - arrest fallback path;
   - recovery и нормализация role assignments.
2. Для каждого сценария фиксируются expected counters/state transitions.
3. Отчётность: operator-readable + machine-readable.

**Критерии готовности**
- Ясные pass/fail критерии.
- Повторяемость в одинаковых условиях.
- Интеграция в PR checklist.

## 3) Сквозные инварианты для всех планируемых механизмов

1. Только area/city-local вычисления, без глобальных сканов по миру.
2. Все новые ветки обязаны быть bounded по времени/объёму работы.
3. City alarm FSM не смешивается напрямую с routine FSM NPC.
4. Runtime locals не используются как ручной инструмент «починки» контента.
5. Любое расширение сопровождается операционными метриками и smoke-кейсами.

## 4) Приоритизация внедрения

1. **P1:** M-01 Reinforcement policy.
2. **P1:** M-02 Legal pipeline.
3. **P2:** M-03 Crime consequences expansion.
4. **P2:** M-05 QA smoke pack.
5. **P3:** M-04 Population respawn policy (если не блокирует legal/reinforcement).

## 5) Синхронизация с существующими документами

- Трекер статусов этапа: `docs/08_STAGE_I3_TRACKER.md`.
- Канон инвариантов: `docs/06_SYSTEM_INVARIANTS.md`.
- Каталог реализованного runtime: `docs/07_SCENARIOS_AND_ALGORITHMS.md`.
- Общий статус прогресса/пробелов: `docs/05_STATUS_AUDIT.md`.
