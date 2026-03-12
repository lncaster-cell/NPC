# PERF Profile Regulation (Ambient Life)

Документ определяет обязательный perf-регламент для изменений в `scripts/ambient_life/al_*`.

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

## 2) Обязательные метрики (must-have)

Во всех отчётах фиксируются следующие метрики:

- `al_dispatch_q_len`
- `al_dispatch_q_overflow`
- `al_reg_overflow_count`
- `al_route_overflow_count`
- `al_h_recent_resync`

Минимальные требования интерпретации:

- отдельно отметить абсолютные значения «до/после»;
- отдельно отметить `Delta`;
- для overflow-метрик обязательно указать факт роста (`0 -> N` или `N -> M`).

## 3) Шаблон отчёта «до/после» для PR

Используйте этот шаблон в описании PR для **каждого** изменения в `scripts/ambient_life/al_*`:

```md
## Perf Summary (Ambient Life)

### Scope
- PR: <id/link>
- Изменённые файлы: <список al_*>
- Сценарии: S80 / S100 / S120
- Нагрузочные события: blocked/disturbed burst + linked-area mass transition

### Baseline vs After

#### S80
| Metric | До | После | Delta | Комментарий |
| --- | ---: | ---: | ---: | --- |
| al_dispatch_q_len |  |  |  |  |
| al_dispatch_q_overflow |  |  |  |  |
| al_reg_overflow_count |  |  |  |  |
| al_route_overflow_count |  |  |  |  |
| al_h_recent_resync |  |  |  |  |

#### S100
| Metric | До | После | Delta | Комментарий |
| --- | ---: | ---: | ---: | --- |
| al_dispatch_q_len |  |  |  |  |
| al_dispatch_q_overflow |  |  |  |  |
| al_reg_overflow_count |  |  |  |  |
| al_route_overflow_count |  |  |  |  |
| al_h_recent_resync |  |  |  |  |

#### S120
| Metric | До | После | Delta | Комментарий |
| --- | ---: | ---: | ---: | --- |
| al_dispatch_q_len |  |  |  |  |
| al_dispatch_q_overflow |  |  |  |  |
| al_reg_overflow_count |  |  |  |  |
| al_route_overflow_count |  |  |  |  |
| al_h_recent_resync |  |  |  |  |

### Conclusion
- Регрессия: yes/no
- Риск для production: low/medium/high
- Нужны follow-up задачи: <да/нет + список>
```

## 4) Gate в TASKS / PR-review

Изменения в core-файлах:

- `scripts/ambient_life/al_area_inc.nss`
- `scripts/ambient_life/al_registry_inc.nss`
- `scripts/ambient_life/al_route_inc.nss`

считаются **неполными**, если в PR нет perf-сводки по шаблону из этого документа (S80/S100/S120 + обязательные метрики).
