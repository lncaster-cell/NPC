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

#### 6.3. Финальный упрощённый legal-блок для мастер-плана (скорость > гибкость)

Этот блок фиксирует сознательное упрощение: только событийная логика, только заранее подготовленные таблицы, только ключевые роли и контроллеры.

##### 6.3.1. Закон о публичном ношении оружия — `LAW_PUBLIC_ARMS`

Назначение:

- в публичной городской юрисдикции игроку запрещено держать оружие в руках;
- закон не действует вне города, в лагере, в собственности игрока и при правовом иммунитете.

Каноническая архитектура:

- `OnPlayerEquipItem` и `OnPlayerUnequipItem` ничего не наказывают напрямую;
- их задача — обновлять кэш игрока: `arms_drawn`, `arms_right_hand`, `arms_left_hand`, `current_jurisdiction`, `legal_immunity_flags`;
- для владельца предмета в `OnPlayerEquipItem` использовать `GetItemPossessor()` от предмета (а не полагаться на `GetPCItemLastEquippedBy()` на повторных логинах).

Юрисдикция задаётся отдельным кэшем/контроллерами зоны:

- `CITY_PUBLIC`
- `CITY_RESTRICTED`
- `PRIVATE_PROPERTY`
- `CAMP`
- `WILDERNESS`
- `SPECIAL_EXEMPT`

Кто реагирует на закон:

- стражники;
- торговцы;
- ключевые городские NPC;
- охранные контроллеры/посты;
- специальные входные триггеры.

Массовка не получает полноценную тяжёлую логику `OnPerception`.

Свидетель подтверждает нарушение только визуально:

- `OnPerception` + `GetLastPerceptionSeen()`;
- при необходимости `GetObjectSeen(oPC, oGuard)`.

Правовая логика:

- если `arms_drawn = TRUE` в `CITY_PUBLIC`, мирные жители отказываются от общения;
- торговцы блокируют торговлю;
- стража при визуальном подтверждении требует убрать оружие;
- преступление возникает при неподчинении законному требованию или повторном нарушении после предупреждения, а не в сам момент экипировки.

Жёсткие упрощения по производительности:

- не делать глобальный обход NPC при каждой экипировке;
- не делать polling-проверку рук игрока;
- не раздавать сложную weapon-логику каждому жителю;
- делать один кэш вооружённости и один кэш юрисдикции на игроке;
- проверки запускать только по событиям: экипировка, вход в юрисдикцию, старт диалога/торговли, `OnPerception` у ограниченного круга свидетелей.

##### 6.3.2. Законы о запрещённой магии — `LAW_PUBLIC_MAGIC` и `LAW_RESTRICTED_MAGIC`

Назначение:

- в `CITY_PUBLIC` запрещены боевые и общественно опасные спеллы;
- в `CITY_RESTRICTED` действует более жёсткий режим;
- вне города/в лагере/в собственности игрока закон не действует, если модуль не задаёт исключение.

Каноническая техническая опора:

- не анализировать описание спелла «на лету»;
- использовать заранее подготовленный реестр `spell_id -> legal_class`;
- `GetLastSpellHarmful()` не использовать как единственный юридический критерий.

Минимальная правовая классификация:

- `MAG_ALLOWED`
- `MAG_FORBIDDEN`
- `MAG_RESTRICTED`
- `MAG_GRAVE`

Правовая логика:

- `MAG_ALLOWED` в городе не наказывается;
- `MAG_FORBIDDEN` в `CITY_PUBLIC` сразу даёт нарушение;
- `MAG_RESTRICTED` нарушает закон только в `CITY_RESTRICTED`;
- `MAG_GRAVE` сразу уходит в тяжкое преступление (без стадии предупреждения).

Детекция нарушения:

- направленный каст по существу/двери/placeable — через `OnSpellCastAt`;
- подтверждение фактического вреда и спорных случаев — через `OnDamaged`;
- охраняемые объекты и чувствительные зоны закрываются отдельными контроллерами/скриптами.

Производительный контур «охраняемых объектов»:

- не строить глобальную «магическую полицию» на всех NPC;
- вешать `OnSpellCastAt` на защищённые двери, архивы, витрины, казну, алтари, контейнеры, посты охраны;
- реакцию стражи оставлять только для ключевых свидетелей;
- проверку делать одним lookup в предвычисленной таблице.

