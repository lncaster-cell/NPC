# Ambient Life v2 — MASTER PLAN (единый полный мастер-документ)

Дата: 2026-03-14  
Версия: 2 (расширенная, «ответы на основные вопросы в одном файле»)  
Статус: главный onboarding-документ проекта  
Область: `README.md`, `docs/*`, `scripts/ambient_life/*`

---

## КАНОН НА 2026-03-14: NWN2 — мировая модель (обязательный приоритет)

**Статус:** Принято как опорная архитектура для первого модуля.  
**Фиксация канона:** на дату 2026-03-14 этот блок имеет приоритет над ранее принятыми решениями и ранее написанным кодом по данной предметной области; предыдущие решения считаются устаревшими.

### Назначение

Документ фиксирует базовую архитектуру игрового мира для кооперативной песочницы на NWN2.  
Цель — получить систему, в которой:

- поселения имеют владельцев;
- в поселениях действуют собственные законы;
- игроки и организации могут получать гражданство, титулы и полномочия;
- документы имеют игровой смысл;
- преступления определяются законом, а не “на глаз”;
- свидетели и тревога работают поверх штатных механизмов движка;
- фракции NWN2 используются только там, где они действительно подходят.

### 1. Базовый принцип

Архитектура делится на три слоя.

#### 1.1. Слой движка NWN2

Отвечает за немедленную реакцию NPC:

- кого NPC считает другом, врагом или нейтральным;
- увидел ли NPC цель;
- услышал ли NPC цель;
- заметил ли NPC кражу;
- услышал ли NPC тревожный “крик” союзника;
- вступит ли NPC в бой, погоню или задержание.

Опора этого слоя:

- `OnPerception` — событие смены состояния восприятия (`Seen`, `Heard`, `Vanished`, `Inaudible`), а не непрерывное слежение; при обычном входе цели в радиус часто сначала приходит слух, потом зрение.
- `OnDisturbed` — штатный канал вмешательства в инвентарь существа или контейнера; для существ это фактически замеченная кража, а у контейнеров — изменение содержимого.
- слушание и шаблоны фраз через `SetListening`, `SetListenPattern`, `GetListenPatternNumber`; `SetListenPattern` сам по себе не включает режим слушания.
- локальные фракции поведения и их отношения `0 = hostile`, `50 = neutral`, `100 = friendly`.

#### 1.2. Слой постоянного мира

Отвечает за правду о мире:

- государства;
- поселения;
- владельцев;
- законы;
- гражданство;
- титулы;
- полномочия;
- дипломатические статусы;
- глобальный статус преступника;
- реестр документов.

Этот слой хранится в SQLite через NWNX4 `xp_sqlite`. В NWNX4 есть загрузка плагинов через `plugin_list`, и `xp_sqlite` рассматривается как штатный путь для SQL-хранилища в NWN2-модуле.

#### 1.3. Слой игровой логики проекта

Это наша надстройка:

- определение, является ли действие преступлением;
- определение свидетелей;
- уровень тревоги области;
- правовая реакция стражи;
- связь документов с реальными правами;
- смена владельцев и политического режима поселений.

### 2. Почему не строить всё на штатных фракциях

Штатные фракции NWN2 хорошо отвечают на вопрос:
“Как этот NPC должен реагировать прямо сейчас?”

Но они плохо отвечают на вопросы:

- кто юридический владелец города;
- какие тут законы;
- кто имеет право ареста;
- кто гражданин;
- кто правитель;
- кто может менять закон;
- кому принадлежит гарнизон;
- законно ли убийство именно в этом поселении.

Дополнительное жёсткое ограничение: `ChangeFaction()` не переводит игроков между фракциями; Lexicon прямо указывает, что PCs cannot change factions.

Решение: фракции NWN2 используются только как локальные роли поведения ИИ, а не как модель государства и права.

### 3. Почему выбран SQLite

Для проекта выбран SQLite через NWNX4 `xp_sqlite`.

Причины:

- в NWNX4 есть явная поддержка `xp_sqlite` через `plugin_list`;
- SQLite подходит как встроенное прикладное хранилище в одном файле;
- для кооперативной песочницы с одним активным хостом это достаточно простой и реалистичный вариант.

Ограничение сразу фиксируется:

SQLite не должна использоваться как один общий файл, в который много машин напрямую пишут по сети одновременно; сама документация SQLite рекомендует избегать такого сценария и указывает на риски производительности и блокировок на сетевых файловых системах.

### 4. Главные сущности мира

#### 4.1. Realm — государство

Это уровень большой политики.

Поля:

- `realm_id`
- `name`
- `government_type`
- `ruling_entity_type`
- `ruling_entity_id`
- `default_law_profile_id`
- `default_citizenship_profile_id`
- `active_flag`
- `notes`

Смысл:

Государство задаёт правовой и политический фон по умолчанию. Оно не обязано напрямую владеть каждым поселением: поселение может быть вассальным, автономным, оккупированным или временно управляться другой силой.

#### 4.2. Settlement — поселение

Это центральная сущность повседневной игры.

Поля:

- `settlement_id`
- `name`
- `type` (`VILLAGE`, `TOWN`, `CITY`, `FORT`, `PORT`, `CAMP`)
- `realm_id`
- `owner_type`
- `owner_id`
- `law_profile_id`
- `guard_profile_id`
- `citizenship_profile_id`
- `status`
- `module_id`
- `area_scope`
- `notes`

Смысл:

Поселение — это контейнер правил мира. Именно поселение отвечает на вопросы:

- чья это земля;
- какая здесь законная стража;
- какие здесь действуют нормы;
- кто здесь считается “своим”;
- какие документы признаются;
- как трактуются преступления.

#### 4.3. Owner — владелец

Владелец — это не всегда государство. Нужна отдельная абстракция владельца.

Возможные типы:

