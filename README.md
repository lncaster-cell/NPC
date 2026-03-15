# Ambient Life v2 — Project README

`PycukSystems` — это design library «живого мира» для NWN2. Проект в текущем состоянии ведётся в **documentation/design mode**: runtime-код был сброшен, а репозиторий используется как архитектурная база и канонический набор проектных документов.

Этот README синхронизирован с `docs/architecture/01_PROJECT_PASSPORT.md` и даёт короткую карту: **какие домены есть, где их границы и куда идти за source-of-truth**.

> ⚠️ Контекст reset/rebuild: см. `docs/18_REBUILD_RESET_CONTEXT.md`.

---

## 1) Формула проекта

**Ambient Life v2 = повседневная жизнь NPC + правовой порядок мира + городская оперативная реакция + длинные социально-экономические последствия в единой модели.**

Ключевой принцип: фракции NWN2 — это инструмент локального ИИ, а не замена права, собственности, институтов и политической структуры мира.

---

## 2) Домены верхнего уровня (по паспорту)

1. **NPC Daily Life**
   - Повседневный контур: lifecycle, schedule/route/transition, sleep/activity, локальные отклонения и возврат к рутине.
   - Primary source: `docs/12B_RUNTIME_MASTER_PLAN.md`.

2. **City Response**
   - Оперативная реакция города на нарушение порядка: alarm/escalation/de-escalation, response units, уличная проекция городского состояния.
   - Primary source: `docs/12B_RUNTIME_MASTER_PLAN.md` + связка с `docs/12E_TRADE_AND_CITY_STATE_CANON.md`.

3. **Legal / World Model**
   - Устойчивая правовая «правда мира»: realm/settlement/owner, law profiles, документы, статусы, легитимность институтов.
   - Primary source: `docs/12A_WORLD_MODEL_CANON.md`.

4. **Witness / Crime / Arrest / Trial**
   - Процессуальная цепочка от инцидента к юридической квалификации и институциональному действию.
   - На уровне паспорта выделено как отдельный концептуальный поддомен; формат окончательной канонизации — frontier-зона.

5. **Player Property**
   - Право владения, доступ, ограничения, конфискация и связка имущества с legal-контуром.
   - Primary source: `docs/12C_PLAYER_PROPERTY_SYSTEM.md`.

6. **World Travel**
   - Межрегиональная география и перенос последствий между settlement-узлами мира.
   - Primary source: `docs/12D_WORLD_TRAVEL_CANON.md`.

7. **Trade / City State**
   - Макроуровень снабжения, дефицита, кризисов и городского состояния.
   - Primary source: `docs/12E_TRADE_AND_CITY_STATE_CANON.md`.

8. **Clan System**
   - Политико-социальный слой кланов, отношений и долгих последствий.
   - Primary source: `docs/14_CLAN_SYSTEM_DESIGN.md`.

9. **Aging / Succession**
   - Возрастные циклы и наследование как долгий исторический контур мира.
   - Primary source: `docs/13_AGING_AND_CLAN_SUCCESSION.md`.

---

## 3) Концептуальный поток (без runtime-реализации)

1. Daily Life создаёт нормальный фон мира.
2. Происходит инцидент.
3. Witness/Crime-цепочка превращает событие в юридически значимый сигнал.
4. Legal/World Model квалифицирует событие и статус участников.
5. City Response выполняет оперативный ответ в городе.
6. Запускаются длинные последствия для Property, Clan, Trade/City State, Aging/Succession.
7. World Travel переносит эффекты между регионами.

---

## 4) Границы доменов, которые нельзя размывать

- **Daily Life ≠ City Response**: рутина и мягкие отклонения не равны режиму городского реагирования.
- **City Response ≠ Legal System**: исполнение и оперативное поведение не равны правовой квалификации.
- **Legal System ≠ Clan Consequences**: правовой статус и социально-политический резонанс — разные слои.
- **Property ≠ Camp-сценарии**: временный режим не создаёт новый правовой домен.
- **World Travel ≠ Local Movement**: межрегиональные перемещения отделены от area-локомоции.
- **Trade/City-State ≠ Runtime Population Response**: макроэкономика и уличная оперативная проекция — разные масштабы.

---

## 5) Инварианты архитектуры

- Не возвращаться к per-NPC heartbeat как базовой модели.
- Не строить ключевую логику на world-wide full scan.
- Не подменять правовую модель только фракциями движка.
- Не «лечить» системные проблемы ручной правкой служебных locals.
- Все тяжёлые контуры должны быть bounded, наблюдаемыми и управляемыми по бюджету.

---

## 6) Что сейчас в frontier (открытые зоны)

1. Граница ownership на стыках Legal ↔ Property ↔ Clan.
2. Степень самостоятельности домена Witness/Crime/Arrest/Trial в каноне.
3. Чистая связка City Response ↔ Trade/City State без смешения масштабов.
4. Граница Clan System ↔ Aging/Succession.
5. Единая терминология и anti-confusion дисциплина по библиотеке.

Решения по этим зонам закрываются профильными канонами и decisions-процессом, а не README.

---

## 7) Рекомендуемый маршрут чтения

1. `docs/architecture/01_PROJECT_PASSPORT.md` — карта доменов и границ.
2. `docs/12_MASTER_PLAN.md` — индекс пакета `12*` и политика синхронизации.
3. `docs/12B_RUNTIME_MASTER_PLAN.md` — Daily Life + City Response (runtime).
4. `docs/12A_WORLD_MODEL_CANON.md` — Legal / World Model.
5. `docs/12C_PLAYER_PROPERTY_SYSTEM.md` — Property.
6. `docs/12D_WORLD_TRAVEL_CANON.md` — Travel.
7. `docs/12E_TRADE_AND_CITY_STATE_CANON.md` — Trade / City State.
8. `docs/14_CLAN_SYSTEM_DESIGN.md` и `docs/13_AGING_AND_CLAN_SUCCESSION.md` — Clan + Succession.
9. `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md` — быстрые проверки идеи/статуса.

---

## 8) Важное правило чтения

README и паспорт — обзорные документы. Они помогают восстановить целостную картину, но **не заменяют профильные source-of-truth документы**.
