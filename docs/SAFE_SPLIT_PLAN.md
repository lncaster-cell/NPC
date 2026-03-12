# Safe split plan for large NWScript includes

Цель: уменьшить когнитивную нагрузку и упростить сопровождение без изменения runtime-поведения Stage A–I.2.

## Почему разделять нужно точечно

Текущая архитектура уже модульная по подсистемам (area/route/sleep/react/blocked), а core-диспетчер их оркестрирует через include-границы.
Из-за этого «резать всё по размеру» не нужно: полезно выносить только тематические кластеры с чёткими границами ответственности.

## Кандидаты на безопасное выделение (приоритет)

1. `scripts/ambient_life/al_area_inc.nss`
   - выделить lookup-cache helper блок в отдельный include (`al_lookup_cache_inc.nss`),
   - выделить health snapshot helper блок в отдельный include (`al_health_inc.nss`).

2. `scripts/ambient_life/al_react_inc.nss`
   - отделить классификацию инцидентов и debounce-слой от реакции ролей (`civilian/militia/guard`).

3. `scripts/ambient_life/al_route_inc.nss`
   - отделить route cache build/validation от runtime progression.

## Жёсткие ограничения (не нарушать)

- Не менять event IDs и контракт шины (`3100..3108`).
- Не менять смысл locals из toolset/runtime contract.
- Не менять ownership центрального area-loop (`AL_ScheduleAreaTick` / `AL_AreaTick`).
- Любой split должен быть text-equivalent: сначала перенос кода без изменения логики.

## Безопасная процедура (по одному файлу за PR)

1. **Extract-only PR**
   - перенести связанный блок функций в новый `*_inc.nss`,
   - подключить через `#include`,
   - сохранить имена функций и сигнатуры без изменений.

2. **Compile/smoke check**
   - импорт скриптов в тестовый модуль,
   - smoke-сценарий: spawn/death, slot-switch, resync, blocked-resume, disturbed.

3. **Perf sanity**
   - сравнить базовые метрики (`queue depth`, `ticks_to_drain`, cache hit/miss),
   - убедиться в отсутствии деградации.

4. **Только после этого** допускается локальный cleanup
   - удаление дублирующих helper-функций,
   - минимальный rename (если нужен) отдельным PR.

## Риски и как их снизить

- Риск скрытых зависимостей между helper-функциями.
  - Митигировать: выносить contiguous-блоки, а не «россыпью».

- Риск смены порядка include.
  - Митигировать: сначала сохранить прежний порядок и выносить только leaf-хелперы.

- Риск регрессий в bounded runtime.
  - Митигировать: обязательный smoke + perf sanity после каждого extract-only шага.

## Минимальный первый шаг (рекомендация)

Стартовать с `al_area_inc.nss`: вынести только lookup-cache helper-блок, без изменения публичных API, и проверить smoke/perf.
Это даёт выигрыш в читаемости при минимальном риске для event-driven runtime.
