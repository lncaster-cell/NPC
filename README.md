# Ambient Life v2 (NPC) — README

> Обновлено: **2026-04-08**.

Репозиторий содержит канон и реализацию систем «живого мира» для NWN2.
С **2026-04-08** проект переведён в режим **полной переписи Daily Life-контура с нуля**: прежняя реализация `Daily Life v1` заархивирована, активная разработка ведётся как `Daily Life v2` по шагам «одна функция → проверка → следующая функция».

---

## 1) Что сейчас является source of truth

### Канон и инварианты
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`

**Текущий активный контур:**
- `Daily Life v2` — clean-room перепись с нуля (инкрементально, функция за функцией).
- `Daily Life v1` сохранён как legacy-архив и используется только как референс.

### Активные документы v2
1. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
2. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
3. `docs/runtime/42_DAILY_LIFE_V2_REPOSITORY_RESET_LOG_RU.md`
4. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

---

## 2) Текущий прогресс (на 2026-04-08)

## Что уже сделано

- **Daily Life v1** сохранён в архив для анализа и точечного переиспользования решений:
  - `archive/daily_life_v1_legacy/scripts/daily_life/`.
- Подготовлен чистый рабочий каталог для `Daily Life v2`:
  - `scripts/daily_life/README.md`
  - `scripts/daily_life/dl_v2_bootstrap.nss`
- Запущен отдельный план переписи:
  - `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`.

**Выход этапа:**
- утверждённый `v2 data-contract`;
- утверждённый `v2 event-pipeline`;
- утверждённый performance baseline (`budget`, `degradation`, `idempotency`).

- Нужно спроектировать v2-контур на основе канона и уроков v1 (до написания рабочего кода).
- Нужно последовательно собрать v2-runtime с проверками на каждом шаге.
- Нужно обновить связанные документы и runbook под новую стратегию разработки.

### Этап B — Runtime Skeleton
**Цель:** построить минимальный исполняемый каркас v2.

**Выход этапа:**
- `OnModuleLoad`, `OnAreaEnter`, `OnAreaHeartbeat`, `OnNPCSpawn`, `OnNPCUserDefined` в виде контролируемых заготовок;
- первая рабочая helper-функция;
- первый smoke step с PASS/FAIL-логами.

### Старт для активной разработки (ежедневный контур)
1. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` — операционная точка входа.
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md` — проектирование и пошаговый протокол v2.
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md` — базовая архитектура v2 и первый шаг реализации.
4. `docs/runtime/42_DAILY_LIFE_V2_REPOSITORY_RESET_LOG_RU.md` — зафиксированная подготовка репозитория к переписи.
5. `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md` — зафиксированное состояние и уроки v1.

### Код
- Legacy runtime v1: `archive/daily_life_v1_legacy/scripts/daily_life/`.
- Активный runtime v2 (чистый старт): `scripts/daily_life/`.

---

**Правило:** в одном PR только один функциональный шаг.

### Этап D — Acceptance + Owner Run
**Цель:** подтвердить работоспособность v2 на smoke и owner-run.

**Выход этапа:**
- обновлённый runbook;
- заполненный acceptance journal;
- финальный verdict `PASS/PARTIAL/FAIL` по owner-run.

---

## 5) Legacy-ссылка: Daily Life v1 (архивный контур)

Эта секция оставлена как историческая справка для сравнения поведения со старым контуром.
Активная разработка ведётся по v2-программе: `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`.

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
