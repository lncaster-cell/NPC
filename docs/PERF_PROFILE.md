# PERF Profile Regulation (Ambient Life)

Документ определяет обязательный perf-регламент для изменений в `scripts/ambient_life/al_*`.

Актуальный baseline для S80/S100/S120 хранится в:

- `docs/perf/baselines/s80_s100_s120_baseline.csv` (источник для автоматических проверок);
- `docs/perf/baselines/s80_s100_s120_baseline.md` (операторское представление);
- `docs/perf/baselines/README.md` (правило обновления baseline).

## 1) Обязательные сценарии прогона

Для каждого PR с изменениями в `scripts/ambient_life/al_*` прогоняются минимум 3 профиля нагрузки:

1. **S80** — 80 NPC в одной связанной зоне.
2. **S100** — 100 NPC (пороговая штатная нагрузка).
3. **S120** — 120 NPC (стресс-сценарий с ожидаемым давлением на лимиты).

В каждом профиле дополнительно воспроизводятся события:

- **Всплески blocked/disturbed**: пакетные триггеры `onblocked`/`ondisturbed` на группе NPC;
- **Массовые переходы между linked areas**: синхронный переход существенной доли NPC между `al_link_*`-зонами.

Рекомендация по окну измерений:

- warm-up: 2 тика `AL_AreaTick`;
- замер: 20 тиков;
- сравнение: одинаковые условия «до» и «после» (area, набор NPC, маршрутные теги, tick rate).

Ожидаемый эффект для оптимизаций write-on-change в area health snapshot:

- снижение частоты local write-операций (`SetLocalInt`/`SetLocalString`) при стабильных значениях;
- снижение CPU на `AL_AreaTick` в части area health snapshot за счёт popcount LUT (`0..255`) вместо побитового цикла в стандартном 8-тиковом окне resync;
- без изменения диагностических метрик, включая `al_h_recent_resync` и логи `[AL][AreaHealthDelta]`.

## 2) Обязательные метрики (must-have)

Во всех отчётах фиксируются следующие метрики:

- `al_dispatch_q_len`
- `al_dispatch_q_overflow`
- `al_reg_overflow_count`
- `al_route_overflow_count`
- `al_h_recent_resync`
- `al_h_reg_index_miss_delta`
- `al_h_reg_index_miss_window_delta`
- `al_reg_compact_calls` / `al_reg_compact_calls_window`
- `al_dispatch_ticks_to_drain`

Минимальные требования интерпретации:

- отдельно отметить абсолютные значения «до/после»;
- отдельно отметить `Delta`;
- для каждой обязательной метрики указать статус относительно порогов (`OK/WARN/CRITICAL`);
- для overflow-метрик обязательно указать факт роста (`0 -> N` или `N -> M`);
- для PR с оптимизацией compaction отдельно фиксировать ожидаемое снижение `al_reg_compact_calls(_window)`;
- для того же PR подтвердить отсутствие деградации по `al_dispatch_ticks_to_drain` (не хуже baseline в пределах шума измерений).

Дополнительно для изменений dispatch-degradation обязательно фиксируйте целевой baseline-vs-after контроль:

| Метрика | Целевой результат «После» | Допустимый Delta vs «До» |
| --- | --- | --- |
| `al_dispatch_q_overflow` | `0` для S80/S100, `<=1` для S120 | `<= 0` (рост запрещён) |
| `al_dispatch_ticks_to_drain` | S80: `<=3`, S100: `<=4`, S120: `<=5` | `<= +1` |

### Пороговые статусы обязательных метрик

Статус выставляется по значению **«После»** в 20-тиковом окне.

| Метрика | S80 (80 NPC) | S100 (100 NPC) | S120 (120 NPC) |
| --- | --- | --- | --- |
| `al_dispatch_q_len` | warn: `8..12`, critical: `>=13` | warn: `10..14`, critical: `>=15` | warn: `12..17`, critical: `>=18` |
| `al_dispatch_q_overflow` | warn: `1..2`, critical: `>=3` | warn: `1..3`, critical: `>=4` | warn: `2..4`, critical: `>=5` |
| `al_reg_overflow_count` | warn: `1`, critical: `>=2` | warn: `1..2`, critical: `>=3` | warn: `2..4`, critical: `>=5` |
| `al_route_overflow_count` | warn: `1`, critical: `>=2` | warn: `1..2`, critical: `>=3` | warn: `2..4`, critical: `>=5` |
| `al_h_recent_resync` | warn: `3..5`, critical: `>=6` | warn: `4..7`, critical: `>=8` | warn: `6..10`, critical: `>=11` |
| `al_h_reg_index_miss_delta` | warn: `1`, critical: `>=2` | warn: `1..2`, critical: `>=3` | warn: `2..3`, critical: `>=4` |
| `al_h_reg_index_miss_window_delta` | warn: `1..2`, critical: `>=3` | warn: `1..3`, critical: `>=4` | warn: `2..4`, critical: `>=5` |

Единое правило:
- `OK` — значение ниже warn-порога;
- `WARN` — значение в warn-диапазоне;
- `CRITICAL` — значение на critical-пороге и выше.

## 3) Шаблон отчёта «до/после» для PR

