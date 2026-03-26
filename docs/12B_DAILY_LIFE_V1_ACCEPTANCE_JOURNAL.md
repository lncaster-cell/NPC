# Ambient Life v2 — Daily Life v1 Milestone A Acceptance Journal

Дата: 2026-03-26  
Статус: active verification journal  
Назначение: единый журнал, в котором фиксируются **реальные результаты прогонов** для сценариев Milestone A. Этот файл отделяет «ожидается по дизайну» от «подтверждено проверкой».

---

## 1) Правило заполнения журнала

- Один запуск = одна запись в таблице `2.1`.
- Если сценарий не запускался, ставится `NOT_RUN`.
- Если результат частичный/неустойчивый, ставится `PARTIAL` с коротким комментарием.
- Если есть расхождение с ожиданием, ставится `FAIL` и указывается точка расхождения.
- Для каждого запуска указывать:
  - дату в формате `YYYY-MM-DD`;
  - тип проверки (`manual smoke` / `scripted smoke`);
  - среду (`toolset`, `owner PC`, `headless` и т.д.).

Статусы:
- `PASS`
- `PARTIAL`
- `FAIL`
- `NOT_RUN`

---

## 2) Журнал запусков

## 2.1 Сводная таблица по сценариям A–G

| Дата | Run ID | Тип | Среда | A (Blacksmith WORK) | B (Blacksmith SOCIAL) | C (Gate duty) | D (Innkeeper late) | E (Quarantine) | F (Area enter resync) | G (WARM/FROZEN) | Итог |
|---|---|---|---|---|---|---|---|---|---|---|---|
| 2026-03-26 | baseline-template-001 | template init | repo docs | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | журнал создан, ожидаются первые прогоны |
| 2026-03-26 | runbook-bootstrap-001 | process prep | repo docs | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | добавлен scripted smoke runbook; ожидается первый фактический прогон |

## 2.2 Детализация расхождений (заполнять только при PARTIAL/FAIL)

| Дата | Run ID | Сценарий | Факт | Ожидание | Гипотеза причины | Следующий шаг |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | — |

---

## 3) Контроль Step A–E acceptance

Эта секция фиксирует **не наличие кода**, а факт проверки критериев из `docs/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`.

| Шаг | Статус | Чем подтверждено | Комментарий |
|---|---|---|---|
| Step A — Contracts foundation | PARTIAL | code inspection | Runbook готов; требуется первый фактический scripted/manual прогон с логом smoke snapshot. |
| Step B — Pure resolver | PARTIAL | code inspection | Runbook готов; нужен отдельный run с проверкой детерминизма на одинаковых входах. |
| Step C — Materialization and interaction | PARTIAL | code inspection | Runbook готов; нужны сценарные подтверждения изменения dialogue/service в A/B/D. |
| Step D — Area worker and lifecycle | PARTIAL | code inspection | Runbook готов; нужен run с явным подтверждением F/G (HOT/WARM/FROZEN и bounded worker). |
| Step E — Stub handoff | PARTIAL | code inspection | API присутствует; runbook готов, нужен smoke-run с `BASE_LOST -> UNASSIGNED/ABSENT` + handoff log. |

---

## 4) Gate для закрытия Milestone A

Milestone A может быть закрыт только если одновременно выполнено:
- в таблице `2.1` есть минимум один run, где `A–G = PASS`;
- нет открытых `FAIL`, влияющих на deterministic/bounded свойства;
- owner-проверка на реальном ПК проведена и зафиксирована отдельной записью.

