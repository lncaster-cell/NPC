# Daily Life v2 Workspace

Active development workspace for Daily Life v2 rewrite.

## Current files

- `dl_v2_runtime_inc.nss` — Step 01 runtime gate helper.
- `dl_v2_contract_inc.nss` — shared contract constants and enum-like values.
- `dl_v2_log_inc.nss` — centralized chat logging helpers.
- `dl_v2_bootstrap_inc.nss` — module contract/bootstrap init helpers.
- `dl_v2_area_inc.nss` — area tier/runtime state helpers.
- `dl_v2_bootstrap.nss` — module bootstrap entry point.
- `dl2_smoke_step_01.nss` — runtime gate smoke.
- `dl2_smoke_step_02_bootstrap_init.nss` — module bootstrap smoke.
- `dl2_smoke_step_03_area_tier.nss` — area tier smoke.

## Notes

- v2 grows in this workspace.
- legacy v1 remains archived under `archive/daily_life_v1_legacy/scripts/daily_life/`.
- prefer isolated helpers and local smoke checks for each runtime slice.
