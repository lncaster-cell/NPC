# Daily Life v1 — Runtime Contour Event-Driven Audit

Дата: 2026-04-07  
Статус: completed (static code+docs audit)  
Цель: провести целевой аудит «почему контур не заработал» с фокусом на event-driven архитектуру, зафиксировать runtime-контур Daily Life и выдать чёткий отчёт по соответствию кода документации.

---

## 1) Executive summary

1. **Архитектура в коде event-driven присутствует**, но её работоспособность критически зависит от корректной привязки скриптов к engine hooks (Area/NPC события).  
2. Критическая точка отказа в реальном запуске с отрицательным результатом чаще всего — **неполная или неверная binding-конфигурация в Toolset**, а не только resolver/materialize код.  
3. Для повышения жёсткости event-driven пути внесена правка: `OnSpawn` и `OnDeath` теперь идут через `OnUserDefined` dispatcher, а не прямым вызовом hook-функций.

---

## 2) Что было проверено

### 2.1 Документация (контур и нормы)
- `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_STATE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md`
- `docs/runtime/26_DAILY_LIFE_V1_TECHNICAL_SPEC_RU.md`

### 2.2 Код (фактический runtime)
- area hooks: `dl_area_enter`, `dl_area_exit`, `dl_area_tick`, `dl_on_load`
- npc hooks: `dl_npc_onspawn`, `dl_npc_onud`, `dl_npc_ondeath`
- producer bridges: `dl_npc_onperception`, `dl_npc_onphysicalattacked`, `dl_npc_ondamaged`, `dl_npc_onspellcastat`, `dl_npc_ondisturbed`
- hook dispatcher и debounce: `dl_npc_hooks_inc`

---

## 3) Чёткий runtime-контур Daily Life (операционный)

1. **Area lifecycle запускает контур**: `OnEnter/OnExit/OnHeartbeat/OnLoad` определяют tier и запускают bounded worker/resync.
2. **NPC lifecycle даёт реактивный вход**: `OnSpawn`/`OnDeath`/`OnUserDefined` формируют жизненный цикл NPC.
3. **Noisy hooks только producer-bridge**: perception/attacked/damaged/spell/disturbed не делают heavy work, а подают сигнал в `OnUserDefined`.
4. **`OnUserDefined` — центральный event dispatcher**: bootstrap/resync/cleanup/producer events сводятся в единый thin path.
5. **Worker+resync запускают resolver/materialization**, после чего фиксируются interaction состояния.

Итог: контур соответствует модели «area-centric + event-driven + bounded worker». Heartbeat используется как gate/dispatch trigger для area worker, а не как per-NPC full loop.

---

## 4) Найденные расхождения / риски

### R1 (Critical, operational): Binding gap risk
Если в Toolset не назначены обязательные скрипты на hooks (`OnUserDefined` в первую очередь), event-driven контур фактически не стартует или работает частично. По runbook это обязательное условие, но на практике этот шаг часто пропускается.

### R2 (High): Симптом «система не использует event-driven scripts»
Симптом совпадает с ситуацией, когда работает только часть area-скриптов, а NPC-hook слой не подключён полностью (или подключён legacy-скриптами без dispatcher path).

### R3 (Medium): Разрыв между owner-ожиданием и runtime-fact
Документация описывает корректную модель, но при неполных bindings внешний эффект выглядит как «архитектура неверная», хотя фактическая причина — эксплуатационная конфигурация запуска.

---

## 5) Изменения по результату аудита

### 5.1 Code hardening
- `dl_npc_onspawn`: переведён на `DL_SignalNpcUserDefined(..., DL_UD_BOOTSTRAP)`.
- `dl_npc_ondeath`: переведён на `DL_SignalNpcUserDefined(..., DL_UD_CLEANUP)`.

Этим шагом жизненный цикл NPC принудительно проходит через централизованный `OnUserDefined` dispatcher, что уменьшает риск «расщеплённого» поведения между hook-скриптами.

### 5.2 Documentation hardening
- Добавлена запись в runtime activity journal с фиксацией централизации spawn/death через `OnUserDefined`.
- Обновлён индекс аудитов с новым отчётом.
- Добавлена запись координации в communication log для мультиагентной наблюдаемости.

---

## 6) Отчёт соответствия docs ↔ code

### 6.1 Соответствует
- Event-driven trigger-matrix (area + npc + producer hooks).
- HOT/WARM/FROZEN tier gate и bounded worker budget.
- Resync pipeline и thin-dispatch в hook-слое.

### 6.2 Условно соответствует (зависит от эксплуатации)
- Полная работоспособность контура требует 100% корректной привязки скриптов в Toolset/module properties.
- Без preflight-checklist перед запуском возможен ложный вывод «код не по документации».

---

## 7) Практический preflight перед следующим owner run

1. Перепроверить area hooks (`OnEnter`, `OnExit`, `OnHeartbeat`) на целевых test areas.
2. Перепроверить NPC hooks минимум: `OnSpawn`, `OnUserDefined`, `OnDeath`.
3. Проверить producer hooks на lightweight-bridge scripts.
4. Включить `dl_smoke_trace=TRUE` и запустить `dl_smoke_milestone_a`.
5. Зафиксировать run ID и статусы A–G в acceptance journal.

---

## 8) Вердикт аудита

- **По архитектуре**: критического отклонения от event-driven модели в текущем коде не обнаружено.
- **По эксплуатации**: обнаружен критический operational risk неполной binding-настройки, способный полностью сорвать запуск.
- **По действиям**: код и документация усилены в сторону централизации dispatcher path и трассируемости для мультиагентной работы.
