# Ambient Life v2 — Daily Life v1 Activity & Animation Reference

Дата: 2026-03-20  
Статус: canonical reference draft  
Назначение: зафиксировать для Daily Life v1 канонический список activity ID, доступных custom animation mapping, locate-wrapper activity и связанных служебных правил. Документ нужен как reference для агента и для будущей реализации activity layer.

---

## 1) Источник

Этот reference собран из канонического activity-файла прототипа Ambient Life в репозитории `COMPILATOR`:

- repository: `lncaster-cell/COMPILATOR`
- file: `scripts/al_prototype/al_acts_inc.nss`
- ref: `7718a878e0e5eed443d466fbe03e746631880969`

Нормативное правило:
- для Daily Life v1 этот документ считать reference-слоем для activity/animation source policy;
- при расхождении между более ранними догадками и этим документом использовать этот документ.

---

## 2) Activity animation source policy

Каноническая policy из источника:

- `AL_GetActivityCustomAnims` и `AL_GetLocateWrapperCustomAnims` — первичный источник анимаций.
- `AL_GetActivityNumericAnims` — только для активностей, у которых нет custom mappings.
- нельзя дублировать одну и ту же activity одновременно в custom и numeric таблицах.

Фактическое состояние источника на указанном ref:
- `AL_GetActivityNumericAnims` пустой;
- runtime-полезная activity-анимация берётся из custom mappings.

Нормативное правило для Daily Life v1:
- в первой реализации считать **custom animation list** единственным реальным источником выбора activity animation;
- numeric fallback не делать обязательной частью Milestone A.

---

## 3) Канонические Activity ID

```text
AL_ACT_NPC_HIDDEN = 0
AL_ACT_NPC_ACT_ONE = 1
AL_ACT_NPC_ACT_TWO = 2
AL_ACT_NPC_DINNER = 3
AL_ACT_NPC_MIDNIGHT_BED = 4
AL_ACT_NPC_SLEEP_BED = 5
AL_ACT_NPC_WAKE = 6
AL_ACT_NPC_AGREE = 7
AL_ACT_NPC_ANGRY = 8
AL_ACT_NPC_SAD = 9
AL_ACT_NPC_COOK = 10
AL_ACT_NPC_DANCE_FEMALE = 11
AL_ACT_NPC_DANCE_MALE = 12
AL_ACT_NPC_DRUM = 13
AL_ACT_NPC_FLUTE = 14
AL_ACT_NPC_FORGE = 15
AL_ACT_NPC_GUITAR = 16
AL_ACT_NPC_WOODSMAN = 17
AL_ACT_NPC_MEDITATE = 18
AL_ACT_NPC_POST = 19
AL_ACT_NPC_READ = 20
AL_ACT_NPC_SIT = 21
AL_ACT_NPC_SIT_DINNER = 22
AL_ACT_NPC_STAND_CHAT = 23
AL_ACT_NPC_TRAINING_ONE = 24
AL_ACT_NPC_TRAINING_TWO = 25
AL_ACT_NPC_TRAINER_PACE = 26
AL_ACT_NPC_WWP = 27
AL_ACT_NPC_CHEER = 28
AL_ACT_NPC_COOK_MULTI = 29
AL_ACT_NPC_FORGE_MULTI = 30
AL_ACT_NPC_MIDNIGHT_90 = 31
AL_ACT_NPC_SLEEP_90 = 32
AL_ACT_NPC_THIEF = 33
AL_ACT_NPC_THIEF2 = 36
AL_ACT_NPC_ASSASSIN = 37
AL_ACT_NPC_MERCHANT_MULTI = 38
AL_ACT_NPC_KNEEL_TALK = 39
AL_ACT_NPC_BARMAID = 41
AL_ACT_NPC_BARTENDER = 42
AL_ACT_NPC_GUARD = 43
AL_ACT_LOCATE_WRAPPER_MIN = 91
AL_ACT_LOCATE_WRAPPER_MAX = 98
```

---

## 4) Locate-wrapper activity custom anims

```text
91 -> lookleft, lookright, shrug
92 -> bored, scratchhead, yawn
93 -> sitfidget, sitidle, sittalk, sittalk01, sittalk02
94 -> kneelidle, kneeltalk
95 -> chuckle, nodno, nodyes, talk01, talk02, talklaugh
96 -> craft01, dustoff, forge01, openlock
97 -> meditate
98 -> disableground, sleightofhand, sneak
```

