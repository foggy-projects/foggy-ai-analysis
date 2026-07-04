# foggy-ai-analysis v0.1.13

Public Skill patch release aligned with `foggy-runtime-cli v0.1.18` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.5`.

## Changes

- Points public onboarding, release validation, and CLI default Skill install guidance to `foggy-ai-analysis` Skill `v0.1.13`.
- Aligns the documented Java Runtime Launcher baseline to `foggy-runtime-launcher-v0.1.5`, which includes Runtime API datasource resolution validation improvements from `foggy-data-mcp-bridge` commit `e144c024`.
- Keeps the default English `foggy-ai-analysis` package, zh-CN package, and paired `foggy-semantic-query` package in the same release.
- Preserves the v0.1.12 portable Skill zip packaging fix.

## Required Verification

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.18` and `cliVersion=0.1.18`.
- Release assets must include `foggy-ai-analysis-skill-0.1.13.*`, `foggy-ai-analysis-skill-0.1.13-zh-CN.*`, and `foggy-semantic-query-skill-0.1.13.*`.
- Zip entries must include `foggy-ai-analysis/SKILL.md` and must not contain `\` separators.
- Runtime launcher evidence should use `foggy-runtime-launcher-v0.1.5`.
