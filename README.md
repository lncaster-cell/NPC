# Ambient Life v2 (NPC) — README

> Обновлено: **2026-04-08**.

Репозиторий содержит канон, runtime-документацию и кодовую базу для контура Daily Life в NWN2.
Сейчас проект работает в режиме **пошаговой переписи Daily Life v2** (clean-room подход):
**один микро-шаг → проверка → фиксация результата → следующий шаг**.

Базовый документ для запуска работ: `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`.

---

## 1) Source of Truth и рабочий контур

### Канон и инварианты
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`

### Операционный контур (обязательно к чтению перед кодом)
1. `docs/runtime/43_DAILY_LIFE_UNIFIED_CONTOUR_DIGEST_RU.md`
2. `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/governance/21_ACTIVE_DEVELOPMENT_CONTROL_PANEL.md`

### Кодовые зоны
- Активная зона v2: `scripts/daily_life/`
- Архивная зона v1 (reference only): `archive/daily_life_v1_legacy/scripts/daily_life/`

---

## 2) Рамки системы Daily Life (коротко)

Daily Life — это **событийно-управляемый runtime-контур поведения NPC**, а не глобальный симулятор всех доменов города.

Обязательные опоры:
- contract-first модель (profile/schedule/base/anchor/directive);
- внешние override через incident-layer;
- materialization + interaction refresh;
- bounded HOT/WARM/FROZEN execution;
- resync и handoff как отдельные контролируемые этапы.

Что **не должно** попадать в ядро Daily Life:
- правовая квалификация;
- макроэкономика;
- полноформатный travel;
- клановая демография как отдельный runtime;
- aging/succession как truth-движок внутри Daily Life.

---

## 3) Дорожная карта разработки (по этапам)

Ниже — рабочая roadmap, которую используем для последовательной разработки без хаоса.
Каждый этап закрывается только после фактической проверки и записи результата в документации.

### Этап 0 — Alignment и контракт границ
**Цель:** синхронизировать owner/agent понимание границ системы.

**Задачи:**
1. Зафиксировать scope Daily Life по digest (что входит/не входит).
2. Подтвердить event-driven модель и отказ от per-NPC heartbeat ядра.
3. Зафиксировать Definition of Done для микро-шагов.

**Артефакты выхода:**
- актуальный control panel;
- обновлённый roadmap (этот README + профильные runtime-документы).

---

### Этап 1 — Data Contract Foundation
**Цель:** утвердить минимальный стабильный набор контрактов v2 до расширения логики.

**Задачи:**
1. Зафиксировать enum/record/сигнатуры для profile/schedule/base/anchor/directive.
2. Явно разделить Resolver (directive/anchor policy) и Activity layer (визуальная активность).
3. Зафиксировать override input как read-only контракт.

**Критерии готовности:**
- нет размытых статусов и дублирующих сущностей;
- контракты согласованы с digest и baseline;
- добавлены комментарии/док-следы, где это нужно для владельца и агентов.

---

### Этап 2 — Event Pipeline Skeleton
**Цель:** собрать минимально исполняемый событийный контур area → npc.

**Задачи:**
1. Определить триггеры запуска (area enter/exit, area tick, time window change, override event, population/slot event).
2. Реализовать каркас: Area Controller → Scheduler/Worker → Resolver → Materialization → Interaction Refresh → Handoff → Resync.
3. Встроить bounded budget и базовую деградацию по tier.

**Критерии готовности:**
- pipeline проходит smoke без хаотичных переходов;
- есть трассируемые логи по ключевым этапам.

---

### Этап 3 — Tier Policy (HOT/WARM/FROZEN)
**Цель:** обеспечить предсказуемое и производительное исполнение по tier-режимам.

**Задачи:**
1. Формализовать поведение HOT, WARM, FROZEN без фоновой псевдосимуляции.
2. Реализовать корректные переходы между tier-состояниями.
3. Добавить проверку resync после паузы/смены контекста.

**Критерии готовности:**
- подтверждённое поведение HOT↔WARM↔FROZEN;
- нет heartbeat-first отката.

---

### Этап 4 — Incident Override + External Handoff
**Цель:** корректно интегрировать внешние домены через контракты, не размывая границы ядра.

**Задачи:**
1. Подключить incident override как главный внешний источник временных ограничений.
2. Реализовать handoff для vacancy/absence сценариев.
3. Проверить, что legal/trade/travel/clan остаются во внешнем контуре.

**Критерии готовности:**
- override влияет на директиву контролируемо;
- handoff срабатывает при потере исполнителя роли;
- границы доменов не нарушены.

---

### Этап 5 — Observability, SLO, Owner Acceptance
**Цель:** закрыть эксплуатационные риски и подтвердить систему owner-сценариями.

**Задачи:**
1. Ввести измеримые runtime-метрики (budget, degradation, resync, override-hit).
2. Зафиксировать micro-SLO профиль v2.
3. Свести owner-check сценарии в единый runbook и провести acceptance run.

**Критерии готовности:**
- есть фактические метрики и журнал проверок;
- owner-run завершается с формальным verdict (PASS/PARTIAL/FAIL).

---

## 4) Протокол выполнения каждого микро-шагa

Для каждого шага обязателен единый цикл:
1. **План шага** (что делаем и зачем, без лишней логики).
2. **Изменение** (одна функция/один контролируемый участок).
3. **Проверка** (точные команды, логи, факт PASS/FAIL).
4. **Док-синхронизация** (README/runtime/governance, если меняется поведение).
5. **Отчёт владельцу** (что сделано, что подтверждено, следующий шаг).

Это обязательный anti-chaos контракт разработки.

---

## 5) Что делаем сразу после этого коммита

Стартуем с **Этапа 1 (Data Contract Foundation)** и дробим его на микро-задачи:
1. Инвентаризация текущих v2 контрактов в `scripts/daily_life/`.
2. Список расхождений относительно digest/baseline.
3. Первый микро-патч контракта (одна сущность), затем проверка и отчёт.

