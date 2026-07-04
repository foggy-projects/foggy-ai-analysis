# foggy-ai-analysis v0.1.16

Public Skill patch release aligned with `foggy-runtime-cli v0.1.20` and Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.6`.

## Added

- Adds `references/semantic-layer-publish-runbook.md` to the English and Chinese Skill packages.
- Defines "publish/update semantic layer" as registering the user's current Git working tree TM/QM model directory as a Runtime managed bundle, then running `models refresh` so Runtime API/MCP query services load the latest models.
- Documents the end-to-end public command sequence: `wait-ready`, `capabilities`, datasource list/test/binding, table inspect, `models validate`, `bundles add --watch --replace`, `models refresh`, `models describe`, query smoke, and MCP JSON-RPC `tools/list`.

## Boundary

- Git versioning, approvals, rollback, audit, tenant permission governance, and RBAC remain owned by the user's Git/engineering process.
- The Skill must not call private Java/Python endpoints, bypass `models validate`, publish after validation failure, write datasource passwords into TM/QM, or put runtime metadata into MCP client `mcpServers`.

## Compatibility

- Keeps `foggy-runtime-cli v0.1.20` as the minimum and recommended CLI.
- Keeps Foggy Runtime Launcher `foggy-runtime-launcher-v0.1.6`.
- Keeps paired `foggy-semantic-query` packaging in the same release so stack install can keep both Skills aligned.

## Validation

- Release assets must include `foggy-ai-analysis-skill-0.1.16.*`, `foggy-ai-analysis-skill-0.1.16-zh-CN.*`, and `foggy-semantic-query-skill-0.1.16.*`.
- Release validation must verify `references/semantic-layer-publish-runbook.md` exists in the unpacked packages and contains the public validate -> bundle add/update -> refresh -> describe -> query smoke -> MCP probe workflow.
- Stable stack should recommend `foggy-runtime-cli v0.1.20`, Foggy Runtime Launcher `v0.1.6`, and Skill `v0.1.16` after release assets are published.
