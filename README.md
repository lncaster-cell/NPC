# PysukSystems (NPC) — README

> Обновлено: **2026-04-14**.

Цель текущего этапа: развивать runtime-код в `daily_life/` и держать документацию синхронизированной с фактическим состоянием `main`.

## ACTIVE DOC SET

Канонический и единственный источник документации проекта:
1. `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`

Важно:
- legacy-структура `docs/canon`, `docs/runtime`, `docs/governance` больше не является активным маршрутом;
- новые архитектурные и runtime-изменения фиксируются в unified-документе;
- при проектировании и правках используем встроенные механики NWN2/NWScript с опорой на NWN Lexicon (без ad-hoc костылей).

## Канонический workspace path

Единый путь разработки runtime: `daily_life/`.

- новые `.nss` файлы и изменения вносятся только сюда;
- ссылки на `scripts/daily_life/` считаются устаревшими;
- документация должна ссылаться на `daily_life/` как на единственный активный путь.

### Правило для авторов: legacy-paths

- **Где legacy-пути допустимы:** только в архивах, исторических отчётах и immutable-журналах (для фиксации факта прошлого состояния).
- **Где legacy-пути недопустимы:** в active set документах, шаблонах и действующих канонах/контрольных панелях.
- **Как писать путь в новых документах:** использовать единый стандарт `daily_life/` (без новых вхождений `scripts/daily_life/` в активных материалах).

### PR-чек-лист для docs

- [ ] Нет новых вхождений `scripts/daily_life/` в active/template документах.

## Практическое правило на следующий шаг

Следующие PR по runtime должны быть code-first:
- минимум 1 изменение в `daily_life/*.nss`;
- документация правится как короткая синхронизация в `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`.

## Daily Life: доступные activity-анимации и игровые константы (как вызывать)

Ниже — фактически доступный в текущем runtime (`daily_life/`) reference-слой activity/animation из `dl_activity_archive_anim_inc.nss`.

### 1) Константы activity ID

```nss
DL_ARCH_ACT_NPC_MIDNIGHT_BED = 4
DL_ARCH_ACT_NPC_SLEEP_BED    = 5
DL_ARCH_ACT_NPC_FORGE        = 15
DL_ARCH_ACT_NPC_MIDNIGHT_90  = 31
DL_ARCH_ACT_NPC_SLEEP_90     = 32
```

### 2) Константы animation set

```nss
DL_ARCH_ANIMS_FORGE     = "craft01, dustoff, forge01"
DL_ARCH_ANIMS_SLEEP_BED = "laydownB, proneB"
```

### 3) Как вызывать в игре (runtime API)

Базовая установка presentation на NPC:

```nss
DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_FORGE, DL_ARCH_ANIMS_FORGE);
DL_SetActivityPresentation(oNpc, DL_ARCH_ACT_NPC_SLEEP_BED, DL_ARCH_ANIMS_SLEEP_BED);
```

Автоматический выбор по директиве (рекомендуемый путь):

```nss
// Проставляет activity/anims внутри resolver-пайплайна:
DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);  // profile-based WORK presentation
DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_SLEEP); // sleep -> sleep_bed
```

Полный runtime-вход (основной вызов):

```nss
// 1) Определить директиву по времени/профилю:
int nDirective = DL_ResolveNpcDirective(oNpc);

// 2) Применить состояние NPC, interaction modes и activity-анимации:
DL_ApplyDirectiveSkeleton(oNpc, nDirective);
```

Прямой запуск sleep-loop анимации:

```nss
DL_PlaySleepAnimation(oNpc); // Берёт 2-й токен из DL_L_NPC_ANIM_SET, fallback на 1-й.
```

### 4) Что реально используется сейчас в skeleton

