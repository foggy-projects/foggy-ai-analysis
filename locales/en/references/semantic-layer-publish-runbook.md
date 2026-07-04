# Semantic Layer Publish/Update Runbook

Use this runbook when the user wants to publish, update, submit to runtime, or make a TM/QM semantic layer effective for Runtime API or MCP query service.

In this document, "publish/update semantic layer" means registering the user's current Git working tree model directory as a Runtime managed bundle, then refreshing Runtime API/MCP query models so the latest TM/QM files are loaded.

## Boundary

The user's own Git and engineering process owns TM/QM versioning, branch strategy, approvals, rollback, audit, tenant permission governance, and RBAC. This Skill does not implement or replace those controls.

This runbook only covers:

1. Runtime/CLI/Skill installation readiness checks.
2. Datasource creation, testing, and namespace binding.
3. Table inspection and read-only SQL probing.
4. TM/QM file generation or modification.
5. `models validate`.
6. `bundles add` or update.
7. `models refresh`.
8. `models describe`.
9. `query validate` and `query execute` smoke checks.
10. MCP endpoint probing and client connection information.

## Preconditions

Confirm these values before running commands:

```text
runtime-url=<runtime API base URL, for example http://127.0.0.1:18066>
namespace=<namespace>
models-dir=<absolute or workspace-relative path to the TM/QM model directory>
bundle=<runtime bundle name>
datasource-name=<Runtime API datasource name>
query-model=<QueryModelName>
evidence-dir=<directory where JSON outputs and pass/fail notes are saved>
```

Required state:

- The user already manages TM/QM files in Git. Git versioning, approval, rollback, audit, and RBAC are the user's responsibility.
- `foggy-runtime-cli` is installed.
- Runtime API is started.
- Runtime URL, namespace, models-dir, bundle name, and datasource name are known.
- If `securityMode=auth-code`, pass `--auth-code <code>` on CLI commands or set `FOGGY_RUNTIME_API_AUTH_CODE`.
- Datasource passwords must stay in environment variables, secret stores, or runtime datasource configuration. Do not write passwords into TM/QM files.

Use JSON output and save every command result:

```powershell
New-Item -ItemType Directory -Force -Path <evidence-dir> | Out-Null

# Optional when Runtime API reports securityMode=auth-code:
$env:FOGGY_RUNTIME_API_AUTH_CODE = "<auth-code>"
```

Record a command as PASS only when the JSON response has `success=true` and the expected target object is present. Record FAIL with the command, output file path, exact `error.code`, `error.phase`, message, and the next repair action.

## Step 1: Runtime Readiness And Capabilities

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> wait-ready --timeout-seconds 90 --interval-seconds 2 |
  Tee-Object -FilePath <evidence-dir>/01-wait-ready.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> capabilities |
  Tee-Object -FilePath <evidence-dir>/02-capabilities.json
```

PASS criteria:

- Runtime is reachable.
- `capabilities` returns `success=true`.
- Record `engine`, `runtimeApiVersion`, `schemaVersion`, `securityMode`, and relevant capabilities for datasource, bundle, model, query, SQL, and MCP work.
- If `securityMode=auth-code`, rerun later CLI commands with `--auth-code <code>` or keep `FOGGY_RUNTIME_API_AUTH_CODE` set.

Stop if Runtime API capability is missing. Do not call private Java or Python endpoints as a workaround.

## Step 2: Datasource Validation

If the datasource does not exist yet, create it with a Runtime API-managed datasource command supported by the target runtime. Examples:

```powershell
# SQLite example
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources add --name <datasource-name> --type sqlite --jdbc-url jdbc:sqlite:<sqlite-db-path> --replace |
  Tee-Object -FilePath <evidence-dir>/03-datasource-add.json

# MySQL example. Keep the password in an environment variable, not in TM/QM files.
$env:FOGGY_DB_PASSWORD = "<password>"
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources add --name <datasource-name> --type mysql --jdbc-url "jdbc:mysql://<host>:<port>/<database>?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC" --username <user> --password-env FOGGY_DB_PASSWORD --replace |
  Tee-Object -FilePath <evidence-dir>/03-datasource-add.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources bind --namespace <namespace> --data-source <datasource-name> |
  Tee-Object -FilePath <evidence-dir>/04-datasource-bind.json
