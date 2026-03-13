# Task Board
<!-- DOCSYNC:2026-03-12 -->
> Documentation sync: 2026-03-12. This file was reviewed and aligned with the current repository structure.


## P0

- [x] Stage I.2: crime/alarm escalation поверх disturbed foundation.
- [x] Диагностика отказа `AL_RegisterNPC` при достижении `AL_MAX_NPCS`.
- [x] Унифицированная схема подключения `al_area_tick` для разных шаблонов модулей (см. `INSTALLATION.md`, разделы 2.2.1 и 2.3).

## P1

- [x] Оффлайн/операторский preflight-валидатор маршрутов (`al_step` range, step continuity, duplicates, area consistency).
- [x] Шаблон контент-подготовки sleep-точек (`_approach`/`_pose`) в `docs/SLEEP_MARKUP_TEMPLATE.md`.
- [x] Операторский гайд по linked areas (`al_link_*`) и warm-policy.
- [x] Автоматизированный preflight-валидатор linked-графа (`al_link_count`, `al_link_*`, дубликаты, самоссылки, превышение degree-порогов).

## P2

### High-impact perf (queue/overflow/drain/registry)

- [ ] Dispatch queue: снизить пиковую `al_dispatch_q_len` в S100/S120 без роста latency drain.
- [ ] Overflow triage: устранить причины роста `al_dispatch_q_overflow`, `al_reg_overflow_count`, `al_route_overflow_count` на стресс-профилях.
- [ ] Drain stability: удерживать `al_dispatch_ticks_to_drain` в целевых окнах S80/S100/S120.
- [ ] Registry compaction: сократить `al_reg_compact_calls(_window)` без регрессии throughput.

### Low-impact

- [x] Сервисный валидатор locals (NPC/waypoints/areas) для контент-команды.
- [ ] Профилирование производительности на сценах с высокой плотностью NPC (по `docs/PERF_RUNBOOK.md`).


## Регулярная QA-практика

- Smoke-check: см. раздел `Runbook: Area Health Snapshot` ниже.
- Python preflight-утилиты удалены из репозитория; валидация маршрутов/locals/linked-графа выполняется внешними инструментами команды.
- Perf-check: см. `docs/PERF_RUNBOOK.md` (минимум Scene M для каждого заметного изменения ambient-life).
- Для каждого perf-PR обязательна оценка: какую часть `AL_AreaTick` затрагивает изменение, и какой метрикой подтверждается эффект.
- Для правок в route/registry/dispatcher: обязательный PR-отчёт «до/после» по шаблону из `docs/PERF_RUNBOOK.md`.
- High-impact perf-priority: `scripts/ambient_life/al_area_inc.nss`, `scripts/ambient_life/al_registry_inc.nss`, `scripts/ambient_life/al_route_inc.nss`, `scripts/ambient_life/al_dispatch_inc.nss`.
- Gate (core): изменения в high-impact файлах считаются неполными без perf-сводки по `docs/PERF_PROFILE.md`.
- Для любого PR с изменениями в `scripts/ambient_life/al_*` обязательный чек: **Perf gate passed** (CI `Ambient Life Perf Gate` + machine-readable отчёт `docs/perf/baselines/perf_gate_report.csv|.json`).

## Runbook: Area Health Snapshot (операторский минимум)

См. также: `docs/LINKED_GRAPH_OPERATIONS.md` (правила linked-графа и warm-policy).

1. Включите debug на area: `al_debug=1` (опционально, только для delta-логов).
2. Дождитесь минимум 2-3 тиков `AL_AreaTick`.
3. Проверьте locals area:
   - `al_h_npc_count` ~= ожидаемому числу активных NPC,
   - `al_h_tier` и `al_h_slot` соответствуют текущей фазе,
   - `al_h_reg_overflow_count=0` и `al_h_route_overflow_count=0` в штатном контенте,
   - `al_h_recent_resync` в норме низкий и растёт в окне только при реальных RESYNC.
4. Интерпретируйте обязательные пороги (`al_dispatch_q_len`, `al_dispatch_q_overflow`, `al_reg_overflow_count`, `al_route_overflow_count`, `al_h_recent_resync`) по таблицам из `docs/PERF_RUNBOOK.md` / `docs/PERF_PROFILE.md`:
   - `OK` — ниже warn-порога,
   - `WARN` — в warn-диапазоне,
   - `CRITICAL` — на critical-пороге и выше.
5. Действия оператора при превышении:
   - при `WARN`: зафиксировать инцидент в отчёте, приложить delta и повторить замер на ещё одном 20-тиковом окне для подтверждения;
   - при `CRITICAL` по любой метрике или при любом росте `*_overflow*`: остановить rollout/мердж, открыть follow-up (route/registry/dispatcher triage), приложить логи `[AL][AreaHealthDelta]` и значения до/после.
6. Для debug-анализа смотрите module log: `[AL][AreaHealthDelta]` пишется только при изменении ключевых метрик.
