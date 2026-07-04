---
name: foggy-ai-analysis
description: Guide Foggy AI analysis onboarding and semantic modeling. Use when Codex needs to help a user install or start Foggy Runtime, connect or inspect a datasource, fall back to SQLite, create namespaces/TM/QM/query models, inspect query-model schema, refresh and validate models, run question banks, tune semantic descriptions and prompts, connect an IDE or MCP client, explain JAR/Docker/Odoo runtime deployment, optionally integrate embedded Spring Boot projects, identify and route existing-model queryModel DSL, composeScript, or restricted Compose/CTE usage to foggy-semantic-query, or prepare GitHub bug and optimization feedback for Foggy analysis workflows.
---

# Foggy AI Analysis

## Capabilities

Use this skill as the formal Foggy AI analysis onboarding and semantic-layer construction entrypoint:

1. Install `foggy-runtime-cli`, download the Java lite runtime launcher, and start Runtime API.
2. Use the runtime default SQLite datasource when the user has not provided a datasource.
3. Inspect tables and run read-only SQL probes before generating semantic models.
4. Create or validate namespace-scoped TM/QM resources; handle model-list registration only for embedded or legacy hosts that require it.
5. Refresh, describe, validate, and execute query models through `foggy-runtime-cli`.
6. Create and run question banks, then tune TM/QM field names, captions, descriptions, and prompts.
7. Connect IDE/MCP clients to the local runtime after Runtime API is ready.
8. Explain supported runtime deployment modes, namespace headers, and external model bundles.
9. Guide embedded Spring Boot integration only when the user explicitly wants an in-app Java integration rather than a standalone runtime.
10. Gather sanitized commands, evidence, and logs for GitHub bug or optimization feedback.

Sales-drop is only the bundled example path. Use it when the user wants a quick demo or has no datasource; do not make it the main workflow when the user supplies their own business data.

Production permission design is out of scope for this skill. State that the current public onboarding path is dev/test-oriented and that production auth, RBAC, audit, and governance are handled in a later phase.

Existing-model query-language work is a separate concern. For queryModel DSL payloads, composeScript, restricted Compose/CTE checks, virtual semantic SQL translation, pre-aggregation routing, or query error recovery, use the `foggy-semantic-query` Skill when it is available. This Skill should prepare runtime/model context, then hand query-language specifics to that workflow. Keep this public Skill package self-contained and do not require undeclared external Skill dependencies.

## Workflow

1. Identify the user's state: fresh install, runtime already running, datasource available, no datasource, model iteration, question-bank tuning, MCP connection, or feedback.
2. Read only the relevant reference from the index below.
3. Resolve runtime URL, namespace, datasource mode, SQLite path, model directory, and evidence directory before running long operations.
4. Start newly launched runtimes with `wait-ready`, then run `capabilities` and record `engine`, `runtimeApiVersion`, `schemaVersion`, `securityMode`, and enabled capabilities.
5. If the runtime reports `securityMode=auth-code`, pass `--auth-code` or set `FOGGY_RUNTIME_API_AUTH_CODE`. The current public sales-drop example uses `securityMode=none-dev-test-only`.
6. For user data, inspect schema first and keep it on a named datasource bound to the target namespace; for no datasource, use the bundled sales-drop SQLite example. Do not mix user databases with the sales-drop reseed flow.
7. Validate models before refresh, describe refreshed models before query execution, and keep all SQL probes read-only unless the user explicitly asks to seed example data.
8. Record commands, ports, evidence paths, failures, and repairs.

For detailed Runtime API command sequencing and failure handling, read `references/runtime-cli-command-rules.md`. The public Skill package must stay self-contained; do not require another Codex Skill unless the package manifest explicitly declares it.

## Reference Index

- `references/public-onboarding.md`: formal download links, CLI install, Java launcher download, runtime startup, and first smoke checks.
- `references/runtime-cli-command-rules.md`: Runtime CLI JSON contract, readiness and capability gates, datasource/model/query sequence, exit-code handling, and public package dependency boundary.
- `references/datasource-and-semantic-modeling.md`: datasource discovery, table inspection, SQL probes, namespace/TM/QM generation, validation, refresh, and describe workflow.
- `references/semantic-layer-publish-runbook.md`: publish or update user-managed TM/QM model directories into the Runtime API bundle registry, refresh query models, and verify Runtime API/MCP query service.
- `references/tm-qm-configuration.md`: practical TM/QM configuration rules for fields, measures, dates, money units, query model exposure, optional host-specific model-list registration, and validation.
- `references/question-bank-and-tuning.md`: build and run question banks, classify misses, and tune semantic metadata or prompts.
- `references/mcp-deployment.md`: JAR/Docker/Odoo runtime deployment notes, Runtime API/MCP endpoint checks, namespace headers, and external bundle usage.
- `references/mcp-ide-connection.md`: connect MCP-capable IDE clients to the local Foggy runtime.
- `references/embedded-java-integration.md`: optional embedded Spring Boot integration with `foggy-dataset-model`, `@EnableFoggyFramework`, datasource, namespace, and bundle checks.
- `references/sales-drop-example.md`: optional bundled SQLite example with demo data, TM/QM assets, and replay command.
- `references/feedback.md`: prepare GitHub bug or optimization feedback with sanitized evidence.
- `references/production-permission-next-phase.md`: explain production permission boundaries without implementing them in this onboarding flow.
- `references/release-validation.md`: validate release-downloaded Skill, CLI, and Java launcher assets without source checkouts.

## Bundled Assets

- `assets/sales-drop-demo/schema.sql`: SQLite schema for the optional example.
- `assets/sales-drop-demo/data.sql`: deterministic example rows.
- `assets/sales-drop-demo/models`: example TM/QM resources.
- `assets/sales-drop-demo/queries`: smoke and question-bank query payloads.
- `assets/sales-drop-demo/question-bank.json`: natural-language example question bank.
- `assets/github-issue-template.md`: sanitized issue template.

## Output Rules

When finishing setup, modeling, or debugging, report:

- Runtime URL, namespace, port, datasource mode, SQLite path if used, and model directory.
- Commands run and pass/fail status.
- Runtime identity and security mode from `capabilities`.
- Files created, copied, or modified.
- Evidence directory and key output files.
- Failure points and exact repairs.
- Remaining assumptions, especially datasource ownership and production permission deferral.

When providing MCP client configuration, keep runtime metadata separate from `mcpServers`:

- Default `mcpServers` output must use only client-supported connection fields: `url` and required `headers`.
- Express the namespace as `headers.X-NS`; do not add a top-level `namespace` field.
- If a named MCP client requires `type` or `transport`, provide that as a clearly labeled optional variant only.
- Do not put `dataSource`, `security`, `namespace`, `runtimeApiBaseUrl`, `endpoint`, `env`, `sqlitePath`, `datasourceMode`, `evidenceDir`, or `validationResult` inside `mcpServers` unless the user's named MCP client documentation explicitly supports that field.
- Report Runtime URL, datasource, SQLite path, `securityMode`, evidence directory, and validation results separately as runtime information or validation results after the MCP client config.