```

Validate the datasource and namespace binding:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources list |
  Tee-Object -FilePath <evidence-dir>/05-datasources-list.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources test <datasource-name> |
  Tee-Object -FilePath <evidence-dir>/06-datasource-test.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> datasources binding --namespace <namespace> |
  Tee-Object -FilePath <evidence-dir>/07-datasource-binding.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> tables list --data-source <datasource-name> |
  Tee-Object -FilePath <evidence-dir>/08-tables-list.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> tables inspect --data-source <datasource-name> --table <key-table> --include-indexes |
  Tee-Object -FilePath <evidence-dir>/09-table-inspect-key-table.json
```

Use at least one key business table in `tables inspect`. If value samples are needed to repair captions, units, or enum meanings, use a small read-only SQL probe:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> sql query --data-source <datasource-name> --sql "select * from <key-table> limit 20" --max-rows 20 --timeout-seconds 5 |
  Tee-Object -FilePath <evidence-dir>/10-sql-sample-key-table.json
```

Do not run mutating SQL, DDL, stored procedures, or broad production scans unless the user explicitly authorizes that operation.

## Step 3: Model Validation

Validate before registering or refreshing the bundle:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models validate --models-dir <models-dir> --include-stack-trace |
  Tee-Object -FilePath <evidence-dir>/11-models-validate.json
```

PASS criteria:

- JSON response has `success=true`.
- No invalid TM/QM files remain.
- Warnings are understood and acceptable for the intended smoke.

If validation fails, do not publish, do not run `bundles add`, and do not run `models refresh`. Repair TM/QM syntax, field references, datasource schema mismatch, missing tables, missing columns, type mismatch, or runtime capability gaps first.

If the output separates `MODEL` and `CASCADING` errors, repair `MODEL` errors first. Treat `CASCADING` errors as downstream symptoms until upstream TM/QM errors are fixed.

## Step 4: Register Or Update Runtime Bundle

After validation passes, register or update the model directory as a runtime managed bundle:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> bundles add --name <bundle> --path <models-dir> --watch --replace |
  Tee-Object -FilePath <evidence-dir>/12-bundles-add-update.json
```

Meaning:

- `--replace` updates an existing bundle with the same name.
- `--watch` asks Runtime to observe the directory for changes when supported.
- This command is not Git version management, release approval, audit, rollback, or RBAC. It only registers or updates Runtime's bundle registry entry for the supplied model directory.

PASS criteria:

- JSON response has `success=true`.
- Bundle name and path match the intended namespace/model directory.

## Step 5: Refresh Models

Refresh Runtime API query model metadata after bundle registration:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models refresh |
  Tee-Object -FilePath <evidence-dir>/13-models-refresh.json
```

If the installed CLI and runtime support targeted refresh, use it for a narrower check:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models refresh --model <QueryModelName> |
  Tee-Object -FilePath <evidence-dir>/13-models-refresh-QueryModelName.json
```

PASS criteria:

- Refresh succeeds.
- The target QueryModel is present in refresh output or in the next `models list` and `models describe` results.

## Step 6: Describe Query Models

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models list |
  Tee-Object -FilePath <evidence-dir>/14-models-list.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models describe <QueryModelName> |
  Tee-Object -FilePath <evidence-dir>/15-models-describe-QueryModelName.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> models describe <QueryModelName> --field <fieldName> |
  Tee-Object -FilePath <evidence-dir>/16-models-describe-field.json
```

Build query payloads only from `fieldName` values returned by `models describe`. Do not infer field names from captions, raw database columns, old docs, or similar model names. Include dimension property suffixes exactly as described, such as `<dimension>$id`, `<dimension>$caption`, or date-grain fields such as `<dateField>$month` when present.

PASS criteria:

- `models list` contains the target QueryModel.
- `models describe <QueryModelName>` returns the fields needed by the smoke.
- Field-level describe confirms the main time field, core dimension, core measure, and filter field.

## Step 7: Query Smoke

Create a small smoke payload from described field names. The payload must cover:

- One main time field.
- One core dimension.
- One core measure.
- One filter condition.

