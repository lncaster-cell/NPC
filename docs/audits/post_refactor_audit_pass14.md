# Post-refactor runtime audit (pass 14) — Daily Life

## Контекст

- Дата аудита: 2026-05-02.
- Область: `daily_life/dl_worker_inc.nss` (координация `DL_AREA_PASS_MODE_RESYNC` и `DL_AREA_PASS_MODE_WORKER`).
- Фокус: убрать повторные touch одного NPC в том же area tick, когда активен `DL_L_AREA_ENTER_RESYNC_PENDING`.
- Верификация API: использованы только штатные NWScript/NWN2 механизмы local variables (`SetLocalInt`/`GetLocalInt`) без внешних костылей.

## Что изменено

1. Введён lightweight marker на NPC:
   - `DL_L_NPC_AREA_TICK_RESYNC_TOUCH` хранит `DL_GetAreaTick(oArea)` тика, в котором NPC уже прошёл resync-touch.
2. В проходе `DL_AREA_PASS_MODE_RESYNC` marker выставляется сразу после успешного `DL_ProcessResync`.
3. В проходе `DL_AREA_PASS_MODE_WORKER` добавлен skip до `DL_WorkerTouchNpc`, если:
   - area в tier `HOT`,
   - `DL_L_AREA_ENTER_RESYNC_PENDING == TRUE` (resync-window),
   - marker NPC совпадает с текущим `nTickStamp`.
4. Для аудита добавлен счётчик `DL_L_AREA_WORKER_SKIP_RESYNC_TICK` (area-local), который увеличивается на каждый такой skip.

## Почему warm/frozen не ломается

- Логика skip ограничена **только** `DL_AREA_PASS_MODE_WORKER` и только при `HOT + resync pending`.
- `DL_AREA_PASS_MODE_WARM` и любые cold/frozen контуры не используют этот фильтр.
- Базовый anti-duplicate guard `DL_L_NPC_LAST_TOUCH_TICK` сохранён без изменения контракта.

## Замер (следующий pass)

Для режима с включённым `DL_L_AREA_ENTER_RESYNC_PENDING`:

- До правки: повторный touch в тот же tick для части NPC был возможен (resync-pass + worker-pass).
- После правки: повторный touch в тот же tick для этих NPC переводится в skip, фиксируется в `DL_L_AREA_WORKER_SKIP_RESYNC_TICK`.

Ожидаемая метрика на тик в hot area:

- `repeat_touches_before ≈ DL_L_AREA_WORKER_SKIP_RESYNC_TICK`
- `repeat_touches_after = 0` для окна `HOT + resync pending`.

Практический эффект:

- снижение лишних `DL_WorkerTouchNpc` в resync-окне до уровня фактических skip,
- более стабильный расход worker budget в hot area при массовом area-enter.
