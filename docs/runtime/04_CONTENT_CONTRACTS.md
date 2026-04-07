# Ambient Life v2 — Content Contracts

## 1. NPC locals
### Обязательные контентные
- `alwp0..alwp5` — route tags по слотам суток.
- `al_default_activity` — дефолтная активность.

### Опциональные/legacy
- `AL_WP_S0..AL_WP_S5` — fallback route tags.
- `al_npc_role` — role hint (`0` civilian, `1` militia, `2` guard/enforcer).
- `al_safe_wp_tag` — waypoint для fallback-run в тревоге.

## 2. Area locals
- `al_link_count`, `al_link_0..N` — linked graph.
- `al_city_id`, `al_city_district_type` — city layer принадлежность.
- Дополнительно: city point tags (`al_city_bell_tag`, `al_city_arsenal_tag`, `al_city_shelter_tag`, `al_city_war_post_tag_<idx>`).

## 3. Sleep/route contracts
- Sleep route-step маркируется `al_bed_id`.
- Индексация route-step (`al_step`) последовательная, без пропусков.
- Все referenced tags обязаны существовать в соответствующей area.

## 4. Runtime locals (ручное редактирование запрещено)
- Счётчики очередей/overflow/диагностики.
- Курсоры, индексы, reverse-index структуры registry.
- City alarm runtime состояние и assignment locals.

## 5. Событийные hooks (обзор)
- Producers: `OnDisturbed`, `OnPhysicalAttacked`, `OnDamaged`, `OnDeath`, `OnSpellCastAt`.
- Runtime-dispatch: `OnUserDefined` для внутренних assignment/event сигналов.

## 6. Правила качества контента
- Нет битых route/waypoint tags.
- Нет конфликтующих/дублированных linked-area записей.
- Legacy-поля допускаются только как fallback, не как основной источник данных.


## 7. Respawn population contracts
### Area locals (контент/конфиг)
- `al_city_respawn_tag` или `al_city_respawn_tag_<idx>` + `al_city_respawn_node_count` — разрешённые respawn nodes.
- `al_city_respawn_resref` — area-level шаблон респауна (опционально).
- `al_city_respawn_cooldown_ticks` — минимальный интервал между респаунами (опционально).
- `al_city_respawn_budget_regen_ticks` — период восстановления бюджета (опционально).
- `al_city_respawn_safe_dist` — безопасная дистанция от игроков для спавна (опционально).

### NPC locals (классификация)
- `al_population_named` / `al_is_named` — источник признака named NPC.
- `al_population_is_named`, `al_population_classified`, `al_population_alive_registered` — runtime метки population-layer.

### City/module runtime keys (через city key)
- `population_target_named`, `population_target_unnamed`
- `population_alive_named`, `population_alive_unnamed`
- `population_deficit_unnamed`
- `population_respawn_budget`, `population_respawn_budget_max`, `population_respawn_budget_initialized`
- `population_last_respawn_tick`, `population_budget_last_regen_tick`
- `population_respawn_resref`
