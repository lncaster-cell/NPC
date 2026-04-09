# Ambient Life (NPC) — README

> Обновлено: **2026-04-09**.

Репозиторий содержит канон, runtime-документацию и кодовую базу для контура Daily Life в NWN2.
Текущий режим разработки: **пошаговая перепись** (clean-room подход).

Ключевой рабочий digest: `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`.

---

## 1) Быстрый старт (что открыть в первую очередь)

1. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md` — текущая активная фаза и ближайшие микро-шаги.
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md` — протокол переписи.
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

### Активная зона
`scripts/daily_life/`

Текущие файлы:
- `dl_core_inc.nss` — module contract + lifecycle event ingress.
- `dl_load.nss` — init contract на `OnModuleLoad`.
- `dl_spawn.nss` / `dl_death.nss` — ingress lifecycle hooks.
- `dl_userdef.nss` — dispatcher для `OnUserDefined` (project-range `3000+`).
- `dl_smoke_ev.nss` — smoke-проверка init-contract.
- `dl_a_enter.nss` / `dl_a_exit.nss` — area-tier bootstrap hooks.
- `dl_a_hb.nss` — bounded area worker tick hook (`OnAreaHeartbeat`).
- `dl_smk_tier.nss` — smoke-проверка area-tier bootstrap.
- `dl_smk_sync.nss` — smoke-проверка dispatcher/resync contract.
- `dl_smk_work.nss` — smoke-проверка registry + worker cursor.
- `dl_res_inc.nss` — resolver/materialization skeleton (sleep-only, `early_worker`).
- `dl_smk_res.nss` — smoke-проверка sleep-resolver окна `22:00..06:00`.

### Архивная зона v1
- Legacy reference каталоги в текущем baseline не используются (clean-room направление от 2026-04-09).

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
