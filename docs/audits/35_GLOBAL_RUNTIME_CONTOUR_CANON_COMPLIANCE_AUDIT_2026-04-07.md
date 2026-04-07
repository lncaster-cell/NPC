# Global Audit — Runtime Contour Compliance (docs/canon/research)

Дата: 2026-04-07  
Статус: completed (static audit, code+docs)  
Контур: `scripts/daily_life/*` + профильные runtime/canon/research документы.

---

## 1) Цель аудита

Проверить runtime-контур Daily Life v1 на соответствие:
1. runtime-документации (implementation/pipeline/runbook/SoT);
2. канону (`12B vNext canon`, ruleset Rev1);
3. исследовательским рекомендациям по NWN2-ограничениям (event-driven, bounded runtime, degrade).

Важно: это **инспекционный аудит** (без owner toolset run), поэтому вердикт про production-ready не выносится.

---

## 2) Использованный нормативный базис

### 2.1 Runtime/SoT
- `docs/runtime/12B_DAILY_LIFE_V1_SOURCE_OF_TRUTH.md`
- `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md`
- `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md`

### 2.2 Canon
- `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`

### 2.3 Research constraints
- `docs/research/19_AI_RESEARCH_ENGINE_CONSTRAINTS_RU.md`

### 2.4 Кодовой срез
- lifecycle/event hooks: `dl_npc_onspawn`, `dl_npc_onud`, `dl_npc_ondeath`, producer bridges;
- orchestration: `dl_npc_hooks_inc`, `dl_area_inc`, `dl_worker_inc`, `dl_resync_inc`;
- materialization/runtime state: `dl_materialize_inc`, `dl_interact_inc`, `dl_activity_inc`.

---

## 3) Методика

1. Сверка «документ заявляет X» ↔ «в коде есть/нет X».
2. Отдельная оценка по трём слоям:
   - L1: runtime contract compliance;
   - L2: canon boundary compliance;
   - L3: research recommendation compliance.
3. Классификация отклонений:
   - **Critical** — ломает запуск/контур;
   - **High** — даёт риск ложного поведения;
   - **Medium** — архитектурный долг, не блокер Milestone A;
   - **Low** — улучшение наблюдаемости/гигиены.

---

## 4) Вердикт по слоям соответствия

## 4.1 L1 — Runtime docs compliance: **Mostly compliant**

Подтверждено:
- Event-driven entry path через NPC hooks и централизованный `OnUserDefined` dispatcher.
- Bounded area worker с tier-gate (`HOT/WARM/FROZEN`) и budget-проходом.
- Resync-путь с нормализацией и приоритезацией причин.
- Runbook-логика preflight (обязательные hook bindings) соответствует фактической критической зависимости контура.

Ограничение:
- Полная проверка A–G остаётся зависимой от owner/toolset run; в репозитории статическая инспекция не заменяет факт smoke-подтверждения.

## 4.2 L2 — Canon compliance: **Compliant (в границах v1)**

Подтверждено:
- Контур не уходит в per-NPC heartbeat как основной механизм.
- Нет зависимости от `DelayCommand()`-сетки как core scheduler.
- Daily Life остаётся в роли routine/materialization/resync слоя, не перетягивает legal/trade/travel/clan.
- Разделение lifecycle hooks и producer hooks соблюдено (thin bridge вместо heavy логики).

Наблюдение:
- Эксплуатационная часть (правильная настройка toolset bindings) фактически стала главным «gate» соответствия канону в реальном запуске.

## 4.3 L3 — Research recommendation compliance: **Partially compliant**

Подтверждено:
- Event-driven и bounded runtime подход реализован.
- Debounce/cooldown для noisy hooks реализован.
- Есть базовые деградационные механизмы (budget limit, deferred через pending-resync).

Не закрыто полностью:
- Нет явного эксплуатационного пакета метрик уровня queue depth / dropped-deferred counters / avg-peak dispatch time.
- Не оформлен явный SLO-профиль цикла Daily Life v1 в runtime-доках как отдельный измеримый контракт.

---

## 5) Найденные риски и несоответствия

### R-35-01 (Critical): Binding integrity risk
Симптом: при неполной привязке hooks в Toolset контур выглядит «нерабочим», хотя кодовая архитектура корректна.

Рекомендация:
- Сделать binding checklist обязательным gate перед любым smoke verdict;
- фиксировать preflight результат в acceptance journal вместе с run ID.

### R-35-02 (High): Неполная наблюдаемость деградации
Симптом: есть budget/fairness механика, но нет явных числовых counters по dropped/deferred/latency.

Рекомендация:
- Ввести минимальные модульные счётчики Daily Life v1 (без расширения scope на весь проект):
  1) `worker_candidates`;
  2) `worker_processed`;
  3) `worker_deferred` (кандидаты минус обработанные);
  4) `resync_reason_count[*]`.

### R-35-03 (Medium): SLO не формализован как runtime-контракт
Симптом: в research и master-plan есть направление на SLO/backpressure, но для Daily Life v1 нет короткой таблицы target/threshold.

Рекомендация:
- Добавить micro-SLO раздел в runtime docs:
  - max NPC processed per heartbeat by tier;
  - допустимый deferred backlog (операционное пороговое значение);
  - expected recovery ticks после AREA_ENTER.

### R-35-04 (Low): Разрозненность owner-facing проверок
Симптом: технические требования к preflight есть в runbook, но владельцу удобнее иметь короткий чеклист «перед кнопкой запуска» в одном месте.

Рекомендация:
- Поддерживать синхронность `35_DAILY_LIFE_V1_OWNER_PRESENTATION_RU.md` и smoke runbook единым блоком preflight.

---

## 6) Приоритетный action-plan (мелкие шаги)

## Wave 1 (обязательный, без расширения scope)
1. Перед каждым owner-run фиксировать preflight hooks-check + run ID в acceptance journal.
2. Запустить A–G по runbook и закрыть статусами `PASS/PARTIAL/FAIL` с smoke snapshot.
3. Для каждого `PARTIAL/FAIL` — точечная причина и корректирующий патч без добавления новой подсистемы.

## Wave 2 (наблюдаемость и эксплуатация)
4. Добавить минимальные counters worker/resync в существующий trace-путь.
5. Документировать micro-SLO таблицу Daily Life v1 в runtime-доках.
6. Сверить формулировки owner-facing документа с техническим runbook после первого подтверждённого owner-run.

---

## 7) Финальный вывод

1. **Runtime-контур Daily Life v1 в коде в целом соответствует документации и канону** (event-driven, bounded, area-centric).  
2. Основной практический риск — **операционная конфигурация hooks в Toolset**, а не архитектурный изъян ядра.  
3. По исследовательским рекомендациям нужен следующий шаг зрелости: **метрики деградации + micro-SLO**, чтобы доказуемо управлять производительностью и стабильностью в owner-run цикле.
