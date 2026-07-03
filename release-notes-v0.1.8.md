# foggy-ai-analysis v0.1.8

Public Skill release aligned with `foggy-runtime-cli v0.1.12` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.3`.

## Changes

- Adds official public docs, whitepaper, TM/QM syntax, and Query DSL syntax links to the onboarding references.
- Keeps Skill source templates version-neutral with `<skill-version>`, `<cli-version>`, and `<launcher-tag>` placeholders; release packaging still replaces them with concrete versions.
- Updates public README release links to `v0.1.8`.
- Keeps the default package English and publishes the Chinese package with the `-zh-CN` suffix.
- Keeps paired delivery of `foggy-ai-analysis` for setup/modeling and `foggy-semantic-query` for existing-model query DSL, composeScript, and restricted Compose/CTE workflows.

## Validation

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.12` and `cliVersion=0.1.12`.
- Release assets must include `foggy-ai-analysis-skill-0.1.8.*`, `foggy-ai-analysis-skill-0.1.8-zh-CN.*`, and `foggy-semantic-query-skill-0.1.8.*`.
- Runtime smoke evidence should use `foggy-runtime-launcher-v0.1.3`.
- The packaged Skill must contain concrete `v0.1.8`, `v0.1.12`, and `foggy-runtime-launcher-v0.1.3` references, not placeholders.
