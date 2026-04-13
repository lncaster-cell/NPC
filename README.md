# PysukSystems (NPC) — README

> Обновлено: **2026-04-11**.

Цель текущего этапа: прекратить рост мета-документации и развивать runtime-код в `daily_life/`.

## ACTIVE DOC SET (только реально существующие файлы)

Основной канонический маршрут:
1. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`
2. `docs/runtime/06_SYSTEM_INVARIANTS.md`
3. `docs/runtime/41_DAILY_LIFE_V2_DESIGN_BASELINE_RU.md`
4. `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
5. `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`

Важно: это **основной маршрут**, но не запрет на использование операционных reference-документов текущего этапа.
Для уточнения acceptance-статуса и фактической рабочей точки также используются:
- `docs/runtime/52_DAILY_LIFE_STEP06_ACCEPTANCE_RUNBOOK_RU.md`
- `docs/runtime/53_DAILY_LIFE_CURRENT_EXECUTION_PLAN_RU.md`
- `docs/runtime/55_DAILY_LIFE_SLEEP_SCENARIO_OWNER_STATUS_RU.md` *(sleep-status source of truth; supersedes archived temporary status)*
- `docs/runtime/12B_DAILY_LIFE_V1_ACCEPTANCE_JOURNAL.md`

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
- [ ] Этот документ не дублирует существующий статус.

## Практическое правило на следующий шаг

Следующие PR должны быть code-first:
- минимум 1 изменение в `daily_life/*.nss`,
- документация правится только как короткая синхронизация в active doc set.

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
DL_ApplyArchiveActivityPresentation(oNpc, DL_DIR_WORK);  // blacksmith -> forge
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

- `DL_ARCH_ACT_NPC_FORGE` + `DL_ARCH_ANIMS_FORGE` для `DL_DIR_WORK` (только профиль `blacksmith`).
- `DL_ARCH_ACT_NPC_SLEEP_BED` + `DL_ARCH_ANIMS_SLEEP_BED` для `DL_DIR_SLEEP`.
- `DL_ARCH_ACT_NPC_MIDNIGHT_BED`, `DL_ARCH_ACT_NPC_MIDNIGHT_90`, `DL_ARCH_ACT_NPC_SLEEP_90` присутствуют как доступные ID-константы reference-слоя, но в текущем skeleton напрямую не назначаются.
