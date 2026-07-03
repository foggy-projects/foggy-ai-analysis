# foggy-ai-analysis v0.1.9

Public Skill release aligned with `foggy-runtime-cli v0.1.14` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.3`.

## Changes

- Supersedes `v0.1.8` as the final paired release for CLI/Skill onboarding.
- Points public onboarding to `foggy-runtime-cli v0.1.14`, whose help and install metadata point back to `foggy-ai-analysis v0.1.9`.
- Keeps official public docs, whitepaper, TM/QM syntax, and Query DSL syntax links in the onboarding references.
- Keeps paired delivery of `foggy-ai-analysis` for setup/modeling and `foggy-semantic-query` for existing-model query DSL, composeScript, and restricted Compose/CTE workflows.
- Keeps the default package English and publishes the Chinese package with the `-zh-CN` suffix.

## Validation

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.14` and `cliVersion=0.1.14`.
- Release assets must include `foggy-ai-analysis-skill-0.1.9.*`, `foggy-ai-analysis-skill-0.1.9-zh-CN.*`, and `foggy-semantic-query-skill-0.1.9.*`.
- Runtime smoke evidence should use `foggy-runtime-launcher-v0.1.3`.
- The packaged Skill must contain concrete `v0.1.9`, `v0.1.14`, and `foggy-runtime-launcher-v0.1.3` references, not placeholders.
