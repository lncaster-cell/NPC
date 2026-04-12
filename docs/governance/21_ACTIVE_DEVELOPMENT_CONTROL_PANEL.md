# Ambient Life — Active Development Control Panel

Дата: 2026-04-12
Статус: execution control panel

## 0) Режим работы

- Формат: **code-first**.
- Документационный scope ведётся только через `docs/library/DOCUMENT_REGISTRY.md`: **5 canonical + ограниченный operational reference list**.
- Канонический runtime workspace path: `daily_life/`.
- Любые ссылки на `scripts/daily_life/` считаются legacy.

## 1) Текущий фактический статус

- Owner-run текущего clean-room lifecycle/registry slice уже выполнен (см. acceptance journal).
- Подтверждены `AREA_ENTER`, `HB`, death lifecycle и cleanup регистрации в isolated area (`reg: 1 -> 0`).
- Это **не равно** полному закрытию Milestone A.
- Обязательный acceptance gate по **Scenario F** и **Scenario G** закрыт (`PASS/PASS`).
- Текущая рабочая точка: сценарии A–E (первый целевой vertical slice — `BLACKSMITH` A/B как `WORK/SLEEP`).
- **Текущий микро-фокус итерации:** не расширять vertical slice дальше, а **закрыть именно `SLEEP` directive scenario** как устойчивый execution-path, включая sleep behavior / sleep presentation / sleep animations без визуальной дёрготни и ложного state-advance.
- Переход к Step 07+ по-прежнему не подтверждён до закрытия A–G целиком.

## 2) Документационный scope (единый источник)

Единый источник границ: `docs/library/DOCUMENT_REGISTRY.md`.

Двухуровневая модель:
1. **Canonical active set (5 файлов)** — обязательный канонический контур.
2. **Operational reference (allowed but non-canonical)** — ограниченный список для текущей операционной точки; не расширяет canonical контур.

Для этой панели любые самостоятельные трактовки scope запрещены: состав и статус слоёв берётся только из реестра.

## 3) Правила PR

1. Каждый PR должен содержать полезный кодовый сдвиг в `daily_life/`, кроме специально выделенных cleanup PR.
2. Док-изменения допускаются только в рамках модели из `DOCUMENT_REGISTRY.md` и только как синхронизация факта.
3. Новые digest/индексные meta-файлы не добавляются.
