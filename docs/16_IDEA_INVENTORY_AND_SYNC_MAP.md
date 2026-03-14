# Ambient Life v2 — IDEA INVENTORY & SYNC MAP

Дата: 2026-03-14
Статус: Active
Назначение: единый инвентарь идей проекта с source of truth, статусами, runtime-привязкой и anti-duplication заметками.

---

## 1) Правила использования

1. Этот файл — **memory и navigation слой**, а не новый канонический том.
2. Для каждой идеи указан **один главный источник** (SoT).
3. При конфликте формулировок приоритет у SoT-документа.
4. Новые архитектурные решения добавляются в `docs/10_DECISIONS_LOG.md`, затем привязываются здесь.
5. Общая архитектура и канон не переписываются в этом реестре — только индексация и синхронизация.

---

## 2) Mapping: идея → источник истины → статус → код/доки

| Идея | Статус | Домен | Source of truth | Связанные документы | Связанные runtime-файлы | Связанные DEC | Не путать с |
|---|---|---|---|---|---|---|---|
| Area-centric orchestration + bounded event-driven runtime | Реализовано (база) | Runtime | `docs/12B_RUNTIME_MASTER_PLAN.md` | `docs/06_SYSTEM_INVARIANTS.md`, `docs/02_MECHANICS.md`, `README.md` | `scripts/ambient_life/al_core_inc.nss`, `al_area_inc.nss`, `al_area_tick.nss`, `al_dispatch_inc.nss`, `al_events_inc.nss` | DEC-2026-03-14-001 | Per-NPC heartbeat архитектура |
| Registry/cache/dispatch discipline | Реализовано | Runtime | `docs/12B_RUNTIME_MASTER_PLAN.md` | `docs/05_STATUS_AUDIT.md`, `docs/07_SCENARIOS_AND_ALGORITHMS.md` | `al_registry_inc.nss`, `al_lookup_cache_inc.nss`, `al_dispatch_inc.nss` | DEC-2026-03-14-001 | Глобальный world-scan регистр |
| Routine pipeline (route/transition/sleep/activity/schedule) | Реализовано (Stage I.2) | Runtime | `docs/02_MECHANICS.md` | `docs/12B_RUNTIME_MASTER_PLAN.md`, `docs/05_STATUS_AUDIT.md` | `al_route_inc.nss`, `al_transition_inc.nss`, `al_transition_post_area.nss`, `al_sleep_inc.nss`, `al_activity_inc.nss` | — | Reactive/crime контур |
| Reactive layer (blocked/disturbed) | Реализовано (Stage I.2) | Runtime | `docs/02_MECHANICS.md` | `docs/12B_RUNTIME_MASTER_PLAN.md`, `docs/03_OPERATIONS.md` | `al_blocked_inc.nss`, `al_react_inc.nss`, `al_npc_onblocked.nss`, `al_npc_ondisturbed.nss` | — | Legal pipeline Stage I.3 |
| City crime/alarm FSM | Реализовано (локальный city слой) | Runtime + Legal bridge | `docs/12B_RUNTIME_MASTER_PLAN.md` | `docs/12A_WORLD_MODEL_CANON.md`, `docs/05_STATUS_AUDIT.md` | `al_city_crime_inc.nss`, `al_city_alarm_inc.nss`, `al_city_registry_inc.nss`, `al_npc_ondamaged.nss`, `al_npc_onspellcastat.nss` | — | Полный legal adjudication pipeline |
| Population respawn policy | Реализовано | Runtime | `docs/10_NPC_RESPAWN_MECHANICS.md` | `docs/12B_RUNTIME_MASTER_PLAN.md`, `docs/05_STATUS_AUDIT.md` | `al_city_population_inc.nss` | — | Экономика/торговля как макросистема |
| NWN2 world/legal 3-layer model | Канон | World/Legal | `docs/12A_WORLD_MODEL_CANON.md` | `README.md`, `docs/12_MASTER_PLAN.md` | `—` | — | Фракции NWN2 как замена правовой модели |
| LawProfile + law modes + enforcement semantics | Канон | World/Legal | `docs/12A_WORLD_MODEL_CANON.md` | `docs/08_STAGE_I3_TRACKER.md`, `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` | `—` | — | Простая reputation/faction реакция |
| Citizenship / titles / authority grants / document validation | Канон | World/Legal | `docs/12A_WORLD_MODEL_CANON.md` | `docs/12C_PLAYER_PROPERTY_SYSTEM.md` | `—` | — | Только inventory ownership без правовых прав |
| Crime/witness/alarm legal chain | Канон + Planned runtime delivery | World/Legal + Runtime | `docs/12A_WORLD_MODEL_CANON.md` | `docs/08_STAGE_I3_TRACKER.md`, `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` | partial hooks: `al_react_inc.nss` (`al_legal_followup_pending`) | — | Уже полностью реализованный trial pipeline |
| Stage I.3 reinforcement policy | Planned | Runtime/Operations | `docs/08_STAGE_I3_TRACKER.md` | `docs/09_LEGAL_REINFORCEMENT_SMOKE.md`, `docs/03_OPERATIONS.md` | (target subsystem) city/react/legal hooks | — | Текущий Stage I.2 alarm FSM |
| Stage I.3 surrender→arrest→legal followup/trial | Planned | Runtime + Legal | `docs/08_STAGE_I3_TRACKER.md` | `docs/09_LEGAL_REINFORCEMENT_SMOKE.md`, `docs/12A_WORLD_MODEL_CANON.md` | future from `al_react_inc.nss` legal hook | — | Crime/alarm detection без legal handoff |
| Stage I.3 QA smoke runbook | Draft (готов к активации) | QA/Operations | `docs/09_LEGAL_REINFORCEMENT_SMOKE.md` | `docs/08_STAGE_I3_TRACKER.md`, `docs/03_OPERATIONS.md` | `—` | — | Полный регрессионный тест-план |
| Player property system | Канон (дизайн) | Property | `docs/12C_PLAYER_PROPERTY_SYSTEM.md` | `docs/12A_WORLD_MODEL_CANON.md`, `docs/12_MASTER_PLAN.md` | `—` | — | Trade/city supply экономика |
| World travel system | Канон (дизайн) | Travel | `docs/12D_WORLD_TRAVEL_CANON.md` | `docs/12_MASTER_PLAN.md`, `docs/03_OPERATIONS.md` | `—` | — | Простые ad-hoc телепорты |
| Trade & city state macro-system | Канон (дизайн) | Trade/Economy | `docs/12E_TRADE_AND_CITY_STATE_CANON.md` | `docs/12_MASTER_PLAN.md`, `docs/10_DECISIONS_LOG.md` | `—` | DEC-2026-03-14-002 | Розничная торговля как вся экономика |
| Docs governance: index vs canonical volumes | Принято и активно | Documentation governance | `docs/12_MASTER_PLAN.md` | `README.md`, `docs/10_DECISIONS_LOG.md`, `docs/00_PROJECT_LIBRARY.md` | `—` | DEC-2026-03-14-001, DEC-2026-03-14-003 | Новый «супер master-plan» поверх томов |

