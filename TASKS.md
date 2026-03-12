# Task Board

## P0

- [x] Stage I.2: crime/alarm escalation поверх disturbed foundation.
- [x] Диагностика отказа `AL_RegisterNPC` при достижении `AL_MAX_NPCS`.
- [ ] Унифицированная схема подключения `al_area_tick` для разных шаблонов модулей.

## P1

- [ ] Чек-лист валидации маршрутов (slot tags, `al_step`, area consistency, duplicates).
- [ ] Шаблон контент-подготовки sleep-точек (`_approach`/`_pose`).
- [ ] Операторский гайд по linked areas (`al_link_*`) и warm-policy.

## P2

- [ ] Сервисный валидатор locals (NPC/waypoints/areas) для контент-команды.
- [ ] Профилирование производительности на сценах с высокой плотностью NPC (по `docs/PERF_RUNBOOK.md`).


## Регулярная QA-практика

- Smoke-check: см. раздел `Runbook: Area Health Snapshot` ниже.
- Perf-check: см. `docs/PERF_RUNBOOK.md` (минимум Scene M для каждого заметного изменения ambient-life).
- Для правок в route/registry/dispatcher: обязательный PR-отчёт «до/после» по шаблону из `docs/PERF_RUNBOOK.md`.

## Runbook: Area Health Snapshot (операторский минимум)

1. Включите debug на area: `al_debug=1` (опционально, только для delta-логов).
2. Дождитесь минимум 2-3 тиков `AL_AreaTick`.
3. Проверьте locals area:
   - `al_h_npc_count` ~= ожидаемому числу активных NPC,
   - `al_h_tier` и `al_h_slot` соответствуют текущей фазе,
   - `al_h_reg_overflow_count=0` и `al_h_route_overflow_count=0` в штатном контенте,
   - `al_h_recent_resync` в норме низкий и растёт в окне только при реальных RESYNC.
4. Для debug-анализа смотрите module log: `[AL][AreaHealthDelta]` пишется только при изменении ключевых метрик.
