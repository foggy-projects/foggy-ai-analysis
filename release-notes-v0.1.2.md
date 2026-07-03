# foggy-ai-analysis Skill v0.1.2

Patch release for issue #9.

## Fixes

- Adds a `Where To File Issues` section to the feedback reference.
- Adds `Issue Routing` guidance to the GitHub issue template.
- Clarifies that Java runtime, Java launcher, Runtime API, MCP JSON-RPC endpoint, MCP tool execution, datasource/model loader, model catalog or `dataset.list_models`, query validation, and query execution issues belong in `foggy-projects/foggy-data-mcp-bridge`.
- Clarifies that CLI installation, argument parsing, command behavior, request or response formatting, exit codes, and command UX issues belong in `foggy-projects/foggy-runtime-cli`.
- Keeps unclear ownership issues in `foggy-projects/foggy-ai-analysis` for triage with sanitized evidence.

## Release Rule

Do not overwrite the existing `v0.1.1` assets. Publish the corrected package as `v0.1.2`.

The `v0.1.2` assets were replaced before handoff to align package documentation and manifest boundaries with Java launcher `foggy-runtime-launcher-v0.1.2`.

Workspace source commit:

```text
c84a8b4d4efc88537244d869b2f46ca135f0e00f
```

## Checksums

```text
edd3446e22537dae6acd9410be86a30ec2feee3e0653da11440434c2ea2fe2f1  foggy-ai-analysis-skill-0.1.2.zip
fddbc75d836e642225fae8d7f3a911f3897e95fd40135a6ea1e6adad41b6004a  foggy-ai-analysis-skill-0.1.2-manifest.json
```
