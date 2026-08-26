# Embedded Analytics Console and optional FAP

Use this reference when a user asks whether Analytics Console ships with the standard launcher,
whether it needs a separate installation, how to enable it, or how it connects to FAP.

## Release capability check

Do not infer Console availability from the JAR name alone. Read
`runtime-launcher-manifest.json` and require:

```text
features.analyticsConsole.embedded=true
features.analyticsConsole.enabledByDefault=false
features.analyticsConsole.springProfile=analytics-console
features.analyticsConsole.fapEnabledByDefault=false
```

The embedded Console first ships in standard launcher `0.1.18`. Older launcher releases do not
support the new start-script opt-in. Resolve the selected release through the stable stack and
still treat its manifest as the final capability contract.

## Installation and activation

For a launcher that advertises the feature, the Console backend and prebuilt SPA are already
inside the executable JAR. The user does not install Node.js, npm, a web server, or a separate
Console archive.

Console is an explicit local dev/test opt-in. PowerShell:

```powershell
$start = .\start-foggy-runtime.ps1 -Port 18066 -AnalyticsConsole | ConvertFrom-Json
foggy-runtime --base-url $start.runtimeUrl wait-ready --timeout-seconds 90
foggy-runtime --base-url $start.runtimeUrl capabilities
```

Bash:

```bash
ANALYTICS_CONSOLE_ENABLED=true PORT=18066 ./start-foggy-runtime.sh
foggy-runtime --base-url http://127.0.0.1:18066 wait-ready --timeout-seconds 90
foggy-runtime --base-url http://127.0.0.1:18066 capabilities
```

Then verify:

```text
Console web=http://127.0.0.1:18066/analytics-console/
Console product API=http://127.0.0.1:18066/analytics-console/api/v1
Analytics Runtime API=http://127.0.0.1:18066/analytics/api/v1
```

Default startup without `-AnalyticsConsole` or `ANALYTICS_CONSOLE_ENABLED=true` must leave all
three routes unavailable. The start scripts store the Console catalog and Function traces below
their runtime work directory unless the caller explicitly overrides those paths.

For direct CLI inspection of the Analytics lane, use its separate base URL and identity:

```bash
FOGGY_ANALYTICS_RUNTIME_API_URL=http://127.0.0.1:18066/analytics \
  foggy analytics capabilities
```

Do not send Analytics credentials through Foggy Runtime API variables. Runtime API and Analytics
Runtime use separate client environment variables and authority contracts.

## FAP integration boundary

FAP is not bundled into the launcher and does not need to run for the Console shell, Catalog, or
direct Analytics Runtime lane. The expected disabled state is visible as `FAP NOT CONFIGURED`; the
browser must not fall back to direct LLM access.

Enabling FAP is a separate, explicitly authorized host deployment operation. The host provides:

- an FAP Service Provider base URL and server-side authorization;
- an opaque workspace/model/provider binding;
- the published question Skill, Capability, and five Analytics Function references with matching
  schema delivery;
- callback capability binding and authorization;
- a host-managed Console subject/authority resolver for production.

Launcher startup never creates, updates, retries publication of, or repairs those FAP resources.
The bundled question Skill and Function delivery are immutable release inputs for a separate FAP
publication workflow. Credentials and bindings must not enter the launcher manifest, Console
catalog, browser payloads, or logs.

In a Foggy source deployment, the host publisher must serialize the exact five projections from
`FapAnalyticsQuestionFunctionCatalog.publicationValues()`. Before its own dry-run/apply, validate
that export with `foggy-data-mcp-bridge/scripts/release/fap_question_publication_gate.py`. A pass
means only that the refs, schemas, and canonical digests match the release; the gate always reports
`mutationPerformed=false` and has no FAP credential or apply mode. The authenticated FAP host
management client remains responsible for appending immutable Function, Skill, and Capability
revisions. A missing host-publication manifest does not invalidate the already published launcher
`0.1.18`; that release is validated through its embedded schema delivery and Adapter catalog.

For static local development only, a deployment may configure the documented
`ANALYTICS_CONSOLE_FAP_*` server environment variables after FAP resources already exist. Never
present `static-dev-only` identity as a production security model.

## Query and model behavior

The bundled FAP question Skill describes the full queryModel DSL and restricted Compose/CTE
shapes shipped by that Console release. Live single-model Function calls pass only `namespace`,
`modelName`, `mode`, and business query `payload`. The Provider resolves the current valid model
once per call and holds that `CatalogResolution` stable through validation or execution.

Use a new FunctionRef such as `@v2` for an incompatible Function contract and a new `modelName`
for an incompatible model contract. Internal model/dependency digests can support bundle audit or
staleness detection, but they are not caller-visible model selection parameters.

## Production boundary

The standard start scripts advertise `none-dev-test-only` Runtime API security and the Console
profile uses `static-dev-only` authority. Do not expose that process directly to untrusted
networks. Production embedding requires authenticated host-managed subject and authority
resolvers, network controls, credential management, audit, and the normal Foggy query
sandbox/permission path.
