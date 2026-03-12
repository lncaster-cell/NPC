# QA findings (start package)

Дата: 2026-03-12

Формат: `issue -> task-stub`.

---

## 1) Registry capacity остаётся жёстко зафиксированной на уровне кода

**Issue.** Лимит реестра задан константой `AL_MAX_NPCS = 100` в `al_registry_inc.nss`, без runtime-конфига на модуль/area. Для разных плотностей сцен это может быть либо избыточно, либо недостаточно; при недооценке лимита система уходит в диагностируемый, но всё же degrade-режим по регистрации.

**Task-stub.**
1. Вынести effective-cap в конфиг с fallback на compile-time значение (`AL_MAX_NPCS_DEFAULT`).
2. Добавить чтение area/module local (`al_max_npcs`) с валидацией безопасного диапазона.
3. Зафиксировать контракт в `docs/TECH_PASSPORT.md` и `INSTALLATION.md`.
4. Добавить smoke-сценарий на cap=80/100/120 и сверку `al_reg_overflow_count`.

---

## 2) Нет автоматического preflight для linked-графа (есть только операторский гайд)

**Статус.** ✅ Закрыто в рамках текущего прохода: добавлен `scripts/ambient_life/al_link_preflight.py`, а также `Linked-gate` в `TASKS.md`.

**Issue.** Правила linked-графа подробно описаны в `docs/LINKED_GRAPH_OPERATIONS.md`, но не проверяются автоматически перед выкладкой контента. Это оставляет риск человеческой ошибки (дубликаты `al_link_*`, самоссылки, критическая степень узлов, несимметричные связи).

**Task-stub (follow-up).**
1. Добавить sample-входы в `docs/` для linked preflight (pass/fail кейсы для операторов).
2. Интегрировать запуск `al_link_preflight.py` в CI/checklist перед merge linked-правок.
3. Уточнить пороги `WARN/ERROR` для degree/cluster-size по итогам perf-замеров S80/S100/S120.

---

## 3) Нет формализованных порогов triage для `al_reg_index_miss`

**Issue.** В `AL_FindNPCInRegistry` учитывается метрика `al_reg_index_miss` (fallback с fast-index на линейный поиск), но для неё нет операционных порогов/правил эскалации в runbook. Это затрудняет раннее обнаружение рассинхронизаций локалов NPC и area-registry.

**Task-stub.**
1. Добавить snapshot-поле `al_h_reg_index_miss_delta` (дельта за окно) в area health.
2. В `docs/PERF_RUNBOOK.md` задать пороги `OK/WARN/CRITICAL` и действия оператора.
3. В debug-режиме добавить throttled-log при росте miss-дельты выше warn-порога.
4. В perf-профиль (`docs/PERF_PROFILE.md`) добавить целевой baseline по miss-дельте для Scene S80/S100/S120.
