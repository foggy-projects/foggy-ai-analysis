# Runtime CLI Command Rules

Use this reference whenever the task needs `foggy-runtime` command evidence. This file is bundled with `foggy-ai-analysis`; do not assume the external `foggy-runtime-cli-workflow` Skill is installed.

## Contract

- Use `foggy-runtime` JSON output for automated checks and evidence.
- Do not call Java/Python private endpoints.
- Do not add or use `--engine`; runtime identity comes from `capabilities`.
- Use `--output pretty` only for human inspection.
- Run read-only SQL probes only in dev/test or when the user explicitly approves the datasource access.

## Preflight

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

For commands that require Runtime API features, CLI `v0.1.16` performs capability preflight and exits with code `3` when unsupported. This covers models, query, table inspection, SQL probing, bundle/datasource/resource management, compose, and fsscript commands.

CLI `v0.1.16` accepts both `-h`/`--help` and the compatibility alias `-help` on top-level and nested commands.

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

With `foggy-runtime-cli v0.1.16` and a runtime that reports the matching capabilities, Runtime API-managed datasources are expected to support datasource add/test/bind, table discovery, read-only SQL probing, model validation/refresh/describe, and namespace-bound query execution when the runtime has the JDBC driver. Keep the public sales-drop replay on the runtime default SQLite datasource because that demo owns and reseeds its fixture file. For user business data, use a separate Runtime API-managed datasource and namespace binding, then prove the path with diagnostics plus a model/query smoke. If an older runtime does not report needed capabilities, stop at the capability failure instead of calling private endpoints.

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

Refresh and describe before querying:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> models refresh --model <QueryModel>
foggy-runtime --base-url <runtime-url> --namespace <ns> models describe <QueryModel>
```

## Query Loop

Build DSL payloads only from `models describe` output. Validate before execute:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> query validate <QueryModel> --payload <payload.json>
foggy-runtime --base-url <runtime-url> --namespace <ns> query execute <QueryModel> --payload <payload.json>
```

CLI `v0.1.16` accepts query payload `groupBy` string-array shorthand and normalizes it to Runtime API v1 object items before sending the request:

```json
{
  "columns": ["customerName", "customerSegment", "observationDate$month", "sum(salesDropAmount) as totalDrop"],
  "groupBy": ["customerName", "customerSegment", "observationDate$month"]
}
```

Raw Runtime API v1 HTTP callers that bypass the CLI should send `groupBy` as `[{"field":"customerName"}]` until the Java API adds native string-array compatibility.

Execute only when the user needs data evidence or the environment is clearly dev/test. On `FIELD_NOT_FOUND`, re-describe the model and replace only with an existing field. On `MODEL_NOT_FOUND`, run `models list` or `models refresh`; do not silently switch to a similar model. If `safeToAutoRepair=false`, explain the issue and stop before changing semantics.

## Exit Codes

| Exit | Meaning | Handling |
|---:|---|---|
| 0 | API success | Parse `data` and continue. |
| 1 | CLI or local input error | Fix command, payload path, or JSON. |
| 2 | Runtime API error | Parse `error` and `diagnostics`. |
| 3 | Unsupported capability | Stop that workflow; do not call private endpoints. |
| 4 | Transport error | Ask to start dev/test runtime or correct `--base-url`. |

## Evidence

Report commands and pass/fail status, runtime identity from `capabilities`, datasource/table inspection outcomes, changed TM/QM files and any host-specific model-list registration, model validation/refresh/describe outcomes, query validation/execution outcomes, exact `error.code` and `error.phase` when present, and remaining assumptions about namespace, datasource, fixture, and dev/test runtime status.
