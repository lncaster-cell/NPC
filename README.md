# Ambient Life v2 (NPC) — README

> Обновлено: **2026-04-08**.

Репозиторий переведён в режим **переписи Daily Life с нуля (v2)**.
Старый runtime (`v1`) сохранён как reference-архив и не используется как активная кодовая база.

---

## 1) Что сейчас является source of truth

### Канон и инварианты
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`

### Ретроспектива и уроки v1
1. `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
2. `archive/daily_life_v1_legacy/scripts/daily_life/`

### Активные документы v2
1. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
2. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
3. `docs/runtime/42_DAILY_LIFE_V2_REPOSITORY_RESET_LOG_RU.md`
4. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

---

## 2) Чёткий план разработки v2

Ниже — основной рабочий план. Любая задача должна попадать в один из этапов.

### Этап A — Design Baseline (сейчас активен)
**Цель:** спроектировать минимальный, чистый и управляемый контур до написания runtime-логики.

**Выход этапа:**
- утверждённый `v2 data-contract`;
- утверждённый `v2 event-pipeline`;
- утверждённый performance baseline (`budget`, `degradation`, `idempotency`).

**Проверка готовности этапа:**
- есть явный список locals/состояний/событий;
- нет противоречий с каноном и инвариантами;
- есть план первого микро-шага кода (`1 функция + smoke`).

### Этап B — Runtime Skeleton
**Цель:** построить минимальный исполняемый каркас v2.

**Выход этапа:**
- `OnModuleLoad`, `OnAreaEnter`, `OnAreaHeartbeat`, `OnNPCSpawn`, `OnNPCUserDefined` в виде контролируемых заготовок;
- первая рабочая helper-функция;
- первый smoke step с PASS/FAIL-логами.

### Этап C — Functional Growth (строго по одной функции)
**Цель:** последовательно добавлять функциональность без «больших прыжков».

**Порядок блоков:**
1. runtime enabled/contract guard;
2. profile/state resolver;
3. anchor selection;
4. materialization;
5. worker fairness + budget.

**Правило:** в одном PR только один функциональный шаг.

### Этап D — Acceptance + Owner Run
**Цель:** подтвердить работоспособность v2 на smoke и owner-run.

**Выход этапа:**
- обновлённый runbook;
- заполненный acceptance journal;
- финальный verdict `PASS/PARTIAL/FAIL` по owner-run.

---

## 3) Микро-план (ближайшие шаги)

- [ ] **Шаг 1:** `DL2_IsRuntimeEnabled()` + `dl2_smoke_step_01.nss`
- [ ] **Шаг 2:** контракт `dl2_profile_id` и валидация профиля
- [ ] **Шаг 3:** базовый state machine (`IDLE/TRANSIT/ACTIVE/BLOCKED`)
- [ ] **Шаг 4:** минимальный area worker tick (без materialization)
- [ ] **Шаг 5:** безопасная materialization-заготовка с ограничениями

Каждый шаг закрывается только после фактической проверки и записи результата.

---

## 4) Правила реализации (обязательные)

1. **Один шаг = одна функция/модуль** (без смешивания нескольких подсистем).
2. Сначала контракт, потом код, потом проверка, потом отчёт.
3. Если меняется логика — синхронно обновляется документация.
4. Никакой избыточной логики: код должен быть читаемым, коротким, предсказуемым.
5. Любая неоднозначность фиксируется в control panel до следующего кодового шага.

---

## 5) Структура репозитория для текущей фазы

- Активный v2 workspace: `scripts/daily_life/`
- Legacy v1 archive: `archive/daily_life_v1_legacy/scripts/daily_life/`
- Общий реестр документации: `docs/library/DOCUMENT_REGISTRY.md`

---

## 6) Формат отчётности по каждому шагу

В каждом PR/коммите обязательно:
1. Что изменено (1–3 пункта).
2. Чем проверено (точные команды/скрипты).
3. Что подтверждено фактом.
4. Следующий микро-шаг.

Это основной анти-хаос контракт разработки.
