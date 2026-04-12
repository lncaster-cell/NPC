# Ambient Life v2 — IDEA INVENTORY & SYNC MAP

Дата: 2026-04-12
Статус: Active
Назначение: единый инвентарь идей проекта с source of truth, статусами, runtime-привязкой и anti-duplication заметками.

---

> ℹ️ Runtime-привязка в таблице синхронизирована с `daily_life/*` (проверка 2026-04-12). Для legacy-имен `al_*` используйте `docs/runtime/12B_DAILY_LIFE_V1_LEGACY_TO_RUNTIME_MAPPING.md`.
> 
> Path-policy (дословно):
> Канонический runtime workspace path: `daily_life/`.
> Любые упоминания `scripts/daily_life/` считаются legacy и не используются для новых шагов.

---

## 1) Правила использования

1. Этот файл — **memory и navigation слой**, а не новый канонический том.
2. Для каждой идеи указан **один главный источник** (SoT).
3. При конфликте формулировок приоритет у SoT-документа.
4. Новые архитектурные решения добавляются в `docs/governance/10_DECISIONS_LOG.md`, затем привязываются здесь.
5. Общая архитектура и канон не переписываются в этом реестре — только индексация и синхронизация.

---

## 2) Mapping: идея → источник истины → статус → код/доки

