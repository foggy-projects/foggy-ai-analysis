# Datasource And Semantic Modeling

Use this reference when the user has a datasource or wants to create namespace/TM/QM resources.

For detailed command gates, exit codes, and failure handling, read `runtime-cli-command-rules.md` first.

## Sequence

1. Confirm runtime readiness with `wait-ready` and `capabilities`.
2. Choose namespace and datasource mode.
3. Inspect tables before writing models.
4. Generate or update TM/QM files, plus model-list registration when the host project requires it.
5. Validate models.
6. Add or update the model bundle.
7. Refresh and describe query models.
8. Validate and execute query payloads.

When the user explicitly asks to publish, update, submit to runtime, or make MCP/Runtime query service effective, continue with `semantic-layer-publish-runbook.md`.

## Datasource Discovery

For a named datasource:

```powershell
foggy-runtime --base-url <url> --namespace <ns> datasources list
foggy-runtime --base-url <url> --namespace <ns> datasources test <name>
foggy-runtime --base-url <url> --namespace <ns> datasources diagnostics
foggy-runtime --base-url <url> --namespace <ns> tables list --data-source <name>
foggy-runtime --base-url <url> --namespace <ns> tables inspect --data-source <name> --table <table> --include-indexes
```

For the runtime default SQLite datasource, omit `--data-source` when the current runtime capability supports default datasource execution.

Keep user business data and the bundled sales-drop demo data separate. The sales-drop replay owns and reseeds a local SQLite file; do not point that replay at a user database. For user data, register or select a named datasource, bind it to the namespace, then validate and query that namespace explicitly.

Read-only SQL probes:

```powershell
foggy-runtime --base-url <url> --namespace <ns> sql query --data-source <name> --sql "select * from <table> limit 5" --max-rows 5 --timeout-seconds 5
```

Do not run mutating SQL against user data unless the user explicitly asks for it.

When a Runtime API-managed datasource must survive runtime restarts, capture datasource persistence evidence from the runtime launch configuration and a restart check:

```powershell
foggy-runtime --base-url <url> --namespace <ns> datasources diagnostics
foggy-runtime --base-url <url> --namespace <ns> datasources list
foggy-runtime --base-url <url> --namespace <ns> datasources test <name>
```

Report the registry and datasource file paths configured at runtime startup, such as `runtime-datasources.json` or `runtime-datasource-registry.json`. Prefer `datasources diagnostics` when supported because it returns the resolved registry path, namespace bindings, persisted datasource records, and pool lifecycle state. Verify the files exist, restart the runtime, and prove the datasource is still returned by `datasources diagnostics` or `datasources list`. Do not guess whether paths live under the runtime working directory, user home, or a configured runtime home.

## Model Files

Keep namespace resources in a local folder that can be added as a runtime-managed bundle:

```text
models/
  model/
    <Name>.tm
  query/
    <Name>QueryModel.qm
```

Do not create `model-list.yml` for runtime-managed bundles unless the target host already requires that registration file.

Generate TM fields from actual table columns, sample values, and user language. Prefer clear business descriptions over raw column names. Explicitly document units, date semantics, enum meanings, and owner/status dimensions.

Before writing or reviewing concrete TM/QM fields, read `tm-qm-configuration.md`. It defines the practical field classification, measure aggregation, date-grain, money-unit, QM exposure, optional host-specific model-list, and validation rules.

## Existing Query Model Schema

When the user asks which fields a QM exposes, do not infer from the `.qm` file alone. Use Runtime API/CLI metadata after the model has been loaded:

```powershell
foggy-runtime --base-url <url> --namespace <ns> models list
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName>
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName> --field <fieldName>
```

Summarize the described fields with `fieldName`, title/caption, type, dimension or measure role, filterability, sortability, aggregation support, and description when present. Keep query guidance grounded in the described `fieldName` values.

## Validate And Refresh

```powershell
foggy-runtime --base-url <url> --namespace <ns> models validate --models-dir <models-dir> --include-stack-trace
foggy-runtime --base-url <url> --namespace <ns> bundles add --name <bundle> --path <models-dir> --watch --replace
foggy-runtime --base-url <url> --namespace <ns> models refresh
foggy-runtime --base-url <url> --namespace <ns> models describe <QueryModelName>
```

If validation fails, classify the issue before editing:

```text
schema mismatch
missing table or column
type mismatch
bad expression or DSL syntax
caption/description ambiguity
runtime capability gap
```

Report validation output in terms the runtime returns, such as total files, valid files, invalid files, warnings, failed files, error category, error phase, file, line, message, and suggestion. If the response distinguishes `MODEL` from `CASCADING`, show `MODEL` errors first and explain that cascading errors usually clear after the upstream TM/QM issue is fixed.

Use `/api/semantic-layer/validate` only as a legacy Spring fallback when Runtime API `models.validate` is unsupported or absent and the project still documents that endpoint.

## Query Check

```powershell
foggy-runtime --base-url <url> --namespace <ns> query validate <QueryModelName> --payload <payload.json>
foggy-runtime --base-url <url> --namespace <ns> query execute <QueryModelName> --payload <payload.json>
```

Save payloads that represent user questions; they become the seed for the question bank.
