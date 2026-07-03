# foggy-ai-analysis v0.1.12

Public Skill patch release aligned with `foggy-runtime-cli v0.1.17` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.4`.

## Changes

- Fixes Skill zip member paths to use POSIX-compatible `/` separators instead of Windows `\` separators.
- Keeps the default English `foggy-ai-analysis` package, zh-CN package, and paired `foggy-semantic-query` package in the same release.
- Points public onboarding and CLI default Skill install guidance to the corrected `v0.1.12` Skill assets.
- Preserves the v0.1.11 Runtime API datasource diagnostics, user datasource separation, and `groupBy` string-array normalization guidance.

## Required Verification

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.17` and `cliVersion=0.1.17`.
- Release assets must include `foggy-ai-analysis-skill-0.1.12.*`, `foggy-ai-analysis-skill-0.1.12-zh-CN.*`, and `foggy-semantic-query-skill-0.1.12.*`.
- Zip entries must include `foggy-ai-analysis/SKILL.md` and must not contain `\` separators.
