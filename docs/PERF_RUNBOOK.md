# PERF Runbook (Ambient Life)

Цель: дать **воспроизводимый** протокол производственных perf-прогонов для сравнения «до/после» изменений в `scripts/ambient_life/*`.

## 1) Фиксированные тест-сцены (Low / Mid / High)

> Во всех сценах используются одинаковые настройки рантайма: `AL_AREA_TICK_SEC=30`, `AL_MAX_NPCS=100`, `AL_ROUTE_MAX_STEPS=16`.

### Scene L (низкая плотность)

- `area tag`: `al_perf_low`
- NPC: **20**
- Набор route-тегов (фиксированный): `rt_market_loop`, `rt_square_idle`, `rt_inn_staff`
- Распределение NPC по route:
  - 8 × `rt_market_loop`
  - 8 × `rt_square_idle`
  - 4 × `rt_inn_staff`

### Scene M (средняя плотность)

- `area tag`: `al_perf_mid`
- NPC: **60**
- Набор route-тегов (фиксированный): `rt_market_loop`, `rt_square_idle`, `rt_inn_staff`, `rt_gate_patrol`, `rt_docks_workers`
- Распределение NPC по route:
  - 16 × `rt_market_loop`
  - 14 × `rt_square_idle`
  - 10 × `rt_inn_staff`
  - 10 × `rt_gate_patrol`
  - 10 × `rt_docks_workers`

### Scene H (высокая плотность)

- `area tag`: `al_perf_high`
- NPC: **95** (контрольный «почти предел» без штатного registry overflow)
- Набор route-тегов (фиксированный):
  `rt_market_loop`, `rt_square_idle`, `rt_inn_staff`, `rt_gate_patrol`, `rt_docks_workers`, `rt_temple_visitors`, `rt_craft_lane`
- Распределение NPC по route:
  - 20 × `rt_market_loop`
  - 15 × `rt_square_idle`
  - 12 × `rt_inn_staff`
  - 12 × `rt_gate_patrol`
  - 12 × `rt_docks_workers`
  - 12 × `rt_temple_visitors`
  - 12 × `rt_craft_lane`

## 2) Длительность прогона и ожидаемые диапазоны `al_h_*`

### Общая процедура

1. Перед стартом сбросить/перезагрузить сцену.
2. Включить `al_debug=1` на area только на время замера.
3. Дать системе прогреться **2 тика** (`~60 сек`).
4. Измерять в окне **20 тиков** (`~10 минут`) после прогрева.

### Ожидаемые диапазоны и лимиты

| Сцена | Длительность окна | `al_h_npc_count` | `al_h_tier` | `al_h_recent_resync` | `al_h_reg_overflow_count` | `al_h_route_overflow_count` |
| --- | --- | --- | --- | --- | --- | --- |
| L | 20 тиков | 18..22 | 2 (HOT) при игроке в area | 0..2 | 0 (hard limit) | 0 (hard limit) |
| M | 20 тиков | 57..63 | 2 (HOT) при игроке в area | 0..2 | 0 (hard limit) | 0 (hard limit) |
| H | 20 тиков | 92..96 | 2 (HOT) при игроке в area | 0..3 | 0 (hard limit) | 0 (hard limit) |

Дополнительно для всех сцен:

- `al_h_slot` должен совпадать с активным временным слотом (`GetTimeHour()/4`) без «дребезга» вне смены слота.
- Любой ненулевой рост `al_h_reg_overflow_count` или `al_h_route_overflow_count` в baseline-сцене считается провалом прогона.

## 3) KPI для регулярного perf-контроля

Снимать KPI в том же 10-минутном окне (после прогрева):

1. **Average dispatch drain**
   - Формула: `avg_dispatch_drain = Δ(al_dispatch_ticks) / Δ(al_sync_tick)`.
   - Целевой диапазон:
     - L: `<= 1.2`
     - M: `<= 1.8`
     - H: `<= 2.5`

2. **Cache hit/miss share**
   - Формулы:
     - `hit_share = Δ(al_cache_hit) / (Δ(al_cache_hit)+Δ(al_cache_miss))`
     - `miss_share = Δ(al_cache_miss) / (Δ(al_cache_hit)+Δ(al_cache_miss))`
   - Цель для всех сцен: `hit_share >= 0.85`, `miss_share <= 0.15`.

3. **Compaction frequency**
   - Практический proxy (так как отдельного счётчика compaction в locals нет):
     - считать частоту строк `[AL][AreaHealthDelta]` с заметным падением `npc_count` без контентного события despawn/transition.
   - Цель: не более **1 аномального случая на 20 тиков** в сценах L/M и не более **2** в H.

4. **Route rebuild count**
   - Практический proxy: `route_rebuild_count = Δ(al_cache_miss)` (каждый miss приводит к восстановлению route cache).
   - Цель:
     - L: `<= 8` за окно
     - M: `<= 20` за окно
     - H: `<= 35` за окно

## 4) Шаблон отчёта для PR («до/после»)

```md
## Perf Report (Ambient Life)

### Протокол
- Runbook: `docs/PERF_RUNBOOK.md`
- Build/branch: <commit or branch>
- Environment: <module, hardware/host, build config>
- Tick window: warmup 2 ticks + measure 20 ticks

### Scene L (`al_perf_low`)
| Metric | До | После | Delta | Статус |
| --- | ---: | ---: | ---: | --- |
| al_h_npc_count (range) |  |  |  | ✅/⚠️/❌ |
| al_h_recent_resync (range) |  |  |  | ✅/⚠️/❌ |
| reg_overflow |  |  |  | ✅/❌ |
| route_overflow |  |  |  | ✅/❌ |
| avg_dispatch_drain |  |  |  | ✅/⚠️/❌ |
| hit_share / miss_share |  |  |  | ✅/⚠️/❌ |
| compaction_frequency |  |  |  | ✅/⚠️/❌ |
| route_rebuild_count |  |  |  | ✅/⚠️/❌ |

### Scene M (`al_perf_mid`)
(таблица как выше)

### Scene H (`al_perf_high`)
(таблица как выше)

### Итог
- Регрессия: yes/no
- Краткая интерпретация (1-3 пункта)
- Приложенные логи/артефакты: <paths>
```

## 5) Встраивание в регулярный QA-процесс

Минимальный QA-gate для изменений ambient-life:

- Smoke-check из `TASKS.md`.
- Perf-check по этому runbook (`docs/PERF_RUNBOOK.md`) минимум на Scene M.
- Для изменений маршрутизации/реестра/диспетчера — обязательно все 3 сцены (L/M/H) и отчёт «до/после» в PR.
