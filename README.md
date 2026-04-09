# Ambient Life v2 (NPC) — README

> Обновлено: **2026-04-09**.

Репозиторий содержит канон, runtime-документацию и кодовую базу для контура Daily Life в NWN2.
Текущий режим разработки: **пошаговая перепись v2** (clean-room подход).

Ключевой рабочий digest: `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`.

---

## 1) Быстрый старт (что открыть в первую очередь)

1. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` — текущая активная фаза и ближайшие микро-шаги.
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md` — протокол переписи v2.
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md` — минимальный baseline контрактов и пайплайна.
4. `docs/library/DOCUMENT_REGISTRY.md` — карта всей документации по слоям.

---

## 2) Source of Truth и границы системы

### Канонические опоры
- `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- `docs/runtime/06_SYSTEM_INVARIANTS.md`

### Что входит в Daily Life runtime
- directive-resolver (time/profile/context/override),
- anchor/materialization,
- interaction refresh (service/dialogue),
- tier execution HOT/WARM/FROZEN,
- resync/handoff.

### Что НЕ входит в ядро Daily Life
- legal truth и судебная квалификация,
- макроэкономика и полный trade-engine,
- полноформатный travel runtime,
- clan demography/aging/succession как самостоятельные truth-domain подсистемы.

---

## 3) Состояние кода (факт на 2026-04-09)

### Активная зона v2
`scripts/daily_life/`

Текущие файлы:
- `dl_v2_runtime_inc.nss` — helper-контракт `DL2_IsRuntimeEnabled()`.
- `dl2_smoke_step_01.nss` — smoke-проверка helper в 3 базовых кейсах.

### Legacy v1 code
Удалён из репозитория 2026-04-09 после извлечения reference-констант в `scripts/daily_life/dl_v2_activity_animation_constants_inc.nss`.

---

## 4) Протокол микро-шага (обязательный)

Каждый шаг выполняется строго циклом:
1. План шага (1 функция/1 участок).
2. Изменение кода.
3. Проверка (команда + факт PASS/FAIL).
4. Док-синхронизация в этом же коммите.
5. Короткий отчёт владельцу: что сделано, чем проверено, следующий шаг.

---

## 5) Документационный DoD

Перед завершением любого шага убедиться, что:
- обновлён профильный документ (runtime/canon/governance),
- изменённые маршруты отражены в `docs/entry/12_MASTER_PLAN.md` и/или `docs/entry/00_PROJECT_LIBRARY.md`,
- новые/перемещённые документы внесены в `docs/library/DOCUMENT_REGISTRY.md`,
- запись о синхронизации добавлена в `docs/governance/26_AGENT_COMMUNICATION_LOG.md` (для мультиагентной прозрачности).
