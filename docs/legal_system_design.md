# Суд, арест и плен — технический дизайн-документ

**Статус:** Draft v1.0  
**Целевая платформа:** Neverwinter Nights 2 Persistent World  
**Движок/рантайм:** NWN2 + NWScript + NWNX4  
**Источник истины данных:** внешняя SQLite БД  
**Назначение документа:** репозиторный дизайн-док для реализации системы суда, ареста, плена и клановой преступности

---

## 1. Цель документа

Этот документ фиксирует целевую архитектуру системы права и принуждения для PW на NWN2. Документ предназначен для разработчиков репозитория и описывает:

- игровые контуры ареста, суда, плена и побега;
- ограничения NWN2 и их влияние на архитектуру;
- модель данных в SQLite;
- state machine по стадиям дела и содержания под стражей;
- точки интеграции с NWScript и модулем;
- требования по отказоустойчивости, производительности и антиабьюзу.

Документ исходит из уже принятого решения: **campaign DB не используется**, долговременное состояние хранится во **внешней SQLite БД**.

---

## 2. Контекст и ограничения

### 2.1. Что должно уметь решение

Система должна поддерживать:

1. Арест игрока или NPC по законному или незаконному основанию.
2. Содержание под стражей в специальной jail-area.
3. Окно побега до суда.
4. Судебное разбирательство через conversations и cutscenes.
5. Приговор с несколькими типами наказаний.
6. Повторные правонарушения и долгосрочную криминальную историю.
7. Правовой статус клана, включая возможность признать клан преступным.
8. Восстановление состояния после relog/crash/reset.
9. Работу без обязательного участия DM, но с возможностью DM override.

### 2.2. Ограничения NWN2

Архитектура обязана учитывать следующие свойства движка:

- Conversations и cutscenes в NWN2 хорошо подходят для постановки суда, но не являются источником истины.
- `DelayCommand()` нельзя использовать как основу длительной тюремной логики.
- `SetCutsceneMode(TRUE)` требует аккуратного снятия и безопасного восстановления после дисконнекта.
- `OnClientEnter`, `OnClientLeave`, `OnExit`, `OnHeartbeat` имеют разные гарантии и edge cases.
- PC faction не подходит как модель правового статуса игрока или клана.
- Heartbeat нельзя размазывать по десяткам placeables/doors/NPC без риска деградации производительности.

### 2.3. Принципы проектирования

1. **SQLite — источник истины.**  
   Состояние дела, ареста, дедлайнов, побегов, приговоров и статусов кланов хранится в БД.

2. **Local variables — только кэш.**  
   Локальные переменные используются для быстрого доступа, но не считаются каноническими.

3. **Суд — presentation layer.**  
   Судебный процесс показывается через диалоги и катсцены, но решение принимается на основе данных из БД.

4. **State machine вместо разрозненных скриптов.**  
   Каждое дело и каждая сессия содержания под стражей имеют явную стадию.

5. **Reconciliation вместо доверия событиям.**  
   Критичные переходы должны подтверждаться сервисной сверкой при логине, входе в зону, heartbeat и старте диалога.

---

## 3. Игровой контур

### 3.1. Базовый сценарий

Нормальный поток выглядит так:

1. Фиксируется преступление.
2. Создается или обновляется правовой статус персонажа.
3. Персонаж арестовывается или добровольно сдается.
4. Создается `custody_session`, игрок переводится в jail-area.
5. Запускается окно побега до суда.
6. По истечении окна игрок доставляется в courtroom.
7. Идет судебная сцена через conversations/cutscene.
8. Система выносит приговор.
9. Запускается наказание: освобождение, штраф, тюремный срок, конфискация, изгнание и т.д.
10. Правовой и клановый статусы пересчитываются.

### 3.2. Разделение на контуры

Система делится на два смежных контура:

#### Гражданско-правовой контур

- преступление;
- задержание;
- следствие/дело;
- суд;
- наказание.

#### Военно-карательный контур

- захват в бою;
- содержание под стражей;
- обмен/выкуп/допрос/вербовка;
- побег;
- внесудебные последствия.

Оба контура используют одну и ту же модель `custody_session`, но разные основания ареста и разные допустимые развязки.

---

## 4. Цели и нецели

### 4.1. Цели

- Устойчивость к relog/crash/reset.
- Понятные игровые последствия преступлений.
- Поддержка как автоматического, так и RP-режима.
- Модульность: систему можно развивать без переписывания ядра.
- Низкая стоимость поддержки в NWScript.