---

## 3) Потенциальные дубли и конфликтующие формулировки

1. **`README.md` vs `12B` по runtime-покрытию**
   Риск: воспринимать README как нормативку.
   Разрешение: runtime-нормативка только в `12B` + профильных runtime-доках.

2. **`08_STAGE_I3_TRACKER.md` vs `09_LEGAL_REINFORCEMENT_SMOKE.md`**
   Риск: смешение статусов задач и QA-критериев.
   Разрешение: `08` = статус этапа, `09` = сценарии smoke/acceptance.

3. **Crime/alarm runtime реализация vs legal канон**
   Риск: считать city alarm FSM завершённой legal системой.
   Разрешение: `12A` фиксирует канон legal-цепочки, `08` фиксирует что Stage I.3 ещё Planned.

4. **Trade/City-state vs Population respawn**
   Риск: смешивать макроэкономику (`12E`) и runtime policy респауна (`10_NPC_RESPAWN...`).
   Разрешение: торговый домен задаёт состояние города; runtime-док задаёт технику исполнения респауна.

---

## 4) Зоны без полной формализации

1. Конкретные DEC-записи для Stage I.3 ещё не добавлены (есть только трекер и smoke-runbook).
2. Интеграция clan/aging дизайна в legal/world канон остаётся roadmap-зоной.
3. Для property/travel/trade пока отсутствуют runtime-реализационные тома уровня Stage I.* (есть канон-дизайн).

---

## 5) Синхронизация (операционный чек)

- При изменении идеи обновлять эту карту и проверять `docs/00_PROJECT_LIBRARY.md`.
- Если change архитектурный — добавить DEC, затем проставить DEC-link в таблице.
- Если идея меняет runtime состояние — синхронизировать `02/03/04/05/08/12B` по зоне ответственности.
