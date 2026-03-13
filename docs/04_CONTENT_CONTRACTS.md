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
