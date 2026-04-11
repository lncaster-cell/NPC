# PysukSystems (NPC) — README

> Обновлено: **2026-04-11**.

Репозиторий содержит канон, runtime-документацию и кодовую базу для контура Daily Life в NWN2.
Текущий режим разработки: **пошаговая перепись v2** (clean-room подход).

---

## 1) Единый канон маршрута (без дополнительных digest)

Единственный обязательный маршрут чтения:
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md` — доменные границы и целевая модель Daily Life.
2. `docs/runtime/06_SYSTEM_INVARIANTS.md` — инварианты runtime, которые нельзя нарушать.
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md` — минимальный baseline контрактов v2.
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md` — протокол шагов реализации.
5. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` — текущий активный шаг и execution-статус.

`docs/library/DOCUMENT_REGISTRY.md` используется как технический реестр структуры, но не как отдельный смысловой слой.

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

## 3) Состояние кода (факт на 2026-04-11)

### Активная зона v2
`daily_life/`

Текущие файлы clean-room контура:
- `dl_core_inc.nss` — базовые runtime-контракты и общие хелперы.
- `dl_a_enter.nss`, `dl_a_exit.nss`, `dl_a_hb.nss` — area ingress/egress/heartbeat hooks.
- `dl_res_inc.nss` — resolver-срез.
- `dl_spawn.nss`, `dl_load.nss`, `dl_death.nss`, `dl_userdef.nss` — lifecycle/event точки.
- `dl_smoke_ev.nss`, `dl_smk_tier.nss`, `dl_smk_sync.nss`, `dl_smk_work.nss`, `dl_smk_res.nss` — smoke-проверки шагов.

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
- новые/перемещённые документы внесены в `docs/library/DOCUMENT_REGISTRY.md`.
