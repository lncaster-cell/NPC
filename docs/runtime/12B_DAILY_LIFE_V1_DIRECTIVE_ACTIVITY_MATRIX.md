# Ambient Life v2 — Daily Life v1 Directive → Activity Selection Matrix

Дата: 2026-03-20  
Статус: canonical reference draft  
Назначение: зафиксировать для Daily Life v1 безопасную матрицу выбора activity ID по `directive`, `npc_family` и `npc_subtype`. Документ нужен для activity layer, чтобы агент не выбирал визуальную постановку произвольно и не смешивал смысл директивы с конкретной анимацией.

---

## 1) Источники

Этот документ опирается на:
- `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md`
- `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
- `docs/runtime/12B_DAILY_LIFE_V1_ACTIVITY_ANIMATION_REFERENCE.md`
- `docs/runtime/12B_DAILY_LIFE_V1_INSPECTION_PATCH.md`

Нормативное правило:
- `directive` определяет смысл текущего режима NPC;
- `activity_id` определяет только визуальную постановку внутри уже выбранной директивы;
- один `directive` может иметь несколько допустимых `activity_id` в зависимости от family/subtype/context.

---

## 2) Базовые правила выбора

### 2.1 Порядок выбора

Activity layer должен идти в таком порядке:
1. принять уже вычисленную `directive`;
2. посмотреть `npc_family` и `npc_subtype`;
3. посмотреть `anchor_group` и контекст точки;
4. выбрать допустимый `AL_ACT_*` из матрицы;
5. выбрать конкретную анимацию из custom animation list activity;
6. если допустимого `AL_ACT_*` нет — использовать safe fallback.

### 2.2 Что запрещено

Запрещено:
- выбирать activity до вычисления `directive`;
- выбирать activity напрямую из профессии, игнорируя текущую директиву;
- использовать случайную анимацию вне матрицы;
- тащить complex pair logic в Milestone A.

### 2.3 Safe fallback

Если нет точного activity match:
- для `SLEEP` -> ближайший безопасный sleep activity
- для `WORK` -> generic work/craft activity
- для `SERVICE` -> generic service/presence activity
- для `DUTY` -> guard/post activity
- для `SOCIAL` -> sit/stand chat activity
- для `PUBLIC_PRESENCE` -> idle/public presence activity

---

## 3) Directive → generic fallback activity

```text
SLEEP -> AL_ACT_NPC_SLEEP_BED / AL_ACT_NPC_SLEEP_90
WORK -> AL_ACT_NPC_FORGE / AL_ACT_NPC_COOK_MULTI / AL_ACT_NPC_FORGE_MULTI
SERVICE -> AL_ACT_NPC_MERCHANT_MULTI / AL_ACT_NPC_BARTENDER / AL_ACT_NPC_POST
DUTY -> AL_ACT_NPC_GUARD / AL_ACT_NPC_POST
EAT -> AL_ACT_NPC_DINNER / AL_ACT_NPC_SIT_DINNER
SOCIAL -> AL_ACT_NPC_SIT / AL_ACT_NPC_STAND_CHAT
WORSHIP -> AL_ACT_NPC_MEDITATE / AL_ACT_NPC_KNEEL_TALK
RETURN_BASE -> AL_ACT_NPC_ACT_ONE
IDLE_BASE -> AL_ACT_NPC_ACT_ONE / AL_ACT_NPC_ACT_TWO
PUBLIC_PRESENCE -> AL_ACT_NPC_ACT_ONE / AL_ACT_NPC_ACT_TWO / AL_ACT_NPC_POST
HIDE_SAFE -> AL_ACT_NPC_HIDDEN
LOCKDOWN_BASE -> AL_ACT_NPC_ACT_ONE / AL_ACT_NPC_SIT
ASSIST_RESPONSE -> AL_ACT_NPC_GUARD / AL_ACT_NPC_POST
HOLD_POST -> AL_ACT_NPC_POST / AL_ACT_NPC_GUARD
LEAVE_CITY -> no local activity
BASE_LOST -> no local activity or safe stub idle before absent
UNASSIGNED -> no local activity
ABSENT -> no local activity
```

---

## 4) Matrix by family and directive

## 4.1 `LAW`

### Subtypes
- `PATROL`
- `GATE_POST`
- `INSPECTION`

### `DUTY`

```text
LAW/PATROL -> AL_ACT_NPC_GUARD, AL_ACT_NPC_POST
LAW/GATE_POST -> AL_ACT_NPC_POST, AL_ACT_NPC_GUARD
LAW/INSPECTION -> AL_ACT_NPC_POST, AL_ACT_NPC_GUARD
```

Нормативная трактовка:
- `PATROL` в Milestone A не обязан иметь богатую патрульную choreography;
- допустима простая visual постановка duty/presence на post/guard activity.

### `PUBLIC_PRESENCE`

```text
LAW/* -> AL_ACT_NPC_POST, AL_ACT_NPC_ACT_ONE
```

### `SOCIAL`

```text
LAW/* -> AL_ACT_NPC_STAND_CHAT, AL_ACT_NPC_SIT
```

### `EAT`

```text
LAW/* -> AL_ACT_NPC_DINNER, AL_ACT_NPC_SIT_DINNER
```

### `SLEEP`

```text
LAW/* -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
```

### `HOLD_POST`

```text
LAW/* -> AL_ACT_NPC_POST, AL_ACT_NPC_GUARD
```

### `ASSIST_RESPONSE`

```text
LAW/* -> AL_ACT_NPC_GUARD, AL_ACT_NPC_POST
```

---

## 4.2 `CRAFT`

### Subtypes
- `BLACKSMITH`
- `ARTISAN`
- `LABORER`

### `WORK`

```text
CRAFT/BLACKSMITH -> AL_ACT_NPC_FORGE, AL_ACT_NPC_FORGE_MULTI
CRAFT/ARTISAN -> AL_ACT_NPC_FORGE_MULTI, AL_ACT_NPC_COOK_MULTI, AL_ACT_NPC_READ
CRAFT/LABORER -> AL_ACT_NPC_WOODSMAN, AL_ACT_NPC_FORGE_MULTI, AL_ACT_NPC_COOK_MULTI
```

Нормативная трактовка:
- `AL_ACT_NPC_READ` для `ARTISAN` использовать только как слабый fallback для workbench/desk-like work presence, а не как основной ремесленный визуал.

### `SERVICE`

```text
CRAFT/BLACKSMITH -> AL_ACT_NPC_FORGE, AL_ACT_NPC_POST
CRAFT/ARTISAN -> AL_ACT_NPC_FORGE_MULTI, AL_ACT_NPC_POST
CRAFT/LABORER -> AL_ACT_NPC_ACT_ONE
```

Нормативная трактовка:
- если ремесленник в сервисном окне обслуживает игрока, допустима work-like service постановка, а не отдельная торговая анимация.

### `SOCIAL`

```text
CRAFT/* -> AL_ACT_NPC_SIT, AL_ACT_NPC_STAND_CHAT, AL_ACT_NPC_CHEER
```

### `EAT`

```text
CRAFT/* -> AL_ACT_NPC_DINNER, AL_ACT_NPC_SIT_DINNER
```

### `SLEEP`

```text
CRAFT/* -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
```

### `PUBLIC_PRESENCE`

```text
CRAFT/* -> AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_ACT_TWO
```

### `ASSIST_RESPONSE`

```text
CRAFT/* -> AL_ACT_NPC_GUARD, AL_ACT_NPC_POST, AL_ACT_NPC_WOODSMAN
```

Нормативная трактовка:
- `AL_ACT_NPC_WOODSMAN` здесь допустим только как rough helper/physical response visual, не как обязательный crisis behavior.

---

## 4.3 `TRADE_SERVICE`

### Subtypes
- `SHOPKEEPER`
- `INNKEEPER`
- `WANDERING_VENDOR`

### `SERVICE`

```text
TRADE_SERVICE/SHOPKEEPER -> AL_ACT_NPC_MERCHANT_MULTI, AL_ACT_NPC_POST
TRADE_SERVICE/INNKEEPER -> AL_ACT_NPC_BARTENDER, AL_ACT_NPC_BARMAID, AL_ACT_NPC_MERCHANT_MULTI
TRADE_SERVICE/WANDERING_VENDOR -> AL_ACT_NPC_MERCHANT_MULTI, AL_ACT_NPC_POST
```

Нормативная трактовка:
- `BARMAID/BARTENDER` pair logic не обязателен в Milestone A;
- одиночный innkeeper может использовать любой из service-compatible activity без параллельной orchestration.

### `SOCIAL`

```text
TRADE_SERVICE/* -> AL_ACT_NPC_SIT, AL_ACT_NPC_STAND_CHAT, AL_ACT_NPC_CHEER
```

### `EAT`

```text
TRADE_SERVICE/* -> AL_ACT_NPC_DINNER, AL_ACT_NPC_SIT_DINNER
```

### `SLEEP`

```text
TRADE_SERVICE/* -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
```

### `PUBLIC_PRESENCE`

```text
TRADE_SERVICE/* -> AL_ACT_NPC_POST, AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_ACT_TWO
```

### `LOCKDOWN_BASE`

```text
TRADE_SERVICE/* -> AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_SIT
```

---

## 4.4 `CIVILIAN`

### Subtypes
- `RESIDENT`
- `HOMELESS`
- `SERVANT`

### `PUBLIC_PRESENCE`

```text
CIVILIAN/RESIDENT -> AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_ACT_TWO, AL_ACT_NPC_POST
CIVILIAN/HOMELESS -> AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_SIT, AL_ACT_NPC_SAD
CIVILIAN/SERVANT -> AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_ACT_TWO, AL_ACT_NPC_MERCHANT_MULTI
```

### `SOCIAL`

```text
CIVILIAN/* -> AL_ACT_NPC_SIT, AL_ACT_NPC_STAND_CHAT, AL_ACT_NPC_AGREE, AL_ACT_NPC_SAD, AL_ACT_NPC_CHEER
```

### `EAT`

```text
CIVILIAN/* -> AL_ACT_NPC_DINNER, AL_ACT_NPC_SIT_DINNER
```

### `SLEEP`

```text
CIVILIAN/RESIDENT -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
CIVILIAN/HOMELESS -> AL_ACT_NPC_SLEEP_90, AL_ACT_NPC_MIDNIGHT_90
CIVILIAN/SERVANT -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
```

### `HIDE_SAFE`

```text
CIVILIAN/* -> AL_ACT_NPC_HIDDEN
```

---

## 4.5 `ELITE_ADMIN`

### Subtypes
- `NOBLE`
- `OFFICIAL`
- `SCRIBE`

### `PUBLIC_PRESENCE`

```text
ELITE_ADMIN/NOBLE -> AL_ACT_NPC_ACT_ONE, AL_ACT_NPC_ACT_TWO, AL_ACT_NPC_POST
ELITE_ADMIN/OFFICIAL -> AL_ACT_NPC_POST, AL_ACT_NPC_READ, AL_ACT_NPC_ACT_ONE
ELITE_ADMIN/SCRIBE -> AL_ACT_NPC_READ, AL_ACT_NPC_SIT, AL_ACT_NPC_ACT_ONE
```

### `WORK`

```text
ELITE_ADMIN/NOBLE -> AL_ACT_NPC_POST, AL_ACT_NPC_READ
ELITE_ADMIN/OFFICIAL -> AL_ACT_NPC_READ, AL_ACT_NPC_POST
ELITE_ADMIN/SCRIBE -> AL_ACT_NPC_READ, AL_ACT_NPC_SIT
```

### `SOCIAL`

```text
ELITE_ADMIN/* -> AL_ACT_NPC_SIT, AL_ACT_NPC_STAND_CHAT, AL_ACT_NPC_AGREE
```

### `EAT`

```text
ELITE_ADMIN/* -> AL_ACT_NPC_DINNER, AL_ACT_NPC_SIT_DINNER
```

### `SLEEP`

```text
ELITE_ADMIN/* -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
```

---

## 4.6 `CLERGY`

### Subtype
- `PRIEST`

### `WORSHIP`

```text
CLERGY/PRIEST -> AL_ACT_NPC_MEDITATE, AL_ACT_NPC_KNEEL_TALK
```

### `PUBLIC_PRESENCE`

```text
CLERGY/PRIEST -> AL_ACT_NPC_POST, AL_ACT_NPC_ACT_ONE
```

### `SOCIAL`

```text
CLERGY/PRIEST -> AL_ACT_NPC_STAND_CHAT, AL_ACT_NPC_SIT, AL_ACT_NPC_AGREE
```

### `EAT`

```text
CLERGY/PRIEST -> AL_ACT_NPC_DINNER, AL_ACT_NPC_SIT_DINNER
```

### `SLEEP`

```text
CLERGY/PRIEST -> AL_ACT_NPC_SLEEP_BED, AL_ACT_NPC_SLEEP_90
```

---

## 5) Directive-specific notes

## 5.1 `SLEEP`

Использовать только sleep-compatible activities:
- `AL_ACT_NPC_SLEEP_BED`
- `AL_ACT_NPC_MIDNIGHT_BED`
- `AL_ACT_NPC_SLEEP_90`
- `AL_ACT_NPC_MIDNIGHT_90`

Нормативное правило:
- bed-based activity использовать только при наличии соответствующего sleep context;
- если bed context нет, для первой версии допустим ограниченный fallback на `_90` вариант или stub absent-path, но не на произвольную idle анимацию.

## 5.2 `WORK`

`WORK` не должен автоматически означать одну и ту же activity для всех.

- кузнец -> forge family
- ремесленник -> craft/multi family
- чиновник/писарь -> read/desk presence
- служитель -> worship не считать обычным work, это отдельная директива

## 5.3 `SERVICE`

`SERVICE` — это не всегда торговая стойка.

Примеры:
- торговец -> merchant multi
- трактирщик -> bartender/barmaid/merchant multi
- кузнец в сервисном окне -> может оставаться в work-like service presentation

## 5.4 `DUTY`

Для первой версии держать duty-визуал максимально простым:
- `AL_ACT_NPC_POST`
- `AL_ACT_NPC_GUARD`

Не строить сложный патрульный визуальный FSM в Milestone A.

## 5.5 `SOCIAL`

`SOCIAL` делить на два визуальных класса:
- сидячая социалка -> `AL_ACT_NPC_SIT`, `AL_ACT_NPC_SIT_DINNER`
- стоячая социалка -> `AL_ACT_NPC_STAND_CHAT`, `AL_ACT_NPC_AGREE`, `AL_ACT_NPC_CHEER`

## 5.6 `PUBLIC_PRESENCE`

`PUBLIC_PRESENCE` не должен выглядеть как полноценная социалка.

Использовать в первую очередь:
- `AL_ACT_NPC_ACT_ONE`
- `AL_ACT_NPC_ACT_TWO`
- `AL_ACT_NPC_POST`

Это соответствует inspection patch, где `PUBLIC_PRESENCE` отделён от `SOCIAL`.

---

## 6) Milestone A core subset

Для Milestone A обязательно и достаточно поддержать такой минимальный activity subset:

```text
AL_ACT_NPC_SLEEP_BED
AL_ACT_NPC_SLEEP_90
AL_ACT_NPC_FORGE
AL_ACT_NPC_FORGE_MULTI
AL_ACT_NPC_MERCHANT_MULTI
AL_ACT_NPC_BARTENDER
AL_ACT_NPC_POST
AL_ACT_NPC_GUARD
AL_ACT_NPC_DINNER
AL_ACT_NPC_SIT_DINNER
AL_ACT_NPC_SIT
AL_ACT_NPC_STAND_CHAT
AL_ACT_NPC_MEDITATE
AL_ACT_NPC_KNEEL_TALK
AL_ACT_NPC_ACT_ONE
AL_ACT_NPC_ACT_TWO
AL_ACT_NPC_HIDDEN
```

Нормативное правило:
- остальные `AL_ACT_*` считать допустимыми расширениями post-Milestone A.

---

## 7) Advanced / deferred activities

Не делать обязательной частью Milestone A:
- `AL_ACT_NPC_TRAINING_ONE`
- `AL_ACT_NPC_TRAINING_TWO`
- `AL_ACT_NPC_TRAINER_PACE`
- `AL_ACT_NPC_WWP`
- `AL_ACT_NPC_BARMAID` как pair-dependent activity
- `AL_ACT_NPC_THIEF`
- `AL_ACT_NPC_THIEF2`
- `AL_ACT_NPC_ASSASSIN`
- locate-wrapper orchestration `91..98`

Они допустимы как future extension, но не как ядро первой версии.

---

## 8) Safe fallback matrix

Если точное family/subtype mapping недоступно, использовать:

```text
SLEEP -> AL_ACT_NPC_SLEEP_90
WORK -> AL_ACT_NPC_FORGE_MULTI
SERVICE -> AL_ACT_NPC_MERCHANT_MULTI
DUTY -> AL_ACT_NPC_GUARD
EAT -> AL_ACT_NPC_DINNER
SOCIAL -> AL_ACT_NPC_STAND_CHAT
WORSHIP -> AL_ACT_NPC_MEDITATE
PUBLIC_PRESENCE -> AL_ACT_NPC_ACT_ONE
LOCKDOWN_BASE -> AL_ACT_NPC_ACT_ONE
HIDE_SAFE -> AL_ACT_NPC_HIDDEN
```

---

## 9) Нормативное резюме

Для Daily Life v1:
- `directive` задаёт смысл;
- `activity_id` задаёт визуальную постановку;
- activity выбирать только после resolver;
- для Milestone A использовать ограниченный core subset activities;
- pair/training/wrapper logic считать advanced feature;
- `PUBLIC_PRESENCE` визуально держать отдельно от `SOCIAL`;
- если в коде нет точного match, применять safe fallback, а не изобретать новую activity импровизацией.
