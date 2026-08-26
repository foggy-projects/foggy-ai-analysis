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
$skillVersion = "<skill-version>"
$skillTag = "v$skillVersion"
$cliTag = "v0.1.22"
$launcherTag = "foggy-runtime-launcher-v0.1.18"
$workspaceRoot = "<workspace-root>"
```

## Atomic Skill-set Release

Build, validate, and publish the default English analysis package, the paired semantic-query
package, and optionally the Chinese analysis package in one gated release:

```powershell
.\.codex\skills\foggy-release-tagging\scripts\publish_foggy_ai_analysis_skill.ps1 `
  -SkillVersion $skillVersion `
  -CliTag $cliTag `
  -LauncherTag $launcherTag `
  -IncludeZhCn
```

The release script validates both canonical sources, packages both Skills, unzips each result,
verifies concrete version replacement, uploads the exact paired asset set, downloads every asset
back, and re-validates the remote packages. `-IncludeZhCn` adds the Chinese analysis package to the
same transaction.

## Paired Semantic Query Skill

The canonical source is `skills/foggy-semantic-query` in this repository. The publisher always
builds and publishes it with the English analysis Skill; there is no supported analysis-only
release path. `scripts/package-foggy-skill.ps1` can still package either canonical source alone for
local diagnostics, but manual upload is not the release workflow.

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

- `references/public-onboarding.md` resolves to the current `foggy-ai-analysis` release, `foggy-runtime-cli v0.1.22`, and `foggy-runtime-launcher-v0.1.18` after packaging.
- `references/runtime-cli-command-rules.md` documents CLI `v0.1.22` capability preflight, `datasources diagnostics`, `groupBy` string-array normalization, and `-help` compatibility.
- `references/tm-qm-configuration.md` links the official TM/QM and Query DSL syntax references.
- `references/semantic-layer-publish-runbook.md` is present, self-contained, routes through public `foggy-runtime` commands and MCP JSON-RPC `tools/list`, and explicitly keeps Git approval, rollback, audit, and RBAC outside Skill scope.
- Manifest `cliRequirement` is `foggy-runtime-cli >= 0.1.22` and `cliVersion` is `0.1.22`.
- English manifest has `language=en`.
- Chinese manifest has `language=zh-CN`.
- Default download remains the unsuffixed English zip.
- The release contains exactly six default assets: three for `foggy-ai-analysis` and three for
  `foggy-semantic-query`. `-IncludeZhCn` makes the exact set nine assets.
- Both manifests use the same committed `foggy-ai-analysis` repository source and release version.
- Zip entry names use `/` separators and contain no Windows `\` paths.

Before OBS replay, run this repository's `scripts/sync-release-to-obs.sh` with
`--validate-assets-only`. It rejects any asset outside the exact six-file default set (or nine-file
set with Chinese), missing paired Semantic Query assets, incomplete checksum coverage, or mismatched
Skill manifests. The live sync writes `latest/skills.json` first and treats the shared
`latest.json` as a reconciled derived index so concurrent CLI/Launcher publication cannot silently
drop another component.

## Historical Checks

For `v0.1.2`, also verify:

- `references/feedback.md` contains `Where To File Issues`.
- `assets/github-issue-template.md` contains `Issue Routing`.
- Java runtime, launcher, MCP endpoint, model catalog, and query execution issues route to `foggy-projects/foggy-data-mcp-bridge`.
- CLI install, argument parsing, command UX, response formatting, and exit-code issues route to `foggy-projects/foggy-runtime-cli`.
