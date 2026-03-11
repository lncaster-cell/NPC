# Ambient Life — Текущий аудит (после синхронизации документации)

## Что подтверждено

1. **Event bus и runtime константы согласованы**: слот-события, RESYNC, ROUTE_REPEAT, BLOCKED_RESUME используют диапазон `3100..3108`.
2. **Area runtime действительно tier-based**: FREEZE/WARM/HOT c linked-area warm retention.
3. **Реестр NPC ограничен и компактен**: cap 100, swap-remove, compaction при lifecycle-операциях.
4. **Stage I.0 и I.1 разделены корректно**: blocked-путь и disturbed-путь независимы, но оба интегрированы в route resume/resync.

## Риски, которые остаются

1. **Тихий отказ регистрации при переполнении**
   - Симптом: NPC > 100 в area не входят в runtime-поток.
   - Риск: «часть NPC живёт, часть — нет» без явного сигнала.

2. **Контентная уязвимость маршрутов**
   - Неполные/ошибочные waypoint locals приводят к fallback в idle.
   - Особенно критично для transition/sleep шагов.

3. **Disturbed foundation без социального слоя**
   - I.1 сознательно не эскалирует тревогу/преступление.
   - Требуется I.2 для полного геймплейного поведения.

## Рекомендации

- Ввести lightweight debug/telemetry hooks для runtime-отказов.
- Держать единый чек-лист контентной валидации перед релизом area.
- После внедрения I.2 повторить аудит реактивных цепочек (blocked + disturbed + crime/alarm).
