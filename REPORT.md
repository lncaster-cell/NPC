# Ambient Life — Stage I.0 Report (OnBlocked Local Unblock / Door Handling)

## Реализовано
- Добавлен отдельный узкий runtime path `OnBlocked` в `scripts/ambient_life/al_blocked_inc.nss` + entry script `al_npc_onblocked.nss`.
- Реализована door-first политика: при `OnBlocked` сначала проверяется локальный door case через `GetBlockingDoor()`, затем выполняется `ActionOpenDoor(...)` и bounded resume текущего route-step.
- Добавлен отдельный internal event `AL_EVENT_BLOCKED_RESUME` (`3108`) для clean resume-path без polling/heartbeat.
- Добавлен bounded fallback: если local-unblock не удался, выполняется single local retry resume; при неуспехе — safe resync через `AL_EVENT_RESYNC`.

## Runtime state (minimal)
- `al_blocked_rt_active` — guard от re-entrant `OnBlocked` обработки.
- `al_blocked_rt_retry` — bounded retry counter (single retry) перед resync.
- State сбрасывается при старте/очистке route runtime и при успешном route-advance.

## Границы Stage I.0
- `OnBlocked` реализован как local navigation/runtime helper, не как full reaction framework.
- `OnDisturbed` сознательно не реализован и вынесен в Stage I.1.
- Crime/alarm реакции сознательно не реализованы и вынесены в Stage I.2.
- Архитектурные ограничения сохранены: HOT-only runtime, без NPC heartbeat, без per-NPC periodic timers, без polling-based retry loops.
