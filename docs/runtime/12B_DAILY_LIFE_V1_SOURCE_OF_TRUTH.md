# Ambient Life v2 — Daily Life v1 Source of Truth Map

Дата: 2026-04-07  
Статус: active  
Назначение: единая точка правды по документам Daily Life v1, чтобы не дублировать одинаковые reference-блоки в runtime-доках.

---

## 1) Канонический набор для реализации

Использовать в таком приоритете:
1. `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md` — канонический ruleset-контракт v1.
2. `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md` — контракты enum/state/API.
3. `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md` — последовательность исполнения и границы подсистем.
4. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md` — верхнеуровневый дизайн-контекст.

## 2) Исторические документы

- `docs/archive/12B_DAILY_LIFE_V1_RULESET_legacy_2026-03-20.md` — legacy-pointer.
- Исторический полный текст legacy-версии восстанавливается через git-history по этому пути.

## 3) Sleep-status source of truth

- Канонический статус-документ: `docs/runtime/55_DAILY_LIFE_SLEEP_SCENARIO_OWNER_STATUS_RU.md`.
- Архивированный заменённый документ: `docs/archive/56_DAILY_LIFE_SLEEP_SCENARIO_TEMP_STATUS_RU.md`.

## 4) Правило против расхождений

Если возникает конфликт между документами:
- принимать сторону `RULESET_REV1` + `DATA_CONTRACTS` + `RUNTIME_PIPELINE`;
- legacy и архивные материалы использовать только как исторический контекст.
