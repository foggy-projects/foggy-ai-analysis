# foggy-ai-analysis v0.1.14

Public Skill patch release aligned with `foggy-runtime-cli v0.1.20` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.5`.

## Changes

- Updates bundled runtime CLI rules to use `foggy-runtime-cli v0.1.20`.
- Keeps stack-manifest-based Skill installation as the public default path, with paired `foggy-ai-analysis` and `foggy-semantic-query` packages from the same release.
- Carries the Runtime API v1 datasource diagnostics, model validation, query validation, `groupBy` string-array normalization, and `-help` guidance from the previous release.

## Verification Targets

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.20` and `cliVersion=0.1.20`.
- Release assets must include `foggy-ai-analysis-skill-0.1.14.*`, `foggy-ai-analysis-skill-0.1.14-zh-CN.*`, and `foggy-semantic-query-skill-0.1.14.*`.
- Runtime launcher evidence should use `foggy-runtime-launcher-v0.1.5`.
- Stable stack should recommend `foggy-runtime-cli v0.1.20` and Skill `v0.1.14` after release assets are published.
