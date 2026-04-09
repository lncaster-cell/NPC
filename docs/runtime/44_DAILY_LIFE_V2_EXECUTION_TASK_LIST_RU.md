# 44 — Daily Life v2 Execution Task List (RU)

> Дата: 2026-04-09  
> Статус: owner-facing execution plan  
> Назначение: зафиксировать полный список задач по построению контура Daily Life v2 на основе актуальной документации и выделить первый practically useful тестовый срез.

---

## 1) Цель документа

Собрать полный roadmap Daily Life v2 в одном месте:
- что именно нужно построить;
- в каком порядке это делать;
- где проходит граница между baseline, skeleton, controlled growth и acceptance;
- какой первый тестовый результат нужен владельцу.

Этот документ не вводит новый канон. Он превращает уже согласованный контур из `40/41/43` в исполнимый список задач.

---

## 2) Базовые принципы выполнения

1. Сначала документация и контракт, потом код.
2. Runtime растёт только внутри event-driven + area-centric контура.
3. Сначала pipeline skeleton, потом resolver/materialization.
4. В каждом шаге должны быть:
   - контракт,
   - минимальная реализация,
   - локальная проверка,
   - doc-sync.
5. Нельзя смешивать несколько крупных подсистем в одном шаге без отдельного owner approval.

---

## 3) Полный список задач по контуру Daily Life v2

### Фаза A — Design Baseline / Contract Approval

#### A1. Утвердить минимальный data-contract v2
Нужно зафиксировать минимальные поля для:
- module state;
- area tier state;
- NPC runtime state.

Подзадачи:
- A1.1. Подтвердить module locals (`dl2_enabled`, `dl2_contract_version`).
- A1.2. Подтвердить area locals (`dl2_area_tier`, `dl2_worker_cursor`, `dl2_worker_budget`).
- A1.3. Подтвердить минимальный набор NPC locals для следующей фазы.
- A1.4. Утвердить naming/version policy для v2 contract.

#### A2. Утвердить event-pipeline hooks set
Подзадачи:
- A2.1. Подтвердить `OnModuleLoad`.
- A2.2. Подтвердить `OnAreaEnter/OnAreaExit`.
- A2.3. Подтвердить `OnAreaHeartbeat`.
- A2.4. Подтвердить `OnNPCSpawn`.
- A2.5. Подтвердить `OnNPCUserDefined` как targeted resync/diagnostic hook.

#### A3. Утвердить performance budget / degradation policy
Подзадачи:
- A3.1. Зафиксировать `HOT/WARM/FROZEN` semantics.
- A3.2. Зафиксировать bounded jobs per tick.
- A3.3. Зафиксировать отсутствие фоновой симуляции в `FROZEN`.
- A3.4. Зафиксировать idempotency rule в пределах одного тика.

---

### Фаза B — Runtime Skeleton

#### B1. Step 02 — `OnModuleLoad` init contract
Подзадачи:
- B1.1. Нормализация contract version.
- B1.2. Инициализация module locals.
- B1.3. Smoke для init-contract.

#### B2. Step 03 — Area-tier bootstrap
Подзадачи:
- B2.1. Ввести area-tier init path.
- B2.2. Научить area входить в `HOT` по событию активации.
- B2.3. Научить area оставаться/переходить в `WARM/FROZEN` без полного worker-loop.
- B2.4. Smoke для tier bootstrap.

#### B3. Step 04 — Minimal dispatcher / resync hook
Подзадачи:
- B3.1. Добавить тонкий dispatcher path поверх event hooks.
- B3.2. Добавить controlled resync event shell.
- B3.3. Проверить binding integrity для event path.

---

### Фаза C — NPC Runtime Registration Layer

#### C1. NPC registration in pipeline
Подзадачи:
- C1.1. Ввести минимальный registration path для NPC.
- C1.2. Зафиксировать runtime-state marker.
- C1.3. Защититься от повторной регистрации.

#### C2. Worker cursor shell
Подзадачи:
- C2.1. Ввести bounded cursor iteration по area.
- C2.2. Не включать ещё full fairness scoring.
- C2.3. Проверить, что scheduler не уходит в per-NPC heartbeat модель.

