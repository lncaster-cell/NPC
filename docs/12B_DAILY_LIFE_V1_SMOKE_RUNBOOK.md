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

---

## 3) Единый формат фиксации smoke snapshot

При включённом `dl_smoke_trace` worker пишет сообщение формата:

- `smoke snapshot reason=<id>(<label>) family=<...> subtype=<...> directive=<id>(<label>) dialogue=<id>(<label>) service=<id>(<label>) override=<id>(<label>)`

Минимальный expected набор полей, который нужно сверять в каждом сценарии:
- `directive`;
- `dialogue`;
- `service`;
- `override` (для E).

Если `smoke snapshot` отсутствует, сценарий считается `PARTIAL` даже если визуально NPC выглядит корректно.

---

## 4) Порядок сценарного прогона (A → G)

### A — Blacksmith WORK
- Профиль: `CRAFT + BLACKSMITH + EARLY_WORKER`.
- Время: `WORK` окно.
- Ожидание: `directive=WORK`, `dialogue=WORK`, `service=AVAILABLE|LIMITED`.

### B — Blacksmith SOCIAL
- Тот же NPC, но время в social/rest окне.
- Ожидание: `directive!=WORK`, сервис не как рабочий (`service!=AVAILABLE` в рабочем смысле).

### C — Gate duty
- Профиль: `LAW + GATE_POST + DUTY_ROTATION_DAY|NIGHT`.
- Ожидание: `directive=DUTY|HOLD_POST`, `dialogue=INSPECTION|WORK`, сервис не "лавочный".

### D — Innkeeper late
- Профиль: `TRADE_SERVICE + INNKEEPER + TAVERN_LATE`.
- Ожидание: в late-window режим отличается от core-service окна; проверяется смена `dialogue/service`.

### E — Quarantine override
- На одном из NPC включить override `QUARANTINE`.
- Ожидание: suppression/service gating (обычно `LOCKDOWN/HIDE` + ограниченный/выключенный сервис).

### F — Area enter resync
- Игрок входит в area с NPC, требующим resync.
- Ожидание: проходит bounded resync path; есть запись `reason=AREA_ENTER` или эквивалентный resync reason.

### G — HOT/WARM/FROZEN
- Для одинакового набора NPC выполнить тик в трёх tier.
- Ожидание:
  - `HOT`: полноценная bounded обработка;
  - `WARM`: ограниченная обработка;
  - `FROZEN`: отсутствие живого тика.

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
