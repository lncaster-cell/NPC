# Post-refactor runtime audit (pass 13) — Daily Life

## Контекст

- Дата аудита: 2026-05-02.
- Область: `daily_life/dl_city_response_inc.nss` (`DL_CR_GetOffenderIdentityKey`) и audit/docs после pass 12.
- Фокус: compile-совместимость с NWN2 сигнатурой `GetPCPublicCDKey`.
- Верификация: сверка с NWN Lexicon и NWN2 function-reference (NWN2Wiki) по поддерживаемой сигнатуре.

## Найденный риск

### R13-1 (High): несовместимый вызов `GetPCPublicCDKey(oPlayer, TRUE)` для NWN2

Симптом:
- После pass 12 в коде использовался двухаргументный вызов `GetPCPublicCDKey(oOffender, TRUE)`.
- Для NWN2 поддерживается сигнатура `GetPCPublicCDKey(object oPlayer)`; дополнительный параметр относится к NWN1/NWScript-веткам и в NWN2 не является штатным.

Риск:
- compile/import ошибка скриптового include в NWN2 toolset/runtime;
- блокирующий regression для сборки модуля.

## Исправление

Минимальная правка:
- В `DL_CR_GetOffenderIdentityKey` возвращён совместимый вызов `GetPCPublicCDKey(oOffender)`.
- Identity fallback-chain сохранён: `GetPCPublicCDKey` -> `ObjectToString` -> `GetTag` -> `"unknown"`.
- Документация синхронизирована с фактическим NWN2-контрактом.

Почему безопасно:
- используется штатная NWN2 функция в её валидной сигнатуре;
- не меняется остальная логика anti-spam/cooldown;
- устраняется потенциальный compile-break без изменения внешнего поведения City Response.

## Итог

Pass 13 закрывает R13-1: runtime-код и документация снова согласованы с NWN2 API-контрактом, исключён риск некомпилируемого include после предыдущего pass.