### 4.2. Нецели первой версии

- Полноценная симуляция права с прецедентами и ручным доказательственным правом.
- Полная AI-симуляция свидетелей и судей.
- Реалистичные многодневные тюремные сроки в реальном времени.
- Смена движковых faction у PC как основной правовой механизм.

---

## 5. Архитектура верхнего уровня

### 5.1. Слои

#### 5.1.1. Domain layer

Чистая предметная логика:

- crime registration;
- warrants;
- case lifecycle;
- custody lifecycle;
- sentencing;
- legal summary;
- clan sanctions.

#### 5.1.2. Persistence layer

Работа с SQLite:

- запросы;
- транзакции;
- миграции;
- агрегаты;
- кэширование.

#### 5.1.3. Engine integration layer

Связывает БД и NWN2 runtime:

- `OnClientEnter` restore;
- `OnClientLeave` snapshot;
- module heartbeat reconciliation;
- triggers/areas/doors;
- NPC bootstrap scripts.

#### 5.1.4. Presentation layer

То, что видит игрок:

- диалоги ареста;
- courtroom conversations;
- cutscene delivery;
- jail-area logic;
- UI-сообщения;
- reactions guards/NPC/services.

### 5.2. Основная идея устойчивости

Стадии не зависят от того, сработало ли конкретное событие. Если событие потерялось, система все равно догоняет игрока до правильного состояния при следующей проверке.

Пример:

- `court_due_at` уже наступил;
- игрок вышел из игры до перевода в суд;
- при следующем логине `restore/reconcile` видит просроченную стадию и переводит персонажа в courtroom flow.

---

## 6. Сущности предметной области

### 6.1. Crime Event

Фиксирует отдельный инцидент.

Поля:

- `crime_event_id`
- `character_id`
- `clan_id`
- `crime_type`
- `severity`
- `location_tag`
- `victim_id`
- `reporter_id`
- `witness_count`
- `is_caught_in_act`
- `created_at`
- `source_type` (combat, script, witness, confession, DM)
- `case_id` nullable

### 6.2. Warrant

Основание для принудительного задержания.

Поля:

- `warrant_id`
- `target_character_id`
- `scope` (local, city, realm, clan, emergency)
- `legal_basis`
- `issued_by`
- `issued_at`
- `expires_at`
- `status` (active, served, revoked, expired)

### 6.3. Case File

Судебное дело.

Поля:

- `case_id`
- `accused_character_id`
- `prosecutor_id`
- `judge_id`
- `status`
- `stage_reason`
- `created_at`
- `scheduled_at`
- `verdict_at`
- `verdict_code`
- `verdict_score`
- `dm_override_flag`
- `notes`

### 6.4. Custody Session

Факт содержания под стражей.

Поля:

- `custody_id`
- `character_id`
- `case_id`
- `arrest_reason_code`
- `arrest_legal_basis`
- `arrested_by_actor_id`
- `arrest_started_at`
- `escape_window_until`
- `court_due_at`
- `current_stage`
- `jail_area_tag`
- `cell_waypoint_tag`
- `courtroom_area_tag`
- `courtroom_waypoint_tag`
- `is_confiscation_complete`
- `is_cutscene_pending`
- `escape_attempts`
- `escaped_at`
- `released_at`

### 6.5. Sentence

Факт наказания.

Поля:

- `sentence_id`
- `case_id`
- `character_id`
- `sentence_type`
- `duration_seconds`
- `fine_amount`
- `confiscation_policy`
- `banish_area_tag`
- `starts_at`
- `ends_at`
- `status`

### 6.6. Character Legal Status

Итоговый правовой статус персонажа.

Поля:

- `character_id`
- `wanted_level`
- `is_fugitive`
- `crime_score_total`
- `crime_score_violent`
- `crime_score_property`
- `crime_score_state`
- `conviction_count`
- `escape_count`
- `last_conviction_at`
- `last_case_id`

### 6.7. Clan Legal Status

Итоговый правовой статус клана.

Поля:

- `clan_id`
- `status` (normal, suspected, sanctioned, outlawed)
- `crime_score_total`
- `convicted_member_count_recent`
- `fugitive_member_count`
- `source_case_id`
- `since_ts`
- `until_ts`
- `review_due_ts`

---

## 7. Модель данных SQLite

### 7.1. Таблицы

Обязательный минимум:

