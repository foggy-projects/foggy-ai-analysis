# Runtime CLI Command Rules

Use this reference whenever the task needs `foggy-runtime` command evidence. This file is bundled with `foggy-ai-analysis`; do not assume the external `foggy-runtime-cli-workflow` Skill is installed.

## Contract

- Use `foggy-runtime` JSON output for automated checks and evidence.
- Do not call Java/Python private endpoints.
- Do not add or use `--engine`; runtime identity comes from `capabilities`.
- Use `--output pretty` only for human inspection.
- Run read-only SQL probes only in dev/test or when the user explicitly approves the datasource access.

## Preflight

Apply this sequence to the affected live workflow, not to every documentation edit. Reuse a healthy Runtime and current capabilities for unchanged runtime/security context; the CLI's per-command capability checks still apply. Datasource registration, rebinding, refresh, restart, and fixture reseeding are conditional operations within the authorized task, not prerequisites for reading an existing model or constructing a query.

Resolve runtime URL from the user, `FOGGY_RUNTIME_API_URL`, or the public onboarding defaults. Resolve namespace from the user, `FOGGY_NAMESPACE`, or state the assumed namespace.

If a runtime was just started:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <namespace> wait-ready --timeout-seconds 90 --interval-seconds 2
```

Then always record capabilities before feature work:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <namespace> capabilities
```

Continue only when `success=true` and the needed capability is supported. Record `engine`, `runtimeApiVersion`, `data.schemaVersion`, `data.securityMode`, and relevant `data.capabilities`. If `securityMode=auth-code`, pass `--auth-code` or set `FOGGY_RUNTIME_API_AUTH_CODE`.

Keep management and data credentials separate:

- `--auth-code` / `FOGGY_RUNTIME_API_AUTH_CODE` becomes
  `X-Foggy-Runtime-Code` for protected management operations.
- `--authorization` / `FOGGY_RUNTIME_AUTHORIZATION` is an optional complete,
  opaque `Authorization` value for model list/describe, query, Compose, and
  dimension-member calls. The CLI does not add `Bearer`.
- The two options may coexist but do not grant each other's permissions.
- Do not print, persist, shell-trace, or include the Authorization value in
  evidence. Cross-origin redirects must not receive it.

For commands that require Runtime API features, CLI `v0.1.21` performs capability preflight and exits with code `3` when unsupported. This covers models, query, table inspection, SQL probing, bundle/datasource/resource management, compose, and fsscript commands.

CLI `v0.1.21` accepts both `-h`/`--help` and the compatibility alias `-help` on top-level and nested commands.

## Datasource Exploration

For a Runtime API-managed datasource, use the matching JDBC type and URL. SQLite, MySQL, PostgreSQL, and H2 are valid dev/test examples when the runtime has the driver:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources add --name <datasource-name> --type sqlite --jdbc-url jdbc:sqlite:<sqlite-db-path> --replace
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources add --name <datasource-name> --type mysql --jdbc-url "jdbc:mysql://<host>:<port>/<database>?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" --username <user> --password-env <PASSWORD_ENV> --replace
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources test <datasource-name>
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources bind --namespace <ns> --data-source <datasource-name>
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources binding --namespace <ns>
foggy-runtime --base-url <runtime-url> --namespace <ns> datasources diagnostics
```

Use `datasources binding` after `datasources bind` when evidence must show the namespace registry entry. When the runtime supports `datasources.diagnostics`, use `datasources diagnostics` as the primary evidence for registry path, namespace bindings, persisted datasource records, and pool lifecycle state. When evidence must show managed datasource persistence or registry paths, also record the launcher or runtime start configuration for files such as `runtime-datasources.json` or `runtime-datasource-registry.json`, verify the files exist, restart the runtime, and prove `datasources diagnostics` or `datasources list` still returns the datasource. Do not infer paths from `.foggy-runtime`, the current working directory, or the user's home directory.

With `foggy-runtime-cli v0.1.21` and a runtime that reports the matching capabilities, Runtime API-managed datasources are expected to support datasource add/test/bind, table discovery, read-only SQL probing, model validation/refresh/describe, and namespace-bound query execution when the runtime has the JDBC driver. Keep the public sales-drop replay on the runtime default SQLite datasource because that demo owns and reseeds its fixture file. For user business data, use a separate Runtime API-managed datasource and namespace binding, then prove the path with diagnostics plus a model/query smoke. If an older runtime does not report needed capabilities, stop at the capability failure instead of calling private endpoints.

List and inspect tables before editing model files:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> tables list
foggy-runtime --base-url <runtime-url> --namespace <ns> tables list --data-source <datasource-name>
foggy-runtime --base-url <runtime-url> --namespace <ns> tables inspect --data-source <datasource-name> --table <table> --include-indexes
```

