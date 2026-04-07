# Daily Life v1 — Base Map Toolset Setup

Дата: 2026-04-07  
Статус: execution checklist  
Назначение: короткий практический чеклист для включения explicit base-map runtime path в Toolset.

---

## 1) Какие hooks ставить

### На area
- `OnHeartbeat -> scripts/daily_life/dl_area_tick_base_map`

### На NPC
- `OnSpawn -> scripts/daily_life/dl_npc_onspawn_base_map`
- `OnUserDefined -> scripts/daily_life/dl_npc_onud_base_map`
- `OnDeath -> scripts/daily_life/dl_npc_ondeath_base_map`

### Опциональные producer bridges
- `OnPerception -> scripts/daily_life/dl_npc_onperception_base_map`
- `OnPhysicalAttacked -> scripts/daily_life/dl_npc_onphysicalattacked_base_map`
- `OnDamaged -> scripts/daily_life/dl_npc_ondamaged_base_map`
- `OnDisturbed -> scripts/daily_life/dl_npc_ondisturbed_base_map`
- `OnSpellCastAt -> scripts/daily_life/dl_npc_onspellcastat_base_map`

---

## 2) Что должно быть на NPC

### Базовые runtime locals
- `dl_npc_family`
- `dl_npc_subtype`
- `dl_schedule_template`
- `dl_npc_base`

### Рекомендовано для теста
- `dl_named = 1` или `dl_persistent = 1`

---

## 3) Что должно быть на base object

### Базовые
- `dl_base_id`
- `dl_base_kind`
- `dl_base_exterior_area_tag`
- `dl_base_interior_area_tag`
- `dl_base_entry_exterior_tag`
- `dl_base_entry_interior_tag`

### Контекстные
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

## 4) Минимальный пример для кузницы

### NPC
- `dl_npc_family = CRAFT`
- `dl_npc_subtype = BLACKSMITH`
- `dl_schedule_template = EARLY_WORKER`
- `dl_npc_base -> smithy_base_cfg_01`

### Base object `smithy_base_cfg_01`
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

## 5) Ожидаемое поведение

### WORK
- target area -> interior кузницы
- target anchor -> `smithy_forge_01`

### SLEEP
- target area -> interior кузницы
- target anchor -> `smithy_bed_01`

### PUBLIC_PRESENCE
- target area -> exterior city area
- target anchor -> `smithy_street_01`

---

## 6) Что проверять первым

1. NPC получает корректную директиву.
2. Runtime выбирает нужную target area по base map.
3. Runtime находит указанный anchor по tag.
4. Same-area и cross-area постановка проходят без ложного `ABSENT`.
5. После этого уже имеет смысл проверять smoke-сценарии дальше.
