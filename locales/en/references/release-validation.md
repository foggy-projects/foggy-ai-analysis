# Release Validation

Use this reference to validate the formal Skill package from public release assets.

## Constraints

```text
do not use foggy-runtime-cli source checkout
do not set PYTHONPATH=src
download Skill from https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v<skill-version>
download CLI from https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v<cli-version>
download Foggy Runtime Launcher from https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/<launcher-tag>
validate all SHA256SUMS
scan the unzipped Skill for undeclared dollar-prefixed Skill references
```

Use the concrete `<skill-version>`, `<cli-version>`, and `<launcher-tag>` stated in the release notes under validation. Do not leave historical version numbers in the validation prompt or evidence.

## Smoke

1. Install CLI in an isolated environment.
2. Start Java runtime on port `18066` unless occupied.
3. Run `wait-ready` and `capabilities`.
4. If no datasource is available, run the bundled sales-drop replay with `--use-default-datasource`.
5. Stop runtime and verify the port is released.

## Static Skill Reference Check

After unzipping the Skill, search for Skill-style references:

```powershell
rg -n --pcre2 '(?<![A-Za-z0-9_-])\$([a-z][a-z0-9]*(?:-[a-z0-9]+)+)(?![A-Za-z0-9_-])' <unzipped-skill-dir>
```

Only `$foggy-ai-analysis` self references are allowed unless the package manifest declares additional `skillDependencies`. Any undeclared external Skill reference blocks release validation.

Report commands, outputs, ports, checksums, failures, and repairs.
