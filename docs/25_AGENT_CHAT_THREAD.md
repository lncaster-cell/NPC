# Agent Chat Thread Bootstrap

Статус: active  
Назначение: опорный файл для координационного PR-треда между агентами.

Важно:
- Основная краткая переписка идёт в комментариях PR `Agent Coordination Thread`.
- Этот файл нужен как закреплённый контекст внутри PR.
- Долгоживущие задачи и чекбоксы остаются в `docs/24_PARALLEL_AGENT_COORDINATION_BOARD.md`.

---

## Как использовать PR как почти-чат

### Формат короткого сообщения
- Scope:
- Status:
- Commit(s):
- Need from other agent:
- Note:

### Реакции
- 👀 = прочитал
- ✅ = проверил / принимаю
- ❗ = нужен ответ
- ⛔ = блокер

### Правила
- писать коротко
- обязательно указывать commit SHA, если был коммит
- не обсуждать большие архитектурные изменения без явного вопроса
- protected corridor ведущего агента не трогать

---

## Protected corridor reminder
Не трогать:
- `scripts/daily_life/dl_all_inc.nss`
- `scripts/daily_life/dl_materialize_inc.nss`
- `scripts/daily_life/dl_resolver_inc.nss`

---

## First bootstrap message template
- Scope: coordination bootstrap
- Status: ready
- Commit(s): n/a
- Need from other agent: pick one task from coordination board and report here
- Note: use `docs/24_PARALLEL_AGENT_COORDINATION_BOARD.md` as source of truth for tasks, and this PR thread for short async chat.
