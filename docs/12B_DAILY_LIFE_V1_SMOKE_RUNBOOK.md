# Ambient Life v2 — Daily Life v1 Milestone A Smoke Runbook

Дата: 2026-03-26  
Статус: active scripted smoke runbook  
Назначение: минимальный, воспроизводимый scripted/manual путь проверки сценариев `A–G` из Milestone A checklist.

---

## 1) Что проверяет этот runbook

Runbook покрывает обязательные сценарии из `docs/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`:
- A — blacksmith в `WORK` окне;
- B — blacksmith вне `WORK` окна;
- C — gate duty;
- D — innkeeper late/service gating;
- E — `QUARANTINE` override;
- F — area enter resync;
- G — различие поведения `HOT/WARM/FROZEN`.

Runbook не доказывает окончательный production-grade verdict — это делает owner на своём ПК, но даёт единый репозиторный формат проверок и фиксации результатов.

---

## 2) Подготовка окружения перед прогоном

1. Включить trace-флаг модуля:
   - `dl_smoke_trace = TRUE`.
2. Убедиться, что у тестовых NPC задано:
   - `dl_npc_family`;
   - `dl_npc_subtype`;
   - `dl_schedule_template`;
   - `dl_npc_base` (кроме негативного кейса base-lost).
3. Для сценариев с handoff назначить `dl_function_slot_id`.
4. Для area-tier тестов подготовить 3 зоны:
   - `HOT` (`dl_area_tier = 2`),
   - `WARM` (`dl_area_tier = 1`),
   - `FROZEN` (`dl_area_tier = 0`).
5. Для Step E использовать отдельный script-hook:
   - `scripts/daily_life/dl_smoke_step_e.nss`.
6. Для быстрого scripted среза A–G можно запускать `scripts/daily_life/dl_smoke_milestone_a.nss`.
   - Скрипт не подменяет полноценный owner-smoke, но даёт единый машинный summary по сценариям `A–G` (`PASS/FAIL/NOT_FOUND`).
   - После завершения пишет агрегированную строку `MilestoneA smoke overall ...` и per-scenario counters `checked/passed`, чтобы сразу видеть полноту runtime-контура в одном прогоне.


---

## 2.1 Отдельный блок: как быстро настроить NPC в Toolset

Ниже минимальный «боевой» набор, чтобы сразу запустить проверку.

### Шаг 1 — Подготовить 3 зоны
- Зона 1: `dl_area_tier = 2` (`HOT`).
- Зона 2: `dl_area_tier = 1` (`WARM`).
- Зона 3: `dl_area_tier = 0` (`FROZEN`).
- На `OnHeartbeat` зоны поставить `scripts/daily_life/dl_area_tick`.

### Шаг 2 — Поставить минимум 4 тестовых NPC

1. **NPC_A_BLACKSMITH**
   - `dl_npc_family = 2` (`CRAFT`)
   - `dl_npc_subtype = 4` (`BLACKSMITH`)
   - `dl_schedule_template = 1` (`EARLY_WORKER`)
   - `dl_npc_base = <валидный base object>`

2. **NPC_C_GATE_POST**
   - `dl_npc_family = 1` (`LAW`)
   - `dl_npc_subtype = 2` (`GATE_POST`)
   - `dl_schedule_template = 4` (`DUTY_ROTATION_DAY`) или `5` (`DUTY_ROTATION_NIGHT`)
   - `dl_npc_base = <валидный base object>`

3. **NPC_D_INNKEEPER**
   - `dl_npc_family = 3` (`TRADE_SERVICE`)
   - `dl_npc_subtype = 8` (`INNKEEPER`)
   - `dl_schedule_template = 3` (`TAVERN_LATE`)
   - `dl_npc_base = <валидный base object>`

4. **NPC_E_QUARANTINE** (любой из service/craft)
   - базовые поля как у обычного NPC
   - `dl_override_kind = 2` (`QUARANTINE`)

Рекомендуется для всех тестовых NPC:
- `dl_named = TRUE` **или** `dl_persistent = TRUE` (чтобы worker гарантированно их обрабатывал).

### Шаг 3 — Включить trace и прогнать
- На модуле: `dl_smoke_trace = TRUE`.
- Запустить `scripts/daily_life/dl_smoke_milestone_a.nss`.
- Для base-lost smoke отдельно запустить `scripts/daily_life/dl_smoke_step_e.nss`.

### Шаг 4 — Что считать «проверка стартует корректно»
- В логе есть строки `MilestoneA smoke A..G status=...`.
- В логе есть `smoke snapshot ...` с `directive/dialogue/service`.
- Для Step E есть `checked/absent/unassigned/last_kind/last_slot`.


## 3) Единый формат фиксации smoke snapshot

При включённом `dl_smoke_trace` worker пишет сообщение формата:

