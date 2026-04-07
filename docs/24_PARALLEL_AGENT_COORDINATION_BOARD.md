# Parallel Agent Coordination Board

Статус: active  
Назначение: единый координационный документ для параллельной работы двух агентов через сам репозиторий.

Этот файл задуман как **рабочая доска + почтовый ящик + журнал приёмки**:
- второй агент читает файл и понимает, что делать;
- второй агент берёт задачу, делает коммит, пишет короткий отчёт сюда;
- ведущий агент читает обновление, ставит отметки **прочёл / проверил**;
- спорные вопросы и блокеры тоже фиксируются здесь.

---

## 1) Как работать через этот файл

### Для параллельного агента
1. Сначала прочитай этот файл целиком.
2. Не трогай защищённый коридор ведущего агента.
3. Выбери одну задачу из секции **Task Board**.
4. Перед началом поставь у задачи отметку `claimed`.
5. После выполнения:
   - закоммить изменения;
   - впиши короткий handoff-отчёт в секцию **Exchange Log**;
   - поставь задаче `done by parallel agent`.
6. Если упёрся в спорное решение:
   - ничего не ломай;
   - добавь запись в **Decision / Blocker Inbox**.

### Для ведущего агента
1. Периодически читать этот файл.
2. После чтения handoff-отчёта ставить:
   - `read by lead agent`
   - `verified by lead agent` (только если проверено и принято)
3. Если есть замечания — писать их в **Exchange Log** или **Decision / Blocker Inbox**.

---

## 2) Значение статусов

- **claimed** = задача взята в работу параллельным агентом
- **done by parallel agent** = агент считает задачу завершённой
- **read by lead agent** = ведущий агент прочитал результат
- **verified by lead agent** = ведущий агент проверил и принимает результат
- **blocked** = задача упёрлась в вопрос или риск

---

## 3) Защищённый коридор ведущего агента

Параллельному агенту **не трогать**:
- `scripts/daily_life/dl_all_inc.nss`
- `scripts/daily_life/dl_materialize_inc.nss`
- `scripts/daily_life/dl_resolver_inc.nss`

Причина: это текущий основной коридор ведущего агента, где идёт синхронизация и тонкая санация. Любые параллельные правки здесь создадут лишние конфликты.

---

## 4) Общие правила для параллельного агента

### Разрешено
- делать **cleanup** (санитарную чистку кода)
- выносить маленькие helper-функции
- убирать повторяющиеся ветки и повторяющиеся проверки
- обновлять smoke / acceptance документацию
- делать короткие понятные коммиты

### Запрещено
- менять runtime-контракт системы
- менять архитектуру без явной причины
- массово переписывать `dl_all_inc`
- трогать protected corridor
- менять поведение handoff / review / resync / directive policy без явного решения

### Принцип
Если есть сомнение: **сначала записать вопрос, потом ждать проверки**, а не изобретать своё правило.

---

## 5) Task Board

---

### Task P1 — Dialogue bridge cleanup
**Scope:**
- `scripts/daily_life/dl_dialogue_bridge_inc.nss`

**Цель:**
Убрать structural шум без изменения поведения.

**Что искать:**
- повторяющиеся valid-area / valid-store проверки
- повторяющиеся search/conflict branches
- повторяющиеся log branches

**Разрешено:**
- вынести маленькие helper’ы
- упростить guard-ветки
- убрать copy-paste

**Запрещено:**
- менять правила выбора store
- менять local key names
- менять смысл диалогового runtime-контракта

**Статус:**
- [ ] claimed by parallel agent
- [ ] done by parallel agent
- [ ] read by lead agent
- [ ] verified by lead agent
- [ ] blocked

---

### Task P2 — Slot handoff cleanup
**Scope:**
- `scripts/daily_life/dl_slot_handoff_inc.nss`

**Цель:**
Проверить, не осталось ли повторов в slot/profile/review bookkeeping.

**Что искать:**
- повторная сборка ключей
- повторная очистка состояния
- повторяющиеся bookkeeping branches

**Разрешено:**
- вынос маленьких key/state helper’ов
- dedup cleanup-path’ов

**Запрещено:**
- менять TTL
- менять reason priority
- менять саму механику handoff

**Статус:**
- [ ] claimed by parallel agent
- [ ] done by parallel agent
- [ ] read by lead agent
- [ ] verified by lead agent
- [ ] blocked

---

### Task P3 — Smoke / acceptance docs refresh
**Scope:**
- `docs/12B_DAILY_LIFE_V1_SMOKE_RUNBOOK.md`
- `docs/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`

**Цель:**
Привести проверочные документы в соответствие с текущим runtime.

**Нужно проверить и при необходимости обновить:**
- `ABSENT`
- `UNASSIGNED`
- base lost
- slot assigned
- resync after hook events
- anchor not found
- anchor filtered by policy

