# foggy-ai-analysis v0.1.6

Public Skill release aligned with `foggy-runtime-cli v0.1.11` and Java launcher `runtime-api-launcher-v0.1.3`.

## Changes

- Updates public onboarding links for `foggy-ai-analysis` and the paired `foggy-semantic-query` Skill assets to `v0.1.6`.
- Points CLI installation and command guidance to `foggy-runtime-cli v0.1.11`.
- Points launcher guidance to `runtime-api-launcher-v0.1.3`.
- Documents Runtime API-managed datasource diagnostics and JDBC datasource usage, including MySQL, for table discovery, SQL probing, model validation/refresh/describe, and query execution on supported runtimes.
- Keeps default release downloads English, with Chinese packages published using the `-zh-CN` suffix.

## Validation

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.11`.
- Release assets must include `foggy-ai-analysis-skill-0.1.6.*`, `foggy-ai-analysis-skill-0.1.6-zh-CN.*`, and `foggy-semantic-query-skill-0.1.6.*`.
- Runtime smoke evidence should use `runtime-api-launcher-v0.1.3` and include a Runtime API-managed MySQL datasource restart/persistence check.