Нормативная трактовка:
- locate-wrapper activity — это готовые контейнеры анимаций для контекстов, где activity выбирается не по жёсткой профессии, а по wrapper-группе поведения;
- в первой версии Daily Life v1 их можно использовать как reference-слой, но не обязательно тащить все wrapper-mechanics в Milestone A.

---

## 5) NPC activity -> custom animation mapping

```text
AL_ACT_NPC_ACT_ONE -> lookleft, lookright
AL_ACT_NPC_ACT_TWO -> lookleft, lookright
AL_ACT_NPC_DINNER -> sitdrink, siteat, sitidle
AL_ACT_NPC_MIDNIGHT_BED -> laydownB, proneB
AL_ACT_NPC_SLEEP_BED -> laydownB, proneB
AL_ACT_NPC_WAKE -> sitdrink, siteat, sitidle
AL_ACT_NPC_AGREE -> chuckle, flirt, nodyes
AL_ACT_NPC_ANGRY -> intimidate, nodno, talkshout
AL_ACT_NPC_SAD -> talksad, tired
AL_ACT_NPC_COOK -> cooking02, disablefront
AL_ACT_NPC_DANCE_FEMALE -> curtsey, dance01
AL_ACT_NPC_DANCE_MALE -> bow, dance01, dance02
AL_ACT_NPC_DRUM -> bow, playdrum
AL_ACT_NPC_FLUTE -> curtsey, playflute
AL_ACT_NPC_FORGE -> craft01, dustoff, forge01
AL_ACT_NPC_GUITAR -> bow, playguitar
AL_ACT_NPC_WOODSMAN -> *1attack01, kneelidle
AL_ACT_NPC_MEDITATE -> meditate
AL_ACT_NPC_POST -> lookleft, lookright
AL_ACT_NPC_READ -> sitidle, sitread, sitteat
AL_ACT_NPC_SIT -> sitfidget, sitidle, sittalk, sittalk01, sittalk02
AL_ACT_NPC_SIT_DINNER -> sitdrink, siteat, sitidle, sittalk, sittalk01, sittalk02
AL_ACT_NPC_STAND_CHAT -> chuckle, lookleft, lookright, shrug, talk01, talk02, talklaugh
AL_ACT_NPC_TRAINING_ONE -> lookleft, lookright
AL_ACT_NPC_TRAINING_TWO -> lookleft, lookright
AL_ACT_NPC_TRAINER_PACE -> lookleft, lookright
AL_ACT_NPC_WWP -> kneelidle, lookleft, lookright
AL_ACT_NPC_CHEER -> chuckle, clapping, talklaugh, victory
AL_ACT_NPC_COOK_MULTI -> cooking01, cooking02, craft01, disablefront, dustoff, forge01, gettable, kneelidle, kneelup, openlock, scratchhead
AL_ACT_NPC_FORGE_MULTI -> craft01, dustoff, forge01, forge02, gettable, kneeldown, kneelidle, kneelup, openlock
AL_ACT_NPC_MIDNIGHT_90 -> laydownB, proneB
AL_ACT_NPC_SLEEP_90 -> laydownB, proneB
AL_ACT_NPC_THIEF -> chuckle, getground, gettable, openlock
AL_ACT_NPC_THIEF2 -> disableground, sleightofhand, sneak
AL_ACT_NPC_ASSASSIN -> sneak
AL_ACT_NPC_MERCHANT_MULTI -> bored, getground, gettable, openlock, sleightofhand, yawn
AL_ACT_NPC_KNEEL_TALK -> kneelidle, kneeltalk
AL_ACT_NPC_BARMAID -> gettable, lookright, openlock, yawn
AL_ACT_NPC_BARTENDER -> gettable, lookright, openlock, yawn
AL_ACT_NPC_GUARD -> bored, lookleft, lookright, sigh
```

---

## 6) Numeric animation mapping

На указанном source ref:

```text
AL_GetActivityNumericAnims -> empty
```

Следствие:
- первая версия Daily Life v1 не должна рассчитывать на numeric fallback как на обязательный рабочий слой;
- если numeric fallback понадобится позже, это уже отдельное post-Milestone A решение.

---

## 7) Activity-specific helper rules from source

### 7.1 Waypoint tag requirements

```text
AL_ACT_NPC_TRAINER_PACE -> AL_WP_PACE
AL_ACT_NPC_WWP -> AL_WP_WWP
```

Нормативная трактовка:
- эти activity требуют специальный waypoint/tag context;
- в Milestone A их можно учитывать как advanced/reference activities, а не как обязательное ядро.

### 7.2 Training partner requirement

Из source:
- `AL_ACT_NPC_TRAINING_ONE`
- `AL_ACT_NPC_TRAINING_TWO`