- `REALM`
- `NPC_HOUSE`
- `NPC_ORDER`
- `CITY_COUNCIL`
- `PLAYER_ORGANIZATION`
- `PLAYER_CHARACTER`
- `OCCUPATION_FORCE`
- `TEMP_ADMINISTRATION`

Поля:

- `owner_type`
- `owner_id`

Смысл:

Эта модель позволяет одинаково обрабатывать:

- королевский город;
- город благородного дома;
- свободную коммуну;
- захваченный город;
- город, перешедший под власть игроков.

### 5. Модель закона

#### 5.1. Общий принцип

Закон моделируется через отдельный `LawProfile`.

Поселение не хранит у себя десятки случайных булевых полей. Оно просто ссылается на профиль закона.

#### 5.2. Что такое “режим”

В этом документе режим — это заранее определённый вариант трактовки конкретной нормы.

Пример: для убийства недостаточно разрешено / запрещено. Нужно уметь выразить:

- разрешено только власти;
- разрешено только в дуэли;
- разрешено против объявленных вне закона;
- разрешено в самообороне.

Поэтому каждая норма хранится как режим, а не как `true/false`.

#### 5.3. LawProfile

Поля:

- `law_profile_id`
- `name`
- `parent_law_profile_id`
- `murder_rule`
- `assault_rule`
- `theft_rule`
- `trespass_rule`
- `arrest_rule`
- `duel_rule`
- `guard_force_rule`
- `fine_policy_id`
- `bounty_policy_id`
- `is_active`
- `notes`

#### 5.4. Базовые режимы закона

`murder_rule`:

- `MURDER_FORBIDDEN`
- `MURDER_ALLOWED`
- `MURDER_ALLOWED_FOR_AUTHORITY`
- `MURDER_ALLOWED_IN_DUEL`
- `MURDER_ALLOWED_AGAINST_OUTLAWS`
- `MURDER_ALLOWED_IN_SELF_DEFENSE`

`assault_rule`:

- `ASSAULT_FORBIDDEN`
- `ASSAULT_ALLOWED`
- `ASSAULT_ALLOWED_FOR_AUTHORITY`
- `ASSAULT_ALLOWED_IN_SELF_DEFENSE`
- `ASSAULT_ALLOWED_IN_DUEL`

`theft_rule`:

- `THEFT_FORBIDDEN`
- `THEFT_TOLERATED`
- `THEFT_ALLOWED`
- `THEFT_ALLOWED_OUTSIDE_SETTLEMENT`
- `THEFT_ALLOWED_BY_OWNER_PERMISSION`

`trespass_rule`:

- `TRESPASS_FORBIDDEN`
- `TRESPASS_RESTRICTED_AREAS_ONLY`
- `TRESPASS_ALLOWED`
- `TRESPASS_ALLOWED_BY_STATUS`

`arrest_rule`:

- `ARREST_AUTHORITY_ONLY`
- `ARREST_AUTHORITY_AND_DEPUTIES`
- `ARREST_CITIZENS_MAY_ASSIST`
- `ARREST_OPEN_BOUNTY`

`duel_rule`:

- `DUEL_FORBIDDEN`
- `DUEL_ALLOWED_FORMAL`
- `DUEL_ALLOWED_IN_ARENAS`
- `DUEL_ALLOWED_BY_AUTHORITY`

`guard_force_rule`:

- `GUARD_FORCE_MINIMAL`
- `GUARD_FORCE_ESCALATING`
- `GUARD_FORCE_LETHAL_ON_RESIST`
- `GUARD_FORCE_WARTIME`

#### 5.5. Наследование закона

У закона может быть `parent_law_profile_id`.

Это нужно, чтобы:

- государство задавало общий закон по умолчанию;
- отдельные поселения переопределяли только часть норм.

Пример:

- государство запрещает убийство и кражу;
- портовый город наследует всё, но смягчает режим вторжения и контрабанды;
- крепость наследует всё, но делает жёстче силу стражи.

### 6. Как закон применяется

#### 6.1. Порядок обработки действия

При любом спорном действии система идёт так:

1. определяется поселение;
2. читается `LawProfile`;
3. проверяются исключения;
4. определяется, является ли действие преступлением;
5. только потом включаются свидетели, тревога и стража.

#### 6.2. Порядок проверки нормы

Сначала:

- есть ли иммунитет;
- есть ли статус власти;
- есть ли ордер;
- является ли цель вне закона;
- был ли формальный поединок;
- была ли самооборона.

Потом:

- читается режим нормы (`murder_rule`, `theft_rule` и т.д.).

Потом:

- учитываются местные условия:
  - запретная зона;
  - дворец;
  - рынок;
  - военное положение;
  - осада;
  - особый статус персонажа.

### 7. Гражданство

#### 7.1. Общий принцип

Гражданство не равно:

- фракции;
- владению;
- титулу;
- простому “друг/враг”.

Это отдельная связь персонажа или организации с государством или поселением.

#### 7.2. Статусы гражданства

Базовые статусы:

- `VISITOR`
- `RESIDENT`
- `CITIZEN`
- `BURGHER`
- `NOBLE`
- `OFFICIAL`
- `VASSAL`
- `OUTLAW`
- `EXILED`

#### 7.3. CitizenshipRecord

Поля:

- `citizenship_id`
- `holder_type`
- `holder_id`
- `realm_id`
- `settlement_id`
- `status`
- `granted_by_type`
- `granted_by_id`
- `granted_at`
- `revoked_at`
- `reason`
- `notes`

#### 7.4. Смысл гражданства

Гражданство определяет:

- право на свободный проход;
- право на собственность;
- налоговый режим;
- право на службу;
- право на ношение оружия;
- смягчение или ужесточение реакции стражи;
- набор доступных документов.

Пример:

- гражданин города может законно входить в ограничённые районы;
- изгнанник считается нарушителем уже при появлении в городской зоне;
- официальный представитель может иметь право ареста.

### 8. Титулы и полномочия

#### 8.1. Почему титул не равен гражданству

Можно:

