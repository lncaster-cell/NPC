# Ambient Life v2 — Active Development Control Panel

Дата: 2026-04-08  
Статус: active execution control panel (rewrite track)

---

## 0) Текущий статус

- Legacy-контур `Daily Life v1` архивирован в `archive/daily_life_v1_legacy/scripts/daily_life/`.
- Активный каталог `scripts/daily_life/` содержит v2 bootstrap + Step 01 runtime gate helper/smoke.
- Работа ведётся строго по протоколу `одна функция -> одна проверка -> запись результата`.

Ключевые документы:
1. `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`

---

## 1) Этап 0 — Alignment и контракт границ (зафиксировано)

Цель этапа: синхронизировать owner/agent-понимание границ Daily Life v2.

### 1.1 Scope (что входит)
- Вычисление директивы поведения (time/profile/context/override).
- Выбор anchor-policy и materialization в area-контуре.
- Обновление interaction состояния (service/dialogue gate).
- Tier execution HOT/WARM/FROZEN + resync/handoff.

### 1.2 Scope (что не входит)
- Legal truth/судебная квалификация.
- Macro trade/economy как самостоятельный движок.
- Полноформатный межгородской travel.
- Clan demography/aging/succession как отдельные truth-domain системы.

### 1.3 Архитектурная позиция
- Модель **event-driven + area-centric** подтверждена как обязательная.
- **Per-NPC heartbeat ядро запрещено** (допустимы только локальные событийные обработки).

### 1.4 Definition of Done (для каждого микро-шага)
Микро-шаг считается завершённым только если одновременно выполнено:
1. Зафиксирован контракт функции (вход/выход/гарантии/ограничения).
2. Реализация изолирована (одна функциональная единица, без скрытого scope-creep).
3. Есть проверка (smoke/diagnostic) с явно заданными кейсами.
4. Документация синхронизирована в том же PR/коммите.
5. Зафиксирован отчёт: что сделано, чем проверено, факт, следующий шаг.

---

## 2) Что делаем сейчас

### Фаза A — Design Baseline (активная)

Цель: закрыть базовые контракты до расширения runtime-логики.

Definition of Done фазы A:
- [ ] Утверждён минимальный data-contract v2.
- [ ] Утверждён event-pipeline v2 (module/area/npc hooks).
- [ ] Утверждён baseline по производительности (budget/degradation).
- [x] Для первой функции определён и реализован локальный smoke-check (Step 01).

---

## 3) Правила выполнения задач

1. В одном PR — один микро-шаг.
2. Каждый микро-шаг обязан содержать:
   - контракт функции;
   - минимальную реализацию;
   - проверку;
   - краткий отчёт по факту.
3. Нельзя параллельно вводить resolver/materialization/worker в одном изменении.
4. Документация обновляется в том же PR, что и код.

---

## 4) Операционный backlog (ближайшие шаги)

1. Закрыть инвентаризацию data-contract v2 (поля, enum, версии).
2. Утвердить event-pipeline hooks и бюджетные ограничения.
3. Ввести Step 02 helper (`OnModuleLoad` init contract).
4. После каждого шага фиксировать результат в control panel/runtime docs.

---

## 5) Короткий формат отчёта в каждом PR

- Что изменено (1–3 пункта).
- Чем проверено (конкретные команды/скрипты).
- Фактический результат.
- Следующий микро-шаг.

---

## 6) PR conflict resolution protocol (CLI-only)

Когда GitHub показывает `This branch has conflicts`, действуем только через терминал:

1. Проверка статуса конфликта:
   - `git status`
   - `git diff --name-only --diff-filter=U`
2. Если есть unmerged-файлы, открыть конфликтные блоки и убрать маркеры `<<<<<<<`, `=======`, `>>>>>>>` с ручным выбором итоговой версии.
3. Проверить, что merge-маркеров больше нет:
   - `rg -n "<<<<<<<|=======|>>>>>>>" -S`
4. Провести быструю проверку затронутых файлов (минимум: `git diff`).
5. Зафиксировать разрешение:
   - `git add <resolved_files>`
   - `git commit -m "merge: resolve PR conflicts"`

Текущий факт по ветке `work` (2026-04-08):
- `git status` -> clean
- `git diff --name-only --diff-filter=U` -> пусто
- активных merge-конфликтов в рабочем дереве нет.
