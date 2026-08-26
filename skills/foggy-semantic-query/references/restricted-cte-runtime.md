# Restricted CTE Runtime Checks

Use this reference when the task is specifically about restricted Compose/CTE scripts or standalone fsscript orchestration through Runtime API.

This page documents direct Runtime CLI checks. It is not an Analytics Function request template:
do not copy `--base-url`, `--namespace`, auth options, filenames, or CLI flags into Function
arguments. For FAP/Console, use the exact envelopes in `query-model-dsl.md` and
`compose-script.md`.

## Preflight

Resolve runtime URL and namespace, then record capabilities:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> capabilities
```

Continue only when the required capability is supported. If a command exits with unsupported capability, stop that workflow and do not call private endpoints.

## Compose Commands

Validate first:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> compose validate --script <compose.fsscript>
```

Preview before execute when SQL or plan diagnostics are enough:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> compose preview --script <compose.fsscript>
```

Execute only in dev/test when row evidence is required:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> compose execute --script <compose.fsscript>
```

Use `--script -` for stdin and `--script-text` only for short smoke checks. Pass parameters as a JSON object with `--params <params.json>`.

## Query-model DSL_CTE Stage Graph

An ordinary total, count, or grouped summary stays in query-model `columns`/`groupBy`; it does not
need `route: "DSL_CTE"`. For a documented controlled DSL_CTE recipe:

- the first stage uses `input: {"model": "<exact described model>"}` and omits `inputs`;
- every later `inputs` entry exactly names a stage declared earlier in the stages array;
- `source`, `input`, table names, and model names are not implicit stage names;
- after `DSL_CTE_STAGE_REFERENCE_INVALID`, correct the graph and validate again. Never execute the
  rejected plan.

Use only the stage shapes and expression signatures documented in `query-model-dsl.md`. A stage
must not smuggle raw SQL, arbitrary database functions, identity, policy, datasource, tenant, or
routing values into `executable_plan`.

## Standalone FSScript

Use standalone fsscript only when the task needs general orchestration. It is not the default path for ordinary queryModel DSL or composeScript debugging.

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> fsscript run --script <workflow.fsscript>
```

Enable the CTE bridge only when the script intentionally calls host-injected `foggy.cte.validate`, `foggy.cte.preview`, or `foggy.cte.execute`:

```powershell
foggy-runtime --base-url <runtime-url> --namespace <ns> fsscript run --script <workflow.fsscript> --enable-cte-bridge
```

If bridge access is not enabled, `foggy.cte.*` should fail with `FSSCRIPT_CTE_BRIDGE_DENIED`. Treat that as the expected boundary unless the current dev/test task explicitly requires the bridge.

## Sandbox Boundary

If Runtime API returns `COMPOSE_SANDBOX_VIOLATION`, do not work around it through:

- Standalone fsscript imports.
- Private endpoints.
- Raw SQL execution.
- Filesystem, network, Java class, Python module, or host context access.
- Injected security, datasource, tenant, or routing parameters.

Report the unsupported operation and the closest governed query alternative.

## Evidence

Report capability state, command, exit code, validation or preview result, execution decision, and any `error.code`, `error.phase`, diagnostics, or sandbox violation.