- быть гражданином, но не иметь власти;
- быть наместником, но не быть уроженцем этой земли;
- быть правителем оккупированного города;
- быть капитаном стражи без права менять закон.

Поэтому нужен отдельный слой полномочий.

#### 8.2. AuthorityGrant

Поля:

- `authority_id`
- `holder_type`
- `holder_id`
- `scope_type`
- `scope_id`
- `authority_type`
- `granted_by_type`
- `granted_by_id`
- `granted_at`
- `revoked_at`
- `notes`

`authority_type`:

- `ARREST`
- `CHANGE_LAW`
- `COLLECT_TAX`
- `RAISE_GARRISON`
- `DECLARE_SIEGE`
- `CONFISCATE_PROPERTY`
- `ISSUE_DOCUMENTS`
- `PARDON`
- `APPOINT_OFFICIALS`

### 9. Документы

#### 9.1. Главный принцип

Документ — это не источник истины, а игровой носитель подтверждения.

Истина живёт в SQLite. Документ — это предмет, запись или регистрационный номер, который может подтверждать право.

Это важно, потому что предмет в игре можно:

- украсть;
- потерять;
- отобрать;
- уничтожить;
- подделать.

#### 9.2. DocumentRecord

Поля:

- `document_id`
- `type`
- `issuer_type`
- `issuer_id`
- `holder_type`
- `holder_id`
- `realm_id`
- `settlement_id`
- `status`
- `issued_at`
- `expires_at`
- `revoked_at`
- `payload_ref`
- `notes`

`type`:

- `CITIZENSHIP_CERT`
- `TITLE_PATENT`
- `LAND_CHARTER`
- `ARREST_WARRANT`
- `PARDON_ORDER`
- `TRADE_LICENSE`
- `MILITARY_COMMISSION`
- `TRAVEL_PASS`
- `PROPERTY_DEED`

#### 9.3. Как документ проверяется

Проверка документа идёт так:

1. NPC или система получает предмет/ссылку;
2. читает `document_id` / серийный номер;
3. запрашивает каноническую запись из БД;
4. проверяет:
   - действителен ли документ;
   - не отозван ли он;
   - соответствует ли он владельцу;
   - распространяется ли он на эту территорию;
   - не истёк ли срок.

### 10. Фракции NWN2

#### 10.1. Что они делают

Штатные фракции используются только как локальные группы поведения ИИ. Матрица отношений `0 / 50 / 100` подходит именно для этого.

#### 10.2. Правильные типы фракций

Фракциями должны быть:

- стража поселения;
- жители поселения;
- торговцы;
- гарнизон;
- бандиты региона;
- ополчение игрока;
- осадная армия;
- временные союзники.

#### 10.3. Чего в них быть не должно

Во фракциях не должны жить:

- владельцы городов;
- законы;
- гражданство;
- титулы;
- дипломатические договоры;
- наследование трона;
- налоговый режим;
- право на арест.

#### 10.4. Массовая настройка отношений

Для массовой логики используются фракционные отношения и `AdjustFactionReputation()`, которая меняет отношение всей одной фракции к другой.

### 11. Репутация

#### 11.1. Для чего нужна репутация

Репутация — это слой частных и локальных отношений:

- капитан стражи ненавидит игрока;
- торговец уважает игрока;
- один отряд считает игрока союзником;
- конкретный NPC не доверяет персонажу после старого преступления.

#### 11.2. Что репутация не заменяет

Репутация не должна заменять:

- закон;
- гражданство;
- право собственности;
- титул;
- владельца поселения.

### 12. Система преступлений

#### 12.1. Общий принцип

Преступление — это не просто “NPC рассердился”.

Преступление — это:

- действие;
- проверка закона;
- определение нарушения;
- определение свидетелей;
- изменение тревоги;
- реакция законной силы.

#### 12.2. Основные типы преступлений

- `MURDER`
- `ASSAULT`
- `THEFT`
- `TRESPASS`
- `ILLEGAL_ENTRY`
- `RESIST_ARREST`
- `FORGED_DOCUMENT`
- `CONTRABAND` (необязательно для первой версии)

#### 12.3. CrimeRecord

Поля:

- `crime_id`
- `crime_type`
- `offender_type`
- `offender_id`
- `target_type`
- `target_id`
- `settlement_id`
- `realm_id`
- `law_profile_id`
- `severity`
- `status`
- `created_at`
- `resolved_at`
- `notes`

`status`:

- `SUSPECTED`
- `WITNESSED`
- `CONFIRMED`
- `WANTED`
- `PARDONED`
- `RESOLVED`

### 13. Система свидетелей

#### 13.1. Общий принцип

Свидетели не строятся как “всевидящий искусственный интеллект”. Они строятся как комбинация:

- текущего восприятия;
- факта преступления;
- типа знания;
- последующей реакции.

#### 13.2. Слой восприятия

У важных NPC хранится минимальный runtime-кэш:

- видит ли нарушителя;
- слышит ли нарушителя;
- когда видел;
- где видел.

Источник — `OnPerception`, который сообщает именно о смене состояния восприятия.

#### 13.3. Источники преступления

Кража: источник — `OnDisturbed`. Это основной штатный канал для краж и вмешательства в контейнеры.

Нападение: источник — боевое событие проекта.

Убийство: источник — событие смерти и связанный боевой контекст.

Вторжение: источник — триггер зоны / собственность / пост.

#### 13.4. Типы свидетелей

- `DIRECT_WITNESS`
- `HEARING_WITNESS`
- `AFTERMATH_WITNESS`
- `THEFT_VICTIM`
- `SECONDARY_WITNESS`

#### 13.5. Память свидетеля

Свидетель хранит не “объективную истину”, а тип знания:

- видел лично;
- слышал;
- нашёл последствия;
- сам пострадал;
- услышал от другого.

### 14. Система тревоги

#### 14.1. Что даёт движок

Тревога должна опираться на штатные механизмы NWN2:

- `OnPerception`;
- `SetListening`;
- `SetListenPattern`;
- шаблоны в `OnConversation`;
- faction-реакцию и подхват союзников через `NW_FLAG_*`.

#### 14.2. Надстройка проекта

Поверх этого вводится уровень тревоги области:

- `0` — спокойно
- `1` — подозрение
- `2` — локальная тревога
- `3` — боевая тревога

Уровень тревоги влияет на:

- состав патрулей;
- жёсткость проверок;
- право на задержание;
- агрессивность реакции;
- число активных проверок документов;
- усиление стражи.

#### 14.3. Чего тревога не делает

Тревога не заменяет:

- закон;
- свидетелей;
- фракции.

Она только эскалирует обстановку после правовой оценки и подтверждения события.

### 15. Как всё связывается вместе

#### 15.1. Поток преступления

1. Игрок или NPC совершает действие.
2. Определяется поселение.
3. Читается `LawProfile`.
4. Проверяются исключения и полномочия.
5. Определяется, является ли действие преступлением.
6. Подтягиваются источники:
   - `OnDisturbed`,
   - боевой контекст,
   - триггеры зоны,
   - восприятие.
7. Формируются свидетели.
8. Поднимается уровень тревоги.
9. Реагирует законная стража.
10. Создаётся или обновляется `CrimeRecord`.

#### 15.2. Поток проверки документа

1. Игрок предъявляет документ.
2. NPC/система считывает серийный номер.
3. Идёт запрос к `DocumentRecord`.
4. Проверяется статус:
   - действителен;
   - не отозван;
   - не просрочен;
   - соответствует владельцу;
   - подходит для этой территории.
5. На основе результата меняется реакция NPC.

#### 15.3. Поток смены владельца поселения

1. В БД меняется `owner_type` / `owner_id`.
2. При следующей синхронизации области обновляется:
   - законная стража,
   - гарнизонный профиль,
   - доступность прав,
   - реакция служебных NPC.
3. Локальные faction-роли перестраиваются под нового владельца.

### 16. Что хранится в SQLite, а что нет

#### 16.1. В SQLite хранится

- государства;
- поселения;
- владельцы;
- законы;
- гражданство;
- полномочия;
- документы;
- глобальные преступления;
- правовой статус;
- дипломатия;
- титулы.

#### 16.2. В runtime хранится

- кто кого сейчас видит;
- кто уже крикнул;
- локальная паника;
- текущая цель патруля;
- текущая погоня;
- текущий уровень тревоги области;
- живой кэш свидетелей.

#### 16.3. Во фракциях хранится

Только локальное поведение ИИ:

- стража,
- жители,
- торговцы,
- бандиты,
- гарнизон,
- осадные силы.

### 17. Что запрещено этой архитектурой

Нельзя:

- моделировать государство через faction-матрицу;
- хранить закон как случайный набор локальных переменных;
- считать документ единственным источником истины;
- строить свидетелей только на `OnPerception`;
- использовать SQLite как один сетевой файл для одновременной прямой записи с нескольких машин.

### 18. Первая версия

Чтобы не утонуть, первая версия должна включать только это.

Поселение:

- владелец;
- закон;
- законная стража;
- базовый статус.

Закон:

- убийство;
- нападение;
- кража;
- вторжение;
- арест;
- дуэль;
- сила стражи.

Гражданство:

- посетитель;
- житель;
- гражданин;
- изгнанник.

Документы:

- свидетельство гражданства;
- грамота о владении;
- ордер на арест;
- помилование.

Полномочия:

- арест;
- смена закона;
- сбор налога;
- управление гарнизоном.

Тревога и свидетели:

- прямой свидетель;
- слуховой свидетель;
- жертва кражи;
- локальная тревога области.

### 19. Порядок внедрения

Этап 1:

- Поселения, владельцы, `LawProfile`.

Этап 2:

- Локальные faction-роли:
  - стража,
  - жители,
  - гарнизон,
  - бандиты.

Этап 3:

- Свидетели и тревога:
  - `OnPerception`,
  - `OnDisturbed`,
  - уровни тревоги.

Этап 4:

- Гражданство, полномочия, документы.

Этап 5:

- Смена владельцев, титулы, политическая эскалация.

### 20. Итоговое решение

Для проекта фиксируется следующее:

- Штатный NWN2 используется для немедленной реакции NPC: восприятие, кражи, слушание, faction-отношения.
- SQLite через NWNX4 `xp_sqlite` используется как каноническое хранилище мира.
- Фракции — только слой локального поведения ИИ, не политика мира.
- Закон определяет, является ли действие преступлением.
- Свидетели подтверждают событие.
- Тревога эскалирует район.
- Стража реагирует на основе закона, тревоги, faction-ролей и полномочий.
- Документы подтверждают права, но не являются источником истины.
- Игроковые государства и владение поселениями строятся поверх SQLite, а не через штатную смену фракций.

---
## 0) Для кого и зачем этот документ

Этот документ предназначен для агента/разработчика, который открывает репозиторий впервые и должен:
- быстро понять идею и границы системы;
- увидеть, какие механики уже реализованы, а какие планируются;
- понять архитектурные решения и причины этих решений;
- знать, где контент, где runtime, где эксплуатация и QA;
- уметь восстановить систему с нуля, даже без чтения остальных документов.

Идея этого файла: **одна точка входа, которая отвечает на «что / почему / как / где / что дальше»**.

---

## 1) Executive summary (за 2 минуты)

1. Ambient Life v2 — это area-centric + event-driven система симуляции жизни NPC в NWN2.
2. Вместо per-NPC heartbeat используется area tick + bounded dispatch.
3. Реализованы базовые контуры до Stage I.2: lifecycle, registry/dispatch, route/transition, sleep/activity, blocked/disturbed, local crime/alarm, population respawn.
4. Основной следующий этап — Stage I.3: reinforcement policy + legal pipeline (surrender/arrest/trial) + расширение последствий преступлений + отдельный QA smoke.
5. Главные принципы: bounded processing, отсутствие world-wide full scan, разделение контента и runtime, обязательная наблюдаемость через метрики.