##### 6.3.3. Окончательные архитектурные ограничения

Запрещено:

- массовый heartbeat/polling для контроля оружия и магии;
- глобальный обход всех NPC/объектов area при каждом касте или экипировке;
- трактовать `GetLastSpellHarmful()` как окончательный юридический ответ;
- запускать правоохранительную реакцию прямо из `OnPlayerEquipItem`;
- раздавать полноценный `OnPerception` всей городской массовке.

Разрешено и рекомендовано:

- один кэш вооружённости на игроке;
- один кэш юрисдикции на игроке;
- одна предвычисленная таблица `spell_id -> legal_class`;
- проверки только по событиям: экипировка, вход в юрисдикцию, старт диалога/торговли, `OnPerception` у ключевых свидетелей, `OnSpellCastAt`, `OnDamaged`;
- охраняемые объекты и зональные контроллеры как базовый контур для магии и особых зон.

##### 6.3.4. Короткая формулировка для вставок в связанные документы

Запрет оружия: `LAW_PUBLIC_ARMS` реализуется как дешёвый закон уровня юрисдикции. Состояние «оружие в руках» кэшируется на игроке через `OnPlayerEquipItem`/`OnPlayerUnequipItem`; экипировка сама по себе не преступление. Подтверждение нарушения дают только ключевые свидетели через `OnPerception`/`GetLastPerceptionSeen`/`GetObjectSeen`. Мирные жители и торговцы проверяют закон только в момент взаимодействия. Полноценное преступление — неподчинение требованию стражи или повтор после предупреждения.

Запрет магии: `LAW_PUBLIC_MAGIC` и `LAW_RESTRICTED_MAGIC` реализуются через предвычисленную таблицу `spell_id -> legal_class` на базе `spells.2da` и ручного override-слоя. Фиксация направленного воздействия — через `OnSpellCastAt`, подтверждение вреда и спорных случаев — через `OnDamaged`. Система не опирается только на `GetLastSpellHarmful()`.

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

## 20) Дизайн-блок: система имущества игрока

### 20.1 Назначение системы

Система имущества игрока — единая подсистема собственности, описывающая все долговременные владения персонажа и задающая общие правила: право владения, лимиты, доступ, хранение состояния, переходы, сервисы и интеграцию с другими системами.

Имущество должно существовать как единая архитектурная категория, внутри которой лагерь, дом, город и судно являются разными классами собственности с разными ролями.

### 20.2 Канонические классы и лимиты

На одного игрока допускается не более:

- одного лагеря;
- одного дома;
- одного города;
- одного судна.

Лимиты являются жёсткими и системными. Имущество должно оставаться редким, значимым и управляемым: это упрощает права доступа, хранение состояния, масштабирование мира и контроль нагрузки.

### 20.3 Роли классов имущества

- **Лагерь** — мобильная база игрока: отдых, комплектование активной группы, резерв спутников и бойцов, личный склад, товарный склад, подготовка перемещений.
- **Дом** — постоянное городское жильё: статус, безопасное хранение, социальные и бытовые функции, точка городского присутствия.
- **Город** — высокоуровневое владение: управление гарнизоном, доходами, политико-экономическими функциями и системами влияния.
- **Судно** — специализированное транспортное имущество: морские переходы, морская логистика, маршруты, грузы и связанные сервисы.

Классы не должны полностью подменять друг друга: лагерь не должен превращаться в дом, дом — в город, а судно — в универсальную сухопутную базу.

### 20.4 Общая архитектурная модель

Каждый объект имущества существует в двух слоях.

1. **Слой данных** — каноническая запись в реестре имущества:
   - идентификатор владельца;
   - тип имущества;
   - статус владения;
   - уровень;
   - специализация;
   - текущее размещение;
   - права доступа;
   - лимиты хранения;
   - открытые сервисы;
   - улучшения;
   - внутреннее состояние.

2. **Слой физического представления** — area, участок, интерьер, входной триггер, сервисный объект или иной пространственный носитель.

Канонический принцип: состояние имущества хранится прежде всего в системных реестрах, а физическая area выступает визуальным и интерактивным интерфейсом к данным.

### 20.5 Пространственная модель и масштабирование

Имущество не должно требовать уникальной крупной area на каждого игрока. Базовая модель — система повторяемых районов и участков:

