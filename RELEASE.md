# Release Process

The English Skill source of truth lives under `locales/en`:

```text
D:\foggy-projects\foggy-data-mcp\foggy-ai-analysis\locales\en
```

The Chinese source is a complete parallel source tree under `locales/zh-CN`:

```text
D:\foggy-projects\foggy-data-mcp\foggy-ai-analysis\locales\zh-CN
```

Build the default English package from the workspace:

```powershell
.\.codex\skills\foggy-release-tagging\scripts\publish_foggy_ai_analysis_skill.ps1 `
  -SkillVersion 0.1.5 `
  -CliTag v0.1.10 `
  -LauncherTag runtime-api-launcher-v0.1.2 `
  -ReleaseRepo <local-foggy-ai-analysis-clone> `
  -IncludeZhCn
```

Build the paired semantic query Skill package explicitly and upload it to the same release:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File scripts\package-foggy-skill.ps1 `
  -SkillName foggy-semantic-query `
  -Version 0.1.5 `
  -LauncherTag runtime-api-launcher-v0.1.2 `
  -CliRequirement "foggy-runtime-cli >= 0.1.10" `
  -RepoRoot D:\foggy-projects\foggy-data-mcp `
  -OutDir D:\foggy-projects\foggy-data-mcp\dist\skills

gh release upload v0.1.5 `
  D:\foggy-projects\foggy-data-mcp\dist\skills\foggy-semantic-query-skill-0.1.5.zip `
  D:\foggy-projects\foggy-data-mcp\dist\skills\foggy-semantic-query-skill-0.1.5-manifest.json `
  D:\foggy-projects\foggy-data-mcp\dist\skills\foggy-semantic-query-skill-0.1.5-SHA256SUMS `
  --repo foggy-projects/foggy-ai-analysis
```

The default asset names remain English:

```text
foggy-ai-analysis-skill-<version>.zip
foggy-ai-analysis-skill-<version>-manifest.json
foggy-ai-analysis-skill-<version>-SHA256SUMS
```

Chinese assets carry the explicit suffix:

```text
foggy-ai-analysis-skill-<version>-zh-CN.zip
foggy-ai-analysis-skill-<version>-zh-CN-manifest.json
foggy-ai-analysis-skill-<version>-zh-CN-SHA256SUMS
```

For the full release workflow, use:

```powershell
.\.codex\skills\foggy-release-tagging\scripts\publish_foggy_ai_analysis_skill.ps1 `
  -SkillVersion 0.1.5 `
  -CliTag v0.1.10 `
  -LauncherTag runtime-api-launcher-v0.1.2 `
  -IncludeZhCn
```

Before publishing, unzip each package and verify that any dollar-prefixed Skill references are either self references or listed in `skillDependencies`. `skillDependencies` should remain empty unless the package intentionally depends on another Skill.

For `v0.1.2`, also verify:

- `references/feedback.md` contains `Where To File Issues`.
- `assets/github-issue-template.md` contains `Issue Routing`.
- Java runtime, launcher, MCP endpoint, model catalog, and query execution issues route to `foggy-projects/foggy-data-mcp-bridge`.
- CLI install, argument parsing, command UX, response formatting, and exit-code issues route to `foggy-projects/foggy-runtime-cli`.

For `v0.1.5`, also verify:

- `references/public-onboarding.md` points to `foggy-runtime-cli v0.1.10`.
- `references/runtime-cli-command-rules.md` documents CLI `v0.1.10` capability preflight, `groupBy` string-array normalization, and `-help` compatibility.
- Manifest `cliRequirement` is `foggy-runtime-cli >= 0.1.10`.
- The same release includes `foggy-semantic-query-skill-0.1.5.*` assets.

For the first bilingual release, also verify:

- English manifest has `language=en`.
- Chinese manifest has `language=zh-CN`.
- Default download remains the unsuffixed English zip.
