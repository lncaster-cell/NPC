# PERF Runbook (Ambient Life)

## 0) Обязательный preflight: оффлайн-валидатор route-разметки

Перед **каждым** perf-прогоном (S80/S100/S120) оператор обязан прогнать оффлайн-валидатор:

```bash
python3 scripts/ambient_life/al_route_preflight.py --input <path/to/waypoints.json>
```

Требования к входному JSON:
- корень: либо массив waypoint-объектов, либо объект с ключом `waypoints`;
- обязательные поля для каждого waypoint: `area_tag`, `route_tag`, `al_step`;
- опционально: `waypoint_tag` (для более удобной диагностики).

Валидатор зеркалит проверки из `AL_RouteBuildAreaCache`:
- диапазон `al_step`: только `0..15`;
- наличие шага `0`;
- непрерывность шагов (`0..N` без пропусков);
- дубликаты `al_step` внутри `(area_tag, route_tag)`;
- area consistency: один `route_tag` не должен одновременно жить в нескольких `area_tag`.

Формат отчёта: одна строка на проблему с обязательной привязкой `area=<area_tag>` и `route=<route_tag>`,
чтобы контент-команда могла исправить данные до запуска сценариев S80/S100/S120.

Политика gate:
- если есть `[ERROR]` — perf-прогон блокируется;
- если есть только `[WARN]` — требуется ручной triage, но запуск допускается.

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
   - Практический proxy: `route_rebuild_count = Δ(al_cache_miss)` (каждый miss приводит к попытке восстановления route cache).
   - Runtime safety-net проверки остаются включёнными, но rebuild после неуспешной проверки ограничен cooldown-окном `AL_ROUTE_REBUILD_COOLDOWN_TICKS` для снижения частоты повторных rebuild в битом контенте.
   - Цель:
     - L: `<= 8` за окно
     - M: `<= 20` за окно
     - H: `<= 35` за окно

### Пороговая интерпретация обязательных метрик (warn/critical)

Для метрик ниже статус в отчёте ставится по значению **«После»** в окне 20 тиков.

| Метрика | Scene L (20 NPC) | Scene M (60 NPC) | Scene H (95 NPC) | Как трактовать |
| --- | --- | --- | --- | --- |
| `al_dispatch_q_len` | warn: `4..6`, critical: `>=7` | warn: `6..9`, critical: `>=10` | warn: `9..13`, critical: `>=14` | Рост очереди = система не успевает разгребать dispatch в целевом темпе. |
| `al_dispatch_q_overflow` | warn: `1`, critical: `>=2` | warn: `1..2`, critical: `>=3` | warn: `1..3`, critical: `>=4` | Overflow очереди означает потерю/пропуск работы диспетчера под нагрузкой. |
| `al_reg_overflow_count` | warn: `1`, critical: `>=2` | warn: `1`, critical: `>=2` | warn: `1..2`, critical: `>=3` | Переполнение registry недопустимо в baseline, в stress — сигнал дефицита ёмкости. |
| `al_route_overflow_count` | warn: `1`, critical: `>=2` | warn: `1`, critical: `>=2` | warn: `1..2`, critical: `>=3` | Переполнение route-cache/route-пула: риск деградации маршрутизации и повторных rebuild. |
| `al_h_recent_resync` | warn: `3..4`, critical: `>=5` | warn: `3..5`, critical: `>=6` | warn: `4..7`, critical: `>=8` | Частые resync без явных контентных причин — симптом нестабильности состояния NPC. |

Правило статуса:
- `OK` — значение ниже warn-порога;
- `WARN` — попадает в warn-диапазон;
- `CRITICAL` — достигает или превышает critical-порог.

Для `*_overflow*` дополнительно фиксируйте и в комментарии, и в выводе отчёта факт роста (`0 -> N`), даже если значение пока в зоне `WARN`.

## 4) Шаблон отчёта для PR («до/после»)

```md
## Perf Report (Ambient Life)

### Протокол
- Runbook: `docs/PERF_RUNBOOK.md`
- Build/branch: <commit or branch>
- Environment: <module, hardware/host, build config>
- Tick window: warmup 2 ticks + measure 20 ticks

### Scene L (`al_perf_low`)
| Metric | До | После | Delta | Порог (warn/critical) | Статус vs пороги | Комментарий |
| --- | ---: | ---: | ---: | --- | --- | --- |
| al_h_npc_count (range) |  |  |  | см. §2 | OK/WARN/CRITICAL |  |
| al_dispatch_q_len |  |  |  | см. таблицу порогов | OK/WARN/CRITICAL |  |
| al_dispatch_q_overflow |  |  |  | см. таблицу порогов | OK/WARN/CRITICAL |  |
| al_reg_overflow_count |  |  |  | см. таблицу порогов | OK/WARN/CRITICAL |  |
| al_route_overflow_count |  |  |  | см. таблицу порогов | OK/WARN/CRITICAL |  |
| al_h_recent_resync |  |  |  | см. таблицу порогов | OK/WARN/CRITICAL |  |
| avg_dispatch_drain |  |  |  | см. KPI-цели | OK/WARN/CRITICAL |  |
| hit_share / miss_share |  |  |  | см. KPI-цели | OK/WARN/CRITICAL |  |
| compaction_frequency |  |  |  | см. KPI-цели | OK/WARN/CRITICAL |  |
| route_rebuild_count |  |  |  | см. KPI-цели | OK/WARN/CRITICAL |  |

### Scene M (`al_perf_mid`)
(таблица как выше)

### Scene H (`al_perf_high`)
(таблица как выше)

### Итог
- Регрессия: yes/no
- Краткая интерпретация (1-3 пункта) с явным указанием метрик в WARN/CRITICAL
- Приложенные логи/артефакты: <paths>
```

## 5) Встраивание в регулярный QA-процесс

Минимальный QA-gate для изменений ambient-life:

- Smoke-check из `TASKS.md`.
- Perf-check по этому runbook (`docs/PERF_RUNBOOK.md`) минимум на Scene M.
- Для изменений маршрутизации/реестра/диспетчера — обязательно все 3 сцены (L/M/H) и отчёт «до/после» в PR.
