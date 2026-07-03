# foggy-ai-analysis v0.1.7

Public Skill release aligned with `foggy-runtime-cli v0.1.12` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.3`.

## Changes

- Renames the public Java launcher boundary from the old runtime API launcher naming to Foggy Runtime Launcher.
- Updates formal onboarding links for `foggy-ai-analysis` and paired `foggy-semantic-query` Skill assets to `v0.1.7`.
- Points CLI installation and command guidance to `foggy-runtime-cli v0.1.12`.
- Keeps default release downloads English, with Chinese packages published using the `-zh-CN` suffix.

## Validation

- Package manifests must declare `cliRequirement=foggy-runtime-cli >= 0.1.12`.
- Release assets must include `foggy-ai-analysis-skill-0.1.7.*`, `foggy-ai-analysis-skill-0.1.7-zh-CN.*`, and `foggy-semantic-query-skill-0.1.7.*`.
- Runtime smoke evidence should use `foggy-runtime-launcher-v0.1.3`.
