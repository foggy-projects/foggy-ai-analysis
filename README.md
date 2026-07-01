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
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.1
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.1/foggy-ai-analysis-skill-0.1.1.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.1/foggy-ai-analysis-skill-0.1.1-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.1/foggy-ai-analysis-skill-0.1.1-SHA256SUMS
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.6
Java launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/runtime-api-launcher-v0.1.1
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

The main branch now documents issue routing for Skill, CLI, Java runtime/launcher, MCP endpoint, model catalog, and query execution issues. Package the corrected Skill source as `v0.1.2`; do not overwrite the existing `v0.1.1` assets.

## Boundary

The current public onboarding path is dev/test-oriented. Production permission, RBAC, audit, and governance are deferred to a later production-readiness phase.
