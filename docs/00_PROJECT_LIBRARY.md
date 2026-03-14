# Ambient Life v2 — Project Library (навигационный memory-слой)

Дата: 2026-03-14  
Статус: Active  
Роль: единый навигационный слой по идеям, доменам, статусам и source of truth без дублирования нормативки.

---

## 1) Архитектура библиотеки

Библиотека документации разделена на три уровня:

1. **Канон и нормативка (source of truth)**  
   Это документы, где принимаются правила системы: `12A/12B/12C/12D/12E`, профильные operational/runtime тома (`02/03/04/06/07/10_NPC_RESPAWN...`).

2. **Навигация и память (этот слой)**  
   `00_PROJECT_LIBRARY.md` + `16_IDEA_INVENTORY_AND_SYNC_MAP.md` + `docs/library/*`.  
   Задача — связать уже принятые решения и показать «куда идти», а не переписывать правила.

3. **Планирование и контроль исполнения**  
   `05_STATUS_AUDIT.md`, `08_STAGE_I3_TRACKER.md`, `09_LEGAL_REINFORCEMENT_SMOKE.md`, `10_DECISIONS_LOG.md`.

### Жёсткие правила библиотеки

- Один тип знания = один главный источник.
- Библиотека не вводит новый master-plan и не переписывает канонические тома.
- Любая idea-card обязана ссылаться на runtime/код и DEC-записи (если есть).
- При конфликте формулировок приоритет у канонического источника, а не у библиотеки.

---

## 2) Domain index (верхнеуровневая карта доменов)

| Домен | Главный источник | Статус домена | Что покрывает |
|---|---|---|---|
| Runtime orchestration | `docs/12B_RUNTIME_MASTER_PLAN.md` | Реализовано (Stage I.2), расширение Planned (I.3) | lifecycle, dispatch, route/transition/sleep/activity, reactive/city, population |
| World/legal canon | `docs/12A_WORLD_MODEL_CANON.md` | Канон | realm/settlement/owner, law profiles, citizenship, authority, documents, crime/witness/alarm |
| Player property | `docs/12C_PLAYER_PROPERTY_SYSTEM.md` | Канон (дизайн) | классы имущества, доступ, хранение, переходы |
| World travel | `docs/12D_WORLD_TRAVEL_CANON.md` | Канон (дизайн) | node/edge travel, land/sea pipelines, encounters, engine limits |
| Trade & city state | `docs/12E_TRADE_AND_CITY_STATE_CANON.md` | Канон (дизайн) | city scales, retail vs supply, crisis ladder, respawn influence |
| Stage I.3 delivery | `docs/08_STAGE_I3_TRACKER.md` | Planned | reinforcement/legal pipeline + контроль готовности |
| Architectural decisions | `docs/10_DECISIONS_LOG.md` | Active | DEC-решения и компромиссы |

---

## 3) Где что обновлять (anti-duplication routing)

- Меняется **правило мира/закона** → сначала `12A`.
- Меняется **runtime-механика/контракты/операции** → сначала `02/03/04/06/07` (или профильный runtime-док), потом синк в `12B`.
- Меняется **trade/city-state** → сначала `12E`.
- Меняется **property** → сначала `12C`.
- Меняется **travel** → сначала `12D`.
- Добавляется/меняется **архитектурное решение** → `10_DECISIONS_LOG.md`.
- Обновляется **инвентарь идей и cross-link карта** → `16_IDEA_INVENTORY_AND_SYNC_MAP.md`.

---

## 4) DEC -> Домены -> Идеи (текущее состояние)

| DEC | Суть | Домены/идеи |
|---|---|---|
| DEC-2026-03-14-001 | `12_MASTER_PLAN` — индекс, `12B` — runtime-свод, `README` — обзор | Governance документации, Runtime orchestration |
| DEC-2026-03-14-002 | Trade/city-state выделены в отдельный канонический том `12E` | Trade & city state |
| DEC-2026-03-14-003 | Project Library оформлен как navigation/memory слой без дублирования канона | Documentation governance, Idea inventory |

---

## 5) Единый шаблон idea-card

Шаблон хранится в: `docs/library/IDEA_CARD_TEMPLATE.md`.

Минимальные обязательные поля каждой идеи:
1. Статус (`Реализовано / Канон / Planned / Draft`).
2. Домен.
3. Главный источник (source of truth).
4. Связанные документы.
5. Связанные runtime-файлы.
6. Связанные DEC-решения.
7. «Не путать с» (явные анти-дубли).

---

## 6) Карта файлов библиотеки

- `docs/00_PROJECT_LIBRARY.md` — архитектура библиотеки и routing-правила.
- `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md` — актуальный инвентарь идей с cross-links и anti-confusion.
- `docs/library/DOMAIN_INDEX.md` — сжатый индекс доменов и их primary sources.
- `docs/library/IDEA_CARD_TEMPLATE.md` — единый шаблон карточки идеи.

