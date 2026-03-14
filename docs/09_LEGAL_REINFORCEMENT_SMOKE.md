# Ambient Life v2 — Legal/Reinforcement Smoke Runbook (Stage I.3)

Дата: 2026-03-14
Статус: Draft (активируется при старте Stage I.3)
Область: legal/reinforcement сценарии поверх disturbed/crime/alarm контура

---

## 1) Назначение

Этот документ фиксирует минимальный smoke-набор для проверки Stage I.3:
- bounded reinforcement policy;
- корректный handoff в legal pipeline;
- предсказуемое завершение сценария без full-scan и без бесконечной эскалации.

## 2) Предусловия

1. Базовые контуры Stage I.2 работают стабильно (route/sleep/react/city alarm).
2. В тестовой area настроены city теги и role-назнажения.
3. Включена диагностическая телеметрия, достаточная для проверки переходов состояния.

## 3) Базовые smoke-сценарии

### S1 — Reinforcement bounded policy

**Цель:** убедиться, что подкрепления вызываются в рамках лимитов.

Шаги:
1. Сгенерировать контролируемый incident в городской зоне.
2. Наблюдать spawn/assignment цепочку в пределах area/city policy.
3. Довести сценарий до восстановления `alarm -> recovery -> normal`.

Критерии pass:
- нет world-wide scan поведения;
- количество/частота подкреплений не выходит за лимиты policy;
- после нормализации новые подкрепления не приходят без нового инцидента.

### S2 — Surrender -> arrest -> legal followup

**Цель:** проверить end-to-end legal handoff.

Шаги:
1. Запустить инцидент, требующий legal followup.
2. Проверить, что actor проходит последовательность surrender/arrest.
3. Подтвердить завершение handoff в legal-контур без зависания промежуточного состояния.

Критерии pass:
- последовательность конечна и наблюдаема;
- нет ручного вмешательства в runtime locals;
- pipeline завершается прогнозируемым outcome.

### S3 — Деэскалация и отсутствие регрессий

**Цель:** убедиться, что legal/reinforcement не ломает базовую рутину NPC.

Шаги:
1. Пройти S1/S2 до завершения.
2. Проверить возврат затронутых NPC в стандартный route/sleep/activity цикл.

Критерии pass:
- routine pipeline восстановлен;
- city FSM деэскалировал состояние;
- нет перманентных stuck-state симптомов.

## 4) Чек-лист перед статусом Done

- [ ] Обновлены `docs/02_MECHANICS.md` (новая механика I.3).
- [ ] Обновлены `docs/03_OPERATIONS.md` (операционные smoke/checks).
- [ ] Обновлены `docs/04_CONTENT_CONTRACTS.md` (новые contract keys/events).
- [ ] Обновлён `docs/08_STAGE_I3_TRACKER.md` (перевод задач из Planned).
- [ ] Зафиксированы архитектурные решения в `docs/10_DECISIONS_LOG.md`.

## 5) Ограничения

- Документ intentionally short: это smoke runbook, а не полный тест-план.
- Детальная матрица регрессий может быть вынесена в отдельный QA-документ после старта Stage I.3.