---

## 2) Источники, которые были объединены

Этот master plan синтезирует и нормализует информацию из:
- `docs/01_PROJECT_OVERVIEW.md`
- `docs/02_MECHANICS.md`
- `docs/03_OPERATIONS.md`
- `docs/04_CONTENT_CONTRACTS.md`
- `docs/05_STATUS_AUDIT.md`
- `docs/06_SYSTEM_INVARIANTS.md`
- `docs/07_SCENARIOS_AND_ALGORITHMS.md`
- `docs/08_STAGE_I3_TRACKER.md`
- `docs/10_NPC_RESPAWN_MECHANICS.md`
- `docs/11_GENERAL_DESIGN_DOCUMENT.md`

Примечание: в ряде исходных документов есть устаревшие ссылки/несинхронизированные места; здесь они сведены в согласованную картину.

---

## 3) Продуктовая идея и замысел автора

### 3.1 Что симулируется
Система симулирует «фоновую жизнь» NPC:
- суточные рутины;
- перемещение по маршрутам;
- переходы между area;
- сон и активность;
- реакции на помехи/инциденты;
- реакцию города на преступность;
- восстановление безымянного населения.

### 3.2 Почему архитектура именно такая
Ключевая проблема: per-NPC heartbeat плохо масштабируется и тяжело контролируется при росте числа NPC.

Выбранный ответ:
- area-centric orchestration (управление сверху, а не «каждый NPC сам по себе»);
- event-driven переходы между шагами поведения;
- bounded budgets/caps для всех «дорогих» операций;
- explicit diagnostics, чтобы поведение наблюдалось, а не угадывалось.

### 3.3 Что считается успехом
- живой, но предсказуемый мир;
- отсутствие бесконечных эскалаций;
- управляемая производительность;
- прозрачная эволюция механик по стадиям roadmap.

---

## 4) Архитектура системы (карта подсистем)

## 4.1 Слои
1. **Core lifecycle слой** — area tick, tiers, жизненный цикл.
2. **Registry/dispatch слой** — регистрация NPC, очередь событий, маршрутизация runtime-сигналов.
3. **Route/sleep/activity слой** — повседневное поведение NPC.
4. **Reactive/city слой** — disturbed/blocked, crime/alarm FSM, role assignments.
5. **Population слой** — восстановление unnamed-дефицита (respawn policy).

## 4.2 Файловая карта runtime
### Core + area lifecycle
- `scripts/ambient_life/al_core_inc.nss`
- `scripts/ambient_life/al_area_inc.nss`
- `scripts/ambient_life/al_area_tick.nss`
- `scripts/ambient_life/al_area_onenter.nss`
- `scripts/ambient_life/al_area_onexit.nss`
- `scripts/ambient_life/al_mod_onleave.nss`

### Registry + dispatch + cache
- `scripts/ambient_life/al_registry_inc.nss`
- `scripts/ambient_life/al_lookup_cache_inc.nss`
- `scripts/ambient_life/al_dispatch_inc.nss`
- `scripts/ambient_life/al_events_inc.nss`

### Route + transition + sleep + activity + schedule
- `scripts/ambient_life/al_route_inc.nss`
- `scripts/ambient_life/al_route_cache_inc.nss`
- `scripts/ambient_life/al_route_runtime_api_inc.nss`
- `scripts/ambient_life/al_transition_inc.nss`
- `scripts/ambient_life/al_transition_post_area.nss`
- `scripts/ambient_life/al_sleep_inc.nss`
- `scripts/ambient_life/al_activity_inc.nss`
- `scripts/ambient_life/al_acts_inc.nss`
- `scripts/ambient_life/al_schedule_inc.nss`

### Reactive + city
- `scripts/ambient_life/al_blocked_inc.nss`
- `scripts/ambient_life/al_react_inc.nss`
- `scripts/ambient_life/al_react_apply_step.nss`
- `scripts/ambient_life/al_react_resume_reset.nss`
- `scripts/ambient_life/al_city_registry_inc.nss`
- `scripts/ambient_life/al_city_crime_inc.nss`
- `scripts/ambient_life/al_city_alarm_inc.nss`
- `scripts/ambient_life/al_city_population_inc.nss`
- `scripts/ambient_life/al_health_inc.nss`

### Wrapper/actions + NPC hooks
- `scripts/ambient_life/al_action_signal_ud.nss`
- `scripts/ambient_life/al_action_set_mode.nss`
- `scripts/ambient_life/al_npc_onspawn.nss`
- `scripts/ambient_life/al_npc_onud.nss`
- `scripts/ambient_life/al_npc_onblocked.nss`
- `scripts/ambient_life/al_npc_ondisturbed.nss`
- `scripts/ambient_life/al_npc_ondamaged.nss`
- `scripts/ambient_life/al_npc_onphysicalattacked.nss`
- `scripts/ambient_life/al_npc_onspellcastat.nss`
- `scripts/ambient_life/al_npc_ondeath.nss`

### Diagnostic/support
- `scripts/ambient_life/al_debug_inc.nss` — debug/logging вспомогательный слой для анализа поведения в рантайме.


## 4.3 Поток управления (упрощённо)
1. Area tick инициирует обработку.
2. Dispatch доставляет события в bounded режиме.
3. NPC проходят route/sleep/activity шаги.
4. Внешние инциденты через hooks запускают reactive/city контуры.
5. City FSM регулирует эскалацию и деэскалацию.
6. Population layer закрывает дефицит населения в рамках policy.

---

## 5) Ответственности и границы (очень важно)

## 5.1 Контент отвечает за
- маршрутные теги и слоты (`alwp0..alwp5`);
- связность area (`al_link_count`, `al_link_*`);
- sleep markup (`al_bed_id`, sleep пары waypoint);
- city принадлежность (`al_city_id`, district type, city точки);
- respawn nodes и конфиг area-level.

