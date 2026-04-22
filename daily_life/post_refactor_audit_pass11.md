# Post-refactor runtime audit (pass 11) — Daily Life

## Контекст

- Дата аудита: 2026-04-21.
- Область: `daily_life/dl_city_response_inc.nss` (`DL_CR_GetEpisodeCooldownKey`, `DL_CR_HandleGuardPerception`).
- Фокус: коллизии cooldown-ключей в multiplayer при использовании только `GetTag(oPC)`.
- Подход: только штатные механики NWScript/NWN2 и проверенные функции из NWN Lexicon.

## Найденный риск

### R11-1 (High): shared cooldown между разными PC при одинаковом tag

Симптом:
- Ключи anti-spam (`dl_cr_cd_*` и guard react cooldown) строились на `GetTag(oOffender)`.
- В multiplayer PC часто имеют одинаковый tag (типовой `PLAYER`), что приводило к коллизиям object-local cooldown ключей.
- Итог: incident/cooldown одного игрока мог подавлять реакцию/регистрацию инцидента для другого игрока.

Риск:
- некорректная правоприменительная реакция в crowd-сценах;
- трудно воспроизводимые «пропуски» инцидентов и несогласованность heat/perception поведения.

## Исправление

Минимальная правка:
- `DL_CR_GetEpisodeCooldownKey` теперь в первую очередь использует `GetPCPublicCDKey(oOffender)` для runtime-player;
- fallback сохранён: если ключ пустой, используется `GetTag`, затем `"unknown"`;
- guard reaction cooldown (`dl_cr_guard_react_*`) переиспользует тот же нормализованный helper, чтобы убрать расхождение форматов ключей.

Почему безопасно:
- не меняется модель heat/level/decay;
- меняется только схема именования local-key для anti-spam;
- используется встроенная NWScript/NWN2 функция идентификации игрока без ad-hoc storage.

## Итог

Pass 11 закрывает R11-1: cooldown-ключи больше не коллидируют между разными PC с одинаковым tag, что стабилизирует City Response в multiplayer без изменения внешних контрактов runtime.
