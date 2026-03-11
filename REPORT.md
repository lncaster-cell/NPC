# Ambient Life — Stage I.1 Report (OnDisturbed Inventory/Theft Foundation)

## Реализовано
- Добавлен отдельный entry script `scripts/ambient_life/al_npc_ondisturbed.nss`, который направляет `OnDisturbed` в новый reaction layer.
- Реализован отдельный bounded runtime path в `scripts/ambient_life/al_react_inc.nss`:
  - чтение контекста через `GetLastDisturbed()`, `GetInventoryDisturbType()`, `GetInventoryDisturbItem()`;
  - классификация disturbance только по canonical inventory типам: `INVENTORY_DISTURB_TYPE_ADDED`, `INVENTORY_DISTURB_TYPE_REMOVED`, `INVENTORY_DISTURB_TYPE_STOLEN`.
- Добавлен отдельный internal event `AL_EVENT_REACT_RESUME` (`3109`) для clean resume/resync после локальной реакции.
- Интеграция выполнена без смешивания с `OnBlocked`: Stage I.0 door-first helper остаётся отдельным в `al_blocked_inc.nss`.

## Runtime state (minimal)
- `al_react_active` — guard активной bounded disturbed-реакции.
- `al_react_type` — тип disturbance (`added`/`removed`/`stolen`).
- `al_react_stage` — служебный marker текущего reaction stage (`disturbed foundation`).
- `al_react_resume_flag` — флаг попытки возврата в route runtime.
- `al_react_last_source` — последний disturbance source (`GetLastDisturbed()`).
- `al_react_last_item` — последний disturbance item (`GetInventoryDisturbItem()`).

## Priority / resume boundary
- При валидном `OnDisturbed` событии ordinary route/activity queue временно прерывается локальным bounded reaction override.
- После реакции runtime идёт по минимальной границе:
  - сначала попытка clean resume текущего route-step (`AL_RouteRoutineResumeCurrent`);
  - при неуспехе — safe resync через `AL_EVENT_RESYNC`.
- Реализация остаётся event-driven, без heartbeat, per-NPC periodic timers и polling retry loops.

## Границы Stage I.1
- `OnDisturbed` трактуется строго как inventory/theft disturbance foundation, не как общий social/noise event.
- Crime/alarm escalation сознательно не реализован в этом этапе и отложен в Stage I.2.
- Stage D/E/F/G/H обычный execution flow и Stage I.0 blocked subsystem сохраняются отдельно.