Use a small read-only sample only when value examples are needed for captions, units, enum descriptions, or field classification:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> sql query --data-source <datasource-name> --sql "select * from <table> limit 20" --max-rows 20
```

Do not use `sql query` for mutation, DDL, stored procedures, multi-statement scripts, production permission bypasses, or private endpoint workarounds.

## Model Loop

Generate or patch TM/QM files only after the datasource schema is confirmed. Patch model-list registration only when the target embedded or legacy host already uses one.

List existing query models before inspecting an unknown model name:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models list
```

Use `models describe` as the primary query-model schema inspection path:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel> --field <fieldName>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel> --include-examples
foggy-runtime --base-url <runtime-url> --namespace <ns> --authorization <opaque-value> models describe <QueryModel>
```

Render describe output as a compact field table when the user asks what fields, dimensions, measures, filterability, sortability, or aggregation options a QM exposes. Use described field names exactly when building query payloads, including dimension property names such as `<dimension>$id` or `<dimension>$caption`.

Do not use legacy `/mcp/analyst/metadata` or `/mcp/analyst/description-model-internal` as the primary schema path. Use those endpoints only when the user is on a legacy Spring service with no Runtime API support and explicitly needs that fallback; label the evidence as legacy.

Validate the model directory:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models validate --models-dir <models-dir>
foggy-runtime --base-url <runtime-url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
```

If validation fails, classify before editing:

- Many missing tables, broad demo tables under a lite runtime, or tables outside the inspected source: schema or fixture mismatch.
- Known table with missing/renamed columns: re-run `tables inspect` and repair only proven differences.
- Existing table and columns: treat as TM/QM syntax, loader, or Runtime API behavior.
- When the response separates model errors and cascading errors, fix `MODEL` errors first; treat `CASCADING` errors as downstream symptoms until the upstream TM/QM issue is repaired.

The Runtime API/CLI `models validate` path replaces the old Spring `/api/semantic-layer/validate` workflow. Use the old endpoint only as a legacy fallback for projects that still expose it and lack Runtime API support:

```powershell
Invoke-RestMethod -Method Post `
  -Uri "http://localhost:<port>/api/semantic-layer/validate" `
  -ContentType "application/json" `
  -Body (@{
    path = "<models-dir>"
    namespace = "<ns>"
    clearExisting = $true
    includeStackTrace = $true
  } | ConvertTo-Json -Depth 5)
```

Attach local models when they should survive runtime restarts:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> bundles add --name <ns>-dev-models --path <models-dir> --watch --replace
```

After model changes, refresh within the authorized scope and describe before querying. For an unchanged existing model, describe it without an unnecessary refresh:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models refresh --model <QueryModel>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel>
```

## Query Loop

Build DSL payloads only from `models describe` output. Validate before execute:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> query validate <QueryModel> --payload <payload.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> query execute <QueryModel> --payload <payload.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> --authorization <opaque-value> members list <QueryModel> <dimension-field>
```

For a protected model, use the same caller Authorization for describe,
validate/execute, Compose leaves, and member lookup. A denial must be reported as
a model-permission failure; do not retry without Authorization or switch to a
private endpoint.

CLI `v0.1.21` accepts query payload `groupBy` string-array shorthand and normalizes it to Runtime API v1 object items before sending the request:

```json
{
  "columns": ["customerName", "customerSegment", "observationDate$yearMonth", "sum(salesDropAmount) as totalDrop"],
  "groupBy": ["customerName", "customerSegment", "observationDate$yearMonth"]
}
```

This `$yearMonth` field must be explicitly supplied by a TM self date dimension or a physical date
dimension and returned by `models describe`. The CLI does not append date grains to a plain
`DATE` / `DATETIME` property.

Raw Runtime API v1 HTTP callers that bypass the CLI should send `groupBy` as `[{"field":"customerName"}]` until the Java API adds native string-array compatibility.

### Static dictionary `$caption` smoke

When `models describe <QueryModel>` explicitly returns both a static-dictionary raw field and
`<field>$caption`, the CLI passes the standard DSL through unchanged. Java Runtime owns code/label
translation; the CLI does not keep a dictionary map or rewrite result rows. Example payload:

```json
{
  "columns": ["orderStatus", "orderStatus$caption", "orderCount"],
  "slice": [
    {"field": "orderStatus", "op": "=", "value": "Awaiting pickup"}
  ],
  "groupBy": ["orderStatus", "orderStatus$caption"],
  "orderBy": ["-orderCount"],
  "limit": 20
}
```

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel> --field orderStatus
foggy-runtime --base-url <runtime-url> --namespace <ns> query validate <QueryModel> --payload <dict-query.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> query execute <QueryModel> --payload <dict-query.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> members list <QueryModel> orderStatus
```

Verify that `orderStatus` remains the raw code, `orderStatus$caption` is the label, and the label
filter is converted server-side to the field's real code type. Do not order by `$caption` or use
range/fuzzy operators on it; model a database dimension when display-name ordering is required.
If describe does not return `$caption`, treat the feature as unavailable on that runtime and do not
generate the field.

Execute only when the user needs data evidence or the environment is clearly dev/test. On `FIELD_NOT_FOUND`, re-describe the model and replace only with an existing field. On `MODEL_NOT_FOUND`, run `models list` or `models refresh`; do not silently switch to a similar model. If `safeToAutoRepair=false`, explain the issue and stop before changing semantics.

A zero exit code or `success=true` can include Runtime `warnings`. Inspect warnings from both validate
and execute before presenting the answer. Treat stable fields such as `code`, `path`, `property`,
`action`, `semanticImpact`, `allowedProperties`, normalized request fragments, and `docsRef` as the
contract. Free-text `suggestedAction` is advisory and may be absent. If an ignored or normalized option
can change query meaning, re-describe the model and validate a corrected payload when a supported
equivalent preserves the user's intent; otherwise report the limitation and do not describe the
result as matching the unsupported semantics. Informational warnings that do not affect semantics do
not turn a successful request into a failure.

## Query PNG export

For an existing model, use `foggy-semantic-query` for DSL construction when
available, then export its real query result as a table, bar chart or line chart.
The Java Runtime performs the query and PNG rendering in process, using the
ordinary namespace and permission checks and bundled Chinese fonts. No Docker,
browser, Node, external render service or AI image model is needed.

This feature is on the `codex/query-image-export` development branches; its
release version is not yet assigned. Published CLI `0.1.24` must not be assumed
to include it. A matching new CLI and Java Runtime are required. This command
uses MCP `tools/list` discovery, rather than a Runtime API capability flag, and
requires `dataset.export_image` on `/mcp/analyst/rpc` by default. Missing tools
return `UNSUPPORTED_IMAGE_TOOL` / `image.discovery`, exit `3`; check the Runtime
version, configured endpoint and namespace policy without using a private fallback.

Reuse the caller's namespace and optional complete opaque Authorization through
`FOGGY_RUNTIME_AUTHORIZATION`. Do not put credentials or connection/runtime
parameters in the DSL, title or column captions. Validate the described model's
query first. `monthly-sales.json` below contains only the query DSL; `month` and
`salesAmount` are illustrative described result fields, not guaranteed demo fields.

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> query export-image <QueryModel> --payload monthly-sales.json --kind table --columns columns.json --title "月度销售明细" --out sales-table.png
foggy-runtime --base-url <runtime-url> --namespace <ns> query export-image <QueryModel> --payload monthly-sales.json --kind bar --x month --y salesAmount --y-label "销售额" --unit "元" --title "月度销售额" --out sales-bar.png
foggy-runtime --base-url <runtime-url> --namespace <ns> query export-image <QueryModel> --payload monthly-sales.json --kind line --x month --y salesAmount --y-label "销售额" --unit "元" --title "销售额趋势" --out sales-line.png
```

- `--x` and `--y` are required for charts and name final result fields, including
  aliases. The renderer preserves query order and values; use the DSL for sorting,
  aggregation and date completion. Line nulls remain gaps.
- Table `--columns <columns.json>` accepts an array of `{field, caption?, unit?}`.
  Captions default to schema titles or field names; supply known units explicitly.
  For the table example, save `[{"field":"month","caption":"月份"},{"field":"salesAmount","caption":"销售额","unit":"元"}]` as `columns.json` first.
- Display limits are 50 table rows, 40 bars, 100 line points and 12 table columns;
  `--max-rows` may lower them. Width is 640–2400 px, default 1200. Requested height
  is 360–2400 px for tables and 520–2400 px for charts; table height grows up to
  4096 px. PNGs are limited to 8 million pixels and 8 MiB.
- Empty/denied queries, unsupported font glyphs and unreadable layouts produce no
  PNG. This is one flat QueryModel result with a single chart series; Compose
  multi-results and tree/grid Pivot are not supported.
- The output directory must already exist. The CLI requests native inline MCP
  `image/png` content, validates it, then atomically replaces `--out`; failures
  preserve the old file. It does not download image links.

Keep the saved PNG and CLI JSON file/dimensions/bytes/`rowsRendered`/`rowsReturned`/
`truncated` as evidence. Pagination and display caps visibly mark partial results.
Inspect the actual PNG for Chinese text, spacing, font sizes, titles, field names
and units before sharing. Never retain Authorization values or Base64 in logs.

## Exit Codes

| Exit | Meaning | Handling |
|---:|---|---|
| 0 | API success | Parse `data` and continue. |
| 1 | CLI or local input error | Fix command, payload path, or JSON. |
| 2 | Runtime API error | Parse `error` and `diagnostics`. |
| 3 | Unsupported capability | Stop that workflow; do not call private endpoints. |
| 4 | Transport error | Ask to start dev/test runtime or correct `--base-url`. |

## Evidence

Report commands and pass/fail status, runtime identity from `capabilities`, datasource/table inspection outcomes, changed TM/QM files and any host-specific model-list registration, model validation/refresh/describe outcomes, query validation/execution outcomes, exact `error.code` and `error.phase` when present, Runtime warning count/codes and semantic impact when present, and remaining assumptions about namespace, datasource, fixture, and dev/test runtime status.
