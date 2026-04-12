# 47 — Daily Life v2 Foundation Batch 02: Registry and Worker Cursor (RU)

> Дата: 2026-04-08  
> Статус: implementation batch in progress

## 1) Цель пакета

Добавить следующий инфраструктурный слой Daily Life v2 после foundation batch 01:
- формальную регистрацию NPC в v2 runtime-контуре;
- area-level worker cursor helpers;
- безопасный доступ к runtime-кандидатам в area без resolver/materialization.

## 2) Что добавлено

### 2.1 Registry layer
Добавлен `daily_life/dl_v2_registry_inc.nss`.

Назначение:
- определить, какой объект является runtime-candidate для Daily Life v2;
- формально помечать NPC как зарегистрированного в v2;
- выставлять минимальные default-значения (`profile_id`, `state`) при регистрации.

### 2.2 Worker cursor layer
Добавлен `daily_life/dl_v2_worker_inc.nss`.

Назначение:
- получить worker budget и worker cursor для area;
- посчитать runtime-кандидатов в area;
- выбирать следующего runtime-кандидата по cursor-модели;
- продвигать cursor без resolver/materialization.

### 2.3 Smoke layer
Добавлен `daily_life/dl2_smoke_step_04_registry_worker.nss`.

Назначение:
- локально проверить регистрацию NPC;
- локально проверить, что worker path возвращает runtime-кандидата;
- локально проверить, что cursor продвигается.

## 3) Что это даёт контуру

После batch 02 Daily Life v2 уже имеет:
1. module/bootstrap foundation;
2. area tier/runtime primitives;
3. централизованный chat-log helper;
4. NPC registration primitive;
5. cursor-based area worker candidate selection.

Это ещё не поведение NPC, но уже operable skeleton для дальнейшего роста.

## 4) Что сознательно НЕ делалось

В пакет намеренно не включались:
- directive resolver;
- anchor policy;
- activity/materialization;
- interaction refresh;
- fairness scoring beyond simple cursor progression.

## 5) Следующие логичные шаги

1. Перевести `dl2_smoke_step_01.nss` на новый centralized log helper.
2. Привязать `dl_v2_bootstrap.nss` к реальному module load path.
3. Ввести первый resolver helper без materialization.
4. После этого вводить anchor policy helper и только потом materialization plan.
---

**Текущий canonical runtime path: `daily_life/`.**