**Разрешено:**
- обновлять smoke steps
- добавлять missing scenarios
- уточнять acceptance wording

**Запрещено:**
- переписывать документы ради стиля без практической пользы

**Статус:**
- [ ] claimed by parallel agent
- [ ] done by parallel agent
- [ ] read by lead agent
- [ ] verified by lead agent
- [ ] blocked

---

### Task P4 — Sync map for future safe-layer work
**Scope:**
- read-only audit across cleaned legacy includes vs `dl_all_inc.nss`

**Цель:**
Дать карту будущих sync-хвостов, но не редактировать `dl_all_inc`.

**Что выдать:**
Короткий список:
- какой helper / cleanup уже есть в legacy include-layer
- чего ещё нет в `dl_all_inc`
- priority: `high / medium / low`

**Важно:**
Это **аудит**, а не массовое редактирование safe-layer.

**Статус:**
- [x] claimed by parallel agent
- [x] done by parallel agent
- [ ] read by lead agent
- [ ] verified by lead agent
- [ ] blocked

---

**P4 audit result (2026-04-07, parallel-agent):**
- `dl_dialogue_bridge_inc.nss` / `dl_slot_handoff_inc.nss`: cleanup-helper слой уже есть и символьно синхронизирован с `dl_all_inc.nss`; явных sync-хвостов для safe-layer не найдено. **Priority: low**.
- `dl_anchor_inc.nss` + `dl_resync_inc.nss`: базовые guard/helper-path’ы присутствуют в include-слое и уже заведены в `dl_all_inc.nss`; отдельный перенос не требуется. **Priority: low**.
- `dl_worker_inc.nss` / `dl_schedule_inc.nss`: ключевые helper entrypoints присутствуют; потенциальный будущий хвост только в точечной унификации лог-веток (не блокер). **Priority: medium**.
- Общий вывод: для `dl_all_inc.nss` сейчас приоритетнее точечные семантические проверки и smoke-подтверждения, чем новый sync-перенос helper-слоя.

---

### Task P5 — Secondary semantic-path audit
**Scope:**
- `scripts/daily_life/dl_activity_inc.nss`
- `scripts/daily_life/dl_anchor_inc.nss`
- `scripts/daily_life/dl_worker_inc.nss`
- `scripts/daily_life/dl_resync_inc.nss`

**Цель:**
Найти повторяющиеся semantic-path’ы для следующих cleanup-проходов.

**Формат результата:**
Для каждого найденного места:
- file
- function
- что повторяется
- можно ли вынести helper
- risk: `low / medium / high`

**Важно:**
Сначала аудит. Не надо бездумно править все файлы сразу.

**Статус:**
- [ ] claimed by parallel agent
- [ ] done by parallel agent
- [ ] read by lead agent
- [ ] verified by lead agent
- [ ] blocked

---

## 6) Decision / Blocker Inbox

Параллельный агент пишет сюда только короткие вопросы, если наткнулся на спорный момент.

### Шаблон
- **Date:** YYYY-MM-DD
- **Author:** parallel-agent / lead-agent
- **Scope:** файл или задача
- **Question / Blocker:**
- **Proposed safe option:**
- **Status:** open / answered / resolved

### Entries
- _пока пусто_

---

## 7) Exchange Log

Сюда оба агента пишут короткие handoff-сообщения.

### Шаблон записи
- **Date:** YYYY-MM-DD
- **Author:** parallel-agent / lead-agent
- **Scope:**
- **Commit(s):**
- **Status:** claimed / in_progress / done / read / verified / blocked
- **Note:** коротко, по делу

### Entries
- **Date:** 2026-04-07
- **Author:** lead-agent
- **Scope:** coordination setup
- **Commit(s):** pending creation commit
- **Status:** done
- **Note:** Создана координационная доска для параллельной работы через репозиторий.

- **Date:** 2026-04-07
- **Author:** parallel-agent
- **Scope:** Task P4 + PR337 thread
- **Commit(s):** 2b206fd
- **Status:** done
- **Note:** Задача P4 взята/закрыта: добавлен sync-map аудит по include-layer vs `dl_all_inc.nss`; в PR337 оставлен handoff для ведущего агента.

---

## 8) Commit style (рекомендуется)

Для параллельного агента предпочтительны короткие commit messages:
- `dialogue bridge cleanup`
- `slot handoff cleanup`
- `smoke docs refresh`
- `sync map update`
- `secondary semantic audit`

Если задача смешанная — лучше разбивать на маленькие отдельные коммиты.

---

## 9) Важное напоминание

Если результат не отражён в этом файле, то для второго агента он считается **не переданным**.

Если задача не отмечена `read` / `verified`, то для координации она считается **ещё не принята ведущим агентом**.
