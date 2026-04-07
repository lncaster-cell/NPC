# Documentation ↔ Code Inspection (2026-04-02)

Дата: 2026-04-02  
Аудитор: Codex  
Scope: `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md` + `scripts/daily_life/dl_const_inc.nss`.

---

## 1) Цель прохода

Продолжение инспекции после предыдущего отчёта (2026-04-01): перевести расхождение по enum-названиям из общего замечания в явный операционный артефакт, пригодный для ежедневной разработки и ревью.

---

## 2) Что проверено

1. Сверка ключевых enum/const из `DATA_CONTRACTS` с фактическим runtime-набором в `dl_const_inc.nss`.
2. Проверка area-tier и budget-контура (`FROZEN/WARM/HOT`, `0/2/6`) на предмет сохранения 1:1 формулировки.
3. Проверка override-набора на предмет совпадений и отсутствующих vNext позиций.

---

## 3) Результат

### R-01: Добавлена встроенная таблица соответствия spec→runtime

В `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md` добавлен новый блок **«Быстрая сверка с Milestone A runtime (2026-04-02)»** с таблицей соответствий и статусами:
- `renamed in runtime` (например, `DL_SUB_LAW_PATROL` -> `DL_SUBTYPE_PATROL`),
- `semantic rename` (`DL_DAY_NORMAL` -> `DL_DAY_WEEKDAY`),
- `not present in Milestone A` (ряд vNext enum-ов),
- `matches` (например, `DL_OVR_FIRE`, `DL_AREA_*`).

### R-02: Критическое расхождение docs↔code по tier budget не обнаружено

По результату текущего прохода: формула `HOT=6`, `WARM=2`, `FROZEN=0` и имена `DL_AREA_FROZEN/WARM/HOT` остаются согласованными между документами и кодом.

---

## 4) Рекомендация на следующий шаг

Если команда подтвердит, что `DATA_CONTRACTS` будет использоваться как рабочая спецификация Milestone A (а не только vNext draft), стоит вынести таблицу соответствия в отдельный «runtime appendix» и сделать её обязательной к обновлению при изменении `dl_const_inc.nss`.
