# Ambient Life — Stage H Report (Activity Subsystem / Canonical Activity Semantics)

## Реализовано
- Введён отдельный activity execution layer в `scripts/ambient_life/al_activity_inc.nss` с центральным int-code mapping и fallback policy.
- Route и transition runtime теперь используют общий вход `AL_ActivityApplyStep(...)`; ad-hoc fallback из Stage D/E/F удалён.
- Сохранён canonical int-контракт: `al_activity` на step и `al_default_activity` на NPC.
- Добавлен минимальный runtime marker `al_activity_current` для диагностики текущей ordinary activity.

## Canonical source of truth
- Источник activity IDs/имен: canonical activity table из `lncaster-cell/PycukSystems` (`al_acts_inc.nss` + таблица активности/анимаций, отражённая в README NPC как mirror).
- В Stage H взят ограниченный Ambient Life subset ordinary-активностей:
  - `1 ActOne`, `3 Dinner`, `7 Agree`, `8 Angry`, `20 Read`, `21 Sit`, `23 StandChat`, `28 Cheer`, `39 KneelTalk`, `43 Guard`.
- Sleep-related IDs (`4`, `5`, `31`, `32`) отмечены как special-code и не исполняются ordinary activity subsystem.

## Границы special-cases
- Transition special-case: только через Stage F (`al_trans_type`, helper endpoints).
- Sleep special-case: только через Stage G (`al_bed_id`, `<bed_id>_approach/<bed_id>_pose`).
- Ordinary activity: все non-transition/non-sleep steps идут через Stage H mapping.
- Reaction override (crime/alarm/disturb) перенесён на следующий этап и в Stage H не реализуется.

## Что не реализовано в Stage H
- Reactions / crime / alarm / disturbed layer.
- Расширенный reaction-priority FSM.
