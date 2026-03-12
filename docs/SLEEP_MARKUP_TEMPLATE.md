# Sleep markup: контентный шаблон и checklist

Этот гайд фиксирует каноническую разметку sleep-точек для Ambient Life.

## 1) Что задаётся на route-step

Для шага маршрута, который должен запускать sleep-рутину, проставьте:

- `al_step` — обычный индекс шага в route (`0..N` без пропусков).
- `al_bed_id` — идентификатор sleep-пары (например `inn_room_02_bed_a`).
- опционально `al_dur_sec` — длительность сна в секундах.

> В runtime sleep-step определяется именно по `al_bed_id`.

## 2) Какие waypoint-теги обязательны

Для каждого `al_bed_id=<BED>` в **той же area** должен существовать полный набор:

- `<BED>_approach`
- `<BED>_pose`

Пример:

- `al_bed_id = dock_barracks_bed_03`
- обязательные waypoint-и:
  - `dock_barracks_bed_03_approach`
  - `dock_barracks_bed_03_pose`

## 3) Инварианты, которые валидируются preflight

`python3 scripts/ambient_life/al_route_preflight.py` проверяет sleep-инварианты:

1. Наличие обеих точек пары для каждого sleep-step (`sleep_pair_point_missing`).
2. Консистентность `al_bed_id` и sleep-waypoint tag (`sleep_bed_id_tag_mismatch`).
3. Area-consistency:
   - один и тот же `al_bed_id` не должен использоваться в нескольких area (`sleep_bed_area_inconsistency`),
   - sleep-waypoint (`*_approach`/`*_pose`) не должен повторяться между area (`sleep_waypoint_area_inconsistency`).

При любой ошибке уровня `ERROR` запуск сценариев блокируется preflight-gate до исправления контента.

## 4) Быстрый шаблон JSON для оффлайн-проверки

```json
[
  {
    "area_tag": "city_inn_floor1",
    "route_tag": "inn_guest_night",
    "waypoint_tag": "inn_guest_sleep_step",
    "al_step": 2,
    "al_bed_id": "inn_room_02_bed_a"
  },
  {
    "area_tag": "city_inn_floor1",
    "route_tag": "inn_guest_night",
    "waypoint_tag": "inn_room_02_bed_a_approach",
    "al_step": 3
  },
  {
    "area_tag": "city_inn_floor1",
    "route_tag": "inn_guest_night",
    "waypoint_tag": "inn_room_02_bed_a_pose",
    "al_step": 4
  }
]
```

## 5) Рекомендации по именованию

- Держите `al_bed_id` глобально уникальным в рамках проекта (минимум — уникальным по area).
- Используйте стабильный префикс area/здания: `<area>_<room>_<bed>`.
- Не переиспользуйте один и тот же `*_approach`/`*_pose` tag между разными area.
