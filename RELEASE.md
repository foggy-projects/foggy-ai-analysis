# Release Process

The Skill source of truth currently lives in:

```text
D:\foggy-projects\foggy-data-mcp\.codex\skills\foggy-ai-analysis
```

Build from the workspace:

```powershell
.\.codex\skills\foggy-release-tagging\scripts\publish_foggy_ai_analysis_skill.ps1 `
  -SkillVersion 0.1.3 `
  -CliTag v0.1.8 `
  -LauncherTag runtime-api-launcher-v0.1.2 `
  -ReleaseRepo <local-foggy-ai-analysis-clone>
```

Upload release assets:

```text
foggy-ai-analysis-skill-0.1.3.zip
foggy-ai-analysis-skill-0.1.3-manifest.json
foggy-ai-analysis-skill-0.1.3-SHA256SUMS
```

Before publishing, unzip the package and verify that any dollar-prefixed Skill references are either self references or listed in `skillDependencies`. For `v0.1.1`, `skillDependencies` should be empty and no external Skill references should remain.

For `v0.1.2`, also verify:

- `references/feedback.md` contains `Where To File Issues`.
- `assets/github-issue-template.md` contains `Issue Routing`.
- Java runtime, launcher, MCP endpoint, model catalog, and query execution issues route to `foggy-projects/foggy-data-mcp-bridge`.
- CLI install, argument parsing, command UX, response formatting, and exit-code issues route to `foggy-projects/foggy-runtime-cli`.

For `v0.1.3`, also verify:

- Public onboarding installs `foggy-runtime-cli v0.1.8`.
- `references/runtime-cli-command-rules.md` documents CLI `v0.1.8` capability preflight and `groupBy` string-array normalization.
- Manifest `cliRequirement` is `foggy-runtime-cli >= 0.1.8`.
