# 41 — Daily Life v2 Design Baseline (RU)

> Дата: 2026-04-08  
> Статус: draft for owner approval

## 1) Цель baseline

Согласовать минимальную архитектуру v2 до написания рабочего runtime-кода.

## 2) Входные источники

- Канон: `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
- Инварианты: `docs/runtime/06_SYSTEM_INVARIANTS.md`
- Ретроспектива v1: `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
- Legacy reference code: `archive/daily_life_v1_legacy/scripts/daily_life/`

## 3) Минимальный v2 Data Contract (предлагаемый)

### 3.1 NPC locals (ядро)

- `dl2_profile_id` — строковый идентификатор профиля поведения.
- `dl2_state` — текущее состояние автомата (`IDLE`, `TRANSIT`, `ACTIVE`, `BLOCKED`).
- `dl2_anchor_id` — текущий целевой anchor.
- `dl2_last_tick` — последний обработанный тик (для защиты от дублей).
- `dl2_debug_trace` — флаг расширенной диагностики.

### 3.2 Area locals

- `dl2_area_tier` — `HOT/WARM/FROZEN`.
- `dl2_worker_cursor` — курсор fairness-обхода.
- `dl2_worker_budget` — лимит NPC на тик.

### 3.3 Module locals

- `dl2_enabled` — глобальный флаг включения v2.
- `dl2_contract_version` — версия контракта (`v2.a0` на старте).

## 4) Event Pipeline v2 (MVP)

1. `OnModuleLoad` — инициализация контракта/флагов.
2. `OnAreaEnter` — перевод area в HOT при входе игрока.
3. `OnAreaHeartbeat` — worker tick по budget.
4. `OnNPCSpawn` — регистрация NPC в v2-пайплайне.
5. `OnNPCUserDefined` — точечные resync/diagnostic события.

## 5) Производительность и контроль

- На каждом тике обрабатывается не более `budget` NPC.
- В `FROZEN` tier runtime-процессинг отключается.
- Каждая функция должна быть idempotent в рамках одного тика.

## 6) Первый технический шаг (после approval)

### Шаг 1 (первая функция)
`DL2_IsRuntimeEnabled()`

Контракт:
- Вход: нет.
- Выход: `TRUE/FALSE`.
- Логика: проверяет `dl2_enabled` и `dl2_contract_version`.

Проверка шага:
- smoke-скрипт `dl2_smoke_step_01.nss` логирует PASS/FAIL для 3 кейсов:
  1. модуль выключен,
  2. включен с неверной версией,
  3. включен с `v2.a0`.

## 7) Что НЕ делаем до Шага 1

- Не вводим resolver/materialization/slot-handoff.
- Не подключаем полноценные диалоги.
- Не мигрируем весь legacy API в v2-нейминг.
