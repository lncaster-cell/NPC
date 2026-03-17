# Ambient Life v2 — Инвентаризация механик и карта зависимостей

Дата: 2026-03-17  
Статус: архитектурная карта зависимостей (cross-domain), уточняющая реальные границы систем.

---

## 1) Цель документа

Этот документ фиксирует систему **не по "папкам доменов"**, а по реальным механикам:
- где находится источник истины (долгая память мира);
- что является runtime-вычислением;
- какие связи прямые, а какие косвенные;
- где границы уже корректны, а где нужно дополнительное разделение.

Документ используется как канонический reference для архитектурной декомпозиции и приоритизации рефакторинга.

---

## 2) Два класса систем: World Memory vs Runtime

## 2.1 Long-term memory мира (персистентная истина)

Это состояние, которое должно переживать reload/рестарт, участвовать в долгой кампании и не зависеть от тактических флагов текущей сцены.

Сюда относятся:
1. **Legal truth и правовой профиль поселений** (что законно, кто имеет право применять силу, какие санкции допустимы).
2. **Свидетельские и кейсовые записи** (инцидент как юридический факт, а не "кто сейчас агрится").
3. **Ownership/титулы/доступы** (personal/clan/public).
4. **Клановая непрерывность** (род, линия преемственности, передача статусов и активов).
5. **Aging/succession** (долгая демография ключевых линий).
6. **Глобальная карта перемещений и доступов** (travel graph, портовые права, ограничения направлений).
7. **Макро-состояние города/экономики** (дефициты, устойчивость, стадии кризиса).

## 2.2 Runtime системы (операционное исполнение)

Это состояние, которое управляет текущей сценой/тиком и может быть восстановлено из контента и world-state.

Сюда относятся:
1. **Area lifecycle / dispatch / queue / tier processing**.
2. **NPC routine pipeline** (schedule/route/transition/sleep/activity).
3. **Blocked/disturbed recovery**.
4. **City alarm FSM и runtime assignments** (shelter/arsenal/war-post и т.д.).
5. **Population materialization/respawn policy** как операционный механизм заполнения дефицита.
6. **Диагностика/health counters/backpressure метрики**.

Правило границы: runtime может читать world memory и публиковать факты, но не должен подменять долгую истину мира своими локальными флагами.

---

## 3) Инвентаризация механик и системные границы

| Система | Класс | Главная ответственность | Прямые входы | Прямые выходы | Критичные зависимости |
|---|---|---|---|---|---|
| NPC Routine (schedule/route/sleep/activity) | Runtime | Повседневное поведение NPC | Контент маршрутов, area links, slot events | Position/step updates, локальные события pipeline | Transition, blocked/disturbed, dispatch |
| Transition Layer | Runtime | Безопасные переходы по area graph | Route step + area links | Материализация NPC в целевой area, route progress | Area topology contracts |
| Blocked/Disturbed | Runtime | Локальное восстановление поведения | OnBlocked/OnDisturbed hooks | Resume/replan events | Routine pipeline |
| City Alarm FSM | Runtime | Эскалация/деэскалация городской тревоги | Crime producers, witness signal (нормализованный) | Desired/live alarm state, role assignments | Legal profile read model, dispatch caps |
| Population Respawn/Materialization | Runtime (с read-only world policy) | Восстановление unnamed population по дефициту | City targets/deficit, area spawn nodes | Spawn/materialization events, budget consumption | City state, performance caps |
| Legal Truth / Law Profile | World Memory | Нормативная квалификация и легитимность ответа | Settlement law config, governance state | Legal classification, allowed procedures | Witness/case system, city response policy |
| Witness & Case Intake | World Memory | Фиксация юридического факта инцидента | Incident facts от runtime + actor identities | Case records, legal triggers | Legal truth, court pipeline |
| Property / Ownership | World Memory | Титул, права доступа, делегирование | Ownership actions, clan authority | Access decisions, legal consequences | Clan system, legal truth |
| World Travel Graph | World Memory | Каноническая связность регионов и gate-условия | Map content, faction/permit constraints | Allowed route set для travel runtime | Property (доступ к assets), trade, law |
| Trade / City Macro State | World Memory | Экономическое состояние и кризисные стадии | Supply/demand drivers, security signals | City modifiers, policy pressure | Alarm outcomes, travel, governance |
| Clan / Aging / Succession | World Memory | Долгая преемственность субъектов и активов | Time progression, death/transfer events | New authority lines, inheritance effects | Property, legal truth |

