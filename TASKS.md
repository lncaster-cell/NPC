# Task Board

## P0

- [x] Stage I.2: crime/alarm escalation поверх disturbed foundation.
- [x] Диагностика отказа `AL_RegisterNPC` при достижении `AL_MAX_NPCS`.
- [x] Унифицированная схема подключения `al_area_tick` для разных шаблонов модулей (см. `INSTALLATION.md`, разделы 2.2.1 и 2.3).

## P1

- [x] Оффлайн/операторский preflight-валидатор маршрутов (`al_step` range, step continuity, duplicates, area consistency).
- [ ] Шаблон контент-подготовки sleep-точек (`_approach`/`_pose`).
- [x] Операторский гайд по linked areas (`al_link_*`) и warm-policy (см. `docs/LINKED_GRAPH_OPERATIONS.md`).

## P2

- [ ] Сервисный валидатор locals (NPC/waypoints/areas) для контент-команды.
- [ ] Профилирование производительности на сценах с высокой плотностью NPC (по `docs/PERF_RUNBOOK.md`).


## Регулярная QA-практика

- Smoke-check: см. раздел `Runbook: Area Health Snapshot` ниже.
- Perf-check: см. `docs/PERF_RUNBOOK.md` (минимум Scene M для каждого заметного изменения ambient-life).
- Preflight-gate перед S80/S100/S120: обязательный запуск `python3 scripts/ambient_life/al_route_preflight.py --input <waypoints.json>`; при `[ERROR]` запуск сценариев запрещён до исправления контента.
- Для правок в route/registry/dispatcher: обязательный PR-отчёт «до/после» по шаблону из `docs/PERF_RUNBOOK.md`.
- Gate (core): изменения в `scripts/ambient_life/al_area_inc.nss`, `scripts/ambient_life/al_registry_inc.nss`, `scripts/ambient_life/al_route_inc.nss` считаются неполными без perf-сводки по `docs/PERF_PROFILE.md`.

## Runbook: Area Health Snapshot (операторский минимум)

См. также: `docs/LINKED_GRAPH_OPERATIONS.md` (правила linked-графа и warm-policy).

1. Включите debug на area: `al_debug=1` (опционально, только для delta-логов).
2. Дождитесь минимум 2-3 тиков `AL_AreaTick`.
3. Проверьте locals area:
   - `al_h_npc_count` ~= ожидаемому числу активных NPC,
   - `al_h_tier` и `al_h_slot` соответствуют текущей фазе,
   - `al_h_reg_overflow_count=0` и `al_h_route_overflow_count=0` в штатном контенте,
   - `al_h_recent_resync` в норме низкий и растёт в окне только при реальных RESYNC.
4. Для debug-анализа смотрите module log: `[AL][AreaHealthDelta]` пишется только при изменении ключевых метрик.


## Check-list валидации подключения hooks (toolset + runtime)

- [ ] **Toolset / Module:** `OnClientLeave=al_mod_onleave`.
- [ ] **Toolset / Area:** `OnEnter=al_area_onenter`, `OnExit=al_area_onexit`; `OnHeartbeat` либо пустой (рекомендуется), либо legacy-bootstrap с `al_area_tick` без второго loop.
- [ ] **Toolset / NPC:** `OnSpawn=al_npc_onspawn`, `OnDeath=al_npc_ondeath`, `OnUserDefined=al_npc_onud`, `OnBlocked=al_npc_onblocked`, `OnDisturbed=al_npc_ondisturbed`.
- [ ] **Runtime (после входа игрока):** в area locals появляются `al_tick_token`, `al_player_count`, `al_sim_tier`, `al_slot`.
- [ ] **Runtime smoke (2–3 тика):** появляются health locals `al_h_npc_count`, `al_h_tier`, `al_h_slot`; overflow-метрики `al_h_reg_overflow_count` и `al_h_route_overflow_count` остаются `0` для штатной сцены.
- [ ] **Runtime logs:** фиксируется `[AL][AreaHealthDelta]` при изменении ключевых метрик; нет признаков дублированного heartbeat-loop.
