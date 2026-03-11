# Ambient Life — Stage I.1 Report (OnDisturbed Inventory/Theft Foundation)

## Реализовано
- Добавлен отдельный bounded runtime path `OnDisturbed` в `scripts/ambient_life/al_react_inc.nss` + entry script `scripts/ambient_life/al_npc_ondisturbed.nss`.
- Реакция читает disturbance context только через штатные API: `GetLastDisturbed()`, `GetInventoryDisturbType()`, `GetInventoryDisturbItem()`.
- Реализована clean классификация disturbance type: `added`, `removed`, `stolen` (+ bounded `unknown` fallback для нештатного type).
- Ordinary route/activity временно прерывается только локально (bounded override), после чего выполняется resume текущего шага; при неуспехе — safe resync через `AL_EVENT_RESYNC`.
- Stage I.0 `OnBlocked` сохранён как отдельный local navigation helper и не смешивается с новым disturbed layer.

## Runtime state (minimal)
- `al_react_active` — guard от re-entrant disturbed обработки.
- `al_react_type` — классифицированный disturbance type runtime.
- `al_react_resume_flag` — маркер необходимости resume ordinary route.
- `al_react_last_source` — последний валидный disturbance source.
- `al_react_last_item` — последний валидный disturbed item.

## Safeguards / partial context
- Runtime не предполагает, что `GetInventoryDisturbItem()` всегда валиден: при invalid item state сохраняется bounded и не приводит к жёсткой ветке.
- Для creature theft edge-cases (partial/strange context) применяется bounded fallback: без crash-like assumptions, без crime/alarm escalation.
- Placeable/container и creature disturbance поддерживаются единым capture path; override ordinary flow запускается только там, где есть валидный NPC HOT runtime context.

## Границы Stage I.1
- Stage I.1 = только inventory/theft disturbance foundation.
- Crime/alarm propagation, глобальная тревога и social/world simulation сознательно отложены на Stage I.2.
- Архитектурные ограничения сохранены: без heartbeat, без per-NPC periodic timers, без polling loops, без hot-path full-area scans.
