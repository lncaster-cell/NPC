# Каталог механик и сценариев Ambient Life v2
<!-- DOCSYNC:2026-03-12 -->
> Documentation sync: 2026-03-12. This file was reviewed and aligned with the current repository structure.


Документ фиксирует **все реализованные на текущий момент механики** и **доступные сценарии поведения**, которые уже запрограммированы в системе.

## 1. Механика временных слотов (6 слотов по 4 часа)

1. В сутках используется 6 слотов по 4 часа: слот вычисляется как `GetTimeHour() / 4`.
2. Для каждого слота у NPC задаётся маршрут через `alwp0..alwp5` (или legacy `AL_WP_S0..AL_WP_S5`).
3. При переходе слота система шлёт событие `AL_EVENT_SLOT_0..5`, а NPC переключаются на новый маршрут.
4. При `RESYNC` NPC принудительно выравниваются по текущему слоту area.

### Сценарии
- Сценарий A: NPC живёт по 6 разным маршрутам в течение суток (утро/день/вечер/ночь и т.д.).
- Сценарий B: NPC имеет одинаковый route tag во всех `alwp0..alwp5` и фактически работает по «постоянному распорядку».
- Сценарий C: после входа игрока в area выполняется `RESYNC`, и NPC сразу переходят в корректное состояние текущего слота.

## 2. Механика area-centric lifecycle (FREEZE/WARM/HOT)

1. Симуляция считается на уровне area, а не heartbeat каждого NPC.
2. HOT: активная симуляция и dispatch событий NPC.
3. WARM: облегчённое удержание контекста без полного активного прогона.
4. FREEZE: тик/симуляция отключаются, runtime token инвалидирует старые циклы.
5. Поддерживается linked-area warm retention через `al_link_count`, `al_link_0..N`.

### Сценарии
- Сценарий A: в area есть игрок → tier HOT → NPC активно ходят по рутине.
- Сценарий B: игрок ушёл, но есть связанная активная area → tier WARM.
- Сценарий C: нет игроков и нет warm-оснований → tier FREEZE.
- Сценарий D: возврат из FREEZE/HOT вызывает пересбор и `RESYNC`.

## 3. Механика реестра NPC в area (плотный registry)

1. NPC регистрируются в `al_npc_0..N` с `al_npc_count`.
2. Удаление/очистка невалидных записей делается через swap-remove.
3. Ограничение: максимум `AL_MAX_NPCS = 100` NPC на area.

### Сценарии
- Сценарий A: валидные NPC получают события шины через area registry.
- Сценарий B: невалидный/ушедший NPC автоматически вычищается при dispatch.
- Сценарий C: при переполнении реестра дополнительные NPC не регистрируются.

## 4. Механика event bus

1. События слотов: `3100..3105`.
2. `3106` — `RESYNC`.
3. `3107` — `ROUTE_REPEAT` (контролируемый повтор шага/продвижения).
4. `3108` — `BLOCKED_RESUME` (возврат после локального recovery).

### Сценарии
- Сценарий A: смена слота переводит NPC на новый маршрут.
- Сценарий B: route-step может запланировать контролируемый повтор без бесконечного цикла.
- Сценарий C: после block-события NPC пробует безопасно вернуться в routine.

## 5. Механика route cache и bounded routine progression

1. Route выбирается по slot tag и кешируется.
2. Лимит шагов маршрута: `AL_ROUTE_MAX_STEPS = 16`.
3. Продвижение по шагам bounded (без unbounded-loop поведения).
4. При проблемах маршрута используется fallback-ветка.

### Сценарии
- Сценарий A: корректный маршрут с шагами `0..N` выполняется по порядку.
- Сценарий B: route tag пустой/битый — NPC уходит в fallback, а не зависает.
- Сценарий C: превышение 16 шагов фиксируется как overflow и не уронит runtime.

## 6. Механика transition subsystem

1. Поддержаны transition-step двух типов:
   - `al_trans_type = 1`: area helper,
   - `al_trans_type = 2`: intra-area teleport.
2. После перехода запускается controlled route repeat.

### Сценарии
- Сценарий A: NPC переходит по helper-маршруту между контентными точками.
- Сценарий B: NPC телепортируется внутри area в нужный узел рутины.
- Сценарий C: после transition NPC возвращается в обычное bounded продвижение.

## 7. Механика sleep subsystem

1. Sleep-step активируется через `al_bed_id`.
2. Для bed-id ожидаются waypoint-и `{bed}_approach` и `{bed}_pose`.
3. Поддержаны sleep-коды активностей (`MIDNIGHT_BED`, `SLEEP_BED`, `MIDNIGHT_90`, `SLEEP_90`).
4. При неполной разметке есть fallback-поведение.

### Сценарии
- Сценарий A: NPC подходит к кровати и занимает позу сна по bed-точкам.
- Сценарий B: отсутствует часть sleep-точек — NPC не ломает цикл и обрабатывается fallback.
- Сценарий C: ночью слот ведёт NPC в sleep-рутину, утром — в wake/day routine.

## 8. Механика activity subsystem

