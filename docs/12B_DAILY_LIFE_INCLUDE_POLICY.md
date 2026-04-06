# Daily Life v1 — Include Policy

Дата: 2026-04-06  
Статус: active  
Назначение: зафиксировать, какой include-слой считается нормативным для нового кода и как обращаться с legacy guarded includes.

## 1) Главный принцип

Для **новых entry scripts** Daily Life нормативным считается compile-safe путь через:
- `scripts/daily_life/dl_all_inc.nss`

Именно этот слой должен использоваться в:
- area hooks;
- NPC lifecycle/event hooks;
- dialogue/store entry scripts;
- smoke scripts;
- любых новых `main()` / `StartingConditional()` entrypoints.

## 2) Что делать с guarded include-слоем

Файлы вида:
- `dl_const_inc.nss`
- `dl_util_inc.nss`
- `dl_schedule_inc.nss`
- `dl_resolver_inc.nss`
- `dl_materialize_inc.nss`
- `dl_worker_inc.nss`
- и другие `*_inc.nss` с `#ifndef/#define/#endif`

считаются **legacy compatibility / internal implementation layer**.

Они сохраняются по трём причинам:
1. не ломать старые internal include-chain зависимости;
2. не делать агрессивный risky refactor без полноценного owner compile/test cycle;
3. позволять поэтапную санитарную чистку без регресса рабочего runtime-path.

## 3) Политика для нового кода

Запрещено для новых entry scripts:
- напрямую включать guarded legacy include-файлы,
- строить новые compile-paths через старый include-граф,
- плодить альтернативные entry-layer aggregation файлы.

Разрешено:
- использовать `dl_all_inc` как единый compile-safe entry aggregation layer;
- точечно оптимизировать legacy include-файлы, если это:
  - безопасно,
  - улучшает hot-path math/utility,
  - не меняет внешний runtime-contract.

## 4) Стратегия санитарной чистки

Текущая стратегия проекта:
1. сначала стабилизировать **рабочий runtime entry path**;
2. затем синхронизировать docs;
3. только потом поэтапно чистить legacy guarded includes.

Это означает:
- не переписывать весь include-лес одним большим коммитом;
- выбирать изменения с лучшим отношением **польза / риск**;
- приоритет отдавать hot-path utility/schedule helpers и compile ambiguity reduction.

## 5) Производительный вариант

Для внутренних улучшений выбирается следующий принцип:
- **runtime-first**: сначала ускорять и упрощать те функции, которые реально участвуют в частом resync/worker path;
- **compatibility-preserving**: не ломать legacy include graph без необходимости;
- **constant-time math где возможно**: fixed-calendar и fixed-window вычисления не должны использовать лишние циклы.

## 6) Текущее состояние на 2026-04-06

- Основной runtime entry path уже переведён на `dl_all_inc`.
- Guarded include-слой остаётся внутренним compatibility-layer.
- Начата поэтапная санитарная чистка с безопасных hot-path helper-оптимизаций.
