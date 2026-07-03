# foggy-ai-analysis v0.1.10

Public Skill release aligned with `foggy-runtime-cli v0.1.15` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.3`.

## Changes

- Points public onboarding to `foggy-runtime-cli v0.1.15`.
- Keeps the official Foggy docs, whitepaper, TM/QM syntax, and Query DSL syntax links in the Skill references.
- Documents Runtime API-managed datasource registration with JDBC datasource types beyond SQLite, including MySQL examples using `--password-env`.
- Corrects datasource persistence guidance to use launcher/runtime registry paths plus restart validation instead of a non-existent `datasources diagnostics` CLI command.
- Clarifies the current public boundary: named Runtime API-managed datasources are for add/test/bind, table discovery, and read-only SQL probing; the sales-drop end-to-end model/query replay still uses the runtime default datasource unless the connected runtime is separately validated for named datasource model/query execution.

## Required Verification

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.15` and `cliVersion=0.1.15`.
- Release assets must include `foggy-ai-analysis-skill-0.1.10.*`, `foggy-ai-analysis-skill-0.1.10-zh-CN.*`, and `foggy-semantic-query-skill-0.1.10.*`.
- The packaged Skill must contain concrete `v0.1.10`, `v0.1.15`, and `foggy-runtime-launcher-v0.1.3` references, not placeholders.
