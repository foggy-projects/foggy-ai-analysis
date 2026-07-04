# foggy-ai-analysis v0.1.15

Public Skill patch release aligned with `foggy-runtime-cli v0.1.20` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.6`.

## Fixed

- Points public onboarding and release validation to launcher `v0.1.6`, whose `start-foggy-runtime.sh` release asset is UTF-8 without BOM and LF-only for Linux/WSL shells.

## Unchanged

- Keeps Runtime API v1 CLI behavior from `v0.1.14`, including capability preflight, `datasources diagnostics`, `groupBy` string-array normalization, and hardened stack Skill install behavior.
- Keeps `foggy-runtime-cli v0.1.20` as the minimum and recommended CLI.

## Release Checklist

- Release assets must include `foggy-ai-analysis-skill-0.1.15.*`, `foggy-ai-analysis-skill-0.1.15-zh-CN.*`, and `foggy-semantic-query-skill-0.1.15.*`.
- Runtime launcher evidence should use `foggy-runtime-launcher-v0.1.6`.
- Stable stack should recommend `foggy-runtime-cli v0.1.20`, Foggy Runtime Launcher `v0.1.6`, and Skill `v0.1.15` after release assets are published.
