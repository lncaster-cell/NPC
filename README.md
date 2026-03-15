# NPC PycukSystem's Entertainment v2

Короткий вход в репозиторий документации по Ambient Life v2.

> ⚠️ Текущий этап: runtime-код прошлой итерации удалён; репозиторий используется как design/docs-база до новой реализации. См. `docs/18_REBUILD_RESET_CONTEXT.md`.

## Куда идти в первую очередь

1. **`docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md`** — единственный главный дизайн-документ проекта (общая картина и инварианты).
2. **`docs/12_MASTER_PLAN.md`** — супер-краткая сводка и навигационный индекс.
3. **Доменные тома `12A–12E`, `13`, `14`** — правила и детализация по подсистемам.

## Роли документов (без конкурирующих входов)

- `README.md` — только короткий вход.
- `docs/17_UNIFIED_GAME_DESIGN_BRIEF_RU.md` — единственный high-level канон.
- `docs/12_MASTER_PLAN.md` — только индекс маршрутизации.
- `docs/10_DECISIONS_LOG.md` — журнал решений.
- `docs/16_IDEA_INVENTORY_AND_SYNC_MAP.md` — служебная карта синхронизации идей (не source of truth).
- `docs/00_PROJECT_LIBRARY.md` — routing-слой по библиотеке документов.

## Мини-формула проекта

Ambient Life v2 =
- NPC routines / daily life;
- bounded event-driven runtime (area-centric, без per-NPC heartbeat);
- legal + witness + city response;
- long-term контуры property / travel / trade / clan / aging / succession.

Ключевой принцип: тактическая реакция движка, правовой статус и долгие социально-экономические последствия не смешиваются в один слой.
