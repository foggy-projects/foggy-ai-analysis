# Release Process

The English Skill source of truth lives under:

```text
foggy-ai-analysis/locales/en
```

The Chinese source is a complete parallel source tree under:

```text
foggy-ai-analysis/locales/zh-CN
```

## Version Inputs

Set these values for each release. The examples below use the current validated component versions:

```powershell
$skillVersion = "0.1.9"
$skillTag = "v$skillVersion"
$cliTag = "v0.1.14"
$launcherTag = "foggy-runtime-launcher-v0.1.3"
$workspaceRoot = "<workspace-root>"
```

## Full Analysis Skill Release

Build, validate, and publish the default English package plus the Chinese package:

```powershell
.\.codex\skills\foggy-release-tagging\scripts\publish_foggy_ai_analysis_skill.ps1 `
  -SkillVersion $skillVersion `
  -CliTag $cliTag `
  -LauncherTag $launcherTag `
  -IncludeZhCn
```

The release script validates source templates, packages the Skill, unzips the result, verifies concrete version replacement, uploads assets, downloads them back, and re-validates the remote package.

## Paired Semantic Query Skill

Build the paired semantic-query package explicitly and upload it to the same release:

```powershell
$outDir = Join-Path $workspaceRoot "dist\skills"

powershell -NoProfile -ExecutionPolicy Bypass -File (Join-Path $workspaceRoot "scripts\package-foggy-skill.ps1") `
  -SkillName foggy-semantic-query `
  -Version $skillVersion `
  -LauncherTag $launcherTag `
  -CliRequirement "foggy-runtime-cli >= 0.1.14" `
  -RepoRoot $workspaceRoot `
  -OutDir $outDir

gh release upload $skillTag `
  (Join-Path $outDir "foggy-semantic-query-skill-$skillVersion.zip") `
  (Join-Path $outDir "foggy-semantic-query-skill-$skillVersion-manifest.json") `
  (Join-Path $outDir "foggy-semantic-query-skill-$skillVersion-SHA256SUMS") `
  --repo foggy-projects/foggy-ai-analysis
```

## Asset Names

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

The paired semantic-query package uses:

```text
foggy-semantic-query-skill-<version>.zip
foggy-semantic-query-skill-<version>-manifest.json
foggy-semantic-query-skill-<version>-SHA256SUMS
```

## Required Verification

Before publishing, unzip each package and verify that any dollar-prefixed Skill references are either self references or listed in `skillDependencies`. `skillDependencies` should remain empty unless the package intentionally depends on another Skill.

For the current runtime-aligned release, also verify:

- `references/public-onboarding.md` resolves to the current `foggy-ai-analysis` release, `foggy-runtime-cli v0.1.14`, and `foggy-runtime-launcher-v0.1.3` after packaging.
- `references/runtime-cli-command-rules.md` documents CLI `v0.1.14` capability preflight, `groupBy` string-array normalization, and `-help` compatibility.
- `references/tm-qm-configuration.md` links the official TM/QM and Query DSL syntax references.
- Manifest `cliRequirement` is `foggy-runtime-cli >= 0.1.14` and `cliVersion` is `0.1.14`.
- English manifest has `language=en`.
- Chinese manifest has `language=zh-CN`.
- Default download remains the unsuffixed English zip.
- The same release includes `foggy-semantic-query-skill-<version>.*` assets.

## Historical Checks

For `v0.1.2`, also verify:

- `references/feedback.md` contains `Where To File Issues`.
- `assets/github-issue-template.md` contains `Issue Routing`.
- Java runtime, launcher, MCP endpoint, model catalog, and query execution issues route to `foggy-projects/foggy-data-mcp-bridge`.
- CLI install, argument parsing, command UX, response formatting, and exit-code issues route to `foggy-projects/foggy-runtime-cli`.
