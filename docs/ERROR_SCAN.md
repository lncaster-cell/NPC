# Error Scan Report

Дата: 2026-03-12

## Что проверено

- merge-конфликты (unmerged files + conflict markers);
- маркеры незавершённых правок (`TODO`/`FIXME`/`XXX`/`BUG`);
- синтаксически подозрительные паттерны (`;;`, табы);
- базовый структурный баланс фигурных скобок в `scripts/ambient_life/*.nss`.

## Результат

По выполненным проверкам критических ошибок не обнаружено:

- unmerged-файлы отсутствуют;
- conflict markers отсутствуют;
- маркеры незавершённых правок отсутствуют;
- структурный баланс `{}` корректен во всех `.nss` в `scripts/ambient_life`.

## Ограничения

В окружении отсутствует NWScript-компилятор (`nwnsc`/`nsscomp`), поэтому полноценная компиляционная валидация не выполнена.

## Runtime-диагностика переполнения `AL_RegisterNPC`

Если area registry достиг `AL_MAX_NPCS`, регистрация нового NPC по-прежнему корректно отклоняется (bounded-поведение сохранено), но теперь дополнительно фиксируется диагностический след в area locals:

- `al_reg_overflow_count` — счётчик отказов регистрации из-за переполнения;
- `al_reg_overflow_last_npc_tag` — tag последнего NPC, не попавшего в реестр;
- `al_reg_overflow_sync_tick` — значение `al_sync_tick` в момент переполнения (если tick уже инициализирован).

Практическая интерпретация:

- рост `al_reg_overflow_count` при стабильном `al_npc_count ~= AL_MAX_NPCS` означает систематическое насыщение area;
- часто меняющийся `al_reg_overflow_last_npc_tag` обычно указывает на конкурирующие попытки регистрации множества NPC;
- большое расхождение между текущим `al_sync_tick` и `al_reg_overflow_sync_tick` говорит о том, что событие было в прошлом и, возможно, уже неактуально.

Для debug-сценариев доступен throttled лог в module log при `al_debug > 0` на area (не чаще, чем раз в 50 sync-тиков).

## Runtime-метрики health snapshot (`al_h_*`)

Для диагностики состояния area-loop и регрессий по resync доступны агрегированные locals:

- `al_h_npc_count`, `al_h_tier`, `al_h_slot`, `al_h_sync_tick`;
- `al_h_reg_overflow_count`, `al_h_route_overflow_count`;
- `al_h_recent_resync_mask` (rolling bitmask) и `al_h_recent_resync` (число установленных битов в окне);
- `al_h_resync_window_mask` — маска окна, инициализируется один раз на area и далее используется при каждом сдвиге rolling mask.

Проверка семантики `al_h_recent_resync`:

- значение остаётся производным от `al_h_recent_resync_mask` через popcount и поэтому не меняет поведение маршрутизации/dispatch;
- перенос вычисления window mask из tick-path в init-path не влияет на rolling-сдвиг (`mask = (mask * 2) & window_mask`, затем `| 1` при resync на текущем тикe).

