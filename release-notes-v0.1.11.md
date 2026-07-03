# foggy-ai-analysis v0.1.11

Public Skill release aligned with `foggy-runtime-cli v0.1.16` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.4`.

## Changes

- Points public onboarding to `foggy-runtime-cli v0.1.16`.
- Documents `foggy-runtime datasources diagnostics` as the preferred evidence path for registry location, namespace bindings, persisted datasource records, and pool lifecycle.
- Aligns user-owned datasource guidance with Runtime API-managed named datasources and keeps the sales-drop replay on the runtime default SQLite datasource.
- Carries MySQL named datasource add/test/bind, model validate/refresh/describe, query validate/execute, and restart persistence validation into the release evidence path.
- Keeps CLI `groupBy` string-array normalization guidance while raw Runtime API v1 callers use object-shaped `groupBy` items until Java native string-array compatibility is added.

## Required Verification

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.16` and `cliVersion=0.1.16`.
- Release assets must include `foggy-ai-analysis-skill-0.1.11.*`, `foggy-ai-analysis-skill-0.1.11-zh-CN.*`, and `foggy-semantic-query-skill-0.1.11.*`.
- The packaged Skill must contain concrete `v0.1.11`, `v0.1.16`, and `foggy-runtime-launcher-v0.1.4` references, not placeholders.
