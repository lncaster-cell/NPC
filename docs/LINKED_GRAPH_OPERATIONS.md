# Linked Areas: operator guide (`al_link_*`) and warm-policy

Документ фиксирует практические правила для контент-команды и операторов по настройке linked-графа area и контролю warm-retention.

## 1) Контракт linked locals

Локалы задаются на **area**:

- `al_link_count` (int) — количество связанных area.
- `al_link_0..N` (string) — `tag` связанной area на каждом индексе `0..al_link_count-1`.

Практические требования:

1. `al_link_count` и фактическое число `al_link_*` должны совпадать.
2. Каждый `al_link_i` обязан указывать на существующий area tag.
3. Дубликаты `al_link_i` для одной area недопустимы.
4. Симметричная связность обязательна: если `A -> B`, то в контенте должен быть и `B -> A`.

## 2) Warm-policy (как linked-граф влияет на tier)

В lifecycle используются tiers:

- `0 = FREEZE`
- `1 = WARM`
- `2 = HOT`

Операционная логика:

1. При наличии игрока в area поддерживается `HOT`.
2. При отсутствии игрока, но при активности в связанном кластере area может удерживаться в `WARM` (linked-area retention).
3. При отсутствии оснований для прогрева area возвращается в `FREEZE`.

Следствие для эксплуатации: linked-граф должен быть достаточно связным для естественных переходов NPC, но не настолько плотным, чтобы «прогревать всё сразу».

## 3) Правила проектирования linked-графа

### 3.1 Ограничения на степень связности

- Целевой диапазон исходящей степени на area: **2..4** связи.
- Допустимый максимум для «хаба»: **6** связей.
- Значения выше 6 допускаются только как осознанное исключение (крупный транспортный узел) с обязательной perf-проверкой по `docs/PERF_RUNBOOK.md`.

### 3.2 Рекомендации по размеру кластеров

- Рабочий размер кластера linked area: **3..8** area.
- Для районов 9..12 area граф делить на под-кластеры с 1-2 мостами между ними.
- Кластеры больше 12 area без сегментации считаются повышенным риском для warm-retention и частых resync-волн.

### 3.3 Антипаттерны

Избегать следующих схем:

1. **Избыточная полносвязность** (почти каждый area связан с каждым).
2. «Звезда» с перегруженным центром, через который проходит почти весь трафик.
3. Длинные цепочки без локальных обходных связей (провоцируют каскадные переходы/resync при узком месте).

Симптомы антипаттернов обычно видны как рост `al_h_recent_resync`, нестабильный `al_h_tier` и ненулевой прирост overflow-счётчиков.

### 3.4 Связь порогов с perf-базой S80/S100/S120

Пороги степени и размера кластера закреплены на базе наблюдений из `docs/perf/baselines/s80_s100_s120_baseline.md`:

- На baseline S80/S100/S120 при контролируемом linked-графе (`degree` в основном `2..4`, локальные хабы до `6`, кластер обычно `3..8`) фиксируются стабильные значения `al_h_recent_resync` и отсутствие критического роста overflow-счётчиков.
- При увеличении степени центральных узлов и/или укрупнении кластеров (>8 без сегментации) в операционных прогонах растут риски каскадного прогрева (`al_h_tier`), resync-волн (`al_h_recent_resync`) и переполнений (`al_reg_overflow_count`, `al_route_overflow_count`).
- Поэтому policy сохраняет: target degree `2..4`, hard max `6`, рабочий размер кластера `3..8`, зона риска `9..12` (только с мостами/сегментацией), >12 без сегментации — антишаблон.

## 4) Операторский чек-лист перед запуском

1. Проверить, что `al_link_count` корректен и без «дыр» по индексам.
2. Проверить валидность всех `al_link_i` по существующим area tag.
3. Проверить отсутствие дублей и самоссылок (`area -> area`).
4. Проверить степень связности: базово 2..4, максимум 6 для хабов.
5. Проверить размеры кластеров и отсутствие неуправляемой полносвязности.
6. После изменений выполнить perf-check по `docs/PERF_RUNBOOK.md` минимум на Scene M.

## 5) Быстрая диагностика перегрева linked-графа

Если есть подозрение на «перегрев» (избыточный прогрев/ресинхронизацию):

1. Снять окно 20 тиков (после прогрева 2 тика), как в `docs/PERF_RUNBOOK.md`.
2. Проверить:
   - `al_h_tier` — не должен хаотично переключаться в baseline.
   - `al_h_recent_resync` — в штатном состоянии низкий (обычно `0..2`, для высокой плотности до `0..3`).
   - `al_h_reg_overflow_count` / `al_h_route_overflow_count` — любой рост в baseline считать инцидентом.
3. При подтверждении инцидента упростить граф:
   - убрать избыточные связи,
   - разделить крупный кластер на под-кластеры,
   - снизить степень центральных хабов.


## 6) Offline preflight validator (`al_link_preflight.py`)

Перед rollout изменений linked-графа запускайте сервисный валидатор:

```bash
python3 scripts/ambient_life/al_link_preflight.py --input scripts/ambient_life/test_al_link_preflight_ok.json --format text
```

JSON-режим (для CI/автоматизации):

```bash
python3 scripts/ambient_life/al_link_preflight.py --input scripts/ambient_life/test_al_link_preflight_ok.json --format json
```

Пример smoke-проверки с ошибками (ожидаем `exit code 1`):

```bash
python3 scripts/ambient_life/al_link_preflight.py --input scripts/ambient_life/test_al_link_preflight_invalid.json --format text
```

Что проверяется:

- валидность `al_link_count`;
- диапазон индексов `al_link_0..al_link_{count-1}` и отсутствие «вне диапазона»;
- self-link (`area -> area`);
- дубликаты linked area внутри одной area;
- симметрия (`A -> B` требует `B -> A`);
- degree-пороги (target `2..4`, hard max `6`).

Policy уровней нарушений (merge gate):

- **ERROR (merge-blocking):** `self_link`, `duplicate_links`, `symmetry_mismatch`, `unknown_link_target`, `degree_exceeds_hub_max`, а также структурные ошибки (`invalid_link_count`, `missing_link_slot`, `invalid_link_slot_*`, `invalid_locals_type`).
- **WARN (не блокирует merge автоматически, но требует операторского решения):** `degree_below_target`, `degree_above_target` в пределах hard-max.

Операторские примеры входа (`docs/`):

```bash
python3 scripts/ambient_life/al_link_preflight.py --input docs/LINKED_PREFLIGHT_EXAMPLES_PASS.json --format text
python3 scripts/ambient_life/al_link_preflight.py --input docs/LINKED_PREFLIGHT_EXAMPLES_FAIL.json --format text
```

Коды завершения:

- `0` — ошибок нет (warnings допустимы);
- `1` — обнаружены ошибки в linked-графе (rollout блокируется);
- `2` — фатальная ошибка чтения/формата входного JSON.