- `player_account`
- `character`
- `clan`
- `clan_member`
- `crime_event`
- `warrant`
- `case_file`
- `case_charge`
- `case_witness`
- `case_evidence`
- `custody_session`
- `sentence`
- `legal_status_character`
- `legal_status_clan`
- `confiscated_item`
- `escape_attempt`
- `court_schedule`
- `guard_action_log`

### 7.2. Рекомендуемые индексы

```sql
CREATE INDEX idx_crime_event_character_time
ON crime_event(character_id, created_at);

CREATE INDEX idx_crime_event_clan_time
ON crime_event(clan_id, created_at);

CREATE INDEX idx_case_file_status_sched
ON case_file(status, scheduled_at);

CREATE INDEX idx_custody_stage_due
ON custody_session(current_stage, court_due_at);

CREATE INDEX idx_legal_status_character_fugitive
ON legal_status_character(is_fugitive, wanted_level);

CREATE INDEX idx_legal_status_clan_status
ON legal_status_clan(status);
```

### 7.3. Политика SQLite

При открытии соединения обязательно:

```sql
PRAGMA foreign_keys = ON;
PRAGMA journal_mode = WAL;
PRAGMA busy_timeout = 5000;
```

Рекомендуется:

- использовать `PRAGMA user_version` для миграций схемы;
- вызывать `PRAGMA optimize` по административному расписанию;
- держать write-транзакции короткими;
- не выполнять длительные сценические операции внутри транзакции.

---

## 8. State machine

### 8.1. Стадии дела (`case_file.status`)

```text
new
investigating
awaiting_arrest
in_custody
awaiting_trial
in_trial
verdict_pending_finalize
sentenced
closed
voided
```

### 8.2. Стадии содержания (`custody_session.current_stage`)

```text
none
field_detained
transport_to_jail
jailed_pretrial
awaiting_trial_transfer
trial_transport
in_trial
post_verdict_hold
serving_sentence
released
escaped
dead_in_custody
transferred
```

### 8.3. Переходы

#### Арест

- `new/investigating -> awaiting_arrest`
- `awaiting_arrest -> in_custody`
- создается `custody_session`

#### Предсудебная тюрьма

- `field_detained -> transport_to_jail`
- `transport_to_jail -> jailed_pretrial`
- `jailed_pretrial -> awaiting_trial_transfer` при наступлении `court_due_at`

#### Побег

- `jailed_pretrial -> escaped`
- `awaiting_trial_transfer -> escaped`
- `is_fugitive = 1`
- штраф к `verdict_score`
- возможный рост кланового риска

#### Суд

- `awaiting_trial -> in_trial`
- `in_trial -> verdict_pending_finalize`
- `verdict_pending_finalize -> sentenced`

#### Наказание

- `sentenced -> serving_sentence`
- `serving_sentence -> released`

### 8.4. Идемпотентность

Каждый terminal transition обязан быть идемпотентным. Повторный вызов finalize-скрипта не должен:

- создавать второй штраф;
- повторно конфисковывать предметы;
- создавать второй `sentence`;
- повторно менять статус клана.

---

## 9. Игровые правила

### 9.1. Основания для ареста

- преступление застигнуто с поличным;
- есть действующий warrant;
- есть прямой законный приказ;
- персонаж принадлежит к outlawed-клану;
- персонаж добровольно сдался.

### 9.2. Законный и незаконный арест

У ареста должен быть признак законности:

- `lawful_arrest = 1` — действует стандартный поток;
- `lawful_arrest = 0` — повышается риск негативных последствий для стороны обвинения и может открываться дополнительная защитная ветка в суде.

### 9.3. Окно побега

Базовая модель:

- по умолчанию 10 минут реального времени;
- хранится как timestamp `escape_window_until`;
- не зависит от непрерывной работы одного скрипта;
- может модифицироваться тяжестью преступления, статусом города, загруженностью суда.

### 9.4. Способы побега

Рекомендуется поддержать минимум три канала:

1. **Геометрический** — двери, решетки, тайные ходы.
2. **Социальный** — подкуп, договор, помощь союзников.
3. **Событийный** — rescue, перевод, ошибка охраны, отвлечение.

### 9.5. Суд

Суд идет по фазам:

1. вводная сцена;
2. оглашение обвинений;
3. ответ обвиняемого;
4. показания свидетелей;
5. расчет/выбор вердикта;
6. оглашение приговора;
7. post-trial transition.

### 9.6. Варианты приговора

Минимальный набор:

- оправдание;
- штраф;
- конфискация;
- краткий срок;
- длительный срок;
- изгнание;
- клановая санкция;
- статус fugitive при неявке/побеге.

---

## 10. Модель приговора

### 10.1. Подход

Базовый режим — автоматический расчет с возможностью DM override.

### 10.2. Пример расчета

```text
verdict_score =
  sum(charge_weight)
+ sum(evidence_weight)
+ sum(witness_weight)
+ repeat_offender_bonus
+ escape_bonus
+ outlaw_clan_bonus
- self_defense_modifier
- alibi_modifier
- unlawful_arrest_modifier
```

### 10.3. Интерпретация результата

```text
<= 0      -> оправдание
1..20     -> штраф
21..40    -> штраф + конфискация
41..70    -> тюремный срок
71..100   -> тяжкий срок / изгнание / особая санкция
```

### 10.4. DM override

Для особых дел разрешен ручной режим:

- смягчить;
- ужесточить;
- заменить тип наказания;
- отправить на пересмотр;
- закрыть дело как политическое/особое.

---

## 11. Клановая преступность

### 11.1. Почему это отдельная система

Клановая преступность не должна кодироваться через faction PC. Это отдельный правовой статус, который влияет на реакцию мира.

### 11.2. Стадии кланового статуса

```text
normal
suspected
sanctioned
outlawed
```

### 11.3. Условия повышения статуса

Пример правил:

- 3 и более членов клана осуждены за тяжкие преступления за период;
- клан укрывает беглецов;
- несколько членов сбежали из-под стражи;
- глава клана осужден;
- клан атаковал guards/court/state NPC.

### 11.4. Последствия

#### suspected

- чаще проверки guards;
- отдельные подозрительные реплики;
- рост цен залога.

#### sanctioned

- ограничения сервисов;
- больше штрафы;
- ускоренный арест;
- отдельные ветки в суде.

#### outlawed

- упрощенные основания ареста;
- запрет на часть зон;
- отказ части NPC/merchant/services;
- автоматические дополнительные отягчающие в суде.

### 11.5. Политика пересмотра

Клановый статус не обязан быть вечным.

- `review_due_ts` — дата автоматического пересмотра;
- возможны варианты смягчения после срока, штрафов, выдачи беглецов, политических договоренностей.

---

## 12. NWScript интеграция

### 12.1. Рекомендуемая структура скриптов

```text
scripts/legal/
  lg_db.nss
  lg_db_case.nss
  lg_db_custody.nss
  lg_db_status.nss
  lg_service_case.nss
  lg_service_custody.nss
  lg_service_clan.nss
  lg_service_reconcile.nss
  lg_conv_case_cond.nss
  lg_conv_case_action.nss
  lg_conv_witness_cond.nss
  lg_conv_witness_action.nss
  lg_cutscene_trial_start.nss
  lg_cutscene_trial_end.nss
  lg_guard_arrest.nss
  lg_guard_release.nss
  lg_jail_escape.nss
  lg_area_jail_enter.nss
  lg_area_court_enter.nss
  lg_mod_client_enter.nss
  lg_mod_client_leave.nss
  lg_mod_heartbeat.nss
```

### 12.2. Обязательные entry points

#### `OnClientEnter`

Должен:

- загрузить legal/custody summary по персонажу;
- восстановить local cache;
- поставить post-enter reconcile;
- при необходимости вернуть игрока в jail или courtroom flow.

#### `OnClientLeave`

Должен:

- сохранить безопасный snapshot текущих правовых стадий;
- снять cutscene mode при необходимости;
- завершить или пометить незавершенную сцену;
- записать позицию/сервисные маркеры.

#### `Module OnHeartbeat`

Должен:

- обрабатывать только ограниченный пул “грязных” или просроченных записей;
- переводить стадии по дедлайнам;
- инициировать deliver-to-court;
- завершать сроки наказаний.

#### `Guard OnConversation / Arrest Script`

Должен:

- проверить warrant/legal status;
- создать или выбрать active case;
- создать custody session;
- инициировать конфискацию и перевод в jail.

#### `Judge/Prosecutor Start Script`

Должен:

- загрузить `case_id`;
- проверить актуальную стадию;
- подготовить context для conversation;
- вызвать `BeginConversation()`.

### 12.3. Параметризованные conversation scripts

Один и тот же conditional/action script должен переиспользоваться на множестве нод через `GetScriptParam()`.

Примеры параметров:

- `case_id`
- `charge_id`
- `witness_id`
- `evidence_id`
- `stage_code`
- `sentence_type`

Это обязательное требование, чтобы не плодить десятки уникальных скриптов для каждой реплики.

---

## 13. Conversations и cutscenes

### 13.1. Общие правила

- Суд проектируется как **один основной conversation pipeline**, а не как набор разрозненных диалогов.
- Ветки зависят от состояния дела, а не от отдельных hardcoded разговоров.
- Speaker/listener и камеры используются для постановки, но логика опирается на БД.

### 13.2. Рекомендуемый flow суда

1. Игрок доставлен в courtroom.
2. Включается сценический режим.
3. Стартует `court_trial_main`.
4. Обвинитель оглашает список `case_charge`.
5. Игрок выбирает позицию защиты.
6. Свидетели включаются condition-нодами.
7. Judge получает финальную развилку на основе контекста.
8. Финальная action-нода пишет приговор в БД.
9. Сцена закрывается и запускается post-verdict transition.

### 13.3. Требования безопасности

- Любая реплика, доступность которой зависит от денег/статуса/предмета/права, перепроверяется не только в condition, но и в action.
- Нельзя считать, что мир не изменился между показом реплики и ее выбором.
- Все критичные финальные действия должны быть идемпотентными.

---

## 14. Jail-area дизайн

### 14.1. Требования к зоне

Jail-area должна быть не просто комнатой ожидания, а специальной функциональной зоной.

Обязательные элементы:

- камера(ы);
- guard post;
- evidence/confiscation storage;
- точки доставки и вывода;
- минимум один побеговой маршрут;
- триггеры допуска/запрета;
- отдельные conversation точки для guards.

### 14.2. Ограничения на персонажа в custody

Рекомендуется:

- конфискация или временная блокировка оружия;
- ограничение доступа к части сервисов;
- особые реакции NPC;
- контроль попыток выйти из тюремной зоны без санкции.

### 14.3. Конфискация

Конфискация должна быть явной подсистемой.

- предметы записываются в `confiscated_item`;
- после освобождения предметы возвращаются по политике приговора;
- повторная конфискация не должна дублировать предметы.

---

## 15. Отказоустойчивость

### 15.1. Crash/relog безопасность

Система обязана корректно переживать:

- выход игрока во время ареста;
- выход игрока во время тюрьмы;
- выход игрока во время суда;
- рестарт сервера;
- сбой во время катсцены.

### 15.2. Политика восстановления

При восстановлении игрока сервис должен определить:

- есть ли активный `custody_session`;
- просрочен ли `court_due_at`;
- должен ли игрок быть в jail, courtroom или serving sentence;
- находится ли персонаж в статусе fugitive.

### 15.3. Reconciliation policy

Переходы стадий должны вызываться из нескольких точек:

- `OnClientEnter`
- module heartbeat
- вход в jail-area
- вход в courtroom-area
- старт разговора с guard/judge

Это снижает зависимость от одного конкретного события движка.

---

## 16. Производительность

### 16.1. Что запрещено

- десятки тяжелых heartbeat на placeables;
- длинные write-транзакции SQLite;
- полный пересчет всех дел каждый тик;
- один скрипт на каждую отдельную реплику суда.

### 16.2. Что рекомендуется

- вести кэш legal summary в local vars на PC;
- обрабатывать только “грязные” или ближайшие по дедлайну custody/case записи;
- писать в БД пакетно и коротко;
- хранить агрегаты (`legal_status_*`) отдельно от append-only истории.

---

## 17. Безопасность и антиабьюз

### 17.1. Защита от logout exploit

- logout не отменяет арест;
- правовой статус сохраняется в БД немедленно;
- на relog игрок восстанавливается в правовую стадию.

### 17.2. Защита от дублирования приговора

- финализация дела должна быть идемпотентной;
- `sentence` должен иметь уникальную связь с `case_id`;
- штраф и конфискация не должны применяться дважды.

### 17.3. Защита от фальшивых побегов

- побег не определяется одним `OnExit`;
- нужен явный маркер успешного escape path или reconcile-проверка местоположения/стадии.

### 17.4. Защита от незаконного ареста как абьюза

- незаконный арест должен создавать процессуальные минусы для обвинения;
- рецидив злоупотреблений guards/factions может быть предметом отдельной правовой механики в будущем.

---

## 18. Рекомендуемый MVP

### 18.1. Что входит в v1