требуют partner NPC в `FACTION_NPC1 / FACTION_NPC2`.

Нормативная трактовка:
- это не ядро первой версии;
- activity pair logic считать advanced feature.

### 7.3 Bar pair requirement

Из source:
- `AL_ACT_NPC_BARMAID` требует параллельную активность bartender.

Нормативная трактовка:
- barmaid/bartender pair mechanics не являются обязательной частью Milestone A;
- в первой версии можно использовать упрощённую одиночную service/activity модель.

---

## 8) Практическое применение в Daily Life v1

### 8.1 Что можно использовать сразу

Для первой версии безопасно использовать как reference следующие activity-наборы:
- сон: `AL_ACT_NPC_SLEEP_BED`, `AL_ACT_NPC_MIDNIGHT_BED`, `AL_ACT_NPC_SLEEP_90`, `AL_ACT_NPC_MIDNIGHT_90`
- кузница/ремесло: `AL_ACT_NPC_FORGE`, `AL_ACT_NPC_FORGE_MULTI`, `AL_ACT_NPC_COOK`, `AL_ACT_NPC_COOK_MULTI`
- пост/стража: `AL_ACT_NPC_POST`, `AL_ACT_NPC_GUARD`
- сидячая социалка/еда: `AL_ACT_NPC_SIT`, `AL_ACT_NPC_SIT_DINNER`, `AL_ACT_NPC_DINNER`
- стоячая социалка: `AL_ACT_NPC_STAND_CHAT`, `AL_ACT_NPC_AGREE`, `AL_ACT_NPC_ANGRY`, `AL_ACT_NPC_SAD`
- таверна/сервис: `AL_ACT_NPC_BARMAID`, `AL_ACT_NPC_BARTENDER`, `AL_ACT_NPC_MERCHANT_MULTI`
- религиозное/созерцательное: `AL_ACT_NPC_MEDITATE`, `AL_ACT_NPC_KNEEL_TALK`

### 8.2 Что считать advanced / optional

Пока не делать ядром Milestone A:
- training pair logic
- bar pair logic
- locate-wrapper orchestration как отдельную подсистему
- numeric fallback
- rich thief/assassin stealth orchestration

---

## 9) Mapping recommendation for Daily Life v1 activity layer

Рекомендуемый принцип для DLV1 activity layer:

- `directive` не равен `activity_id`
- `directive` определяет смысл режима
- `activity_id` выбирается как контекстная визуальная постановка внутри directive/anchor

Примеры:

### `DLV1 directive = WORK`
Возможные activity reference:
- `AL_ACT_NPC_FORGE`
- `AL_ACT_NPC_FORGE_MULTI`
- `AL_ACT_NPC_COOK`
- `AL_ACT_NPC_COOK_MULTI`
- `AL_ACT_NPC_READ` (для office-like work не как сервис, а как визуальная рутина)

### `DLV1 directive = SERVICE`
Возможные activity reference:
- `AL_ACT_NPC_MERCHANT_MULTI`
- `AL_ACT_NPC_BARTENDER`
- `AL_ACT_NPC_BARMAID`
- `AL_ACT_NPC_POST` (для formal presence / watch-like service contexts только если это действительно подходит контексту)

### `DLV1 directive = DUTY`
Возможные activity reference:
- `AL_ACT_NPC_POST`
- `AL_ACT_NPC_GUARD`

### `DLV1 directive = SOCIAL`
Возможные activity reference:
- `AL_ACT_NPC_SIT`
- `AL_ACT_NPC_SIT_DINNER`
- `AL_ACT_NPC_STAND_CHAT`
- `AL_ACT_NPC_AGREE`
- `AL_ACT_NPC_ANGRY`
- `AL_ACT_NPC_SAD`
- `AL_ACT_NPC_CHEER`

### `DLV1 directive = SLEEP`
Возможные activity reference:
- `AL_ACT_NPC_SLEEP_BED`
- `AL_ACT_NPC_MIDNIGHT_BED`
- `AL_ACT_NPC_SLEEP_90`
- `AL_ACT_NPC_MIDNIGHT_90`

---

## 10) Нормативное резюме

Для Daily Life v1 в репозитории `NPC`:
- activity/animation source policy брать из `COMPILATOR` activity prototype reference;
- custom animation mappings считать каноническим источником;
- numeric animation fallback не делать обязательным слоем первой версии;
- `directive` и `activity_id` жёстко различать;
- pairing/partner activity logic считать advanced feature;
- этот документ использовать как reference для activity layer, а не как приказ немедленно реализовать весь прототип один в один.
