# Ambient Life v2 — Daily Life v1 Inspection Patch

Дата: 2026-03-20  
Статус: canonical clarification patch  
Назначение: закрыть двусмысленности, найденные при инспекции пакета Daily Life v1, без переписывания всех предыдущих документов. Этот документ имеет приоритет как patch-слой над ранними draft-формулировками, если между ними есть расхождение.

---

## 1) Канонический приоритет документов

Для Daily Life v1 использовать следующий порядок приоритета:

1. `docs/runtime/12B_DAILY_LIFE_V1_INSPECTION_PATCH.md`
2. `docs/runtime/12B_DAILY_LIFE_V1_MILESTONE_A_CHECKLIST.md`
3. `docs/runtime/12B_DAILY_LIFE_V1_IMPLEMENTATION_SLICE.md`
4. `docs/runtime/12B_DAILY_LIFE_V1_RUNTIME_PIPELINE.md`
5. `docs/runtime/12B_DAILY_LIFE_V1_DATA_CONTRACTS.md`
6. `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md`
7. `docs/archive/12B_DAILY_LIFE_V1_RULESET_legacy_2026-03-20.md`
8. `docs/canon/12B_DAILY_LIFE_VNEXT_CANON.md`

Нормативное правило:
- `docs/runtime/12B_DAILY_LIFE_V1_RULESET_REV1.md` считается каноническим ruleset-документом для v1.
- `docs/archive/12B_DAILY_LIFE_V1_RULESET_legacy_2026-03-20.md` — legacy-pointer на ранний черновик; использовать только для исторического контекста, не как source-of-truth.

---

## 2) Единый префикс API

Во всех новых `.nss`-файлах Daily Life v1 использовать единый префикс:

- `DL_`

Примеры:
- `DL_ResolveDirective(...)`
- `DL_RunResync(...)`
- `DL_AreaWorkerTick(...)`
- `DL_RequestFunctionSlotReview(...)`

Нормативное правило:
- обозначения вида `DL_...` в runtime pipeline и data contracts трактовать как концептуальный уровень;
- в реальном NWScript implementation API использовать только `DL_...`.

---

## 3) Кто выбирает activity

Чтобы избежать двусмысленности, в Daily Life v1 зафиксировать следующее разделение ответственности:

### Resolver выбирает только:
- `directive`
- `target_anchor_group`
- `dialogue_mode`
- `service_mode`
- флаги materialization / hide / absent

### Activity layer выбирает:
- `activity_kind`
- конкретную визуальную анимацию

Нормативное правило:
- `selected_activity_kind` в ранних описаниях `DL_ResolverResult` не считать обязательным полем первой реализации;
- если поле пока остаётся в data contracts, трактовать его как optional/deferred и не делать activity responsibility resolver-а.

---

## 4) NWScript-style сигнатуры

Во всех инженерных документах и в коде использовать сигнатуры, максимально близкие к реальному стилю NWScript:

- `object oNPC`
- `object oArea`
- `int nReason`
- `int nDirective`
- `int nAnchorGroup`
- `string sFunctionSlotId`

Нормативное правило:
- абстрактные формы вида `npc_id`, `area`, `reason` считать допустимыми только на conceptual уровне;
- в implementation slice и в реальном коде использовать именно NWScript-style naming.

---

## 5) Жёсткое правило для `BASE_LOST` в Milestone A

В общем ruleset потеря базы может вести к поиску новой базы, уходу или миграции.

Для **Milestone A** фиксируется упрощённое правило:

### Разрешено
- `BASE_LOST -> ABSENT`
- `BASE_LOST -> UNASSIGNED`
- `BASE_LOST -> stub handoff`

### Не разрешено в Milestone A
- полноценный поиск новой базы по городу;
- полноценная миграция между городами;
- rich reassignment logic;
- сложная цепочка переселения persistent NPC.

Нормативное правило:
- полная логика base reassignment откладывается на пост-Milestone A этап.

---

## 6) Жёсткое различие `PUBLIC_PRESENCE` и `SOCIAL`

Чтобы агент не смешал эти директивы, фиксируется следующее:

### `PUBLIC_PRESENCE`
NPC должен быть видим в публичном пространстве, но без выраженной социальной или сервисной активности.

Типичные контексты:
- улица рядом с базой;
- площадь;
- рынок как фон присутствия;
- ожидание / idle в публичной зоне.

### `SOCIAL`
NPC должен находиться в контексте общения или досуга.

Типичные контексты:
- таверна;
- стол/угол разговора;
- drink/talk/idle social animation.

Нормативное правило:
- `PUBLIC_PRESENCE` — это фоновое публичное присутствие;
- `SOCIAL` — это явная социальная активность.

---

## 7) Правило по ruleset duplication

Если агент видит противоречие между:
- `RULESET.md`
- `RULESET_REV1.md`

он обязан принимать сторону `RULESET_REV1.md` и этого patch-документа.

Нормативное правило:
- старый `RULESET.md` не удаляется только ради сохранения истории обсуждения;
- при реализации он не должен иметь равный вес с `REV1`.

---

## 8) Что это меняет для реализации

После этой инспекционной правки реализация Daily Life v1 должна исходить из следующего:
- канонический ruleset = `REV1`;
- единый префикс implementation API = `DL_`;
- resolver не выбирает activity как обязательную часть своего контракта;
- `BASE_LOST` в Milestone A остаётся stub-level случаем;
- `PUBLIC_PRESENCE` и `SOCIAL` различаются жёстко;
- инженерные сигнатуры должны быть ближе к реальному NWScript.

---

## 9) Нормативное резюме

Инспекция не выявила архитектурного провала пакета Daily Life v1.

Пакет в целом пригоден для старта реализации.

Этот patch-документ существует только для того, чтобы:
- убрать остаточную двусмысленность;
- не дать агенту расползтись в naming drift;
- не дать activity снова уехать в resolver;
- не дать `BASE_LOST` раздуть первую итерацию;
- закрепить единый канонический ruleset-файл для кода.