## 5.2 Runtime отвечает за
- очереди, курсоры, индексы;
- state flags и состояние FSM;
- служебные счётчики/диагностику/health;
- bounded бюджеты и cooldown-логики.

## 5.3 Жёсткий запрет
Runtime locals нельзя редактировать вручную как способ «починки» сценариев. Исправление должно быть через код/контент/контракты.

---

## 6) Канонические инварианты системы

## 6.1 Архитектура
1. Нет per-NPC heartbeat как базового механизма.
2. Нет world-wide full-scan как базовой стратегии.
3. Любая тяжёлая логика обязана быть bounded.
4. Любой новый механизм обязан иметь наблюдаемое состояние и критерии завершения.

## 6.2 Lifecycle / registry / dispatch
- NPC регистрируется и удаляется только в валидных lifecycle-точках.
- Tier модель (`FREEZE/WARM/HOT`) влияет на интенсивность обработки.
- Dispatch обрабатывается пакетно с backpressure и overflow-контролем.

## 6.3 Route / transition / sleep
- Route исполняется bounded шагами.
- Transition всегда валидирует endpoint и destination area.
- Sleep — отдельная ветка исполнения, с возвратом в routine pipeline.

## 6.4 Reactive / city
- Blocked/disturbed — локальные реакции, не ломающие route/schedule канон.
- Alarm — FSM, а не «мгновенная агрессия всего мира».
- Обязателен путь деэскалации (`active -> recovery -> normal`).

## 6.5 Контент
- `al_link_count` == фактическое число `al_link_*`.
- Индексация route-шагов без пропусков.
- `al_bed_id` допустим только при корректной sleep-разметке area.

---

## 7) Контракты данных и событий

## 7.1 NPC locals
### Обязательные
- `alwp0..alwp5`
- `al_default_activity`

### Опциональные / fallback / role hints
- `AL_WP_S0..AL_WP_S5`
- `al_npc_role` (`0` civilian, `1` militia, `2` guard/enforcer)
- `al_safe_wp_tag`

## 7.2 Area locals
- `al_link_count`, `al_link_0..N`
- `al_city_id`, `al_city_district_type`
- city tags: `al_city_bell_tag`, `al_city_arsenal_tag`, `al_city_shelter_tag`, `al_city_war_post_tag_<idx>`

## 7.3 Sleep/route
- `al_step`
- `al_bed_id`
- `al_dur_sec` (опционально)

## 7.4 Population/respawn
### Area конфиг
- `al_city_respawn_tag` ИЛИ `al_city_respawn_tag_<idx>` + `al_city_respawn_node_count`
- `al_city_respawn_resref` (опционально)
- `al_city_respawn_cooldown_ticks` (опционально)
- `al_city_respawn_budget_regen_ticks` (опционально)
- `al_city_respawn_safe_dist` (опционально)

### Module/city runtime keys
- `population_target_named`, `population_target_unnamed`
- `population_alive_named`, `population_alive_unnamed`
- `population_deficit_unnamed`
- `population_respawn_budget`, `population_respawn_budget_max`, `population_respawn_budget_initialized`
- `population_last_respawn_tick`, `population_budget_last_regen_tick`
- `population_respawn_resref`

## 7.5 Внутренние события (bus)
- `AL_EVENT_SLOT_0..AL_EVENT_SLOT_5`
- `AL_EVENT_RESYNC`
- `AL_EVENT_ROUTE_REPEAT`
- `AL_EVENT_BLOCKED_RESUME`
- city assignment events:
  - `AL_EVENT_CITY_ASSIGN_GO_SHELTER`
  - `AL_EVENT_CITY_ASSIGN_GO_ARSENAL`
  - `AL_EVENT_CITY_ASSIGN_HOLD_WAR_POST`
  - `AL_EVENT_CITY_ASSIGN_ALARM_RECOVERY`

---

## 8) Сценарии выполнения (операционная картина)

## 8.1 Базовый lifecycle
- `OnSpawn` -> регистрация -> участие в tick/dispatched логике.
- `OnExit/OnDeath` -> очистка runtime-состояний.

## 8.2 Суточный цикл
- slot event выбирает route.
- route исполняется по шагам в bounded режиме.
- fallback/resync не ломает общий бюджет area.

## 8.3 Переходы между area
- transition-step -> валидация endpoint.
- переход -> post-area transfer/sync registry.

## 8.4 Sleep lifecycle
- шаг с `al_bed_id` переключает в sleep pipeline.
- wake-up возвращает в routine.

## 8.5 Blocked/disturbed
- `OnBlocked` -> door-first + bounded resume.
- `OnDisturbed`/producer hooks -> реакция + city/crime pipeline.

## 8.6 Crime/alarm
- инциденты типизируются.
- desired/live alarm state разделены.
- role assignments управляются через события.
- есть controlled recovery.

## 8.7 Population respawn
- `OnSpawn/OnDeath` поддерживают alive/target/deficit.
- при выполнении pre-checks запускается create-path.
- только unnamed дефицит закрывается респауном.

---

## 9) Deep dive: Population Respawn (важная часть)

## 9.1 Цель
Поддерживать демографическую устойчивость города без:
- респауна named NPC,
- burst-спавнов,
- смешения с materialization.

## 9.2 Термины
- **Respawn**: создание нового NPC через `CreateObject`.
- **Materialization**: возврат уже существующего логического NPC.

## 9.3 Hooks
- `AL_OnNpcSpawn -> AL_CityPopulationOnNpcSpawn`
- `AL_OnNpcDeath -> AL_CityPopulationOnNpcDeath`
- `AL_AreaTick -> AL_CityPopulationTryRespawnTick`

## 9.4 Алгоритм OnSpawn
1. validate + no-double-register;
2. определить city;
3. классифицировать named/unnamed;
4. обновить alive counters;
5. поднять target при необходимости;
6. для unnamed уменьшить deficit (если > 0);
7. ensure/normalize budget.

