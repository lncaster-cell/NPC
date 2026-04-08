# Daily Life v2 Rewrite Workspace

Этот каталог очищен под поэтапную перепись Daily Life-контура с нуля.

## Правила работы
1. Добавляем только одну новую функцию/модуль за шаг.
2. На каждый шаг: контракт -> реализация -> smoke-проверка -> запись в журнал.
3. Старый контур v1 перенесён в архив:
   - `archive/daily_life_v1_legacy/scripts/daily_life/`

## Стартовая точка
- Текущая фаза: проектирование и подготовка репозитория.
- Активный документ-план: `docs/runtime/40_DAILY_LIFE_V2_REWRITE_PROGRAM_RU.md`.

## Progress log

### Step 01 — Runtime gate helper
- Добавлен include: `dl_v2_runtime_inc.nss`.
- Добавлена функция: `DL2_IsRuntimeEnabled()`.
- Добавлен smoke script: `dl2_smoke_step_01.nss` (3 кейса из baseline).
- `dl_v2_bootstrap.nss` подключен к helper и пишет диагностический сигнал.
