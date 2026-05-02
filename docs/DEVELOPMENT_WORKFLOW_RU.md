# Development Workflow (RU)

## Назначение

Короткий практический документ для сопровождения разработки Daily Life без разрастания лишней документации.

## Обязательный порядок для runtime-правок

1. **Проверить штатные механики** NWN2/NWScript (NWN Lexicon) для задачи.
2. Внести изменение в `daily_life/*.nss` минимальным безопасным диффом.
3. Проверить инварианты: bounded execution, idempotent transitions, observability.
4. Синхронизировать документацию:
   - архитектурный контекст: `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`;
   - оперативный прогресс: `docs/DEVELOPMENT_STATUS_RU.md`.
5. Каждый новый `docs/audits/post_refactor_audit_pass*.md` считается завершённым только после обновления `docs/audits/risk_register.md` в том же коммите.
6. Если меняется wiring/локалки/entrypoint-контракты — обновить `README.md` в том же коммите.
7. Новые `case kind` / `case resolution` / detain-crime diagnostic status строки добавлять только через contract-слой (`daily_life/dl_runtime_contract_inc.nss` или специализированный `*_contract_inc`) и затем использовать только константы.
8. Для контрактных status-строк обязателен статический контроль: `rg` по raw literal не должен находить вхождений вне contract-файла.



## Runtime Regression Gates (Daily Life)

Минимальные runtime-gates обязательны для любой PR с правками `daily_life/*.nss` (worker/resync/lifecycle/city-response/legal).

### Gate 1 — Worker/Resync cursor progression при `nNpcProcessed == 0`

**Цель:** исключить stall курсора и повторное «залипание» на одном слоте в bounded round-robin, даже если за тик не обработано ни одного NPC.

**Что смотреть:**
- area-local курсор worker/resync до/после тика (`dl_cursor`, `dl_resync_cursor` или актуальные area-local ключи курсора в runtime-контракте);
- `nNpcProcessed`, `nNpcSeen`, рассчитанный шаг advance (через diagnostics/trace, где доступно);
- area/module last_processed метрики и отсутствие долгого plateau при живом тике.

### Gate 2 — No same-tick duplicate processing в HOT+resync window

**Цель:** один и тот же NPC не должен повторно проходить materialization/transition в пределах одного tick-window из-за пересечения hot worker и area-enter resync.

**Что смотреть:**
- tick-stamp ключи на area/NPC (`dl_area_tick`, `dl_last_tick_processed`, `dl_last_resync_tick` и эквивалентные diagnostics-контракты);
- счётчики skipped/guarded повторов за тот же tick (anti-duplicate guards);
- diag/log маркеры, подтверждающие single-pass на NPC в пределах одного тика.

### Gate 3 — Уникальность offender cooldown key для multiplayer PC

**Цель:** anti-spam/cooldown ключи инцидентов и guard reaction не коллидируют между разными игроками с одинаковым tag.

**Что смотреть:**
- итоговые offender identity/cooldown ключи (`GetPCPublicCDKey` chain, incident/reaction prefixes);
- local cooldown state (`dl_cr_offender_until`, incident/reaction timestamp keys);
- диагностику коллизий: два разных PC в одинаковом сценарии должны получать разные cooldown keys.

### Gate 4 — Корректность SOCIAL partner cache invalidation

**Цель:** partner cache не удерживает stale-ссылки при смерти/деспавне/смене area/невалидном partner и корректно уходит в fallback (обычно PUBLIC).

**Что смотреть:**
- partner cache locals на NPC (partner object/tag + cached tick/time keys);
- invalidation события lifecycle (spawn/death/blocked/area-enter) и их след в diagnostics;
- факт очистки stale partner и корректный fallback directive без loop/flip-flop.

### Правило готовности PR

PR с runtime-правками **не считается завершённым**, пока в описании PR/комментарии ревью нет явного отчёта по всем 4 gate’ам:
- статус каждого gate: `PASS` / `FAIL` / `N/A (обосновано)`;
- короткий evidence-блок: какие ключи/счётчики/диагностика проверялись;
- ссылка на последний regression pass в `docs/DEVELOPMENT_STATUS_RU.md`.

## Mandatory gate перед merge

- Перед merge изменений в runtime-скриптах обязательно пройти policy: `docs/NWN_SCRIPTING_POLICY_RU.md`.
- PR считается неготовым, если любой из mandatory review gates policy не выполнен.

## Минимальный Definition of Done

- [ ] Нет ad-hoc костылей при наличии встроенного механизма NWScript/NWN2.
- [ ] Изменение не ломает lifecycle ingress (spawn/death/blocked).
- [ ] Worker/resync остаются в квотах и без unbounded fan-out.
- [ ] Добавлена/обновлена краткая запись в `docs/DEVELOPMENT_STATUS_RU.md`.
- [ ] При изменении архитектурных правил обновлён unified-документ.

## Политика документации

- `docs/UNIFIED_DESIGN_DOCUMENT_RU.md` — источник архитектурной истины.
- Этот файл и `docs/DEVELOPMENT_STATUS_RU.md` — операционные документы сопровождения (короткие, прикладные, без дублирования всего unified).
- Избегаем создания новых документов без необходимости.

## Чек-лист «обновление документации и README»

- [ ] Проверены штатные функции/паттерны NWScript и релевантные заметки NWN Lexicon.
- [ ] README синхронизирован с фактическими runtime-контрактами (скрипты, локалки, wiring).
- [ ] `docs/DEVELOPMENT_STATUS_RU.md` обновлён текущей датой и кратким changelog.
- [ ] Неподтверждённые owner-run сценарии помечены как `⏳ validation pending`.
- [ ] Для нового audit pass обновлён `docs/audits/risk_register.md` (статусы рисков + regression check).
- [ ] Архитектурные изменения (если есть) отражены в `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`.


### Практика работы с NWN Lexicon

- Перед реализацией новой логики всегда делаем проверку: существует ли штатная функция/событие/паттерн в NWScript.
- Если найдено несколько вариантов, выбираем тот, который снижает runtime-нагрузку и упрощает поддержку.
- Если приходится делать адаптер, в PR/коммите кратко фиксируем, почему встроенный механизм не подошёл.