- для каждого класса имущества есть шаблонные районы или наборы зон;
- игроку назначается конкретный участок/слот/запись размещения;
- при заполнении района создаётся следующая копия шаблона.

Это означает масштабирование через повторяемые районы, а не через бесконечное разрастание одной области и не через уникальную тяжёлую area на каждый объект.

Как внешний ориентир масштабирования: в публичном описании housing-системы WoW используется модель public neighborhoods, которые создаются по мере заполнения, при этом один neighborhood содержит примерно 50 plots. Для проекта это не прямой шаблон реализации, а практический референс по подходу «районы + ограниченное число участков + тиражирование по заполнению».

Для серверного worst-case (до 32 игроков с полным набором имущества) масштабирование должно опираться на:

- шаблонные районы;
- ограниченное число участков на район;
- реестр размещения;
- создание новых районов по мере заполнения;
- хранение большей части состояния вне runtime-симуляции.

### 20.6 Общие правила доступа

Каждый объект имущества поддерживает общую систему ролей:

- владелец;
- член группы;
- союзник;
- гость;
- служебный NPC;
- запрещённый доступ.

Права задаются отдельно для:

- входа;
- отдыха;
- личного хранилища;
- товарного хранилища;
- резерва спутников;
- управления сервисами;
- вызова поддержки;
- изменения настроек и улучшений.

### 20.7 Общие правила хранения

Система различает минимум три уровня хранения:

- личное имущество;
- служебное/отрядное имущество;
- экономическое имущество.

Практическая модель:

- личные вещи допустимо хранить через persistent-контейнеры;
- отрядное снаряжение лучше хранить как реестр комплектов/снабжения;
- крупные торговые партии хранить как абстрактные записи, а не как физическую массу предметов в мире.

Для контейнерной логики использовать штатную событийную модель disturbances (`OnDisturbed`, `GetLastDisturbed`, `GetInventoryDisturbType`, `GetInventoryDisturbItem`) вместо тяжёлого постоянного опроса инвентарей.

### 20.8 Общие правила переходов и перемещений

Имущество должно встраиваться в существующую систему переходов:

- обычные переходы — через стандартные area transition и партийный переход;
- глобальные маршруты — через world map-подход.

Это особенно критично для лагеря и судна как мобильных узлов перемещения.

### 20.9 Требования к производительности

Система имущества проектируется с приоритетом производительности:

- физические зоны компактные и контролируемые по плотности объектов;
- неинтерактивные объекты по возможности упрощаются;
- количество активных NPC держится низким;
- сложность walkmesh ограничивается.

### 20.10 Каноническое решение (кратко)

Система имущества игрока — единая подсистема с четырьмя классами (лагерь, дом, город, судно) и лимитом «не более одного экземпляра каждого класса на игрока».

Основное состояние имущества хранится в реестрах и сервисных структурах данных, а физическое представление реализуется через районы, участки, интерьеры и входные точки. Масштабирование выполняется через копии шаблонных районов по мере заполнения. Лагерь занимает роль мобильной базы и не размывает границы между классами собственности.



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

---

## КАНОН НА 2026-03-14: Дизайн-блок — система перемещений по миру

**Статус:** Принято как каноническая архитектура travel-layer для модуля.  
**Фиксация канона:** на текущую дату (2026-03-14) данный блок считается каноном и имеет приоритет над более ранними решениями по перемещениям.

### 1. Базовый принцип

Каноническая модель для модуля — узловые перемещения через world map, а не свободная overland-симуляция.
В штатной NWN2 world map игрок выбирает известные точки, после чего движок переводит партию к выбранной локации, а по пути могут происходить встречи. Полноценная 3D overland-система уровня Storm of Zehir существует, но это уже отдельная тяжёлая подсистема; наличие на Vault отдельного demo-модуля и документации по ней показывает, что её разумно считать самостоятельным пластом разработки, а не «простым режимом карты».

Следствие: ядро проекта должно быть таким:  
**узел отправления → выбор доступного соседнего узла → переходный слой (катсцена/видео/затемнение) → прибытие или событие по пути.**

Это даёт атмосферу и масштаб, но не требует строить открытый мир между всеми городами. Под саму world map в NWN2 уже есть штатный вызов `ShowWorldMap(string sWorldMap, object oPlayer, string sTag)`, а в World Map Editor hotspot’ы работают через `ActionScript` и `ConditionalScript`.

