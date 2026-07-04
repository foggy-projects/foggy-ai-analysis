# Foggy AI Analysis Skill

Formal Codex Skill package for Foggy AI analysis onboarding and semantic modeling.

This Skill guides an AI coding agent through:

- installing `foggy-runtime-cli`
- starting the Java Foggy lite Runtime API
- using SQLite fallback when no datasource is provided
- inspecting datasource tables
- creating namespace/TM/QM resources
- validating, refreshing, describing, and querying semantic models
- running question banks and tuning semantic descriptions
- connecting MCP-capable IDE clients
- preparing sanitized bug or optimization feedback

The bundled sales-drop data is an optional example, not the main Skill identity.

## Current Release

```text
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.13
Analysis Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.13/foggy-ai-analysis-skill-0.1.13.zip
Analysis Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.13/foggy-ai-analysis-skill-0.1.13-manifest.json
Analysis Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.13/foggy-ai-analysis-skill-0.1.13-SHA256SUMS
Semantic Query Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.13/foggy-semantic-query-skill-0.1.13.zip
Semantic Query Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.13/foggy-semantic-query-skill-0.1.13-manifest.json
Semantic Query Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.13/foggy-semantic-query-skill-0.1.13-SHA256SUMS
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.18
Foggy Runtime Launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/foggy-runtime-launcher-v0.1.5
```

## Official Public Docs

The Skill is self-contained for install, demo replay, datasource onboarding, and basic TM/QM modeling. Use these public docs for full syntax, compatibility, and advanced modeling details:

```text
Foggy docs=https://foggy-projects.github.io/foggy-data-mcp-docs/en/
Whitepaper v1.0=https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/
TM/QM syntax reference=https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/semantic-layer-syntax-reference.html
Query DSL syntax reference=https://foggy-projects.github.io/foggy-data-mcp-docs/en/whitepaper/v1.0/query-dsl-syntax-reference.html
```

## Source Layout

The canonical English Skill source now lives under `locales/en`:

```text
locales/en/SKILL.md
locales/en/agents/
locales/en/assets/
locales/en/references/
```

The Chinese Skill source is a complete parallel source tree under `locales/zh-CN`:

```text
locales/zh-CN/SKILL.md
locales/zh-CN/agents/
locales/zh-CN/assets/
locales/zh-CN/references/
```

Default release downloads use the English package name:

```text
foggy-ai-analysis-skill-<version>.zip
```

Chinese packages use an explicit language suffix when generated:

```text
foggy-ai-analysis-skill-<version>-zh-CN.zip
```

## Install Shape

Download the Skill zip, verify `SHA256SUMS`, then install it with the runtime CLI:

```powershell
foggy-runtime skills install foggy-ai-analysis --zip .\foggy-ai-analysis-skill-0.1.13.zip --replace
foggy-runtime skills install foggy-semantic-query --zip .\foggy-semantic-query-skill-0.1.13.zip --replace
```

The target agent Skill directories are:

```text
~/.agents/skills/foggy-ai-analysis
~/.agents/skills/foggy-semantic-query
```

The runtime CLI Skill install path intentionally targets `~/.agents/skills` only; it does not write to `~/.codex/skills` or `~/.claude/skills`. Use the Skill with:

```text
Use $foggy-ai-analysis to install or start Foggy Runtime, connect a datasource, build TM/QM semantic models, and run an optional sales-drop example.
```

When using local workspace sources, the CLI can install the paired analysis/query Skills together:

```powershell
foggy-runtime skills install foggy-analysis-suite --workspace-root <workspace-root>
```

This installs `foggy-ai-analysis` for setup/modeling and `foggy-semantic-query` for existing-model DSL, composeScript, and restricted Compose/CTE query work.

## Where To File Issues

Choose the repository by the component that most likely owns the failure:

| Repository | Use for | New issue |
| --- | --- | --- |
| `foggy-projects/foggy-ai-analysis` | Skill packaging, Skill instructions, bundled demo assets, onboarding docs, GitHub issue template, release validation instructions, and unclear routing. | <https://github.com/foggy-projects/foggy-ai-analysis/issues/new> |
| `foggy-projects/foggy-runtime-cli` | CLI installation, argument parsing, command behavior, request or response formatting, exit codes, and command UX. | <https://github.com/foggy-projects/foggy-runtime-cli/issues/new> |
| `foggy-projects/foggy-data-mcp-bridge` | Java runtime, Runtime API, Java launcher, MCP JSON-RPC endpoint, MCP tool execution, datasource/model loader, model catalog or `dataset.list_models`, query validation, and query execution. | <https://github.com/foggy-projects/foggy-data-mcp-bridge/issues/new> |
| `foggy-projects/foggy-ai-analysis-demo` | Legacy demo-only Skill package issues, if that package is still in use. | <https://github.com/foggy-projects/foggy-ai-analysis-demo/issues/new> |

If ownership is unclear, file the issue in `foggy-projects/foggy-ai-analysis` with sanitized evidence and mark it as a routing question.

## Issue 7 Status

The `v0.1.0` package has a known documentation/package defect: it references the internal `foggy-runtime-cli-workflow` Skill without bundling or declaring that dependency. The fix is included in the `v0.1.1` patch release by bundling runtime CLI command rules inside `foggy-ai-analysis` and keeping `skillDependencies` empty in the package manifest.

Do not overwrite the `v0.1.0` release assets; use the corrected `v0.1.1` assets for new installs.

## Issue 9 Status

The `v0.1.2` package documents issue routing for Skill, CLI, Java runtime/launcher, MCP endpoint, model catalog, and query execution issues. Do not overwrite the existing `v0.1.1` assets.

## Issue 11 Status

The `v0.1.11` package has a cross-platform packaging defect: zip entries were generated with Windows `\` separators, which breaks Linux/macOS extraction and `foggy-runtime skills install --zip`. Do not overwrite `v0.1.11`; use `v0.1.12` or later, where zip entries use POSIX-compatible `/` separators.

## Runtime API v1 CLI Alignment

The `v0.1.13` package points public onboarding to `foggy-runtime-cli v0.1.18` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.5`. This release keeps the `datasources diagnostics` runtime evidence path, Runtime API v1 capability preflight, and `groupBy` string-array normalization, while fixing cross-platform Skill zip member paths for Linux/macOS installation.

## Bilingual Source Status

The repository carries English and Chinese `foggy-ai-analysis` Skill sources. The default published asset is the unsuffixed English package, and the Chinese package uses the `-zh-CN` suffix.

## Boundary

The current public onboarding path is dev/test-oriented. Production permission, RBAC, audit, and governance are deferred to a later production-readiness phase.
