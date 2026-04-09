# 52 — Daily Life Step 06 Acceptance Runbook (RU)

> Дата: 2026-04-09  
> Статус: ready for owner-run

## 1) Цель

Зафиксировать единый acceptance-порядок для текущего clean-room baseline (Steps 01–05) перед переходом к следующей волне расширения runtime.

## 2) Scope acceptance (текущий)

Проверяем только уже зафиксированные контракты:
1. module init contract;
2. lifecycle ingress (`OnSpawn`/`OnDeath` -> `OnUserDefined`);
3. area-tier bootstrap;
4. registry + bounded worker skeleton;
5. sleep-only resolver/materialization skeleton.

## 3) Preflight перед owner-run

1. Runtime scripts размещены в `scripts/daily_life/`.
2. Событийные хендлеры NWN2 подключены к актуальным скриптам:
   - `OnModuleLoad` -> `dl_load`
   - `OnSpawn` -> `dl_spawn`
   - `OnDeath` -> `dl_death`
   - `OnUserDefined` -> `dl_userdef`
   - `OnAreaEnter` -> `dl_a_enter`
   - `OnAreaExit` -> `dl_a_exit`
   - `OnAreaHeartbeat` -> `dl_a_hb`
3. На модуле включён runtime gate: `dl_enabled = 1`.

## 4) Acceptance-процедура (минимальный прогон)

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

## 5) PASS-критерий текущего этапа

Текущий этап считается пройденным, если:
- все smoke-проверки из раздела 4 дают ожидаемые значения;
- не обнаружено нарушения event-driven + area-centric модели;
- не добавлена логика вне согласованного scope (resolver/materialization skeleton only).

## 6) Что НЕ входит в этот acceptance

- Полный activity/materialization runtime.
- Anchor policy execution.
- Full fairness/profiling worker loop.
- Интеграционные сценарии с incident/trade/legal/travel системами.

## 7) Формат owner-отчёта (короткий)

1. Дата прогона.
2. PASS/FAIL по каждому smoke шагу (A..E).
3. Общий verdict: `GO Step 07+` или `HOLD`.
4. Если `HOLD` — конкретный блокер и требуемое действие.