Используйте этот шаблон в описании PR для **каждого** изменения в `scripts/ambient_life/al_*`:

```md
## Perf Summary (Ambient Life)

### Scope
- PR: <id/link>
- Изменённые файлы: <список al_*>
- Сценарии: S80 / S100 / S120
- Нагрузочные события: blocked/disturbed burst + linked-area mass transition
- Доля `AL_AreaTick`, затронутая изменением: <оценка в %, подсистема/фаза тика>
- Метрика подтверждения эффекта: <какая обязательная метрика(и) показывает улучшение>

### Baseline vs After

#### S80
| Metric | До | После | Delta | Порог (warn/critical) | Статус vs пороги | Комментарий |
| --- | ---: | ---: | ---: | --- | --- | --- |
| al_dispatch_q_len |  |  |  |  |  |  |
| al_dispatch_q_overflow |  |  |  |  |  |  |
| al_reg_overflow_count |  |  |  |  |  |  |
| al_route_overflow_count |  |  |  |  |  |  |
| al_h_recent_resync |  |  |  |  |  |  |
| al_h_reg_index_miss_delta |  |  |  |  |  |  |
| al_h_reg_index_miss_window_delta |  |  |  |  |  |  |
| al_reg_compact_calls / al_reg_compact_calls_window |  |  |  | n/a | n/a | ожидается снижение |
| al_dispatch_ticks_to_drain |  |  |  | n/a | n/a | без деградации vs baseline |

#### S100
| Metric | До | После | Delta | Порог (warn/critical) | Статус vs пороги | Комментарий |
| --- | ---: | ---: | ---: | --- | --- | --- |
| al_dispatch_q_len |  |  |  |  |  |  |
| al_dispatch_q_overflow |  |  |  |  |  |  |
| al_reg_overflow_count |  |  |  |  |  |  |
| al_route_overflow_count |  |  |  |  |  |  |
| al_h_recent_resync |  |  |  |  |  |  |
| al_h_reg_index_miss_delta |  |  |  |  |  |  |
| al_h_reg_index_miss_window_delta |  |  |  |  |  |  |
| al_reg_compact_calls / al_reg_compact_calls_window |  |  |  | n/a | n/a | ожидается снижение |
| al_dispatch_ticks_to_drain |  |  |  | n/a | n/a | без деградации vs baseline |

#### S120
| Metric | До | После | Delta | Порог (warn/critical) | Статус vs пороги | Комментарий |
| --- | ---: | ---: | ---: | --- | --- | --- |
| al_dispatch_q_len |  |  |  |  |  |  |
| al_dispatch_q_overflow |  |  |  |  |  |  |
| al_reg_overflow_count |  |  |  |  |  |  |
| al_route_overflow_count |  |  |  |  |  |  |
| al_h_recent_resync |  |  |  |  |  |  |
| al_h_reg_index_miss_delta |  |  |  |  |  |  |
| al_h_reg_index_miss_window_delta |  |  |  |  |  |  |
| al_reg_compact_calls / al_reg_compact_calls_window |  |  |  | n/a | n/a | ожидается снижение |
| al_dispatch_ticks_to_drain |  |  |  | n/a | n/a | без деградации vs baseline |

### Conclusion
- Регрессия: yes/no
- Риск для production: low/medium/high
- Нужны follow-up задачи: <да/нет + список>
```

Дополнительно к текущему шаблону, для машинного сравнения прикладывайте CSV в едином формате:

```csv
scenario,metric,baseline_value,after_value,delta,unit,warn_threshold,critical_threshold,status,notes
S80,al_dispatch_q_len,6,,,,count,8..12,>=13,,
```

Markdown-таблицы и CSV должны описывать один и тот же набор строк/метрик.

## 4) Критерии принятия baseline-vs-after

PR считается прошедшим perf-gate только если одновременно выполнено:

1. Для S80/S100/S120 заполнены все must-have метрики;
2. Сравнение оформлено в двух форматах: Markdown (для review) и CSV (для автоматических проверок);
3. Нет необоснованного роста overflow-метрик;
4. `al_dispatch_ticks_to_drain` не деградирует сверх допустимого дельта-окна;
5. Для изменений compaction зафиксирован ожидаемый тренд по `al_reg_compact_calls(_window)`.

## 5) Gate в TASKS / PR-review

Изменения в core-файлах:

- `scripts/ambient_life/al_area_inc.nss`
- `scripts/ambient_life/al_registry_inc.nss`
- `scripts/ambient_life/al_route_inc.nss`
- `scripts/ambient_life/al_dispatch_inc.nss`

считаются **неполными**, если в PR нет perf-сводки по шаблону из этого документа (S80/S100/S120 + обязательные метрики).

Дополнительно PR считается **неполным**, если отсутствует baseline-vs-after по файлам из `docs/perf/baselines/*`.

Используйте `docs/PR_CHECKLIST.md` как обязательный pre-review checklist.

## 6) Правило обновления baseline

Baseline в `docs/perf/baselines/*` обновляется только при подтверждённом улучшении
или при явно обоснованном изменении поведения системы.

Обязательные условия обновления:

- обоснование причины в PR;
- ссылка на артефакт сравнения baseline-vs-after;
- синхронное обновление `.csv` и `.md` baseline-файлов.