- `smoke snapshot reason=<id>(<label>) family=<...> subtype=<...> directive=<id>(<label>) dialogue=<id>(<label>) service=<id>(<label>) override=<id>(<label>) base_lost_kind=<id>(<label>) base_lost_slot=<slot_id>`

Минимальный expected набор полей, который нужно сверять в каждом сценарии:
- `directive`;
- `dialogue`;
- `service`;
- `override` (для E).

Если `smoke snapshot` отсутствует, сценарий считается `PARTIAL` даже если визуально NPC выглядит корректно.

Для Step E (`Stub handoff`) дополнительно проверять:
- `base_lost_kind=ABSENT|UNASSIGNED` в зависимости от ветки;
- `base_lost_slot=<slot_id>` для NPC с `dl_function_slot_id`;
- при совпадении NPC с последним событием будет маркер `base_lost_npc=SELF`.

---

## 4) Порядок сценарного прогона (A → G)

### A — Blacksmith WORK
- Профиль: `CRAFT + BLACKSMITH + EARLY_WORKER`.
- Время: `WORK` окно.
- Ожидание: `directive=WORK`, `dialogue=WORK`, `service=AVAILABLE|LIMITED`.

### B — Blacksmith SOCIAL
- NPC кузнец в non-work окне (допустимо отдельный второй кузнец с другим offset/временем проверки).
- Ожидание: `directive!=WORK`, сервис не как рабочий (`service!=AVAILABLE` в рабочем смысле).
- Если кузнец найден, но non-work состояние не подтверждено, scripted smoke должен давать `FAIL` (а не `NOT_FOUND`).

### C — Gate duty
- Профиль: `LAW + GATE_POST + DUTY_ROTATION_DAY|NIGHT`.
- Ожидание: `directive=DUTY|HOLD_POST`, `dialogue=INSPECTION|WORK`, сервис не "лавочный".

### D — Innkeeper late
- Профиль: `TRADE_SERVICE + INNKEEPER + TAVERN_LATE`.
- Ожидание: в late-window режим отличается от core-service окна; проверяется смена `dialogue/service`.

### E — Quarantine override
- На одном из NPC включить override `QUARANTINE`.
- Ожидание: suppression/service gating (обычно `LOCKDOWN/HIDE` + ограниченный/выключенный сервис).
- Для отдельной проверки stub handoff/base-lost запустить `dl_smoke_step_e`:
  - скрипт принудительно прогоняет `DL_RunForcedResync(..., DL_RESYNC_BASE_LOST)` для Daily Life NPC без валидной базы;
  - пишет итог в лог: `checked/absent/unassigned/last_kind/last_slot`;
  - даёт быстрый сигнал, что Milestone A ветки `ABSENT` и `UNASSIGNED` реально срабатывают на текущих данных.

### F — Area enter resync
- Игрок входит в area с NPC, требующим resync.
- Ожидание: проходит bounded resync path; есть запись `reason=AREA_ENTER` или эквивалентный resync reason.

### G — HOT/WARM/FROZEN
- Для одинакового набора NPC выполнить тик в трёх tier.
- Ожидание:
  - `HOT`: полноценная bounded обработка;
  - `WARM`: ограниченная обработка;
  - `FROZEN`: отсутствие живого тика.
- Scripted smoke дополнительно проверяет shape gate:
  - `DL_ShouldRunDailyLifeTier(HOT)=TRUE`,
  - `DL_ShouldRunDailyLifeTier(WARM)=TRUE`,
  - `DL_ShouldRunDailyLifeTier(FROZEN)=FALSE`.

---

## 5) Правила статусов в acceptance journal

- `PASS`: сценарий дал ожидаемый `smoke snapshot` + не наблюдается функциональное расхождение.
- `PARTIAL`: есть часть сигналов, но нет полного доказательства (например, нет snapshot или сомнительный reason).
- `FAIL`: есть зафиксированное расхождение по directive/dialogue/service/override.
- `NOT_RUN`: сценарий не запускался в этом run.

---

## 6) Шаблон run ID и записи в журнал

Рекомендуемый шаблон run ID:
- `dlv1-smoke-YYYYMMDD-<env>-<seq>`

Пример:
- `dlv1-smoke-20260326-toolset-01`

После каждого прогона обязательно обновить:
1. `docs/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md` → таблица `2.1`;
2. при `PARTIAL/FAIL` — таблица `2.2`;
3. при закрытии новых критериев Step A–E — таблица секции `3`.

---

## 7) Минимальный definition of progress для текущей недели

Неделя считается продвинутой, если есть хотя бы один run, где:
- A, C, E, F прошли минимум в `PARTIAL` с валидным smoke snapshot;
- для B и D есть подтверждённое различие `dialogue/service` относительно A;
- для G отдельно зафиксировано поведение `HOT/WARM/FROZEN`.