| Идея | Статус | Домен | Source of truth | Связанные документы | Связанные runtime-файлы | Связанные DEC | Не путать с |
|---|---|---|---|---|---|---|---|
| Area-centric orchestration + bounded event-driven runtime | Реализовано (база) | Runtime | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` | `docs/runtime/06_SYSTEM_INVARIANTS.md`, `docs/runtime/02_MECHANICS.md`, `README.md` | `daily_life/dl_area_tick.nss`, `daily_life/dl_area_inc.nss`, `daily_life/dl_worker_inc.nss`, `daily_life/dl_types_inc.nss` | DEC-2026-03-14-001 | Per-NPC heartbeat архитектура |
| Registry/cache/dispatch discipline | Реализовано | Runtime | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` | `docs/governance/18_REBUILD_RESET_CONTEXT.md`, `docs/runtime/07_SCENARIOS_AND_ALGORITHMS.md` | `dl_worker_inc.nss`, `dl_util_inc.nss`, `dl_log_inc.nss` | DEC-2026-03-14-001 | Глобальный world-scan регистр |
| Routine pipeline (route/transition/sleep/activity/schedule) | Реализовано (Stage I.2) | Runtime | `docs/runtime/02_MECHANICS.md` | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`, `docs/governance/18_REBUILD_RESET_CONTEXT.md` | `dl_schedule_inc.nss`, `dl_activity_inc.nss`, `dl_resolver_inc.nss`, `dl_resync_inc.nss`, `dl_anchor_inc.nss` | — | Reactive/crime контур |
| Полная design-спецификация поведения NPC (state machine + recovery + bounded policy) | Канон (дизайн, специализированный том) | Runtime | `docs/canon/20_NPC_BEHAVIOR_SYSTEM_DESIGN_RU.md` | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`, `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`, `docs/entry/12_MASTER_PLAN.md` | `—` | — | Обзорный runtime summary без полного описания автомата |
| Reactive layer (blocked/disturbed) | Реализовано (Stage I.2) | Runtime | `docs/runtime/02_MECHANICS.md` | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`, `docs/runtime/03_OPERATIONS.md` | `dl_resolver_inc.nss`, `dl_resync_inc.nss`, `dl_interact_inc.nss` | — | Legal pipeline Stage I.3 |
| City crime/alarm FSM | Реализовано (локальный city слой) | Runtime + Legal bridge | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` | `docs/canon/12A_WORLD_MODEL_CANON.md`, `docs/governance/18_REBUILD_RESET_CONTEXT.md` | `dl_resolver_inc.nss`, `dl_override_inc.nss`, `dl_slot_handoff_inc.nss`, `dl_area_inc.nss` | — | Полный legal adjudication pipeline |
| Population respawn policy | Реализовано | Runtime | `docs/runtime/10_NPC_RESPAWN_MECHANICS.md` | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`, `docs/governance/18_REBUILD_RESET_CONTEXT.md` | `dl_area_inc.nss` | — | Экономика/торговля как макросистема |
| NWN2 world/legal 3-layer model | Канон | World/Legal | `docs/canon/12A_WORLD_MODEL_CANON.md` | `README.md`, `docs/entry/12_MASTER_PLAN.md` | `—` | — | Фракции NWN2 как замена правовой модели |
| LawProfile + law modes + enforcement semantics | Канон | World/Legal | `docs/canon/12A_WORLD_MODEL_CANON.md` | `docs/governance/18_REBUILD_RESET_CONTEXT.md`, `docs/runtime/03_OPERATIONS.md` | `—` | — | Простая reputation/faction реакция |
| Citizenship / titles / authority grants / document validation | Канон | World/Legal | `docs/canon/12A_WORLD_MODEL_CANON.md` | `docs/canon/12C_PLAYER_PROPERTY_SYSTEM.md` | `—` | — | Только inventory ownership без правовых прав |
| Crime/witness/alarm legal chain | Канон + Planned runtime delivery | World/Legal + Runtime | `docs/canon/12A_WORLD_MODEL_CANON.md` | `docs/governance/18_REBUILD_RESET_CONTEXT.md`, `docs/runtime/03_OPERATIONS.md` | partial hooks: `dl_resolver_inc.nss` (`al_legal_followup_pending`) _(legacy reference)_ | — | Уже полностью реализованный trial pipeline |
| Court mechanics (evidence/hearing/verdict/sanctions) | Канон (дизайн) + Planned runtime delivery | World/Legal + Runtime | `docs/canon/12A_WORLD_MODEL_CANON.md` | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md`, `docs/runtime/03_OPERATIONS.md` | `—` | DEC-2026-03-15-004 | Только арест без процессуального продолжения |
| Stage I.3 reinforcement policy | Planned | Runtime/Operations | `docs/governance/18_REBUILD_RESET_CONTEXT.md` | `docs/runtime/03_OPERATIONS.md` | (target subsystem) city/react/legal hooks | — | Текущий Stage I.2 alarm FSM |
| Stage I.3 surrender→arrest→case intake→trial→sentence | Planned | Runtime + Legal | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` | `docs/runtime/03_OPERATIONS.md`, `docs/canon/12A_WORLD_MODEL_CANON.md`, `docs/governance/18_REBUILD_RESET_CONTEXT.md` | future from `dl_resolver_inc.nss` legal hook _(legacy reference)_ | DEC-2026-03-15-004 | Crime/alarm detection без legal handoff |
| Stage I.3 QA smoke runbook | Draft (готов к активации) | QA/Operations | `docs/runtime/03_OPERATIONS.md` | `docs/governance/18_REBUILD_RESET_CONTEXT.md`, `docs/runtime/03_OPERATIONS.md` | `—` | — | Полный регрессионный тест-план |
| Player property system | Канон (дизайн) | Property | `docs/canon/12C_PLAYER_PROPERTY_SYSTEM.md` | `docs/canon/12A_WORLD_MODEL_CANON.md`, `docs/entry/12_MASTER_PLAN.md` | `—` | — | Trade/city supply экономика |
| World travel system | Канон (дизайн) | Travel | `docs/canon/12D_WORLD_TRAVEL_CANON.md` | `docs/entry/12_MASTER_PLAN.md`, `docs/runtime/03_OPERATIONS.md` | `—` | — | Простые ad-hoc телепорты |
| Trade & city state macro-system | Канон (дизайн) | Trade/Economy | `docs/canon/12E_TRADE_AND_CITY_STATE_CANON.md` | `docs/entry/12_MASTER_PLAN.md`, `docs/governance/10_DECISIONS_LOG.md` | `—` | DEC-2026-03-14-002 | Розничная торговля как вся экономика |
| Docs governance: index vs canonical volumes | Принято и активно | Documentation governance | `docs/entry/12_MASTER_PLAN.md` | `README.md`, `docs/governance/10_DECISIONS_LOG.md`, `docs/entry/00_PROJECT_LIBRARY.md` | `—` | DEC-2026-03-14-001, DEC-2026-03-14-003 | Новый «супер master-plan» поверх томов |

---

## 3) Потенциальные дубли и конфликтующие формулировки

1. **`README.md` vs `12B` по runtime-покрытию**
   Риск: воспринимать README как нормативку.
   Разрешение: runtime-нормативка только в `12B` + профильных runtime-доках.

2. **`18_REBUILD_RESET_CONTEXT.md` vs `03_OPERATIONS.md`**
   Риск: смешение статусов задач и QA-критериев.
   Разрешение: статус и ограничения этапа фиксируются в `18`, операционные правила — в `03`.

3. **Crime/alarm runtime реализация vs legal канон**
   Риск: считать city alarm FSM завершённой legal системой.
   Разрешение: `12A` фиксирует канон legal-цепочки, а статус текущего этапа отражён в `18`.

4. **Trade/City-state vs Population respawn**
   Риск: смешивать макроэкономику (`12E`) и runtime policy респауна (`10_NPC_RESPAWN...`).
   Разрешение: торговый домен задаёт состояние города; runtime-док задаёт технику исполнения респауна.

---

## 4) Зоны без полной формализации

1. Конкретные DEC-записи для новой реализации должны добавляться по мере уточнения архитектуры.
2. Формализация судебной процессуальной модели начата в `12A/12B`, runtime-реализация остаётся roadmap-зоной.
3. Интеграция clan/aging дизайна в legal/world канон остаётся roadmap-зоной.
4. Для property/travel/trade пока отсутствуют runtime-реализационные тома уровня Stage I.* (есть канон-дизайн).

---

## 5) Синхронизация (операционный чек)

- При изменении идеи обновлять эту карту и проверять `docs/entry/00_PROJECT_LIBRARY.md`.
- Если change архитектурный — добавить DEC, затем проставить DEC-link в таблице.
- Если идея меняет runtime состояние — синхронизировать `02/03/04/12B/18` по зоне ответственности.