- `DL_ARCH_ACT_NPC_FORGE` + `DL_ARCH_ANIMS_FORGE` для `DL_DIR_WORK` (профиль `blacksmith`, `work_kind=forge`).
- `DL_ARCH_ACT_NPC_FORGE_MULTI` + `DL_ARCH_ANIMS_CRAFT` для `DL_DIR_WORK` (профиль `blacksmith`, не-forge фазы).
- `DL_ARCH_ACT_NPC_FORGE_MULTI` + `DL_ARCH_ANIMS_DOMESTIC` для `DL_DIR_WORK` (профиль `domestic_worker`).
- `DL_ARCH_ACT_NPC_SLEEP_BED` + `DL_ARCH_ANIMS_SLEEP_BED` для `DL_DIR_SLEEP`.
- `DL_ARCH_ACT_NPC_MIDNIGHT_BED`, `DL_ARCH_ACT_NPC_MIDNIGHT_90`, `DL_ARCH_ACT_NPC_SLEEP_90` присутствуют как доступные ID-константы reference-слоя, но в текущем skeleton напрямую не назначаются.

### 5) Полная таблица доступных animation tokens (archive reference)

> Источник: `docs/archive/ambientlivev2-stable/scripts/al_acts_inc.nss` (`AL_GetLocateWrapperCustomAnims`, `AL_GetActivityCustomAnims`).

| Animation token | Краткое описание |
|---|---|
| `*1attack01` | Базовая атака (анимация удара №1). |
| `bored` | Скучающая стойка/жест. |
| `bow` | Поклон. |
| `chuckle` | Небольшой смешок. |
| `clapping` | Аплодисменты. |
| `cooking01` | Готовка, вариант 1. |
| `cooking02` | Готовка, вариант 2. |
| `craft01` | Ремесленное действие/крафт. |
| `curtsey` | Реверанс. |
| `dance01` | Танец, вариант 1. |
| `dance02` | Танец, вариант 2. |
| `disablefront` | Работа с механизмом/ловушкой спереди. |
| `disableground` | Работа с объектом/ловушкой у земли. |
| `dustoff` | Смахнуть пыль/очистить руки. |
| `flirt` | Флиртующий жест. |
| `forge01` | Ковка, вариант 1. |
| `forge02` | Ковка, вариант 2. |
| `getground` | Поднять предмет с земли. |
| `gettable` | Взять предмет со стола/поверхности. |
| `intimidate` | Угрожающая/запугивающая подача. |
| `kneeldown` | Встать на колено (фаза опускания). |
| `kneelidle` | Поза на коленях (idle). |
| `kneeltalk` | Разговор в позе на коленях. |
| `kneelup` | Подъём с колен. |
| `laydownB` | Лечь (вариант B). |
| `lookleft` | Посмотреть влево. |
| `lookright` | Посмотреть вправо. |
| `meditate` | Медитация. |
| `nodno` | Жест «нет». |
| `nodyes` | Жест «да». |
| `openlock` | Взлом/открытие замка. |
| `playdrum` | Игра на барабане. |
| `playflute` | Игра на флейте. |
| `playguitar` | Игра на гитаре/лютне. |
| `proneB` | Положение лёжа (вариант B). |
| `scratchhead` | Почесать голову (озадаченность). |
| `shrug` | Пожимание плечами. |
| `sigh` | Вздох. |
| `sitdrink` | Сидя: пить. |
| `siteat` | Сидя: есть. |
| `sitfidget` | Сидя: ёрзать/смена позы. |
| `sitidle` | Сидя: спокойный idle. |
| `sitread` | Сидя: чтение. |
| `sittalk` | Сидя: разговор (базовый). |
| `sittalk01` | Сидя: разговор, вариант 1. |
| `sittalk02` | Сидя: разговор, вариант 2. |
| `sitteat` | Сидя: приём пищи (альтернативный токен). |
| `sleightofhand` | Ловкость рук/карманные манипуляции. |
| `sneak` | Скрытное передвижение/крадущаяся поза. |
| `talk01` | Разговор, вариант 1. |
| `talk02` | Разговор, вариант 2. |
| `talklaugh` | Разговор со смехом. |
| `talksad` | Печальная манера речи. |
| `talkshout` | Крик/повышенный тон в разговоре. |
| `tired` | Уставшая поза/жест. |
| `victory` | Жест победы/триумфа. |
| `yawn` | Зевок. |
