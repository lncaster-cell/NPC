# Ambient Life v2 — MASTER PLAN (краткий индекс)

Дата: 2026-04-11
Статус: навигационный индекс (вторичен относительно канона)

---

## 1) Роль файла

`12_MASTER_PLAN.md` — это короткий маршрут чтения и синхронизации.
Документ не заменяет канон и не хранит детальные runtime-алгоритмы.

---

## 2) Канонический маршрут по задачам

1. **Канон (SoT)**
   - `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
   - `docs/runtime/06_SYSTEM_INVARIANTS.md`
   - `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`

2. **Активная разработка v2**
   - `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
   - `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
   - `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
   - `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

3. **Реестр и доменная навигация**
   - `docs/library/DOCUMENT_REGISTRY.md`
   - `docs/library/DOMAIN_INDEX.md`

4. **Аудиты/traceability**
   - `docs/audits/30_AUDIT_AND_INSPECTION_INDEX.md`

---

## 3) Правило приоритета при конфликте формулировок

`SoT-канон` → `runtime invariants/baseline` → `rewrite program` → `governance/entry`.

---

## 4) Определение «документация актуальна»

Документация считается актуальной, если:
- ссылки соответствуют реально существующим файлам,
- в control panel отражён текущий этап и ближайший шаг,
- README и entry-слой не расходятся с runtime baseline,
- канонические границы Daily Life не размыты в служебных документах,
- не создаются новые digest-документы вместо обновления канонического маршрута.
