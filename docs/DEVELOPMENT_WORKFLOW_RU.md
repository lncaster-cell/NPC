# Development Workflow (RU)

## Назначение

Короткий практический документ для сопровождения разработки Daily Life без разрастания лишней документации.

## Обязательный порядок для runtime-правок

1. **Проверить штатные механики** NWN2/NWScript (NWN Lexicon) для задачи.
2. Внести изменение в `daily_life/*.nss` минимальным безопасным диффом.
3. Проверить инварианты: bounded execution, idempotent transitions, observability.
4. Синхронизировать документацию:
   - архитектурный контекст: `docs/UNIFIED_DESIGN_DOCUMENT_RU.md`;
   - оперативный прогресс: `docs/DEVELOPMENT_STATUS_RU.md`.

## Минимальный Definition of Done

- [ ] Нет ad-hoc костылей при наличии встроенного механизма NWScript/NWN2.
- [ ] Изменение не ломает lifecycle ingress (spawn/death/blocked).
- [ ] Worker/resync остаются в квотах и без unbounded fan-out.
- [ ] Добавлена/обновлена краткая запись в `docs/DEVELOPMENT_STATUS_RU.md`.
- [ ] При изменении архитектурных правил обновлён unified-документ.

## Политика документации

- `docs/UNIFIED_DESIGN_DOCUMENT_RU.md` — источник архитектурной истины.
- Этот файл и `docs/DEVELOPMENT_STATUS_RU.md` — операционные документы сопровождения (короткие, прикладные, без дублирования всего unified).
- Избегаем создания новых документов без необходимости.
