# Daily Life v1 — Base Context Policy (explicit base map)

Дата: 2026-04-07  
Статус: draft execution note  
Назначение: зафиксировать runtime-политику для баз вида `дом/кузница/таверна` с внешней area, внутренней area и заранее размеченными anchor-point маршрутами.

---

## 1) Главный принцип

Для домов-баз Daily Life не должен угадывать маршрут по шаблону тегов на лету, если контент уже знает правильные exterior/interior точки.

Вместо этого используется **explicit base map**:
- NPC хранит ссылку на base object;
- base object хранит готовую карту `context -> area tag + anchor tag`;
- runtime сначала выбирает target context, затем area, затем anchor.

---

## 2) Что считается base object

Base object — это runtime-конфигурационный объект базы:
- допустимо хранить его на самом доме-placeable;
- допустимо хранить на отдельном invisible/config object;
- допустимо раскладывать часть данных по связанным служебным объектам.

Критично только одно:
- `dl_npc_base` у NPC должен указывать на валидный object, с которого runtime читает карту базы.

---

## 3) Минимальный набор locals на base object

### Базовые
- `dl_base_id`
- `dl_base_kind`
- `dl_base_exterior_area_tag`
- `dl_base_interior_area_tag`
- `dl_base_entry_exterior_tag`
- `dl_base_entry_interior_tag`

### Контекстные маршруты
- `dl_base_work_area_tag`
- `dl_base_work_anchor_tag`
- `dl_base_sleep_area_tag`
- `dl_base_sleep_anchor_tag`
- `dl_base_service_area_tag`
- `dl_base_service_anchor_tag`
- `dl_base_social_area_tag`
- `dl_base_social_anchor_tag`
- `dl_base_public_area_tag`
- `dl_base_public_anchor_tag`
- `dl_base_duty_area_tag`
- `dl_base_duty_anchor_tag`
- `dl_base_gate_area_tag`
- `dl_base_gate_anchor_tag`
- `dl_base_hide_area_tag`
- `dl_base_hide_anchor_tag`

---

## 4) Как runtime читает эту карту

1. Resolver определяет директиву (`WORK`, `SLEEP`, `SERVICE`, `PUBLIC_PRESENCE`, `LOCKDOWN_BASE` и т.д.).
2. Runtime переводит директиву в target anchor group.
3. Base map пытается дать **явную пару**:
   - `area_tag`
   - `anchor_tag`
4. Если явной пары нет, runtime использует fallback:
   - exterior/integrior area по типу директивы;
   - entry anchor как безопасную точку входа.
5. После этого выполняется materialization:
   - same-area -> local path;
   - cross-area -> safe jump/materialization.

---

## 5) Практический пример для кузницы

NPC-кузнец хранит:
- `dl_npc_base -> smithy_base_cfg_01`

На `smithy_base_cfg_01`:
- `dl_base_exterior_area_tag = city_market_01`
- `dl_base_interior_area_tag = smithy_int_01`
- `dl_base_entry_exterior_tag = smithy_ext_entry_01`
- `dl_base_entry_interior_tag = smithy_int_entry_01`
- `dl_base_work_area_tag = smithy_int_01`
- `dl_base_work_anchor_tag = smithy_forge_01`
- `dl_base_sleep_area_tag = smithy_int_01`
- `dl_base_sleep_anchor_tag = smithy_bed_01`
- `dl_base_public_area_tag = city_market_01`
- `dl_base_public_anchor_tag = smithy_street_01`

---

## 6) Что это решает

Этот подход явно закрывает проблему, когда:
- дом существует как placeable во внешней area;
- интерьер вынесен в отдельную area;
- NPC должен работать/спать/прятаться в interior, но появляться/стоять на улице в exterior.

Без explicit base map текущий same-area anchor path даёт слишком много двусмысленностей и заставляет контент угадывать поведение через теги.

---

## 7) Рекомендация по использованию

Для нового runtime-path использовать entry scripts из ветки base-map:
- `dl_area_tick_base_map`
- `dl_npc_onspawn_base_map`
- `dl_npc_onud_base_map`
- `dl_npc_ondeath_base_map`

Они работают через агрегатор `dl_all_base_map_inc` и используют explicit base map policy.