### 2. Цели системы

Система перемещений должна решать 5 задач:

1. Давать игроку понятный выбор направления.
2. Визуально показывать, что герой в пути, а не просто ждёт в пустоте.
3. Поддерживать встречи, задержки, риск и сюжетные события.
4. Одинаково обслуживать сухопутные и морские переходы.
5. Не опираться на шаткие или недокументированные механики движка.

### 3. Каноническая архитектура

#### 3.1. Разделение на слои

Система должна быть разделена на 4 слоя:

1. **Слой карты мира**  
   Только UI выбора направления. Карта не хранит логику мира, она только показывает доступные точки и принимает выбор игрока. В NWN2 сама карта задаётся как `.wmp`, а в типовом гайде под неё используется изображение `647x647 .tga` и hotspot-иконки `32x32 .tga`.

2. **Слой графа маршрутов**  
   Хранит узлы и связи: города, деревни, переправы, пограничные выходы, морские точки, типы дорог и переходов, длину, риск и условия открытия.

3. **Контроллер путешествия**  
   Главный мозг: знает текущий и целевой узлы, выбирает тип перехода, запускает presentation-layer, решает встречу и завершает переход прибытия.

4. **Слой представления перехода**  
   То, что видит игрок: наземная микро-катсцена, морское видео, чёрный экран/fade, короткий текст статуса, дорожная encounter-сцена.

Это разделение критично: world map в NWN2 уже подразумевает выбор hotspot’а и передачу действия через ActionScript, а не хранение всей логики внутри карты.

### 4. Узлы и связи

#### 4.1. Типы узлов

Минимальный набор:

- `CITY` — крупный город;
- `SETTLEMENT` — малая деревня/посёлок;
- `LAND_GATE` — сухопутный выход или пограничный переход;
- `PORT` — порт или пристань;
- `FERRY_POINT` — точка паромной переправы;
- `MODULE_EXIT` — выход в другой модуль;
- `HIDDEN_TRANSIT` — служебный узел, через который считается путь, но игрок его напрямую не выбирает.

#### 4.2. Типы связей

- `ROAD` — тракт/дорога;
- `FOREST_PATH` — лесной путь;
- `MOUNTAIN_PATH` — перевал/горный участок;
- `FERRY` — короткая водная переправа;
- `SEA_ROUTE` — морской переход;
- `MODULE_LINK` — связь с другим модулем.

### 5. Наземные перемещения

#### 5.1. Канон

Наземный переход должен строиться вокруг world map и короткой наземной визуализации. Игрок подходит к точке выхода (ворота, тракт, пограничный проход) и открывает world map. На карте доступны только соседние или разрешённые точки. После выбора запускается переход: либо короткая наземная катсцена, либо затемнение, либо дорожная встреча, а затем партия прибывает в целевой узел. Такой подход соответствует тому, как в NWN2 организованы world map и area transition.

#### 5.2. Экранный сценарий

Сухопутный переход:

1. Игрок входит в триггер у выхода.
2. Открывается карта мира.
3. Игрок выбирает ближайший доступный узел.
4. Контроллер запускает наземный переход.
5. Далее один из трёх исходов:
   - мгновенное прибытие после короткого монтажного перехода;
   - встреча на дороге;
   - особое событие.
6. После завершения — прибытие к `waypoint` целевой области.

Стандартные area transition NWN2 умеют вести на waypoint и поддерживают Party Transition, который рекомендуется включать для перевода всей партии целиком.

#### 5.3. Что визуализировать

Для земли правильная подача — микро-катсцена, не видео и не ожидание на месте.

Использовать:

- выход из ворот;
- дорогу;
- лесную тропу;
- мост;
- ночлег;
- прибытие к стенам города.

Для таких коротких сцен NWN2 даёт штатные функции катсцен, затемнения и возврата камеры: `FadeToBlack`, `BlackScreen`, `SetCutsceneMode`, `StoreCameraFacing`, `RestoreCameraFacing` и др.

#### 5.4. Практическая рекомендация

Для пеших переходов не использовать видео как основную форму. Катсцены здесь лучше, потому что позже их легче контекстно разнообразить: время суток, погода, состав партии, регион, тип дороги.

