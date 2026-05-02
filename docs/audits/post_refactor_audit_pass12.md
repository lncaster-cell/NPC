# Post-refactor runtime audit (pass 12) — Daily Life

## Контекст

- Дата аудита: 2026-05-02.
- Область: `daily_life/dl_city_response_inc.nss` (`DL_CR_GetOffenderIdentityKey`).
- Фокус: соответствие runtime-кода и задокументированного identity fallback-chain для multiplayer cooldown keys.
- Подход: только встроенные механики NWScript/NWN2 и documented API-паттерн из NWN Lexicon для `GetPCPublicCDKey`.

## Найденный риск

### R12-1 (Medium): дрейф между документацией и кодом в вызове `GetPCPublicCDKey`

Симптом:
- В статусе разработки зафиксирован канонический chain `GetPCPublicCDKey(..., TRUE) -> ObjectToString -> tag/unknown`.
- В runtime-коде использовался вызов `GetPCPublicCDKey(oOffender)` без второго аргумента.

Риск:
- неоднозначность поведения между shard/server-профилями, где значение опционального параметра может отличаться от ожидаемого контракта;
- сопровождение усложняется: документация утверждает одно, код исполняет другое.

## Исправление

Минимальная правка:
- В `DL_CR_GetOffenderIdentityKey` вызов обновлён на `GetPCPublicCDKey(oOffender, TRUE)`.
- Остальная fallback-цепочка (`ObjectToString -> tag -> "unknown"`) и downstream-cooldown формирование не изменялись.

Почему безопасно:
- меняется только источник identity-ключа в уже существующей ветке runtime-player;
- структура anti-spam/local-key протокола и семантика heat/legal контуров остаются прежними;
- правка устраняет документарно-кодовой drift без изменения внешних API контракта include.

## Итог

Pass 12 закрывает R12-1: код синхронизирован с каноническим identity fallback-contract, что уменьшает риск platform/profile-неоднозначности и упрощает дальнейшие аудиты City Response.