---

### Фаза D — Resolver Foundation

#### D1. Directive contract
Подзадачи:
- D1.1. Зафиксировать минимальный набор директив для раннего v2.
- D1.2. Развести `directive` и `activity` как отдельные сущности.
- D1.3. Не смешивать `PUBLIC_PRESENCE` и `SOCIAL`.

#### D2. Schedule contract
Подзадачи:
- D2.1. Зафиксировать schedule template IDs.
- D2.2. Зафиксировать time-window interpretation.
- D2.3. Зафиксировать personal offset policy.

#### D3. Base context contract
Подзадачи:
- D3.1. Зафиксировать минимальный `base_id/base_state/base access` слой.
- D3.2. Не вводить ещё тяжёлую base-migration logic.
- D3.3. Подготовить место для будущего `BASE_LOST` path.

#### D4. Resolver chain skeleton
Подзадачи:
- D4.1. Ввести ordered rule chain.
- D4.2. Оставить расширяемые insertion points для future conditions.
- D4.3. Отдельно держать fallback path.

---

### Фаза E — Sleep Slice (первый practically useful тест)

> Цель владельца на раннем этапе: для первого тестирования достаточно, чтобы NPC умел спать.

#### E1. Sleep directive rule
Подзадачи:
- E1.1. Зафиксировать sleep window для целевого schedule template.
- E1.2. Ввести resolver rule для `SLEEP`.
- E1.3. Добавить smoke по времени окна сна.

#### E2. Sleep anchor contract
Подзадачи:
- E2.1. Зафиксировать `SLEEP` как отдельную anchor group.
- E2.2. Для первого теста использовать один sleep anchor type.
- E2.3. Для первой bed-механики использовать sleep pair из двух waypoint:
  - `approach` near bed;
  - `bed` on bed.

#### E3. Sleep execution for test stand
Подзадачи:
- E3.1. Сделать test stand: одна interior area, одна кровать, один NPC.
- E3.2. Реализовать move-to-approach.
- E3.3. Реализовать controlled snap/teleport на bed point.
- E3.4. Подключить sleep presentation/activity hook.
- E3.5. Зафиксировать минимальный PASS-критерий: NPC стабильно переходит в sleep state на кровати.

#### E4. Sleep diagnostics
Подзадачи:
- E4.1. Диагностика pair validity.
- E4.2. Диагностика approach reached.
- E4.3. Диагностика snap result.
- E4.4. Диагностика chosen activity/presentation path.

---

### Фаза F — Anchor / Activity Layer

#### F1. Anchor policy
Подзадачи:
- F1.1. `directive -> anchor_group`.
- F1.2. Выбор конкретной точки внутри группы.
- F1.3. Fallback на другой anchor того же типа.

#### F2. Activity layer
Подзадачи:
- F2.1. `directive + anchor context -> activity`.
- F2.2. Не смешивать activity layer с resolver.
- F2.3. Подключить initial custom activity source policy.

---

### Фаза G — Materialization Layer

#### G1. Initial materialization plan
Подзадачи:
- G1.1. `directive + anchor -> placement plan`.
- G1.2. Развести instant placement / local walk / soft hide.
- G1.3. Не ломать visual integrity перед глазами игрока.

#### G2. Controlled visual activation
Подзадачи:
- G2.1. Подготовка materialization в `WARM`.
- G2.2. Полный local runtime в `HOT`.
- G2.3. Без фоновой жизни в `FROZEN`.

---

### Фаза H — Dialogue / Service Refresh

#### H1. Dialogue mode
Подзадачи:
- H1.1. `directive -> dialogue mode`.
- H1.2. Базовая синхронизация с повседневной директивой.

#### H2. Service availability
Подзадачи:
- H2.1. `directive -> service_available`.
- H2.2. Отдельный path для service NPC.

---

### Фаза I — Base / Fallback / Absence Layer

#### I1. Base validity
Подзадачи:
- I1.1. Проверка доступности базы.
- I1.2. Реакция на `BASE_INVALID/BASE_LOST`.

