# 46 — Daily Life v2 Foundation Batch 01 (RU)

> Дата: 2026-04-08  
> Статус: implementation batch in progress

## 1) Цель пакета

Заложить первый расширенный технический фундамент Daily Life v2 без захода в спорные продуктовые решения resolver/materialization.

Пакет закрывает только инфраструктурную базу:
- contract/include слой;
- bootstrap/init слоя модуля;
- area tier/runtime state helpers;
- централизованный chat-log helper;
- локальные smoke-проверки для новых helper-функций.

## 2) Что добавлено

### 2.1 Contract layer
Добавлен `scripts/daily_life/dl_v2_contract_inc.nss`.

Назначение:
- собрать v2 locals и enum-like константы в одном include;
- зафиксировать базовые значения для NPC state и Area Tier;
- зафиксировать минимальный worker budget default.

### 2.2 Logging layer
Добавлен `scripts/daily_life/dl_v2_log_inc.nss`.

Назначение:
- централизовать chat logging;
- держать logging disabled-by-default;
- вынести smoke/debug log из будущей core-логики в helper-слой.

### 2.3 Module bootstrap layer
Добавлены:
- `scripts/daily_life/dl_v2_bootstrap_inc.nss`
- `scripts/daily_life/dl_v2_bootstrap.nss`

Назначение:
- инициализировать module contract;
- выставлять/нормализовать contract version;
- нормализовать budget и debug/log flags.

### 2.4 Area layer
Добавлен `scripts/daily_life/dl_v2_area_inc.nss`.

Назначение:
- получить/установить area tier;
- инициализировать area runtime state;
- активировать area в HOT при player-enter path.

### 2.5 Smoke layer
Добавлены:
- `scripts/daily_life/dl2_smoke_step_02_bootstrap_init.nss`
- `scripts/daily_life/dl2_smoke_step_03_area_tier.nss`

Назначение:
- локально проверять bootstrap contract init;
- локально проверять area tier helpers;
- использовать централизованный chat logging helper.

## 3) Что это даёт контуру

После этого пакета Daily Life v2 получает уже не один isolated helper, а минимальный рабочий foundation contour:
1. есть shared contract constants;
2. есть module init path;
3. есть area tier/runtime state primitives;
4. есть централизованный chat-log path;
5. есть smoke-скрипты для проверки новых слоёв.

## 4) Что сознательно НЕ делалось в этом пакете

В пакет намеренно не включались:
- resolver;
- anchor policy;
- materialization;
- interaction refresh;
- handoff/resync logic.

Причина: эти шаги уже затрагивают продуктовые решения higher-level поведения и не должны вводиться до стабилизации foundation-слоя.

## 5) Следующие логичные шаги

1. Привязать `dl_v2_bootstrap.nss` к реальному module load path.
2. Вынести Step 01 smoke на новый log helper.
3. Ввести NPC registration helper.
4. Ввести registry/cursor helper для area worker.
5. После этого переходить к первому resolver helper.