## 9.5 Алгоритм OnDeath
- named: `alive_named--`;
- unnamed: `alive_unnamed--`, `deficit_unnamed++`;
- все операции с clamping.

## 9.6 RespawnTick pre-checks
1. area HOT;
2. alarm desired/live == peace;
3. `deficit_unnamed > 0`;
4. cooldown OK;
5. budget > 0;
6. regen budget при необходимости;
7. валидный respawn node;
8. безопасная node (нет врагов, игрок не слишком близко);
9. валидный resref (area/local fallback на city).

## 9.7 Create-path
На успешном создании:
- budget--;
- deficit--;
- last_respawn_tick обновляется;
- новый NPC маркируется unnamed;
- дальше стандартный `OnSpawn` lifecycle.

## 9.8 Что запрещено
- респаун named NPC;
- решение о респауне в heartbeat конкретного NPC;
- спавн перед игроком;
- отключение cooldown/budget/safety;
- объединение materialization и respawn в один «серый» контур.

---

## 10) Operations / perf / QA

## 10.1 Perf-gate
Для изменений в `scripts/ambient_life/al_*` обязательно:
- S80
- S100
- S120

Режим:
- warm-up: 2 area tick
- measurement: 20 tick
- baseline и after в одинаковых условиях

## 10.2 Обязательные метрики
- `al_dispatch_q_len`, `al_dispatch_q_overflow`
- `al_reg_overflow_count`, `al_route_overflow_count`
- `route_cache_hits`, `route_cache_rebuilds`, `route_cache_invalidations`
- `al_h_recent_resync`
- `al_h_reg_index_miss_delta`, `al_h_reg_index_miss_window_delta`
- `al_reg_lookup_window_total`, `al_reg_lookup_window_miss`, `al_reg_reverse_hit`
- `al_dispatch_ticks_to_drain`, `al_dispatch_budget_current`
- `al_dispatch_processed_tick`, `al_dispatch_backlog_before`, `al_dispatch_backlog_after`

## 10.3 Operator checklist
Перед PR:
1. baseline-vs-after по обязательным метрикам;
2. operator-readable + machine-readable отчёт;
3. perf-проверка не пропущена для core-файлов;
4. обновление baseline имеет обоснование;
5. preflight summary приложен.

## 10.4 Preflight для контента
Проверять до релиза:
- linked graph (`al_link_*`);
- route/step/sleep markup;
- отсутствие битых тегов/дубликатов/невалидных ссылок.

---

## 11) Статус проекта и roadmap

## 11.1 Реализовано (подтверждённый baseline)
- Stage A–H;
- Stage I.0–I.2;
- зрелый базовый контур: lifecycle + routine + city crime/alarm + population recovery.

## 11.2 Planned (Stage I.3)
1. Reinforcement / guard spawn policy.
2. Surrender -> arrest -> trial pipeline.
3. Consequences expansion for crime incidents.
4. Специализированный smoke-runbook и QA критерии для legal/reinforcement.

## 11.3 Definition of Done для Stage I.3
- реализована bounded policy подкреплений;
- legal pipeline проходит end-to-end;
- smoke сценарии воспроизводимы;
- docs синхронно обновлены (`02`, `03`, `04`, `05`, `08`, master-plan).

---

## 12) План восстановления системы с нуля (практический)

## 12.1 Порядок реализации
1. Area tick + event bus + bounded dispatch.
2. Registry + lookup/cache + diagnostics.
3. Slot routines + route runtime.
4. Transition subsystem + post-transfer sync.
5. Sleep pipeline.
6. Activity pipeline.
7. Blocked/disturbed.
8. City registry + crime + alarm FSM.
9. Population layer + respawn policy.
10. Perf + operations gates.
11. Только после этого Stage I.3 legal/reinforcement.

## 12.2 Критерии приёмки каждого шага
Шаг не считается завершённым без:
- явных инвариантов;
- наблюдаемого runtime-состояния;
- smoke-сценариев;
- bounded гарантии (нет бесконечных контуров);
- базового perf контроля.

---

## 13) Анти-паттерны (чего делать нельзя)

1. World-wide scan как «универсальное решение».
2. Бесконечные циклы без budget/cap.
3. Смешение city FSM и per-NPC routine FSM в неявную общую машину.
4. Ручное правление runtime locals вместо исправления первопричины.
5. «Магические» спавны/эскалации без диагностируемых причин.
6. Смешение respawn и materialization.

---

## 14) Диагностика и отладка: где смотреть в первую очередь

Если «NPC не живут нормальной жизнью»:
1. Проверить route tags (`alwp*`) и existence waypoint.
2. Проверить registry overflow/lookup miss метрики.
3. Проверить dispatch backlog/overflow.
4. Проверить linked graph (`al_link_count`, `al_link_*`).

Если «не работают переходы между area»:
1. Проверить endpoint tags и target area.
2. Проверить post-transition transfer hooks.
3. Проверить дубли/битые links в контенте.

Если «город не реагирует/не успокаивается»:
1. Проверить producer hooks (damage/attack/spell/death/disturbed).
2. Проверить desired/live alarm state.
3. Проверить assignment event flow.
4. Проверить, что recovery-path выполняется.

Если «не работает respawn населения»:
1. Проверить `deficit_unnamed` > 0.
2. Проверить cooldown/budget.
3. Проверить peace-state города.
4. Проверить respawn node и safe distance.
5. Проверить resref (area/local или city fallback).

---

## 15) FAQ — ответы на типовые вопросы нового агента

### Q1. Почему нет heartbeat на каждого NPC?
Потому что это ухудшает масштабируемость и контроль. Здесь orchestration area-centric и bounded.

### Q2. Где «истина»: в контенте или runtime?
Intent в контенте, динамика и служебное состояние в runtime. Нельзя подменять одно другим.

### Q3. Что самое критичное в стабильности?
Dispatch/registry bounded-инварианты + валидный контент route/links + корректная деэскалация city FSM.

