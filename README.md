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
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.3
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.3/foggy-ai-analysis-skill-0.1.3.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.3/foggy-ai-analysis-skill-0.1.3-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.3/foggy-ai-analysis-skill-0.1.3-SHA256SUMS
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.8
Java launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/runtime-api-launcher-v0.1.2
```

## Install Shape

Download the Skill zip, verify `SHA256SUMS`, then install or unpack it into your agent's Skill directory. Use the Skill with:

```text
Use $foggy-ai-analysis to install or start Foggy Runtime, connect a datasource, build TM/QM semantic models, and run an optional sales-drop example.
```

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

## Runtime API v1 CLI Alignment

The `v0.1.3` package updates the formal onboarding path to `foggy-runtime-cli v0.1.8`. This CLI release accepts query payload `groupBy` string-array shorthand, normalizes it to Runtime API v1 object items, and aligns bundle, datasource, table inspection, and capability preflight behavior with the Java Runtime API v1 contract.

## Boundary

The current public onboarding path is dev/test-oriented. Production permission, RBAC, audit, and governance are deferred to a later production-readiness phase.