### 6. Морские перемещения

#### 6.1. Канон

Морской переход для проекта фиксируется как сервисный переход через порт/паромщика + видео как постоянный presentation-layer. Не симулировать физическое плавание корабля по миру. Не строить настоящую over-water overland-систему на старте. Хотя community proof-of-concept по overland over water существует, это отдельное направление разработки и явный признак повышенной сложности.

#### 6.2. Экранный сценарий

Морской переход:

1. Игрок говорит с паромщиком/капитаном/мастером пристани.
2. Видит список доступных направлений, цену и, при необходимости, условия.
3. Платит.
4. Запускается морской ролик.
5. По завершении:
   - прибытие в порт назначения;
   - или редкое морское событие;
   - или переход к другому модулю.

#### 6.3. Видео как канон для моря

Источники подтверждают, что NWN2 использует `.bik` как movie-формат, а кастомные NWN2-модули действительно поставлялись с собственными `.bik`-роликами, которые игроки клали в папку `Movies`. Это делает видео жизнеспособным слоем оформления морского перехода. Однако в найденных источниках нет столь же полной документации именно по произвольному mid-game вызову кастомного ролика, как по world map и обычным переходам; поэтому решение считается допустимым, но требующим обязательного прототипа на конкретной сборке.

#### 6.4. Несколько роликов

Для моря использовать пулы роликов, а не один и тот же файл всегда.
Минимальный набор:

- короткая переправа;
- обычный прибрежный переход;
- дальний морской переход;
- плохая погода;
- прибытие в крупный порт.

Правило выбора:

1. Сначала выбирается тип маршрута.
2. Потом случайный ролик из соответствующего пула.
3. Ролик, показанный в прошлый раз, не должен выпадать сразу повторно.

### 7. События и встречи

#### 7.1. Общий принцип

Встречи должны быть привязаны не к городам, а к типу сегмента пути.

Не: «по дороге в город X бывает Y».  
А: «на `ROAD_CIVILIZED` может быть патруль, купец, паломники»; «на `FOREST_PATH` — засада, зверь, следы, потерянный обоз»; «на `SEA_ROUTE` — шторм, дрейфующий мусор, чужое судно, пиратская угроза».

#### 7.2. Реализация

Для встречи не нужно строить area на каждый переход. Нужен небольшой пул заготовленных encounter-областей:

- тракт;
- лесная дорога;
- мост;
- горный проход;
- побережье;
- причал;
- морская сцена.

Их загружает контроллер только когда выпадает событие.

### 8. Данные состояния

#### 8.1. Что хранить

Минимальный `TravelState`:

- `origin_node`
- `target_node`
- `travel_type`
- `edge_id`
- `encounter_pool_id`
- `price`
- `presentation_type`
- `last_sea_video_id`
- `pending_event_id`
- `return_node_if_interrupted`

#### 8.2. Где хранить

Не опираться на Campaign DB как основу travel-state.
В документации NWN2 у campaign DB функций прямо стоит пометка: «Campaign DB functions are not currently supported.» Это касается, например, `SetCampaignLocation`; аналогичное предупреждение есть и у других campaign DB функций. Для постоянного состояния маршрутов, портов и межмодульных переходов использовать:

- локальные/глобальные переменные там, где это безопасно;
- внешний БД-слой проекта как канонический persistent storage.

### 9. Ограничения движка, которые нужно учитывать жёстко

#### 9.1. Нельзя строить систему вокруг «настоящего движущегося корабля»

`MountObject` в NWN2 задокументирован как stub и «does not do anything». Это означает: нельзя опираться на идею «посадим игрока на корабль и повезём как mounted object».

#### 9.2. Можно спавнить и переставлять представления, но не надо симулировать carrier physics

`CreateObject` позволяет создавать placeable/waypoint и другие объекты, а `JumpToLocation` — телепортировать цель в нужную точку. То есть «переставить состояние перехода», «создать новый портовый корабль» или «перенести партию к точке прибытия» — нормально. А вот реальное плавное перемещение walkable ship с пассажирами как физической платформы — плохая опорная архитектура.

#### 9.3. Heartbeat нельзя делать основой travel-system

