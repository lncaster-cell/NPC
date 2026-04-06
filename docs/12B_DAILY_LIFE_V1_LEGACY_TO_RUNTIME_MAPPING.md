# Daily Life v1 — Legacy (`al_*`) to Runtime (`dl_*`) Mapping

Дата: 2026-04-06  
Статус: active  
Назначение: единая таблица соответствий для чтения старых design/аудит документов, где встречаются `scripts/ambient_life/al_*`.

## 1) Правило чтения старых документов

- Если в старом документе указан `scripts/ambient_life/al_*.nss`, ориентироваться на таблицу ниже.
- Простое переименование `al_ -> dl_` **не является универсальным правилом**: часть legacy-файлов объединена, часть возвращена как отдельные thin entrypoints в рамках event-driven NPC hook layer.
- При споре приоритет у фактического runtime-каталога `scripts/daily_life/*.nss` и актуальных SoT-доков (`12B`, `07`, `22`).

## 2) Mapping-таблица

| Legacy name | Текущий runtime-файл | Статус | Комментарий |
|---|---|---|---|
| `al_activity_inc.nss` | `dl_activity_inc.nss` | implemented | Прямое соответствие |
| `al_area_inc.nss` | `dl_area_inc.nss` | implemented | Прямое соответствие |
| `al_area_tick.nss` | `dl_area_tick.nss` | implemented | Прямое соответствие |
| `al_schedule_inc.nss` | `dl_schedule_inc.nss` | implemented | Прямое соответствие |
| `al_area_onenter.nss` | `dl_area_enter.nss` | renamed | Хук переименован |
| `al_area_onexit.nss` | `dl_area_exit.nss` | renamed | Хук переименован |
| `al_core_inc.nss` | `dl_worker_inc.nss` | merged | Ядро/оркестрация объединены |
| `al_dispatch_inc.nss` | `dl_worker_inc.nss` | merged | Dispatch-контур объединён в worker |
| `al_registry_inc.nss` | `dl_worker_inc.nss` | merged | Registry-слой объединён |
| `al_lookup_cache_inc.nss` | `dl_worker_inc.nss` | merged | Cache-часть объединена |
| `al_events_inc.nss` | `dl_types_inc.nss` | merged | Event/types слой консолидирован |
| `al_route_inc.nss` | `dl_schedule_inc.nss` | merged | Route-путь объединён с расписанием |
| `al_route_cache_inc.nss` | `dl_schedule_inc.nss` | merged | Route cache слит в schedule/resolver контур |
| `al_route_runtime_api_inc.nss` | `dl_schedule_inc.nss` | merged | API-слой маршрутов объединён |
| `al_transition_inc.nss` | `dl_resolver_inc.nss` | merged | Transition-проверки в resolver |
| `al_transition_post_area.nss` | `dl_resync_inc.nss` | merged | Post-transfer в resync |
| `al_sleep_inc.nss` | `dl_activity_inc.nss` | merged | Sleep execution в activity pipeline |
| `al_acts_inc.nss` | `dl_activity_inc.nss` | merged | Activity helper объединён |
| `al_blocked_inc.nss` | `dl_resolver_inc.nss` | merged | Blocked recovery в resolver |
| `al_react_inc.nss` | `dl_resolver_inc.nss` | merged | Reactive слой объединён |
| `al_city_crime_inc.nss` | `dl_resolver_inc.nss` | merged | Crime handling объединён в resolver/override |
| `al_city_alarm_inc.nss` | `dl_override_inc.nss` | merged | Alarm override вынесен отдельно |
| `al_city_population_inc.nss` | `dl_area_inc.nss` | merged | Population/runtime hooks в area/runtime слое |
| `al_city_registry_inc.nss` | `dl_area_inc.nss` | merged | City registry объединён |
| `al_health_inc.nss` | `dl_log_inc.nss` | merged | Diagnostics/health унифицированы |
| `al_action_signal_ud.nss` | `dl_interact_inc.nss` | merged | Сигналы взаимодействия объединены |
| `al_action_set_mode.nss` | `dl_override_inc.nss` | merged | Set-mode переведён в override |
| `al_npc_onspawn.nss` | `dl_npc_onspawn.nss` | implemented | Возвращён как thin lifecycle/bootstrap hook |
| `al_npc_onud.nss` | `dl_npc_onud.nss` | implemented | Центральный NPC event dispatcher |
| `al_npc_onblocked.nss` | `dl_resolver_inc.nss` | merged | Blocked hook объединён |
| `al_npc_ondisturbed.nss` | `dl_npc_ondisturbed.nss` | implemented | Lightweight producer bridge |
| `al_npc_ondamaged.nss` | `dl_npc_ondamaged.nss` | implemented | Lightweight producer bridge |
| `al_npc_onphysicalattacked.nss` | `dl_npc_onphysicalattacked.nss` | implemented | Lightweight producer bridge |
| `al_npc_onspellcastat.nss` | `dl_npc_onspellcastat.nss` | implemented | Lightweight producer bridge |
| `al_npc_ondeath.nss` | `dl_npc_ondeath.nss` | implemented | Thin cleanup/deregister hook |
| `al_mod_onleave.nss` | `dl_on_load.nss` | dropped | Отдельный модульный hook снят |
| `al_debug_inc.nss` | `dl_log_inc.nss` | merged | Logging/diag слой объединён |
| `al_react_apply_step.nss` | `—` | dropped | Отдельный шаг больше не выделяется как файл |
| `al_react_resume_reset.nss` | `—` | dropped | Resume/reset интегрирован в resync/resolver |

## 3) Последняя валидация

- Последняя проверка каталога runtime: **2026-04-06**.
- Базовый runtime-контур: `scripts/daily_life/`.
- Обязательный NPC-side lifecycle/event слой для текущего runtime: `dl_npc_onspawn`, `dl_npc_onud`, `dl_npc_ondeath`.
