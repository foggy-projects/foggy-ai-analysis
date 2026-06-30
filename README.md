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
Skill release=https://github.com/foggy-projects/foggy-ai-analysis/releases/tag/v0.1.0
Skill zip=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.0/foggy-ai-analysis-skill-0.1.0.zip
Skill manifest=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.0/foggy-ai-analysis-skill-0.1.0-manifest.json
Skill checksum=https://github.com/foggy-projects/foggy-ai-analysis/releases/download/v0.1.0/foggy-ai-analysis-skill-0.1.0-SHA256SUMS
CLI release=https://github.com/foggy-projects/foggy-runtime-cli/releases/tag/v0.1.6
Java launcher release=https://github.com/foggy-projects/foggy-data-mcp-bridge/releases/tag/runtime-api-launcher-v0.1.1
```

## Install Shape

Download the Skill zip, verify `SHA256SUMS`, then install or unpack it into your agent's Skill directory. Use the Skill with:

```text
Use $foggy-ai-analysis to install or start Foggy Runtime, connect a datasource, build TM/QM semantic models, and run an optional sales-drop example.
```

## Issue 7 Status

The `v0.1.0` package has a known documentation/package defect: it references the internal `foggy-runtime-cli-workflow` Skill without bundling or declaring that dependency. The fix is included in the `v0.1.1` patch release by bundling runtime CLI command rules inside `foggy-ai-analysis` and keeping `skillDependencies` empty in the package manifest.

Do not overwrite the `v0.1.0` release assets; use the corrected `v0.1.1` assets for new installs.

## Boundary

The current public onboarding path is dev/test-oriented. Production permission, RBAC, audit, and governance are deferred to a later production-readiness phase.
