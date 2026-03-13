# Ambient Life perf baselines (S80/S100/S120)
<!-- DOCSYNC:2026-03-13 -->
> Documentation sync: 2026-03-13. This file was reviewed and aligned with the current repository structure.


Единая точка хранения baseline-замеров для обязательных perf-сценариев из `docs/PERF_RUNBOOK.md` и `docs/PERF_PROFILE.md`.

## Файлы

- `s80_s100_s120_baseline.csv` — машинно-читаемый baseline (источник для автоматических проверок/диффов).
  Для метрик с трендовой проверкой (`route_cache_hits`, `route_cache_rebuilds`, `route_cache_invalidations`)
  обязательны поля `expected_direction` (`up|down|stable`) и `trend_tolerance`.
- `s80_s100_s120_baseline.md` — операторское представление тех же значений в формате «до/после».
- `perf_gate_report_template.csv` / `perf_gate_report_template.json` — шаблоны machine-readable отчёта для CI perf-gate.
- `perf_gate_report.csv` (генерируется в PR) — фактический отчёт, который валидируется в CI.

## Базовое правило обновления baseline

Baseline **обновляется только** при одном из двух условий:

1. Подтверждённое улучшение (`After` лучше baseline по KPI/порогам, без регрессии по overflow, `al_dispatch_ticks_to_drain` и cache-trend метрикам).
2. Обоснованное изменение поведения (документированная архитектурная/контентная причина, почему прежний baseline больше не репрезентативен).

В обоих случаях обновление должно включать:

- ссылку на PR/commit, где подтверждён новый baseline;
- приложенный отчёт `baseline-vs-after` по шаблону из `docs/PERF_PROFILE.md`;
- заполненные поля `source_date`, `source_commit`, `notes` в CSV.

## Perf gate (CI)

Для PR с изменениями в `scripts/ambient_life/al_*` обязателен зелёный job `Ambient Life Perf Gate`.
Проверка использует baseline `s80_s100_s120_baseline.csv` и отчёт `perf_gate_report.csv` (или `.json`)
через внешний CI tooling (external-only, без локального Python-валидатора в этом репозитории).

Во внешнем tooling допускается локальный best-effort кэш нормализованных/распарсенных входов
в `.cache/perf_gate/` (ключ: `sha256(<baseline-bytes> + "\\0" + <report-bytes>)`).
Кэш не влияет на логику PASS/FAIL (вердикт считается каждый запуск), а при любой ошибке чтения,
декодирования или записи должен использоваться безопасный fallback на прямой парсинг файлов.
Для полностью детерминированных CI-прогонов используйте режим без кэша (если поддерживается tooling).