Example CLI payload using the string-array `groupBy` shorthand supported by `foggy-runtime-cli`:

```json
{
  "columns": [
    "<mainTimeField>$month",
    "<coreDimensionField>",
    "sum(<coreMeasureField>) as totalMeasure"
  ],
  "groupBy": [
    "<mainTimeField>$month",
    "<coreDimensionField>"
  ],
  "slice": [
    {
      "field": "<filterField>",
      "op": "=",
      "value": "<small-scope-value>"
    }
  ],
  "limit": 20
}
```

Raw Runtime API v1 HTTP callers that bypass the CLI should use the runtime-supported groupBy object form, for example:

```json
{
  "groupBy": [
    { "field": "<mainTimeField>$month" },
    { "field": "<coreDimensionField>" }
  ]
}
```

Validate before execute:

```powershell
foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> query validate <QueryModelName> --payload <payload.json> |
  Tee-Object -FilePath <evidence-dir>/17-query-validate.json

foggy-runtime --output json --base-url <runtime-url> --namespace <namespace> query execute <QueryModelName> --payload <payload.json> |
  Tee-Object -FilePath <evidence-dir>/18-query-execute.json
```

Do not run broad queries against production data without explicit user approval. Use small time windows, low limits, and narrow filters for smoke. On `FIELD_NOT_FOUND`, re-run `models describe` and replace only with described fields. On `MODEL_NOT_FOUND`, run `models list` and `models refresh`; do not silently switch to a similar model.

## Step 8: MCP Service Probe

Endpoint:

```text
<runtime-url>/mcp/analyst/rpc
```

Probe `tools/list` with namespace header:

```powershell
$body = @{
  jsonrpc = "2.0"
  id = 1
  method = "tools/list"
  params = @{}
} | ConvertTo-Json -Depth 5

Invoke-RestMethod `
  -Method Post `
  -Uri "<runtime-url>/mcp/analyst/rpc" `
  -ContentType "application/json" `
  -Headers @{ "X-NS" = "<namespace>" } `
  -Body $body |
  ConvertTo-Json -Depth 20 |
  Tee-Object -FilePath <evidence-dir>/19-mcp-tools-list.json
```

If the runtime requires auth, include only the release-supported auth header documented by the runtime/launcher or use the supported CLI auth-code flow where applicable. Do not invent token fields.

MCP client configuration should contain only client-supported connection fields. For the generic client shape, keep `mcpServers` limited to `url` and `headers`:

```json
{
  "mcpServers": {
    "foggy-analysis": {
      "url": "<runtime-url>/mcp/analyst/rpc",
      "headers": {
        "X-NS": "<namespace>"
      }
    }
  }
}
```

Do not put datasource name, security mode, namespace metadata, runtime API base URL, evidence path, validation result, or other runtime metadata inside the `mcpServers` entry unless a named MCP client explicitly documents those fields.

PASS criteria:

- JSON-RPC response contains a tools list.
- Expected analysis/model/query tools are present for the target runtime.
- Namespace header is set as `X-NS`.

## Step 9: Publish/Update Report

Return a concise report with pass/fail status and evidence paths:

```text
runtime URL:
namespace:
datasource name:
models-dir:
bundle name:
query model names:
capabilities summary:
datasource test result:
table inspect result:
models validate result:
bundle add/update result:
refresh result:
describe result:
query smoke result:
MCP tools/list result:
remaining assumptions:
```

For each item, include:

- PASS or FAIL.
- Command or payload file used.
- JSON output file path under `<evidence-dir>`.
- Key IDs, model names, and field names.
- Exact error code, phase, and message for failures.
- Whether any repair changed TM/QM files, datasource binding, or bundle registration.

## Prohibited Actions

- Do not make Git version management, approval, rollback, audit, tenant governance, or RBAC a required Foggy Skill capability.
- Do not suggest changing production permission strategy as part of this runbook.
- Do not call private Java or Python endpoints.
- Do not bypass `models validate`.
- Do not continue to `bundles add` or `models refresh` when validation fails.
- Do not write datasource passwords into TM/QM files.
- Do not place runtime metadata in an MCP client's `mcpServers` field.
- Do not run broad production queries without explicit user approval.
