# Ambient Life — глубокий технический аудит (Stage I.2 snapshot)
<!-- DOCSYNC:2026-03-13 -->
> Documentation sync: 2026-03-13. This file was reviewed and aligned with the current repository structure.


## 0) Область и ограничения аудита

- Проверка выполнена по текущему коду `scripts/ambient_life` и актуальной документации в `docs/`.
- Скрипты из `third party` и вложенный в неё компилятор **не анализировались и не модифицировались**.
- Фокус: архитектурная состоятельность, соответствие ограничениям NWN2/NWScript, эксплуатационные риски и приоритеты развития в рамках текущего среза Stage I.2.

---

## 1) Executive summary

Система находится в устойчивом состоянии **Stage I.2**: базовый runtime-контур зрелый, а реактивная ветка расширена до локального `crime/alarm` policy-layer внутри area.

Сильные стороны текущего среза:
1. **Event-driven area-centric runtime** без per-NPC heartbeat.
2. **Bounded execution** по dispatch/route/react веткам.
3. **Рабочий диагностический минимум**: overflow-счётчики и area health snapshot.
4. **Операционный контур I.2**: role-aware локальная тревога (`civilian/militia/guard`) и bounded fan-out в area.

Ключевые ограничения остаются в границах I.2 (осознанно):
- нет global/world alarm propagation;
- нет guard spawn/reinforcements;
- нет surrender/arrest/trial/legal pipeline.

---

## 2) Delta since I.1 audit

### Что внедрено после I.1

- Добавлена диагностика registry/route overflow (включая area-level счётчики snapshot).
- Зафиксирован и документирован **health snapshot** (`al_h_*`) как штатная runtime-диагностика area.
- Preflight-практика по locals переведена во внешний контур команды (вне этого репозитория), а в репозитории сохранены только контракт и входные примеры.
- Реализован **Stage I.2 policy-layer**: area-local alarm scope, bounded nearby fan-out, role hints через `al_npc_role`, safe-waypoint fallback-поведение.

### Что не закрыто (границы I.2)

- Эскалация не выходит за пределы текущей area.
- Нет механик подкреплений/спавна стражи.
- Нет полного legal follow-up контура (surrender/arrest/trial).

---

## 3) Что в архитектуре остаётся сильным

### 3.1 Runtime-модель под NWN2/NWScript

Выбор area-centric scheduler (`AL_ScheduleAreaTick` → `AL_AreaTick`) и `OnUserDefined` event bus остаётся оптимальным под бюджет NWScript: предсказуемая нагрузка, ограниченные bursts, минимум «фонового шума».

### 3.2 Tier/lifecycle и bounded dispatch

Связка `FREEZE/WARM/HOT`, token-gating и очереди dispatch с fairness/anti-starvation стабильно удерживает симуляцию в рамках лимитов даже на плотных сценах.

### 3.3 Registry и route runtime

Плотный area registry (`al_npc_<idx>`, swap-remove) и bounded route progression дают контролируемую стоимость операций. Route cache валидирует `al_step` и поддерживает runtime fallback вместо зависания NPC.

### 3.4 Подсистемная декомпозиция

Route/transition/sleep/blocked/react остаются изолированными подсистемами с явными точками входа в core dispatcher — это снижает стоимость сопровождения и дебага.

---

## 4) Техническая согласованность с текущим контрактом

Срез согласован с терминами и правилами из `docs/TECH_PASSPORT.md` и `docs/TOOLSET_CONTRACT.md`:

- стадия обозначается как **I.2**;
- реактивная модель формулируется как **area-local alarm scope** и **bounded nearby fan-out**;
- role-модель задаётся через `al_npc_role` (`civilian/militia/guard`);
- health/diag слой учитывает `al_h_*` snapshot + overflow counters;
- preflight валидация locals считается частью операционного контура;
- ограничения I.2 явно фиксируют отсутствие global propagation/reinforcements/arrest pipeline.

---

## 5) Риски и рекомендации (актуализировано для I.2)

## P0 — обязательно (текущий фокус)

1. **Закрыть perf-smoke профиль для dense area как регулярный регламент**
   - сценарии 80/100/120 NPC;
   - burst `OnBlocked/OnDisturbed`;
   - контроль метрик деградации (fallback idle, resync window, queue saturation).

2. **Усилить операторский runbook I.2-инцидентов**
   - отдельные playbook-ветки: «локальная тревога не затухает», «flee без safe waypoint», «guard role не подхватывает реакцию».

## P1 — важно

3. **Нормировать linked-area topology policy**
   - зафиксировать ограничения связности для крупных модулей, чтобы WARM-retention не приводил к избыточному каскаду активных зон.

4. **Довести единый формат runtime diagnostics экспорта**
   - унифицировать сбор `al_h_*` + alarm/runtime counters для повторяемого техразбора.

## P2 — следующий этап (I.3+)

5. **Проектирование глобальной эскалации**
   - world/global alarm propagation поверх area-local модели I.2.

6. **Проектирование enforcement pipeline**
   - reinforcements/spawn policy;
   - surrender/arrest/trial/legal flow с bounded-инвариантами I.2 как базой.

---

## 6) Исторически выполнено (закрыто относительно аудита I.1)

Пункты ниже считались рисками/рекомендациями в I.1-аудите и к текущему срезу закрыты:

- runtime-диагностика переполнений registry/route;
- health snapshot по area;
- preflight validator для контентных locals;
- Stage I.2 policy-layer (локальный crime/alarm контур с role-aware реакцией).

---

## 7) Итоговая оценка

**Общая техническая оценка: высокая (8.5/10) для границ Stage I.2.**

Причины, почему не 10/10:
- остаются намеренные продуктовые ограничения I.2 (без global alarm/reinforcement/arrest pipeline);
- требуется более формализованный perf/runbook контур под production-нагрузки.

В рамках заявленных границ I.2 архитектура и runtime-контракт выглядят консистентно и готовы к эволюции в I.3+ без пересборки фундаментальных инвариантов.