1. Каждый шаг маршрута может задавать `al_activity` и `al_dur_sec`.
2. Если `al_activity` не задан, используется `al_default_activity` NPC.
3. Поддержан канонический набор activity-кодов (включая социальные/рабочие/боевые/sleep).
4. Для активностей доступны custom/numeric animations и базовые behavioral-профили (sit/guard/social/work/idle).

### Сценарии
- Сценарий A: NPC на шаге садится/читает/дежурит в зависимости от activity-кода.
- Сценарий B: NPC играет custom animation token (включая циклические анимации).
- Сценарий C: при отсутствии спец-анимации применяется базовый режим ожидания.

## 9. Механика OnBlocked recovery (Stage I.0)

1. При `OnBlocked` запускается локальное bounded-восстановление.
2. После recovery NPC получает `BLOCKED_RESUME`.
3. Если resume неудачен, выполняется reset + `RESYNC`.

### Сценарии
- Сценарий A: NPC временно упёрся в препятствие и успешно продолжил шаг.
- Сценарий B: NPC не смог продолжить — route runtime сбрасывается и пересинхронизируется.

## 10. Механика OnDisturbed foundation + crime/alarm (Stage I.1/I.2)

1. Поддержаны disturb-типы: `ADDED`, `REMOVED`, `STOLEN`, `UNKNOWN`.
2. Классификация инцидента: `none`, `suspicious`, `theft`, `hostile-legal`.
3. Учитываются признаки: источник, предмет, witness, allow/owner policy.
4. Есть actor-local и area-local debounce (anti-spam повторов).
5. Area-alarm хранится в `al_alarm_state`, `al_alarm_until`, `al_alarm_source`.
6. Есть bounded fan-out на nearby NPC (радиус 18.0, до 8 responders).
7. Scope строго area-local: нет world scan/global alarm/spawn reinforcements.

### Сценарии
- Сценарий A: `ADDED` в инвентарь — инцидент игнорируется как crime (`none`).
- Сценарий B: `REMOVED/UNKNOWN` с неразрешённым источником/свидетелем — `suspicious`.
- Сценарий C: `STOLEN` + есть source+item+witness + неразрешённый доступ — `theft`.
- Сценарий D: guard при theft может поднять уровень до `hostile-legal`.
- Сценарий E: повторные одинаковые инциденты в debounce-окне подавляются.
- Сценарий F: по тревоге зовутся nearby responders в той же area.

## 11. Механика role-based response (civilian/militia/guard)

1. Роль NPC задаётся `al_npc_role`:
   - `0` civilian,
   - `1` militia,
   - `2` guard.
2. Поведение при crime:
   - civilian: крик + попытка уйти в safe waypoint / retreat,
   - militia: прямая атака источника,
   - guard: `Stop!`/сближение либо атака по legal/hostility/faction условиям.
3. Для guard выставляется future-hook `al_legal_followup_pending`.

### Сценарии
- Сценарий A: мирный NPC убегает к `al_safe_wp` или ближайшей safe-точке.
- Сценарий B: militia сразу вступает в бой с нарушителем.
- Сценарий C: guard атакует при hostile/legal условиях, иначе перехватывает нарушителя.

## 12. Механика возврата к routine после реакций

1. Реакция ставит временный override и затем очищает runtime-флаги.
2. Если NPC был в активной routine, выполняется `resume` текущего шага.
3. Если resume не удалось — reset blocked-runtime + `RESYNC`.

### Сценарии
- Сценарий A: NPC прерывает routine из-за инцидента и затем корректно возвращается.
- Сценарий B: после неудачного возврата NPC безопасно пересинхронизируется, не зависая в react-состоянии.

## 13. Границы реализованных сценариев (что уже есть и чего ещё нет)

### Уже реализовано
- Полный цикл Stage A–I.2: slot routing, transitions, sleep, activities, blocked/disturbed recovery, local crime/alarm.
- Local legal hostility для guard-path через встроенные faction/hostility правила NWN2.

### Пока не реализовано (запланировано на I.3+)
- Guard spawn/reinforcements.
- Surrender/arrest/trial pipeline.
- Глобальная (меж-area/мировая) тревога.

## 14. QA health-пороги для диагностических сценариев

Пороговые критерии применяются к runtime-snapshot locals `al_h_*` и используются как быстрый smoke-check.

### Базовый штатный режим (валидный контент, без стресса)
- `al_h_reg_overflow_count = 0`.
- `al_h_route_overflow_count = 0`.
- `al_h_npc_count <= AL_MAX_NPCS (100)`.
- `al_h_recent_resync` обычно низкий (`0..1` в окне 8 тиков), без постоянного роста каждый тик.

### После входа игрока в area (ожидаемый HOT/resync)
- в течение 1-2 тиков: `al_h_tier = 2` (HOT).
- `al_h_slot` соответствует `GetTimeHour()/4`.
- `al_h_recent_resync >= 1` в ближайшем окне (подтверждение факта недавнего `RESYNC`).

### При выходе игроков и warm-retention
- `al_h_tier` переходит в `1` (WARM), затем в `0` (FREEZE) при отсутствии оснований для прогрева.
- overflow-счётчики не должны расти только из-за lifecycle-переходов.

### Debug-диагностика
- при `al_debug > 0` ожидается delta-only лог `[AL][AreaHealthDelta]`.
- отсутствие изменений метрик не должно создавать новый health-log шум.
