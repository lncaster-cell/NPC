# Ambient Life v2 — Daily Life v1 Milestone A Acceptance Journal

Дата: 2026-04-07  
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
| 2026-03-27 | smoke-script-bootstrap-001 | process prep | repo scripts | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | добавлен scripted helper `dl_smoke_milestone_a.nss` для единого A–G summary; ожидается фактический прогон в toolset/owner PC |
| 2026-03-31 | smoke-script-fix-b-001 | process prep | repo scripts | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | в `dl_smoke_milestone_a.nss` исправлен учёт сценария B: non-work кузнец теперь ищется независимо от PASS сценария A, без ложного `NOT_FOUND` при наличии mixed blacksmith набора |
| 2026-04-07 | status-sync-001 | process sync | repo docs | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | подтверждён статус: фактические scripted/manual прогоны A–G ещё не зафиксированы; milestone gate остаётся открытым |
| 2026-04-10 | manual-smoke-lifecycle-001 | manual smoke | toolset / owner PC | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PARTIAL | NOT_RUN | **owner-run текущего clean-room lifecycle/registry slice выполнен**: подтверждены `AREA_ENTER`, `HB`, death lifecycle и cleanup регистрации в isolated area (`reg: 1 -> 0`); это не эквивалентно полному PASS Milestone A, потому что сценарии A–E и G отдельно не пройдены |
| 2026-04-11 | manual-owner-fg-003 | manual smoke | toolset / owner PC | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | NOT_RUN | PASS | PASS | owner-run подтвердил F/G: bounded area-enter resync стабильно завершается через heartbeat/worker path без лагов; hidden full simulation и визуальная дёрготня/хаотичный телепорт NPC не наблюдались; tier-cycle подтверждён на `Gotha Kuznica`/`Gotha` (`HOT=2 -> WARM=1 -> HOT=2`) с повторным enter-resync |

## 2.2 Детализация расхождений (заполнять только при PARTIAL/FAIL)

| Дата | Run ID | Сценарий | Факт | Ожидание | Гипотеза причины | Следующий шаг |
|---|---|---|---|---|---|---|
| 2026-04-10 | manual-smoke-lifecycle-001 | F (Area enter resync) | подтверждены enter hook, heartbeat, death lifecycle и cleanup area registry; owner-run текущего lifecycle/registry slice завершён | bounded resync/materialization на входе игрока должны быть подтверждены как сценарий целиком | текущий прогон был точечным lifecycle/registry smoke, а не полным scenario F acceptance | провести отдельный scenario F run по runbook и зафиксировать итог PASS/FAIL |

---

## 3) Контроль Step A–E acceptance

Эта секция фиксирует **не наличие кода**, а факт проверки критериев из `docs/runtime/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`.

| Шаг | Статус | Чем подтверждено | Комментарий |
|---|---|---|---|
| Step A — Contracts foundation | PARTIAL | code inspection | Runbook готов; фактический smoke trace для полного foundation acceptance ещё не зафиксирован отдельным run. |
| Step B — Pure resolver | PARTIAL | code inspection | Runbook готов; отдельный run с проверкой детерминизма и полных directive/dialogue/service outputs ещё не зафиксирован. |
| Step C — Materialization and interaction | PARTIAL | code inspection | Скелет materialization есть; сценарные подтверждения изменения dialogue/service в A/B/D ещё не зафиксированы. |
| Step D — Area worker and lifecycle | PARTIAL | code inspection + manual smoke | На 2026-04-11 acceptance gate F/G закрыт фактическим owner-run (`F=PASS`, `G=PASS`): подтверждены bounded enter-resync, стабильный heartbeat/worker path и tier-cycle `HOT/WARM/HOT`; при этом Step D остаётся PARTIAL до закрытия сценариев A–E. |
| Step E — Stub handoff | PARTIAL | code inspection | Hook/markers существуют, но фактический owner-run handoff-сценария ещё не зафиксирован. |

---

## 4) Gate для закрытия Milestone A

Milestone A может быть закрыт только если одновременно выполнено:
- в таблице `2.1` есть минимум один run, где `A–G = PASS`;
- нет открытых `FAIL`, влияющих на deterministic/bounded свойства;
- полная owner-проверка Milestone A проведена и зафиксирована отдельной записью.

Пояснение:
- owner-run текущего clean-room lifecycle/registry slice **уже проведён** и зафиксирован записью `manual-smoke-lifecycle-001`;
- это **не равно** полному закрытию Milestone A.

---

## 5) Операционная пометка

- По состоянию на `2026-04-10` временное debug/logging **остаётся в игровом чате** и не удаляется до следующей итерации проверки Daily Life.
- Термин `owner-run` без уточнения не использовать: нужно явно писать либо `owner-run текущего slice`, либо `полный owner-run Milestone A`.
