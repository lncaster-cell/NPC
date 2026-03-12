# NPC Ambient Life v2 (NWN2)

## Кратко о проекте
NPC Ambient Life v2 — это событийная система симуляции поведения NPC для NWN2 без heartbeat/polling на каждом NPC. Управление логикой выполняется централизованно через area tick и event bus, что снижает нагрузку и упрощает контроль поведения.

## Карточка активностей
**Назначение:** единый набор activity-кодов для рутин и сцен NPC.

**Ключевые группы активностей:**
- Базовые состояния: hidden, wake, sleep, midnight.
- Социальные: agree, angry, sad, cheer, stand_chat, kneel_talk.
- Бытовые/ремесленные: cook, cook_multi, forge, forge_multi, read, sit, dinner.
- Профессии/роли: guard, bartender, barmaid, merchant_multi, thief, assassin.
- Сценические/прочие: dance, flute, drum, guitar, meditate, training.

**Источник кодов:** `scripts/ambient_life/al_acts_inc.nss`.

## Карточка игровых механик
**Что реализовано:**
- Event bus + area registry для маршрутизации событий по NPC в зоне.
- LOD-модель жизненного цикла (FREEZE/WARM/HOT).
- Route cache и bounded progression по рутинам.
- Transition/sleep/activity подсистемы для повседневных сценариев.
- Локальная Crime/Alarm-эскалация в пределах area (civilian/militia/guard split).

**Текущее ограничение:**
- Нет global/world alarm и полноценной legal pipeline (reinforcement/arrest/trial остаются как future extension).

## Техкарточка (кратко)
- **Ядро:** NWScript (`scripts/ambient_life/`).
- **Runtime-модель:** единый `area tick` + `OnUserDefined` события NPC.
- **Ключевые параметры:**
  - `AL_AREA_TICK_SEC = 30.0`
  - `AL_MAX_NPCS = 100`
  - `AL_ROUTE_MAX_STEPS = 16`
- **Документация:**
  - Архитектура: `docs/ARCHITECTURE.md`
  - Контракт toolset: `docs/TOOLSET_CONTRACT.md`
  - Установка: `INSTALLATION.md`
