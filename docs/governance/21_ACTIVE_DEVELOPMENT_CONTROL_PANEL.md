# Ambient Life — Active Development Control Panel

Дата: 2026-04-11  
Статус: execution control panel (rewrite track)

---

## 0) Текущий статус

- Статус выполнения: **WAITING OWNER-RUN (runtime environment required)**.
- Решение владельца от **2026-04-09**: legacy-reference не восстанавливаем, разработка идёт clean-room с нуля.
- Активный runtime-каталог: `daily_life/`.
- Текущий микро-шаг: Step 06 `owner-run execution in NWN2 toolset/runtime`.
- UserDefined ID для текущего ingress: `3001` (project range `3000+`).
- Нумерация clean-room шагов перезапущена с **Step 01** после удаления прежнего кода.
- Режим исполнения: `один микро-шаг -> одна проверка -> документирование факта`.

Ключевые документы для текущей фазы:
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`

---

## 0.1) Owner resolution (applied)

- Тип решения: глобальный architectural direction от владельца.
- Решение: разработка Daily Life продолжается с нуля без восстановления legacy reference.
- Ограничение: pipeline остаётся event-driven + area-centric, без helper-first runtime в обход событийного контура.

## 1) Зафиксированное

### 1.1 Этап 0 — Alignment (завершён)
- Границы Daily Life зафиксированы.
- Event-driven + area-centric модель подтверждена.
- Per-NPC heartbeat-first ядро запрещено.

### 1.2 Шаг 1 baseline-runtime (завершён)
- Базовый include `dl_core_inc.nss` содержит module contract (`DL_IsRuntimeEnabled`, `DL_InitModuleContract`).
- Добавлен smoke `dl_smoke_ev.nss` для проверки init-contract.

### 1.3 Шаг 2 area-tier bootstrap (завершён)
- Добавлены area hooks `dl_a_enter.nss` / `dl_a_exit.nss`.
- Реализован tier bootstrap `DL_BootstrapAreaTier` с диапазоном `FROZEN/WARM/HOT` и правилом `HOT`, если в area есть игрок.
- Добавлен smoke `dl_smk_tier.nss` для фиксации tier после bootstrap.

### 1.4 Шаг 3 dispatcher/resync contract (завершён)
- Добавлен resync-контракт (`DL_RequestResync`, `DL_ProcessResync`) через существующий event-driven контур.
- Добавлен cleanup path для death-сценария (`DL_CleanupNpcRuntimeState`).
- Добавлен smoke `dl_smk_sync.nss`.

### 1.5 Шаг 4 registry + bounded worker skeleton (завершён)
- Добавлен registry-контракт (`DL_RegisterNpc`, `DL_UnregisterNpc`) для runtime-candidate NPC.
- Добавлен bounded worker tick `DL_RunAreaWorkerTick` с `budget/cursor` и scan-cap.
- Добавлен area heartbeat hook `dl_a_hb.nss`.
- Добавлен smoke `dl_smk_work.nss`.

### 1.6 Шаг 5 resolver/materialization skeleton (завершён)
- Добавлен include `dl_res_inc.nss` с первым resolver-срезом: только директива `SLEEP` для профиля `early_worker`.
- Зафиксировано owner-окно сна для этого шага: `22:00..06:00`.
- Materialization остаётся skeleton-уровнем (`dl_npc_mat_req`, `dl_npc_mat_tag`) без anchor/activity runtime.
- Добавлен smoke `dl_smk_res.nss`.

### 1.7 Шаг 6 acceptance runbook (завершён, owner-run pending)
- Подготовлен единый runbook: `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`.
- Зафиксированы preflight, последовательность smoke-проверок A..E и PASS-критерий этапа.
- Owner-run отмечен как следующий операционный шаг.

---

## 2) Текущая активная фаза

### Фаза A — Design Baseline (в работе)

DoD фазы:
- [ ] Утверждён минимальный data-contract.
- [ ] Утверждён event-pipeline hooks set (module/area/npc).
- [ ] Утверждён performance budget + degradation policy.
- [x] Реализован init-contract + event-ingress hooks + smoke.

---

## 3) Правила исполнения

1. Один PR = один микро-шаг.
2. На каждый шаг обязательно:
   - контракт,
   - минимальная реализация,
   - проверка,
   - синхронизация docs.
3. Нельзя смешивать resolver/materialization/worker в одном шаге без явного отдельного approval.
4. Нельзя добавлять новые digest-документы вместо обновления этого control panel и runtime-baseline/program.

---

## 4) Ближайшие этапы

1. Step 06: owner-run по acceptance runbook.
2. После PASS owner-run: переход к Step 07+.

---

## 5) Формат отчёта владельцу

- Что изменено (1–3 пункта).
- Чем проверено (точные команды).
- Что подтверждено фактом.
- Следующий микро-шаг.