- регистрация преступлений;
- арест и `custody_session`;
- jail-area;
- окно побега;
- courtroom conversation;
- 1 прокурор, 1 судья, 1 свидетель;
- автоматический приговор;
- штраф, конфискация, тюремный срок, оправдание;
- personal crime score;
- fugitive status;
- базовый clan crime status.

### 18.2. Что переносится в v2+

- rescue events;
- полноценные апелляции;
- залог и поручительство;
- каторга и общественные работы;
- политические процессы;
- расширенная witness/evidence logic;
- дипломатия и выкуп пленников.

---

## 19. План реализации

### Phase 1 — Foundation

- внедрить SQLite schema;
- реализовать DB helpers;
- реализовать local-cache policy;
- подключить module lifecycle hooks.

### Phase 2 — Custody core

- arrest flow;
- confiscation;
- jail placement;
- escape window;
- release flow.

### Phase 3 — Court core

- `case_file` lifecycle;
- `court_trial_main` conversation;
- verdict calculator;
- sentence finalization.

### Phase 4 — Legal summaries

- character legal summary;
- clan legal summary;
- guard/store/service reactions.

### Phase 5 — Hardening

- reconcile after relog/crash;
- anti-duplicate protection;
- performance tuning;
- QA scenarios.

---

## 20. QA-сценарии

Минимальный обязательный набор тестов:

1. Арест → relog → игрок все еще в custody.  
2. Арест → побег → relog → статус fugitive сохранен.  
3. Арест → окончание окна → суд стартует после relog.  
4. Суд → disconnect в cutscene → корректное восстановление.  
5. Приговор → повторный вызов finalize не дублирует штраф.  
6. Освобождение → конфискованные предметы возвращаются корректно.  
7. Клан получает статус sanctioned после серии осуждений.  
8. Outlawed-клан дает guards право на упрощенный arrest flow.  
9. Несколько игроков с активными делами не ломают модульный heartbeat.  
10. Большое количество старых crime_event не мешает работе активных кейсов.

---

## 21. Открытые вопросы

1. Является ли срок тюрьмы чисто реальным временем или частью может быть offline-progression?  
2. Может ли игрок откупиться до суда?  
3. Кто имеет право инициировать warrant: только NPC-государство или также игроки-должностные лица?  
4. Нужен ли отдельный военный режим плена вне суда?  
5. Какой набор преступлений входит в MVP?  
6. Нужны ли публичные списки разыскиваемых и реестр осужденных?

---

## 22. Итоговое архитектурное решение

Финальное решение для репозитория формулируется так:

> Система суда, ареста и плена реализуется как модульная state-machine над внешней SQLite БД.  
> БД хранит юридическую истину, NWScript обеспечивает интеграцию и reconciliation, а conversations/cutscenes выступают presentation layer для судебных и тюремных сцен.

Это решение выбрано потому, что оно:

- устойчиво для PW на NWN2;
- переживает relog/crash/reset;
- не зависит от campaign DB;
- расширяемо до клановой преступности, военного плена и DM override;
- хорошо ложится на ограничения движка и на уже найденные community best practices.

---

## Приложение A. Минимальные enum-константы

```text
CrimeType:
  THEFT
  ASSAULT
  MURDER
  TRESPASS
  CONTRABAND
  RESISTING_ARREST
  ESCAPE_CUSTODY
  HARBORING_FUGITIVE
  ATTACK_ON_GUARD
  ATTACK_ON_COURT

SentenceType:
  ACQUITTAL
  FINE
  CONFISCATION
  JAIL_SHORT
  JAIL_LONG
  EXILE
  CLAN_SANCTION
  FUGITIVE_MARK

ClanStatus:
  NORMAL
  SUSPECTED
  SANCTIONED
  OUTLAWED
```

## Приложение B. Рекомендуемая naming policy

- Префикс скриптов: `lg_` (legal).
- Префикс БД-таблиц без модульных сокращений, чтобы сохранить читаемость.
- Все stage/status значения хранить в нижнем регистре snake_case.
- Все timestamps хранить в UTC.

## Приложение C. Рекомендуемые local vars на PC

```text
LG_CHARACTER_ID
LG_ACTIVE_CASE_ID
LG_ACTIVE_CUSTODY_ID
LG_WANTED_LEVEL
LG_IS_FUGITIVE
LG_CLAN_STATUS
LG_LEGAL_SUMMARY_VERSION
LG_CUTSCENE_GUARD
LG_RESTORE_PENDING
```