#### I2. Fallback chain
Подзадачи:
- I2.1. Fallback на другой anchor того же типа.
- I2.2. Fallback на `IDLE_BASE/RETURN_BASE`.
- I2.3. Крайний fallback на `UNASSIGNED/ABSENT`.

---

### Фаза J — External Overrides / Resync / Handoff

#### J1. Override input shell
Подзадачи:
- J1.1. Ввести read-only override input adapter.
- J1.2. Не строить ad-hoc subsystem под отдельные инциденты.

#### J2. Resync
Подзадачи:
- J2.1. Временной resync.
- J2.2. Context-change resync.
- J2.3. Tier-change resync.

#### J3. Handoff
Подзадачи:
- J3.1. Vacancy/role handoff shell.
- J3.2. Не смешивать handoff с core resolver.

---

### Фаза K — Worker / Fairness / Profiling

#### K1. Full bounded worker
Подзадачи:
- K1.1. Cursor + budget.
- K1.2. Fairness loop.
- K1.3. Minimal profiling counters.

#### K2. Observability
Подзадачи:
- K2.1. Trace points по pipeline.
- K2.2. Degradation counters.
- K2.3. Binding integrity checks.

---

### Фаза L — Acceptance

#### L1. Runbook
Подзадачи:
- L1.1. Owner-facing runbook.
- L1.2. Test stand instructions.
- L1.3. Failure symptoms and recovery notes.

#### L2. Owner-run scenarios
Минимум:
- L2.1. Area enter activation.
- L2.2. Sleep scenario.
- L2.3. Basic work scenario.
- L2.4. Tier transition scenario.
- L2.5. Controlled resync scenario.

#### L3. PASS protocol
Подзадачи:
- L3.1. Зафиксировать фактические PASS/FAIL.
- L3.2. Утвердить следующий growth slice.

---

## 4) Приоритеты исполнения

### P0 — Обязательный старт
1. A1. Data-contract approval.
2. A2. Event-pipeline hooks approval.
3. A3. Budget/degradation approval.
4. B1. `OnModuleLoad` init contract.
5. B2. Area-tier bootstrap.
6. B3. Minimal dispatcher hook.

### P1 — Первый practically useful результат
7. C1. NPC registration.
8. D1/D2. Directive + schedule contracts.
9. E1. Sleep directive rule.
10. E2. Sleep anchor pair contract.
11. E3. Sleep execution on test stand.

### P2 — После первого sleep PASS
12. F1/F2. Anchor + activity layer.
13. G1/G2. Materialization layer.
14. H1/H2. Dialogue/service refresh.
15. I/J/K. Base/fallback/override/worker maturity.
16. L. Acceptance / runbook / owner-run.

---

## 5) Первый тестовый результат, который нужен владельцу

Для первой practically useful проверки достаточно следующего:

1. Есть один NPC с типовым schedule template.
2. Есть одна interior test area.
3. В area есть кровать и sleep pair из двух waypoint.
4. В sleep window resolver выдаёт `SLEEP`.
5. NPC доходит до `approach` и стабильно переводится на bed-point.
6. Sleep state/presentation подтверждены фактом.

Это считается первым meaningful milestone для ранней v2-ветки.

---

## 6) Что пока сознательно не является приоритетом

До первого PASS по sleep test stand не делать как обязательный фронт:
- полный base-system;
- law/city response integration;
- trade/service richness;
- travel/domain logic;
- clan/legal/economy truth-domain expansion;
- сложный respawn/population handoff.

---

## 7) Итог

Полный контур Daily Life v2 должен строиться в таком порядке:

1. contract + event pipeline;
2. runtime skeleton;
3. NPC registration + bounded scheduler shell;
4. resolver foundation;
5. первый practically useful sleep slice;
6. anchor/activity/materialization;
7. dialogue/service/base/override/resync/handoff;
8. worker maturity + observability;
9. owner-run + acceptance.

Ближайшая owner-ценность при этом проста:
**сначала научить NPC спать, а уже потом расширять контур дальше.**
