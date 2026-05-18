# 04_LAW_CRIME_WITNESS_DESIGN

## Цель

Law/crime/witness система должна быть событийной, дешёвой и разделённой по каналам.

Нельзя строить монолитную witness-систему на heartbeat.

## Event surface

Использовать штатные события:

### Creature / victim / witness

- `OnDamaged`;
- `OnDeath`;
- `OnInventoryDisturbed`;
- `OnPerception`;
- `OnPhysicallyAttacked`;
- `OnSpellCastAt`;
- `OnUserDefined`.

### Module

- `OnPlayerEquipItem`;
- `OnPlayerUnequipItem`;
- `OnAcquireItem`;
- `OnUnacquireItem`;
- `OnActivateItem`.

### Triggers

- `OnEnter`;
- `OnExit`.

## Central route

Все события должны сходиться в единый law-router:

```c
void Law_ReportCrime(
    object oSource,
    object oOffender,
    int nCrimeType,
    object oVictim,
    int nSeverity
);
```

Event handlers должны быть тонкими:

```text
event stub -> extract context -> normalize -> Law_ReportCrime
```

Не решать “арестовать/казнить/простить” прямо в `OnDisturbed` или `OnDamaged`.

## Law zones

Мир делится на зоны закона:

- город;
- рынок;
- частный дом;
- кузница/лавка;
- казарма;
- храм;
- дворец;
- тюрьма;
- лагерь игрока;
- wilderness;
- owned property.

Зона должна задавать policy:

```text
weapons_allowed
theft_policy
spell_policy
owner/faction
guard_response_profile
fine/jail/reputation impact
```

## Оружие в городе

Первичный канал для PC:

- module `OnPlayerEquipItem`;
- module `OnPlayerUnequipItem`;
- current `LAW_ZONE`.

Вторичный канал:

- `OnPerception`, когда вооружённый игрок входит в поле зрения NPC/стражи.

Не делать глобальный heartbeat “проверить у всех оружие”.

## Кража

Кража и disturbance — отдельный inventory/theft layer.

Использовать:

- `GetLastDisturbed()`;
- `GetInventoryDisturbType()`;
- `GetInventoryDisturbItem()`.

Правило:

```text
OnDisturbed != автоматически crime
```

Нужно учитывать:

- тип disturbance;
- ownership;
- scripted transfer suppress flag;
- валиден ли item;
- валиден ли offender;
- контейнер/creature/placeable;
- context fallback.

## Theft fallback

Если контекст неполный:

```text
if offender invalid:
  use last hostile actor only if semantically safe
if item invalid:
  report suspicious disturbance, not exact item theft
if suppress flag set:
  ignore scripted transfer
```

## Не смешивать theft и social/noise

Разделение:

```text
OnInventoryDisturbed -> theft/inventory
OnConversation/listening/shout -> alarm/social/noise
OnPerception heard/seen -> perception
OnDamaged/OnDeath -> violence
Trigger enter/exit -> forbidden zone/trespass
```

## Assault / murder

Использовать:

- `OnDamaged` для нападения;
- `OnDeath` для убийства;
- `OnPhysicallyAttacked` как дополнительный сигнал;
- faction/zone policy для реакции.

## Forbidden zones

Использовать triggers:

```text
LAW_ZONE_PRIVATE
LAW_ZONE_RESTRICTED
LAW_ZONE_GUARD_ONLY
LAW_ZONE_OWNER_PROPERTY
```

OnEnter:

```text
set current zone
check permission
warn or report trespass
```

OnExit:

```text
clear/update zone
```

## Spells

Использовать:

- `OnSpellCastAt`;
- harmful flag;
- spell classification table.

Не делать дорогую проверку всех spell effects постоянно.

## Witness memory

Минимальный witness memory:

```text
offender id
crime type
zone
severity
time
victim/faction
dedupe key
```

Хранение:

- краткосрочно в locals;
- долговременно только значимые преступления;
- batch flush в DB/event_log.

## Guard response

Реакция должна быть ступенчатой:

```text
warning
demand sheath weapon
fine
refuse service
call guards
arrest
attack only for severe cases
```

## Антипаттерны

- общий heartbeat свидетелей;
- каждый NPC ищет преступника area scan;
- OnDisturbed трактуется как любой социальный шум;
- theft/social/noise слиты в одну систему;
- law logic внутри каждого NPC без центрального router;
- DB write на каждый мелкий perception;
- автоматический murder report без проверки faction/zone/context.

## MVP law system

Для первой версии:

1. law zones;
2. weapon equip reaction in city;
3. theft through OnDisturbed;
4. attack/murder through OnDamaged/OnDeath;
5. guard warning/escalation;
6. merchant refusal by crime/reputation;
7. event log;
8. no global polling.
