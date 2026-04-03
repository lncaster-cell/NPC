# Глубокий всеобщий аудит репозитория — 2026-04-02

Дата: 2026-04-02  
Аудитор: Codex  
Scope: весь репозиторий (`README.md`, `docs/**`, `scripts/daily_life/**`)

---

## 1) Цель и метод

Цель: дать «сквозной» аудит состояния проекта в режиме active development и выявить узкие места, которые создают риск ложной навигации, неверной имплементации и drift между каноном и runtime.

Проверки (факт):
1. Git-состояние и базовая чистота дерева.
2. Наличие merge-маркеров.
3. Наличие технических плейсхолдеров (TODO/FIXME/TBD/XXX).
4. Статус runtime-ссылок в документации (legacy `ambient_life` vs текущий `daily_life`).
5. Техническая целостность `scripts/daily_life` (разрешение `#include`).
6. Дополнительная sanity-проверка enum-контура `dl_const_inc.nss`.

---

## 2) Ключевой вердикт

Критических блокеров выполнения Milestone A в коде `scripts/daily_life` не обнаружено (include-цепочки валидны, явных merge-артефактов нет).  
Главный риск находится в **документационном слое**: значимая часть SoT/overview всё ещё ссылается на legacy runtime-путь `scripts/ambient_life/*`, что в текущем репозитории отсутствует.

---

## 3) Находки

### A-01 (High): Массовый legacy drift в runtime-ссылках документации

Симптом:
- В ряде канонических и обзорных файлов используются ссылки/область действия вида `scripts/ambient_life/*` и имена `al_*.nss`, при том что фактический runtime-контур находится в `scripts/daily_life/*.nss`.

Подтверждение (примеры):
- `docs/12B_RUNTIME_MASTER_PLAN.md` (множество ссылок на `scripts/ambient_life/al_*.nss`).
- `docs/07_SCENARIOS_AND_ALGORITHMS.md` (список файлов `al_*`).
- `docs/10_NPC_RESPAWN_MECHANICS.md` (runtime references на legacy путь).
- `docs/12A_WORLD_MODEL_CANON.md`, `docs/12C_PLAYER_PROPERTY_SYSTEM.md`, `docs/12D_WORLD_TRAVEL_CANON.md` (scope c `scripts/ambient_life/*`).
- `docs/06_SYSTEM_INVARIANTS.md` и `docs/library/IDEA_CARD_TEMPLATE.md` (legacy-пути в правилах/шаблонах).

Риск:
- Новая правка может уйти в неверную файловую модель.
- Ревью/онбординг получают устаревшую «карту кода».
- Увеличивается вероятность несинхронных изменений между документами и реальным runtime.

Рекомендация:
- Провести отдельный doc-migration-pass: унифицировать runtime-path на `scripts/daily_life/*` и/или завести явную mapping-таблицу `al_* -> dl_*` в одном SoT.

---

### A-02 (Medium): Режимный маркер `documentation/design mode` всё ещё жив

Симптом:
- В `docs/architecture/02_OPEN_DESIGN_QUESTIONS.md` статусная строка остаётся `active (documentation/design mode)`.

Риск:
- Противоречит active implementation фазе и может уводить процесс в «только дизайн» трактовку.

Рекомендация:
- Обновить формулировку на совместимую с текущей фазой исполнения (например, `active (design register during active implementation)`).

---

### A-03 (Low): Наличие шаблонного DEC-плейсхолдера

Симптом:
- В `docs/10_DECISIONS_LOG.md` присутствует строка-шаблон `DEC-XXXX`.

Риск:
- Низкий. Это допустимо как шаблон, но может попасть в рабочие выборки автоматического отчёта как «непринятое решение».

Рекомендация:
- Явно пометить блок как template-only (если ещё не помечен) либо вынести шаблон в `docs/library`.

---

## 4) Технические проверки runtime-кода

### T-01: include-целостность `scripts/daily_life`

Проверено 21 `.nss` файл в `scripts/daily_life`.  
Результат: **0 missing include**.

Вывод: локальная структурная целостность include-графа в текущем runtime-контуре соблюдена.

### T-02: merge-маркеры

Поиск `<<<<<<<|=======|>>>>>>>` не выявил merge-артефактов в коде/доках (кроме буквального упоминания сигнатур в тексте уже существующего audit-документа).

### T-03: enum sanity check (`dl_const_inc.nss`)

Повторяющиеся integer-значения присутствуют, но выглядят как ожидаемая практика независимых enum-групп с общей числовой шкалой внутри разных доменов констант.  
Критических признаков коллизии в рамках этого прохода не обнаружено.

---

## 5) Приоритетный план закрытия

1. **P1 (обязательно):** закрыть legacy drift (`ambient_life -> daily_life`) в `12B_RUNTIME_MASTER_PLAN`, `07_SCENARIOS_AND_ALGORITHMS`, `10_NPC_RESPAWN_MECHANICS`, `06_SYSTEM_INVARIANTS`, `README`-связках.
2. **P2:** обновить режимный статус `docs/architecture/02_OPEN_DESIGN_QUESTIONS.md`.
3. **P3:** нормализовать шаблонные DEC-записи для чистоты decision register.
4. **P4:** после правок провести короткий re-audit теми же командами + spot-check ссылок.

---

## 6) Итог

На 2026-04-02 репозиторий операционно работоспособен для продолжения Milestone A, но документационный слой всё ещё несёт значимый исторический след legacy `ambient_life`-структуры.  
Ключевая задача следующего шага — не менять механику, а довести docs-navigation/runtime mapping до однозначного, чтобы снизить риск ошибочных правок в ежедневной разработке.
