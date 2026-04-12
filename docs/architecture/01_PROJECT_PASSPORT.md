# Ambient Life v2 — Project Passport (вспомогательная карта границ)

Дата: 2026-03-15  
Статус: вспомогательный архитектурный документ (не обзорный вход, не source of truth)

---

## 1) Роль документа

`01_PROJECT_PASSPORT.md` нужен только как **карта границ между доменами** и как quick-check против смешения масштабов.

Он:
- не заменяет `README.md`;
- не заменяет `docs/canon/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`;
- не заменяет `docs/entry/01_PROJECT_OVERVIEW.md`;
- не дублирует нормативную детализацию `12A–12E`, `13`, `14`.

Если нужна общая картина проекта, открывается `17`, а не этот паспорт.

---

## 2) Мини-карта доменов и источников канона

| Домен | Граница (что это) | Primary SoT |
|---|---|---|
| NPC Daily Life | Штатная рутина NPC: schedule/route/sleep/activity и локальные отклонения | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` |
| City Response | Оперативный городской ответ на инцидент (alarm/escalation/de-escalation) | `docs/runtime/12B_RUNTIME_MASTER_PLAN.md` |
| Legal / Witness / Crime | Нормативная квалификация, свидетели, преступления, правовой lifecycle | `docs/canon/12A_WORLD_MODEL_CANON.md` |
| Player Property | Личное/клановое/публичное владение и права доступа | `docs/canon/12C_PLAYER_PROPERTY_SYSTEM.md` |
| World Travel | Межрегиональная связность, land/sea маршруты, travel-state | `docs/canon/12D_WORLD_TRAVEL_CANON.md` |
| Trade / City State | Макроустойчивость города, supply/deficit/crisis | `docs/canon/12E_TRADE_AND_CITY_STATE_CANON.md` |
| Clans | Политико-социальные клановые сущности и последствия | `docs/canon/14_CLAN_SYSTEM_DESIGN.md` |
| Aging / Succession | Старение, смерть, наследование и смена поколений | `docs/canon/13_AGING_AND_CLAN_SUCCESSION.md` |

---

## 3) Ключевые границы (anti-confusion)

- **Daily Life vs City Response:** штатная повседневность vs режим реагирования на инцидент.
- **City Response vs Legal:** исполнение «здесь и сейчас» vs нормативная легитимность и квалификация.
- **Property vs Camp:** camp — класс/режим использования в property-системе, а не отдельный правовой домен.
- **Local Movement vs World Travel:** внутри-area роутины vs межрегиональные переходы.
- **Trade/City-State vs Runtime Population:** долгие макрошкалы города vs краткая оперативная проекция в runtime.
- **Personal vs Clan vs Public Ownership:** разные режимы права, не взаимозаменяемые ярлыки.
- **Player Clan vs NPC Clans:** детализированный персистентный прогресс игрока vs фасадные NPC-сущности мира.

---

## 4) Что не является отдельным доменом

- **Camp** — связующий сценарный слой между property / travel / clan-assets внутри канона собственности.
- **Respawn** — policy-проекция runtime и city-state, а не самостоятельная «мировая экономика».
- **Witness** — часть legal/crime lifecycle, не изолированный модуль сам по себе.

---

## 5) Как использовать паспорт

Использование узкое:
1. Открыть после `17`, если нужно проверить границу доменов.
2. Перейти в primary SoT конкретного домена для нормативки.
3. Не расширять этот файл до обзорного master-документа.