Событие `OnHeartbeat` у модуля срабатывает каждые 6 секунд; у зон/триггеров/встреч — тоже с таким же шагом. Community-материалы отдельно предупреждают, что heartbeat-скрипты могут быть CPU-intensive. Значит, travel-system не строится как «глобальный heartbeat считает путь». Архитектура должна быть событийной: выбор узла, запуск перехода, встреча, прибытие.

#### 9.4. Катсцены требуют безопасного выхода

`OnCutsceneAbort` существует, а отменившего игрока можно получить через `GetLastPCToCancelCutscene()`. Значит, если наземные переходы делают микро-катсцены, нужно обязательно предусматривать аварийный выход. Нельзя рассчитывать, что Escape сам корректно всё разрулит.

#### 9.5. World map требует дисциплины в настройке

В типовом гайде для NWN2 world map:

- карта делается как `647x647 .tga`;
- hotspot-иконки — `32x32 .tga`;
- у hotspot’ов есть `ActionScript` и `ConditionalScript`;
- world map trigger использует переменную `sMap`;
- для цели рекомендуется иметь waypoint по сторонам света (`_n`, `_s`, `_e`, `_w`).

Это не «жёсткий закон движка», но это проверенная builder-практика.

#### 9.6. Судовые переходы и walkmesh чувствительны к таймингам

В community-модуле Stormchaser отдельно упоминаются:

- переработка ship transition scripts для повышения устойчивости;
- timing problems;
- смена метода работы с walkmesh helper, чтобы избежать script lag и abort critical event.

Вывод: корабельные переходы и «живые» walkmesh-решения в NWN2 чувствительны к таймингам, поэтому море лучше делать через узловой переход, а не через сложную симуляцию объекта-корабля.

### 10. Рекомендации по реализации

#### 10.1. Что рекомендуется как канон

**Наземный слой**

- использовать world map как основной UI выбора направления;
- запускать короткие катсцены только для земли;
- встречи держать в отдельных encounter-area;
- маршруты считать по данным, а не по «красоте карты».

**Морской слой**

- вход через паромщика/порт/капитана;
- presentation-layer всегда видео;
- несколько роликов на тип перехода;
- обязательный fallback: затемнение + телепорт, если ролик не сработал.

**Для обоих слоёв**

- вся логика в travel-controller;
- карта только показывает доступные точки;
- узлы и связи хранятся как данные;
- прибытие всегда происходит на waypoint целевой области.

#### 10.2. Что не рекомендуется

- делать SoZ-подобную свободную overland-карту как базу всего модуля;
- делать путь таймером на месте;
- делать море как «настоящий движущийся корабль с игроком сверху»;
- хранить критическое состояние переходов в Campaign DB;
- делать глобальные heartbeat-циклы для путешествий.

### 11. Этапы внедрения

1. **Этап 1. Базовый сухопутный каркас**
   - список узлов;
   - список сухопутных связей;
   - вызов world map;
   - выбор соседней точки;
   - переход по waypoint.

2. **Этап 2. Наземный presentation-layer**
   - 1–2 микро-катсцены;
   - затемнение/возврат камеры;
   - 1 encounter-area.

3. **Этап 3. Морской каркас**
   - паромщик;
   - цена;
   - порт-узлы;
   - телепорт прибытия.

4. **Этап 4. Морской video-layer**
   - один тестовый `.bik`;
   - проверка стабильного проигрывания на целевой сборке;
   - затем пулы роликов.

5. **Этап 5. События по пути**
   - дорожные;
   - морские;
   - пограничные.

### 12. Итоговый вердикт

Лучший дизайн для модуля — узловая система путешествий поверх world map NWN2:

- **земля** = карта → выбор соседнего узла → короткая катсцена/событие → прибытие;
- **море** = порт/паромщик → выбор маршрута → видео → прибытие/морское событие.

Это решение:

- соответствует тому, как NWN2 изначально работает с world map;
- не упирается в явные ограничения движка вроде неработающего `MountObject` и неподдерживаемого Campaign DB;
- не требует опасной heartbeat-архитектуры;
- и оставляет путь к будущему расширению через encounter-сцены, дополнительные ролики и более богатые катсцены.

Следующий логичный шаг — собрать формальную спецификацию данных: таблицы `NodeDefinition`, `EdgeDefinition`, `TravelState`, `EncounterPool` и `SeaVideoPool` под целевую карту.
