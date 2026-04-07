# Documentation ↔ Code Inspection (2026-04-01)

Дата: 2026-04-01  
Аудитор: Codex  
Scope: `docs/*` (ключевые Daily Life документы) + `scripts/daily_life/*`.

---

## 1) Краткий итог

Текущий runtime-код Milestone A в `scripts/daily_life/` в целом консистентен внутри себя (tier gate, budget, enter/exit hooks), но часть документов остаётся в смешанном состоянии: рядом с актуальным контрактом есть исторические или vNext-формулировки, которые читаются как текущие требования.

---

## 2) Подтверждённые расхождения (docs vs runtime)

### I-01 (высокий): `DATA_CONTRACTS` существенно шире и в ряде пунктов несовместим с текущими enum/runtime names

**Наблюдение:**
- В `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md` описаны enum-ветки, которых нет в текущем коде (`DL_SUB_LAW_PATROL`, `DL_DAY_NORMAL`, расширенные override и activity наборы).
- В runtime используются другие имена и более узкий набор (`DL_SUBTYPE_PATROL`, `DL_DAY_WEEKDAY`, `DL_OVR_FIRE/QUARANTINE`, и т.д.).

**Риск:**
- Для реализации/ревью можно выбрать неверные идентификаторы из документа и получить ложный "контракт" относительно кода Milestone A.

**Рекомендация:**
- Либо зафиксировать файл как `vNext draft (non-runtime SoT)` в явной шапке,
- либо выпустить отдельный `V1_RUNTIME_DATA_CONTRACTS` с 1:1 именами из `dl_const_inc.nss`.

---

### I-02 (средний): Runtime Pipeline формально описывает WARM как prep-only, но код исполняет ограниченный worker в WARM

**Наблюдение:**
- `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md` описывает "полноценно только HOT" и "WARM как подготовительный слой".
- В коде `DL_ShouldRunDailyLifeTier` возвращает `TRUE` для `HOT` и `WARM`; budget для WARM = 2.

**Риск:**
- Команда может трактовать WARM как полностью без worker-dispatch и ошибочно отбрасывать ожидаемую ограниченную обработку.

**Рекомендация:**
- Внести в Runtime Pipeline явную формулу: `HOT=full budget`, `WARM=limited budget`, `FROZEN=stop`.

---

### I-03 (средний): System Invariants ссылается на legacy путь и использует `FREEZE` вместо `FROZEN`

**Наблюдение:**
- `docs/runtime/06_SYSTEM_INVARIANTS.md` как источник указывает `scripts/ambient_life/*`.
- В том же файле tier указан как `FREEZE/WARM/HOT`, тогда как в runtime-константах используется `FROZEN`.

**Риск:**
- Ошибка терминов/путей ухудшает трассируемость инвариантов к фактическому коду.

**Рекомендация:**
- Синхронизировать термин (`FROZEN`) и путь на `scripts/daily_life/*` (или явно пометить legacy scope).

---

## 3) Что проверить следующим проходом

1. Отделить документы уровня `vNext vision` от `Milestone A runtime SoT` явными шапками/лейблами.
2. Собрать короткую таблицу соответствия `doc enum -> code const` для 20–30 ключевых идентификаторов.
3. После owner-решения зафиксировать единый статус WARM-policy в `12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md` и `21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`.

---

## 4) Примечание о границах

Этот отчёт не вводит новую механику. Он фиксирует инспекционные расхождения формулировок и контрактов между документацией и текущим runtime-кодом Milestone A.
