# Development Workflow (RU)

## Назначение

Короткий практический документ для сопровождения разработки Daily Life без разрастания лишней документации.

## Обязательный порядок для runtime-правок

1. **Проверить штатные механики** NWN2/NWScript (NWN Lexicon) для задачи.
2. Внести изменение в `daily_life/*.nss` минимальным безопасным диффом.
3. Проверить инварианты: bounded execution, idempotent transitions, observability.
4. **Legacy Cleanup Pass (remove old paths)** — обязательный этап сразу после реализации.
5. Синхронизировать документацию:
   - архитектурный контекст: `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`;
   - оперативный прогресс: `docs/DEVELOPMENT_STATUS_RU.md`.
5. Каждый новый `docs/audits/post_refactor_audit_pass*.md` считается завершённым только после обновления `docs/audits/risk_register.md` в том же коммите.
6. Если меняется wiring/локалки/entrypoint-контракты — обновить `README.md` в том же коммите.
7. Новые diagnostic-коды вводить только через contract-константы (канонический словарь в профильном `*_contract_inc.nss`), без raw-строк в runtime-логике.
8. После **каждого этапа унификации** запускать статический поиск неиспользуемых функций/констант в `daily_life/*.nss` (`rg` по имени + ручная call-site проверка).
9. Deprecated-функции удалять в **том же PR**, где введён replacement (долгое сосуществование старого и нового пути запрещено).
10. Если временное сосуществование неизбежно, оставлять явный маркер `remove-by: <YYYY-MM-DD|version>; owner: <name>` рядом с transitional-кодом.
11. Для area-domain guard-проверок соблюдать единый порядок: `runtime gate -> object validity -> area/tier/domain toggle`; использовать только канонические helper’ы `DL_CanRun*ForArea`, без inline-дубликатов.



## Legacy Cleanup Pass (remove old paths)

Этап обязателен для каждого PR с новой реализацией runtime-логики и выполняется **до merge**.

### Чек-лист cleanup-pass

- [ ] Нет дублирующих entrypoints с одинаковой ролью (старый и новый путь не живут параллельно без явной причины).
- [ ] Нет raw literal-диагностик вне contract-слоя (`*_contract_inc.nss` / централизованный diag-contract).
- [ ] Нет inline reset action-queue, если в проекте уже есть канонический helper для этого reset-сценария.
- [ ] Legacy-path либо удалён, либо присутствует deprecation record с `remove_by` в `docs/DEPRECATION_REGISTRY_RU.md`.
- [ ] Transitional-код ограничен thin compatibility adapters; развитие legacy-path (новая функциональность/новые ветки) запрещено.

### Merge-правило для новой реализации

- Если в PR добавляется новый runtime-путь/реализация, старый путь должен быть:
  1) удалён в том же PR, **или**
  2) явно помечен как legacy с дедлайном удаления (конкретная дата) и задачей на удаление в backlog.

PR без выполнения одного из этих условий считается неготовым к merge.

### Обязательная фиксация cleanup-pass в статусе

Для каждого cleanup-pass нужно обновить `docs/DEVELOPMENT_STATUS_RU.md` и перечислить:
- какие legacy-функции/ветки удалены;
- что временно оставлено как legacy и до какой даты будет удалено (если применимо);
- дату планового удаления compatibility adapters (не позднее одного релизного цикла).

## Static grep-checks: legacy patterns (rg gate)

Перед merge выполнить набор `rg`-проверок на типовые legacy-паттерны:

```bash
# 1) Потенциальные дубли entrypoint-ролей/legacy-теней
rg -n "(legacy|old|deprecated).*(spawn|death|blocked|userdef|worker|resync)|\b(dl_spawn_old|dl_death_old|dl_worker_old|dl_resync_old)\b" daily_life

# 2) Raw literal diagnostics вне contract-слоя
rg -n "(WriteTimestampedLogEntry|SendMessageToPC|FloatingTextStringOnCreature)\(\s*\"[A-Za-z0-9_:-]+\"" daily_life --glob "*.nss" --glob "!**/*contract*.nss"

# 3) Inline action-queue reset при наличии канонического helper
rg -n "\b(ClearAllActions|AssignCommand\(.*ClearAllActions|ActionDoCommand\(.*ClearAllActions)\b" daily_life --glob "*.nss"

# 4) Deprecated identifiers gate (обязательный pre-merge ревью-чек)
rg -n -f docs/deprecation/deprecated_identifiers_rg.txt daily_life
```

Интерпретация:
- пустой вывод (`exit 1`) — PASS;
- непустой вывод — обязательный cleanup/refactor перед merge или документированное исключение с дедлайном удаления legacy.

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
- PR не принимается, если оставляет дубль старого и нового пути без технического обоснования и переходного плана удаления (`remove-by` + owner).

## Минимальный Definition of Done

- [ ] Нет ad-hoc костылей при наличии встроенного механизма NWScript/NWN2.
- [ ] Изменение не ломает lifecycle ingress (spawn/death/blocked).
- [ ] Worker/resync остаются в квотах и без unbounded fan-out.
- [ ] Добавлена/обновлена краткая запись в `docs/DEVELOPMENT_STATUS_RU.md`.
- [ ] При изменении архитектурных правил обновлён unified-документ.
- [ ] Новые diagnostic-коды/сообщения добавлены в канонический contract include, а не разбросаны raw-строками по runtime-веткам.

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

## Static check: reset-policy consistency (rg gate)

Добавлен обязательный grep-gate для обнаружения новых несогласованных reset-паттернов в lifecycle/worker/registry/resync.

Команда:

```bash
rg -n "DeleteLocal(Int|String|Object)\\(.*DL_L_AREA_(TIER|ENTER_RESYNC_(PENDING|CURSOR)|RESYNC_LAST_PROCESSED)|DeleteLocalInt\\(.*DL_L_NPC_RESYNC_PENDING" daily_life/dl_{lifecycle,worker,registry,resync}_inc.nss daily_life/dl_smk_tier.nss
```

Ожидаемое поведение:
- пустой вывод (`exit 1`) — PASS (новых запрещённых reset-паттернов нет);
- непустой вывод — FAIL, требуется приведение к политике из `UNIFIED_DESIGN_DOCUMENT_RU.md` (раздел reset-политики) или явный `COMPAT`-комментарий с планом удаления.

## Static check: unused-symbol sweep после этапов унификации

После каждого завершённого этапа унификации (contract dedupe / include dedupe / replacement migration) обязателен быстрый статический sweep:

1. Выделить кандидаты на удаление (deprecated wrappers, legacy constants/helpers).
2. Для каждого кандидата выполнить `rg -n "<symbol_name>" daily_life/*.nss`.
3. Подтвердить call-site вручную:
   - если найдено только объявление (и/или комментарий) — удалить символ в этом же PR;
   - если есть активные вызовы старого пути — либо мигрировать их в этом же PR, либо добавить `remove-by` маркер с owner и обоснованием.
4. Отразить удалённые legacy-фрагменты в `docs/DEVELOPMENT_STATUS_RU.md` (что удалено и чем заменено).