### Q4. Что уже готово и что нет?
Готова база до Stage I.2. Основной незакрытый пакет — Stage I.3 (legal/reinforcement).

### Q5. Можно ли быстро «подкрутить локал» в рантайме и закрыть баг?
Нет. Это нарушает воспроизводимость и скрывает причину.

### Q6. Какая минимальная проверка перед слиянием?
Perf S80/S100/S120 + обязательные метрики + smoke/контент preflight.

### Q7. Как понять, что система не ушла в unbounded-поведение?
Смотреть queue/backlog/overflow, ticks-to-drain, cache rebuild/invalidations, и подтверждать bounded сценариями.

---

## 16) Глоссарий

- **Area-centric execution** — управление симуляцией на уровне area tick.
- **Event-driven orchestration** — переходы между состояниями через события.
- **Bounded processing** — ограниченные бюджеты/ёмкости/время выполнения.
- **Routine pipeline** — повседневный цикл маршрутов/активностей NPC.
- **City FSM** — state-машина тревоги и реакции города.
- **Respawn** — создание нового NPC для закрытия дефицита.
- **Materialization** — возврат уже существующего NPC в активную зону.
- **Preflight** — предварительная валидация контента и связей до релиза.

---

## 17) Документационные долги и план поддержания master-документа

1. В репозитории встречаются ссылки на документы, которых может не быть в текущем tree (например некоторые `docs/09_*`).
2. Документ `docs/10_NPC_RESPAWN_MECHANICS.md` содержит следы несинхрона/merge-остатков и требует отдельной очистки.
3. При изменениях в архитектуре сначала обновлять этот master-plan, затем профильные документы.

Рекомендуемый процесс поддержки:
- изменили механику -> обновили профильный doc -> обновили этот master-plan (разделы 8/10/11/15).
- закрыли этап -> обновили status/roadmap/FAQ.

---

## 18) Короткая памятка «что делать прямо сейчас новому агенту»

1. Прочитать разделы 1, 4, 6, 8, 10, 11, 12, 15.
2. Зафиксировать: система уже зрелая до I.2; I.3 — главный фронт.
3. Любое изменение проектировать через bounded и observability.
4. Не ломать границу content/runtime.
5. Перед PR пройти perf-gate и smoke-валидацию.

Если ты понимаешь этот документ — ты понимаешь архитектурный замысел проекта и можешь продолжать разработку осмысленно.



---


## 19) Формальная проверка полноты покрытия («описывает всё»)

Этот раздел нужен, чтобы проверить, что мастер-план действительно покрывает все основные элементы системы, а не только «ядро по памяти».

### 19.1 Покрытие документации
Покрыты и нормализованы материалы:
- `01_PROJECT_OVERVIEW` (назначение/архитектура/roadmap);
- `02_MECHANICS` (канон механик);
- `03_OPERATIONS` (perf-регламент и метрики);
- `04_CONTENT_CONTRACTS` (контент и runtime ключи);
- `05_STATUS_AUDIT` (сделано/планируется);
- `06_SYSTEM_INVARIANTS` (инварианты);
- `07_SCENARIOS_AND_ALGORITHMS` (сценарии и алгоритмы);
- `08_STAGE_I3_TRACKER` (planned Stage I.3);
- `10_NPC_RESPAWN_MECHANICS` (детализация respawn, с учётом несинхронов исходника);
- `11_GENERAL_DESIGN_DOCUMENT` (общая проектная рамка).

### 19.2 Покрытие runtime-файлов (`scripts/ambient_life/*.nss`)
В master-плане отражены все файлы текущей директории `scripts/ambient_life`:
- Core/lifecycle: `al_core_inc`, `al_area_inc`, `al_area_tick`, `al_area_onenter`, `al_area_onexit`, `al_mod_onleave`;
- Registry/dispatch/cache: `al_registry_inc`, `al_lookup_cache_inc`, `al_dispatch_inc`, `al_events_inc`;
- Route/transition/schedule/sleep/activity: `al_route_inc`, `al_route_cache_inc`, `al_route_runtime_api_inc`, `al_transition_inc`, `al_transition_post_area`, `al_schedule_inc`, `al_sleep_inc`, `al_activity_inc`, `al_acts_inc`;
- Reactive/city/health/population: `al_blocked_inc`, `al_react_inc`, `al_react_apply_step`, `al_react_resume_reset`, `al_city_registry_inc`, `al_city_crime_inc`, `al_city_alarm_inc`, `al_city_population_inc`, `al_health_inc`;
- Hooks/actions: `al_action_signal_ud`, `al_action_set_mode`, `al_npc_onspawn`, `al_npc_onud`, `al_npc_onblocked`, `al_npc_ondisturbed`, `al_npc_ondamaged`, `al_npc_onphysicalattacked`, `al_npc_onspellcastat`, `al_npc_ondeath`;
- Диагностика: `al_debug_inc`.

### 19.3 Покрытие сущностей и контрактов
Покрыты:
- NPC locals (route/activity/role/safe wp);
- Area locals (links/city metadata/city points);
- Sleep markup и route-step правила;
- Population/respawn area + module/city ключи;
- Runtime-only locals и запрет ручного редактирования.

### 19.4 Покрытие сценариев
Покрыты end-to-end сценарии:
- lifecycle spawn/exit/death;
- routine slot execution;
- transition между area;
- sleep/wakeup;
- blocked recovery;
- disturbed/crime escalation;
- alarm recovery;
- population respawn.

### 19.5 Покрытие «планируемого»
Покрыт весь запланированный блок Stage I.3:
- reinforcement policy;
- surrender/arrest/trial pipeline;
- consequences expansion;
- dedicated legal/reinforcement QA smoke.

### 19.6 Что сознательно не включено в область
- `third party/*` и компилятор внутри неё (по правилам проекта не анализируются и не изменяются).

Итог проверки полноты: master-план описывает текущую систему целиком (архитектура, контракты, сценарии, операционный контур, roadmap) и отдельно маркирует зоны документального долга.
