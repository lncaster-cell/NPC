# Краткие дизайн-доки по механикам Ambient Life v2

Ниже собраны краткие канонические дизайн-доки по уже реализованным механикам.

## Список

- [Респаун населения города](./NPC_RESPAWN_DESIGN.md)
- [Рутины и расписание NPC](./NPC_ROUTINE_SCHEDULE_DESIGN.md)
- [Маршруты и переходы между area](./NPC_ROUTE_TRANSITION_DESIGN.md)
- [Реакции на blocked/disturbed и безопасное восстановление](./NPC_REACT_BLOCKED_DISTURBED_DESIGN.md)
- [Сон и ночной lifecycle NPC](./NPC_SLEEP_LIFECYCLE_DESIGN.md)
- [Городские crime/alarm механики](./CITY_CRIME_ALARM_DESIGN.md)
- [Registry/dispatch и bounded-производительность](./REGISTRY_DISPATCH_PERF_DESIGN.md)

## Назначение формата

Каждый документ:
- фиксирует цель механики;
- описывает канонические правила/ограничения;
- отделяет похожие, но разные процессы;
- задаёт сценарии ожидаемого поведения.

Это «краткие» документы: подробные контракты, операционные runbook и low-level детали остаются в `docs/ARCHITECTURE.md`, `docs/TOOLSET_CONTRACT.md`, `docs/TECH_PASSPORT.md`, `docs/PERF_RUNBOOK.md`.