---

## 4) Матрица влияний (кто на кого влияет)

Обозначения:
- **D (direct)** — прямой контракт/вызов/событие;
- **I (indirect)** — влияние через агрегированное состояние/политику;
- пусто — системной зависимости нет.

| From \ To | Routine | Transition | Blocked | Alarm FSM | Respawn | Legal | Witness/Case | Property | Travel | Trade/City | Clan/Aging |
|---|---|---|---|---|---|---|---|---|---|---|---|
| Routine | — | D | D | I | I |  |  |  |  | I |  |
| Transition | D | — |  |  |  |  |  |  |  |  |  |
| Blocked | D | I | — | I |  |  |  |  |  |  |  |
| Alarm FSM | I |  | D | — | D | I | I |  |  | D |  |
| Respawn | I |  |  | I | — |  |  |  |  | I |  |
| Legal |  |  |  | D |  | — | D | D | I | D | D |
| Witness/Case |  |  |  | D |  | D | — | I |  | I | I |
| Property |  |  |  | I |  | D | I | — | D | I | D |
| Travel |  |  |  | I | I | I |  | I | — | D | I |
| Trade/City | I |  |  | D | D | I | I | I | D | — | I |
| Clan/Aging |  |  |  |  |  | D | I | D | I | I | — |

---

## 5) Где границы нужно ужесточить

1. **Alarm FSM ↔ Legal**  
   Сейчас риск смешения "тактической тревоги" и "юридического статуса". Нужен явный anti-corruption слой: `incident_fact -> legal_classification -> enforcement_policy`.

2. **Respawn ↔ Macro Economy**  
   Respawn не должен скрывать экономический/безопасностный коллапс. Нужен явный ceiling: respawn решает только "операционный минимум населения", а не макро-стабильность города.

3. **Routine ↔ Travel/Property**  
   Локальные маршруты NPC не должны напрямую менять права доступа и мировые travel-permits. Только через world-memory транзакции.

4. **Clan/Aging ↔ Runtime NPC identity**  
   Runtime-идентификаторы акторов нельзя использовать как долгую истину родовых линий; нужен стабильный world-id субъектов и отдельная проекция в runtime.

---

## 6) Минимальная целевая декомпозиция (рекомендуемая)

## 6.1 Слой A — Runtime Orchestration
Компоненты: lifecycle, dispatch, routine, transition, blocked/disturbed, alarm FSM, respawn materialization.

Контракт слоя: принимает policy/read-model из world memory, исполняет bounded pipeline, эмитит нормализованные факты.

## 6.2 Слой B — World Memory & Governance
Компоненты: legal truth, witness/case, property, travel graph, trade/city macro, clan/aging/succession.

Контракт слоя: хранит долгую истину и принимает изменения только через валидированные доменные команды/процедуры.

## 6.3 Слой C — Integration (Event Translation)
Компоненты: anti-corruption адаптеры между runtime event bus и world-memory командами.

Контракт слоя: никакой доменной логики "по месту" в runtime hooks; только нормализация, дедупликация, маршрутизация.

---

## 7) Практические правила для дальнейших изменений

1. Любая новая механика сначала помечается как **World Memory** или **Runtime** (запрещён "гибрид без границы").
2. Для каждой зависимости явно фиксируется тип: `direct` или `indirect`.
3. Если runtime должен "что-то решить по закону", он не решает сам: он запрашивает legal read-model/policy.
4. Если world-memory событие меняет поведение NPC, это делается через интеграционный слой и явное событие в runtime bus.
5. KPI на устойчивость архитектуры:
   - zero runtime-only legal truth;
   - zero direct writes в world memory из low-level runtime hooks;
   - полная трассируемость `incident -> case -> enforcement -> outcome`.

---

## 8) Связь с каноническими документами

- Общий high-level канон: `docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`.
- Навигационный индекс: `docs/12_MASTER_PLAN.md`.
- Runtime-детализация: `docs/12B_RUNTIME_MASTER_PLAN.md`.
- Доменные каноны world-memory: `12A`, `12C`, `12D`, `12E`, `13`, `14`.

Этот документ не заменяет доменные тома; он фиксирует **поперечную архитектурную карту зависимостей** и границу между долгой памятью мира и runtime исполнением.
