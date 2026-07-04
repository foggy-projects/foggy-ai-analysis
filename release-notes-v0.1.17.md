# foggy-ai-analysis v0.1.17

Public Skill patch release aligned with `foggy-runtime-cli v0.1.21` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.8`.

## Fixed

- Adds customer fields to the bundled sales-drop demo schema, seed data, TM, QM, smoke query, and question-bank payloads.
- Ensures the example query model exposes `customerId`, `customerName`, and `customerSegment` so customer-level decline questions can be answered from the public demo package.
- Adds the executable `SD-012` customer sales-drop question-bank case and moves the forecast unsupported case to `SD-013`.

## Compatibility

- Requires `foggy-runtime-cli v0.1.21` or later.
- Uses Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.8`.
- Keeps the paired `foggy-semantic-query` package in the same release so stack installs can keep both Skills aligned.

## Validation

- Sales-drop question-bank replay target is `total=13`, `executable=12`, `pass=12`, `fail=0`, `needs-clarification=1`.
- Runtime API smoke must show `customerId`, `customerName`, and `customerSegment` in `SalesDropDailyQueryModel`.
- `SD-012` must pass and return customer-level ranking by `salesDropAmount`.
