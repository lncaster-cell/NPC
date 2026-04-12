# 52 — Daily Life Step 06 Acceptance Runbook (RU)

Execution results are tracked only in acceptance journal.

## 1) Scope acceptance (baseline)

Проверяются только foundation-контракты:
1. module init contract;
2. lifecycle ingress (`OnSpawn`/`OnDeath` -> `OnUserDefined`);
3. area-tier bootstrap;
4. registry + bounded worker skeleton;
5. baseline resolver/materialization skeleton.

## 2) Preflight перед baseline owner-run

1. Runtime scripts размещены в `daily_life/`.
2. Событийные хендлеры NWN2 подключены к актуальным скриптам:
   - `OnModuleLoad` -> `dl_load`
   - `OnSpawn` -> `dl_spawn`
   - `OnDeath` -> `dl_death`
   - `OnUserDefined` -> `dl_userdef`
   - `OnAreaEnter` -> `dl_a_enter`
   - `OnAreaExit` -> `dl_a_exit`
   - `OnAreaHeartbeat` -> `dl_a_hb`
3. На модуле включён runtime gate: `dl_enabled = 1`.
4. При необходимости chat-debug контролируется модульным флагом `dl_chat_log`.

## 3) Baseline acceptance-процедура (минимальный прогон)

### A. Module contract
- Запустить `dl_smoke_ev`.
- Ожидаемый факт: `dl_smoke_ev_runtime_enabled == 1`.

### B. Area-tier bootstrap
- Запустить `dl_smk_tier` в целевой area.
- Ожидаемый факт: `dl_smk_tier_value` в диапазоне `WARM/HOT` (не `FROZEN` при активной area).

### C. Dispatcher/resync
- Запустить `dl_smk_sync`.
- Ожидаемый факт:
  - `dl_smk_sync_before == 1`
  - `dl_smk_sync_after == 0`

### D. Registry + bounded worker
- Запустить `dl_smk_work`.
- Ожидаемый факт:
  - `dl_smk_work_tik >= 1`
  - `dl_smk_work_cur >= 0`

### E. Resolver/materialization skeleton
- Запустить `dl_smk_res`.
- Ожидаемый факт:
  - `dl_smk_res_05 == 1`
  - `dl_smk_res_06 == 0`
  - `dl_smk_res_21 == 0`
  - `dl_smk_res_22 == 1`
  - `dl_smk_res_23 == 1`
  - `dl_smk_res_mat == 1`

## 4) PASS-критерий baseline-этапа

Baseline-этап считается пройденным, если:
- все smoke-проверки из раздела 3 дают ожидаемые значения;
- не обнаружено нарушения event-driven + area-centric модели;
- не добавлена логика вне согласованного foundation-scope.

## 5) Формат owner-отчёта (короткий)

1. Дата прогона.
2. PASS/FAIL по каждому smoke шагу (A..E).
3. Общий verdict: `GO next agreed slice` или `HOLD`.
4. Если `HOLD` — конкретный блокер и требуемое действие.
